// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: UNLICENSED

// File contracts/interfaces/iDAO.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iDAO {
    function ROUTER() external view returns(address);
    function BASE() external view returns(address);
    function UTILS() external view returns(address);
    function DAO() external view returns (address);
    function RESERVE() external view returns(address);
    function BOND() external view returns (address);
    function SYNTHFACTORY() external view returns(address);
    function POOLFACTORY() external view returns(address);
    function depositForMember(address pool, uint256 amount, address member) external;
    function bondingPeriodSeconds() external returns (uint256);
}


// File contracts/interfaces/iBASE.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;

interface iBASE {
    function DAO() external view returns (iDAO);
    function secondsPerEra() external view returns (uint256);
    function changeDAO(address) external;
    function setParams(uint256, uint256) external;
    function flipEmissions() external;
    function mintFromDAO(uint256, address) external; 
    function burn(uint256) external; 
}


// File contracts/interfaces/iBEP20.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function burn(uint) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/interfaces/iPOOL.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iPOOL {
    function TOKEN() external view returns(address);
    function removeLiquidity() external returns (uint, uint);
    function genesis() external view returns(uint);
    function baseAmount() external view returns(uint);
    function tokenAmount() external view returns(uint);
    function fees() external view returns(uint);
    function volume() external view returns(uint);
    function txCount() external view returns(uint);
    function mintSynth(address, address) external returns (uint256, uint256);
}


// File contracts/interfaces/iPOOLFACTORY.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iPOOLFACTORY {
    function isCuratedPool(address) external view returns (bool);
    function addCuratedPool(address) external;
    function removeCuratedPool(address) external;
    function isPool(address) external returns (bool);
    function getPool(address) external view returns(address);
    function createPool(address) external view returns(address);
    function getPoolArray(uint) external view returns(address);
    function poolCount() external view returns(uint);
    function getToken(uint) external view returns(address);
    function tokenCount() external view returns(uint);
    function getCuratedPoolsLength() external view returns (uint);
}


// File contracts/interfaces/iROUTER.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iROUTER {
    function addLiquidityForMember(uint, uint, address, address) external payable returns (uint);
    function grantFunds(uint, address) external payable returns (bool);
    function changeArrayFeeSize(uint) external;
    function changeMaxTrades(uint) external;
    function addLiquidity(uint, uint, address) external payable returns (uint);
    function totalPooled() external view returns (uint);
    function totalVolume() external view returns (uint);
    function totalFees() external view returns (uint);
    function getPool(address) external view returns(address payable);
}


// File contracts/interfaces/iUTILS.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iUTILS {
    function calcShare(uint, uint, uint) external pure returns (uint);
    function getFeeOnTransfer(uint256, uint256) external view returns(uint);
    function getPoolShareWeight(address, uint)external view returns(uint);
    function calcAsymmetricValueBase(address, uint) external pure returns (uint);
    function calcAsymmetricValueToken(address, uint) external pure returns (uint);
    function calcLiquidityUnits(uint, uint, uint, uint, uint) external pure returns (uint);
    function calcLiquidityHoldings(uint, address, address) external pure returns (uint);
    function calcSwapOutput(uint, uint, uint) external pure returns (uint);
    function calcSwapFee(uint, uint, uint) external pure returns (uint);
    function calcSwapValueInBase(address, uint) external view returns (uint);
    function calcSpotValueInBaseWithPool(address, uint) external view returns (uint);
    function calcSpotValueInBase(address, uint) external view returns (uint);
    function calcSpotValueIn(address, uint) external view returns (uint);
    function calcPart(uint, uint) external pure returns (uint);
    function calcLiquidityUnitsAsym(uint, address)external pure returns (uint);
    function calcActualSynthUnits(uint amount, address synth) external view returns (uint);
}


// File contracts/BondVault.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;







contract BondVault {
    address public BASE;
    address public DEPLOYER;
    uint256 public totalWeight;
    bool private bondRelease;
    address [] public arrayMembers;

    struct ListedAssets {
        bool isListed;
        address[] members;
        mapping(address => bool) isMember;
        mapping(address => uint256) bondedLP;
        mapping(address => uint256) claimRate;
        mapping(address => uint256) lastBlockTime;
    }
    struct MemberDetails {
        bool isMember;
        uint256 bondedLP;
        uint256 claimRate;
        uint256 lastBlockTime;
    }

    mapping(address => ListedAssets) public mapBondAsset_memberDetails;
    mapping(address => uint256) private mapMember_weight; // Value of users weight (scope: user)
    mapping(address => mapping(address => uint256)) private mapMemberPool_weight; // Value of users weight (scope: pool)

    constructor (address _base) {
        BASE = _base;
        DEPLOYER = msg.sender;
        bondRelease = false;
    }

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER);
        _;
    }

    // Can purge deployer once DAO is stable and final
    function purgeDeployer() public onlyDAO {
        DEPLOYER = address(0);
    }

    // Get the current DAO address as reported by the BASE contract
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    // Deposit LPs in the BondVault for a user (Called from DAO)
    function depositForMember(address asset, address member, uint LPS) external onlyDAO returns(bool){
        if(!mapBondAsset_memberDetails[asset].isMember[member]){
            mapBondAsset_memberDetails[asset].isMember[member] = true; // Register user as member (scope: user -> asset)
            arrayMembers.push(member); // Add user to member array (scope: vault)
            mapBondAsset_memberDetails[asset].members.push(member); // Add user to member array (scope: user -> asset)
        }
        if(mapBondAsset_memberDetails[asset].bondedLP[member] != 0){
            claimForMember(asset, member); // Force claim if member has an existing remainder
        }
        mapBondAsset_memberDetails[asset].bondedLP[member] += LPS; // Add new deposit to users remainder
        mapBondAsset_memberDetails[asset].lastBlockTime[member] = block.timestamp; // Set lastBlockTime to current time
        mapBondAsset_memberDetails[asset].claimRate[member] = mapBondAsset_memberDetails[asset].bondedLP[member] / iDAO(_DAO().DAO()).bondingPeriodSeconds(); // Set claim rate per second
        increaseWeight(asset, member); // Update user's weight
        return true;
    }

    // Increase user's weight in the BondVault
    function increaseWeight(address asset, address member) internal{
        address pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(asset); // Get pool address
        if (mapMemberPool_weight[member][pool] > 0) {
            totalWeight -= mapMemberPool_weight[member][pool]; // Remove user weight from totalWeight (scope: vault)
            mapMember_weight[member] -= mapMemberPool_weight[member][pool]; // Remove user weight from totalWeight (scope: user)
            mapMemberPool_weight[member][pool] = 0; // Zero out user weight (scope: user -> pool)
        }
        uint256 weight = iUTILS(_DAO().UTILS()).getPoolShareWeight(asset, mapBondAsset_memberDetails[asset].bondedLP[member]); // Calculate user's bonded weight
        mapMemberPool_weight[member][pool] = weight; // Set new weight (scope: user -> pool)
        mapMember_weight[member] += weight; // Add new weight to totalWeight (scope: user)
        totalWeight += weight; // Add new weight to totalWeight (scope: vault)
    }

    // Calculate the user's current available claim amount
    function calcBondedLP(address member, address asset) public view returns (uint claimAmount){ 
        if(mapBondAsset_memberDetails[asset].isMember[member]){
            uint256 _secondsSinceClaim = block.timestamp - mapBondAsset_memberDetails[asset].lastBlockTime[member]; // Get seconds passed since last claim
            uint256 rate = mapBondAsset_memberDetails[asset].claimRate[member]; // Get user's claim rate
            claimAmount = _secondsSinceClaim * rate; // Set claim amount
            if(claimAmount >= mapBondAsset_memberDetails[asset].bondedLP[member] || bondRelease){
                claimAmount = mapBondAsset_memberDetails[asset].bondedLP[member]; // If final claim; set claimAmount as remainder
            }
            return claimAmount;
        }
    }

    // Perform a claim of the users's current available claim amount
    function claimForMember(address asset, address member) public onlyDAO returns (bool){
        require(mapBondAsset_memberDetails[asset].bondedLP[member] > 0, '!bonded'); // They must have remaining unclaimed LPs
        require(mapBondAsset_memberDetails[asset].isMember[member], '!member'); // They must be a member (scope: user -> asset)
        uint256 _claimable = calcBondedLP(member, asset); // Get the current claimable amount
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(asset); // Get the pool address
        mapBondAsset_memberDetails[asset].lastBlockTime[member] = block.timestamp; // Set lastBlockTime to current time
        mapBondAsset_memberDetails[asset].bondedLP[member] -= _claimable; // Remove the claim amount from the user's remainder
        if(_claimable == mapBondAsset_memberDetails[asset].bondedLP[member]){
            mapBondAsset_memberDetails[asset].claimRate[member] = 0; // If final claim; zero-out their claimRate
        }
        decreaseWeight(asset, member); // Update user's weight
        iBEP20(_pool).transfer(member, _claimable); // Send claim amount to user
        return true;
    }

    // Decrease user's weight in the BondVault
    function decreaseWeight(address asset, address member) internal {
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(asset); // Get pool address
        totalWeight -= mapMemberPool_weight[member][_pool]; // Remove user weight from totalWeight (scope: vault)
        mapMember_weight[member] -= mapMemberPool_weight[member][_pool]; // Remove user weight from totalWeight (scope: user)
        mapMemberPool_weight[member][_pool] = 0; // Zero out user weight (scope: user -> pool)
        uint256 weight = iUTILS(_DAO().UTILS()).getPoolShareWeight(asset, mapBondAsset_memberDetails[asset].bondedLP[member]); // Calculate user's bonded weight
        mapMemberPool_weight[member][_pool] = weight; // Set new weight (scope: user -> pool)
        mapMember_weight[member] += weight; // Add new weight to totalWeight (scope: user)
        totalWeight += weight; // // Add new weight to totalWeight (scope: vault)
    }

    // Get the total count of all existing & past BondVault members
    function memberCount() external view returns (uint256 count){
        return arrayMembers.length;
    }

    // Get array of all existing & past BondVault members
    function allMembers() external view returns (address[] memory _allMembers){
        return arrayMembers;
    }

    function release() external onlyDAO {
        bondRelease = true;
    }

    // Get a bond details (scope: user -> asset)
    function getMemberDetails(address member, address asset) external view returns (MemberDetails memory memberDetails){
        memberDetails.isMember = mapBondAsset_memberDetails[asset].isMember[member];
        memberDetails.bondedLP = mapBondAsset_memberDetails[asset].bondedLP[member];
        memberDetails.claimRate = mapBondAsset_memberDetails[asset].claimRate[member];
        memberDetails.lastBlockTime = mapBondAsset_memberDetails[asset].lastBlockTime[member];
        return memberDetails;
    }

    // Get a users's totalWeight (scope: user)
    function getMemberWeight(address member) external view returns (uint256) {
        if (mapMember_weight[member] > 0) {
            return mapMember_weight[member];
        } else {
            return 0;
        }
    } 
}


// File contracts/interfaces/iBONDVAULT.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iBONDVAULT{
 function depositForMember(address asset, address member, uint liquidityUnits) external;
 function claimForMember(address listedAsset, address member) external;
 function calcBondedLP(address bondedMember, address asset) external returns(uint);
 function getMemberWeight(address) external view returns (uint256);
 function totalWeight() external view returns (uint);
}


// File contracts/interfaces/iDAOVAULT.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iDAOVAULT{
function getMemberWeight(address) external view returns (uint256);
function depositLP(address, uint, address) external;
function withdraw(address, address) external returns (bool);
function totalWeight() external view returns (uint);
}


// File contracts/interfaces/iRESERVE.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iRESERVE {
    function grantFunds(uint, address) external; 
    function emissions() external returns(bool); 
}


// File contracts/interfaces/iSYNTHFACTORY.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iSYNTHFACTORY {
    function isSynth(address) external view returns (bool);
    function getSynth(address) external view returns (address);
}


// File contracts/interfaces/iSYNTHVAULT.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iSYNTHVAULT{

}


// File contracts/Dao.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;










contract Dao {
    address public DEPLOYER;
    address public BASE;

    uint256 public secondsPerEra;   // Amount of seconds per era (Inherited from BASE contract; intended to be ~1 day)
    uint256 public coolOffPeriod;   // Amount of time a proposal will need to be in finalising stage before it can be finalised
    uint256 public proposalCount;   // Count of proposals
    uint256 public majorityFactor;  // Number used to calculate majority; intended to be 6666bp === 2/3
    uint256 public erasToEarn;      // Amount of eras that make up the targeted RESERVE depletion; regulates incentives
    uint256 public daoClaim;        // The DAOVault's portion of rewards; intended to be ~10% initially
    uint256 public daoFee;          // The SPARTA fee for a user to create a new proposal, intended to be 100 SPARTA initially
    uint256 public currentProposal; // The most recent proposal; should be === proposalCount
    
    struct MemberDetails {
        bool isMember;
        uint weight;
        uint lastBlock;
        uint poolCount;
    }
    struct ProposalDetails {
        uint id;
        string proposalType;
        uint votes;
        uint coolOffTime;
        bool finalising;
        bool finalised;
        uint param;
        address proposedAddress;
        bool open;
        uint startTime;
    }

    bool public daoHasMoved;
    address public DAO;

    iROUTER private _ROUTER;
    iUTILS private _UTILS;
    iBONDVAULT private _BONDVAULT;
    iDAOVAULT private _DAOVAULT;
    iPOOLFACTORY private _POOLFACTORY;
    iSYNTHFACTORY private _SYNTHFACTORY;
    iRESERVE private _RESERVE;
    iSYNTHVAULT private _SYNTHVAULT;

    address[] public arrayMembers;
    address [] listedBondAssets; // Only used in UI; is intended to be a historical array of all past Bond listed assets
    uint256 public bondingPeriodSeconds = 15552000; // Vesting period for bonders (6 months)
    
    mapping(address => bool) public isMember;
    mapping(address => bool) public isListed; // Used internally to get CURRENT listed Bond assets
    mapping(address => uint256) public mapMember_lastTime;

    mapping(uint256 => uint256) public mapPID_param;
    mapping(uint256 => address) public mapPID_address;
    mapping(uint256 => string) public mapPID_type;
    mapping(uint256 => uint256) public mapPID_votes;
    mapping(uint256 => uint256) public mapPID_coolOffTime;
    mapping(uint256 => bool) public mapPID_finalising;
    mapping(uint256 => bool) public mapPID_finalised;
    mapping(uint256 => bool) public mapPID_open;
    mapping(uint256 => uint256) public mapPID_startTime;
    mapping(uint256 => mapping(address => uint256)) public mapPIDMember_votes;

    event MemberDeposits(address indexed member, address indexed pool, uint256 amount);
    event MemberWithdraws(address indexed member, address indexed pool, uint256 balance);

    event NewProposal(address indexed member, uint indexed proposalID, string proposalType);
    event NewVote(address indexed member, uint indexed proposalID, uint voteWeight, uint totalVotes, string proposalType);
    event RemovedVote(address indexed member, uint indexed proposalID, uint voteWeight, uint totalVotes, string proposalType);
    event ProposalFinalising(address indexed member, uint indexed proposalID, uint timeFinalised, string proposalType);
    event CancelProposal(address indexed member, uint indexed proposalID);
    event FinalisedProposal(address indexed member, uint indexed proposalID, uint votesCast, uint totalWeight, string proposalType);
    event ListedAsset(address indexed DAO, address indexed asset);
    event DelistedAsset(address indexed DAO, address indexed asset);
    event DepositAsset(address indexed owner, uint256 depositAmount, uint256 bondedLP);

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER);
        _;
    }

    constructor (address _base){
        BASE = _base;
        DEPLOYER = msg.sender;
        DAO = address(this);
        coolOffPeriod = 259200;
        erasToEarn = 30;
        majorityFactor = 6666;
        daoClaim = 1000;
        daoFee = 100;
        proposalCount = 0;
        secondsPerEra = iBASE(BASE).secondsPerEra();
    }

    //==================================== PROTOCOL CONTRACTs SETTER =================================//

    function setGenesisAddresses(address _router, address _utils, address _reserve) external onlyDAO {
        _ROUTER = iROUTER(_router);
        _UTILS = iUTILS(_utils);
        _RESERVE = iRESERVE(_reserve);
    }

    function setVaultAddresses(address _daovault, address _bondvault, address _synthVault) external onlyDAO {
        _DAOVAULT = iDAOVAULT(_daovault);
        _BONDVAULT = iBONDVAULT(_bondvault);
        _SYNTHVAULT = iSYNTHVAULT(_synthVault); 
    }
    
    function setFactoryAddresses(address _poolFactory, address _synthFactory) external onlyDAO {
        _POOLFACTORY = iPOOLFACTORY(_poolFactory);
        _SYNTHFACTORY = iSYNTHFACTORY(_synthFactory);
    }

    function setGenesisFactors(uint32 _coolOff, uint32 _daysToEarn, uint32 _majorityFactor, uint32 _daoClaim, uint32 _daoFee) external onlyDAO {
        coolOffPeriod = _coolOff;
        erasToEarn = _daysToEarn;
        majorityFactor = _majorityFactor;
        daoClaim = _daoClaim;
        daoFee = _daoFee;
    }

    // Can purge deployer once DAO is stable and final
    function purgeDeployer() external onlyDAO {
        DEPLOYER = address(0);
    }

    // Can change vesting period for bonders
    function changeBondingPeriod(uint256 bondingSeconds) external onlyDAO{
        bondingPeriodSeconds = bondingSeconds;
    }

    //============================== USER - DEPOSIT/WITHDRAW ================================//

    // User deposits LP tokens in the DAOVault
    function deposit(address pool, uint256 amount) external {
        depositLPForMember(pool, amount, msg.sender);
    }

    // Contract deposits LP tokens for member
    function depositLPForMember(address pool, uint256 amount, address member) public {
        require(_POOLFACTORY.isCuratedPool(pool) == true, "!curated"); // Pool must be Curated
        require(amount > 0, "!amount"); // Deposit amount must be valid
        if (isMember[member] != true) {
            arrayMembers.push(member); // If not a member; add user to member array
            isMember[member] = true; // If not a member; register the user as member
        }
        if((_DAOVAULT.getMemberWeight(member) + _BONDVAULT.getMemberWeight(member)) > 0) {
            harvest(); // If member has existing weight; force harvest to block manipulation of lastTime + harvest
        }
        require(iBEP20(pool).transferFrom(msg.sender, address(_DAOVAULT), amount), "!funds"); // Send user's deposit to the DAOVault
        _DAOVAULT.depositLP(pool, amount, member); // Update user's deposit balance & weight
        mapMember_lastTime[member] = block.timestamp; // Reset user's last harvest time
        emit MemberDeposits(member, pool, amount);
    }
    
    // User withdraws all of their selected asset from the DAOVault
    function withdraw(address pool) external {
        removeVote(); // Users weight is removed from the current open DAO proposal
        require(_DAOVAULT.withdraw(pool, msg.sender), "!transfer"); // User receives their withdrawal
    }

    //============================== REWARDS ================================//
    
    // User claims their DAOVault incentives
    function harvest() public {
        require(_RESERVE.emissions(), "!emissions"); // Reserve must have emissions turned on
        uint reward = calcCurrentReward(msg.sender); // Calculate the user's claimable incentive
        mapMember_lastTime[msg.sender] = block.timestamp; // Reset user's last harvest time
        uint reserve = iBEP20(BASE).balanceOf(address(_RESERVE)); // Get total BASE balance of RESERVE
        uint daoReward = (reserve * daoClaim) / 10000; // Get DAO's share of BASE balance of RESERVE (max user claim amount)
        if(reward > daoReward){
            reward = daoReward; // User cannot claim more than the daoReward limit
        }
        _RESERVE.grantFunds(reward, msg.sender); // Send the claim to the user
    }

    // Calculate the user's current incentive-claim per era
    function calcCurrentReward(address member) public view returns(uint){
        uint secondsSinceClaim = block.timestamp - mapMember_lastTime[member]; // Get seconds passed since last claim
        uint share = calcReward(member); // Get share of rewards for user
        uint reward = (share * secondsSinceClaim) / secondsPerEra; // User's share times eras since they last claimed
        return reward;
    }

    // Calculate the user's current total claimable incentive
    function calcReward(address member) public view returns(uint){
        uint weight = _DAOVAULT.getMemberWeight(member) + _BONDVAULT.getMemberWeight(member); // Get combined total weights (scope: user)
        uint _totalWeight = _DAOVAULT.totalWeight() + _BONDVAULT.totalWeight(); // Get combined total weights (scope: vaults)
        uint reserve = iBEP20(BASE).balanceOf(address(_RESERVE)) / erasToEarn; // Aim to deplete reserve over a number of days
        uint daoReward = (reserve * daoClaim) / 10000; // Get the DAO's share of that
        return _UTILS.calcShare(weight, _totalWeight, daoReward); // Get users's share of that (1 era worth)
    }

    //================================ BOND Feature ==================================//

    // Can burn the SPARTA remaining in this contract (Bond allocations held in the DAO)
    function burnBalance() external onlyDAO returns (bool){
        uint256 baseBal = iBEP20(BASE).balanceOf(address(this));
        iBASE(BASE).burn(baseBal);   
        return true;
    }

    // Can transfer the SPARTA remaining in this contract to a new DAO (If DAO is upgraded)
    function moveBASEBalance(address newDAO) external onlyDAO {
        uint256 baseBal = iBEP20(BASE).balanceOf(address(this));
        iBEP20(BASE).transfer(newDAO, baseBal);
    }

    // List an asset to be enabled for Bonding
    function listBondAsset(address asset) external onlyDAO {
        if(!isListed[asset]){
            isListed[asset] = true; // Register as a currently enabled asset
            listedBondAssets.push(asset); // Add to historical record of past Bond assets
        }
        emit ListedAsset(msg.sender, asset);
    }

    // Delist an asset from the Bond program
    function delistBondAsset(address asset) external onlyDAO {
        isListed[asset] = false; // Unregister as a currently enabled asset
        emit DelistedAsset(msg.sender, asset);
    }

    // User deposits assets to be Bonded
    function bond(address asset, uint256 amount) external payable returns (bool success) {
        require(amount > 0, '!amount'); // Amount must be valid
        require(isListed[asset], '!listed'); // Asset must be listed for Bond
        if (isMember[msg.sender] != true) {
            arrayMembers.push(msg.sender); // If user is not a member; add them to the member array
            isMember[msg.sender] = true; // Register user as a member
        }
        if((_DAOVAULT.getMemberWeight(msg.sender) + _BONDVAULT.getMemberWeight(msg.sender)) > 0) {
            harvest(); // If member has existing weight; force harvest to block manipulation of lastTime + harvest
        }
        uint256 liquidityUnits = handleTransferIn(asset, amount); // Add liquidity and calculate LP units
        _BONDVAULT.depositForMember(asset, msg.sender, liquidityUnits); // Deposit the Bonded LP units in the BondVault
        mapMember_lastTime[msg.sender] = block.timestamp; // Reset user's last harvest time
        emit DepositAsset(msg.sender, amount, liquidityUnits);
        return true;
    }

    // Add Bonded assets as liquidity and calculate LP units
    function handleTransferIn(address _token, uint _amount) internal returns (uint LPunits){
        uint256 spartaAllocation = _UTILS.calcSwapValueInBase(_token, _amount); // Get the SPARTA swap value of the bonded assets
        if(iBEP20(BASE).allowance(address(this), address(_ROUTER)) < spartaAllocation){
            iBEP20(BASE).approve(address(_ROUTER), iBEP20(BASE).totalSupply()); // Increase SPARTA allowance if required
        }
        if(_token == address(0)){
            require((_amount == msg.value), "!amount");
            LPunits = _ROUTER.addLiquidityForMember{value:_amount}(spartaAllocation, _amount, _token, address(_BONDVAULT)); // Add spartaAllocation & BNB as liquidity to mint LP tokens
        } else {
            iBEP20(_token).transferFrom(msg.sender, address(this), _amount); // Transfer user's assets to Dao contract
            if(iBEP20(_token).allowance(address(this), address(_ROUTER)) < _amount){
                uint256 approvalTNK = iBEP20(_token).totalSupply();
                iBEP20(_token).approve(address(_ROUTER), approvalTNK); // Increase allowance if required
            }
            LPunits = _ROUTER.addLiquidityForMember(spartaAllocation, _amount, _token, address(_BONDVAULT)); // Add spartaAllocation & assets as liquidity to mint LP tokens
        } 
    }

    // User claims all of their unlocked Bonded LPs
    function claimAllForMember(address member) external returns (bool){
        address [] memory listedAssets = listedBondAssets; // Get array of bond assets
        for(uint i = 0; i < listedAssets.length; i++){
            uint claimA = calcClaimBondedLP(member, listedAssets[i]); // Check user's unlocked Bonded LPs for each asset
            if(claimA > 0){
               _BONDVAULT.claimForMember(listedAssets[i], member); // Claim LPs if any unlocked
            }
        }
        return true;
    }

    // User claims unlocked Bond units of a selected asset
    function claimForMember(address asset) external returns (bool){
        uint claimA = calcClaimBondedLP(msg.sender, asset); // Check user's unlocked Bonded LPs
        if(claimA > 0){
            _BONDVAULT.claimForMember(asset, msg.sender); // Claim LPs if any unlocked
        }
        return true;
    }
    
    // Calculate user's unlocked Bond units of a selected asset
    function calcClaimBondedLP(address bondedMember, address asset) public returns (uint){
        uint claimAmount = _BONDVAULT.calcBondedLP(bondedMember, asset); // Check user's unlocked Bonded LPs
        return claimAmount;
    }

    //============================== CREATE PROPOSALS ================================//

    // New ID, but specify type, one type for each function call
    // Votes counted to IDs
    // IDs are finalised
    // IDs are executed, but type specifies unique logic

    // New DAO proposal: Simple action
    function newActionProposal(string memory typeStr) external returns(uint) {
        checkProposal(); // If no open proposal; construct new one
        payFee(); // Pay SPARTA fee for new proposal
        mapPID_type[currentProposal] = typeStr; // Set the proposal type
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }

    // New DAO proposal: uint parameter
    function newParamProposal(uint32 param, string memory typeStr) external returns(uint) {
        checkProposal(); // If no open proposal; construct new one
        payFee(); // Pay SPARTA fee for new proposal
        mapPID_param[currentProposal] = param; // Set the proposed parameter
        mapPID_type[currentProposal] = typeStr; // Set the proposal type
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }

    // New DAO proposal: Address parameter
    function newAddressProposal(address proposedAddress, string memory typeStr) external returns(uint) {
        checkProposal(); // If no open proposal; construct new one
        payFee(); // Pay SPARTA fee for new proposal
        mapPID_address[currentProposal] = proposedAddress; // Set the proposed new address
        mapPID_type[currentProposal] = typeStr; // Set the proposal type
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }

    // New DAO proposal: Grant SPARTA to wallet
    function newGrantProposal(address recipient, uint amount) external returns(uint) {
        checkProposal(); // If no open proposal; construct new one
        payFee(); // Pay SPARTA fee for new proposal
        string memory typeStr = "GRANT";
        mapPID_type[currentProposal] = typeStr; // Set the proposal type
        mapPID_address[currentProposal] = recipient; // Set the proposed grant recipient
        mapPID_param[currentProposal] = amount; // Set the proposed grant amount
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }

    // If no existing open DAO proposal; register a new one
    function checkProposal() internal {
        require(mapPID_open[currentProposal] == false, '!open'); // There must not be an existing open proposal
        proposalCount += 1; // Increase proposal count
        currentProposal = proposalCount; // Set current proposal to the new count
        mapPID_open[currentProposal] = true; // Set new proposal as open status
        mapPID_startTime[currentProposal] = block.timestamp; // Set the start time of the proposal to now
    }
    
    // Pay the fee for a new DAO proposal
    function payFee() internal returns(bool){
        uint _amount = daoFee*(10**18); // Convert DAO fee to WEI
        require(iBEP20(BASE).transferFrom(msg.sender, address(_RESERVE), _amount), '!fee'); // User pays the new proposal fee
        return true;
    } 

    //============================== VOTE && FINALISE ================================//

    // Vote for a proposal
    function voteProposal() external returns (uint voteWeight) {
        require(mapPID_open[currentProposal] == true, "!open"); // Proposal must be open status
        bytes memory _type = bytes(mapPID_type[currentProposal]); // Get the proposal type
        voteWeight = countVotes(); // Vote for proposal and recount
        if(hasQuorum(currentProposal) && mapPID_finalising[currentProposal] == false){
            if(isEqual(_type, 'DAO') || isEqual(_type, 'UTILS') || isEqual(_type, 'RESERVE') ||isEqual(_type, 'GET_SPARTA') || isEqual(_type, 'ROUTER') || isEqual(_type, 'LIST_BOND')|| isEqual(_type, 'GRANT')|| isEqual(_type, 'ADD_CURATED_POOL')){
                if(hasMajority(currentProposal)){
                    _finalise(); // Critical proposals require 'majority' consensus to enter finalization phase
                }
            } else {
                _finalise(); // Other proposals require 'quorum' consensus to enter finalization phase
            }
        }
        emit NewVote(msg.sender, currentProposal, voteWeight, mapPID_votes[currentProposal], string(_type));
    }

    // Remove vote from a proposal
    function removeVote() public returns (uint voteWeightRemoved){
        bytes memory _type = bytes(mapPID_type[currentProposal]); // Get the proposal type
        voteWeightRemoved = mapPIDMember_votes[currentProposal][msg.sender]; // Get user's current vote weight
        if(mapPID_open[currentProposal]){
            mapPID_votes[currentProposal] -= voteWeightRemoved; // Remove user's votes from propsal (scope: proposal)
        }
        mapPIDMember_votes[currentProposal][msg.sender] = 0; // Remove user's votes from propsal (scope: member)
        emit RemovedVote(msg.sender, currentProposal, voteWeightRemoved, mapPID_votes[currentProposal], string(_type));
        return voteWeightRemoved;
    }

    // Push the proposal into 'finalising' status
    function _finalise() internal {
        bytes memory _type = bytes(mapPID_type[currentProposal]); // Get the proposal type
        mapPID_finalising[currentProposal] = true; // Set finalising status to true
        mapPID_coolOffTime[currentProposal] = block.timestamp; // Set timestamp to calc cooloff time from
        emit ProposalFinalising(msg.sender, currentProposal, block.timestamp+coolOffPeriod, string(_type));
    }

    // Attempt to cancel the open proposal
    function cancelProposal() external {
        require(block.timestamp > (mapPID_startTime[currentProposal] + 1296000), "!days"); // Proposal must not be new
        mapPID_votes[currentProposal] = 0; // Clear all votes from the proposal
        mapPID_open[currentProposal] = false; // Set the proposal as not open (closed status)
        emit CancelProposal(msg.sender, currentProposal);
    }

    // A finalising-stage proposal can be finalised after the cool off period
    function finaliseProposal() external {
        require((block.timestamp - mapPID_coolOffTime[currentProposal]) > coolOffPeriod, "!cooloff"); // Must be past cooloff period
        require(mapPID_finalising[currentProposal] == true, "!finalising"); // Must be in finalising stage
        if(!hasQuorum(currentProposal)){
            mapPID_finalising[currentProposal] = false; // If proposal has lost quorum consensus; kick it out of the finalising stage
        } else {
            bytes memory _type = bytes(mapPID_type[currentProposal]); // Get the proposal type
            if(isEqual(_type, 'DAO')){
                moveDao(currentProposal);
            } else if (isEqual(_type, 'ROUTER')) {
                moveRouter(currentProposal);
            } else if (isEqual(_type, 'UTILS')){
                moveUtils(currentProposal);
            } else if (isEqual(_type, 'RESERVE')){
                moveReserve(currentProposal);
            } else if (isEqual(_type, 'FLIP_EMISSIONS')){
                flipEmissions(currentProposal);
            } else if (isEqual(_type, 'COOL_OFF')){
                changeCooloff(currentProposal);
            } else if (isEqual(_type, 'ERAS_TO_EARN')){
                changeEras(currentProposal);
            } else if (isEqual(_type, 'GRANT')){
                grantFunds(currentProposal);
            } else if (isEqual(_type, 'GET_SPARTA')){
                _increaseSpartaAllocation(currentProposal);
            } else if (isEqual(_type, 'LIST_BOND')){
                _listBondingAsset(currentProposal);
            } else if (isEqual(_type, 'DELIST_BOND')){
                _delistBondingAsset(currentProposal);
            } else if (isEqual(_type, 'ADD_CURATED_POOL')){
                _addCuratedPool(currentProposal);
            } else if (isEqual(_type, 'REMOVE_CURATED_POOL')){
                _removeCuratedPool(currentProposal);
            } 
        }
    }

    // Change the DAO to a new contract address
    function moveDao(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new address
        require(_proposedAddress != address(0), "!address"); // Proposed address must be valid
        DAO = _proposedAddress; // Change the DAO to point to the new DAO address
        iBASE(BASE).changeDAO(_proposedAddress); // Change the BASE contract to point to the new DAO address
        daoHasMoved = true; // Set status of this old DAO
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Change the ROUTER to a new contract address
    function moveRouter(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new address
        require(_proposedAddress != address(0), "!address"); // Proposed address must be valid
        _ROUTER = iROUTER(_proposedAddress); // Change the DAO to point to the new ROUTER address
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Change the UTILS to a new contract address
    function moveUtils(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new address
        require(_proposedAddress != address(0), "!address"); // Proposed address must be valid
        _UTILS = iUTILS(_proposedAddress); // Change the DAO to point to the new UTILS address
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Change the RESERVE to a new contract address
    function moveReserve(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new address
        require(_proposedAddress != address(0), "!address"); // Proposed address must be valid
        _RESERVE = iRESERVE(_proposedAddress); // Change the DAO to point to the new RESERVE address
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Flip the BASE emissions on/off
    function flipEmissions(uint _proposalID) internal {
        iBASE(BASE).flipEmissions(); // Toggle emissions on the BASE contract
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Change cool off period (Period of time until a finalising proposal can be finalised)
    function changeCooloff(uint _proposalID) internal {
        uint256 _proposedParam = mapPID_param[_proposalID]; // Get the proposed new param
        require(_proposedParam != 0, "!param"); // Proposed param must be valid
        coolOffPeriod = _proposedParam; // Change coolOffPeriod
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Change erasToEarn (Used to regulate the incentives flow)
    function changeEras(uint _proposalID) internal {
        uint256 _proposedParam = mapPID_param[_proposalID]; // Get the proposed new param
        require(_proposedParam != 0, "!param"); // Proposed param must be valid
        erasToEarn = _proposedParam; // Change erasToEarn
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Grant SPARTA to the proposed recipient
    function grantFunds(uint _proposalID) internal {
        uint256 _proposedAmount = mapPID_param[_proposalID]; // Get the proposed SPARTA grant amount
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed SPARTA grant recipient
        require(_proposedAmount != 0, "!param"); // Proposed grant amount must be valid
        require(_proposedAddress != address(0), "!address"); // Proposed recipient must be valid
        _RESERVE.grantFunds(_proposedAmount, _proposedAddress); // Grant the funds to the recipient
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Mint a 2.5M SPARTA allocation for the Bond program
    function _increaseSpartaAllocation(uint _proposalID) internal {
        uint256 _2point5m = 2.5*10**6*10**18; //_2.5m
        iBASE(BASE).mintFromDAO(_2point5m, address(this)); // Mint SPARTA and send to DAO to hold
        completeProposal(_proposalID); // Finalise the proposal
    }

    // List an asset to be enabled for Bonding
    function _listBondingAsset(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new asset
        if(!isListed[_proposedAddress]){
            isListed[_proposedAddress] = true; // Register asset as listed for Bond
            listedBondAssets.push(_proposedAddress); // Add asset to array of listed Bond assets
        }
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Delist an asset from being allowed to Bond
    function _delistBondingAsset(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new asset
        isListed[_proposedAddress] = false; // Unregister asset as listed for Bond (Keep it in the array though; as this is used in the UI)
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Add a pool as 'Curated' to enable synths, weight and incentives
    function _addCuratedPool(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed new asset
        _POOLFACTORY.addCuratedPool(_proposedAddress); // Add the pool as Curated
        completeProposal(_proposalID); // Finalise the proposal
    }

    // Remove a pool from Curated status
    function _removeCuratedPool(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; // Get the proposed asset for removal
        _POOLFACTORY.removeCuratedPool(_proposedAddress); // Remove pool as Curated
        completeProposal(_proposalID); // Finalise the proposal
    }
    
    // After completing the proposal's action; close it
    function completeProposal(uint _proposalID) internal {
        string memory _typeStr = mapPID_type[_proposalID]; // Get proposal type
        emit FinalisedProposal(msg.sender, _proposalID, mapPID_votes[_proposalID], _DAOVAULT.totalWeight(), _typeStr);
        mapPID_votes[_proposalID] = 0; // Reset proposal votes to 0
        mapPID_finalised[_proposalID] = true; // Finalise the proposal
        mapPID_finalising[_proposalID] = false; // Remove proposal from 'finalising' stage
        mapPID_open[_proposalID] = false; // Close the proposal
    }

    //============================== CONSENSUS ================================//
    
    // Add user's total weight to proposal and recount
    function countVotes() internal returns (uint voteWeight){
        mapPID_votes[currentProposal] -= mapPIDMember_votes[currentProposal][msg.sender]; // Remove user's current votes from the open proposal
        voteWeight = _DAOVAULT.getMemberWeight(msg.sender) + _BONDVAULT.getMemberWeight(msg.sender); // Get user's combined total weights
        mapPID_votes[currentProposal] += voteWeight; // Add user's total weight to the current open proposal (scope: proposal)
        mapPIDMember_votes[currentProposal][msg.sender] = voteWeight; // Add user's total weight to the current open proposal (scope: member)
        return voteWeight;
    }

    // Check if a proposal has Majority consensus
    function hasMajority(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID]; // Get the proposal's total voting weight
        uint _totalWeight = _DAOVAULT.totalWeight() + _BONDVAULT.totalWeight(); // Get combined total vault weights
        uint consensus = _totalWeight * majorityFactor / 10000; // Majority > 66.6%
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }

    // Check if a proposal has Quorum consensus
    function hasQuorum(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID]; // Get the proposal's total voting weight
        uint _totalWeight = _DAOVAULT.totalWeight()  + _BONDVAULT.totalWeight(); // Get combined total vault weights
        uint consensus = _totalWeight / 2; // Quorum > 50%
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }

    // Check if a proposal has Minority consensus
    function hasMinority(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID]; // Get the proposal's total voting weight
        uint _totalWeight = _DAOVAULT.totalWeight()  + _BONDVAULT.totalWeight(); // Get combined total vault weights
        uint consensus = _totalWeight / 6; // Minority > 16.6%
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }

    //======================================PROTOCOL CONTRACTs GETTER=================================//
    
    // Get the ROUTER address that the DAO currently points to
    function ROUTER() public view returns(iROUTER){
        if(daoHasMoved){
            return Dao(DAO).ROUTER();
        } else {
            return _ROUTER;
        }
    }

    // Get the UTILS address that the DAO currently points to
    function UTILS() public view returns(iUTILS){
        if(daoHasMoved){
            return Dao(DAO).UTILS();
        } else {
            return _UTILS;
        }
    }

    // Get the BONDVAULT address that the DAO currently points to
    function BONDVAULT() public view returns(iBONDVAULT){
        if(daoHasMoved){
            return Dao(DAO).BONDVAULT();
        } else {
            return _BONDVAULT;
        }
    }

    // Get the DAOVAULT address that the DAO currently points to
    function DAOVAULT() public view returns(iDAOVAULT){
        if(daoHasMoved){
            return Dao(DAO).DAOVAULT();
        } else {
            return _DAOVAULT;
        }
    }

    // Get the POOLFACTORY address that the DAO currently points to
    function POOLFACTORY() public view returns(iPOOLFACTORY){
        if(daoHasMoved){
            return Dao(DAO).POOLFACTORY();
        } else {
            return _POOLFACTORY;
        }
    }

    // Get the SYNTHFACTORY address that the DAO currently points to
    function SYNTHFACTORY() public view returns(iSYNTHFACTORY){
        if(daoHasMoved){
            return Dao(DAO).SYNTHFACTORY();
        } else {
            return _SYNTHFACTORY;
        }
    }

    // Get the RESERVE address that the DAO currently points to
    function RESERVE() public view returns(iRESERVE){
        if(daoHasMoved){
            return Dao(DAO).RESERVE();
        } else {
            return _RESERVE;
        }
    }

    // Get the SYNTHVAULT address that the DAO currently points to
    function SYNTHVAULT() public view returns(iSYNTHVAULT){
        if(daoHasMoved){
            return Dao(DAO).SYNTHVAULT();
        } else {
            return _SYNTHVAULT;
        }
    }

    //============================== HELPERS ================================//
    
    function memberCount() external view returns(uint){
        return arrayMembers.length;
    }

    function getProposalDetails(uint proposalID) external view returns (ProposalDetails memory proposalDetails){
        proposalDetails.id = proposalID;
        proposalDetails.proposalType = mapPID_type[proposalID];
        proposalDetails.votes = mapPID_votes[proposalID];
        proposalDetails.coolOffTime = mapPID_coolOffTime[proposalID];
        proposalDetails.finalising = mapPID_finalising[proposalID];
        proposalDetails.finalised = mapPID_finalised[proposalID];
        proposalDetails.param = mapPID_param[proposalID];
        proposalDetails.proposedAddress = mapPID_address[proposalID];
        proposalDetails.open = mapPID_open[proposalID];
        proposalDetails.startTime = mapPID_startTime[proposalID];
        return proposalDetails;
    }

    function assetListedCount() external view returns (uint256 count){
        return listedBondAssets.length;
    }

    function allListedAssets() external view returns (address[] memory _allListedAssets){
        return listedBondAssets;
    }
    
    function isEqual(bytes memory part1, bytes memory part2) private pure returns(bool){
        if(sha256(part1) == sha256(part2)){
            return true;
        } else {
            return false;
        }
    }
}


// File contracts/DaoVault.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;







contract DaoVault {
    address public BASE;
    address public DEPLOYER;
    uint256 public totalWeight; // Total weight of the whole DAOVault

    constructor(address _base) {
        BASE = _base;
        DEPLOYER = msg.sender;
    }

    mapping(address => uint256) private mapMember_weight; // Member's total weight in DAOVault
    mapping(address => mapping(address => uint256)) private mapMemberPool_balance; // Member's LPs locked in DAOVault
    mapping(address => mapping(address => uint256)) public mapMember_depositTime; // Timestamp when user last deposited
    mapping(address => mapping(address => uint256)) private mapMemberPool_weight; // Member's total weight in DOAVault (scope: pool)

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER, "!DAO");
        _;
    }

    function _DAO() internal view returns (iDAO) {
        return iBASE(BASE).DAO();
    }

    // User despoits LP tokens in the DAOVault
    function depositLP(address pool, uint256 amount, address member) external onlyDAO returns (bool) {
        mapMemberPool_balance[member][pool] += amount; // Updated user's vault balance
        increaseWeight(pool, member); // Recalculate user's DAOVault weights
        return true;
    }

    // Update a member's weight in the DAOVault (scope: pool)
    function increaseWeight(address pool, address member) internal returns (uint256){
        if (mapMemberPool_weight[member][pool] > 0) {
            totalWeight -= mapMemberPool_weight[member][pool]; // Remove user's previous weight (scope: vault)
            mapMember_weight[member] -= mapMemberPool_weight[member][pool]; // Remove user's previous weight (scope: member -> pool)
            mapMemberPool_weight[member][pool] = 0; // Reset user's weight to zero (scope: member -> pool)
        }
        uint256 weight = iUTILS(_DAO().UTILS()).getPoolShareWeight(iPOOL(pool).TOKEN(), mapMemberPool_balance[member][pool]); // Get user's current weight
        mapMemberPool_weight[member][pool] = weight; // Set user's new weight (scope: member -> pool)
        mapMember_weight[member] += weight; // Set user's new total weight (scope: member)
        totalWeight += weight; // Add user's new weight to the total weight (scope: DAOVault)
        mapMember_depositTime[member][pool] = block.timestamp; // Set user's new last-deposit-time
        return weight;
    }

    // Update a member's weight in the DAOVault (scope: pool)
    function decreaseWeight(address pool, address member) internal {
        uint256 weight = mapMemberPool_weight[member][pool]; // Get user's previous weight
        mapMemberPool_balance[member][pool] = 0; // Zero out user's balance (scope: member -> pool)
        mapMemberPool_weight[member][pool] = 0; // Zero out user's weight (scope: member -> pool)
        totalWeight -= weight; // Remove user's previous weight from the total weight (scope: DAOVault)
        mapMember_weight[member] -= weight; // Remove user's previous weight from their total weight (scope: member)
    }

    // Withdraw 100% of user's LPs from their DAOVault
    function withdraw(address pool, address member) external onlyDAO returns (bool){
        require(block.timestamp > (mapMember_depositTime[member][pool] + 86400), '!unlocked'); // 1 day must have passed since last deposit (lockup period)
        uint256 _balance = mapMemberPool_balance[member][pool]; // Get user's whole balance (scope: member -> pool)
        require(_balance > 0, "!balance"); // Withdraw amount must be valid
        decreaseWeight(pool, member); // Recalculate user's DAOVault weights
        require(iBEP20(pool).transfer(member, _balance), "!transfer"); // Transfer user's balance to their wallet
        return true;
    }

    // Get user's current total DAOVault weight
    function getMemberWeight(address member) external view returns (uint256) {
        if (mapMember_weight[member] > 0) {
            return mapMember_weight[member];
        } else {
            return 0;
        }
    }

    // Get user's current balance of a chosen asset
    function getMemberPoolBalance(address pool, address member)  external view returns (uint256){
        return mapMemberPool_balance[member][pool];
    }

    // Get user's current DAOVault weight from a chosen asset
    function getMemberPoolWeight(address pool, address member) external view returns (uint256){
        return mapMemberPool_weight[member][pool];
    }
}


// File contracts/interfaces/iBEP677.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;

interface iBEP677 {
 function onTokenApproval(address token, uint amount, address member,bytes calldata data) external;
 function onTokenTransfer(address token, uint amount, address member,bytes calldata data) external;
}


// File contracts/interfaces/iSYNTH.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iSYNTH {
    function genesis() external view returns(uint);
    function totalMinted() external view returns(uint);
    function LayerONE()external view returns(address);
    function mintSynth(address, uint) external returns (uint256);
    function burnSynth() external returns(uint);
    function realise(address pool) external;
}


// File contracts/Pool.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;









contract Pool is iBEP20 {  
    address public BASE;
    address public TOKEN;
    address public DEPLOYER;

    string _name; string _symbol;
    uint8 public override decimals; uint256 public override totalSupply;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    uint256 public baseAmount; // SPARTA amount that should be in the pool
    uint256 public tokenAmount; // TOKEN amount that should be in the pool

    uint private lastMonth; // Timestamp of the start of current metric period (For UI)
    uint public genesis; // Timestamp from when the pool was first deployed (For UI)

    uint256 public map30DPoolRevenue; // Tally of revenue during current incomplete metric period (for UI)
    uint256 public mapPast30DPoolRevenue; // Tally of revenue from last full metric period (for UI)
    uint256 [] public revenueArray; // Array of the last two metric periods (For UI)

    event AddLiquidity(address indexed member, uint inputBase, uint inputToken, uint unitsIssued);
    event RemoveLiquidity(address indexed member, uint outputBase, uint outputToken, uint unitsClaimed);
    event Swapped(address indexed tokenFrom, address indexed tokenTo, address indexed recipient, uint inputAmount, uint outputAmount, uint fee);
    event MintSynth(address indexed member, address indexed base, uint256 baseAmount, address indexed token, uint256 synthAmount);
    event BurnSynth(address indexed member, address indexed base, uint256 baseAmount, address indexed token, uint256 synthAmount);

    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    constructor (address _base, address _token) {
        BASE = _base;
        TOKEN = _token;
        string memory poolName = "-SpartanProtocolPool";
        string memory poolSymbol = "-SPP";
        _name = string(abi.encodePacked(iBEP20(_token).name(), poolName));
        _symbol = string(abi.encodePacked(iBEP20(_token).symbol(), poolSymbol));
        decimals = 18;
        genesis = block.timestamp;
        DEPLOYER = msg.sender;
        lastMonth = 0;
    }

    //========================================iBEP20=========================================//

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "!approval");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "!owner");
        require(spender != address(0), "!spender");
        if (_allowances[owner][spender] < type(uint256).max) { // No need to re-approve if already max
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
    }

    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        // Max approval (saves an SSTORE)
        if (_allowances[sender][msg.sender] < type(uint256).max) {
            uint256 currentAllowance = _allowances[sender][msg.sender];
            require(currentAllowance >= amount, "!approval");
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    //iBEP677 approveAndCall
    function approveAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
      _approve(msg.sender, recipient, type(uint256).max); // Give recipient max approval
      iBEP677(recipient).onTokenApproval(address(this), amount, msg.sender, data); // Amount is passed thru to recipient
      return true;
    }

    //iBEP677 transferAndCall
    function transferAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
      _transfer(msg.sender, recipient, amount);
      iBEP677(recipient).onTokenTransfer(address(this), amount, msg.sender, data); // Amount is passed thru to recipient 
      return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "!sender");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "!balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) external virtual override {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external virtual {  
        uint256 decreasedAllowance = allowance(account, msg.sender) - (amount);
        _approve(account, msg.sender, decreasedAllowance); 
        _burn(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        require(_balances[account] >= amount, "!balance");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    //====================================POOL FUNCTIONS =================================//

    // User adds liquidity to the pool
    function add() external returns(uint liquidityUnits){
        liquidityUnits = addForMember(msg.sender);
        return liquidityUnits;
    }

    // Contract adds liquidity for user 
    function addForMember(address member) public returns(uint liquidityUnits){
        uint256 _actualInputBase = _getAddedBaseAmount(); // Get the received SPARTA amount
        uint256 _actualInputToken = _getAddedTokenAmount(); // Get the received TOKEN amount
        if(baseAmount == 0 || tokenAmount == 0){
        require(_actualInputBase != 0 && _actualInputToken != 0, "!Balanced");
        }
        liquidityUnits = iUTILS(_DAO().UTILS()).calcLiquidityUnits(_actualInputBase, baseAmount, _actualInputToken, tokenAmount, totalSupply); // Calculate LP tokens to mint
        _incrementPoolBalances(_actualInputBase, _actualInputToken); // Update recorded BASE and TOKEN amounts
        _mint(member, liquidityUnits); // Mint the LP tokens directly to the user
        emit AddLiquidity(member, _actualInputBase, _actualInputToken, liquidityUnits);
        return liquidityUnits;
    }
    
    // User removes liquidity from the pool 
    function remove() external returns (uint outputBase, uint outputToken) {
        return removeForMember(msg.sender);
    } 

    // Contract removes liquidity for the user
    function removeForMember(address member) public returns (uint outputBase, uint outputToken) {
        uint256 _actualInputUnits = balanceOf(address(this)); // Get the received LP units amount
        outputBase = iUTILS(_DAO().UTILS()).calcLiquidityHoldings(_actualInputUnits, BASE, address(this)); // Get the SPARTA value of LP units
        outputToken = iUTILS(_DAO().UTILS()).calcLiquidityHoldings(_actualInputUnits, TOKEN, address(this)); // Get the TOKEN value of LP units
        _decrementPoolBalances(outputBase, outputToken); // Update recorded BASE and TOKEN amounts
        _burn(address(this), _actualInputUnits); // Burn the LP tokens
        iBEP20(BASE).transfer(member, outputBase); // Transfer the SPARTA to user
        iBEP20(TOKEN).transfer(member, outputToken); // Transfer the TOKENs to user
        emit RemoveLiquidity(member, outputBase, outputToken, _actualInputUnits);
        return (outputBase, outputToken);
    }

    // Caller swaps tokens
    function swap(address token) external returns (uint outputAmount, uint fee){
        (outputAmount, fee) = swapTo(token, msg.sender);
        return (outputAmount, fee);
    }

    // Contract swaps tokens for the member
    function swapTo(address token, address member) public payable returns (uint outputAmount, uint fee) {
        require((token == BASE || token == TOKEN), "!BASE||TOKEN"); // Must be SPARTA or the pool's relevant TOKEN
        address _fromToken; uint _amount;
        if(token == BASE){
            _fromToken = TOKEN; // If SPARTA is selected; swap from TOKEN
            _amount = _getAddedTokenAmount(); // Get the received TOKEN amount
            (outputAmount, fee) = _swapTokenToBase(_amount); // Calculate the SPARTA output from the swap
        } else {
            _fromToken = BASE; // If TOKEN is selected; swap from SPARTA
            _amount = _getAddedBaseAmount(); // Get the received SPARTA amount
            (outputAmount, fee) = _swapBaseToToken(_amount); // Calculate the TOKEN output from the swap
        }
        emit Swapped(_fromToken, token, member, _amount, outputAmount, fee);
        iBEP20(token).transfer(member, outputAmount); // Transfer the swap output to the selected user
        return (outputAmount, fee);
    }

    // Swap SPARTA for Synths
    function mintSynth(address synthOut, address member) external returns(uint outputAmount, uint fee) {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synthOut) == true, "!synth"); // Must be a valid Synth
        uint256 _actualInputBase = _getAddedBaseAmount(); // Get received SPARTA amount
        uint output = iUTILS(_DAO().UTILS()).calcSwapOutput(_actualInputBase, baseAmount, tokenAmount); // Calculate value of swapping SPARTA to the relevant underlying TOKEN
        uint _liquidityUnits = iUTILS(_DAO().UTILS()).calcLiquidityUnitsAsym(_actualInputBase, address(this)); // Calculate LP tokens to be minted
        _incrementPoolBalances(_actualInputBase, 0); // Update recorded SPARTA amount
        uint _fee = iUTILS(_DAO().UTILS()).calcSwapFee(_actualInputBase, baseAmount, tokenAmount); // Calc slip fee in TOKEN
        fee = iUTILS(_DAO().UTILS()).calcSpotValueInBase(TOKEN, _fee); // Convert TOKEN fee to SPARTA
        _mint(synthOut, _liquidityUnits); // Mint the LP tokens directly to the Synth contract to hold
        iSYNTH(synthOut).mintSynth(member, output); // Mint the Synth tokens directly to the user
        _addPoolMetrics(fee); // Add slip fee to the revenue metrics
        emit MintSynth(member, BASE, _actualInputBase, TOKEN, outputAmount);
      return (output, fee);
    }
    
    // Swap Synths for SPARTA
    function burnSynth(address synthIN, address member) external returns(uint outputAmount, uint fee) {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synthIN) == true, "!synth"); // Must be a valid Synth
        uint _actualInputSynth = iBEP20(synthIN).balanceOf(address(this)); // Get received SYNTH amount
        uint outputBase = iUTILS(_DAO().UTILS()).calcSwapOutput(_actualInputSynth, tokenAmount, baseAmount); // Calculate value of swapping relevant underlying TOKEN to SPARTA
        fee = iUTILS(_DAO().UTILS()).calcSwapFee(_actualInputSynth, tokenAmount, baseAmount); // Calc slip fee in SPARTA
        iBEP20(synthIN).transfer(synthIN, _actualInputSynth); // Transfer SYNTH to relevant synth contract
        iSYNTH(synthIN).burnSynth(); // Burn the SYNTH units
        _decrementPoolBalances(outputBase, 0); // Update recorded SPARTA amount
        iBEP20(BASE).transfer(member, outputBase); // Transfer SPARTA to user
        _addPoolMetrics(fee); // Add slip fee to the revenue metrics
        emit BurnSynth(member, BASE, outputBase, TOKEN, _actualInputSynth);
      return (outputBase, fee);
    }

    //=======================================INTERNAL MATHS======================================//

    // Check the SPARTA amount received by this Pool
    function _getAddedBaseAmount() internal view returns(uint256 _actual){
        uint _baseBalance = iBEP20(BASE).balanceOf(address(this)); 
        if(_baseBalance > baseAmount){
            _actual = _baseBalance-(baseAmount);
        } else {
            _actual = 0;
        }
        return _actual;
    }
  
    // Check the TOKEN amount received by this Pool
    function _getAddedTokenAmount() internal view returns(uint256 _actual){
        uint _tokenBalance = iBEP20(TOKEN).balanceOf(address(this)); 
        if(_tokenBalance > tokenAmount){
            _actual = _tokenBalance-(tokenAmount);
        } else {
            _actual = 0;
        }
        return _actual;
    }

    // Calculate output of swapping SPARTA for TOKEN & update recorded amounts
    function _swapBaseToToken(uint256 _x) internal returns (uint256 _y, uint256 _fee){
        uint256 _X = baseAmount;
        uint256 _Y = tokenAmount;
        _y =  iUTILS(_DAO().UTILS()).calcSwapOutput(_x, _X, _Y); // Calc TOKEN output
        uint fee = iUTILS(_DAO().UTILS()).calcSwapFee(_x, _X, _Y); // Calc TOKEN fee
        _fee = iUTILS(_DAO().UTILS()).calcSpotValueInBase(TOKEN, fee); // Convert TOKEN fee to SPARTA
        _setPoolAmounts(_X + _x, _Y - _y); // Update recorded BASE and TOKEN amounts
        _addPoolMetrics(_fee); // Add slip fee to the revenue metrics
        return (_y, _fee);
    }

    // Calculate output of swapping TOKEN for SPARTA & update recorded amounts
    function _swapTokenToBase(uint256 _x) internal returns (uint256 _y, uint256 _fee){
        uint256 _X = tokenAmount;
        uint256 _Y = baseAmount;
        _y =  iUTILS(_DAO().UTILS()).calcSwapOutput(_x, _X, _Y); // Calc SPARTA output
        _fee = iUTILS(_DAO().UTILS()).calcSwapFee(_x, _X, _Y); // Calc SPARTA fee
        _setPoolAmounts(_Y - _y, _X + _x); // Update recorded BASE and TOKEN amounts
        _addPoolMetrics(_fee); // Add slip fee to the revenue metrics
        return (_y, _fee);
    }

    //=======================================BALANCES=========================================//

    // Sync internal balances to actual
    function sync() external {
        baseAmount = iBEP20(BASE).balanceOf(address(this));
        tokenAmount = iBEP20(TOKEN).balanceOf(address(this));
    }

    // Increment internal balances
    function _incrementPoolBalances(uint _baseAmount, uint _tokenAmount) internal  {
        baseAmount += _baseAmount;
        tokenAmount += _tokenAmount;
    }

    // Set internal balances
    function _setPoolAmounts(uint256 _baseAmount, uint256 _tokenAmount) internal  {
        baseAmount = _baseAmount;
        tokenAmount = _tokenAmount; 
    }

    // Decrement internal balances
    function _decrementPoolBalances(uint _baseAmount, uint _tokenAmount) internal  {
        baseAmount -= _baseAmount;
        tokenAmount -= _tokenAmount; 
    }

    //===========================================POOL FEE ROI=================================//

    function _addPoolMetrics(uint256 _fee) internal {
        if(lastMonth == 0){
            lastMonth = block.timestamp;
        }
        if(block.timestamp <= lastMonth + 2592000){ // 30Days
            map30DPoolRevenue = map30DPoolRevenue+(_fee);
        } else {
            lastMonth = block.timestamp;
            mapPast30DPoolRevenue = map30DPoolRevenue;
            addRevenue(mapPast30DPoolRevenue);
            map30DPoolRevenue = 0;
            map30DPoolRevenue = map30DPoolRevenue+(_fee);
        }
    }

    function addRevenue(uint _totalRev) internal {
        if(!(revenueArray.length == 2)){
            revenueArray.push(_totalRev);
        } else {
            addFee(_totalRev);
        }
    }

    function addFee(uint _rev) internal {
        uint _n = revenueArray.length; // 2
        for (uint i = _n - 1; i > 0; i--) {
            revenueArray[i] = revenueArray[i - 1];
        }
        revenueArray[0] = _rev;
    }
}


// File contracts/poolFactory.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;


contract PoolFactory { 
    address public BASE;
    address public WBNB;
    address public DEPLOYER;
    uint public curatedPoolSize;    // Max amount of pools that can be curated status
    address[] public arrayPools;    // Array of all deployed pools
    address[] public arrayTokens;   // Array of all listed tokens

    mapping(address=>address) private mapToken_Pool;
    mapping(address=>bool) public isListedPool;
    mapping(address=>bool) public isCuratedPool;

    event CreatePool(address indexed token, address indexed pool);
    event AddCuratePool(address indexed pool, bool Curated);
    event RemoveCuratePool(address indexed pool, bool Curated);

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER || msg.sender == _DAO().DAO());
        _;
    }

    constructor (address _base, address _wbnb) {
        BASE = _base;
        WBNB = _wbnb;
        curatedPoolSize = 10;
        DEPLOYER = msg.sender;
    }

    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    // Can purge deployer once DAO is stable and final
    function purgeDeployer() external onlyDAO {
        DEPLOYER = address(0);
    }

    // Anyone can create a pool and add liquidity at the same time
    function createPoolADD(uint256 inputBase, uint256 inputToken, address token) external payable returns(address pool){
        require(getPool(token) == address(0)); // Must be a valid token
        require((inputToken > 0 && inputBase >= (10000*10**18)), "!min"); // User must add at least 10,000 SPARTA liquidity & ratio must be finite
        Pool newPool; address _token = token;
        if(token == address(0)){_token = WBNB;} // Handle BNB -> WBNB
        require(_token != BASE && iBEP20(_token).decimals() == 18); // Token must not be SPARTA & it's decimals must be 18
        newPool = new Pool(BASE, _token); // Deploy new pool
        pool = address(newPool); // Get address of new pool
        mapToken_Pool[_token] = pool; // Record the new pool address in PoolFactory
        _handleTransferIn(BASE, inputBase, pool); // Transfer SPARTA liquidity to new pool
        _handleTransferIn(token, inputToken, pool); // Transfer TOKEN liquidity to new pool
        arrayPools.push(pool); // Add pool address to the pool array
        arrayTokens.push(_token); // Add token to the listed array
        isListedPool[pool] = true; // Record pool as currently listed
        Pool(pool).addForMember(msg.sender); // Perform the liquidity-add for the user
        emit CreatePool(token, pool);
        return pool;
    }

    // Can create pools initially with no liquidity (not public)
    function createPool(address token) external onlyDAO returns(address pool){
        require(getPool(token) == address(0)); // Must be a valid token
        Pool newPool; address _token = token;
        if(token == address(0)){_token = WBNB;} // Handle BNB -> WBNB
        newPool = new Pool(BASE, _token); // Deploy new pool
        pool = address(newPool); // Get address of new pool
        mapToken_Pool[_token] = pool; // Record the new pool address in PoolFactory
        arrayPools.push(pool); // Add pool address to the pool array
        arrayTokens.push(_token); // Add token to the listed array
        isListedPool[pool] = true; // Record pool as currently listed
        emit CreatePool(token, pool);
        return pool;
    }

    // Add pool to the Curated list, enabling it's synths & dividends & dao/vault weight
    function addCuratedPool(address token) external onlyDAO {
        require(token != BASE); // Token must not be SPARTA
        address _pool = getPool(token); // Get pool address
        require(isListedPool[_pool] == true); // Pool must be valid
        require(curatedPoolCount() < curatedPoolSize, "maxCurated"); // Must be room in the Curated list
        isCuratedPool[_pool] = true; // Record pool as Curated
        emit AddCuratePool(_pool, isCuratedPool[_pool]);
    }

    // Remove pool from the Curated list
    function removeCuratedPool(address token) external onlyDAO {
        require(token != BASE); // Token must not be SPARTA
        address _pool = getPool(token); // Get pool address
        require(isCuratedPool[_pool] == true); // Pool must be Curated
        isCuratedPool[_pool] = false; // Record pool as not curated
        emit RemoveCuratePool(_pool, isCuratedPool[_pool]);
    }

    function curatedPoolCount() internal view returns (uint){
        uint cPoolCount; 
        for(uint i = 0; i< arrayPools.length; i++){
            if(isCuratedPool[arrayPools[i]] == true){
                cPoolCount += 1;
            }
        }
        return cPoolCount;
    }

    // Transfer assets into new pool
    function _handleTransferIn(address _token, uint256 _amount, address _pool) internal returns(uint256 actual){
        if(_amount > 0) {
            uint startBal = iBEP20(_token).balanceOf(_pool); 
            iBEP20(_token).transferFrom(msg.sender, _pool, _amount); 
            actual = iBEP20(_token).balanceOf(_pool) - (startBal);
        }
    }

    //======================================HELPERS========================================//

    function getPool(address token) public view returns(address pool){
        if(token == address(0)){
            pool = mapToken_Pool[WBNB];   // Handle BNB
        } else {
            pool = mapToken_Pool[token];  // Handle normal token
        } 
        return pool;
    }

    function isPool(address pool) external view returns (bool){
        if(isListedPool[pool] == true){
            return true;
        }
        return  false;
    }

    function poolCount() external view returns(uint256){
        return arrayPools.length;
    }

    function tokenCount() external view returns(uint256){
        return arrayTokens.length;
    }

    function getToken(uint256 i) external view returns(address){
        return arrayTokens[i];
    }

    function getPoolArray(uint256 i) external view returns(address){
        return arrayPools[i];
    }
}


// File contracts/interfaces/iWBNB.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iWBNB {
    function withdraw(uint256) external;
}


// File contracts/Router.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;




contract Router {
    address public BASE;
    address public WBNB;
    address public DEPLOYER;

    uint private maxTrades;         // Amount of dividend events per era
    uint private eraLength;         // Dividend factor to regulate the max percentage of RESERVE balance
    uint public normalAverageFee;   // The average fee size (dividend smoothing)
    uint private arrayFeeSize;      // The size of the average window used for normalAverageFee
    uint [] private feeArray;       // The array used to calc normalAverageFee
    uint private lastMonth;         // Timestamp of the start of current metric period (For UI)

    mapping(address=> uint) public mapAddress_30DayDividends;
    mapping(address=> uint) public mapAddress_Past30DayPoolDividends;

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER);
        _;
    }

    constructor (address _base, address _wbnb) {
        BASE = _base;
        WBNB = _wbnb;
        arrayFeeSize = 20;
        eraLength = 30;
        maxTrades = 100;
        lastMonth = 0;
        DEPLOYER = msg.sender;
    }

    receive() external payable {}

    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    // User adds liquidity
    function addLiquidity(uint inputBase, uint inputToken, address token) external payable{
        addLiquidityForMember(inputBase, inputToken, token, msg.sender);
    }

    // Contract adds liquidity for user
    function addLiquidityForMember(uint inputBase, uint inputToken, address token, address member) public payable{
        address pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token);  // Get pool address
        _handleTransferIn(BASE, inputBase, pool); // Transfer SPARTA to pool
        _handleTransferIn(token, inputToken, pool); // Transfer TOKEN to pool
        Pool(pool).addForMember(member); // Add liquidity to pool for user
    }

    // Trade LP tokens for another type of LP tokens
    function zapLiquidity(uint unitsInput, address fromPool, address toPool) external {
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isPool(fromPool) == true); // FromPool must be a valid pool
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isPool(toPool) == true); // ToPool must be a valid pool
        address _fromToken = Pool(fromPool).TOKEN(); // Get token underlying the fromPool
        address _member = msg.sender; // Get user's address
        require(unitsInput <= iBEP20(fromPool).totalSupply()); // Input must be valid
        iBEP20(fromPool).transferFrom(_member, fromPool, unitsInput); // Transfer LPs from user to the pool
        Pool(fromPool).remove(); // Remove liquidity to ROUTER
        iBEP20(_fromToken).transfer(fromPool, iBEP20(_fromToken).balanceOf(address(this))); // Transfer TOKENs from ROUTER to fromPool
        Pool(fromPool).swapTo(BASE, toPool); // Swap the received TOKENs for SPARTA then transfer to the toPool
        iBEP20(BASE).transfer(toPool, iBEP20(BASE).balanceOf(address(this))); // Transfer SPARTA from ROUTER to toPool
        Pool(toPool).addForMember(_member); // Add liquidity and send the LPs to user
    }

    // User adds liquidity asymetrically (one asset)
    function addLiquiditySingle(uint inputToken, bool fromBase, address token) external payable{
        addLiquiditySingleForMember(inputToken, fromBase, token, msg.sender);
    }

    // Contract adds liquidity asymetrically for user (one asset)
    function addLiquiditySingleForMember(uint inputToken, bool fromBase, address token, address member) public payable{
        require(inputToken > 0); // Must be valid input amount
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); // Get pool address
        address _token = token;
        if(token == address(0)){_token = WBNB;} // Handle BNB -> WBNB
        if(fromBase){
            _handleTransferIn(BASE, inputToken, _pool); // Transfer SPARTA into pool
            Pool(_pool).addForMember(member); // Add liquidity and send LPs to user
        } else {
            _handleTransferIn(token, inputToken, _pool); // Transfer TOKEN into pool
            Pool(_pool).addForMember(member); // Add liquidity and send LPs to user
        }
    }

    // User removes liquidity - redeems a percentage of their balance
    function removeLiquidity(uint basisPoints, address token) external{
        require((basisPoints > 0 && basisPoints <= 10000)); // Must be valid basis points
        uint _units = iUTILS(_DAO().UTILS()).calcPart(basisPoints, iBEP20(iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token)).balanceOf(msg.sender));
        removeLiquidityExact(_units, token);
    }

    // User removes liquidity - redeems exact qty of LP tokens
    function removeLiquidityExact(uint units, address token) public {
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); // Get the pool address
        address _member = msg.sender; // The the user's address
        iBEP20(_pool).transferFrom(_member, _pool, units); // Transfer LPs to the pool
        if(token != address(0)){
            Pool(_pool).removeForMember(_member); // Remove liquidity and send assets directly to user
        } else {
            Pool(_pool).remove(); // If BNB; remove liquidity and send to ROUTER instead
            uint outputBase = iBEP20(BASE).balanceOf(address(this)); // Get the received SPARTA amount
            uint outputToken = iBEP20(WBNB).balanceOf(address(this)); // Get the received WBNB amount
            _handleTransferOut(token, outputToken, _member); // Unwrap to BNB & tsf it to user
            _handleTransferOut(BASE, outputBase, _member); // Transfer SPARTA to user
        }
    }

    // User removes liquidity asymetrically (one asset)
    function removeLiquiditySingle(uint units, bool toBase, address token) external{
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); // Get pool address
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isPool(_pool) == true); // Pool must be valid
        address _member = msg.sender; // Get user's address
        iBEP20(_pool).transferFrom(_member, _pool, units); // Transfer LPs to pool
        Pool(_pool).remove(); // Remove liquidity & tsf to ROUTER
        address _token = token; // Get token address
        if(token == address(0)){_token = WBNB;} // Handle BNB -> WBNB
        if(toBase){
            iBEP20(_token).transfer(_pool, iBEP20(_token).balanceOf(address(this))); // Transfer TOKEN to pool
            Pool(_pool).swapTo(BASE, _member); // Swap TOKEN for SPARTA & tsf to user
        } else {
            iBEP20(BASE).transfer(_pool, iBEP20(BASE).balanceOf(address(this))); // Transfer SPARTA to pool
            Pool(_pool).swap(_token); // Swap SPARTA for TOKEN & transfer to ROUTER
            _handleTransferOut(token, iBEP20(_token).balanceOf(address(this)), _member); // Send TOKEN to user
        } 
    }

    //============================== Swapping Functions ====================================//
    
    // Swap SPARTA for TOKEN
    function buyTo(uint amount, address token, address member) public {
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); // Get the pool address
        _handleTransferIn(BASE, amount, _pool); // Transfer SPARTA to pool
        uint fee;
        if(token != address(0)){
            (, uint feey) = Pool(_pool).swapTo(token, member); // Swap SPARTA to TOKEN & tsf to user
            fee = feey;
        } else {
            (uint outputAmount, uint feez) = Pool(_pool).swap(WBNB); // Swap SPARTA to WBNB
            _handleTransferOut(token, outputAmount, member); // Unwrap to BNB & tsf to user
            fee = feez;
        }
        getsDividend(_pool, fee); // Check for dividend & tsf it to pool
    }

    // Swap TOKEN for SPARTA
    function sellTo(uint amount, address token, address member) public payable returns (uint){
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); // Get pool address
        _handleTransferIn(token, amount, _pool); // Transfer TOKEN to pool
        (, uint fee) = Pool(_pool).swapTo(BASE, member); // Swap TOKEN to SPARTA & transfer to user
        getsDividend(_pool, fee); // Check for dividend & tsf it to pool
        return fee;
    }

    // User performs a simple swap (to -> from)
    function swap(uint256 inputAmount, address fromToken, address toToken) external payable{
        swapTo(inputAmount, fromToken, toToken, msg.sender);
    }

    // Contract checks which swap function the user will require
    function swapTo(uint256 inputAmount, address fromToken, address toToken, address member) public payable{
        require(fromToken != toToken); // Tokens must not be the same
        if(fromToken == BASE){
            buyTo(inputAmount, toToken, member); // Swap SPARTA to TOKEN & tsf to user
        } else if(toToken == BASE) {
            sellTo(inputAmount, fromToken, member); // Swap TOKEN to SPARTA & tsf to user
        } else {
            address _poolTo = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(toToken); // Get pool address
            uint feey = sellTo(inputAmount, fromToken, _poolTo); // Swap TOKEN to SPARTA & tsf to pool
            address _toToken = toToken;
            if(toToken == address(0)){_toToken = WBNB;} // Handle BNB -> WBNB
            (uint _zz, uint _feez) = Pool(_poolTo).swap(_toToken); // Swap SPARTA to TOKEN & tsf to ROUTER
            uint fee = feey+(_feez); // Get total slip fees
            getsDividend(_poolTo, fee); // Check for dividend & tsf it to pool
            _handleTransferOut(toToken, _zz, member); // Transfer TOKEN to user
        }
    }

    // Check if fee should generate a dividend & send it to the pool
    function getsDividend(address _pool, uint fee) internal {
        if(iPOOLFACTORY(_DAO().POOLFACTORY()).isCuratedPool(_pool) == true){
            addTradeFee(fee); // Add fee to array for avgFee calcs etc
            addDividend(_pool, fee); // Check and tsf dividend to pool
        }
    }

    //============================== Token Transfer Functions ======================================//
    
    // Handle the transfer of assets into the pool
    function _handleTransferIn(address _token, uint256 _amount, address _pool) internal returns(uint256 actual){
        if(_amount > 0) {
            if(_token == address(0)){
                require((_amount == msg.value));
                (bool success, ) = payable(WBNB).call{value: _amount}(""); // Wrap BNB
                require(success, "!send");
                iBEP20(WBNB).transfer(_pool, _amount); // Transfer WBNB from ROUTER to pool
                actual = _amount;
            } else {
                uint startBal = iBEP20(_token).balanceOf(_pool); // Get prior TOKEN balance of pool
                iBEP20(_token).transferFrom(msg.sender, _pool, _amount); // Transfer TOKEN to pool
                actual = iBEP20(_token).balanceOf(_pool)-(startBal); // Get received TOKEN amount
            }
        }
    }

    // Handle the transfer of assets out of the ROUTER
    function _handleTransferOut(address _token, uint256 _amount, address _recipient) internal {
        if(_amount > 0) {
            if (_token == address(0)) {
                iWBNB(WBNB).withdraw(_amount); // Unwrap WBNB to BNB
                (bool success, ) = payable(_recipient).call{value:_amount}("");  // Send BNB to recipient
                require(success, "!send");
            } else {
                iBEP20(_token).transfer(_recipient, _amount); // Transfer TOKEN to recipient
            }
        }
    }

    //================================ Swap Synths ========================================//
    
    // Swap TOKEN to Synth
    function swapAssetToSynth(uint inputAmount, address fromToken, address toSynth) external payable {
        require(fromToken != toSynth); // Tokens must not be the same
        address _synthLayer1 = iSYNTH(toSynth).LayerONE(); // Get underlying token's address
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(_synthLayer1); // Get relevant pool address
        if(fromToken != BASE){
            sellTo(inputAmount, fromToken, address(this)); // Swap TOKEN to SPARTA & tsf to ROUTER
            iBEP20(BASE).transfer(_pool, iBEP20(BASE).balanceOf(address(this))); // Transfer SPARTA from ROUTER to pool
        } else {
            iBEP20(BASE).transferFrom(msg.sender, _pool, inputAmount); // Transfer SPARTA from ROUTER to pool
        }
        (, uint fee) = Pool(_pool).mintSynth(toSynth, msg.sender); // Mint synths & tsf to user
        getsDividend(_pool, fee); // Check and tsf dividend to pool
    }
   
    // Swap Synth to TOKEN
    function swapSynthToAsset(uint inputAmount, address fromSynth, address toToken) external {
        require(fromSynth != toToken); // Tokens must not be the same
        address _synthINLayer1 = iSYNTH(fromSynth).LayerONE(); // Get synth's underlying token's address
        address _poolIN = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(_synthINLayer1); // Get synth's relevant pool address
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(toToken); // Get TOKEN's relevant pool address
        iBEP20(fromSynth).transferFrom(msg.sender, _poolIN, inputAmount); // Transfer synth from user to pool
        uint outputAmount; uint fee;
        if(toToken == BASE){
            Pool(_poolIN).burnSynth(fromSynth, msg.sender); // Swap Synths for SPARTA & tsf to user
        } else {
            (outputAmount,fee) = Pool(_poolIN).burnSynth(fromSynth, address(this)); // Swap Synths to SPARTA & tsf to ROUTER
            if(toToken != address(0)){
                (, uint feey) = Pool(_pool).swapTo(toToken, msg.sender); // Swap SPARTA to TOKEN & transfer to user
                fee = feey + fee;
            } else {
                (uint outputAmountY, uint feez) = Pool(_pool).swap(WBNB); // Swap SPARTA to WBNB & tsf to ROUTER
                _handleTransferOut(toToken, outputAmountY, msg.sender); // Unwrap to BNB & tsf to user
                fee = feez + fee;
            }
        }
        getsDividend(_pool, fee); // Check and tsf dividend to pool
    }
    
    //============================= Token Dividends / Curated Pools =================================//
    
    // Calculate the Dividend and transfer it to the pool
    function addDividend(address _pool, uint256 _fees) internal {
        if(!(normalAverageFee == 0)){
            uint reserve = iBEP20(BASE).balanceOf(_DAO().RESERVE()); // Get SPARTA balance in the RESERVE contract
            if(!(reserve == 0)){
                uint dailyAllocation = (reserve / eraLength) / maxTrades; // Calculate max dividend
                uint numerator = _fees * dailyAllocation;
                uint feeDividend = numerator / (_fees + normalAverageFee); // Calculate actual dividend
                revenueDetails(feeDividend, _pool); // Add to revenue metrics
                iRESERVE(_DAO().RESERVE()).grantFunds(feeDividend, _pool); // Transfer dividend from RESERVE to POOL
                Pool(_pool).sync(); // Sync the pool balances to attribute the dividend to the existing LPers
            }
        }
    }

    // Add fee to feeArray, used to calculate normalAverageFee
    function addTradeFee(uint _fee) internal {
        uint totalTradeFees = 0;
        uint arrayFeeLength = feeArray.length;
        if(arrayFeeLength < arrayFeeSize){
            feeArray.push(_fee); // Build array until it is == arrayFeeSize
        } else {
            addFee(_fee); // If array is required length; shift in place of oldest item
            for(uint i = 0; i < arrayFeeSize; i++){
                totalTradeFees = totalTradeFees + feeArray[i]; // NET sum of feeArray
            }
        }
        normalAverageFee = totalTradeFees / arrayFeeSize; // Calc average fee
    }

    // Shift out oldest fee item and add newest
    function addFee(uint _fee) internal {
        uint n = feeArray.length; // 20
        for (uint i = n - 1; i > 0; i--) {
            feeArray[i] = feeArray[i - 1];
        }
        feeArray[0] = _fee;
    }

    function revenueDetails(uint _fees, address _pool) internal {
        if(lastMonth == 0){
            lastMonth = block.timestamp;
        }
        if(block.timestamp <= lastMonth + 2592000){ // 30 days
            mapAddress_30DayDividends[_pool] = mapAddress_30DayDividends[_pool] + _fees;
        } else {
            lastMonth = block.timestamp;
            mapAddress_Past30DayPoolDividends[_pool] = mapAddress_30DayDividends[_pool];
            mapAddress_30DayDividends[_pool] = 0;
            mapAddress_30DayDividends[_pool] = mapAddress_30DayDividends[_pool] + _fees;
        }
    }

    function stringToBytes(string memory s) external pure returns (bytes memory){
        return bytes(s);
    }

    function isEqual(bytes memory part1, bytes memory part2) external pure returns(bool equal){
        if(sha256(part1) == sha256(part2)){
            return true;
        }
    }
    
    //======================= Change Dividend Variables ===========================//

    function changeArrayFeeSize(uint _size) external onlyDAO {
        arrayFeeSize = _size;
        delete feeArray;
    }

    function changeMaxTrades(uint _maxtrades) external onlyDAO {
        maxTrades = _maxtrades;
    }

    function changeEraLength(uint _eraLength) external onlyDAO {	
        eraLength = _eraLength;	
    }

    //================================== Helpers =================================//

    function currentPoolRevenue(address pool) external view returns(uint256) {
        return mapAddress_30DayDividends[pool];
    }

    function pastPoolRevenue(address pool) external view returns(uint256) {
        return mapAddress_Past30DayPoolDividends[pool];
    }
}


// File contracts/Synth.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;


contract Synth is iBEP20 {
    address public BASE;
    address public LayerONE; // Underlying relevant layer1 token
    uint public genesis;
    address public DEPLOYER;

    string _name; string _symbol;
    uint8 public override decimals; uint256 public override totalSupply;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping(address => uint) public mapSynth_LPBalance;
    mapping(address => uint) public mapSynth_LPDebt;
   
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    
    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER, "!DAO");
        _;
    }

    // Restrict access
    modifier onlyPool() {
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isCuratedPool(msg.sender) == true, "!curated");
        _;
    }
    
    constructor (address _base, address _token) {
        BASE = _base;
        LayerONE = _token;
        string memory synthName = "-SpartanProtocolSynthetic";
        string memory synthSymbol = "-SPS";
        _name = string(abi.encodePacked(iBEP20(_token).name(), synthName));
        _symbol = string(abi.encodePacked(iBEP20(_token).symbol(), synthSymbol));
        decimals = iBEP20(_token).decimals();
        DEPLOYER = msg.sender;
        genesis = block.timestamp;
    }

    //========================================iBEP20=========================================//

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    // iBEP20 Transfer function
    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // iBEP20 Approve, change allowance functions
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "!approval");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "!owner");
        require(spender != address(0), "!spender");
        if (_allowances[owner][spender] < type(uint256).max) { // No need to re-approve if already max
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
    }
    
    // iBEP20 TransferFrom function
    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        // Unlimited approval (saves an SSTORE)
        if (_allowances[sender][msg.sender] < type(uint256).max) {
            uint256 currentAllowance = _allowances[sender][msg.sender];
            require(currentAllowance >= amount, "!approval");
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }

    //iBEP677 approveAndCall
    function approveAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
        _approve(msg.sender, recipient, type(uint256).max); // Give recipient max approval
        iBEP677(recipient).onTokenApproval(address(this), amount, msg.sender, data); // Amount is passed thru to recipient
        return true;
    }

    //iBEP677 transferAndCall
    function transferAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        iBEP677(recipient).onTokenTransfer(address(this), amount, msg.sender, data); // Amount is passed thru to recipient 
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "!sender");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "!balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // Internal mint (upgrading and daily emissions)
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Burn supply
    function burn(uint256 amount) external virtual override {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) external virtual {  
        uint256 decreasedAllowance = allowance(account, msg.sender) - (amount);
        _approve(account, msg.sender, decreasedAllowance); 
        _burn(account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        require(_balances[account] >= amount, "!balance");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    //==================================== SYNTH FUNCTIONS =================================//

    // Handle received LP tokens and mint Synths
    function mintSynth(address member, uint amount) external onlyPool returns (uint syntheticAmount){
        uint lpUnits = _getAddedLPAmount(msg.sender); // Get the received LP units
        mapSynth_LPDebt[msg.sender] += amount; // Increase debt by synth amount
        mapSynth_LPBalance[msg.sender] += lpUnits; // Increase lp balance by LPs received
        _mint(member, amount); // Mint the synths & tsf to user
        return amount;
    }
    
    // Handle received Synths and burn the LPs and Synths
    function burnSynth() external returns (bool){
        uint _syntheticAmount = balanceOf(address(this)); // Get the received synth units
        uint _amountUnits = (_syntheticAmount * mapSynth_LPBalance[msg.sender]) / mapSynth_LPDebt[msg.sender]; // share = amount * part/total
        mapSynth_LPBalance[msg.sender] -= _amountUnits; // Reduce lp balance
        mapSynth_LPDebt[msg.sender] -= _syntheticAmount; // Reduce debt by synths being burnt
        if(_amountUnits > 0){
            _burn(address(this), _syntheticAmount); // Burn the synths
            Pool(msg.sender).burn(_amountUnits); // Burn the LP tokens
        }
        return true;
    }

    // Burn LPs to if their value outweights the synths supply value (Ensures incentives are funnelled to existing LPers)
    function realise(address pool) external {
        uint baseValueLP = iUTILS(_DAO().UTILS()).calcLiquidityHoldings(mapSynth_LPBalance[pool], BASE, pool); // Get the SPARTA value of the LP tokens
        uint baseValueSynth = iUTILS(_DAO().UTILS()).calcActualSynthUnits(mapSynth_LPDebt[pool], address(this)); // Get the SPARTA value of the synths
        if(baseValueLP > baseValueSynth){
            uint premium = baseValueLP - baseValueSynth; // Get the premium between the two values
            if(premium > 10**18){
                uint premiumLP = iUTILS(_DAO().UTILS()).calcLiquidityUnitsAsym(premium, pool); // Get the LP value of the premium
                mapSynth_LPBalance[pool] -= premiumLP; // Reduce the LP balance
                Pool(pool).burn(premiumLP); // Burn the premium of the LP tokens
            }
        }
    }

    // Check the received token amount
    function _handleTransferIn(address _token, uint256 _amount) internal returns(uint256 _actual){
        if(_amount > 0) {
            uint startBal = iBEP20(_token).balanceOf(address(this)); // Get existing balance
            iBEP20(_token).transferFrom(msg.sender, address(this), _amount); // Transfer tokens in
            _actual = iBEP20(_token).balanceOf(address(this)) - startBal; // Calculate received amount
        }
        return _actual;
    }

    // Check the received LP tokens amount
    function _getAddedLPAmount(address _pool) internal view returns(uint256 _actual){
        uint _lpCollateralBalance = iBEP20(_pool).balanceOf(address(this)); // Get total balance held
        if(_lpCollateralBalance > mapSynth_LPBalance[_pool]){
            _actual = _lpCollateralBalance - mapSynth_LPBalance[_pool]; // Get received amount
        } else {
            _actual = 0;
        }
        return _actual;
    }

    function getmapAddress_LPBalance(address pool) external view returns (uint){
        return mapSynth_LPBalance[pool];
    }

    function getmapAddress_LPDebt(address pool) external view returns (uint){
        return mapSynth_LPDebt[pool];
    }
}


// File contracts/synthFactory.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;

contract SynthFactory { 
    address public BASE;
    address public WBNB;
    address public DEPLOYER;

    address[] public arraySynths; // Array of all deployed synths
    mapping(address => address) private mapToken_Synth;
    mapping(address => bool) public isSynth;
    event CreateSynth(address indexed token, address indexed pool);

    constructor (address _base, address _wbnb) {
        BASE = _base;
        WBNB = _wbnb;
        DEPLOYER = msg.sender; 
    }

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER, "!DAO");
        _;
    }

    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    // Can purge deployer once DAO is stable and final
    function purgeDeployer() external onlyDAO {
        DEPLOYER = address(0);
    }

    // Anyone can create a synth if it's pool is curated
    function createSynth(address token) external returns(address synth){
        require(getSynth(token) == address(0), "exists"); // Synth must not already exist
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); // Get pool address
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isCuratedPool(_pool) == true, "!curated"); // Pool must be Curated
        Synth newSynth; address _token = token;
        if(token == address(0)){_token = WBNB;} // Handle BNB -> WBNB
        newSynth = new Synth(BASE, _token); // Deploy synth asset contract
        synth = address(newSynth); // Get new synth's address
        addSynth(_token, synth); // Record new synth contract with the SynthFactory
        emit CreateSynth(token, synth);
        return synth;
    }

    // Record synth with the SynthFactory
    function addSynth(address _token, address _synth) internal {
        require(_token != BASE); // Must not be SPARTA
        mapToken_Synth[_token] = _synth; // Record synth address
        arraySynths.push(_synth); // Add synth address to the array
        isSynth[_synth] = true; // Record synth as valid
    }

    //================================ Helper Functions ==================================//
    
    function getSynth(address token) public view returns(address synth){
        if(token == address(0)){
            synth = mapToken_Synth[WBNB];   // Handle BNB
        } else {
            synth = mapToken_Synth[token];  // Handle normal token
        } 
        return synth;
    }

    function synthCount() external view returns(uint256){
        return arraySynths.length;
    }

    function getSynthsArray(uint256 i) external view returns(address){
        return arraySynths[i];
    }
}


// File contracts/synthVault.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;









contract SynthVault {
    address public BASE;
    address public DEPLOYER;

    uint256 public minimumDepositTime;  // Withdrawal & Harvest lockout period; intended to be 1 hour
    uint256 public totalWeight;         // Total weight of the whole SynthVault
    uint256 public erasToEarn;          // Amount of eras that make up the targeted RESERVE depletion; regulates incentives
    uint256 public vaultClaim;          // The SynthVaults's portion of rewards; intended to be ~10% initially
    address [] public stakedSynthAssets; // Array of all synth assets that have ever been staked in (scope: vault)
    uint private lastMonth;             // Timestamp of the start of current metric period (For UI)
    uint public genesis;                // Timestamp from when the synth was first deployed (For UI)

    uint256 public map30DVaultRevenue; // Tally of revenue during current incomplete metric period (for UI)
    uint256 public mapPast30DVaultRevenue; // Tally of revenue from last full metric period (for UI)
    uint256 [] public revenueArray; // Array of the last two metric periods (For UI)

    // Restrict access
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER);
        _;
    }

    constructor(address _base) {
        BASE = _base;
        DEPLOYER = msg.sender;
        erasToEarn = 30;
        minimumDepositTime = 3600; // 1 hour
        vaultClaim = 1000;
        genesis = block.timestamp;
        lastMonth = 0;
    }

    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    mapping(address => mapping(address => uint256)) private mapMemberSynth_weight;
    mapping(address => uint256) private mapMemberTotal_weight;
    mapping(address => mapping(address => uint256)) private mapMemberSynth_deposit;

    mapping(address => mapping(address => uint256)) private mapMemberSynth_lastTime;
    mapping(address => uint256) private mapMember_depositTime;
    mapping(address => uint256) public lastBlock;
    mapping(address => bool) private isStakedSynth;
    mapping(address => mapping(address => bool)) private isSynthMember;

    event MemberDeposits(
        address indexed synth,
        address indexed member,
        uint256 newDeposit,
        uint256 weight,
        uint256 totalWeight
    );
    event MemberWithdraws(
        address indexed synth,
        address indexed member,
        uint256 amount,
        uint256 weight,
        uint256 totalWeight
    );
    event MemberHarvests(
        address indexed synth,
        address indexed member,
        uint256 amount,
        uint256 weight,
        uint256 totalWeight
    );

    function setParams(uint256 one, uint256 two, uint256 three) external onlyDAO {
        erasToEarn = one;
        minimumDepositTime = two;
        vaultClaim = three;
    }

    //====================================== DEPOSIT ========================================//

    // User deposits Synths in the SynthVault
    function deposit(address synth, uint256 amount) external {
        depositForMember(synth, msg.sender, amount);
    }

    // Contract deposits Synths in the SynthVault for user
    function depositForMember(address synth, address member, uint256 amount) public {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synth), "!synth"); // Must be a valid synth
        require(iBEP20(synth).transferFrom(msg.sender, address(this), amount)); // Must successfuly transfer in
        _deposit(synth, member, amount); // Assess and record the deposit
    }

    // Check and record the deposit
    function _deposit(address _synth, address _member, uint256 _amount) internal {
        if(!isStakedSynth[_synth]){
            isStakedSynth[_synth] = true; // Record as a staked synth
            stakedSynthAssets.push(_synth); // Add to staked synth array
        }
        mapMemberSynth_lastTime[_member][_synth] = block.timestamp + minimumDepositTime; // Record deposit time (scope: member -> synth)
        mapMember_depositTime[_member] = block.timestamp + minimumDepositTime; // Record deposit time (scope: member)
        mapMemberSynth_deposit[_member][_synth] += _amount; // Record balance for member
        uint256 _weight = iUTILS(_DAO().UTILS()).calcSpotValueInBase(iSYNTH(_synth).LayerONE(), _amount); // Get the SPARTA weight of the deposit
        mapMemberSynth_weight[_member][_synth] += _weight; // Add the weight to the user (scope: member -> synth)
        mapMemberTotal_weight[_member] += _weight; // Add to the user's total weight (scope: member)
        totalWeight += _weight; // Add to the total weight (scope: vault)
        isSynthMember[_member][_synth] = true; // Record user as a member
        emit MemberDeposits(_synth, _member, _amount, _weight, totalWeight);
    }

    //====================================== HARVEST ========================================//

    // User harvests all of their available rewards
    function harvestAll() external returns (bool) {
        for(uint i = 0; i < stakedSynthAssets.length; i++){
            if((block.timestamp > mapMemberSynth_lastTime[msg.sender][stakedSynthAssets[i]])){
                uint256 reward = calcCurrentReward(stakedSynthAssets[i], msg.sender);
                if(reward > 0){
                    harvestSingle(stakedSynthAssets[i]);
                }
            }
            
        }
        return true;
    }

    // User harvests available rewards of the chosen asset
    function harvestSingle(address synth) public returns (bool) {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synth), "!synth"); // Must be valid synth
        require(iRESERVE(_DAO().RESERVE()).emissions(), "!emissions"); // RESERVE emissions must be on
        uint256 _weight;
        uint256 reward = calcCurrentReward(synth, msg.sender); // Calc user's current SPARTA reward
        mapMemberSynth_lastTime[msg.sender][synth] = block.timestamp; // Set last harvest time as now
        address _poolOUT = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(iSYNTH(synth).LayerONE()); // Get pool address
        iRESERVE(_DAO().RESERVE()).grantFunds(reward, _poolOUT); // Send the SPARTA from RESERVE to POOL
        (uint synthReward,) = iPOOL(_poolOUT).mintSynth(synth, address(this)); // Mint synths & tsf to SynthVault
        _weight = iUTILS(_DAO().UTILS()).calcSpotValueInBase(iSYNTH(synth).LayerONE(), synthReward); // Calc reward's SPARTA value
        mapMemberSynth_deposit[msg.sender][synth] += synthReward; // Record deposit for the user (scope: member -> synth)
        mapMemberSynth_weight[msg.sender][synth] += _weight; // Add the weight to the user (scope: member -> synth)
        mapMemberTotal_weight[msg.sender] += _weight; // Add to the user's total weight (scope: member)
        totalWeight += _weight; // Add to the total weight (scope: vault)
        _addVaultMetrics(reward); // Add to the revenue metrics (for UI)
        iSYNTH(synth).realise(_poolOUT); // Check synth-held LP value for premium; burn if so
        emit MemberHarvests(synth, msg.sender, reward, _weight, totalWeight);
        return true;
    }

    // Calculate the user's current incentive-claim per era based on selected asset
    function calcCurrentReward(address synth, address member) public view returns (uint256 reward){
        require((block.timestamp > mapMemberSynth_lastTime[member][synth]), "!unlocked"); // Must not harvest before lockup period passed
        uint256 _secondsSinceClaim = block.timestamp - mapMemberSynth_lastTime[member][synth]; // Get seconds passed since last claim
        uint256 _share = calcReward(synth, member); // Get member's share of RESERVE incentives
        reward = (_share * _secondsSinceClaim) / iBASE(BASE).secondsPerEra(); // User's share times eras since they last claimed
        return reward;
    }

    // Calculate the user's current total claimable incentive
    function calcReward(address synth, address member) public view returns (uint256) {
        uint256 _weight = mapMemberSynth_weight[member][synth]; // Get user's weight (scope: member -> synth)
        uint256 _reserve = reserveBASE() / erasToEarn; // Aim to deplete reserve over a number of days
        uint256 _vaultReward = (_reserve * vaultClaim) / 10000; // Get the SynthVault's share of that
        return iUTILS(_DAO().UTILS()).calcShare(_weight, totalWeight, _vaultReward); // Get member's share of that
    }

    //====================================== WITHDRAW ========================================//

    // User withdraws a percentage of their synths from the vault
    function withdraw(address synth, uint256 basisPoints) external returns (uint256 redeemedAmount) {
        redeemedAmount = _processWithdraw(synth, msg.sender, basisPoints); // Perform the withdrawal
        require(iBEP20(synth).transfer(msg.sender, redeemedAmount)); // Transfer from SynthVault to user
        return redeemedAmount;
    }

    // Contract withdraws a percentage of user's synths from the vault
    function _processWithdraw(address _synth, address _member, uint256 _basisPoints) internal returns (uint256 synthReward) {
        require((block.timestamp > mapMember_depositTime[_member]), "lockout"); // Must not withdraw before lockup period passed
        uint256 _principle = iUTILS(_DAO().UTILS()).calcPart(_basisPoints, mapMemberSynth_deposit[_member][_synth]); // Calc amount to withdraw
        mapMemberSynth_deposit[_member][_synth] -= _principle; // Remove from user's recorded vault holdings
        uint256 _weight = iUTILS(_DAO().UTILS()).calcPart(_basisPoints, mapMemberSynth_weight[_member][_synth]); // Calc SPARTA value of amount
        mapMemberTotal_weight[_member] -= _weight; // Remove from member's total weight (scope: member)
        mapMemberSynth_weight[_member][_synth] -= _weight; // Remove from member's synth weight (scope: member -> synth)
        totalWeight -= _weight; // Remove from total weight (scope: vault)
        emit MemberWithdraws(_synth, _member, synthReward, _weight, totalWeight);
        return (_principle + synthReward);
    }

    //================================ Helper Functions ===============================//

    function reserveBASE() public view returns (uint256) {
        return iBEP20(BASE).balanceOf(_DAO().RESERVE());
    }

    function getMemberDeposit(address synth, address member) external view returns (uint256){
        return mapMemberSynth_deposit[member][synth];
    }

    function getMemberWeight(address member) external view returns (uint256) {
        return mapMemberTotal_weight[member];
    }

    function getStakeSynthLength() external view returns (uint256) {
        return stakedSynthAssets.length;
    }

    function getMemberLastTime(address member) external view returns (uint256) {
        return mapMember_depositTime[member];
    }

    function getMemberLastSynthTime(address synth, address member) external view returns (uint256){
        return mapMemberSynth_lastTime[member][synth];
    }

    function getMemberSynthWeight(address synth, address member) external view returns (uint256) {
        return mapMemberSynth_weight[member][synth];
    }

    //=============================== SynthVault Metrics =================================//

    function _addVaultMetrics(uint256 _fee) internal {
        if(lastMonth == 0){
            lastMonth = block.timestamp;
        }
        if(block.timestamp <= lastMonth + 2592000){ // 30 days
            map30DVaultRevenue = map30DVaultRevenue + _fee;
        } else {
            lastMonth = block.timestamp;
            mapPast30DVaultRevenue = map30DVaultRevenue;
            addRevenue(mapPast30DVaultRevenue);
            map30DVaultRevenue = 0;
            map30DVaultRevenue = map30DVaultRevenue + _fee;
        }
    }

    function addRevenue(uint _totalRev) internal {
        if(!(revenueArray.length == 2)){
            revenueArray.push(_totalRev);
        } else {
            addFee(_totalRev);
        }
    }

    function addFee(uint _rev) internal {
        uint _n = revenueArray.length; // 2
        for (uint i = _n - 1; i > 0; i--) {
            revenueArray[i] = revenueArray[i - 1];
        }
        revenueArray[0] = _rev;
    }
}


// File contracts/Utils.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;





contract Utils {
    address public BASE;
    uint public one = 10**18;

    constructor (address _base) {
        BASE = _base;
    }

    struct PoolDataStruct {
        address tokenAddress;
        address poolAddress;
        uint genesis;
        uint baseAmount;
        uint tokenAmount;
        uint fees;
        uint volume;
        uint txCount;
        uint poolUnits;
    }

    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }

    //================================== HELPERS ================================//

    function getPoolData(address token) external view returns(PoolDataStruct memory poolData){
        address pool = getPool(token);
        poolData.poolAddress = pool;
        poolData.tokenAddress = token;
        poolData.genesis = iPOOL(pool).genesis();
        poolData.baseAmount = iPOOL(pool).baseAmount();
        poolData.tokenAmount = iPOOL(pool).tokenAmount();
        poolData.poolUnits = iBEP20(pool).totalSupply();
        return poolData;
    }

    function getPoolShareWeight(address token, uint units) external view returns(uint weight){
        address pool = getPool(token);
        weight = calcShare(units, iBEP20(pool).totalSupply(), iPOOL(pool).baseAmount());
        return (weight);
    }

    function getPool(address token) public view returns(address pool){
        return iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token);
    }

    //================================== CORE-MATH ==================================//
    
    // Calculate the feeBurn's feeOnTransfer based on total supply
    function getFeeOnTransfer(uint256 totalSupply, uint256 maxSupply) external pure returns (uint256) {
        return calcShare(totalSupply, maxSupply, 100); // 0 -> 100bp
    }

    // Calculate 'part' of a total using basis points | 10,000 basis points = 100.00%
    function calcPart(uint256 bp, uint256 total) external pure returns (uint256) {
        require(bp <= 10000, "!bp"); // basis points must be valid
        return calcShare(bp, 10000, total);
    }

    // Calc share | share = amount * part / total
    function calcShare(uint256 part, uint256 total, uint256 amount) public pure returns (uint256 share) {
        if (part > total) {
            part = total; // Part cant be greater than the total
        }
        if (total > 0) {
            share = (amount * part) / total;
        }
    }

    // Calculate liquidity units
    function calcLiquidityUnits(uint b, uint B, uint t, uint T, uint P) external view returns (uint units){
        if(P == 0){
            return b; // If pool is empty; use b as initial units
        } else {
            // units = ((P (t B + T b))/(2 T B)) * slipAdjustment
            // P * (part1 + part2) / (part3) * slipAdjustment
            uint slipAdjustment = getSlipAdustment(b, B, t, T);
            uint part1 = t*(B);
            uint part2 = T*(b);
            uint part3 = T*(B)*(2);
            uint _units = (P * (part1 + (part2))) / (part3);
            return _units * slipAdjustment / one;  // Divide by 10**18
        }
    }

    // Get slip adjustment
    function getSlipAdustment(uint b, uint B, uint t, uint T) public view returns (uint slipAdjustment){
        // slipAdjustment = (1 - ABS((B t - b T)/((2 b + B) (t + T))))
        // 1 - ABS(part1 - part2)/(part3 * part4))
        uint part1 = B * (t);
        uint part2 = b * (T);
        uint part3 = b * (2) + (B);
        uint part4 = t + (T);
        uint numerator;
        if(part1 > part2){
            numerator = part1 - (part2);
        } else {
            numerator = part2 - (part1);
        }
        uint denominator = part3 * (part4);
        return one - ((numerator * (one)) / (denominator)); // Multiply by 10**18
    }

    // Calculate symmetrical redemption value of LP tokens (per side)
    function calcLiquidityHoldings(uint units, address token, address pool) external view returns (uint share){
        // share = amount * part / total
        // address pool = getPool(token);
        uint amount;
        if(token == BASE){
            amount = iPOOL(pool).baseAmount();
        } else {
            amount = iPOOL(pool).tokenAmount();
        }
        uint totalSupply = iBEP20(pool).totalSupply();
        return(amount*(units))/(totalSupply);
    }

    function calcSwapOutput(uint x, uint X, uint Y) public pure returns (uint output){
        // y = (x * X * Y )/(x + X)^2
        uint numerator = x * (X * (Y));
        uint denominator = (x + (X)) * (x + (X));
        return numerator / (denominator);
    }

    function calcSwapFee(uint x, uint X, uint Y) external pure returns (uint output){
        // y = (x * x * Y) / (x + X)^2
        uint numerator = x * (x * (Y));
        uint denominator = (x + (X)) * (x + (X));
        return numerator / (denominator);
    }

    // Calculate asymmetrical redemption value of LP tokens (remove all to TOKEN)
    function calcAsymmetricValueToken(address pool, uint amount) external view returns (uint tokenValue){
        uint baseAmount = calcShare(amount, iBEP20(pool).totalSupply(), iPOOL(pool).baseAmount());
        uint tokenAmount = calcShare(amount, iBEP20(pool).totalSupply(), iPOOL(pool).tokenAmount());
        uint baseSwapped = calcSwapValueInTokenWithPool(pool, baseAmount);
        tokenValue = tokenAmount + baseSwapped;
        return tokenValue;
    }

    function calcLiquidityUnitsAsym(uint amount, address pool) external view returns (uint units){
        // synthUnits += (P b)/(2 (b + B))
        uint baseAmount = iPOOL(pool).baseAmount();
        uint totalSupply = iBEP20(pool).totalSupply();
        uint two = 2;
        return (totalSupply * amount) / (two * (amount + baseAmount));
    }

    //==================================== PRICING ====================================//

    function calcSpotValueInBase(address token, uint amount) external view returns (uint value){
        address pool = getPool(token);
        return calcSpotValueInBaseWithPool(pool, amount);
    }

    function calcSpotValueInToken(address token, uint amount) external view returns (uint value){
        address pool = getPool(token);
        return calcSpotValueInTokenWithPool(pool, amount);
    }

    function calcSwapValueInBase(address token, uint amount) external view returns (uint _output){
        address pool = getPool(token);
        return  calcSwapValueInBaseWithPool(pool, amount);
    }

    function calcSwapValueInBaseWithSYNTH(address synth, uint amount) external view returns (uint _output){
        address token = iSYNTH(synth).LayerONE();
        address pool = getPool(token);
        return  calcSwapValueInBaseWithPool(pool, amount);
    }

    function calcSwapValueInToken(address token, uint amount) external view returns (uint _output){
        address pool = getPool(token);
        return  calcSwapValueInTokenWithPool(pool, amount);
    }

    function calcSpotValueInBaseWithPool(address pool, uint amount) public view returns (uint value){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return (amount*(_baseAmount))/(_tokenAmount);
    }

    function calcSpotValueInTokenWithPool(address pool, uint amount) public view returns (uint value){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return (amount*(_tokenAmount))/(_baseAmount);
    }

    function calcSwapValueInBaseWithPool(address pool, uint amount) public view returns (uint _output){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return  calcSwapOutput(amount, _tokenAmount, _baseAmount);
    }

    function calcSwapValueInTokenWithPool(address pool, uint amount) public view returns (uint _output){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return  calcSwapOutput(amount, _baseAmount, _tokenAmount);
    }

    function calcActualSynthUnits(uint amount, address synth) external view returns (uint _output) {
        address token = iSYNTH(synth).LayerONE();
        address pool = getPool(token);
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return ((amount * _baseAmount) / (2 * _tokenAmount));
    }
}


// File contracts/interfaces/iBASEv1.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;
interface iBASEv1 {
    function transferTo(address,uint256) external returns(bool);
}
