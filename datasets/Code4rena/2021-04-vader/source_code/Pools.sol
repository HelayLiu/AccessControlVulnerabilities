// Sources flattened with hardhat v2.22.17 https://hardhat.org

// SPDX-License-Identifier: MIT AND UNLICENSED

// File contracts/interfaces/iERC20.sol

// Original license: SPDX_License_Identifier: UNLICENSED
pragma solidity 0.8.3;

interface iERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    function transferTo(address, uint) external returns (bool);
    function burn(uint) external;
    function burnFrom(address, uint) external;
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


// File contracts/interfaces/iROUTER.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iROUTER {
    function setParams(uint newFactor, uint newTime, uint newLimit) external;
    function addLiquidity(address base, uint inputBase, address token, uint inputToken) external returns(uint);
    function removeLiquidity(address base, address token, uint basisPoints) external returns (uint amountBase, uint amountToken);
    function swap(uint inputAmount, address inputToken, address outputToken) external returns (uint outputAmount);
    function swapWithLimit(uint inputAmount, address inputToken, address outputToken, uint slipLimit) external returns (uint outputAmount);
    function swapWithSynths(uint inputAmount, address inputToken, bool inSynth, address outputToken, bool outSynth) external returns (uint outputAmount);
    function swapWithSynthsWithLimit(uint inputAmount, address inputToken, bool inSynth, address outputToken, bool outSynth, uint slipLimit) external returns (uint outputAmount);
    
    function getILProtection(address member, address base, address token, uint basisPoints) external view returns(uint protection);
    
    function curatePool(address token) external;
    function listAnchor(address token) external;
    function replacePool(address oldToken, address newToken) external;
    function updateAnchorPrice(address token) external;
    function getAnchorPrice() external view returns (uint anchorPrice);
    function getVADERAmount(uint USDVAmount) external view returns (uint vaderAmount);
    function getUSDVAmount(uint vaderAmount) external view returns (uint USDVAmount);
    function isCurated(address token) external view returns(bool curated);

    function reserveUSDV() external view returns(uint);
    function reserveVADER() external view returns(uint);

    function getMemberBaseDeposit(address member, address token) external view returns(uint);
    function getMemberTokenDeposit(address member, address token) external view returns(uint);
    function getMemberLastDeposit(address member, address token) external view returns(uint);
    function getMemberCollateral(address member, address collateralAsset, address debtAsset) external view returns(uint);
    function getMemberDebt(address member, address collateralAsset, address debtAsset) external view returns(uint);
    function getSystemCollateral(address collateralAsset, address debtAsset) external view returns(uint);
    function getSystemDebt(address collateralAsset, address debtAsset) external view returns(uint);
    function getSystemInterestPaid(address collateralAsset, address debtAsset) external view returns(uint);
}


// File contracts/interfaces/iUSDV.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iUSDV {
    function ROUTER() external view returns (address);
    function isMature() external view returns (bool);
    function setParams(uint newDelay) external;
    
    function convert(uint amount) external returns(uint convertAmount);
    function convertForMember(address member, uint amount) external returns(uint convertAmount);
    function redeem(uint amount) external returns(uint redeemAmount);
    function redeemForMember(address member, uint amount) external returns(uint redeemAmount);
}


// File contracts/interfaces/iVADER.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iVADER {
    function UTILS() external view returns (address);
    function DAO() external view returns (address);
    function emitting() external view returns (bool);
    function minting() external view returns (bool);
    function secondsPerEra() external view returns (uint);
    function flipEmissions() external;
    function flipMinting() external;
    function setParams(uint newEra, uint newCurve) external;
    function setRewardAddress(address newAddress) external;
    function changeUTILS(address newUTILS) external;
    function changeDAO(address newDAO) external;
    function purgeDAO() external;
    function upgrade(uint amount) external;
    function redeem() external returns (uint);
    function redeemToMember(address member) external returns (uint);
}


// File contracts/Attack.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces




    //======================================VADER=========================================//
contract Attack {
    bool private inited;
    address public VADER;
    address public USDV;

    //=====================================CREATION=========================================//
    // Constructor
    constructor() {}

    function init(address _vader, address _USDV) public {
        require(inited == false);
inited = true;
        VADER = _vader;
        USDV = _USDV;
    }

    //========================================iERC20=========================================//
    function attackUSDV(uint amount) public {
        iERC20(VADER).approve(USDV, amount);
        iERC20(USDV).approve(USDV, amount);
        iERC20(VADER).transferTo(address(this), amount); // get VADER funds
        iUSDV(USDV).convert(amount); // Convert to USDV back to this address
        iUSDV(USDV).redeem(amount); // Burn USDV back to VADER to this address
    }
}


// File contracts/interfaces/iUTILS.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iUTILS {
    function getFeeOnTransfer(uint totalSupply, uint maxSupply) external pure returns (uint);
    function assetChecks(address collateralAsset, address debtAsset) external;
    function isBase(address token) external view returns(bool base);

    function calcValueInBase(address token, uint amount) external view returns (uint);
    function calcValueInToken(address token, uint amount) external view returns (uint);
    function calcValueOfTokenInToken(address token1, uint amount, address token2) external view returns (uint);
    function calcSwapValueInBase(address token, uint amount) external view returns (uint);
    function calcSwapValueInToken(address token, uint amount) external view returns (uint);
    function requirePriceBounds(address token, uint bound, bool inside, uint targetPrice) external view;

    function getRewardShare(address token, uint rewardReductionFactor) external view returns (uint rewardShare);
    function getReducedShare(uint amount) external view returns(uint);

    function getProtection(address member, address token, uint basisPoints, uint timeForFullProtection) external view returns(uint protection);
    function getCoverage(address member, address token) external view returns (uint);
    
    function getCollateralValueInBase(address member, uint collateral, address collateralAsset, address debtAsset) external returns (uint debt, uint baseValue);
    function getDebtValueInCollateral(address member, uint debt, address collateralAsset, address debtAsset) external view returns(uint, uint);
    function getInterestOwed(address collateralAsset, address debtAsset, uint timeElapsed) external returns(uint interestOwed);
    function getInterestPayment(address collateralAsset, address debtAsset) external view returns(uint);
    function getDebtLoading(address collateralAsset, address debtAsset) external view returns(uint);

    function calcPart(uint bp, uint total) external pure returns (uint);
    function calcShare(uint part, uint total, uint amount) external pure returns (uint);
    function calcSwapOutput(uint x, uint X, uint Y) external pure returns (uint);
    function calcSwapFee(uint x, uint X, uint Y) external pure returns (uint);
    function calcSwapSlip(uint x, uint X) external pure returns (uint);
    function calcLiquidityUnits(uint b, uint B, uint t, uint T, uint P) external view returns (uint);
    function getSlipAdustment(uint b, uint B, uint t, uint T) external view returns (uint);
    function calcSynthUnits(uint b, uint B, uint P) external view returns (uint);
    function calcAsymmetricShare(uint u, uint U, uint A) external pure returns (uint);
    function calcCoverage(uint B0, uint T0, uint B1, uint T1) external pure returns(uint);
    function sortArray(uint[] memory array) external pure returns (uint[] memory);
}


// File contracts/interfaces/iVAULT.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iVAULT {
    function setParams(uint newEra, uint newDepositTime, uint newGrantTime) external;
    function grant(address recipient, uint amount) external;

    function deposit(address synth, uint amount) external;
    function depositForMember(address synth, address member, uint amount) external;
    function harvest(address synth) external returns(uint reward);
    function calcCurrentReward(address synth, address member) external view returns(uint reward);
    function calcReward(address synth, address member) external view returns(uint);
    function withdraw(address synth, uint basisPoints) external returns(uint redeemedAmount);
    
    function totalWeight() external view returns(uint);
    function reserveUSDV() external view returns(uint);
    function reserveVADER() external view returns(uint);
    function getMemberDeposit(address synth, address member) external view returns(uint);
    function getMemberWeight(address member) external view returns(uint);
    function getMemberLastTime(address synth, address member) external view returns(uint);
}


// File contracts/DAO.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces





    //======================================VADER=========================================//
contract DAO {

    struct GrantDetails{
        address recipient;
        uint amount;
    }

    bool private inited;
    uint public proposalCount;
    address public VADER;
    address public USDV;
    address public VAULT;
    uint public coolOffPeriod;

    mapping(uint => GrantDetails) public mapPID_grant;
    mapping(uint => address) public mapPID_address;

    mapping(uint => string) public mapPID_type;
    mapping(uint => uint) public mapPID_votes;
    mapping(uint => uint) public mapPID_timeStart;
    mapping(uint => bool) public mapPID_finalising;
    mapping(uint => bool) public mapPID_finalised;
    mapping(uint => mapping(address => uint)) public mapPIDMember_votes;

    event NewProposal(address indexed member, uint indexed proposalID, string proposalType);
    event NewVote(address indexed member, uint indexed proposalID, uint voteWeight, uint totalVotes, string proposalType);
    event ProposalFinalising(address indexed member,uint indexed proposalID, uint timeFinalised, string proposalType);
    event CancelProposal(address indexed member, uint indexed oldProposalID, uint oldVotes, uint newVotes, uint totalWeight);
    event FinalisedProposal(address indexed member,uint indexed proposalID, uint votesCast, uint totalWeight, string proposalType);

    //=====================================CREATION=========================================//
    // Constructor
    constructor() {
    }
    function init(address _vader, address _usdv, address _vault) public {
        require(inited == false);
        inited = true;
        VADER = _vader;
        USDV = _usdv;
        VAULT = _vault;
        coolOffPeriod = 1;
    }

    //============================== CREATE PROPOSALS ================================//
    // Action with funding
    function newGrantProposal(address recipient, uint amount) public {
        string memory typeStr = "GRANT";
        proposalCount += 1;
        mapPID_type[proposalCount] = typeStr;
        GrantDetails memory grant;
        grant.recipient = recipient;
        grant.amount = amount;
        mapPID_grant[proposalCount] = grant;
        emit NewProposal(msg.sender, proposalCount, typeStr);
    }

    // Action with address parameter
    function newAddressProposal(address proposedAddress, string memory typeStr) public {
        proposalCount += 1;
        mapPID_address[proposalCount] = proposedAddress;
        mapPID_type[proposalCount] = typeStr;
        emit NewProposal(msg.sender, proposalCount, typeStr);
    }

//============================== VOTE && FINALISE ================================//

    // Vote for a proposal
    function voteProposal(uint proposalID) public returns (uint voteWeight) {
        bytes memory _type = bytes(mapPID_type[proposalID]);
        voteWeight = countMemberVotes(proposalID);
        if(hasQuorum(proposalID) && mapPID_finalising[proposalID] == false){
            if(isEqual(_type, 'DAO') || isEqual(_type, 'UTILS') || isEqual(_type, 'REWARD')){
                if(hasMajority(proposalID)){
                    _finalise(proposalID);
                }
            } else {
                _finalise(proposalID);
            }
        }
        emit NewVote(msg.sender, proposalID, voteWeight, mapPID_votes[proposalID], string(_type));
    }

    function _finalise(uint _proposalID) internal {
        bytes memory _type = bytes(mapPID_type[_proposalID]);
        mapPID_finalising[_proposalID] = true;
        mapPID_timeStart[_proposalID] = block.timestamp;
        emit ProposalFinalising(msg.sender, _proposalID, block.timestamp+coolOffPeriod, string(_type));
    }

    // If an existing proposal, allow a minority to cancel
    function cancelProposal(uint oldProposalID, uint newProposalID) public {
        require(mapPID_finalising[oldProposalID], "Must be finalising");
        require(hasMinority(newProposalID), "Must have minority");
        require(isEqual(bytes(mapPID_type[oldProposalID]), bytes(mapPID_type[newProposalID])), "Must be same");
        mapPID_votes[oldProposalID] = 0;
        emit CancelProposal(msg.sender, oldProposalID, mapPID_votes[oldProposalID], mapPID_votes[newProposalID], iVAULT(VAULT).totalWeight());
    }

    // Proposal with quorum can finalise after cool off period
    function finaliseProposal(uint proposalID) public  {
        require((block.timestamp - mapPID_timeStart[proposalID]) > coolOffPeriod, "Must be after cool off");
        require(mapPID_finalising[proposalID] == true, "Must be finalising");
        if(!hasQuorum(proposalID)){
            _finalise(proposalID);
        }
        bytes memory _type = bytes(mapPID_type[proposalID]);
        if (isEqual(_type, 'GRANT')){
            grantFunds(proposalID);
        } else if (isEqual(_type, 'UTILS')){
            moveUtils(proposalID);
        } else if (isEqual(_type, 'REWARD')){
            moveRewardAddress(proposalID);
        }
    }

    function completeProposal(uint _proposalID) internal {
        string memory _typeStr = mapPID_type[_proposalID];
        emit FinalisedProposal(msg.sender, _proposalID, mapPID_votes[_proposalID], iVAULT(VAULT).totalWeight(), _typeStr);
        mapPID_votes[_proposalID] = 0;
        mapPID_finalised[_proposalID] = true;
        mapPID_finalising[_proposalID] = false;
    }

//============================== BUSINESS LOGIC ================================//

    function grantFunds(uint _proposalID) internal {
        GrantDetails memory _grant = mapPID_grant[_proposalID];
        require(_grant.amount <= iERC20(USDV).balanceOf(VAULT) / 10, "Not more than 10%");
        completeProposal(_proposalID);
        iVAULT(VAULT).grant(_grant.recipient, _grant.amount);
    }

    function moveUtils(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID];
        require(_proposedAddress != address(0), "No address proposed");
        iVADER(VADER).changeUTILS(_proposedAddress);
        completeProposal(_proposalID);
    }
    function moveRewardAddress(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID];
        require(_proposedAddress != address(0), "No address proposed");
        iVADER(VADER).setRewardAddress(_proposedAddress);
        completeProposal(_proposalID);
    }
//============================== CONSENSUS ================================//

    function countMemberVotes(uint _proposalID) internal returns (uint voteWeight){
        mapPID_votes[_proposalID] -= mapPIDMember_votes[_proposalID][msg.sender];
        voteWeight = iVAULT(VAULT).getMemberWeight(msg.sender);
        mapPID_votes[_proposalID] += voteWeight;
        mapPIDMember_votes[_proposalID][msg.sender] = voteWeight;
    }

    function hasMajority(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID];
        uint consensus = iVAULT(VAULT).totalWeight() / 2; // >50%
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }
    function hasQuorum(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID];
        uint consensus = iVAULT(VAULT).totalWeight() / 3; // >33%
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }
    function hasMinority(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID];
        uint consensus = iVAULT(VAULT).totalWeight() / 6; // >16%
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }
    function isEqual(bytes memory part1, bytes memory part2) public pure returns(bool){
        if(sha256(part1) == sha256(part2)){
            return true;
        } else {
            return false;
        }
    }
    
}


// File contracts/Synth.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces

// Synth Contract
contract Synth is iERC20 {

    address public FACTORY;
    address public TOKEN;

    // Coin Defaults
    string public override name;
    string public override symbol;
    uint public override decimals  = 18;
    uint public override totalSupply;

    // ERC-20 Mappings
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    modifier onlyFACTORY() {
        require(msg.sender == FACTORY, "!FACTORY");
        _;
    }
    
    // Minting event
    constructor(address _token){
        TOKEN = _token;
        FACTORY = msg.sender;
        string memory synthName = " - vSynth";
        string memory synthSymbol = ".v";
        name = string(abi.encodePacked(iERC20(_token).name(), synthName));
        symbol = string(abi.encodePacked(iERC20(_token).symbol(), synthSymbol));
    }

    
    //========================================iERC20=========================================//
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    // iERC20 Transfer function
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // iERC20 Approve, change allowance functions
    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "sender");
        require(spender != address(0), "spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // iERC20 TransferFrom function
    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // TransferTo function
    // Risks: User can be phished, or tx.origin may be deprecated, optionality should exist in the system. 
    function transferTo(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(tx.origin, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "sender");
        require(recipient != address(this), "recipient");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    // Only FACTORY can mint
    function mint(address account, uint amount) external virtual onlyFACTORY {
        require(account != address(0), "recipient");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    // Burn supply
    function burn(uint amount) public virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint amount) public virtual override {
        uint decreasedAllowance = allowance(account, msg.sender) - amount;
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "address err");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}


// File contracts/Factory.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Factory Contract
contract Factory {

    bool private inited;
    address public VADER;
    address public USDV;
    address public POOLS;

    address[] public arraySynths;
    mapping(address => address) public getSynth;
    mapping(address => bool) public isSynth;

    event CreateSynth(address indexed token, address indexed pool);

    modifier onlyPOOLS() {
        require(msg.sender == POOLS, "!POOLS");
        _;
    }
    
    constructor(){
    }
    function init(address _pool) public {
        require(inited == false);
        inited = true;
        POOLS = _pool;
    }

    //Create a synth asset
    function deploySynth(address token) external onlyPOOLS returns(address synth) {
        require(getSynth[token] == address(0), "CreateErr");
        Synth newSynth;
        newSynth = new Synth(token);  
        synth = address(newSynth);
        _addSynth(token, synth);
        emit CreateSynth(token, synth);
    }

    function mintSynth(address synth, address member, uint amount) external onlyPOOLS returns(bool) {
         Synth(synth).mint(member, amount); 
        return true;
    }

    // function getSynth(address token) public view returns (address synth){
    //     return mapToken_Synth[token];
    // }
    // function isSynth(address token) public view returns (bool _isSynth){
    //     if(_isListedSynth[token] == true){
    //         return true;
    //     }
    // }

    function _addSynth(address _token, address _synth) internal {
        getSynth[_token] = _synth;
        arraySynths.push(_synth); 
        isSynth[_synth] = true;
    }

}


// File contracts/interfaces/iFACTORY.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iFACTORY{
    function deploySynth(address) external returns(address);
    function mintSynth(address, address, uint) external returns(bool);
    function getSynth(address) external view returns (address);
    function isSynth(address) external view returns (bool);
}


// File contracts/Pools.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces




contract Pools {

    // Parameters
    bool private inited;
    uint public pooledVADER;
    uint public pooledUSDV;
    
    address public VADER;
    address public USDV;
    address public ROUTER;
    address public FACTORY;

    mapping(address => bool) _isMember;
    mapping(address => bool) _isAsset;
    mapping(address => bool) _isAnchor;

    mapping(address => uint) public mapToken_Units;
    mapping(address => mapping(address => uint)) public mapTokenMember_Units;
    mapping(address => uint) public mapToken_baseAmount;
    mapping(address => uint) public mapToken_tokenAmount;

    // Events
    event AddLiquidity(address indexed member, address indexed base, uint baseAmount, address indexed token, uint tokenAmount, uint liquidityUnits);
    event RemoveLiquidity(address indexed member, address indexed base, uint baseAmount, address indexed token, uint tokenAmount, uint liquidityUnits, uint totalUnits);
    event Swap(address indexed member, address indexed inputToken, uint inputAmount, address indexed outputToken, uint outputAmount, uint swapFee);
    event Sync(address indexed token, address indexed pool, uint addedAmount);
    event SynthSync(address indexed token, uint burntSynth, uint deletedUnits);

    //=====================================CREATION=========================================//
    // Constructor
    constructor() {}

    // Init
    function init(address _vader, address _usdv, address _router, address _factory) public {
        require(inited == false);
        inited = true;
        VADER = _vader;
        USDV = _usdv;
        ROUTER = _router;
        FACTORY = _factory;
    }

    //====================================LIQUIDITY=========================================//

    function addLiquidity(address base, address token, address member) external returns(uint liquidityUnits) {
        require(token != USDV && token != VADER); // Prohibited
        uint _actualInputBase;
        if(base == VADER){
            if(!isAnchor(token)){               // If new Anchor
                _isAnchor[token] = true;
            }
            _actualInputBase = getAddedAmount(VADER, token);
        } else if (base == USDV) {
            if(!isAsset(token)){               // If new Asset
                _isAsset[token] = true;
            }
            _actualInputBase = getAddedAmount(USDV, token);
        }
        uint _actualInputToken = getAddedAmount(token, token);
        liquidityUnits = iUTILS(UTILS()).calcLiquidityUnits(_actualInputBase, mapToken_baseAmount[token], _actualInputToken, mapToken_tokenAmount[token], mapToken_Units[token]);
        mapTokenMember_Units[token][member] += liquidityUnits;  // Add units to member
        mapToken_Units[token] += liquidityUnits;                // Add in total
        mapToken_baseAmount[token] += _actualInputBase;         // Add BASE
        mapToken_tokenAmount[token] += _actualInputToken;       // Add token
        emit AddLiquidity(member, base, _actualInputBase, token, _actualInputToken, liquidityUnits);
    }

    function removeLiquidity(address base, address token, uint basisPoints) external returns (uint outputBase, uint outputToken) {
        return _removeLiquidity(base, token, basisPoints, tx.origin); // Because this contract is wrapped by a router
    }
    function removeLiquidityDirectly(address base, address token, uint basisPoints) external returns (uint outputBase, uint outputToken) {
        return _removeLiquidity(base, token, basisPoints, msg.sender); // If want to interact directly
    }
    function _removeLiquidity(address base, address token, uint basisPoints, address member) internal returns (uint outputBase, uint outputToken) {
        require(base == USDV || base == VADER);
        uint _units = iUTILS(UTILS()).calcPart(basisPoints, mapTokenMember_Units[token][member]);
        outputBase = iUTILS(UTILS()).calcShare(_units, mapToken_Units[token], mapToken_baseAmount[token]);
        outputToken = iUTILS(UTILS()).calcShare(_units, mapToken_Units[token], mapToken_tokenAmount[token]);
        mapToken_Units[token] -=_units;
        mapTokenMember_Units[token][member] -= _units;
        mapToken_baseAmount[token] -= outputBase;
        mapToken_tokenAmount[token] -= outputToken;
        emit RemoveLiquidity(member, base, outputBase, token, outputToken, _units, mapToken_Units[token]);
        transferOut(base, outputBase, member);
        transferOut(token, outputToken, member);
        return (outputBase, outputToken);
    }
    
    //=======================================SWAP===========================================//
    
    // Designed to be called by a router, but can be called directly
    function swap(address base, address token, address member, bool toBase) external returns (uint outputAmount) {
        if(toBase){
            uint _actualInput = getAddedAmount(token, token);
            outputAmount = iUTILS(UTILS()).calcSwapOutput(_actualInput, mapToken_tokenAmount[token], mapToken_baseAmount[token]);
            uint _swapFee = iUTILS(UTILS()).calcSwapFee(_actualInput, mapToken_tokenAmount[token], mapToken_baseAmount[token]);
            mapToken_tokenAmount[token] += _actualInput;
            mapToken_baseAmount[token] -= outputAmount;
            emit Swap(member, token, _actualInput, base, outputAmount, _swapFee);
            transferOut(base, outputAmount, member);
        } else {
            uint _actualInput = getAddedAmount(base, token);
            outputAmount = iUTILS(UTILS()).calcSwapOutput(_actualInput, mapToken_baseAmount[token], mapToken_tokenAmount[token]);
            uint _swapFee = iUTILS(UTILS()).calcSwapFee(_actualInput, mapToken_baseAmount[token], mapToken_tokenAmount[token]);
            mapToken_baseAmount[token] += _actualInput;
            mapToken_tokenAmount[token] -= outputAmount;
            emit Swap(member, base, _actualInput, token, outputAmount, _swapFee);
            transferOut(token, outputAmount, member);
        }
    }

    // Add to balances directly (must send first)
    function sync(address token, address pool) external {
        uint _actualInput = getAddedAmount(token, pool);
        if (token == VADER || token == USDV){
            mapToken_baseAmount[pool] += _actualInput;
        } else {
            mapToken_tokenAmount[pool] += _actualInput;
        // } else if(isSynth()){
        //     //burnSynth && deleteUnits
        }
        emit Sync(token, pool, _actualInput);
    }

    //======================================SYNTH=========================================//

    // Should be done with intention, is gas-intensive
    function deploySynth(address token) external {
        require(token != VADER || token != USDV);
        iFACTORY(FACTORY).deploySynth(token);
    }

    // Mint a Synth against its own pool
    function mintSynth(address base, address token, address member) external returns (uint outputAmount) {
        require(iFACTORY(FACTORY).isSynth(getSynth(token)), "!synth");
        uint _actualInputBase = getAddedAmount(base, token);                    // Get input
        uint _synthUnits = iUTILS(UTILS()).calcSynthUnits(_actualInputBase, mapToken_baseAmount[token], mapToken_Units[token]);     // Get Units
        outputAmount = iUTILS(UTILS()).calcSwapOutput(_actualInputBase, mapToken_baseAmount[token], mapToken_tokenAmount[token]);   // Get output
        mapTokenMember_Units[token][address(this)] += _synthUnits;                  // Add units for self
        mapToken_Units[token] += _synthUnits;                                       // Add supply
        mapToken_baseAmount[token] += _actualInputBase;                             // Add BASE 
        emit AddLiquidity(member, base, _actualInputBase, token, 0, _synthUnits);   // Add Liquidity Event
        iFACTORY(FACTORY).mintSynth(getSynth(token), member, outputAmount);         // Ask factory to mint to member
    }
    // Burn a Synth to get out BASE
    function burnSynth(address base, address token, address member) external returns (uint outputBase) {
        uint _actualInputSynth = iERC20(getSynth(token)).balanceOf(address(this));  // Get input
        uint _unitsToDelete = iUTILS(UTILS()).calcShare(_actualInputSynth, iERC20(getSynth(token)).totalSupply(), mapTokenMember_Units[token][address(this)]); // Pro rata
        iERC20(getSynth(token)).burn(_actualInputSynth);                            // Burn it
        mapTokenMember_Units[token][address(this)] -= _unitsToDelete;               // Delete units for self
        mapToken_Units[token] -= _unitsToDelete;                                    // Delete units
        outputBase = iUTILS(UTILS()).calcSwapOutput(_actualInputSynth, mapToken_tokenAmount[token], mapToken_baseAmount[token]);    // Get output
        mapToken_baseAmount[token] -= outputBase;                                   // Remove BASE
        emit RemoveLiquidity(member, base, outputBase, token, 0, _unitsToDelete, mapToken_Units[token]);        // Remove liquidity event
        transferOut(base, outputBase, member);                                      // Send BASE to member
    }
    // Remove a synth, make other LPs richer
    function syncSynth(address token) external {
        uint _actualInputSynth = iERC20(getSynth(token)).balanceOf(address(this));  // Get input
        uint _unitsToDelete = iUTILS(UTILS()).calcShare(_actualInputSynth, iERC20(getSynth(token)).totalSupply(), mapTokenMember_Units[token][address(this)]); // Pro rata
        iERC20(getSynth(token)).burn(_actualInputSynth);                            // Burn it
        mapTokenMember_Units[token][address(this)] -= _unitsToDelete;               // Delete units for self
        mapToken_Units[token] -= _unitsToDelete;                                    // Delete units
        emit SynthSync(token, _actualInputSynth, _unitsToDelete);
    }

    //======================================LENDING=========================================//
    
    // Assign units to callee (ie, a LendingRouter)
    function lockUnits(uint units, address token, address member) external {
        mapTokenMember_Units[token][member] -= units;
        mapTokenMember_Units[token][msg.sender] += units;       // Assign to protocol
    }
    // Assign units to callee (ie, a LendingRouter)
    function unlockUnits(uint units, address token, address member) external {
        mapTokenMember_Units[token][msg.sender] -= units;      
        mapTokenMember_Units[token][member] += units;
    }

    //======================================HELPERS=========================================//

    // Safe adds
    function getAddedAmount(address _token, address _pool) internal returns(uint addedAmount) {
        uint _balance = iERC20(_token).balanceOf(address(this));
        if(_token == VADER && _pool != VADER){  // Want to know added VADER
            addedAmount = _balance - pooledVADER;
            pooledVADER = pooledVADER + addedAmount;
        } else if(_token == USDV) {             // Want to know added USDV
            addedAmount = _balance - pooledUSDV;
            pooledUSDV = pooledUSDV + addedAmount;
        } else {                                // Want to know added Asset/Anchor
            addedAmount = _balance - mapToken_tokenAmount[_pool];
        }
    }
    function transferOut(address _token, uint _amount, address _recipient) internal {
        if(_token == VADER){
            pooledVADER = pooledVADER - _amount; // Accounting
        } else if(_token == USDV) {
            pooledUSDV = pooledUSDV - _amount;  // Accounting
        }
        if(_recipient != address(this)){
            iERC20(_token).transfer(_recipient, _amount);
        }
    }

    function isMember(address member) public view returns(bool) {
        return _isMember[member];
    }
    function isAsset(address token) public view returns(bool) {
        return _isAsset[token];
    }
    function isAnchor(address token) public view returns(bool) {
        return _isAnchor[token];
    }
    function getPoolAmounts(address token) external view returns(uint, uint) {
        return (getBaseAmount(token), getTokenAmount(token));
    }
    function getBaseAmount(address token) public view returns(uint) {
        return mapToken_baseAmount[token];
    }
    function getTokenAmount(address token) public view returns(uint) {
        return mapToken_tokenAmount[token];
    }
    function getUnits(address token) external view returns(uint) {
        return mapToken_Units[token];
    }
    function getMemberUnits(address token, address member) external view returns(uint) {
        return mapTokenMember_Units[token][member];
    }
    function getSynth(address token) public view returns (address) {
        return iFACTORY(FACTORY).getSynth(token);
    }
    function isSynth(address token) public view returns (bool) {
        return iFACTORY(FACTORY).isSynth(token);
    }
    function UTILS() public view returns(address){
        return iVADER(VADER).UTILS();
    }
}


// File contracts/interfaces/iPOOLS.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iPOOLS{
    function pooledVADER() external view returns(uint);
    function pooledUSDV() external view returns(uint);
    function addLiquidity(address base, address token, address member) external returns(uint liquidityUnits);
    function removeLiquidity(address base, address token, uint basisPoints) external returns (uint outputBase, uint outputToken);
    function sync(address token, address pool) external;
    function swap(address base, address token, address member, bool toBase) external returns (uint outputAmount);
    function deploySynth(address token) external;
    function mintSynth(address base, address token, address member) external returns (uint outputAmount);
    function burnSynth(address base, address token, address member) external returns (uint outputBase);
    function syncSynth(address token) external;
    function lockUnits(uint units, address token, address member) external;
    function unlockUnits(uint units, address token, address member) external;
    function isMember(address member) external view returns(bool);
    function isAsset(address token) external view returns(bool);
    function isAnchor(address token) external view returns(bool);
    function getPoolAmounts(address token) external view returns(uint, uint);
    function getBaseAmount(address token) external view returns(uint);
    function getTokenAmount(address token) external view returns(uint);
    function getUnits(address token) external view returns(uint);
    function getMemberUnits(address token, address member) external view returns(uint);
    function getSynth(address token) external returns (address);
    function isSynth(address token) external returns (bool);
}


// File contracts/interfaces/iSYNTH.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iSYNTH {
    function mint(address account, uint amount) external;
    function TOKEN() external view returns(address);
}


// File hardhat/console.sol@v2.22.17


library console {
    address constant CONSOLE_ADDRESS =
        0x000000000000000000636F6e736F6c652e6c6f67;

    function _sendLogPayloadImplementation(bytes memory payload) internal view {
        address consoleAddress = CONSOLE_ADDRESS;
        /// @solidity memory-safe-assembly
        assembly {
            pop(
                staticcall(
                    gas(),
                    consoleAddress,
                    add(payload, 32),
                    mload(payload),
                    0,
                    0
                )
            )
        }
    }

    function _castToPure(
      function(bytes memory) internal view fnIn
    ) internal pure returns (function(bytes memory) pure fnOut) {
        assembly {
            fnOut := fnIn
        }
    }

    function _sendLogPayload(bytes memory payload) internal pure {
        _castToPure(_sendLogPayloadImplementation)(payload);
    }

    function log() internal pure {
        _sendLogPayload(abi.encodeWithSignature("log()"));
    }

    function logInt(int256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
    }

    function logUint(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }

    function logString(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function logBool(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }

    function logAddress(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }

    function logBytes(bytes memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
    }

    function logBytes1(bytes1 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
    }

    function logBytes2(bytes2 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
    }

    function logBytes3(bytes3 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
    }

    function logBytes4(bytes4 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
    }

    function logBytes5(bytes5 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
    }

    function logBytes6(bytes6 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
    }

    function logBytes7(bytes7 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
    }

    function logBytes8(bytes8 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
    }

    function logBytes9(bytes9 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
    }

    function logBytes10(bytes10 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
    }

    function logBytes11(bytes11 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
    }

    function logBytes12(bytes12 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
    }

    function logBytes13(bytes13 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
    }

    function logBytes14(bytes14 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
    }

    function logBytes15(bytes15 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
    }

    function logBytes16(bytes16 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
    }

    function logBytes17(bytes17 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
    }

    function logBytes18(bytes18 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
    }

    function logBytes19(bytes19 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
    }

    function logBytes20(bytes20 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
    }

    function logBytes21(bytes21 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
    }

    function logBytes22(bytes22 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
    }

    function logBytes23(bytes23 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
    }

    function logBytes24(bytes24 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
    }

    function logBytes25(bytes25 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
    }

    function logBytes26(bytes26 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
    }

    function logBytes27(bytes27 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
    }

    function logBytes28(bytes28 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
    }

    function logBytes29(bytes29 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
    }

    function logBytes30(bytes30 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
    }

    function logBytes31(bytes31 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
    }

    function logBytes32(bytes32 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
    }

    function log(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }

    function log(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }

    function log(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }

    function log(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }

    function log(uint256 p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
    }

    function log(uint256 p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
    }

    function log(uint256 p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
    }

    function log(uint256 p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
    }

    function log(string memory p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }

    function log(string memory p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
    }

    function log(string memory p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
    }

    function log(string memory p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
    }

    function log(bool p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
    }

    function log(bool p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
    }

    function log(bool p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
    }

    function log(bool p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
    }

    function log(address p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
    }

    function log(address p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
    }

    function log(address p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
    }

    function log(address p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
    }

    function log(uint256 p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
    }

    function log(uint256 p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
    }

    function log(uint256 p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
    }

    function log(uint256 p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
    }

    function log(string memory p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
    }

    function log(string memory p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
    }

    function log(string memory p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
    }

    function log(string memory p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
    }

    function log(string memory p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
    }

    function log(string memory p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
    }

    function log(string memory p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
    }

    function log(bool p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
    }

    function log(bool p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
    }

    function log(bool p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
    }

    function log(bool p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
    }

    function log(bool p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
    }

    function log(bool p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
    }

    function log(bool p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
    }

    function log(bool p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
    }

    function log(bool p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
    }

    function log(bool p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
    }

    function log(address p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
    }

    function log(address p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
    }

    function log(address p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
    }

    function log(address p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
    }

    function log(address p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
    }

    function log(address p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
    }

    function log(address p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
    }

    function log(address p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
    }

    function log(address p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
    }

    function log(address p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
    }

    function log(address p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
    }

    function log(address p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
    }

    function log(address p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
    }

    function log(uint256 p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
    }

    function log(string memory p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
    }

    function log(bool p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
    }

    function log(address p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
    }
}


// File contracts/Router.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces





contract Router {

    // Parameters
    bool private inited;
    uint one = 10**18;
    uint public rewardReductionFactor;
    uint public timeForFullProtection;

    uint public curatedPoolLimit;
    uint public curatedPoolCount;
    mapping(address => bool) private _isCurated;
    
    address public VADER;
    address public USDV;
    address public POOLS;

    uint public anchorLimit;
    uint public insidePriceLimit;
    uint public outsidePriceLimit;
    address[] public arrayAnchors;
    uint[] public arrayPrices;

    uint public repayDelay = 3600;

    mapping(address => mapping(address => uint)) public mapMemberToken_depositBase;
    mapping(address => mapping(address => uint)) public mapMemberToken_depositToken;
    mapping(address => mapping(address => uint)) public mapMemberToken_lastDeposited;

    mapping(address => CollateralDetails) private mapMember_Collateral;
    mapping(address => mapping(address => uint)) private mapCollateralDebt_Collateral;
    mapping(address => mapping(address => uint)) private mapCollateralDebt_Debt;
    mapping(address => mapping(address => uint)) private mapCollateralDebt_interestPaid; 
    mapping(address => mapping(address => uint)) private mapCollateralAsset_NextEra;

    struct CollateralDetails {
        uint ID;
        mapping(address => DebtDetails) mapCollateral_Debt;
    }
    struct DebtDetails{
        uint ID;
        mapping(address =>uint) debt; //assetC > AssetD > AmountDebt
        mapping(address =>uint) collateral; //assetC > AssetD > AmountCol
        // mapping(address =>uint) assetCollateralDeposit; //assetC > AssetD > AmountCol
        // mapping(address =>uint) timeBorrowed; // assetC > AssetD > time
        // mapping(address =>uint) currentDay; // assetC > AssetD > time
    }

    event PoolReward(address indexed base, address indexed token, uint amount);
    event Protection(address indexed member, uint amount);
    event Curated(address indexed curator, address indexed token);

    event AddCollateral(address indexed member, address indexed collateralAsset, uint collateralLocked, address indexed debtAsset, uint debtIssued);
    event RemoveCollateral(address indexed member, address indexed collateralAsset, uint collateralUnlocked, address indexed debtAsset, uint debtReturned);

    // Only DAO can execute
    modifier onlyDAO() {
        require(msg.sender == DAO(), "Not DAO");
        _;
    }

    //=====================================CREATION=========================================//
    // Constructor
    constructor() {}
    // Init
    function init(address _vader, address _usdv, address _pool) public {
        require(inited == false,  "inited");
        inited = true;
        VADER = _vader;
        USDV = _usdv;
        POOLS = _pool;
        rewardReductionFactor = 1;
        timeForFullProtection = 1;//8640000; //100 days
        curatedPoolLimit = 1;
        anchorLimit = 5;
        insidePriceLimit = 200;
        outsidePriceLimit = 500;
    }

    //=========================================DAO=========================================//
    // Can set params
    function setParams(uint newFactor, uint newTime, uint newLimit) external onlyDAO {
        rewardReductionFactor = newFactor;
        timeForFullProtection = newTime;
        curatedPoolLimit = newLimit;
    }
    function setAnchorParams(uint newLimit, uint newInside, uint newOutside) external onlyDAO {
        anchorLimit = newLimit;
        insidePriceLimit = newInside;
        outsidePriceLimit = newOutside;
    }

    //====================================LIQUIDITY=========================================//

    function addLiquidity(address base, uint inputBase, address token, uint inputToken) external returns(uint){
        uint _actualInputBase = moveTokenToPools(base, inputBase);
        uint _actualInputToken = moveTokenToPools(token, inputToken);
        addDepositData(msg.sender, token, _actualInputBase, _actualInputToken); 
        return iPOOLS(POOLS).addLiquidity(base, token, msg.sender);
    }

    function removeLiquidity(address base, address token, uint basisPoints) external returns (uint amountBase, uint amountToken) {
        (amountBase, amountToken) = iPOOLS(POOLS).removeLiquidity(base, token, basisPoints);
        uint _protection = getILProtection(msg.sender, base, token, basisPoints);
        removeDepositData(msg.sender, token, basisPoints, _protection); 
        iERC20(base).transfer(msg.sender, _protection);
    }

      //=======================================SWAP===========================================//
    
    function swap(uint inputAmount, address inputToken, address outputToken) external returns (uint outputAmount) {
        return swapWithSynthsWithLimit(inputAmount, inputToken, false, outputToken, false, 10000);
    }
    function swapWithLimit(uint inputAmount, address inputToken, address outputToken, uint slipLimit) external returns (uint outputAmount) {
        return swapWithSynthsWithLimit(inputAmount, inputToken, false, outputToken, false, slipLimit);
    }

    function swapWithSynths(uint inputAmount, address inputToken, bool inSynth, address outputToken, bool outSynth) external returns (uint outputAmount) {
        return swapWithSynthsWithLimit(inputAmount, inputToken, inSynth, outputToken, outSynth, 10000);
    }

    function swapWithSynthsWithLimit(uint inputAmount, address inputToken, bool inSynth, address outputToken, bool outSynth, uint slipLimit) public returns (uint outputAmount) {
        address _member = msg.sender;
        if(!inSynth){
            moveTokenToPools(inputToken, inputAmount);
        } else {
            moveTokenToPools(iPOOLS(POOLS).getSynth(inputToken), inputAmount);
        }
        address _base;
        if(iPOOLS(POOLS).isAnchor(inputToken) || iPOOLS(POOLS).isAnchor(outputToken)) {
            _base = VADER;
        } else {
            _base = USDV;
        }
        if (isBase(outputToken)) {
            // Token||Synth -> BASE
            require(iUTILS(UTILS()).calcSwapSlip(inputAmount, iPOOLS(POOLS).getTokenAmount(inputToken)) <= slipLimit);
            if(!inSynth){
                outputAmount = iPOOLS(POOLS).swap(_base, inputToken, _member, true);
            } else {
                outputAmount = iPOOLS(POOLS).burnSynth(_base, inputToken, _member);
            }
        } else if (isBase(inputToken)) {
            // BASE -> Token||Synth
            require(iUTILS(UTILS()).calcSwapSlip(inputAmount, iPOOLS(POOLS).getBaseAmount(outputToken)) <= slipLimit);
            if(!outSynth){
                outputAmount = iPOOLS(POOLS).swap(_base, outputToken, _member, false);
            } else {
                outputAmount = iPOOLS(POOLS).mintSynth(_base, outputToken, _member);
            }
        } else if (!isBase(inputToken) && !isBase(outputToken)) {
            // Token||Synth -> Token||Synth
            require(iUTILS(UTILS()).calcSwapSlip(inputAmount, iPOOLS(POOLS).getTokenAmount(inputToken)) <= slipLimit);
            if(!inSynth){
                iPOOLS(POOLS).swap(_base, inputToken, POOLS, true);
            } else {
                iPOOLS(POOLS).burnSynth(_base, inputToken, POOLS);
            }
            require(iUTILS(UTILS()).calcSwapSlip(inputAmount, iPOOLS(POOLS).getBaseAmount(outputToken)) <= slipLimit);
            if(!outSynth){
                outputAmount = iPOOLS(POOLS).swap(_base, outputToken, _member, false);
            } else {
                outputAmount = iPOOLS(POOLS).mintSynth(_base, outputToken, _member);
            }
        }
        _handlePoolReward(_base, inputToken);
        _handlePoolReward(_base, outputToken);
        _handleAnchorPriceUpdate(inputToken);
        _handleAnchorPriceUpdate(outputToken); 
    }

    //====================================INCENTIVES========================================//

    function _handlePoolReward(address _base, address _token) internal{
        if(!isBase(_token)){                        // USDV or VADER is never a pool
            uint _reward = iUTILS(UTILS()).getRewardShare(_token, rewardReductionFactor);
            iERC20(_base).transfer(POOLS, _reward);
            iPOOLS(POOLS).sync(_base, _token);
            emit PoolReward(_base, _token, _reward);
        }
    }

    //=================================IMPERMANENT LOSS=====================================//
    
    function addDepositData(address member, address token, uint amountBase, uint amountToken) internal {
        mapMemberToken_depositBase[member][token] += amountBase;
        mapMemberToken_depositToken[member][token] += amountToken;
        mapMemberToken_lastDeposited[member][token] = block.timestamp;
    }
    function removeDepositData(address member, address token, uint basisPoints, uint protection) internal {
        mapMemberToken_depositBase[member][token] += protection;
        uint _baseToRemove = iUTILS(UTILS()).calcPart(basisPoints, mapMemberToken_depositBase[member][token]);
        uint _tokenToRemove = iUTILS(UTILS()).calcPart(basisPoints, mapMemberToken_depositToken[member][token]);
        mapMemberToken_depositBase[member][token] -= _baseToRemove;
        mapMemberToken_depositToken[member][token] -= _tokenToRemove;
    }

    function getILProtection(address member, address base, address token, uint basisPoints) public view returns(uint protection) {
        protection = iUTILS(UTILS()).getProtection(member, token, basisPoints, timeForFullProtection);
        if(base == VADER){
            if(protection >= reserveVADER()){
                protection = reserveVADER(); // In case reserve is running out
            }
        } else {
            if(protection >= reserveUSDV()){
                protection = reserveUSDV(); // In case reserve is running out
            }
        }
    }
    
    //=====================================CURATION==========================================//

    function curatePool(address token) external {
        require(iPOOLS(POOLS).isAsset(token) || iPOOLS(POOLS).isAnchor(token));
        if(!isCurated(token)){
            if(curatedPoolCount < curatedPoolLimit){ // Limit
                _isCurated[token] = true;
                curatedPoolCount += 1;
            }
        }
        emit Curated(msg.sender, token);
    }
    function replacePool(address oldToken, address newToken) external {
        require(iPOOLS(POOLS).isAsset(newToken));
        if(iPOOLS(POOLS).getBaseAmount(newToken) > iPOOLS(POOLS).getBaseAmount(oldToken)){ // Must be deeper
            _isCurated[oldToken] = false;
            _isCurated[newToken] = true;
            emit Curated(msg.sender, newToken);
        }
    }

    //=====================================ANCHORS==========================================//

    function listAnchor(address token) external {
        require(arrayAnchors.length < anchorLimit); // Limit
        require(iPOOLS(POOLS).isAnchor(token));     // Must be anchor
        arrayAnchors.push(token);                   // Add
        arrayPrices.push(iUTILS(UTILS()).calcValueInBase(token, one));
        _isCurated[token] = true; 
        updateAnchorPrice(token);
    }

    function replaceAnchor(address oldToken, address newToken) external {
        require(iPOOLS(POOLS).isAnchor(newToken), "Not anchor");
        require((iPOOLS(POOLS).getBaseAmount(newToken) > iPOOLS(POOLS).getBaseAmount(oldToken)), "Not deeper");
        iUTILS(UTILS()).requirePriceBounds(oldToken, outsidePriceLimit, false, getAnchorPrice());                             // if price oldToken >5%
        iUTILS(UTILS()).requirePriceBounds(newToken, insidePriceLimit, true, getAnchorPrice());                               // if price newToken <2%
        _isCurated[oldToken] = false; 
        _isCurated[newToken] = true; 
        for(uint i = 0; i<arrayAnchors.length; i++){
            if(arrayAnchors[i] == oldToken){
                arrayAnchors[i] = newToken;
            }
        }
        updateAnchorPrice(newToken);
    }

    // Anyone to update prices
    function updateAnchorPrice(address token) public {
        for(uint i = 0; i<arrayAnchors.length; i++){
            if(arrayAnchors[i] == token){
                arrayPrices[i] = iUTILS(UTILS()).calcValueInBase(arrayAnchors[i], one);
            }
        }
    }

    function _handleAnchorPriceUpdate(address _token) internal{
        if(iPOOLS(POOLS).isAnchor(_token)){
            updateAnchorPrice(_token);
        }
    }

    // Price of 1 VADER in USD
    function getAnchorPrice() public view returns (uint anchorPrice) {
        if(arrayPrices.length > 0){
            uint[] memory _sortedAnchorFeed = iUTILS(UTILS()).sortArray(arrayPrices);  // Sort price array, no need to modify storage
            anchorPrice = _sortedAnchorFeed[2];                         // Return the middle
        } else {
            anchorPrice = one;          // Edge case for first USDV mint
        }
    }

    // The correct amount of Vader for an input of USDV
    function getVADERAmount(uint USDVAmount) public view returns (uint vaderAmount){
        uint _price = getAnchorPrice();
        return (_price * USDVAmount) / one;
    }

    // The correct amount of USDV for an input of VADER
    function getUSDVAmount(uint vaderAmount) public view returns (uint USDVAmount){
        uint _price = getAnchorPrice();
        return (vaderAmount * one) / _price;
    }
    
    
    //======================================LENDING=========================================//

    // Draw debt for self
    function borrow(uint amount, address collateralAsset, address debtAsset) public returns (uint) {
        return borrowForMember(msg.sender, amount, collateralAsset, debtAsset);
    }

    function borrowForMember(address member, uint amount, address collateralAsset, address debtAsset) public returns(uint) {
        iUTILS(UTILS()).assetChecks(collateralAsset, debtAsset);
        uint _collateral = _handleTransferIn(member, collateralAsset, amount);                  // get collateral 
        (uint _debtIssued, uint _baseBorrowed) = iUTILS(UTILS()).getCollateralValueInBase(member, _collateral, collateralAsset, debtAsset);
        mapCollateralDebt_Collateral[collateralAsset][debtAsset] += _collateral;               // Record collateral 
        mapCollateralDebt_Debt[collateralAsset][debtAsset] += _debtIssued;                            // Record debt
        _addDebtToMember(member, _collateral, collateralAsset, _debtIssued, debtAsset);    // Update member details
        if(collateralAsset == VADER || iPOOLS(POOLS).isAnchor(debtAsset)){
            iERC20(VADER).transfer(POOLS, _baseBorrowed);                                  // Send to pools
            iPOOLS(POOLS).swap(VADER, debtAsset, member, false);                         // Execute swap to member
        } else if(collateralAsset == USDV || iPOOLS(POOLS).isAsset(debtAsset)) {
            iERC20(USDV).transfer(POOLS, _baseBorrowed);                                  // Send to pools
            iPOOLS(POOLS).swap(USDV, debtAsset, member, false);                         // Execute swap to member
        }
        emit AddCollateral(member, collateralAsset, amount, debtAsset, _debtIssued);               // Event
        payInterest(collateralAsset, debtAsset);
        return _debtIssued;
    }

    // Repay for self
    function repay(uint amount, address collateralAsset, address debtAsset) public returns (uint){
        return repayForMember(msg.sender, amount, collateralAsset, debtAsset);
    }
     // Repay for member
    function repayForMember(address member, uint basisPoints, address collateralAsset, address debtAsset) public returns (uint){
        uint _amount = iUTILS(UTILS()).calcPart(basisPoints, getMemberDebt(member, collateralAsset, debtAsset));
        uint _debt = moveTokenToPools(debtAsset, _amount);    // Get Debt
        if(collateralAsset == VADER || iPOOLS(POOLS).isAnchor(debtAsset)){
            iPOOLS(POOLS).swap(VADER, debtAsset, address(this), true);           // Swap Debt to Base back here
        } else if(collateralAsset == USDV || iPOOLS(POOLS).isAsset(debtAsset)) {
            iPOOLS(POOLS).swap(USDV, debtAsset, address(this), true);           // Swap Debt to Base back here
        }
        (uint _collateralUnlocked,  uint _memberInterestShare) = iUTILS(UTILS()).getDebtValueInCollateral(member, _debt, collateralAsset, debtAsset); // Unlock collateral that is pro-rata to re-paid debt ($50/$100 = 50%)
        mapCollateralDebt_Collateral[collateralAsset][debtAsset] -= _collateralUnlocked;               // Update collateral 
        mapCollateralDebt_Debt[collateralAsset][debtAsset] -= _debt;                   // Update debt 
        mapCollateralDebt_interestPaid[collateralAsset][debtAsset] -= _memberInterestShare;
        _removeDebtFromMember(member, _collateralUnlocked, collateralAsset, _debt, debtAsset);  // Remove
        emit RemoveCollateral(member, collateralAsset, _collateralUnlocked, debtAsset, _debt);
        _handleTransferOut(member, collateralAsset, _collateralUnlocked);
        payInterest(collateralAsset, debtAsset);
        return _collateralUnlocked;
    }

    // Called once a day to pay interest
    function payInterest(address collateralAsset, address debtAsset) internal {
        if (block.timestamp >= getNextEraTime(collateralAsset, debtAsset) && emitting()) {                              // If new Era
            uint _timeElapsed = block.timestamp - mapCollateralAsset_NextEra[collateralAsset][debtAsset];
            mapCollateralAsset_NextEra[collateralAsset][debtAsset] = block.timestamp + iVADER(VADER).secondsPerEra(); 
            uint _interestOwed = iUTILS(UTILS()).getInterestOwed(collateralAsset, debtAsset, _timeElapsed);
            mapCollateralDebt_interestPaid[collateralAsset][debtAsset] += _interestOwed;
            _removeCollateral(_interestOwed, collateralAsset, debtAsset);
            if(isBase(collateralAsset)){
                iERC20(collateralAsset).transfer(POOLS, _interestOwed);
                iPOOLS(POOLS).sync(collateralAsset, debtAsset);
            } else if(iPOOLS(POOLS).isSynth(collateralAsset)){
                iERC20(collateralAsset).transfer(POOLS, _interestOwed);
                iPOOLS(POOLS).syncSynth(iSYNTH(collateralAsset).TOKEN());
            }
        }
    }

    function checkLiquidate() public {
        // get member remaining Collateral: originalDeposit - shareOfInterestPayments
        // if remainingCollateral <= 101% * debtValueInCollateral
        // purge, send remaining collateral to liquidator
    }

    // function purgeMember() public {

    // }

    // Get Collateral
    function _handleTransferIn(address _member, address _collateralAsset, uint _amount) internal returns(uint _inputAmount){
        if(isBase(_collateralAsset) || iPOOLS(POOLS).isSynth(_collateralAsset)){
            _inputAmount = _getFunds(_collateralAsset, _amount); // Get funds
        }else if(isPool(_collateralAsset)){
             iPOOLS(POOLS).lockUnits(_amount, _collateralAsset, _member); // Lock units to protocol
             _inputAmount = _amount;
        }
    }
    // Send Collateral
    function _handleTransferOut(address _member, address _collateralAsset, uint _amount) internal{
        if(isBase(_collateralAsset) || iPOOLS(POOLS).isSynth(_collateralAsset)){
            _sendFunds(_collateralAsset, _member, _amount); // Send Base
        }else if(isPool(_collateralAsset)){
            iPOOLS(POOLS).unlockUnits(_amount, _collateralAsset, _member); // Unlock units to member
        }
    }

    function _getFunds(address _token, uint _amount) internal returns(uint) {
        uint _balance = iERC20(_token).balanceOf(address(this));
        if(tx.origin==msg.sender){
            require(iERC20(_token).transferTo(address(this), _amount));
        }else{
            require(iERC20(_token).transferFrom(msg.sender, address(this), _amount));
        }
        return iERC20(_token).balanceOf(address(this)) - _balance;
    }

    function _sendFunds(address _token, address _member, uint _amount) internal {
        require(iERC20(_token).transfer(_member, _amount));
    }

    function _addDebtToMember(address _member, uint _collateral, address _collateralAsset, uint _debt, address _debtAsset) internal {
        mapMember_Collateral[_member].mapCollateral_Debt[_collateralAsset].debt[_debtAsset] += _debt;
        mapMember_Collateral[_member].mapCollateral_Debt[_collateralAsset].collateral[_debtAsset] += _collateral;
    }
    function _removeDebtFromMember(address _member, uint _collateral, address _collateralAsset, uint _debt, address _debtAsset) internal {
        mapMember_Collateral[_member].mapCollateral_Debt[_collateralAsset].debt[_debtAsset] -= _debt;
        mapMember_Collateral[_member].mapCollateral_Debt[_collateralAsset].collateral[_debtAsset] -= _collateral;
    }
    function _removeCollateral(uint _collateral, address _collateralAsset, address _debtAsset) internal {
        mapCollateralDebt_Collateral[_collateralAsset][_debtAsset] -= _collateral;               // Record collateral 
    }



    //======================================HELPERS=========================================//

    function isBase(address token) public view returns(bool base) {
        if(token == VADER || token == USDV){
            return true;
        }
    }

    function reserveVADER() public view returns(uint) {
        return iERC20(VADER).balanceOf(address(this));
    }
    function reserveUSDV() public view returns(uint) {
        return iERC20(USDV).balanceOf(address(this));
    }

    // Optionality
    function moveTokenToPools(address _token, uint _amount) internal returns(uint safeAmount) {
        if(_token == VADER || _token == USDV || iPOOLS(POOLS).isSynth(_token)){
            safeAmount = _amount;
            if(tx.origin==msg.sender){
                iERC20(_token).transferTo(POOLS, _amount);
            }else{
                iERC20(_token).transferFrom(msg.sender, POOLS, _amount);
            }
        } else {
            uint _startBal = iERC20(_token).balanceOf(POOLS);
            iERC20(_token).transferFrom(msg.sender, POOLS, _amount);
            safeAmount = iERC20(_token).balanceOf(POOLS) - _startBal;
        }
    }

    

    function UTILS() public view returns(address){
        return iVADER(VADER).UTILS();
    }
    function DAO() public view returns(address){
        return iVADER(VADER).DAO();
    }
    function emitting() public view returns(bool){
        return iVADER(VADER).emitting();
    }
    function isCurated(address token) public view returns(bool curated) {
        if(_isCurated[token]){
            curated = true;
        }
    }
    function isPool(address token) public view returns(bool pool) {
        if(iPOOLS(POOLS).isAnchor(token) || iPOOLS(POOLS).isAsset(token)){
            pool = true;
        }
    }

    function getMemberBaseDeposit(address member, address token) external view returns(uint) {
        return mapMemberToken_depositBase[member][token];
    }
    function getMemberTokenDeposit(address member, address token) external view returns(uint) {
        return mapMemberToken_depositToken[member][token];
    }
    function getMemberLastDeposit(address member, address token) external view returns(uint) {
        return mapMemberToken_lastDeposited[member][token];
    }
    function getMemberCollateral(address member, address collateralAsset, address debtAsset) external view returns(uint) {
        return mapMember_Collateral[member].mapCollateral_Debt[collateralAsset].collateral[debtAsset];
    }
    function getMemberDebt(address member, address collateralAsset, address debtAsset) public view returns(uint) {
        return mapMember_Collateral[member].mapCollateral_Debt[collateralAsset].debt[debtAsset];
    }
    function getSystemCollateral(address collateralAsset, address debtAsset) public view returns(uint) {
        return mapCollateralDebt_Collateral[collateralAsset][debtAsset];
    }
    function getSystemDebt(address collateralAsset, address debtAsset) public view returns(uint) {
        return mapCollateralDebt_Debt[collateralAsset][debtAsset];
    }
    function getSystemInterestPaid(address collateralAsset, address debtAsset) public view returns(uint) {
        return mapCollateralDebt_interestPaid[collateralAsset][debtAsset];
    }
    function getNextEraTime(address collateralAsset, address debtAsset) public view returns(uint) {
        return mapCollateralAsset_NextEra[collateralAsset][debtAsset];
    }
}


// File contracts/Token1.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces

// Token Contract
contract Token1 is iERC20 {

    // Coin Defaults
    string public override name;                                         // Name of Coin
    string public override symbol;                                       // Symbol of Coin
    uint public override decimals  = 18;                              // Decimals
    uint public override totalSupply  = 1*10**9 * (10 ** decimals);   // 1,000,000 Total

    // ERC-20 Mappings
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    
    // Minting event
    constructor(){
        _balances[msg.sender] = totalSupply;
        name = "Token1";
        symbol  = "TKN1";
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    //========================================iERC20=========================================//
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    // iERC20 Transfer function
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // iERC20 Approve, change allowance functions
    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "sender");
        require(spender != address(0), "spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // iERC20 TransferFrom function
    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // TransferTo function
    // Risks: User can be phished, or tx.origin may be deprecated, optionality should exist in the system. 
    function transferTo(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(tx.origin, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "sender");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    // Internal mint (upgrading and daily emissions)
    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "recipient");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    // Burn supply
    function burn(uint amount) public virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint amount) public virtual override {
        uint decreasedAllowance = allowance(account, msg.sender) - amount;
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "address err");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}


// File contracts/Token2.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces

// Token Contract
contract Token2 is iERC20 {

    // Coin Defaults
    string public override name;                                         // Name of Coin
    string public override symbol;                                       // Symbol of Coin
    uint public override decimals  = 18;                              // Decimals
    uint public override totalSupply  = 1*10**9 * (10 ** decimals);   // 1,000,000 Total

    // ERC-20 Mappings
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    
    // Minting event
    constructor() {
        _balances[msg.sender] = totalSupply;
        name = "Token2";
        symbol  = "TKN2";
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    //========================================iERC20=========================================//
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    // iERC20 Transfer function
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // iERC20 Approve, change allowance functions
    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "sender");
        require(spender != address(0), "spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // iERC20 TransferFrom function
    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // TransferTo function
    // Risks: User can be phished, or tx.origin may be deprecated, optionality should exist in the system. 
    function transferTo(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(tx.origin, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "sender");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    // Internal mint (upgrading and daily emissions)
    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "recipient");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    // Burn supply
    function burn(uint amount) public virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint amount) public virtual override {
        uint decreasedAllowance = allowance(account, msg.sender) - amount;
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "address err");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}


// File contracts/USDV.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces



contract USDV is iERC20 {

    // ERC-20 Parameters
    string public override name; string public override symbol;
    uint public override decimals; uint public override totalSupply;

    // ERC-20 Mappings
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    // Parameters
    bool private inited;
    uint public nextEraTime;
    uint public blockDelay;

    address public VADER;
    address public VAULT;
    address public ROUTER;

    mapping(address => uint) public lastBlock;

    // Only DAO can execute
    modifier onlyDAO() {
        require(msg.sender == DAO(), "Not DAO");
        _;
    }
    // Stop flash attacks
    modifier flashProof() {
        require(isMature(), "No flash");
        _;
    }
    function isMature() public view returns(bool isMatured){
        if(lastBlock[tx.origin] + blockDelay <= block.number){ // Stops an EOA doing a flash attack in same block
            return true;
        }
    }

    //=====================================CREATION=========================================//
    // Constructor
    constructor() {
        name = 'VADER STABLE DOLLAR';
        symbol = 'USDV';
        decimals = 18;
        totalSupply = 0;
    }
    function init(address _vader, address _vault, address _router) external {
        require(inited == false);
        inited = true;
        VADER = _vader;
        VAULT = _vault;
        ROUTER = _router;
        nextEraTime = block.timestamp + iVADER(VADER).secondsPerEra();
    }

    //========================================iERC20=========================================//
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    // iERC20 Transfer function
    function transfer(address recipient, uint amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // iERC20 Approve, change allowance functions
    function approve(address spender, uint amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "sender");
        require(spender != address(0), "spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // iERC20 TransferFrom function
    function transferFrom(address sender, address recipient, uint amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // TransferTo function
    // Risks: User can be phished, or tx.origin may be deprecated, optionality should exist in the system. 
    function transferTo(address recipient, uint amount) external virtual override returns (bool) {
        _transfer(tx.origin, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint amount) internal virtual {
        if(amount > 0){                                     // Due to design, this function may be called with 0
            require(sender != address(0), "sender");
            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            _checkIncentives();
        }
    }
    // Internal mint (upgrading and daily emissions)
    function _mint(address account, uint amount) internal virtual {
        if(amount > 0){                                     // Due to design, this function may be called with 0
            require(account != address(0), "recipient");
            totalSupply += amount;
            _balances[account] += amount;
            emit Transfer(address(0), account, amount);
        }
    }
    // Burn supply
    function burn(uint amount) external virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint amount) external virtual override {
        uint decreasedAllowance = allowance(account, msg.sender)- amount;
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    function _burn(address account, uint amount) internal virtual {
        if(amount > 0){                                     // Due to design, this function may be called with 0
            require(account != address(0), "address err");
            _balances[account] -= amount;
            totalSupply -= amount;
            emit Transfer(account, address(0), amount);
        }
    }

    //=========================================DAO=========================================//
    // Can set params
    function setParams(uint newDelay) external onlyDAO {
        blockDelay = newDelay;
    }

   //======================================INCENTIVES========================================//
    // Internal - Update incentives function
    function _checkIncentives() private {
        if (block.timestamp >= nextEraTime && emitting()) {                 // If new Era
            nextEraTime = block.timestamp + iVADER(VADER).secondsPerEra(); 
            uint _balance = iERC20(VADER).balanceOf(address(this));         // Get spare VADER
            if(_balance > 4){
                uint _USDVShare = _balance/2;                                   // Get 50%
                _convert(address(this), _USDVShare);                            // Convert it
                if(balanceOf(address(this)) > 2){
                    _transfer(address(this), ROUTER, balanceOf(address(this)) / 2);              // Send half USDV to ROUTER
                    _transfer(address(this), VAULT, balanceOf(address(this)));                   // Send rest to VAULT
                }
                iERC20(VADER).transfer(ROUTER, iERC20(VADER).balanceOf(address(this))/2);   // Send half VADER to ROUTER
                iERC20(VADER).transfer(VAULT, iERC20(VADER).balanceOf(address(this)));      // Send rest to VAULT
            }
        }
    }
    
    //======================================ASSET MINTING========================================//
    // Convert to USDV
    function convert(uint amount) external returns(uint) {
        return convertForMember(msg.sender, amount);
    }
    // Convert for members
    function convertForMember(address member, uint amount) public returns(uint) {
        getFunds(VADER, amount);
        return _convert(member, amount);
    }
    // Internal convert
    function _convert(address _member, uint amount) internal flashProof returns(uint _convertAmount){
        if(minting()){
            lastBlock[tx.origin] = block.number;                    // Record first
            iERC20(VADER).burn(amount);
            _convertAmount = iROUTER(ROUTER).getUSDVAmount(amount); // Critical pricing functionality
            _mint(_member, _convertAmount);
        }
    }
    // Redeem to VADER
    function redeem(uint amount) external returns(uint) {
        return redeemForMember(msg.sender, amount);
    }
    // Contracts to redeem for members
    function redeemForMember(address member, uint amount) public returns(uint redeemAmount) {
        _transfer(msg.sender, VADER, amount);                   // Move funds
        redeemAmount = iVADER(VADER).redeemToMember(member);    // Ask VADER to redeem
        lastBlock[tx.origin] = block.number;                    // Must record block AFTER the tx
    }

    //============================== ASSETS ================================//

    function getFunds(address token, uint amount) internal {
        if(token == address(this)){
            _transfer(msg.sender, address(this), amount);
        } else {
            if(tx.origin==msg.sender){
                require(iERC20(token).transferTo(address(this), amount));
            }else{
                require(iERC20(token).transferFrom(msg.sender, address(this), amount));
            }
        }
    }

    //============================== HELPERS ================================//

    function DAO() public view returns(address){
        return iVADER(VADER).DAO();
    }
    function emitting() public view returns(bool){
        return iVADER(VADER).emitting();
    }
    function minting() public view returns(bool){
        return iVADER(VADER).minting();
    }

}


// File contracts/Utils.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces






contract Utils {

    uint private one = 10**18;
    uint private _10k = 10000;
    uint private _year = 31536000; // One Year (in seconds)

    bool private inited;

    address public VADER;
    address public USDV;
    address public ROUTER;
    address public POOLS;
    address public FACTORY;

    constructor () {}

    function init(address _vader, address _usdv, address _router, address _pools, address _factory) public {
        require(inited == false,  "inited");
        inited = true;
        VADER = _vader;
        USDV = _usdv;
        ROUTER = _router;
        POOLS = _pools;
        FACTORY = _factory;
    }
    //====================================SYSTEM FUNCTIONS====================================//
    // VADER FeeOnTransfer
    function getFeeOnTransfer(uint totalSupply, uint maxSupply) external pure returns(uint){
        return calcShare(totalSupply, maxSupply, 100); // 0->100BP
    }

    function assetChecks(address collateralAsset, address debtAsset) external {
        if(collateralAsset == VADER){
            require(iPOOLS(POOLS).isAnchor(debtAsset), "Bad Combo"); // Can borrow Anchor with VADER/ANCHOR-SYNTH
        } else if(collateralAsset == USDV){
            require(iPOOLS(POOLS).isAsset(debtAsset), "Bad Combo"); // Can borrow Asset with VADER/ASSET-SYNTH
        } else if(iPOOLS(POOLS).isSynth(collateralAsset) && iPOOLS(POOLS).isAnchor(iSYNTH(collateralAsset).TOKEN())){
            require(iPOOLS(POOLS).isAnchor(debtAsset), "Bad Combo"); // Can borrow Anchor with VADER/ANCHOR-SYNTH
        } else if(iPOOLS(POOLS).isSynth(collateralAsset) && iPOOLS(POOLS).isAsset(iSYNTH(collateralAsset).TOKEN())){
            require(iPOOLS(POOLS).isAsset(debtAsset), "Bad Combo"); // Can borrow Anchor with VADER/ANCHOR-SYNTH
        }
    }

    function isBase(address token) public view returns(bool base) {
        if(token == VADER || token == USDV){
            return true;
        }
    }
    function isPool(address token) public view returns(bool pool) {
        if(iPOOLS(POOLS).isAnchor(token) || iPOOLS(POOLS).isAsset(token)){
            pool = true;
        }
    }

    //====================================PRICING====================================//

    function calcValueInBase(address token, uint amount) public view returns (uint value){
       (uint _baseAmt, uint _tokenAmt) = iPOOLS(POOLS).getPoolAmounts(token);
       if(_baseAmt > 0 && _tokenAmt > 0){
            return (amount * _baseAmt) / _tokenAmt;
       }
    }

    function calcValueInToken(address token, uint amount) public view returns (uint value){
        (uint _baseAmt, uint _tokenAmt) = iPOOLS(POOLS).getPoolAmounts(token);
        if(_baseAmt > 0 && _tokenAmt > 0){
            return (amount * _tokenAmt) / _baseAmt;
       }
    }
    function calcValueOfTokenInToken(address token1, uint amount, address token2) public view returns (uint value){
            return calcValueInToken(token2, calcValueInBase(token1, amount));
    }

    function calcSwapValueInBase(address token, uint amount) public view returns (uint){
        (uint _baseAmt, uint _tokenAmt) = iPOOLS(POOLS).getPoolAmounts(token);
        return calcSwapOutput(amount, _tokenAmt, _baseAmt);
    }
    function calcSwapValueInToken(address token, uint amount) public view returns (uint){
        (uint _baseAmt, uint _tokenAmt) = iPOOLS(POOLS).getPoolAmounts(token);
        return calcSwapOutput(amount, _baseAmt, _tokenAmt);
    }

    function requirePriceBounds(address token, uint bound, bool inside, uint targetPrice) external view {
        uint _testingPrice = calcValueInBase(token, one);
        uint _lower = calcPart((_10k - bound), targetPrice);                // ie 98% of price
        uint _upper = (targetPrice * (_10k + bound)) / _10k;                // ie 105% of price
        if(inside){
            require((_testingPrice >= _lower && _testingPrice <= _upper), "Not inside");
        } else {
            require((_testingPrice <= _lower || _testingPrice >= _upper), "Not outside");
        }
    }

    //====================================INCENTIVES========================================//

    function getRewardShare(address token, uint rewardReductionFactor) external view returns (uint rewardShare) {
        if(iVADER(VADER).emitting() && iROUTER(ROUTER).isCurated(token)){
            uint _baseAmount = iPOOLS(POOLS).getBaseAmount(token);
            if (iPOOLS(POOLS).isAsset(token)) {
                uint _share = calcShare(_baseAmount, iPOOLS(POOLS).pooledUSDV(), iROUTER(ROUTER).reserveUSDV());
                rewardShare = getReducedShare(_share, rewardReductionFactor);
            } else if(iPOOLS(POOLS).isAnchor(token)) {
                uint _share = calcShare(_baseAmount, iPOOLS(POOLS).pooledVADER(), iROUTER(ROUTER).reserveVADER());
                rewardShare = getReducedShare(_share, rewardReductionFactor);
            }
        }
    }

    function getReducedShare(uint amount, uint rewardReductionFactor) public pure returns(uint) {
        return calcShare(1, rewardReductionFactor, amount); // Reduce to stop depleting fast
    }

    //=================================IMPERMANENT LOSS=====================================//

    // Actual protection with 100 day rule and Reserve balance
    function getProtection(address member, address token, uint basisPoints, uint timeForFullProtection) public view returns(uint protection) {
        uint _coverage = getCoverage(member, token);
        if(iROUTER(ROUTER).isCurated(token)){
            uint _duration = block.timestamp - iROUTER(ROUTER).getMemberLastDeposit(member, token);
            if(_duration <= timeForFullProtection) {
                protection = calcShare(_duration, timeForFullProtection, _coverage); // Apply 100 day rule
            } else {
                protection = _coverage;
            }
        }
        return calcPart(basisPoints, protection);
    }
    // Theoretical coverage based on deposit/redemption values
    function getCoverage(address member, address token) public view returns (uint) {
        uint _B0 = iROUTER(ROUTER).getMemberBaseDeposit(member, token); uint _T0 = iROUTER(ROUTER).getMemberTokenDeposit(member, token);
        uint _units = iPOOLS(POOLS).getMemberUnits(token, member);
        uint _B1 = calcShare(_units, iPOOLS(POOLS).getUnits(token), iPOOLS(POOLS).getBaseAmount(token));
        uint _T1 = calcShare(_units, iPOOLS(POOLS).getUnits(token), iPOOLS(POOLS).getTokenAmount(token));
        return calcCoverage(_B0, _T0, _B1, _T1);
    }

    //==================================== LENDING ====================================//

    function getCollateralValueInBase(address member, uint collateral, address collateralAsset, address debtAsset) external view returns (uint debt, uint baseValue) {
        uint _collateralAdjusted = (collateral * 6666) / 10000; // 150% collateral Ratio
        if(isBase(collateralAsset)){
            baseValue = _collateralAdjusted;
        }else if(isPool(collateralAsset)){
            baseValue = calcAsymmetricShare(_collateralAdjusted, iPOOLS(POOLS).getMemberUnits(collateralAsset, member), iPOOLS(POOLS).getBaseAmount(collateralAsset)); // calc units to BASE
        }else if(iFACTORY(FACTORY).isSynth(collateralAsset)){
            baseValue = calcSwapValueInBase(iSYNTH(collateralAsset).TOKEN(), _collateralAdjusted); // Calc swap value
        }
        debt = calcSwapValueInToken(debtAsset, baseValue);        // get debt output
        return (debt, baseValue);
    }

    function getDebtValueInCollateral(address member, uint debt, address collateralAsset, address debtAsset) external view returns(uint, uint) {
        uint _memberDebt = iROUTER(ROUTER).getMemberDebt(member, collateralAsset, debtAsset); // Outstanding Debt
        uint _memberCollateral = iROUTER(ROUTER).getMemberCollateral(member, collateralAsset, debtAsset); // Collateral
        uint _collateral = iROUTER(ROUTER).getSystemCollateral(collateralAsset, debtAsset);
        uint _interestPaid = iROUTER(ROUTER).getSystemInterestPaid(collateralAsset, debtAsset);
        uint _memberInterestShare = calcShare(_memberCollateral, _collateral, _interestPaid); // Share of interest based on collateral
        uint _collateralUnlocked = calcShare(debt, _memberDebt, _memberCollateral); 
        return (_collateralUnlocked, _memberInterestShare);
    }

    function getInterestOwed(address collateralAsset, address debtAsset, uint timeElapsed) external view returns(uint interestOwed) {
        uint _interestPayment = calcShare(timeElapsed, _year, getInterestPayment(collateralAsset, debtAsset)); // Share of the payment over 1 year
        if(isBase(collateralAsset)){
            interestOwed = calcValueInBase(debtAsset, _interestPayment); // Back to base
        } else if(iFACTORY(FACTORY).isSynth(collateralAsset)) {
            interestOwed = calcValueOfTokenInToken(debtAsset, _interestPayment, collateralAsset); // Get value of Synth in debtAsset (doubleSwap)
        }
    }
    function getInterestPayment(address collateralAsset, address debtAsset) public view returns(uint) {
        uint _debtLoading = getDebtLoading(collateralAsset, debtAsset);
        return (_debtLoading * iROUTER(ROUTER).getSystemDebt(collateralAsset, debtAsset)) / 10000; 
    }
    function getDebtLoading(address collateralAsset, address debtAsset) public view returns(uint) {
        uint _debtIssued = iROUTER(ROUTER).getSystemDebt(collateralAsset, debtAsset);
        uint _debtDepth = iPOOLS(POOLS).getTokenAmount(debtAsset);
        return (_debtIssued * 10000) / _debtDepth; 
    }

    //====================================CORE-MATH====================================//

    function calcPart(uint bp, uint total) public pure returns (uint){
        // 10,000 basis points = 100.00%
        require((bp <= 10000) && (bp >= 0), "Must be correct BP");
        return calcShare(bp, 10000, total);
    }

    function calcShare(uint part, uint total, uint amount) public pure returns (uint share){
        // share = amount * part/total
        if(part > total){
            part = total;
        }
        if(total > 0){
            share = (amount * part) / total;
        }
    }

    function calcSwapOutput(uint x, uint X, uint Y) public pure returns (uint){
        // y = (x * X * Y )/(x + X)^2
        uint numerator = (x * X * Y);
        uint denominator = (x + X) * (x + X);
        return (numerator / denominator);
    }

    function calcSwapFee(uint x, uint X, uint Y) external pure returns (uint){
        // fee = (x * x * Y) / (x + X)^2
        uint numerator = (x * x * Y);
        uint denominator = (x + X) * (x + X);
        return (numerator / denominator);
    }
    function calcSwapSlip(uint x, uint X) external pure returns (uint){
        // slip = (x) / (x + X)
        return (x*10000) / (x + X);
    }

    function calcLiquidityUnits(uint b, uint B, uint t, uint T, uint P) external view returns (uint){
        if(P == 0){
            return b;
        } else {
            // units = ((P (t B + T b))/(2 T B)) * slipAdjustment
            // P * (part1 + part2) / (part3) * slipAdjustment
            uint slipAdjustment = getSlipAdustment(b, B, t, T);
            uint part1 = (t * B);
            uint part2 = (T * b);
            uint part3 = (T * B) * 2;
            uint _units = (((P * part1) + part2) / part3);
            return (_units * slipAdjustment) / one;  // Divide by 10**18
        }
    }

    function getSlipAdustment(uint b, uint B, uint t, uint T) public view returns (uint){
        // slipAdjustment = (1 - ABS((B t - b T)/((2 b + B) (t + T))))
        // 1 - ABS(part1 - part2)/(part3 * part4))
        uint part1 = B * t;
        uint part2 = b * T;
        uint part3 = (b * 2) + B;
        uint part4 = t + T;
        uint numerator;
        if(part1 > part2){
            numerator = (part1 - part2);
        } else {
            numerator = (part2 - part1);
        }
        uint denominator = (part3 * part4);
        return one - (numerator * one) / denominator; // Multiply by 10**18
    }

    function calcSynthUnits(uint b, uint B, uint P) external pure returns(uint){
        // (P * b)/(2*(b + B))
        return (P * b) / (2 * (b + B));
    }

    function calcAsymmetricShare(uint u, uint U, uint A) public pure returns (uint){
        // share = (u * U * (2 * A^2 - 2 * U * u + U^2))/U^3
        // (part1 * (part2 - part3 + part4)) / part5
        uint part1 = (u * A);
        uint part2 = ((U * U) * 2);
        uint part3 = ((U * u) * 2);
        uint part4 = (u * u);
        uint numerator = ((part1 * part2) - part3) + part4;
        uint part5 = ((U * U) * U);
        return (numerator / part5);
    }
    function calcCoverage(uint B0, uint T0, uint B1, uint T1) public pure returns(uint coverage){
        if(B0 > 0 && T1 > 0){
            uint _depositValue = B0 + (T0 * B1) / T1; // B0+(T0*B1/T1)
            uint _redemptionValue = B1 + (T1 * B1) / T1; // B1+(T1*B1/T1)
            if(_redemptionValue <= _depositValue){
                coverage = (_depositValue - _redemptionValue);
            }
        }
    }

    // Sorts array in memory from low to high, returns in-memory (Does not need to modify storage)
    function sortArray(uint[] memory array) external pure returns (uint[] memory) {
        uint l = array.length;
        for(uint i = 0; i < l; i++){
            for(uint j = i+1; j < l; j++){
                if(array[i] > array[j]){
                    uint temp = array[i];
                    array[i] = array[j];
                    array[j] = temp;
                }
            }
        }
        return array;
    }

}


// File contracts/Vader.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces




contract Vader is iERC20 {

    // ERC-20 Parameters
    string public override name; string public override symbol;
    uint public override decimals; uint public override totalSupply;

    // ERC-20 Mappings
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;

    // Parameters
    bool private inited;
    bool public emitting;
    bool public minting;
    uint _1m;
    uint public baseline;
    uint public emissionCurve;
    uint public maxSupply;
    uint public secondsPerEra;
    uint public currentEra;
    uint public nextEraTime;
    uint public feeOnTransfer;

    address public VETHER;
    address public USDV;
    address public UTILS;
    address public burnAddress;
    address public rewardAddress;
    address public DAO;

    event NewEra(uint currentEra, uint nextEraTime, uint emission);

    // Only DAO can execute
    modifier onlyDAO() {
        require(msg.sender == DAO, "Not DAO");
        _;
    }
    // Stop flash attacks
    modifier flashProof() {
        require(isMature(), "No flash");
        _;
    }
    function isMature() public view returns(bool){
        return iUSDV(USDV).isMature();
    }

    //=====================================CREATION=========================================//
    // Constructor
    constructor() {
        name = 'VADER PROTOCOL TOKEN';
        symbol = 'VADER';
        decimals = 18;
        _1m = 10**6 * 10 ** decimals; //1m
        baseline = _1m;
        totalSupply = 0;
        maxSupply = 2 * _1m;
        currentEra = 1;
        secondsPerEra = 1; //86400;
        nextEraTime = block.timestamp + secondsPerEra;
        emissionCurve = 900;
        DAO = msg.sender;
        burnAddress = 0x0111011001100001011011000111010101100101;
    }
    // Can only be called once
    function init(address _vether, address _USDV, address _utils) external {
        require(inited == false);
        inited = true;
        VETHER = _vether;
        USDV = _USDV;
        UTILS = _utils;
        rewardAddress = _USDV;
    }

    //========================================iERC20=========================================//
    function balanceOf(address account) external view override returns (uint) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    // iERC20 Transfer function
    function transfer(address recipient, uint amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // iERC20 Approve, change allowance functions
    function approve(address spender, uint amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "sender");
        require(spender != address(0), "spender");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // iERC20 TransferFrom function
    function transferFrom(address sender, address recipient, uint amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // TransferTo function
    // Risks: User can be phished, or tx.origin may be deprecated, optionality should exist in the system. 
    function transferTo(address recipient, uint amount) external virtual override returns (bool) {
        _transfer(tx.origin, recipient, amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "sender");
        require(recipient != address(this), "recipient");
        _balances[sender] -= amount;
        uint _fee = iUTILS(UTILS).calcPart(feeOnTransfer, amount);  // Critical functionality
        if(_fee >= 0 && _fee <= amount){                            // Stops reverts if UTILS corrupted
            amount -= _fee;
            _burn(msg.sender, _fee);
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _checkEmission();
    }
    // Internal mint (upgrading and daily emissions)
    function _mint(address account, uint amount) internal virtual {
        require(account != address(0), "recipient");
        if((totalSupply + amount) >= maxSupply){
            amount = maxSupply - totalSupply;       // Safety, can't mint above maxSupply
        }
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    // Burn supply
    function burn(uint amount) public virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint amount) external virtual override {
        uint decreasedAllowance = allowance(account, msg.sender) - amount;
        _approve(account, msg.sender, decreasedAllowance);
        _burn(account, amount);
    }
    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "address err");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    //=========================================DAO=========================================//
    // Can start
    function flipEmissions() external onlyDAO {
        if(emitting){
            emitting = false;
        } else {
            emitting = true;
        }
    }
    // Can stop
    function flipMinting() external onlyDAO {
        if(minting){
            minting = false;
        } else {
            minting = true;
        }
    }
    // Can set params
    function setParams(uint newEra, uint newCurve) external onlyDAO {
        secondsPerEra = newEra;
        emissionCurve = newCurve;
    }
    // Can set reward address
    function setRewardAddress(address newAddress) external onlyDAO {
        rewardAddress = newAddress;
    }
    // Can change UTILS
    function changeUTILS(address newUTILS) external onlyDAO {
        require(newUTILS != address(0), "address err");
        UTILS = newUTILS;
    }
    // Can change DAO
    function changeDAO(address newDAO) external onlyDAO {
        require(newDAO != address(0), "address err");
        DAO = newDAO;
    }
    // Can purge DAO
    function purgeDAO() external onlyDAO{
        DAO = address(0);
    }

   //======================================EMISSION========================================//
    // Internal - Update emission function
    function _checkEmission() private {
        if ((block.timestamp >= nextEraTime) && emitting) {                                // If new Era and allowed to emit
            currentEra += 1;                                                               // Increment Era
            nextEraTime = block.timestamp + secondsPerEra;                                 // Set next Era time
            uint _emission = getDailyEmission();                                           // Get Daily Dmission
            _mint(rewardAddress, _emission);                                               // Mint to the Rewad Address
            feeOnTransfer = iUTILS(UTILS).getFeeOnTransfer(totalSupply, maxSupply);        // UpdateFeeOnTransfer
            if(feeOnTransfer > 1000){feeOnTransfer = 1000;}                                // Max 10% if UTILS corrupted
            emit NewEra(currentEra, nextEraTime, _emission);                               // Emit Event
        }
    }
    // Calculate Daily Emission
    function getDailyEmission() public view returns (uint) {
        uint _adjustedMax;
        if(totalSupply <= baseline){ // If less than 1m, then adjust cap down
            _adjustedMax = (maxSupply * totalSupply) / baseline; // 2m * 0.5m / 1m = 2m * 50% = 1.5m
        } else {
            _adjustedMax = maxSupply;  // 2m
        }
        return (_adjustedMax - totalSupply) / (emissionCurve); // outstanding / curve 
    }

    //======================================ASSET MINTING========================================//
    // VETHER Owners to Upgrade
    function upgrade(uint amount) external {
        require(iERC20(VETHER).transferFrom(msg.sender, burnAddress, amount));
        _mint(msg.sender, amount);
    }
    // Directly redeem back to VADER (must have sent USDV first)
    function redeem() external returns (uint redeemAmount){
        return redeemToMember(msg.sender);
    }
    // Redeem on behalf of member (must have sent USDV first)
    function redeemToMember(address member) public flashProof returns (uint redeemAmount){
        if(minting){
            uint _amount = iERC20(USDV).balanceOf(address(this)); 
            iERC20(USDV).burn(_amount);
            redeemAmount = iROUTER(iUSDV(USDV).ROUTER()).getVADERAmount(_amount); // Critical pricing functionality
            _mint(member, redeemAmount);
        }
    }
}


// File contracts/Vault.sol









contract Vault {

    bool private inited;
    uint public erasToEarn;
    uint public minGrantTime;
    uint public lastGranted;

    address public VADER;
    address public USDV;
    address public ROUTER;
    address public POOLS;
    address public FACTORY;

    uint public minimumDepositTime;
    uint public totalWeight;

    mapping(address => uint) private mapMember_weight;
    mapping(address => mapping(address => uint)) private mapMemberSynth_deposit;
    mapping(address => mapping(address => uint)) private mapMemberSynth_lastTime;

    // Events
    event MemberDeposits(address indexed synth, address indexed member, uint amount, uint weight, uint totalWeight);
    event MemberWithdraws(address indexed synth, address indexed member, uint amount, uint weight, uint totalWeight);
    event MemberHarvests(address indexed synth, address indexed member, uint amount, uint weight, uint totalWeight);

    // Only DAO can execute
    modifier onlyDAO() {
        require(msg.sender == DAO(), "Not DAO");
        _;
    }

    constructor(){}

    function init(address _vader, address _usdv, address _router, address _factory, address _pool) public {
        require(inited == false);
        inited = true;
        POOLS = _pool;
        VADER = _vader;
        USDV = _usdv;
        ROUTER = _router;
        FACTORY = _factory;
        POOLS = _pool;
        erasToEarn = 100;
        minimumDepositTime = 1;
        minGrantTime = 2592000;     // 30 days
    }

    //=========================================DAO=========================================//
    // Can set params
    function setParams(uint newEra, uint newDepositTime, uint newGrantTime) external onlyDAO {
        erasToEarn = newEra;
        minimumDepositTime = newDepositTime;
        minGrantTime = newGrantTime;
    }

    // Can issue grants
    function grant(address recipient, uint amount) public onlyDAO {
        require((block.timestamp - lastGranted) >= minGrantTime, "not too fast");
        lastGranted = block.timestamp;
        iERC20(USDV).transfer(recipient, amount); 
    }

    //======================================DEPOSITS========================================//

    // Deposit USDV or SYNTHS
    function deposit(address synth, uint amount) external {
        depositForMember(synth, msg.sender, amount);
    }
    // Wrapper for contracts
    function depositForMember(address synth, address member, uint amount) public {
        require((iFACTORY(FACTORY).isSynth(synth)), "Not Synth"); // Only Synths
        getFunds(synth, amount);
        _deposit(synth, member, amount);
    }
    function _deposit(address _synth, address _member, uint _amount) internal {
        mapMemberSynth_lastTime[_member][_synth] = block.timestamp;         // Time of deposit
        mapMemberSynth_deposit[_member][_synth] += _amount;                 // Record deposit
        uint _weight = iUTILS(UTILS()).calcValueInBase(iSYNTH(_synth).TOKEN(), _amount);
        if(iPOOLS(POOLS).isAnchor(iSYNTH(_synth).TOKEN())){
            _weight = iROUTER(ROUTER).getUSDVAmount(_weight);               // Price in USDV
        }
        mapMember_weight[_member] += _weight;                               // Total member weight 
        totalWeight += _weight;                                             // Total weight 
        emit MemberDeposits(_synth, _member, _amount, _weight, totalWeight);
    }

    //====================================== HARVEST ========================================//

    // Harvest, get payment, allocate, increase weight
    function harvest(address synth) external returns(uint reward) {
        address _member = msg.sender;
        uint _weight;
        address _token = iSYNTH(synth).TOKEN();
        reward = calcCurrentReward(synth, _member);                     // In USDV
        mapMemberSynth_lastTime[_member][synth] = block.timestamp;      // Reset time
        if(iPOOLS(POOLS).isAsset(_token)){
            iERC20(USDV).transfer(POOLS, reward); 
            reward = iPOOLS(POOLS).mintSynth(USDV, _token, address(this));
            _weight = iUTILS(UTILS()).calcValueInBase(_token, reward);
        } else {
            iERC20(VADER).transfer(POOLS, reward); 
            reward = iPOOLS(POOLS).mintSynth(VADER, _token, address(this));
            _weight = iROUTER(ROUTER).getUSDVAmount(iUTILS(UTILS()).calcValueInBase(_token, reward));
        }
        mapMemberSynth_deposit[_member][synth] += reward; 
        mapMember_weight[_member] += _weight;
        totalWeight += _weight;
        emit MemberHarvests(synth, _member, reward, _weight, totalWeight);
    }

    // Get the payment owed for a member
    function calcCurrentReward(address synth, address member) public view returns(uint reward) {
        uint _secondsSinceClaim = block.timestamp - mapMemberSynth_lastTime[member][synth];        // Get time since last claim
        uint _share = calcReward(synth, member);                                               // Get share of rewards for member
        reward = (_share * _secondsSinceClaim) / iVADER(VADER).secondsPerEra();         // Get owed amount, based on per-day rates
        uint _reserve;
        if(iPOOLS(POOLS).isAsset(iSYNTH(synth).TOKEN())){
            _reserve = reserveUSDV();
        } else {
            _reserve = reserveVADER();
        }
        if(reward >= _reserve) {
            reward = _reserve;                                                          // Send full reserve if the last
        }
    }

    function calcReward(address synth, address member) public view returns(uint reward) {
        uint _weight = mapMember_weight[member];  
        if(iPOOLS(POOLS).isAsset(iSYNTH(synth).TOKEN())){
            uint _adjustedReserve = iROUTER(ROUTER).getUSDVAmount(reserveVADER()) + reserveUSDV();      // Aggregrate reserves
            return iUTILS(UTILS()).calcShare(_weight, totalWeight, _adjustedReserve / erasToEarn);                   // Get member's share of that
        } else{
            uint _adjustedReserve = iROUTER(ROUTER).getUSDVAmount(reserveVADER()) + reserveUSDV();
            return iUTILS(UTILS()).calcShare(_weight, totalWeight, _adjustedReserve / erasToEarn);          
        }
    }

    //====================================== WITHDRAW ========================================//

    // Members to withdraw
    function withdraw(address synth, uint basisPoints) external returns(uint redeemedAmount) {
        redeemedAmount = _processWithdraw(synth, msg.sender, basisPoints);          // Get amount to withdraw
        sendFunds(synth, msg.sender, redeemedAmount);
    }
    function _processWithdraw(address _synth, address _member, uint _basisPoints) internal returns(uint redeemedAmount) {
        require((block.timestamp - mapMemberSynth_lastTime[_member][_synth]) >= minimumDepositTime, "DepositTime");    // stops attacks
        redeemedAmount = iUTILS(UTILS()).calcPart(_basisPoints, mapMemberSynth_deposit[_member][_synth]); // Share of deposits
        mapMemberSynth_deposit[_member][_synth] -= redeemedAmount;                  // Reduce for member                             
        uint _weight = iUTILS(UTILS()).calcPart(_basisPoints, mapMember_weight[_member]);   // Find recorded weight to reduce
        mapMember_weight[_member] -= _weight;                                   // Reduce for member 
        totalWeight -= _weight;                                                 // Reduce for total
        emit MemberWithdraws(_synth, _member, redeemedAmount, _weight, totalWeight);   // Event
    }

    //============================== ASSETS ================================//

    function getFunds(address synth, uint amount) internal {
        if(tx.origin==msg.sender){
            require(iERC20(synth).transferTo(address(this), amount));
        }else{
            require(iERC20(synth).transferFrom(msg.sender, address(this), amount));
        }
    }
    function sendFunds(address synth, address member, uint amount) internal {
        require(iERC20(synth).transfer(member, amount));
    }

    //============================== HELPERS ================================//

    function reserveUSDV() public view returns(uint) {
        return iERC20(USDV).balanceOf(address(this)); // Balance
    }
    function reserveVADER() public view returns(uint) {
        return iERC20(VADER).balanceOf(address(this)); // Balance
    }

    function getMemberDeposit(address synth, address member) external view returns(uint){
        return mapMemberSynth_deposit[member][synth];
    }
    function getMemberWeight(address member) external view returns(uint){
        return mapMember_weight[member];
    }
    function getMemberLastTime(address synth, address member) external view returns(uint){
        return mapMemberSynth_lastTime[member][synth];
    }

    function DAO() public view returns(address){
        return iVADER(VADER).DAO();
    }
    function UTILS() public view returns(address){
        return iVADER(VADER).UTILS();
    }

}


// File contracts/interfaces/iVETHER.sol

// Original license: SPDX_License_Identifier: UNLICENSED


interface iVETHER {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address, uint) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


// File contracts/Vether.sol

// Original license: SPDX_License_Identifier: UNLICENSED


// Interfaces

// Token Contract
contract Vether is iVETHER {

    // Coin Defaults
    string public override name;                                         // Name of Coin
    string public override symbol;                                       // Symbol of Coin
    uint public override decimals  = 18;                              // Decimals
    uint public override totalSupply  = 1*10**6 * (10 ** decimals);   // 1,000,000 Total

    uint public totalFees;
    mapping(address=>bool) public mapAddress_Excluded;  

    // ERC-20 Mappings
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    
    // Minting event
    constructor() {
        name = "Vether";
        symbol  = "VETH";
        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }
    // iERC20 Transfer function
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // iERC20 Approve, change allowance functions
    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }
    function _approve(address owner, address spender, uint amount) internal virtual {
        require(owner != address(0), "iERC20: approve from the zero address");
        require(spender != address(0), "iERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    // iERC20 TransferFrom function
    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

       // Internal transfer function which includes the Fee
    function _transfer(address _from, address _to, uint _value) private {
        require(_balances[_from] >= _value, 'Must not send more than balance');
        require(_balances[_to] + _value >= _balances[_to], 'Balance overflow');
        _balances[_from] -= _value;
        uint _fee = _getFee(_from, _to, _value);                                            // Get fee amount
        _balances[_to] += (_value - _fee);                                               // Add to receiver
        _balances[address(this)] += _fee;                                                   // Add fee to self
        totalFees += _fee;                                                                  // Track fees collected
        emit Transfer(_from, _to, (_value - _fee));                                      // Transfer event
        if (!mapAddress_Excluded[_from] && !mapAddress_Excluded[_to]) {
            emit Transfer(_from, address(this), _fee);                                      // Fee Transfer event
        }
    }
    
    // Calculate Fee amount
    function _getFee(address _from, address _to, uint _value) private view returns (uint) {
        if (mapAddress_Excluded[_from] || mapAddress_Excluded[_to]) {
           return 0;                                                                        // No fee if excluded
        } else {
            return (_value / 1000);                                                         // Fee amount = 0.1%
        }
    }

    function addExcluded(address excluded) public {
        mapAddress_Excluded[excluded] = true;
    }
}
