// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
// Sources flattened with hardhat v2.8.3 https://hardhat.org

// File contracts/facades/LimboDAOLike.sol


abstract contract LimboDAOLike {
    function approveFlanMintingPower(address minter, bool enabled)
        public
        virtual;

    function makeProposal(address proposal, address proposer) public virtual;

    function currentProposalState() public view virtual returns (uint,uint,address,uint,address);

    function setProposalConfig(
        uint256 votingDuration,
        uint256 requiredFateStake,
        address proposalFactory
    ) public virtual;

    function setApprovedAsset(address asset, bool approved) public virtual;

    function successfulProposal(address proposal)
        public
        view
        virtual
        returns (bool);

    function domainConfig()
        public
        virtual
        returns (
            address,
            address,
            address,
            address,
            bool,
            address,
            address
        );

    function getFlashGoverner() external view virtual returns (address);

    function proposalConfig() public virtual view returns (uint,uint,address);

  function setFateToFlan(uint256 rate) public virtual;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.4.2


// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/facades/FlashGovernanceArbiterLike.sol




abstract contract FlashGovernanceArbiterLike {
    function assertGovernanceApproved(address sender, address target, bool emergency)
        public
        virtual;

    function enforceToleranceInt(int256 v1, int256 v2) public view virtual;

    function enforceTolerance(uint256 v1, uint256 v2) public view virtual;

    function burnFlashGovernanceAsset(
        address targetContract,
        address user,
        address asset,
        uint256 amount
    ) public virtual;

     function setEnforcement(bool enforce) public virtual;
}


// File contracts/facades/ProposalFactoryLike.sol




abstract contract ProposalFactoryLike {
     function toggleWhitelistProposal(address proposal) public virtual;
     function soulUpdateProposal () public  virtual view returns (address); 
}


// File contracts/DAO/Governable.sol







///@title Governable
///@author Justin Goro
/**@dev Contracts that implement this can be governed by LimboDAO.
 * Depending on the importance and context, you can enforce governance oversight with one of two modifiers:
 *       -enforceGovernance will execute if either a proposal passes with a yes vote or if the caller is using flash governance
 *       -onlySuccessfulProposals will only execute if a proposal passes with a yes vote.
 */
abstract contract Governable {
  FlashGovernanceArbiterLike internal flashGoverner;

  bool public configured;
  address public DAO;

  /**@notice during initial setup, requiring strict multiday proposals for calibration would unecessarily delay release. 
    As long as configured is false, the contract has no governance enforcement. Calling endConfiguration is a one way operation 
    to ensure governance mechanisms kicks in. As a user, do not interact with these contracts if configured is false.
    */
  function endConfiguration() public {
    configured = true;
  }

  modifier onlySuccessfulProposal() {
    //modifiers are inline macros so you'd get a lot of code duplication if you don't refactor (EIP-170)
    assertSuccessfulProposal(msg.sender);
    _;
  }

  modifier onlySoulUpdateProposal() {
    assertSoulUpdateProposal(msg.sender);
    _;
  }

  function assertSoulUpdateProposal(address sender) internal view {
    (, , address proposalFactory) = LimboDAOLike(DAO).proposalConfig();
    require(!configured || sender == ProposalFactoryLike(proposalFactory).soulUpdateProposal(), "EJ");
    assertSuccessfulProposal(sender);
  }

  function _governanceApproved(bool emergency) internal {
    bool successfulProposal = LimboDAOLike(DAO).successfulProposal(msg.sender);
    if (successfulProposal) {
      flashGoverner.setEnforcement(false);
    } else if (configured) flashGoverner.assertGovernanceApproved(msg.sender, address(this), emergency);
  }

  modifier governanceApproved(bool emergency) {
    _governanceApproved(emergency);
    _;
    flashGoverner.setEnforcement(true);
  }

  function assertSuccessfulProposal(address sender) internal view {
    require(!configured || LimboDAOLike(DAO).successfulProposal(sender), "EJ");
  }

  constructor(address dao) {
    setDAO(dao);
  }

  ///@param dao The LimboDAO contract address
  function setDAO(address dao) public {
    require(DAO == address(0) || msg.sender == DAO || !configured, "EK");
    DAO = dao;
    flashGoverner = FlashGovernanceArbiterLike(LimboDAOLike(dao).getFlashGoverner());
  }
}


// File @openzeppelin/contracts/utils/Context.sol@v4.4.2


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)


/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.4.2


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/DAO/ProposalFactory.sol






///@title Proposal
///@author Justin Goro
///@notice suggested base contract for proposals on Limbo. Not strictly enforced but strongly recommended
abstract contract Proposal {
  string public description;
  LimboDAOLike DAO;

  constructor(address dao, string memory _description) {
    DAO = LimboDAOLike(dao);
    description = _description;
  }

  modifier onlyDAO() {
    address dao = address(DAO);
    require(dao != address(0), "PROPOSAL: DAO not set");
    require(msg.sender == dao, "PROPOSAL: only DAO can invoke");
    _;
  }

  //Use this modifier on a parameterize funtion. This allows the proposal to lock itself into a readonly state during voting.
  modifier notCurrent() {
    (, , , , address proposal) = DAO.currentProposalState();
    require(proposal != address(this), "LimboDAO: proposal locked");
    _;
  }

  function orchestrateExecute() public onlyDAO {
    require(execute(), "LimboDAO: execution of proposal failed");
  }

  //override this function with all proposal logic. Only instructions included in this function will be executed if the proposal is a success.
  function execute() internal virtual returns (bool);
}

///@title Proposal Factory
///@author Justin Goro
///@notice authenticates and gatekeeps proposals up for vote on LimboDAO.
///@dev constructors are prefered to initializers when an imporant base contract exists.
contract ProposalFactory is Governable, Ownable {
  mapping(address => bool) public whitelistedProposalContracts;
  address public soulUpdateProposal;

  constructor(
    address _dao,
    address whitelistingProposal,
    address _soulUpdateProposal
  ) Governable(_dao) {
    //in order for proposals to be white listed, an initial whitelisting proposal needs to be whitelisted at deployment
    whitelistedProposalContracts[whitelistingProposal] = true;
    whitelistedProposalContracts[_soulUpdateProposal] = true;
    soulUpdateProposal = _soulUpdateProposal;
  }

  ///@notice SoulUpdateProposal is one of the most important proposals and governs the creation of new staking souls.
  ///@dev onlyOwner denotes that this important function is overseen by MorgothDAO.
  ///@param newProposal new update soul
  function changeSoulUpdateProposal(address newProposal) public onlyOwner {
    soulUpdateProposal = newProposal;
  }

  ///@notice there is no formal onchain enforcement of proposal structure and compliance. Proposal contracts must first be white listed for usage
  function toggleWhitelistProposal(address proposal) public onlySuccessfulProposal {
    whitelistedProposalContracts[proposal] = !whitelistedProposalContracts[proposal];
  }

  ///@notice user facing function to vote on a new proposal. Note that the proposal contract must first be whitelisted for usage
  ///@param proposal whitelisted popular contract
  function lodgeProposal(address proposal) public {
    require(whitelistedProposalContracts[proposal], "LimboDAO: invalid proposal");
    LimboDAOLike(DAO).makeProposal(proposal, msg.sender);
  }
}


// File contracts/DAO/Proposals/BurnFlashStakeDeposit.sol





/**
* @author Justin Goro
* @notice Flash governance decisions are accompanied by staked collateral that can be slashed by LimboDAO. This proposal is responsible for slashing
*/
contract BurnFlashStakeDeposit is Proposal {
    struct Parameters {
        address user;
        address asset;
        uint256 amount;
        address flashGoverner;
        address targetContract;
    }

    Parameters public params;

    constructor(address dao, string memory _description)
        Proposal(dao, description)
    {}

    function parameterize(
        address user,
        address asset,
        uint256 amount,
        address flashGoverner,
        address targetContract
    ) public notCurrent {
        params.user = user;
        params.asset = asset;
        params.amount = amount;
        params.flashGoverner = flashGoverner;
        params.targetContract = targetContract;
    }

    function execute() internal override returns (bool) {
        FlashGovernanceArbiterLike(params.flashGoverner)
            .burnFlashGovernanceAsset(
            params.targetContract,
            params.user,
            params.asset,
            params.amount
        );
        return true;
    }
}
