// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

// lib/openzeppelin-contracts/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// src/interfaces/IBaseBlastManager.sol

interface IBaseBlastManager {
    function getConfiguredGovernor() external view returns (address _governor);
}

// src/interfaces/IBlast.sol

enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}

enum GasMode {
    VOID,
    CLAIMABLE
}

interface IBlastPoints {
    function configurePointsOperator(address operator) external;
}

interface IERC20Rebasing {
    function configure(YieldMode) external returns (uint256);

    function claim(
        address recipient,
        uint256 amount
    ) external returns (uint256);

    function getClaimableAmount(
        address account
    ) external view returns (uint256);
}

interface IBlast {
    // configure
    function configureContract(
        address contractAddress,
        YieldMode _yield,
        GasMode gasMode,
        address governor
    ) external;
    function configure(
        YieldMode _yield,
        GasMode gasMode,
        address governor
    ) external;

    // base configuration options
    function configureClaimableYield() external;
    function configureClaimableYieldOnBehalf(address contractAddress) external;
    function configureAutomaticYield() external;
    function configureAutomaticYieldOnBehalf(address contractAddress) external;
    function configureVoidYield() external;
    function configureVoidYieldOnBehalf(address contractAddress) external;
    function configureClaimableGas() external;
    function configureClaimableGasOnBehalf(address contractAddress) external;
    function configureVoidGas() external;
    function configureVoidGasOnBehalf(address contractAddress) external;
    function configureGovernor(address _governor) external;
    function configureGovernorOnBehalf(
        address _newGovernor,
        address contractAddress
    ) external;

    // claim yield
    function claimYield(
        address contractAddress,
        address recipientOfYield,
        uint256 amount
    ) external returns (uint256);
    function claimAllYield(
        address contractAddress,
        address recipientOfYield
    ) external returns (uint256);

    // claim gas
    function claimAllGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256);
    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipientOfGas,
        uint256 minClaimRateBips
    ) external returns (uint256);
    function claimMaxGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256);
    function claimGas(
        address contractAddress,
        address recipientOfGas,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    ) external returns (uint256);

    // read functions
    function readClaimableYield(
        address contractAddress
    ) external view returns (uint256);
    function readYieldConfiguration(
        address contractAddress
    ) external view returns (uint8);
    function readGasParams(
        address contractAddress
    )
        external
        view
        returns (
            uint256 etherSeconds,
            uint256 etherBalance,
            uint256 lastUpdated,
            GasMode
        );
    /**
     * @notice Checks if the caller is authorized
     * @param contractAddress The address of the contract
     * @return A boolean indicating if the caller is authorized
     */
    function isAuthorized(address contractAddress) external view returns (bool);

    function isGovernor(address contractAddress) external view returns (bool);
}

// src/interfaces/IConfigStorage.sol

enum StorageKey {
    Many,
    Paused,
    LockManager,
    AccountManager,
    ClaimManager,
    MigrationManager,
    NFTOverlord,
    SnuggeryManager,
    PrimordialManager,
    MunchadexManager,
    MunchNFT,
    MunchToken,
    RewardsManager,
    YieldDistributor,
    GasFeeDistributor,
    BlastContract,
    BlastPointsContract,
    BlastPointsOperator,
    USDBContract,
    WETHContract,
    RNGProxyContract,
    NFTAttributesManager,
    Treasury,
    OldMunchNFT,
    MaxLockDuration,
    DefaultSnuggerySize,
    MaxRevealQueue,
    MaxSchnibbleSpray,
    PetTotalSchnibbles,
    NewSlotCost,
    PrimordialsEnabled,
    BonusManager,
    ReferralBonus,
    RealmBonuses,
    RarityBonuses,
    LevelThresholds,
    PrimordialLevelThresholds,
    TotalMunchables,
    MunchablesPerRealm,
    MunchablesPerRarity,
    RaritySetBonuses,
    PointsPerPeriod,
    PointsPerToken,
    SwapEnabled,
    PointsPerMigratedNFT,
    PointsPerUnrevealedNFT,
    MinETHPetBonus,
    MaxETHPetBonus,
    PetBonusMultiplier,
    RealmLookups,
    // Species & Probabilities
    CommonSpecies,
    RareSpecies,
    EpicSpecies,
    LegendarySpecies,
    MythicSpecies,
    CommonPercentage,
    RarePercentage,
    EpicPercentage,
    LegendaryPercentage,
    MythicPercentage,
    MigrationBonus,
    MigrationBonusEndTime,
    MigrationDiscountFactor
}

enum Role {
    Admin,
    Social_1,
    Social_2,
    Social_3,
    Social_4,
    Social_5,
    SocialApproval_1,
    SocialApproval_2,
    SocialApproval_3,
    SocialApproval_4,
    SocialApproval_5,
    PriceFeed_1,
    PriceFeed_2,
    PriceFeed_3,
    PriceFeed_4,
    PriceFeed_5,
    Snapshot,
    NewPeriod,
    ClaimYield,
    Minter,
    NFTOracle
}

enum StorageType {
    Uint,
    SmallUintArray,
    UintArray,
    SmallInt,
    SmallIntArray,
    Bool,
    Address,
    AddressArray,
    Bytes32
}

interface IConfigStorage {
    // Manual notify
    function manualNotify(uint8 _index, uint8 _length) external;

    // Manual notify for a specific contract
    function manualNotifyAddress(address _contract) external;

    // Setters
    function setRole(Role _role, address _contract, address _addr) external;

    function setUniversalRole(Role _role, address _addr) external;

    function setUint(StorageKey _key, uint256 _value, bool _notify) external;

    function setUintArray(
        StorageKey _key,
        uint256[] memory _value,
        bool _notify
    ) external;

    function setSmallUintArray(
        StorageKey _key,
        uint8[] calldata _smallUintArray,
        bool _notify
    ) external;

    function setSmallInt(StorageKey _key, int16 _value, bool _notify) external;

    function setSmallIntArray(
        StorageKey _key,
        int16[] memory _value,
        bool _notify
    ) external;

    function setBool(StorageKey _key, bool _value, bool _notify) external;

    function setAddress(StorageKey _key, address _value, bool _notify) external;

    function setAddresses(
        StorageKey[] memory _keys,
        address[] memory _values,
        bool _notify
    ) external;

    function setAddressArray(
        StorageKey _key,
        address[] memory _value,
        bool _notify
    ) external;

    function setBytes32(StorageKey _key, bytes32 _value, bool _notify) external;

    // Getters
    function getRole(Role _role) external view returns (address);

    function getContractRole(
        Role _role,
        address _contract
    ) external view returns (address);

    function getUniversalRole(Role _role) external view returns (address);

    function getUint(StorageKey _key) external view returns (uint256);

    function getUintArray(
        StorageKey _key
    ) external view returns (uint256[] memory);

    function getSmallUintArray(
        StorageKey _key
    ) external view returns (uint8[] memory _smallUintArray);

    function getSmallInt(StorageKey _key) external view returns (int16);

    function getSmallIntArray(
        StorageKey _key
    ) external view returns (int16[] memory);

    function getBool(StorageKey _key) external view returns (bool);

    function getAddress(StorageKey _key) external view returns (address);

    function getAddressArray(
        StorageKey _key
    ) external view returns (address[] memory);

    function getBytes32(StorageKey _key) external view returns (bytes32);

    // Notification Address Management
    function addNotifiableAddress(address _addr) external;

    function addNotifiableAddresses(address[] memory _addresses) external;

    function removeNotifiableAddress(address _addr) external;

    function getNotifiableAddresses()
        external
        view
        returns (address[] memory _addresses);

    error ArrayTooLongError();
}

// src/interfaces/IERC20YieldClaimable.sol

/// @notice Contracts which implement this interface can be instructed by Rewards Manager to claim their yield for
///         ERC20 tokens and send the yield back to the rewards manager
interface IERC20YieldClaimable {
    function claimERC20Yield(address _tokenContract, uint256 _amount) external;
}

// src/interfaces/IHoldsGovernorship.sol

/// @notice Contracts which implement this interface will be the governor for other contracts and
///         give it up on request from the contract
interface IHoldsGovernorship {
    function reassignBlastGovernor(address _newAddress) external;

    function isGovernorOfContract(
        address _contract
    ) external view returns (bool);
}

// src/interfaces/ILockManager.sol

/// @title ILockManager interface
/// @notice Provides an interface for managing token locks, including price updates, lock configurations, and user interactions.
interface ILockManager {
    /// @notice Struct representing a lockdrop event
    /// @param start Unix timestamp for when the lockdrop starts
    /// @param end Unix timestamp for when the lockdrop ends
    /// @param minLockDuration Minimum lock duration allowed when locking a token
    struct Lockdrop {
        uint32 start;
        uint32 end;
        uint32 minLockDuration;
    }

    /// @notice Struct holding details about tokens that can be locked
    /// @param usdPrice USD price per token
    /// @param nftCost Cost of the NFT associated with locking this token
    /// @param decimals Number of decimals for the token
    /// @param active Boolean indicating if the token is currently active for locking
    struct ConfiguredToken {
        uint256 usdPrice;
        uint256 nftCost;
        uint8 decimals;
        bool active;
    }

    /// @notice Struct describing tokens locked by a player
    /// @param quantity Amount of tokens locked
    /// @param remainder Tokens left over after locking, not meeting the full NFT cost
    /// @param lastLockTime The last time tokens were locked
    /// @param unlockTime When the tokens will be unlocked
    struct LockedToken {
        uint256 quantity;
        uint256 remainder;
        uint32 lastLockTime;
        uint32 unlockTime;
    }

    /// @notice Struct to hold locked tokens and their metadata
    /// @param lockedToken LockedToken struct containing lock details
    /// @param tokenContract Address of the token contract
    struct LockedTokenWithMetadata {
        LockedToken lockedToken;
        address tokenContract;
    }

    /// @notice Struct to keep player-specific settings
    /// @param lockDuration Duration in seconds for which tokens are locked
    struct PlayerSettings {
        uint32 lockDuration;
    }

    /// @notice Struct to manage USD price update proposals
    /// @param proposedDate Timestamp when the price was proposed
    /// @param proposer Address of the oracle proposing the new price
    /// @param contracts Array of contracts whose prices are proposed to be updated
    /// @param proposedPrice New proposed price in USD
    struct USDUpdateProposal {
        uint32 proposedDate;
        address proposer;
        address[] contracts;
        uint256 proposedPrice;
        mapping(address => uint32) approvals;
        mapping(address => uint32) disapprovals;
        uint8 approvalsCount;
        uint8 disapprovalsCount;
    }

    /// @notice Configures the start and end times for a lockdrop event
    /// @param _lockdropData Struct containing the start and end times
    function configureLockdrop(Lockdrop calldata _lockdropData) external;

    /// @notice Adds or updates a token configuration for locking purposes
    /// @param _tokenContract The contract address of the token to configure
    /// @param _tokenData The configuration data for the token
    function configureToken(
        address _tokenContract,
        ConfiguredToken memory _tokenData
    ) external;

    /// @notice Sets the thresholds for approving or disapproving USD price updates
    /// @param _approve Number of approvals required to accept a price update
    /// @param _disapprove Number of disapprovals required to reject a price update
    function setUSDThresholds(uint8 _approve, uint8 _disapprove) external;

    /// @notice Proposes a new USD price for one or more tokens
    /// @param _price The new proposed price in USD
    /// @param _contracts Array of token contract addresses to update
    function proposeUSDPrice(
        uint256 _price,
        address[] calldata _contracts
    ) external;

    /// @notice Approves a proposed USD price update
    /// @param _price The price that needs to be approved
    function approveUSDPrice(uint256 _price) external;

    /// @notice Disapproves a proposed USD price update
    /// @param _price The price that needs to be disapproved
    function disapproveUSDPrice(uint256 _price) external;

    /// @notice Sets the lock duration for a player's tokens
    /// @param _duration The lock duration in seconds
    function setLockDuration(uint256 _duration) external;

    /// @notice Locks tokens on behalf of a player
    /// @param _tokenContract Contract address of the token to be locked
    /// @param _quantity Amount of tokens to lock
    /// @param _onBehalfOf Address of the player for whom tokens are being locked
    function lockOnBehalf(
        address _tokenContract,
        uint256 _quantity,
        address _onBehalfOf
    ) external payable;

    /// @notice Locks tokens
    /// @param _tokenContract Contract address of the token to be locked
    /// @param _quantity Amount of tokens to lock
    function lock(address _tokenContract, uint256 _quantity) external payable;

    /// @notice Unlocks the player's tokens
    /// @param _tokenContract Contract address of the token to be unlocked
    /// @param _quantity Amount of tokens to unlock
    function unlock(address _tokenContract, uint256 _quantity) external;

    /// @notice Retrieves locked tokens for a player
    /// @param _player Address of the player
    /// @return _lockedTokens Array of LockedTokenWithMetadata structs for all tokens configured
    function getLocked(
        address _player
    ) external view returns (LockedTokenWithMetadata[] memory _lockedTokens);

    /// @notice Calculates the USD value of all tokens locked by a player, weighted by their yield
    /// @param _player Address of the player
    /// @return _lockedWeightedValue Total weighted USD value of locked tokens
    function getLockedWeightedValue(
        address _player
    ) external view returns (uint256 _lockedWeightedValue);

    /// @notice Retrieves configuration for a token given its contract address
    /// @param _tokenContract The contract address of the token
    /// @return _token Struct containing the token's configuration
    function getConfiguredToken(
        address _tokenContract
    ) external view returns (ConfiguredToken memory _token);

    /// @notice Retrieves lock settings for a player
    /// @param _player Address of the player
    /// @return _settings PlayerSettings struct containing the player's lock settings
    function getPlayerSettings(
        address _player
    ) external view returns (PlayerSettings calldata _settings);

    /// @notice Emitted when a new token is configured
    /// @param _tokenContract The token contract being configured
    /// @param _tokenData ConfiguredToken struct with new config
    event TokenConfigured(address _tokenContract, ConfiguredToken _tokenData);

    /// @notice Emitted when a new lockdrop has been configured
    /// @param _lockdrop_data Lockdrop struct containing the new lockdrop configuration
    event LockDropConfigured(Lockdrop _lockdrop_data);

    /// @notice Emitted when a new USD price has been proposed by one of the oracles
    /// @param _proposer The oracle proposing the new price
    /// @param _price New proposed price, specified in whole dollars
    event ProposedUSDPrice(address _proposer, uint256 _price);

    /// @notice Emitted when a USD price proposal has been approved by the required number of oracles
    /// @param _approver The oracle who approved the new price
    event ApprovedUSDPrice(address _approver);

    /// @notice Emitted when an oracle disapproves of the proposed USD price
    /// @param _disapprover The oracle disapproving of the new price
    event DisapprovedUSDPrice(address _disapprover);

    /// @notice Emitted when a USD price proposal is removed after receiving sufficient disapprovals
    event RemovedUSDProposal();

    /// @notice Emitted when the thresholds for USD oracle approvals and disapprovals are updated
    /// @param _approve New threshold for approvals
    /// @param _disapprove New threshold for disapprovals
    event USDThresholdUpdated(uint8 _approve, uint8 _disapprove);

    /// @notice Emitted when a player updates their lock duration
    /// @param _player The player whose lock duration is updated
    /// @param _duration New lock duration, specified in seconds
    event LockDuration(address indexed _player, uint256 _duration);

    /// @notice Emitted when a player locks tokens
    /// @param _player The player locking the tokens
    /// @param _sender The sender of the lock transaction
    /// @param _tokenContract The contract address of the locked token
    /// @param _quantity The amount of tokens locked
    /// @param _remainder The remainder of tokens left after locking (not reaching an NFT cost)
    /// @param _numberNFTs The number of NFTs the player is entitled to due to the lock
    event Locked(
        address indexed _player,
        address _sender,
        address _tokenContract,
        uint256 _quantity,
        uint256 _remainder,
        uint256 _numberNFTs,
        uint256 _lockDuration
    );

    /// @notice Emitted when a player unlocks tokens
    /// @param _player The player unlocking the tokens
    /// @param _tokenContract The contract address of the unlocked token
    /// @param _quantity The amount of tokens unlocked
    event Unlocked(
        address indexed _player,
        address _tokenContract,
        uint256 _quantity
    );

    /// @notice Emitted when the discount factor for token locking is updated
    /// @param discountFactor The new discount factor
    event DiscountFactorUpdated(uint256 discountFactor);

    /// @notice Emitted when the USD price is updated for a token
    /// @param _tokenContract The token contract updated
    /// @param _newPrice The new USD price
    event USDPriceUpdated(address _tokenContract, uint256 _newPrice);

    /// @notice Error thrown when an action is attempted by an entity other than the Account Manager
    error OnlyAccountManagerError();

    /// @notice Error thrown when an operation is attempted on a token that is not configured
    error TokenNotConfiguredError();

    /// @notice Error thrown when an action is attempted after the lockdrop period has ended
    /// @param end The ending time of the lockdrop period
    /// @param block_timestamp The current block timestamp, indicating the time of the error
    error LockdropEndedError(uint32 end, uint32 block_timestamp);

    /// @notice Error thrown when the lockdrop configuration is invalid
    error LockdropInvalidError();

    /// @notice Error thrown when the NFT cost specified is invalid or not allowed
    error NFTCostInvalidError();

    /// @notice Error thrown when the USD price proposed is deemed invalid
    error USDPriceInvalidError();

    /// @notice Error thrown when there is already a proposal in progress and another cannot be started
    error ProposalInProgressError();

    /// @notice Error thrown when the contracts specified in a proposal are invalid
    error ProposalInvalidContractsError();

    /// @notice Error thrown when there is no active proposal to operate on
    error NoProposalError();

    /// @notice Error thrown when the proposer is not allowed to approve their own proposal
    error ProposerCannotApproveError();

    /// @notice Error thrown when a proposal has already been approved
    error ProposalAlreadyApprovedError();

    /// @notice Error thrown when a proposal has already been disapproved
    error ProposalAlreadyDisapprovedError();

    /// @notice Error thrown when the price specified does not match the price in the active proposal
    error ProposalPriceNotMatchedError();

    /// @notice Error thrown when the lock duration specified exceeds the maximum allowed limit
    error MaximumLockDurationError();

    /// @notice Error thrown when the ETH value provided in a transaction is incorrect for the intended operation
    error ETHValueIncorrectError();

    /// @notice Error thrown when the message value provided in a call is invalid
    error InvalidMessageValueError();

    /// @notice Error thrown when the allowance provided for an operation is insufficient
    error InsufficientAllowanceError();

    /// @notice Error thrown when the amount locked is insufficient for the intended operation
    error InsufficientLockAmountError();

    /// @notice Error thrown when tokens are still locked and cannot be unlocked due to the lock period not expiring
    error TokenStillLockedError();

    /// @notice Error thrown when an invalid call is made to the Lock Manager
    error LockManagerInvalidCallError();

    /// @notice Error thrown when the Lock Manager refuses to accept ETH for a transaction
    error LockManagerRefuseETHError();

    /// @notice Error thrown when an invalid token contract address is provided for an operation
    error InvalidTokenContractError();

    /// @notice Lock duration out of range
    error InvalidLockDurationError();

    /// @notice User tries to reduce the unlock time
    error LockDurationReducedError();

    /// @notice If a sub account tries to lock tokens
    error SubAccountCannotLockError();

    /// @notice Account not registered with AccountManager
    error AccountNotRegisteredError();

    /// @notice If the player tries to lock too many tokens resulting in too many NFTs being minted
    error TooManyNFTsError();
}

// src/libraries/MunchablesCommonLib.sol

library MunchablesCommonLib {
    enum Rarity {
        Primordial,
        Common,
        Rare,
        Epic,
        Legendary,
        Mythic,
        Invalid
    }

    enum Realm {
        Everfrost,
        Drench,
        Moltania,
        Arridia,
        Verdentis,
        Invalid
    }

    struct NFTImmutableAttributes {
        Rarity rarity;
        uint16 species;
        Realm realm;
        uint8 generation;
        uint32 hatchedDate;
    }

    struct NFTAttributes {
        uint256 chonks;
        uint16 level;
        uint16 evolution;
        uint256 lastPettedTime;
    }

    struct NFTGameAttribute {
        GameAttributeType dataType;
        bytes value;
    }

    struct Munchadex {
        mapping(Realm => uint256) numInRealm;
        mapping(Rarity => uint256) numInRarity;
        mapping(bytes32 => uint256) unique;
        uint256 numUnique;
    }

    enum GameAttributeIndex {
        Strength,
        Agility,
        Stamina,
        Defence,
        Voracity,
        Cuteness,
        Charisma,
        Trustworthiness,
        Leadership,
        Empathy,
        Intelligence,
        Cunning,
        Creativity,
        Adaptability,
        Wisdom,
        IsOriginal,
        IndexCount // Do not use and keep at the end to detect number of indexes
    }

    enum GameAttributeType {
        NotSet,
        Bool,
        String,
        SmallInt,
        BigUInt,
        Bytes
    }

    struct PrimordialData {
        uint256 chonks;
        uint32 createdDate;
        int8 level;
        bool hatched;
    }

    struct SnuggeryNFT {
        uint256 tokenId;
        uint32 importedDate;
    }

    struct NFTFull {
        uint256 tokenId;
        NFTImmutableAttributes immutableAttributes;
        NFTAttributes attributes;
        NFTGameAttribute[] gameAttributes;
    }

    struct Player {
        uint32 registrationDate;
        uint32 lastPetMunchable;
        uint32 lastHarvestDate;
        Realm snuggeryRealm;
        uint16 maxSnuggerySize;
        uint256 unfedSchnibbles;
        address referrer;
    }

    // Pure Functions

    /// @notice Error when insufficient random data is provided for operations
    error NotEnoughRandomError();

    function calculateRaritySpeciesPercentage(
        bytes memory randomBytes
    ) internal pure returns (uint32, uint32) {
        if (randomBytes.length < 5) revert NotEnoughRandomError();

        uint32 rarityBytes;
        uint8 speciesByte;
        uint32 rarityPercentage;
        uint32 speciesPercent;

        rarityBytes =
            (uint32(uint8(randomBytes[0])) << 24) |
            (uint32(uint8(randomBytes[1])) << 16) |
            (uint32(uint8(randomBytes[2])) << 8) |
            uint32(uint8(randomBytes[3]));
        speciesByte = uint8(randomBytes[4]);

        uint256 rarityPercentageTmp = (uint256(rarityBytes) * 1e6) /
            uint256(4294967295);
        uint256 speciesPercentTmp = (uint256(speciesByte) * 1e6) / uint256(255);
        rarityPercentage = uint32(rarityPercentageTmp);
        speciesPercent = uint32(speciesPercentTmp);

        return (rarityPercentage, speciesPercent);
    }

    function getLevelThresholds(
        uint256[] memory levelThresholds,
        uint256 _chonk
    )
        internal
        pure
        returns (uint16 _currentLevel, uint256 _currentLevelThreshold)
    {
        if (_chonk >= levelThresholds[99]) {
            return (101, levelThresholds[99]);
        }
        if (_chonk < levelThresholds[0]) {
            return (1, 0);
        }

        uint256 low = 0;
        uint256 high = levelThresholds.length;
        uint256 mid = 0;
        uint16 answer = 0;

        while (low < high) {
            mid = (low + high) / 2;
            if (levelThresholds[mid] <= _chonk) {
                low = mid + 1;
            } else {
                answer = uint16(mid);
                high = mid;
            }
        }

        _currentLevel = answer + 1;
        _currentLevelThreshold = levelThresholds[uint256(answer - 1)];
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// src/config/BaseConfigStorage.sol

abstract contract BaseConfigStorage {
    IConfigStorage public configStorage;
    bool _paused;

    modifier onlyConfigStorage() {
        if (msg.sender != address(configStorage)) revert OnlyStorageError();
        _;
    }

    modifier onlyConfiguredContract(StorageKey _key) {
        address configuredContract = configStorage.getAddress(_key);
        if (configuredContract == address(0)) revert UnconfiguredError(_key);
        if (configuredContract != msg.sender) revert UnauthorisedError();
        _;
    }

    modifier onlyConfiguredContract2(StorageKey _key, StorageKey _key2) {
        address configuredContract = configStorage.getAddress(_key);
        address configuredContract2 = configStorage.getAddress(_key2);
        if (
            configuredContract != msg.sender &&
            configuredContract2 != msg.sender
        ) {
            if (configuredContract == address(0))
                revert UnconfiguredError(_key);
            if (configuredContract2 == address(0))
                revert UnconfiguredError(_key2);

            revert UnauthorisedError();
        }
        _;
    }
    modifier onlyOneOfRoles(Role[5] memory roles) {
        for (uint256 i = 0; i < roles.length; i++) {
            if (msg.sender == configStorage.getRole(roles[i])) {
                _;
                return;
            }
        }
        revert InvalidRoleError();
    }

    modifier onlyRole(Role role) {
        if (msg.sender != configStorage.getRole(role))
            revert InvalidRoleError();
        _;
    }

    modifier onlyUniversalRole(Role role) {
        if (msg.sender != configStorage.getUniversalRole(role))
            revert InvalidRoleError();
        _;
    }

    modifier onlyAdmin() {
        if (msg.sender != configStorage.getUniversalRole(Role.Admin))
            revert InvalidRoleError();
        _;
    }

    modifier notPaused() {
        if (_paused) revert ContractsPausedError();
        _;
    }

    error UnconfiguredError(StorageKey _key);
    error UnauthorisedError();
    error OnlyStorageError();
    error InvalidRoleError();
    error ContractsPausedError();

    function configUpdated() external virtual;

    function __BaseConfigStorage_setConfigStorage(
        address _configStorage
    ) internal {
        configStorage = IConfigStorage(_configStorage);
    }

    function __BaseConfigStorage_reconfigure() internal {
        _paused = configStorage.getBool(StorageKey.Paused);
    }
}

// src/interfaces/IAccountManager.sol

/// @title Interface for the Account Manager
/// @notice This interface manages player accounts including their snuggery, schibbles, chonks, and sub-accounts
interface IAccountManager {
    /// @notice Struct representing a "Squirt", which is a distribution of schnibbles to a player
    struct Squirt {
        address player; // The address of the player receiving schnibbles
        uint256 schnibbles; // The amount of schnibbles being distributed to that player
    }

    /// @notice Struct representing a proposal to spray schnibbles across multiple accounts
    struct SprayProposal {
        uint32 proposedDate; // The date the proposal was made
        Squirt[] squirts; // Array of "Squirt" structs detailing the distribution
    }

    /// @notice Register a new account, create a new Player record, and set snuggery and referrer
    /// @dev This should be the first function called when onboarding a new user
    /// @param _snuggeryRealm The realm of the new snuggery, which cannot be changed later
    /// @param _referrer The account referring this user, use the null address if there is no referrer
    /// @custom:frontend Register a new account
    function register(
        MunchablesCommonLib.Realm _snuggeryRealm,
        address _referrer
    ) external;

    /// @notice Calculate schnibbles to distribute and credit to unfedSchnibbles, set lastHarvestDate
    /// @custom:frontend Harvest schnibbles
    function harvest() external returns (uint256 _harvested);

    /// @notice Used when a user adds to their lock to force claim at the previous locked value
    /// @param _player Address of the player whose harvest to force
    function forceHarvest(address _player) external;

    /// @notice Propose a spray of schnibbles to multiple accounts
    /// @param _players Array of player addresses
    /// @param _schnibbles Array of schnibbles amounts corresponding to each player
    function spraySchnibblesPropose(
        address[] calldata _players,
        uint256[] calldata _schnibbles
    ) external;

    /// @notice Approve a proposed spray of schnibbles
    /// @param _proposer Address of the proposer of the spray
    function execSprayProposal(address _proposer) external;

    /// @notice Remove a proposed spray of schnibbles
    /// @param _proposer Address of the proposer of the spray to remove
    function removeSprayProposal(address _proposer) external;

    /// @notice Add a sub-account for a player
    /// @param _subAccount The sub-account to add
    /// @custom:frontend Use to add a new sub-account
    function addSubAccount(address _subAccount) external;

    /// @notice Remove a previously added sub-account
    /// @param _subAccount The sub-account to remove
    /// @custom:frontend Use to remove an existing sub-account
    function removeSubAccount(address _subAccount) external;

    /// @notice Restricted to the Munchable Manager only
    function updatePlayer(
        address _account,
        MunchablesCommonLib.Player memory _player
    ) external;

    /// @notice Look up the main account associated with a potentially sub-account
    /// @param _maybeSubAccount Account to check
    /// @return _mainAccount Main account associated, or the input if not a sub-account
    function getMainAccount(
        address _maybeSubAccount
    ) external view returns (address _mainAccount);

    /// @notice Get a list of sub-accounts associated with a main account
    /// @param _player Main account to check
    /// @param _start Index to start pagination
    /// @return _subAccounts List of sub-accounts
    /// @return _more Whether there are more sub-accounts beyond the returned list
    /// @custom:frontend Use this to populate a UI for managing sub accounts
    function getSubAccounts(
        address _player,
        uint256 _start
    ) external view returns (address[20] memory _subAccounts, bool _more);

    /// @notice Retrieve player data for a given account
    /// @param _account Account to retrieve data for
    /// @return _mainAccount Main account associated, or the input if not a sub-account
    /// @return _player Player data structure
    /// @custom:frontend Call this straight after log in to get the data about this player.  The account
    ///                  logging in may be a sub account and in this case the _mainAccount parameter
    ///                  will be different from the logged in user.  In this case the UI should show only
    ///                  functions available to a sub-account
    function getPlayer(
        address _account
    )
        external
        view
        returns (
            address _mainAccount,
            MunchablesCommonLib.Player memory _player
        );

    /// @notice Retrieve detailed player and snuggery data
    /// @param _account Address of the player
    /// @return _mainAccount Main account associated
    /// @return _player Player data
    /// @return _snuggery List of snuggery NFTs
    /// @return _snuggerySize Number of NFTs in the snuggery
    /// @custom:frontend Use this to fetch player and snuggery data
    function getFullPlayerData(
        address _account
    )
        external
        view
        returns (
            address _mainAccount,
            MunchablesCommonLib.Player memory _player,
            MunchablesCommonLib.SnuggeryNFT[] memory _snuggery,
            uint256 _snuggerySize
        );

    /// @notice Get daily schnibbles that an account is accrueing
    /// @param _player The address of the player
    function getDailySchnibbles(
        address _player
    ) external view returns (uint256 _dailySchnibbles, uint256 _bonus);

    /// @notice Emitted when a player registers for a new account
    /// @param _player The address of the player who registered
    /// @param _snuggeryRealm The realm associated with the new snuggery chosen by the player
    /// @param _referrer The address of the referrer, if any; otherwise, the zero address
    /// @custom:frontend You should only receive this event once and only if you are onboarding a new user
    ///                  safe to ignore if you are in the onboarding process
    event PlayerRegistered(
        address indexed _player,
        MunchablesCommonLib.Realm _snuggeryRealm,
        address _referrer
    );

    /// @notice Emitted when a player's schnibbles are harvested
    /// @param _player The address of the player who harvested schnibbles
    /// @param _harvestedSchnibbles The total amount of schnibbles that were harvested
    /// @custom:frontend Listen for events where _player is your mainAccount and update unfedSchnibbles total
    event Harvested(address indexed _player, uint256 _harvestedSchnibbles);

    /// @notice Emitted when a sub-account is added to a player's account
    /// @param _player The address of the main account to which a sub-account was added
    /// @param _subAccount The address of the sub-account that was added
    /// @custom:frontend If you are managing sub accounts (ie the logged in user is not a subAccount), then use this
    ///                  event to reload your cache of sub accounts
    event SubAccountAdded(address indexed _player, address _subAccount);

    /// @notice Emitted when a sub-account is removed from a player's account
    /// @param _player The address of the main account from which a sub-account was removed
    /// @param _subAccount The address of the sub-account that was removed
    /// @custom:frontend If you are managing sub accounts (ie the logged in user is not a subAccount), then use this
    ///                  event to reload your cache of sub accounts
    event SubAccountRemoved(address indexed _player, address _subAccount);

    /// @notice Emitted when a proposal to spray schnibbles is made
    /// @param _proposer The address of the player who proposed the spray
    /// @param _squirts An array of "Squirt" details defining the proposed schnibble distribution
    /// @custom:admin
    event ProposedScnibblesSpray(address indexed _proposer, Squirt[] _squirts);

    // Errors

    /// @notice Error thrown when a player is already registered and attempts to register again
    error PlayerAlreadyRegisteredError();

    /// @notice Error thrown when an action is attempted that requires the player to be registered, but they are not
    error PlayerNotRegisteredError();

    /// @notice Error thrown when the main account of a player is not registered
    error MainAccountNotRegisteredError(address _mainAccount);

    /// @notice Error thrown when there are no pending reveals for a player
    error NoPendingRevealError();

    /// @notice Error thrown when a sub-account is already registered and an attempt is made to register it again
    error SubAccountAlreadyRegisteredError();

    /// @notice Error thrown when a sub-account attempts to register as a main account
    error SubAccountCannotRegisterError();

    /// @notice Error thrown when a spray proposal already exists and another one is attempted
    error ExistingProposalError();

    /// @notice Error thrown when the parameters provided to a function do not match in quantity or type
    error UnMatchedParametersError();

    /// @notice Error thrown when too many entries are attempted to be processed at once
    error TooManyEntriesError();

    /// @notice Error thrown when an expected parameter is empty
    error EmptyParameterError();

    /// @notice Error thrown when a realm is invalid
    error InvalidRealmError();

    /// @notice Error thrown when a sub-account is not registered and is tried to be removed
    error SubAccountNotRegisteredError();

    /// @notice Error thrown when a proposal is attempted to be executed, but none exists
    error EmptyProposalError();

    /// @notice Error thrown when a player attempts to refer themselves
    error SelfReferralError();

    /// @notice Error thrown when the same sprayer gets added twice in a proposal
    error DuplicateSprayerError();

    /// @notice When a user tries to create too many sub accounts (currently 5 max)
    error TooManySubAccountsError();
}

// src/interfaces/IConfigNotifiable.sol

interface IConfigNotifiable {
    function configUpdated() external;
}

// src/interfaces/IMigrationManager.sol

interface IOldNFT {
    // This function needs to be added when upgrading the old NFT contract
    function burn(uint256 _tokenId) external;
}

/// @title Interface for Migration Manager
/// @notice Handles the migration of NFTs with specific attributes and immutable attributes
interface IMigrationManager {
    enum UserLockedChoice {
        NONE,
        LOCKED_FULL_MIGRATION,
        LOCKED_BURN
    }

    /// @dev Struct to hold data during migration
    /// @param tokenId The ID of the token being migrated
    /// @param lockAmount Amount of tokens to lock during migration
    /// @param lockDuration Duration for which tokens will be locked
    /// @param tokenType Type of the token
    /// @param attributes Attributes of the NFT
    /// @param immutableAttributes Immutable attributes of the NFT
    /// @param claimed Status of the NFT claim
    struct MigrationSnapshotData {
        uint256 tokenId;
        uint256 lockAmount;
        address token;
        MunchablesCommonLib.NFTAttributes attributes;
        MunchablesCommonLib.NFTImmutableAttributes immutableAttributes;
        MunchablesCommonLib.NFTGameAttribute[] gameAttributes;
        bool claimed;
    }

    struct MigrationTotals {
        uint256 totalPurchasedAmount;
        uint256 totalLockedAmount;
        address tokenLocked;
    }

    /// @notice Load the migration snapshot for a batch of users
    /// @dev This function sets up migration data for users
    /// @param users Array of user addresses
    /// @param data Array of migration data corresponding to each user
    function loadMigrationSnapshot(
        address[] calldata users,
        MigrationSnapshotData[] calldata data
    ) external;

    /// @notice Load the unrevealed snapshot for a batch of users
    /// @dev This function sets up unrevealed data for users
    /// @param users Array of user addresses
    /// @param unrevealed Array of number of unrevealed for each user
    function loadUnrevealedSnapshot(
        address[] calldata users,
        uint16[] calldata unrevealed
    ) external;

    /// @notice Seals migration data loading
    function sealData() external; // onlyRole(DEFAULT_ADMIN_ROLE)

    /// @notice Burns NFTs
    /// @dev This function handles multiple NFT burn process
    function burnNFTs(address _user, uint32 _skip) external;

    /// @notice Burns remaining purchased NFTs
    /// @dev This function handles burning all remaining purchased NFTs
    function burnRemainingPurchasedNFTs(address _user, uint32 _skip) external;

    /// @notice Lock funds for migration
    /// @dev This function handles locking funds and changing state to migrate
    function lockFundsForAllMigration() external payable;

    /// @notice Migrates all NFTs to the new version
    /// @dev This function handles multiple NFT migration processes. They need to lock funds first before migrating.
    function migrateAllNFTs(address _user, uint32 _skip) external;

    /// @notice Migrates purchased NFTs to the new version
    /// @dev This function handles multiple NFT migration processes
    function migratePurchasedNFTs(uint256[] memory tokenIds) external payable;

    /// @notice Burn unrevealed NFTs for points
    function burnUnrevealedForPoints() external;

    /// @notice Gets the migration data for a user and token ID
    /// @param _user The user address
    /// @param _tokenId The token ID
    function getUserMigrationData(
        address _user,
        uint256 _tokenId
    ) external view returns (MigrationSnapshotData memory);

    /// @notice Gets the overall migration data for a user
    /// @param _user The user address
    function getUserMigrationCompletedData(
        address _user
    ) external view returns (bool, MigrationTotals memory);

    /// @notice Gets the total number of NFTs owned by a user
    /// @param _user The user address
    function getUserNFTsLength(address _user) external view returns (uint256);

    /// @notice Emitted when the migration snapshot is loaded
    /// @param users The array of user addresses involved in the migration
    /// @param data The migration data corresponding to each user
    event MigrationSnapshotLoaded(
        address[] users,
        MigrationSnapshotData[] data
    );

    /// @notice Emitted when unreveal data is loaded
    /// @param users The accounts
    /// @param unrevealed Number of unrevealed NFTs
    event UnrevealedSnapshotLoaded(address[] users, uint16[] unrevealed);

    /// @notice Emitted when an NFT migration is successful
    /// @param user The user who owns the NFTs
    /// @param _oldTokenIds The token IDs of the old NFTs
    /// @param _newTokenIds The token IDs of the new NFTs
    event MigrationSucceeded(
        address user,
        uint256[] _oldTokenIds,
        uint256[] _newTokenIds
    );

    /// @notice Emitted when an NFT burn is successful
    /// @param user The user who owns the NFTs
    /// @param _oldTokenIds The token IDs of the old NFTs
    event BurnSucceeded(address user, uint256[] _oldTokenIds);

    /// @notice Emitted when an NFT burn is successful
    /// @param user The user who owns the NFTs
    /// @param _oldTokenIds The token IDs of the old NFTs
    event BurnPurchasedSucceeded(address user, uint256[] _oldTokenIds);

    /// @notice Emitted after a player swaps unrevealed NFTs for points
    /// @param user The account that swapped the unrevealed NFTS
    /// @param amountSwapped The amount of unrevealed NFTs which will be swapped for points
    event UnrevealedSwapSucceeded(address user, uint256 amountSwapped);

    /// @notice Emitted when the migration data is sealed
    event MigrationDataSealed();

    /// @notice Emitted when a user locks their funds for a full migration
    event LockedForMigration(address user, uint256 amount, address token);

    error NotBoughtNFTError();
    error NFTPurchasedContractError();
    error UnrevealedNFTError();
    error NoMigrationExistsError();
    error InvalidMigrationOwnerError(address _owner, address _sender);
    error InvalidMigrationAmountError();
    error InvalidMigrationTokenError();
    error AllowanceTooLowError();
    error MigrationDataSealedError();
    error MigrationDataNotSealedError();
    error NoUnrevealedError();
    error NoNFTsToBurnError();
    error InvalidDataLengthError();
    error DataAlreadyLoadedError();
    error DifferentLockActionError();
    error SelfNeedsToChooseError();
    error InvalidSkipAmountError();
    error InvalidMigrationTokenIdError();
}

// src/interfaces/INFTOverlord.sol

/// @title Interface for the NFT Overlord
/// @notice This interface manages NFT minting and level up functions which rely on the RNGProxy.  The implementation
///         contract will also handle notification from the LockManager contract when a player has earned
interface INFTOverlord {
    /// @notice Stored between level up requests for a specific token id
    struct LevelUpRequest {
        address owner;
        uint16 fromLevel;
        uint16 toLevel;
    }

    /// @notice Struct to define mint probabilities based on percentage and species array
    struct MintProbability {
        uint32 percentage; // Probability percentage
        uint8[] species; // Array of species IDs that can be minted under this probability
    }

    /// @notice Deduct one from Player.unrevealedNFTs and add one to AccountManager.revealQueue
    /// @custom:frontend Use to reveal an NFT, listen for the events to see when it was minted
    function startReveal() external;

    /// @notice Add to Player.unrevealedNFTs, function only callable by lock manager
    /// @param _player Address of the player
    /// @param _quantity Quantity of reveals to add
    function addReveal(address _player, uint16 _quantity) external;

    /// @notice Reveals an NFT based on provided player ID and signature, decrementing the reveal queue
    /// @param _player The player ID for whom the NFT will be revealed
    /// @param _signature The signature to validate the reveal process
    /// @return _tokenId The ID of the minted NFT
    /// @dev This function should be called after RNG process
    function reveal(
        uint256 _player,
        bytes memory _signature
    ) external returns (uint256 _tokenId);

    /// @notice Called by PrimordialManager when a primordial has reached level 0 and can be hatched into a Munchable
    /// @param _player The player address
    function mintFromPrimordial(address _player) external; // only PrimordialManager

    /// @notice Reveals an NFT based on provided player ID and signature, this is from a primordial hatching
    /// @param _player The player ID  whom the NFT will be revealed
    /// @param _signature The signature to validate the reveal process
    /// @return _tokenId The ID of the minted NFT
    /// @dev This function should be called after RNG process
    function revealFromPrimordial(
        uint256 _player,
        bytes memory _signature
    ) external returns (uint256 _tokenId);

    /// @notice Mints an NFT for migration from V1 to V2, preserving attributes
    /// @param _player The address of the player receiving the NFT
    /// @param _attributes The dynamic attributes of the NFT
    /// @param _immutableAttributes The immutable attributes of the NFT
    /// @param _gameAttributes The game attributes of the NFT
    /// @return _tokenId The token ID of the newly minted NFT
    /// @dev Only callable by the migration manager
    function mintForMigration(
        address _player,
        MunchablesCommonLib.NFTAttributes memory _attributes,
        MunchablesCommonLib.NFTImmutableAttributes memory _immutableAttributes,
        MunchablesCommonLib.NFTGameAttribute[] memory _gameAttributes
    ) external returns (uint256 _tokenId);

    /// @notice Called post-level-up to randomly adjust game attributes based on transaction hash and signature
    /// @param _tokenId The ID of the NFT being leveled up
    /// @param _rng Random bytes from the RNGProxy
    /// @dev Only can be called by the RNGProxy
    function levelUp(uint256 _tokenId, bytes memory _rng) external;

    /// @notice Called by SnuggeryManager when a player feeds a Munchable, it will check if level up is needed and
    ///         request randomness to update game attributes
    /// @param _tokenId The token ID which was fed
    /// @param _owner The eventual owner of the NFT at the time of the level up
    function munchableFed(uint256 _tokenId, address _owner) external; // onlySnuggeryManager

    /// @notice Get a player's unrevealed NFTs
    /// @param _player The player to query, if a sub account is provided the main account unrevealedNFTs will be returned
    function getUnrevealedNFTs(
        address _player
    ) external view returns (uint16 _unrevealed);

    /// @notice Get the current level and the next level threshold for a NFT given its schnibbles count
    /// @param _chonks Quantity of schnibbles
    /// @return _currentLevel Current level of the NFT
    /// @return _nextLevelThreshold Schnibbles threshold for the next level
    function getLevelUpData(
        uint256 _chonks
    ) external view returns (uint16 _currentLevel, uint256 _nextLevelThreshold);

    /// @notice Emitted when a player requests to reveal a munchable
    /// @param _player The address of the player who initiated the reveal
    event MunchableRevealRequested(address indexed _player);

    /// @notice Emitted when a munchable levels up and requires an update to its attributes by an off-chain process
    /// @param _player The address of the player whose munchable is leveling up
    /// @param _tokenId The token ID of the munchable leveling up
    /// @param _levelFrom The current level of the munchable
    /// @param _levelTo The new level that the munchable should be updated to
    event MunchableLevelUpRequest(
        address indexed _player,
        uint256 _tokenId,
        uint16 _levelFrom,
        uint16 _levelTo
    );

    /// @notice Event emitted when an NFT is revealed
    event Revealed(
        address indexed _owner,
        uint256 _tokenId,
        MunchablesCommonLib.NFTImmutableAttributes _immutableAttributes
    );

    /// @notice Event emitted when an NFT is leveled up
    event LevelledUp(
        address _owner,
        uint256 _tokenId,
        uint16 _fromLevel,
        uint16 _toLevel
    );

    /// @notice Emitted when a primordial is hatched into a munchable
    event PrimordialHatched(
        address indexed _player,
        MunchablesCommonLib.NFTImmutableAttributes _immutableAttributes
    );

    /// @notice Event emitted when an NFT is minted for migration
    event MintedForMigration(
        address _player,
        uint256 indexed _tokenId,
        MunchablesCommonLib.NFTImmutableAttributes _immutableAttributes,
        MunchablesCommonLib.NFTAttributes _attributes
    );

    /// @notice Error thrown when there are no unrevealed munchables available for a player
    error NoUnrevealedMunchablesError();

    /// @notice Error thrown when a player's reveal queue is full and cannot handle more reveals
    error RevealQueueFullError();

    /// @notice Error thrown when a player's reveal queue is empty and there is nothing to reveal
    error RevealQueueEmptyError();

    /// @notice Error when a level up request either doesn't exist or the fromLevel is invalid
    error InvalidLevelUpRequest();

    /// @notice Error when no species is found for a given rarity during NFT creation
    /// @param _rarity The rarity level that failed to produce a species
    error NoSpeciesFoundError(MunchablesCommonLib.Rarity _rarity);

    /// @notice Error if reveal cannot find species in realmLookup
    /// @param _speciesId The species that failed
    error NoRealmFoundError(uint16 _speciesId);

    /// @notice Error thrown when a player attempts to claim a primordial while not being eligible
    error PrimordialNotEligibleError();

    /// @notice Error thrown when an action is attempted that requires the player to be registered, but they are not
    error PlayerNotRegisteredError();
}

// src/interfaces/ISnuggeryManager.sol

/// @title Interface for the Account Manager
/// @notice This interface manages player accounts including their snuggery, schibbles, chonks, and sub-accounts
interface ISnuggeryManager {
    /// @notice Imports a munchable to the player's snuggery
    /// @dev Check that the NFT is approved to transfer by this contract
    /// @param _tokenId The token ID to import
    /// @custom:frontend Import a munchable
    function importMunchable(uint256 _tokenId) external;

    /// @notice Exports a munchable from the player's snuggery, the munchable will be returned directly
    /// @param _tokenId The token ID to export
    /// @custom:frontend Export a munchable
    function exportMunchable(uint256 _tokenId) external;

    /// @notice Feed a munchable to increase its chonks, chonks will be schnibbles multiplied by any feed bonus
    /// @param _tokenId Token ID of the munchable to feed
    /// @param _schnibbles Amount of schnibbles to feed
    /// @custom:frontend Feed a munchable, use event data to show how much chonk was added
    function feed(uint256 _tokenId, uint256 _schnibbles) external;

    /// @notice Increase the number of slots in a player's snuggery
    /// @param _quantity Quantity to increase the snuggery size by
    function increaseSnuggerySize(uint8 _quantity) external;

    /// @notice Pet another player's munchable to give both petter and petted some schnibbles
    /// @param _pettedOwner The owner of the token being petted (the token must be in that player's snuggery)
    /// @param _tokenId Token ID of the munchable to pet
    /// @custom:frontend Pet another user's munchable.  Check last pet and petted times to see if this function
    ///                  should be available
    function pet(address _pettedOwner, uint256 _tokenId) external;

    /// @notice Retrieve the total schnibbles count for a player's snuggery
    /// @param _player Address of the player
    /// @return _totalChonk Total schnibbles count
    function getTotalChonk(
        address _player
    ) external view returns (uint256 _totalChonk);

    /// @notice Retrieve the global total schnibbles count across all snuggeries
    function getGlobalTotalChonk()
        external
        view
        returns (uint256 _totalGlobalChonk);

    /// @notice Gets a snuggery (array of SnuggeryNFT)
    /// @param _player Address of the player to get snuggery for
    /// @param _start Starting index for larger snuggeries
    /// @return _snuggery Array of SnuggeryNFT items
    /// @return _snuggerySize Unfiltered size of the snuggery
    function getSnuggery(
        address _player,
        uint256 _start
    )
        external
        view
        returns (
            MunchablesCommonLib.SnuggeryNFT[] memory _snuggery,
            uint256 _snuggerySize
        );

    /// @notice Emitted when a munchable is imported into a player's snuggery
    /// @param _player The address of the player who imported the munchable
    /// @param _tokenId The token ID of the munchable that was imported
    /// @custom:frontend Listen for events for the mainAccount, when it is received update your snuggery data
    event MunchableImported(address indexed _player, uint256 _tokenId);

    /// @notice Emitted when a munchable is exported from a player's snuggery
    /// @param _player The address of the player who exported the munchable
    /// @param _tokenId The token ID of the munchable that was exported
    /// @custom:frontend Listen for events for the mainAccount, when it is received update your snuggery data
    event MunchableExported(address indexed _player, uint256 _tokenId);

    /// @notice Emitted when a munchable is fed schnibbles
    /// @param _player The address of the player who fed the munchable
    /// @param _tokenId The token ID of the munchable that was fed
    /// @param _baseChonks The base amount of chonks that were gained by feeding, will be equal to the schnibbles fed
    /// @param _bonusChonks The additional bonus chonks that were awarded during the feeding
    /// @custom:frontend Listen for events for your mainAccount and when this is received update the particular token
    ///                  in the snuggery by reloading the NFT data
    event MunchableFed(
        address indexed _player,
        uint256 _tokenId,
        uint256 _baseChonks,
        int256 _bonusChonks
    );

    /// @notice Emitted when a munchable is petted, distributing schnibbles to both the petter and the petted
    /// @param _petter The address of the player who petted the munchable
    /// @param _petted The address of the player who owns the petted munchable
    /// @param _tokenId The token ID of the munchable that was petted
    /// @param _petterSchnibbles The amount of schnibbles awarded to the petter
    /// @param _pettedSchnibbles The amount of schnibbles awarded to the owner of the petted munchable
    /// @custom:frontend Listen for events where your mainAccount petted and where it was pet
    ///                  - If your mainAccount was petted, update the unfedMunchables total
    ///                  - If your account was petted then, update the unfedMunchables total, also optionally load the
    ///                    lastPetTime for the munchable if you use that
    event MunchablePetted(
        address indexed _petter,
        address indexed _petted,
        uint256 _tokenId,
        uint256 _petterSchnibbles,
        uint256 _pettedSchnibbles
    );

    /// @notice Event emitted when a snuggery size is increased
    event SnuggerySizeIncreased(
        address _player,
        uint16 _previousSize,
        uint16 _newSize
    );

    /// @notice Error thrown when a token ID is not found in the snuggery
    error TokenNotFoundInSnuggeryError();

    /// @notice Error thrown when a player's snuggery is already full and cannot accept more munchables
    error SnuggeryFullError();

    /// @notice Someone tries to import a munchable they do not own
    error IncorrectOwnerError();

    /// @notice Error if user tries to import someone else's NFT
    error InvalidOwnerError();

    /// @notice Error thrown when an action is attempted that requires the player to be registered, but they are not
    error PlayerNotRegisteredError();

    /// @notice Error thrown when a munchable is not found in a player's snuggery
    error MunchableNotInSnuggeryError();

    /// @notice Error thrown when a player attempts to pet their own munchable
    error CannotPetOwnError();

    /// @notice Error thrown when a munchable is petted too soon after the last petting
    error PettedTooSoonError();

    /// @notice Error thrown when a player attempts to pet too soon after their last petting action
    error PetTooSoonError();

    /// @notice Error thrown when a player tries to feed a munchable but does not have enough schnibbles
    /// @param _currentUnfedSchnibbles The current amount of unfed schnibbles available to the player
    error InsufficientSchnibblesError(uint256 _currentUnfedSchnibbles);

    /// @notice Error thrown when a player attempts swap a primordial but they dont have one
    error NoPrimordialInSnuggeryError();

    /// @notice Invalid token id passed (normally if 0)
    error InvalidTokenIDError();

    /// @notice Contract is not approved to transfer NFT on behalf of user
    error NotApprovedError();

    /// @notice Something not configured
    error NotConfiguredError();

    /// @notice This is thrown by the claim manager but we need it here to decode selector
    error NotEnoughPointsError();

    /// @notice When petting the user petting must supply the main account being petted
    error PettedIsSubAccount();
}

// lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// src/managers/BaseBlastManager.sol

abstract contract BaseBlastManager is
    IBaseBlastManager,
    IERC20YieldClaimable,
    BaseConfigStorage
{
    IBlast public blastContract;
    IBlastPoints public blastPointsContract;

    address private _governorConfigured;
    address private _pointsOperatorConfigured;
    bool private _blastClaimableConfigured;

    IERC20 public USDB;
    IERC20 public WETH;

    error InvalidGovernorError();

    function __BaseBlastManager_reconfigure() internal {
        // load config from the config storage contract and configure myself
        address blastAddress = configStorage.getAddress(
            StorageKey.BlastContract
        );
        if (blastAddress != address(blastContract)) {
            blastContract = IBlast(blastAddress);
            if (blastContract.isAuthorized(address(this))) {
                blastContract.configureClaimableGas();
                // fails on cloned networks
                (bool success, ) = blastAddress.call(
                    abi.encodeWithSelector(
                        bytes4(keccak256("configureClaimableYield()"))
                    )
                );
                if (success) {
                    // not on a cloned network and no compiler error!
                }
            }
        }

        address pointsContractAddress = configStorage.getAddress(
            StorageKey.BlastPointsContract
        );
        if (pointsContractAddress != address(blastPointsContract)) {
            blastPointsContract = IBlastPoints(pointsContractAddress);

            address pointsOperator = configStorage.getAddress(
                StorageKey.BlastPointsOperator
            );
            if (_pointsOperatorConfigured == address(0)) {
                // Reassignment must be called from the point operator itself
                blastPointsContract.configurePointsOperator(pointsOperator);
                _pointsOperatorConfigured = pointsOperator;
            }
        }

        address usdbAddress = configStorage.getAddress(StorageKey.USDBContract);
        address wethAddress = configStorage.getAddress(StorageKey.WETHContract);

        if (usdbAddress != address(USDB)) {
            USDB = IERC20(usdbAddress);
            IERC20Rebasing _USDB = IERC20Rebasing(usdbAddress);
            _USDB.configure(YieldMode.CLAIMABLE);
        }

        if (wethAddress != address(WETH)) {
            WETH = IERC20(wethAddress);
            IERC20Rebasing _WETH = IERC20Rebasing(wethAddress);
            _WETH.configure(YieldMode.CLAIMABLE);
        }

        address rewardsManagerAddress = configStorage.getAddress(
            StorageKey.RewardsManager
        );
        if (rewardsManagerAddress != address(0)) {
            setBlastGovernor(rewardsManagerAddress);
        }

        super.__BaseConfigStorage_reconfigure();
    }

    function setBlastGovernor(address _governor) internal {
        if (_governor == address(0)) revert InvalidGovernorError();
        if (address(blastContract) == address(0)) return;
        if (_governorConfigured == address(0)) {
            // if this contract is the governor then it should claim its own yield/gas
            if (_governor != address(this)) {
                // Once this is called the governor will be the only account allowed to configure
                blastContract.configureGovernor(_governor);
            }
        } else {
            IHoldsGovernorship(_governorConfigured).reassignBlastGovernor(
                _governor
            );
        }
        _governorConfigured = _governor;
    }

    function claimERC20Yield(
        address _tokenContract,
        uint256 _amount
    ) external onlyConfiguredContract(StorageKey.RewardsManager) {
        IERC20Rebasing(_tokenContract).claim(
            configStorage.getAddress(StorageKey.RewardsManager),
            _amount
        );
    }

    function getConfiguredGovernor() external view returns (address _governor) {
        _governor = _governorConfigured;
    }
}

// src/managers/LockManager.sol

contract LockManager is BaseBlastManager, ILockManager, ReentrancyGuard {
    /// @notice Threshold for executing a proposal
    uint8 APPROVE_THRESHOLD = 3;
    /// @notice Threshold for removing a proposal
    uint8 DISAPPROVE_THRESHOLD = 3;
    /// @notice Tokens configured on the contract
    mapping(address => ConfiguredToken) public configuredTokens;
    /// @notice Index of token contracts for easy enumerating
    address[] public configuredTokenContracts;
    /// @notice Player's currently locked tokens, can be multiple. Indexed by player then token contract
    mapping(address => mapping(address => LockedToken)) public lockedTokens;
    /// @notice Lock settings for each player
    mapping(address => PlayerSettings) playerSettings;
    /// @notice Current lockdrop start and end
    Lockdrop public lockdrop;
    /// @notice Current USD update proposal
    USDUpdateProposal usdUpdateProposal;
    /// @notice Used to make sure each approval is unique to a particular proposal
    uint32 private _usdProposalId;

    /// @notice Reference to the AccountManager contract
    IAccountManager public accountManager;

    /// @notice Reference to the SnuggeryManager.sol contract
    ISnuggeryManager public snuggeryManager;

    /// @notice Reference to the MigrationManager contract
    IMigrationManager public migrationManager;

    /// @notice Reference to the NFTOverlord contract to notify of unrevealed NFTs
    INFTOverlord public nftOverlord;

    /// @notice Token supplied must be configured but can be inactive
    modifier onlyConfiguredToken(address _tokenContract) {
        if (configuredTokens[_tokenContract].nftCost == 0)
            revert TokenNotConfiguredError();
        _;
    }

    /// @notice Token supplied must be configured and active
    modifier onlyActiveToken(address _tokenContract) {
        if (!configuredTokens[_tokenContract].active)
            revert TokenNotConfiguredError();
        _;
    }

    constructor(address _configStorage) {
        __BaseConfigStorage_setConfigStorage(_configStorage);
        _reconfigure();
    }

    function _reconfigure() internal {
        accountManager = IAccountManager(
            configStorage.getAddress(StorageKey.AccountManager)
        );

        migrationManager = IMigrationManager(
            configStorage.getAddress(StorageKey.MigrationManager)
        );

        snuggeryManager = ISnuggeryManager(
            configStorage.getAddress(StorageKey.SnuggeryManager)
        );

        nftOverlord = INFTOverlord(
            configStorage.getAddress(StorageKey.NFTOverlord)
        );

        super.__BaseBlastManager_reconfigure();
    }

    function configUpdated() external override onlyConfigStorage {
        _reconfigure();
    }

    fallback() external payable {
        revert LockManagerInvalidCallError();
    }

    receive() external payable {
        revert LockManagerRefuseETHError();
    }

    /// @inheritdoc ILockManager
    function configureLockdrop(
        Lockdrop calldata _lockdropData
    ) external onlyAdmin {
        if (_lockdropData.end < block.timestamp)
            revert LockdropEndedError(
                _lockdropData.end,
                uint32(block.timestamp)
            ); // , "LockManager: End date is in the past");
        if (_lockdropData.start >= _lockdropData.end)
            revert LockdropInvalidError();

        lockdrop = _lockdropData;

        emit LockDropConfigured(_lockdropData);
    }

    /// @inheritdoc ILockManager
    function configureToken(
        address _tokenContract,
        ConfiguredToken memory _tokenData
    ) external onlyAdmin {
        if (_tokenData.nftCost == 0) revert NFTCostInvalidError();
        if (configuredTokens[_tokenContract].nftCost == 0) {
            // new token
            configuredTokenContracts.push(_tokenContract);
        }
        configuredTokens[_tokenContract] = _tokenData;

        emit TokenConfigured(_tokenContract, _tokenData);
    }

    function setUSDThresholds(
        uint8 _approve,
        uint8 _disapprove
    ) external onlyAdmin {
        if (usdUpdateProposal.proposer != address(0))
            revert ProposalInProgressError();
        APPROVE_THRESHOLD = _approve;
        DISAPPROVE_THRESHOLD = _disapprove;

        emit USDThresholdUpdated(_approve, _disapprove);
    }

    /// @inheritdoc ILockManager
    function proposeUSDPrice(
        uint256 _price,
        address[] calldata _contracts
    )
        external
        onlyOneOfRoles(
            [
                Role.PriceFeed_1,
                Role.PriceFeed_2,
                Role.PriceFeed_3,
                Role.PriceFeed_4,
                Role.PriceFeed_5
            ]
        )
    {
        if (usdUpdateProposal.proposer != address(0))
            revert ProposalInProgressError();
        if (_contracts.length == 0) revert ProposalInvalidContractsError();

        delete usdUpdateProposal;

        // Approvals will use this because when the struct is deleted the approvals remain
        ++_usdProposalId;

        usdUpdateProposal.proposedDate = uint32(block.timestamp);
        usdUpdateProposal.proposer = msg.sender;
        usdUpdateProposal.proposedPrice = _price;
        usdUpdateProposal.contracts = _contracts;
        usdUpdateProposal.approvals[msg.sender] = _usdProposalId;
        usdUpdateProposal.approvalsCount++;

        emit ProposedUSDPrice(msg.sender, _price);
    }

    /// @inheritdoc ILockManager
    function approveUSDPrice(
        uint256 _price
    )
        external
        onlyOneOfRoles(
            [
                Role.PriceFeed_1,
                Role.PriceFeed_2,
                Role.PriceFeed_3,
                Role.PriceFeed_4,
                Role.PriceFeed_5
            ]
        )
    {
        if (usdUpdateProposal.proposer == address(0)) revert NoProposalError();
        if (usdUpdateProposal.proposer == msg.sender)
            revert ProposerCannotApproveError();
        if (usdUpdateProposal.approvals[msg.sender] == _usdProposalId)
            revert ProposalAlreadyApprovedError();
        if (usdUpdateProposal.proposedPrice != _price)
            revert ProposalPriceNotMatchedError();

        usdUpdateProposal.approvals[msg.sender] = _usdProposalId;
        usdUpdateProposal.approvalsCount++;

        if (usdUpdateProposal.approvalsCount >= APPROVE_THRESHOLD) {
            _execUSDPriceUpdate();
        }

        emit ApprovedUSDPrice(msg.sender);
    }

    /// @inheritdoc ILockManager
    function disapproveUSDPrice(
        uint256 _price
    )
        external
        onlyOneOfRoles(
            [
                Role.PriceFeed_1,
                Role.PriceFeed_2,
                Role.PriceFeed_3,
                Role.PriceFeed_4,
                Role.PriceFeed_5
            ]
        )
    {
        if (usdUpdateProposal.proposer == address(0)) revert NoProposalError();
        if (usdUpdateProposal.approvals[msg.sender] == _usdProposalId)
            revert ProposalAlreadyApprovedError();
        if (usdUpdateProposal.disapprovals[msg.sender] == _usdProposalId)
            revert ProposalAlreadyDisapprovedError();
        if (usdUpdateProposal.proposedPrice != _price)
            revert ProposalPriceNotMatchedError();

        usdUpdateProposal.disapprovalsCount++;
        usdUpdateProposal.disapprovals[msg.sender] = _usdProposalId;

        emit DisapprovedUSDPrice(msg.sender);

        if (usdUpdateProposal.disapprovalsCount >= DISAPPROVE_THRESHOLD) {
            delete usdUpdateProposal;

            emit RemovedUSDProposal();
        }
    }

    /// @inheritdoc ILockManager
    function setLockDuration(uint256 _duration) external notPaused {
        if (_duration > configStorage.getUint(StorageKey.MaxLockDuration))
            revert MaximumLockDurationError();

        playerSettings[msg.sender].lockDuration = uint32(_duration);
        // update any existing lock
        uint256 configuredTokensLength = configuredTokenContracts.length;
        for (uint256 i; i < configuredTokensLength; i++) {
            address tokenContract = configuredTokenContracts[i];
            if (lockedTokens[msg.sender][tokenContract].quantity > 0) {
                // check they are not setting lock time before current unlocktime
                if (
                    uint32(block.timestamp) + uint32(_duration) <
                    lockedTokens[msg.sender][tokenContract].unlockTime
                ) {
                    revert LockDurationReducedError();
                }

                uint32 lastLockTime = lockedTokens[msg.sender][tokenContract]
                    .lastLockTime;
                lockedTokens[msg.sender][tokenContract].unlockTime =
                    lastLockTime +
                    uint32(_duration);
            }
        }

        emit LockDuration(msg.sender, _duration);
    }

    /// @inheritdoc ILockManager
    function lockOnBehalf(
        address _tokenContract,
        uint256 _quantity,
        address _onBehalfOf
    )
        external
        payable
        notPaused
        onlyActiveToken(_tokenContract)
        onlyConfiguredToken(_tokenContract)
        nonReentrant
    {
        address tokenOwner = msg.sender;
        address lockRecipient = msg.sender;
        if (_onBehalfOf != address(0)) {
            lockRecipient = _onBehalfOf;
        }

        _lock(_tokenContract, _quantity, tokenOwner, lockRecipient);
    }

    /// @inheritdoc ILockManager
    function lock(
        address _tokenContract,
        uint256 _quantity
    )
        external
        payable
        notPaused
        onlyActiveToken(_tokenContract)
        onlyConfiguredToken(_tokenContract)
        nonReentrant
    {
        _lock(_tokenContract, _quantity, msg.sender, msg.sender);
    }

    function _lock(
        address _tokenContract,
        uint256 _quantity,
        address _tokenOwner,
        address _lockRecipient
    ) private {
        (
            address _mainAccount,
            MunchablesCommonLib.Player memory _player
        ) = accountManager.getPlayer(_lockRecipient);
        if (_mainAccount != _lockRecipient) revert SubAccountCannotLockError();
        if (_player.registrationDate == 0) revert AccountNotRegisteredError();
        // check approvals and value of tx matches
        if (_tokenContract == address(0)) {
            if (msg.value != _quantity) revert ETHValueIncorrectError();
        } else {
            if (msg.value != 0) revert InvalidMessageValueError();
            IERC20 token = IERC20(_tokenContract);
            uint256 allowance = token.allowance(_tokenOwner, address(this));
            if (allowance < _quantity) revert InsufficientAllowanceError();
        }

        LockedToken storage lockedToken = lockedTokens[_lockRecipient][
            _tokenContract
        ];
        ConfiguredToken storage configuredToken = configuredTokens[
            _tokenContract
        ];

        // they will receive schnibbles at the new rate since last harvest if not for force harvest
        accountManager.forceHarvest(_lockRecipient);

        // add remainder from any previous lock
        uint256 quantity = _quantity + lockedToken.remainder;
        uint256 remainder;
        uint256 numberNFTs;
        uint32 _lockDuration = playerSettings[_lockRecipient].lockDuration;

        if (_lockDuration == 0) {
            _lockDuration = lockdrop.minLockDuration;
        }
        if (
            lockdrop.start <= uint32(block.timestamp) &&
            lockdrop.end >= uint32(block.timestamp)
        ) {
            if (
                _lockDuration < lockdrop.minLockDuration ||
                _lockDuration >
                uint32(configStorage.getUint(StorageKey.MaxLockDuration))
            ) revert InvalidLockDurationError();
            if (msg.sender != address(migrationManager)) {
                // calculate number of nfts
                remainder = quantity % configuredToken.nftCost;
                numberNFTs = (quantity - remainder) / configuredToken.nftCost;

                if (numberNFTs > type(uint16).max) revert TooManyNFTsError();

                // Tell nftOverlord that the player has new unopened Munchables
                nftOverlord.addReveal(_lockRecipient, uint16(numberNFTs));
            }
        }

        // Transfer erc tokens
        if (_tokenContract != address(0)) {
            IERC20 token = IERC20(_tokenContract);
            token.transferFrom(_tokenOwner, address(this), _quantity);
        }

        lockedToken.remainder = remainder;
        lockedToken.quantity += _quantity;
        lockedToken.lastLockTime = uint32(block.timestamp);
        lockedToken.unlockTime =
            uint32(block.timestamp) +
            uint32(_lockDuration);

        // set their lock duration in playerSettings
        playerSettings[_lockRecipient].lockDuration = _lockDuration;

        emit Locked(
            _lockRecipient,
            _tokenOwner,
            _tokenContract,
            _quantity,
            remainder,
            numberNFTs,
            _lockDuration
        );
    }

    /// @inheritdoc ILockManager
    function unlock(
        address _tokenContract,
        uint256 _quantity
    ) external notPaused nonReentrant {
        LockedToken storage lockedToken = lockedTokens[msg.sender][
            _tokenContract
        ];
        if (lockedToken.quantity < _quantity)
            revert InsufficientLockAmountError();
        if (lockedToken.unlockTime > uint32(block.timestamp))
            revert TokenStillLockedError();

        // force harvest to make sure that they get the schnibbles that they are entitled to
        accountManager.forceHarvest(msg.sender);

        lockedToken.quantity -= _quantity;

        // send token
        if (_tokenContract == address(0)) {
            payable(msg.sender).transfer(_quantity);
        } else {
            IERC20 token = IERC20(_tokenContract);
            token.transfer(msg.sender, _quantity);
        }

        emit Unlocked(msg.sender, _tokenContract, _quantity);
    }

    /// @inheritdoc ILockManager
    function getLocked(
        address _player
    ) external view returns (LockedTokenWithMetadata[] memory _lockedTokens) {
        uint256 configuredTokensLength = configuredTokenContracts.length;
        LockedTokenWithMetadata[]
            memory tmpLockedTokens = new LockedTokenWithMetadata[](
                configuredTokensLength
            );
        for (uint256 i; i < configuredTokensLength; i++) {
            LockedToken memory tmpLockedToken;
            tmpLockedToken.unlockTime = lockedTokens[_player][
                configuredTokenContracts[i]
            ].unlockTime;
            tmpLockedToken.quantity = lockedTokens[_player][
                configuredTokenContracts[i]
            ].quantity;
            tmpLockedToken.lastLockTime = lockedTokens[_player][
                configuredTokenContracts[i]
            ].lastLockTime;
            tmpLockedToken.remainder = lockedTokens[_player][
                configuredTokenContracts[i]
            ].remainder;
            tmpLockedTokens[i] = LockedTokenWithMetadata(
                tmpLockedToken,
                configuredTokenContracts[i]
            );
        }
        _lockedTokens = tmpLockedTokens;
    }

    /// @inheritdoc ILockManager
    function getLockedWeightedValue(
        address _player
    ) external view returns (uint256 _lockedWeightedValue) {
        uint256 lockedWeighted = 0;
        uint256 configuredTokensLength = configuredTokenContracts.length;
        for (uint256 i; i < configuredTokensLength; i++) {
            if (
                lockedTokens[_player][configuredTokenContracts[i]].quantity >
                0 &&
                configuredTokens[configuredTokenContracts[i]].active
            ) {
                // We are assuming all tokens have a maximum of 18 decimals and that USD Price is denoted in 1e18
                uint256 deltaDecimal = 10 **
                    (18 -
                        configuredTokens[configuredTokenContracts[i]].decimals);
                lockedWeighted +=
                    (deltaDecimal *
                        lockedTokens[_player][configuredTokenContracts[i]]
                            .quantity *
                        configuredTokens[configuredTokenContracts[i]]
                            .usdPrice) /
                    1e18;
            }
        }

        _lockedWeightedValue = lockedWeighted;
    }

    /// @inheritdoc ILockManager
    function getConfiguredToken(
        address _tokenContract
    ) external view returns (ConfiguredToken memory _token) {
        _token = configuredTokens[_tokenContract];
    }

    function getPlayerSettings(
        address _player
    ) external view returns (PlayerSettings memory _settings) {
        _settings = playerSettings[_player];
    }

    /*******************************************************
     ** INTERNAL FUNCTIONS
     ********************************************************/

    function _execUSDPriceUpdate() internal {
        if (
            usdUpdateProposal.approvalsCount >= APPROVE_THRESHOLD &&
            usdUpdateProposal.disapprovalsCount < DISAPPROVE_THRESHOLD
        ) {
            uint256 updateTokensLength = usdUpdateProposal.contracts.length;
            for (uint256 i; i < updateTokensLength; i++) {
                address tokenContract = usdUpdateProposal.contracts[i];
                if (configuredTokens[tokenContract].nftCost != 0) {
                    configuredTokens[tokenContract].usdPrice = usdUpdateProposal
                        .proposedPrice;

                    emit USDPriceUpdated(
                        tokenContract,
                        usdUpdateProposal.proposedPrice
                    );
                }
            }

            delete usdUpdateProposal;
        }
    }
}

