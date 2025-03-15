// SPDX-License-Identifier: None
pragma solidity ^0.8.19;

// contracts/common/library/InitErrors.sol

/// @notice For maximum readability, error code must be a hex-encoded ASCII in the form {#DDD}.
/// @dev Reverts if the _condition is false.
/// @param _condition boolean condition required to be true.
/// @param _errorCode hex-encoded ASCII error code
function _require(bool _condition, uint32 _errorCode) pure {
    if (!_condition) revert(string(abi.encodePacked(_errorCode)));
}

library Errors {
    // Common
    uint32 internal constant ZERO_VALUE = 0x23313030; // hex-encoded ASCII of '#100'
    uint32 internal constant NOT_INIT_CORE = 0x23313031; // hex-encoded ASCII of '#101'
    uint32 internal constant SLIPPAGE_CONTROL = 0x23313032; // hex-encoded ASCII of '#102'
    uint32 internal constant CALL_FAILED = 0x23313033; // hex-encoded ASCII of '#103'
    uint32 internal constant NOT_OWNER = 0x23313034; // hex-encoded ASCII of '#104'
    uint32 internal constant NOT_WNATIVE = 0x23313035; // hex-encoded ASCII of '#105'
    uint32 internal constant ALREADY_SET = 0x23313036; // hex-encoded ASCII of '#106'
    uint32 internal constant NOT_WHITELISTED = 0x23313037; // hex-encoded ASCII of '#107'

    // Input
    uint32 internal constant ARRAY_LENGTH_MISMATCHED = 0x23323030; // hex-encoded ASCII of '#200'
    uint32 internal constant INPUT_TOO_LOW = 0x23323031; // hex-encoded ASCII of '#201'
    uint32 internal constant INPUT_TOO_HIGH = 0x23323032; // hex-encoded ASCII of '#202'
    uint32 internal constant INVALID_INPUT = 0x23323033; // hex-encoded ASCII of '#203'
    uint32 internal constant INVALID_TOKEN_IN = 0x23323034; // hex-encoded ASCII of '#204'
    uint32 internal constant INVALID_TOKEN_OUT = 0x23323035; // hex-encoded ASCII of '#205'
    uint32 internal constant NOT_SORTED_OR_DUPLICATED_INPUT = 0x23323036; // hex-encoded ASCII of '#206'

    // Core
    uint32 internal constant POSITION_NOT_HEALTHY = 0x23333030; // hex-encoded ASCII of '#300'
    uint32 internal constant POSITION_NOT_FOUND = 0x23333031; // hex-encoded ASCII of '#301'
    uint32 internal constant LOCKED_MULTICALL = 0x23333032; // hex-encoded ASCII of '#302'
    uint32 internal constant POSITION_HEALTHY = 0x23333033; // hex-encoded ASCII of '#303'
    uint32 internal constant INVALID_HEALTH_AFTER_LIQUIDATION = 0x23333034; // hex-encoded ASCII of '#304'
    uint32 internal constant FLASH_PAUSED = 0x23333035; // hex-encoded ASCII of '#305'
    uint32 internal constant INVALID_FLASHLOAN = 0x23333036; // hex-encoded ASCII of '#306'
    uint32 internal constant NOT_AUTHORIZED = 0x23333037; // hex-encoded ASCII of '#307'
    uint32 internal constant INVALID_CALLBACK_ADDRESS = 0x23333038; // hex-encoded ASCII of '#308'

    // Lending Pool
    uint32 internal constant MINT_PAUSED = 0x23343030; // hex-encoded ASCII of '#400'
    uint32 internal constant REDEEM_PAUSED = 0x23343031; // hex-encoded ASCII of '#401'
    uint32 internal constant BORROW_PAUSED = 0x23343032; // hex-encoded ASCII of '#402'
    uint32 internal constant REPAY_PAUSED = 0x23343033; // hex-encoded ASCII of '#403'
    uint32 internal constant NOT_ENOUGH_CASH = 0x23343034; // hex-encoded ASCII of '#404'
    uint32 internal constant INVALID_AMOUNT_TO_REPAY = 0x23343035; // hex-encoded ASCII of '#405'
    uint32 internal constant SUPPLY_CAP_REACHED = 0x23343036; // hex-encoded ASCII of '#406'
    uint32 internal constant BORROW_CAP_REACHED = 0x23343037; // hex-encoded ASCII of '#407'

    // Config
    uint32 internal constant INVALID_MODE = 0x23353030; // hex-encoded ASCII of '#500'
    uint32 internal constant TOKEN_NOT_WHITELISTED = 0x23353031; // hex-encoded ASCII of '#501'
    uint32 internal constant INVALID_FACTOR = 0x23353032; // hex-encoded ASCII of '#502'

    // Position Manager
    uint32 internal constant COLLATERALIZE_PAUSED = 0x23363030; // hex-encoded ASCII of '#600'
    uint32 internal constant DECOLLATERALIZE_PAUSED = 0x23363031; // hex-encoded ASCII of '#601'
    uint32 internal constant MAX_COLLATERAL_COUNT_REACHED = 0x23363032; // hex-encoded ASCII of '#602'
    uint32 internal constant NOT_CONTAIN = 0x23363033; // hex-encoded ASCII of '#603'
    uint32 internal constant ALREADY_COLLATERALIZED = 0x23363034; // hex-encoded ASCII of '#604'

    // Oracle
    uint32 internal constant NO_VALID_SOURCE = 0x23373030; // hex-encoded ASCII of '#700'
    uint32 internal constant TOO_MUCH_DEVIATION = 0x23373031; // hex-encoded ASCII of '#701'
    uint32 internal constant MAX_PRICE_DEVIATION_TOO_LOW = 0x23373032; // hex-encoded ASCII of '#702'
    uint32 internal constant NO_PRICE_ID = 0x23373033; // hex-encoded ASCII of '#703'
    uint32 internal constant PYTH_CONFIG_NOT_SET = 0x23373034; // hex-encoded ASCII of '#704'
    uint32 internal constant DATAFEED_ID_NOT_SET = 0x23373035; // hex-encoded ASCII of '#705'
    uint32 internal constant MAX_STALETIME_NOT_SET = 0x23373036; // hex-encoded ASCII of '#706'
    uint32 internal constant MAX_STALETIME_EXCEEDED = 0x23373037; // hex-encoded ASCII of '#707'
    uint32 internal constant PRIMARY_SOURCE_NOT_SET = 0x23373038; // hex-encoded ASCII of '#708'

    // Risk Manager
    uint32 internal constant DEBT_CEILING_EXCEEDED = 0x23383030; // hex-encoded ASCII of '#800'

    // Misc
    uint32 internal constant INCORRECT_PAIR = 0x23393030; // hex-encoded ASCII of '#900'
    uint32 internal constant UNIMPLEMENTED = 0x23393939; // hex-encoded ASCII of '#999'
}

// contracts/interfaces/common/IAccessControlManager.sol

/// @title Access Control Manager Interface
interface IAccessControlManager {
    /// @dev check the role of the user, revert against an unauthorized user.
    /// @param _role keccak256 hash of role name
    /// @param _user user address to check for the role
    function checkRole(bytes32 _role, address _user) external;
}

// contracts/interfaces/common/IMulticall.sol

/// @title Multicall Interface
interface IMulticall {
    /// @dev Perform multiple calls according to the provided _data. Reverts with reason if any of the calls failed.
    /// @notice `msg.value` should not be trusted or used in the multicall data.
    /// @param _data The encoded function data for each subcall.
    /// @return results The call results, if success.
    function multicall(bytes[] calldata _data) external payable returns (bytes[] memory results);
}

// contracts/interfaces/hook/IMarginTradingHook.sol

// @ mnt-eth = 3200, eth-usd = 2200
//    pair         |  col | bor |  B  |  Q  |   limit (sl)  |  limit (tp)  |
// ETH-USD (long)  |  ETH | USD | ETH | USD |    < 2000     |    > 3000    |
// ETH-USD (short) |  USD | ETH | ETH | USD |    > 3000     |    < 2000    |
// MNT-ETH (long)  |  MNT | ETH | ETH | MNT |    < 3000     |    > 4000    |
// MNT-ETH (short) |  ETH | MNT | ETH | MNT |    > 4000     |    > 3000    |

// enums
enum OrderType {
    StopLoss,
    TakeProfit
}

enum OrderStatus {
    Cancelled,
    Active,
    Filled
}

enum SwapType {
    OpenExactIn,
    CloseExactIn,
    CloseExactOut
}

// structs
struct Order {
    uint initPosId; // nft id
    uint triggerPrice_e36; // price (base asset price / quote asset price) to trigger limit order
    uint limitPrice_e36; // price limit price (base asset price / quote asset price) to fill order
    uint collAmt; // size of collateral to be used in order
    address tokenOut; // token to transfer to pos owner
    OrderType orderType; // stop loss or take profit
    OrderStatus status; // cancelled, active, filled
    address recipient; // address to receive tokenOut
}

struct MarginPos {
    address collPool; // lending pool to deposit holdToken
    address borrPool; // lending pool to borrow borrowToken
    address baseAsset; // base asset of position
    address quoteAsset; // quote asset of position
    bool isLongBaseAsset; // long base asset or not
}

struct SwapInfo {
    uint initPosId; // nft id
    SwapType swapType; // swap type
    address tokenIn; // token to swap
    address tokenOut; // token to receive from swap
    uint amtOut; // token amount out info for the swap
    bytes data; // swap data
}

interface IMarginTradingHook {
    // events
    event SwapToIncreasePos(
        uint indexed initPosId, address indexed tokenIn, address indexed tokenOut, uint amtIn, uint amtOut
    );
    event SwapToReducePos(
        uint indexed initPosId, address indexed tokenIn, address indexed tokenOut, uint amtIn, uint amtOut
    );

    event IncreasePos(
        uint indexed initPosId, address indexed tokenIn, address indexed borrToken, uint amtIn, uint borrowAmt
    );
    event ReducePos(uint indexed initPosId, address indexed tokenOut, uint amtOut, uint size, uint repayAmt);
    event CreateOrder(
        uint indexed initPosId,
        uint indexed orderId,
        address tokenOut,
        uint triggerPrice_e36,
        uint limitPrice_e36,
        uint size,
        OrderType orderType
    );

    event UpdateOrder(
        uint indexed initPosId,
        uint indexed orderId,
        address tokenOut,
        uint triggerPrice_e36,
        uint limitPrice_e36,
        uint size
    );
    event CancelOrder(uint indexed initPosId, uint indexed orderId);
    event FillOrder(uint indexed initPosId, uint indexed orderId, address tokenOut, uint amtOut);

    // struct
    struct IncreasePosInternalParam {
        uint initPosId; // nft id
        address tokenIn; // token to transfer from msg.sender
        uint amtIn; // token amount to transfer from msg sender (for wNative, amt to transfer will reduce by msg value)
        address borrPool; // lending pool to borrow
        uint borrAmt; // token amount to borrow
        address collPool; // lending pool to deposit
        bytes data; // swap data
        uint minHealth_e18; // minimum health to maintain after execute
    }

    struct ReducePosInternalParam {
        uint initPosId; // nft id
        uint collAmt; // collateral amt to reduce
        uint repayShares; // debt shares to repay
        address tokenOut; // token to transfer to msg sender
        uint minAmtOut; // minimum amount of token to transfer to msg sender
        bool returnNative; // return wNative as native token or not (using balanceOf(address(this)))
        bytes data; // swap data
        uint minHealth_e18; // minimum health to maintain after execute
    }

    // functions
    /// @dev open margin trading position
    /// @param _mode position mode to be used
    /// @param _viewer address to view position
    /// @param  _tokenIn token to transfer from msg.sender
    /// @param _amtIn token amount to transfer from msg sender (for wNative, amt to transfer will reduce by msg value)
    /// @param _borrPool lending pool to borrow
    /// @param _borrAmt token amount to borrow
    /// @param _collPool lending pool to deposit
    /// @param _data swap data
    /// @param _minHealth_e18 minimum health to maintain after execute
    /// @return posId margin trading position id
    ///         initPosId init position id (nft id)
    ///         health_e18 position health after execute
    function openPos(
        uint16 _mode,
        address _viewer,
        address _tokenIn,
        uint _amtIn,
        address _borrPool,
        uint _borrAmt,
        address _collPool,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable returns (uint posId, uint initPosId, uint health_e18);

    /// @dev increase position size (need to borrow)
    /// @param _posId margin trading position id
    /// @param  _tokenIn token to transfer from msg.sender
    /// @param _amtIn token amount to transfer from msg sender (for wNative, amt to transfer will reduce by msg value)
    /// @param _borrAmt token amount to borrow
    /// @param _data swap data
    /// @param _minHealth_e18 minimum health to maintain after execute
    /// @return health_e18 position health after execute
    function increasePos(
        uint _posId,
        address _tokenIn,
        uint _amtIn,
        uint _borrAmt,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable returns (uint health_e18);

    /// @dev add collarteral to position
    /// @param _posId position id
    /// @param _amtIn token amount to transfer from msg sender (for wNative, amt to transfer will reduce by msg value)
    /// @return health_e18 position health after execute
    function addCollateral(uint _posId, uint _amtIn) external payable returns (uint health_e18);

    /// @dev remove collateral from position
    /// @param _posId margin trading position id
    /// @param _shares shares amount to withdraw
    /// @param _returnNative return wNative as native token or not (using balanceOf(address(this)))
    function removeCollateral(uint _posId, uint _shares, bool _returnNative) external returns (uint health_e18);

    /// @dev repay debt of position
    /// @param _posId margin trading position id
    /// @param _repayShares debt shares to repay
    /// @return repayAmt actual amount of debt repaid
    ///         health_e18 position health after execute
    function repayDebt(uint _posId, uint _repayShares) external payable returns (uint repayAmt, uint health_e18);

    /// @dev reduce position size
    /// @param _posId margin trading position id
    /// @param _collAmt collateral amt to reduce
    /// @param _repayShares debt shares to repay
    /// @param _tokenOut token to transfer to msg sender
    /// @param _minAmtOut minimum amount of token to transfer to msg sender
    /// @param _returnNative return wNative as native token or not (using balanceOf(address(this)))
    /// @param _data swap data
    /// @param _minHealth_e18 minimum health to maintain after execute
    /// @return amtOut actual amount of token transferred to msg sender
    ///         health_e18 position health after execute
    function reducePos(
        uint _posId,
        uint _collAmt,
        uint _repayShares,
        address _tokenOut,
        uint _minAmtOut,
        bool _returnNative,
        bytes calldata _data,
        uint _minHealth_e18
    ) external returns (uint amtOut, uint health_e18);

    /// @dev create stop loss order
    /// @param _posId margin trading position id
    /// @param _triggerPrice_e36 oracle price (quote asset price / base asset price) to trigger limit order
    /// @param _tokenOut token to transfer to msg sender
    /// @param _limitPrice_e36 price limit price (quote asset price / base asset price) to fill order
    /// @param _collAmt collateral size for the order
    /// @return orderId order id
    function addStopLossOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId);

    /// @dev create take profit order
    /// @param _posId margin trading position id
    /// @param _triggerPrice_e36 oracle price (quote asset price / base asset price) to trigger limit order
    /// @param _tokenOut token to transfer to msg sender
    /// @param _limitPrice_e36 price limit price (quote asset price / base asset price) to fill order
    /// @param _collAmt share of collateral to use in order
    /// @return orderId order id
    function addTakeProfitOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId);

    /// @dev update order
    /// @param _orderId order id
    /// @param _triggerPrice_e36 oracle price (quote asset price / base asset price) to trigger limit order
    /// @param _tokenOut token to transfer to msg sender
    /// @param _limitPrice_e36 price limit price (quote asset price / base asset price) to fill order
    /// @param _collAmt share of collateral to use in order
    function updateOrder(
        uint _posId,
        uint _orderId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external;

    /// @dev cancel order
    /// @param _posId margin trading position id
    /// @param _orderId order id
    function cancelOrder(uint _posId, uint _orderId) external;

    /// @dev arbitrager reduce position in order and collateral at limit price
    /// @param _orderId order id
    function fillOrder(uint _orderId) external;

    /// @notice _tokenA and _tokenB MUST be different
    /// @dev set quote asset of pair
    /// @param _tokenA token A of pair
    /// @param _tokenB token B of pair
    /// @param _quoteAsset quote asset of pair
    function setQuoteAsset(address _tokenA, address _tokenB, address _quoteAsset) external;

    /// @dev get base asset and token asset of pair
    /// @param _tokenA token A of pair
    /// @param _tokenB token B of pair
    /// @return baseAsset base asset of pair
    /// @return quoteAsset quote asset of pair
    function getBaseAssetAndQuoteAsset(address _tokenA, address _tokenB)
        external
        view
        returns (address baseAsset, address quoteAsset);

    /// @dev get order information
    /// @param _orderId order id
    /// @return order order information
    function getOrder(uint _orderId) external view returns (Order memory);

    /// @dev get margin position information
    /// @param _initPosId init position id (nft id)
    /// @return marginPos margin position information
    function getMarginPos(uint _initPosId) external view returns (MarginPos memory);

    /// @dev get position's orders length
    /// @param _initPosId init position id (nft id)
    function getPosOrdersLength(uint _initPosId) external view returns (uint);

    /// @dev get hook's order id
    function lastOrderId() external view returns (uint);

    /// @dev get all position's order ids
    /// @param _initPosId init position id (nft id)
    function getPosOrderIds(uint _initPosId) external view returns (uint[] memory);
}

// contracts/interfaces/lending_pool/ILendingPool.sol

/// @title Lending Pool Interface
/// @notice rebase token is not supported
interface ILendingPool {
    event SetIrm(address _irm);
    event SetReserveFactor_e18(uint _reserveFactor_e18);
    event SetTreasury(address _treasury);

    /// @dev get core address
    function core() external view returns (address core);

    /// @dev get the interest rate model address
    function irm() external view returns (address model);

    /// @dev get the reserve factor in 1e18 (1e18 = 100%)
    function reserveFactor_e18() external view returns (uint factor_e18);

    /// @dev get the pool's underlying token
    function underlyingToken() external view returns (address token);

    /// @notice total assets = cash + total debts
    function totalAssets() external view returns (uint amt);

    /// @dev get the pool total debt (underlying token)
    function totalDebt() external view returns (uint debt);

    /// @dev get the pool total debt shares
    function totalDebtShares() external view returns (uint shares);

    /// @dev calaculate the debt share from debt amount (without interest accrual)
    /// @param _amt the amount of debt
    /// @return shares amount of debt shares (rounded up)
    function debtAmtToShareStored(uint _amt) external view returns (uint shares);

    /// @dev calaculate the debt share from debt amount (with interest accrual)
    /// @param _amt the amount of debt
    /// @return shares current amount of debt shares (rounded up)
    function debtAmtToShareCurrent(uint _amt) external returns (uint shares);

    /// @dev calculate the corresponding debt amount from debt share (without interest accrual)
    /// @param _shares the amount of debt shares
    /// @return amt corresponding debt amount (rounded up)
    function debtShareToAmtStored(uint _shares) external view returns (uint amt);

    /// @notice this is NOT a view function
    /// @dev calculate the corresponding debt amount from debt share (with interest accrual)
    /// @param _shares the amount of debt shares
    /// @return amt corresponding current debt amount (rounded up)
    function debtShareToAmtCurrent(uint _shares) external returns (uint amt);

    /// @dev get current supply rate per sec in 1e18
    function getSupplyRate_e18() external view returns (uint supplyRate_e18);

    /// @dev get current borrow rate per sec in 1e18
    function getBorrowRate_e18() external view returns (uint borrowRate_e18);

    /// @dev get the pool total cash (underlying token)
    function cash() external view returns (uint amt);

    /// @dev get the latest timestamp of interest accrual
    /// @return lastAccruedTime last accrued time unix timestamp
    function lastAccruedTime() external view returns (uint lastAccruedTime);

    /// @dev get the treasury address
    function treasury() external view returns (address treasury);

    /// @notice only core can call this function
    /// @dev mint shares to the receiver from the transfered assets
    /// @param _receiver address to receive shares
    /// @return mintShares amount of shares minted
    function mint(address _receiver) external returns (uint mintShares);

    /// @notice only core can call this function
    /// @dev burn shares and send the underlying assets to the receiver
    /// @param _receiver address to receive the underlying tokens
    /// @return amt amount of underlying assets transferred
    function burn(address _receiver) external returns (uint amt);

    /// @notice only core can call this function
    /// @dev borrow the asset from the lending pool
    /// @param _receiver address to receive the borrowed asset
    /// @param _amt amount of asset to borrow
    /// @return debtShares debt shares amount recorded from borrowing
    function borrow(address _receiver, uint _amt) external returns (uint debtShares);

    /// @notice only core can call this function
    /// @dev repay the borrowed assets
    /// @param _shares the amount of debt shares to repay
    /// @return amt assets amount used for repay
    function repay(uint _shares) external returns (uint amt);

    /// @dev accrue interest from the last accrual
    function accrueInterest() external;

    /// @dev get the share amounts from underlying asset amt
    /// @param _amt the amount of asset to convert to shares
    /// @return shares amount of shares (rounded down)
    function toShares(uint _amt) external view returns (uint shares);

    /// @dev get the asset amount from shares
    /// @param _shares the amount of shares to convert to underlying asset amt
    /// @return amt amount of underlying asset (rounded down)
    function toAmt(uint _shares) external view returns (uint amt);

    /// @dev get the share amounts from underlying asset amt (with interest accrual)
    /// @param _amt the amount of asset to convert to shares
    /// @return shares current amount of shares (rounded down)
    function toSharesCurrent(uint _amt) external returns (uint shares);

    /// @dev get the asset amount from shares (with interest accrual)
    /// @param _shares the amount of shares to convert to underlying asset amt
    /// @return amt current amount of underlying asset (rounded down)
    function toAmtCurrent(uint _shares) external returns (uint amt);

    /// @dev set the interest rate model
    /// @param _irm new interest rate model address
    function setIrm(address _irm) external;

    /// @dev set the pool's reserve factor in 1e18
    /// @param _reserveFactor_e18 new reserver factor in 1e18
    function setReserveFactor_e18(uint _reserveFactor_e18) external;

    /// @dev set the pool's treasury address
    /// @param _treasury new treasury address
    function setTreasury(address _treasury) external;
}

// contracts/interfaces/oracle/IBaseOracle.sol

/// @title Base Oracle Interface
interface IBaseOracle {
    /// @dev return the value of the token as USD, multiplied by 1e36.
    /// @param _token token address
    /// @return price_e36 token price in 1e36
    function getPrice_e36(address _token) external view returns (uint price_e36);
}

// contracts/interfaces/receiver/ICallbackReceiver.sol

/// @title Callback Receiver Interface
interface ICallbackReceiver {
    /// @dev handle the callback from core
    /// @param _sender the sender address
    /// @param _data the data payload to execute on the callback
    /// @return result the encoded result of the callback
    function coreCallback(address _sender, bytes calldata _data) external payable returns (bytes memory result);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// lib/openzeppelin-contracts/contracts/utils/math/Math.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}

// lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/IERC721ReceiverUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721ReceiverUpgradeable {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// lib/openzeppelin-contracts-upgradeable/contracts/utils/AddressUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// contracts/common/UnderACM.sol

abstract contract UnderACM {
    // immutables
    IAccessControlManager public immutable ACM; // access control manager

    // constructor
    constructor(address _acm) {
        ACM = IAccessControlManager(_acm);
    }
}

// contracts/interfaces/common/IWNative.sol

/// @title Wrapped Native Interface
interface IWNative is IERC20 {
    /// @dev wrap the native token to wrapped token using `msg.value` as the amount
    function deposit() external payable;

    /// @dev unwrap the wrapped token to native token
    /// @param amount token amount to unwrap
    function withdraw(uint amount) external;
}

// contracts/interfaces/core/IConfig.sol

// structs

struct TokenFactors {
    uint128 collFactor_e18; // collateral factor in 1e18 (1e18 = 100%)
    uint128 borrFactor_e18; // borrow factor in 1e18 (1e18 = 100%)
}

struct ModeConfig {
    EnumerableSet.AddressSet collTokens; // enumerable set of collateral tokens
    EnumerableSet.AddressSet borrTokens; // enumerable set of borrow tokens
    uint64 maxHealthAfterLiq_e18; // max health factor allowed after liquidation
    mapping(address => TokenFactors) factors; // token factors mapping
    ModeStatus status; // mode status
    uint8 maxCollWLpCount; // limit number of wLp to avoid out of gas
}

struct PoolConfig {
    uint128 supplyCap; // pool supply cap
    uint128 borrowCap; // pool borrow cap
    bool canMint; // pool mint status
    bool canBurn; // pool burn status
    bool canBorrow; // pool borrow status
    bool canRepay; // pool repay status
    bool canFlash; // pool flash status
}

struct ModeStatus {
    bool canCollateralize; // mode collateralize status
    bool canDecollateralize; // mode decollateralize status
    bool canBorrow; // mode borrow status
    bool canRepay; // mode repay status
}

/// @title Config Interface
/// @notice Configuration parameters for the protocol.
interface IConfig {
    event SetPoolConfig(address indexed pool, PoolConfig config);
    event SetCollFactors_e18(uint16 indexed mode, address[] tokens, uint128[] _factors);
    event SetBorrFactors_e18(uint16 indexed mode, address[] tokens, uint128[] factors);
    event SetMaxHealthAfterLiq_e18(uint16 indexed mode, uint64 maxHealthAfterLiq_e18);
    event SetWhitelistedWLps(address[] wLps, bool status);
    event SetModeStatus(uint16 mode, ModeStatus status);
    event SetMaxCollWLpCount(uint16 indexed mode, uint8 maxCollWLpCount);

    /// @dev check if the wrapped lp is whitelisted.
    /// @param _wlp wrapped lp address
    /// @return whether the wrapped lp is whitelisted.
    function whitelistedWLps(address _wlp) external view returns (bool);

    /// @dev get mode config
    /// @param _mode mode id
    /// @return collTokens collateral token list
    ///         borrTokens borrow token list
    ///         maxHealthAfterLiq_e18 max health factor allowed after liquidation
    ///         maxCollWLpCount // limit number of wLp to avoid out of gas
    function getModeConfig(uint16 _mode)
        external
        view
        returns (
            address[] memory collTokens,
            address[] memory borrTokens,
            uint maxHealthAfterLiq_e18,
            uint8 maxCollWLpCount
        );

    /// @dev get pool config
    /// @param _pool pool address
    /// @return poolConfig pool config
    function getPoolConfig(address _pool) external view returns (PoolConfig memory poolConfig);

    /// @dev check if the pool within the specified mode is allowed for borrowing.
    /// @param _mode mode id
    /// @param _pool lending pool address
    /// @return whether the pool within the mode is allowed for borrowing.
    function isAllowedForBorrow(uint16 _mode, address _pool) external view returns (bool);

    /// @dev check if the pool within the specified mode is allowed for collateralizing.
    /// @param _mode mode id
    /// @param _pool lending pool address
    /// @return whether the pool within the mode is allowed for collateralizing.
    function isAllowedForCollateral(uint16 _mode, address _pool) external view returns (bool);

    /// @dev get the token factors (collateral and borrow factors)
    /// @param _mode mode id
    /// @param _pool lending pool address
    /// @return tokenFactors token factors
    function getTokenFactors(uint16 _mode, address _pool) external view returns (TokenFactors memory tokenFactors);

    /// @notice if return the value of type(uint64).max, skip the health check after liquidation
    /// @dev get the mode max health allowed after liquidation
    /// @param _mode mode id
    /// @param maxHealthAfterLiq_e18 max allowed health factor after liquidation
    function getMaxHealthAfterLiq_e18(uint16 _mode) external view returns (uint maxHealthAfterLiq_e18);

    /// @dev get the current mode status
    /// @param _mode mode id
    /// @return modeStatus mode status (collateralize, decollateralize, borrow or repay)
    function getModeStatus(uint16 _mode) external view returns (ModeStatus memory modeStatus);

    /// @dev set pool config
    /// @param _pool lending pool address
    /// @param _config new pool config
    function setPoolConfig(address _pool, PoolConfig calldata _config) external;

    /// @dev set pool collateral factors
    /// @param _pools lending pool address list
    /// @param _factors new collateral factor list in 1e18 (1e18 = 100%)
    function setCollFactors_e18(uint16 _mode, address[] calldata _pools, uint128[] calldata _factors) external;

    /// @dev set pool borrow factors
    /// @param _pools lending pool address list
    /// @param _factors new borrow factor list in 1e18 (1e18 = 100%)
    function setBorrFactors_e18(uint16 _mode, address[] calldata _pools, uint128[] calldata _factors) external;

    /// @dev set mode status
    /// @param _status new mode status to set to (collateralize, decollateralize, borrow and repay)
    function setModeStatus(uint16 _mode, ModeStatus calldata _status) external;

    /// @notice only governor role can call
    /// @dev set whitelisted wrapped lp statuses
    /// @param _wLps wrapped lp list
    /// @param _status whitelisted status to set to
    function setWhitelistedWLps(address[] calldata _wLps, bool _status) external;

    /// @dev set max health after liquidation (type(uint64).max means infinite, or no check)
    /// @param _mode mode id
    /// @param _maxHealthAfterLiq_e18 new max allowed health factor after liquidation
    function setMaxHealthAfterLiq_e18(uint16 _mode, uint64 _maxHealthAfterLiq_e18) external;

    /// @dev set mode's max collateral wrapped lp count to avoid out of gas
    /// @param _mode mode id
    /// @param _maxCollWLpCount max collateral wrapped lp count
    function setMaxCollWLpCount(uint16 _mode, uint8 _maxCollWLpCount) external;

    /// @dev get mode's max collateral wlp count
    /// @param _mode mode id
    /// @return the mode's max collateral wlp count
    function getModeMaxCollWLpCount(uint16 _mode) external view returns (uint8);
}

// contracts/interfaces/core/IPosManager.sol

/// @title Position Interface
interface IPosManager {
    event SetMaxCollCount(uint maxCollCount);

    struct PosInfo {
        address viewer; // viewer address
        uint16 mode; // position mode
    }

    // NOTE: extra info for hooks (not used in core)
    struct PosBorrExtraInfo {
        uint128 totalInterest; // total accrued interest since the position is created
        uint128 lastDebtAmt; // position's debt amount after the last interaction
    }

    struct PosCollInfo {
        EnumerableSet.AddressSet collTokens; // enumerable set of collateral tokens
        mapping(address => uint) collAmts; // collateral token to collateral amts mapping
        EnumerableSet.AddressSet wLps; // enumerable set of collateral wlps
        mapping(address => EnumerableSet.UintSet) ids; // wlp address to enumerable set of ids mapping
        uint8 collCount; // current collateral count (erc20 + wlp)
        uint8 wLpCount; // current collateral count (wlp)
    }

    struct PosBorrInfo {
        EnumerableSet.AddressSet pools; // enumerable set of borrow tokens
        mapping(address => uint) debtShares; // debt token to debt shares mapping
        mapping(address => PosBorrExtraInfo) borrExtraInfos; // debt token to extra info mapping
    }

    /// @dev get the next nonce of the owner for calculating the next position id
    /// @param _owner the position owner
    /// @return nextNonce the next nonce of the position owner
    function nextNonces(address _owner) external view returns (uint nextNonce);

    /// @dev get core address
    function core() external view returns (address core);

    /// @dev get pending reward token amts for the pos id
    /// @param _posId pos id
    /// @param _rewardToken reward token
    /// @return amt reward token amt
    function pendingRewards(uint _posId, address _rewardToken) external view returns (uint amt);

    /// @dev get whether the wlp is already collateralized to a position
    /// @param _wLp wlp address
    /// @param _tokenId wlp token id
    /// @return whether the wlp is already collateralized to a position
    function isCollateralized(address _wLp, uint _tokenId) external view returns (bool);

    /// @dev get the position borrowed info (excluding the extra info)
    /// @param _posId position id
    /// @return pools the borrowed pool list
    ///         debtShares the debt shares list of the borrowed pools
    function getPosBorrInfo(uint _posId) external view returns (address[] memory pools, uint[] memory debtShares);

    /// @dev get the position borrowed extra info
    /// @param _posId position id
    /// @param _pool borrowed pool address
    /// @return totalInterest total accrued interest since the position is created
    ///         lastDebtAmt position's debt amount after the last interaction
    function getPosBorrExtraInfo(uint _posId, address _pool)
        external
        view
        returns (uint totalInterest, uint lastDebtAmt);

    /// @dev get the position collateral info
    /// @param _posId position id
    /// @return pools the collateral pool adddres list
    ///         amts collateral amts of the collateral pools
    ///         wLps the collateral wlp list
    ///         ids the ids of the collateral wlp list
    ///         wLpAmts the amounts of the collateral wlp list
    function getPosCollInfo(uint _posId)
        external
        view
        returns (
            address[] memory pools,
            uint[] memory amts,
            address[] memory wLps,
            uint[][] memory ids,
            uint[][] memory wLpAmts
        );

    /// @dev get pool's collateral amount for the position
    /// @param _posId position id
    /// @param _pool collateral pool address
    /// @return amt collateral amount
    function getCollAmt(uint _posId, address _pool) external view returns (uint amt);

    /// @dev get wrapped lp collateral amount for the position
    /// @param _posId position id
    /// @param _wLp collateral wlp address
    /// @param _tokenId collateral wlp token id
    /// @return amt collateral amount
    function getCollWLpAmt(uint _posId, address _wLp, uint _tokenId) external view returns (uint amt);

    /// @dev get position's collateral count
    /// @param _posId position id
    /// @return collCount position's collateral count
    function getPosCollCount(uint _posId) external view returns (uint8 collCount);

    /// @dev get position's wLp count
    /// @param _posId position id
    function getPosCollWLpCount(uint _posId) external view returns (uint8 wLpCount);

    /// @dev get position info
    /// @param _posId position id
    /// @return viewerAddress position's viewer address
    ///         mode position's mode
    function getPosInfo(uint _posId) external view returns (address viewerAddress, uint16 mode);

    /// @dev get position mode
    /// @param _posId position id
    /// @return mode position's mode
    function getPosMode(uint _posId) external view returns (uint16 mode);

    /// @dev get pool's debt shares for the position
    /// @param _posId position id
    /// @param _pool lending pool address
    /// @return debtShares debt shares
    function getPosDebtShares(uint _posId, address _pool) external view returns (uint debtShares);

    /// @dev get pos id at index corresponding to the viewer address (reverse mapping)
    /// @param _viewer viewer address
    /// @param _index index
    /// @return posId pos id
    function getViewerPosIdsAt(address _viewer, uint _index) external view returns (uint posId);

    /// @dev get pos id length corresponding to the viewer address (reverse mapping)
    /// @param _viewer viewer address
    /// @return length pos ids length
    function getViewerPosIdsLength(address _viewer) external view returns (uint length);

    /// @notice only core can call this function
    /// @dev update pool's debt share
    /// @param _posId position id
    /// @param _pool lending pool address
    /// @param _debtShares  new debt shares
    function updatePosDebtShares(uint _posId, address _pool, int _debtShares) external;

    /// @notice only core can call this function
    /// @dev update position mode
    /// @param _posId position id
    /// @param _mode new position mode to set to
    function updatePosMode(uint _posId, uint16 _mode) external;

    /// @notice only core can call this function
    /// @dev add lending pool share as collateral to the position
    /// @param _posId position id
    /// @param _pool lending pool address
    /// @return amtIn pool's share collateral amount added to the position
    function addCollateral(uint _posId, address _pool) external returns (uint amtIn);

    /// @notice only core can call this function
    /// @dev add wrapped lp share as collateral to the position
    /// @param _posId position id
    /// @param _wLp wlp address
    /// @param _tokenId wlp token id
    /// @return amtIn wlp collateral amount added to the position
    function addCollateralWLp(uint _posId, address _wLp, uint _tokenId) external returns (uint amtIn);

    /// @notice only core can call this function
    /// @dev remove lending pool share from the position
    /// @param _posId position id
    /// @param _pool lending pool address
    /// @param _receiver address to receive the shares
    /// @return amtOut pool's share collateral amount removed from the position
    function removeCollateralTo(uint _posId, address _pool, uint _shares, address _receiver)
        external
        returns (uint amtOut);

    /// @notice only core can call this function
    /// @dev remove wlp from the position
    /// @param _posId position id
    /// @param _wLp wlp address
    /// @param _tokenId wlp token id
    /// @param _amt wlp token amount to remove
    /// @return amtOut wlp collateral amount removed from the position
    function removeCollateralWLpTo(uint _posId, address _wLp, uint _tokenId, uint _amt, address _receiver)
        external
        returns (uint amtOut);

    /// @notice only core can call this function
    /// @dev create a new position
    /// @param _owner position owner
    /// @param _mode position mode
    /// @param _viewer position viewer
    /// @return posId position id
    function createPos(address _owner, uint16 _mode, address _viewer) external returns (uint posId);

    /// @dev harvest rewards from the wlp token
    /// @param _posId position id
    /// @param _wlp wlp address
    /// @param _tokenId id of the wlp token
    /// @param _to address to receive the rewards
    /// @return tokens token address list harvested
    ///         amts token amt list harvested
    function harvestTo(uint _posId, address _wlp, uint _tokenId, address _to)
        external
        returns (address[] memory tokens, uint[] memory amts);

    /// @notice When removing the wrapped LP collateral, the rewards are harvested to the position manager
    ///         before unwrapping the LP and sending it to the user
    /// @dev claim pending reward pending in the position manager
    /// @param _posId position id
    /// @param _tokens token address list to claim pending reward
    /// @param _to address to receive the pending rewards
    /// @return amts amount of each reward tokens claimed
    function claimPendingRewards(uint _posId, address[] calldata _tokens, address _to)
        external
        returns (uint[] memory amts);

    /// @notice authorized account could be the owner or approved addresses
    /// @dev check if the accoount is authorized for the position
    /// @param _account account address to check
    /// @param _posId position id
    /// @return whether the account is authorized to manage the position
    function isAuthorized(address _account, uint _posId) external view returns (bool);

    /// @notice only guardian can call this function
    /// @dev set the max number of the different collateral count (to avoid out-of-gas error)
    /// @param _maxCollCount new max collateral count
    function setMaxCollCount(uint8 _maxCollCount) external;

    /// @notice only position owner can call this function
    /// @dev set new position viewer for pos id
    /// @param _posId pos id
    /// @param _viewer new viewer address
    function setPosViewer(uint _posId, address _viewer) external;
}

// contracts/interfaces/helper/swap_helper/IBaseSwapHelper.sol

interface IBaseSwapHelper {
    function swap(SwapInfo calldata _swapInfo) external;
}

// contracts/interfaces/oracle/IInitOracle.sol

/// @title Init Oracle Interface
interface IInitOracle is IBaseOracle {
    event SetPrimarySource(address indexed token, address oracle);
    event SetSecondarySource(address indexed token, address oracle);
    event SetMaxPriceDeviation_e18(address indexed token, uint maxPriceDeviation_e18);

    /// @dev return the oracle token's primary source
    /// @param _token token address
    /// @return primarySource primary oracle address
    function primarySources(address _token) external view returns (address primarySource);

    /// @dev return the oracle token's secondary source
    /// @param _token token address
    /// @return secondarySource secoundary oracle address
    function secondarySources(address _token) external view returns (address secondarySource);

    /// @dev return the max price deviation between the primary and secondary sources
    /// @param _token token address
    /// @return maxPriceDeviation_e18 max price deviation in 1e18
    function maxPriceDeviations_e18(address _token) external view returns (uint maxPriceDeviation_e18);

    /// @dev return the price of the tokens in USD, multiplied by 1e36.
    /// @param _tokens token address list
    /// @return prices_e36 the token prices for each tokens
    function getPrices_e36(address[] calldata _tokens) external view returns (uint[] memory prices_e36);

    /// @dev set primary source for tokens
    /// @param _tokens token address list
    /// @param _sources the primary source address for each tokens
    function setPrimarySources(address[] calldata _tokens, address[] calldata _sources) external;

    /// @dev set secondary source for tokens
    /// @param _tokens token address list
    /// @param _sources the secondary source address for each tokens
    function setSecondarySources(address[] calldata _tokens, address[] calldata _sources) external;

    /// @dev set max price deviation between the primary and sercondary sources
    /// @param _tokens token address list
    /// @param _maxPriceDeviations_e18 the max price deviation in 1e18 for each tokens
    function setMaxPriceDeviations_e18(address[] calldata _tokens, uint[] calldata _maxPriceDeviations_e18) external;
}

// lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// contracts/interfaces/core/IInitCore.sol

/// @title InitCore Interface
interface IInitCore {
    event SetConfig(address indexed newConfig);
    event SetOracle(address indexed newOracle);
    event SetIncentiveCalculator(address indexed newIncentiveCalculator);
    event SetRiskManager(address indexed newRiskManager);
    event Borrow(address indexed pool, uint indexed posId, address indexed to, uint borrowAmt, uint shares);
    event Repay(address indexed pool, uint indexed posId, address indexed repayer, uint shares, uint amtToRepay);
    event CreatePosition(address indexed owner, uint indexed posId, uint16 mode, address viewer);
    event SetPositionMode(uint indexed posId, uint16 mode);
    event Collateralize(uint indexed posId, address indexed pool, uint amt);
    event Decollateralize(uint indexed posId, address indexed pool, address indexed to, uint amt);
    event CollateralizeWLp(uint indexed posId, address indexed wLp, uint indexed tokenId, uint amt);
    event DecollateralizeWLp(uint indexed posId, address indexed wLp, uint indexed tokenId, address to, uint amt);
    event Liquidate(uint indexed posId, address indexed liquidator, address poolOut, uint shares);
    event LiquidateWLp(uint indexed posId, address indexed liquidator, address wLpOut, uint tokenId, uint amt);

    struct LiquidateLocalVars {
        IConfig config;
        uint16 mode;
        uint health_e18;
        uint liqIncentive_e18;
        address collToken;
        address repayToken;
        uint repayAmt;
        uint repayAmtWithLiqIncentive;
    }

    /// @dev get position manager address
    function POS_MANAGER() external view returns (address);

    /// @dev get config address
    function config() external view returns (address);

    /// @dev get oracle address
    function oracle() external view returns (address);

    /// @dev get risk manager address
    function riskManager() external view returns (address);

    /// @dev get liquidation incentive calculator address
    function liqIncentiveCalculator() external view returns (address);

    /// @dev mint lending pool shares (using ∆balance in lending pool)
    /// @param _pool lending pool address
    /// @param _to address to receive share token
    /// @return shares amount of share tokens minted
    function mintTo(address _pool, address _to) external returns (uint shares);

    /// @dev burn lending pool share tokens to receive underlying (using ∆balance in lending pool)
    /// @param _pool lending pool address
    /// @param _to address to receive underlying
    /// @return amt amount of underlying to receive
    function burnTo(address _pool, address _to) external returns (uint amt);

    /// @dev borrow underlying from lending pool
    /// @param _pool lending pool address
    /// @param _amt amount of underlying to borrow
    /// @param _posId position id to account for the borrowing
    /// @param _to address to receive borrow underlying
    /// @return shares the amount of debt shares for the borrowing
    function borrow(address _pool, uint _amt, uint _posId, address _to) external returns (uint shares);

    /// @dev repay debt to the lending pool
    /// @param _pool address of lending pool
    /// @param _shares  debt shares to repay
    /// @param _posId position id to repay debt
    /// @return amt amount of underlying to repaid
    function repay(address _pool, uint _shares, uint _posId) external returns (uint amt);

    /// @dev create a new position
    /// @param _mode position mode
    /// @param _viewer position viewer address
    function createPos(uint16 _mode, address _viewer) external returns (uint posId);

    /// @dev change a position's mode
    /// @param _posId position id to change mode
    /// @param _mode position mode to change to
    function setPosMode(uint _posId, uint16 _mode) external;

    /// @dev collateralize lending pool share tokens to position
    /// @param _posId position id to collateralize to
    /// @param _pool lending pool address
    function collateralize(uint _posId, address _pool) external;

    /// @notice need to check the position's health after decollateralization
    /// @dev decollateralize lending pool share tokens from the position
    /// @param _posId position id to decollateral
    /// @param _pool lending pool address
    /// @param _shares amount of share tokens to decollateralize
    /// @param _to address to receive token
    function decollateralize(uint _posId, address _pool, uint _shares, address _to) external;

    /// @dev collateralize wlp to position
    /// @param _posId position id to collateralize to
    /// @param _wLp wlp token address
    /// @param _tokenId token id of wlp token to collateralize
    function collateralizeWLp(uint _posId, address _wLp, uint _tokenId) external;

    /// @notice need to check position's health after decollateralization
    /// @dev decollateralize wlp from the position
    /// @param _posId position id to decollateralize
    /// @param _wLp wlp token address
    /// @param _tokenId token id of wlp token to decollateralize
    /// @param _amt amount of wlp token to decollateralize
    function decollateralizeWLp(uint _posId, address _wLp, uint _tokenId, uint _amt, address _to) external;

    /// @notice need to check position's health before liquidate & limit health after liqudate
    /// @dev (partial) liquidate the position
    /// @param _posId position id to liquidate
    /// @param _poolToRepay address of lending pool to liquidate
    /// @param _repayShares debt shares to repay
    /// @param _tokenOut pool token to receive for the liquidation
    /// @param _minShares min amount of pool token to receive after liquidate (slippage control)
    /// @return amt the token amount out actually transferred out
    function liquidate(uint _posId, address _poolToRepay, uint _repayShares, address _tokenOut, uint _minShares)
        external
        returns (uint amt);

    /// @notice need to check position's health before liquidate & limit health after liqudate
    /// @dev (partial) liquidate the position
    /// @param _posId position id to liquidate
    /// @param _poolToRepay address of lending pool to liquidate
    /// @param _repayShares debt shares to liquidate
    /// @param _wLp wlp to unwrap for liquidation
    /// @param _tokenId wlp token id to burn for liquidation
    /// @param _minLpOut min amount of lp to receive for liquidation
    /// @return amt the token amount out actually transferred out
    function liquidateWLp(
        uint _posId,
        address _poolToRepay,
        uint _repayShares,
        address _wLp,
        uint _tokenId,
        uint _minLpOut
    ) external returns (uint amt);

    /// @notice caller must implement `flashCallback` function
    /// @dev flashloan underlying tokens from lending pool
    /// @param _pools lending pool address list to flashloan from
    /// @param _amts token amount list to flashloan
    /// @param _data data to execute in the callback function
    function flash(address[] calldata _pools, uint[] calldata _amts, bytes calldata _data) external;

    /// @dev make a callback to the target contract
    /// @param _to target address to receive callback
    /// @param _value msg.value to pass on to the callback
    /// @param _data data to execute callback function
    /// @return result callback result
    function callback(address _to, uint _value, bytes calldata _data) external payable returns (bytes memory result);

    /// @notice this is NOT a view function
    /// @dev get current position's collateral credit in 1e36 (interest accrued up to current timestamp)
    /// @param _posId position id to get collateral credit for
    /// @return credit current position collateral credit
    function getCollateralCreditCurrent_e36(uint _posId) external returns (uint credit);

    /// @dev get current position's borrow credit in 1e36 (interest accrued up to current timestamp)
    /// @param _posId position id to get borrow credit for
    /// @return credit current position borrow credit
    function getBorrowCreditCurrent_e36(uint _posId) external returns (uint credit);

    /// @dev get current position's health factor in 1e18 (interest accrued up to current timestamp)
    /// @param _posId position id to get health factor
    /// @return health current position health factor
    function getPosHealthCurrent_e18(uint _posId) external returns (uint health);

    /// @dev set new config
    function setConfig(address _config) external;

    /// @dev set new oracle
    function setOracle(address _oracle) external;

    /// @dev set new liquidation incentve calculator
    function setLiqIncentiveCalculator(address _liqIncentiveCalculator) external;

    /// @dev set new risk manager
    function setRiskManager(address _riskManager) external;

    /// @dev transfer token from msg.sender to the target address
    /// @param _token token address to transfer
    /// @param _to address to receive token
    /// @param _amt amount of token to transfer
    function transferToken(address _token, address _to, uint _amt) external;
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

// lib/openzeppelin-contracts-upgradeable/contracts/token/ERC721/utils/ERC721HolderUpgradeable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }

    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// contracts/hook/BaseMappingIdHook.sol

abstract contract BaseMappingIdHook is ERC721HolderUpgradeable {
    using SafeERC20 for IERC20;

    // immutables
    address public immutable CORE;
    address public immutable POS_MANAGER;
    // storages
    mapping(address => uint) public lastPosIds;
    mapping(address => mapping(uint => uint)) public initPosIds;

    // constructor
    constructor(address _core, address _posManager) {
        CORE = _core;
        POS_MANAGER = _posManager;
    }

    /// @dev approve token for init core if needed
    /// @param _token token address
    /// @param _amt token amount to spend
    function _ensureApprove(address _token, uint _amt) internal {
        if (IERC20(_token).allowance(address(this), CORE) < _amt) {
            IERC20(_token).safeApprove(CORE, type(uint).max);
        }
    }
}

// contracts/hook/MarginTradingHook.sol

contract MarginTradingHook is BaseMappingIdHook, UnderACM, IMarginTradingHook, ICallbackReceiver {
    using SafeERC20 for IERC20;
    using Math for uint;

    // constants
    uint private constant ONE_E18 = 1e18;
    uint private constant ONE_E36 = 1e36;
    bytes32 private constant GOVERNOR = keccak256('governor');
    // immutables
    address public immutable WNATIVE;
    // storages
    address public swapHelper;
    mapping(address => mapping(address => address)) private __quoteAssets;
    mapping(uint => Order) private __orders;
    mapping(uint => MarginPos) private __marginPositions;
    mapping(uint => uint[]) private __posOrderIds;
    uint public lastOrderId;

    // modifiers
    modifier onlyGovernor() {
        ACM.checkRole(GOVERNOR, msg.sender);
        _;
    }

    // constructor
    constructor(address _core, address _posManager, address _wNative, address _acm)
        BaseMappingIdHook(_core, _posManager)
        UnderACM(_acm)
    {
        WNATIVE = _wNative;
    }

    // initializer
    function initialize(address _swapHelper) external initializer {
        swapHelper = _swapHelper;
    }

    modifier depositNative() {
        if (msg.value != 0) IWNative(WNATIVE).deposit{value: msg.value}();
        _;
    }

    modifier refundNative() {
        _;
        // refund native token
        uint wNativeBal = IERC20(WNATIVE).balanceOf(address(this));
        // NOTE: no need receive function since we will use TransparentUpgradeableProxyReceiveETH
        if (wNativeBal != 0) IWNative(WNATIVE).withdraw(wNativeBal);
        uint nativeBal = address(this).balance;
        if (nativeBal != 0) {
            (bool success,) = payable(msg.sender).call{value: nativeBal}('');
            _require(success, Errors.CALL_FAILED);
        }
    }

    // functions
    /// @inheritdoc IMarginTradingHook
    function openPos(
        uint16 _mode,
        address _viewer,
        address _tokenIn,
        uint _amtIn,
        address _borrPool,
        uint _borrAmt,
        address _collPool,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable depositNative refundNative returns (uint posId, uint initPosId, uint health_e18) {
        initPosId = IInitCore(CORE).createPos(_mode, _viewer);
        address borrToken = ILendingPool(_borrPool).underlyingToken();
        {
            (address baseToken, address quoteToken) = getBaseAssetAndQuoteAsset(
                ILendingPool(_collPool).underlyingToken(), ILendingPool(_borrPool).underlyingToken()
            );
            bool isLongBaseAsset = baseToken != borrToken;
            __marginPositions[initPosId] = MarginPos(_collPool, _borrPool, baseToken, quoteToken, isLongBaseAsset);
        }
        posId = ++lastPosIds[msg.sender];
        initPosIds[msg.sender][posId] = initPosId;
        health_e18 = _increasePosInternal(
            IncreasePosInternalParam({
                initPosId: initPosId,
                tokenIn: _tokenIn,
                amtIn: _amtIn,
                borrPool: _borrPool,
                borrAmt: _borrAmt,
                collPool: _collPool,
                data: _data,
                minHealth_e18: _minHealth_e18
            })
        );
    }

    /// @inheritdoc IMarginTradingHook
    function increasePos(
        uint _posId,
        address _tokenIn,
        uint _amtIn,
        uint _borrAmt,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable depositNative refundNative returns (uint health_e18) {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        health_e18 = _increasePosInternal(
            IncreasePosInternalParam({
                initPosId: initPosId,
                tokenIn: _tokenIn,
                amtIn: _amtIn,
                borrPool: marginPos.borrPool,
                borrAmt: _borrAmt,
                collPool: marginPos.collPool,
                data: _data,
                minHealth_e18: _minHealth_e18
            })
        );
    }

    /// @dev increase margin pos internal logic
    function _increasePosInternal(IncreasePosInternalParam memory _param) internal returns (uint health_e18) {
        _transmitTokenIn(_param.tokenIn, _param.amtIn);

        // perform multicall to INIT core:
        // 1. borrow tokens
        // 2. callback (perform swap from borr -> coll)
        // 3. deposit collateral tokens
        // 4. collateralize tokens
        bytes[] memory multicallData = new bytes[](4);
        multicallData[0] = abi.encodeWithSelector(
            IInitCore(CORE).borrow.selector, _param.borrPool, _param.borrAmt, _param.initPosId, address(this)
        );
        address collToken = ILendingPool(_param.collPool).underlyingToken();
        address borrToken = ILendingPool(_param.borrPool).underlyingToken();
        _require(_param.tokenIn == collToken || _param.tokenIn == borrToken, Errors.INVALID_INPUT);
        {
            SwapInfo memory swapInfo =
                SwapInfo(_param.initPosId, SwapType.OpenExactIn, borrToken, collToken, 0, _param.data);
            multicallData[1] =
                abi.encodeWithSelector(IInitCore(CORE).callback.selector, address(this), 0, abi.encode(swapInfo));
        }
        multicallData[2] = abi.encodeWithSelector(IInitCore(CORE).mintTo.selector, _param.collPool, POS_MANAGER);
        multicallData[3] =
            abi.encodeWithSelector(IInitCore(CORE).collateralize.selector, _param.initPosId, _param.collPool);

        // do multicall
        IMulticall(CORE).multicall(multicallData);

        // position health check
        health_e18 = _validateHealth(_param.initPosId, _param.minHealth_e18);
        emit IncreasePos(_param.initPosId, _param.tokenIn, borrToken, _param.amtIn, _param.borrAmt);
    }

    /// @inheritdoc IMarginTradingHook
    function addCollateral(uint _posId, uint _amtIn)
        external
        payable
        depositNative
        refundNative
        returns (uint health_e18)
    {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        // transfer in tokens
        _transmitTokenIn(collToken, _amtIn);
        // transfer tokens to collPool
        IERC20(collToken).safeTransfer(marginPos.collPool, _amtIn);
        // mint collateral pool tokens
        IInitCore(CORE).mintTo(marginPos.collPool, POS_MANAGER);
        // collateralize to INIT position
        IInitCore(CORE).collateralize(initPosId, marginPos.collPool);
        // get health
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(initPosId);
    }

    /// @inheritdoc IMarginTradingHook
    function removeCollateral(uint _posId, uint _shares, bool _returnNative)
        external
        refundNative
        returns (uint health_e18)
    {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        // decollateralize collTokens to collPool
        IInitCore(CORE).decollateralize(initPosId, marginPos.collPool, _shares, marginPos.collPool);
        // redeem underlying
        IInitCore(CORE).burnTo(marginPos.collPool, address(this));
        // transfer collateral tokens out
        uint balance = IERC20(collToken).balanceOf(address(this));
        _transmitTokenOut(collToken, balance, _returnNative);
        // get position health
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(initPosId);
    }

    /// @inheritdoc IMarginTradingHook
    function repayDebt(uint _posId, uint _repayShares)
        external
        payable
        depositNative
        refundNative
        returns (uint repayAmt, uint health_e18)
    {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        address borrPool = marginPos.borrPool;
        // calculate repay shares (if it exceeds position debt share, only repay what's available)
        uint debtShares = IPosManager(POS_MANAGER).getPosDebtShares(initPosId, borrPool);
        if (_repayShares > debtShares) _repayShares = debtShares;
        // get borrow token amount to repay
        address borrToken = ILendingPool(borrPool).underlyingToken();
        uint amtToRepay = ILendingPool(borrPool).debtShareToAmtCurrent(_repayShares);
        // transfer in borrow tokens
        _transmitTokenIn(borrToken, amtToRepay);
        // repay debt to INIT core
        _ensureApprove(borrToken, amtToRepay);
        repayAmt = IInitCore(CORE).repay(borrPool, _repayShares, initPosId);
        // get position health
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(initPosId);
    }

    /// @inheritdoc IMarginTradingHook
    function reducePos(
        uint _posId,
        uint _collAmt,
        uint _repayShares,
        address _tokenOut,
        uint _minAmtOut,
        bool _returnNative,
        bytes calldata _data,
        uint _minHealth_e18
    ) external refundNative returns (uint amtOut, uint health_e18) {
        uint initPosId = initPosIds[msg.sender][_posId];
        (amtOut, health_e18) = _reducePosInternal(
            ReducePosInternalParam({
                initPosId: initPosId,
                collAmt: _collAmt,
                repayShares: _repayShares,
                tokenOut: _tokenOut,
                minAmtOut: _minAmtOut,
                returnNative: _returnNative,
                data: _data,
                minHealth_e18: _minHealth_e18
            })
        );
    }

    function _reducePosInternal(ReducePosInternalParam memory _param) internal returns (uint amtOut, uint health_e18) {
        MarginPos memory marginPos = __marginPositions[_param.initPosId];
        // check collAmt & repay shares
        _require(
            _param.collAmt <= IPosManager(POS_MANAGER).getCollAmt(_param.initPosId, marginPos.collPool),
            Errors.INPUT_TOO_HIGH
        );
        _require(
            _param.repayShares <= IPosManager(POS_MANAGER).getPosDebtShares(_param.initPosId, marginPos.borrPool),
            Errors.INPUT_TOO_HIGH
        );

        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        address borrToken = ILendingPool(marginPos.borrPool).underlyingToken();
        _require(_param.tokenOut == collToken || _param.tokenOut == borrToken, Errors.INVALID_INPUT);

        uint repayAmt = ILendingPool(marginPos.borrPool).debtShareToAmtCurrent(_param.repayShares);
        _ensureApprove(borrToken, repayAmt);

        // 1. decollateralize collateral tokens
        // 2. redeem underlying collateral tokens
        // 3. callback (perform swap from coll -> borr)
        // 4. repay borrow tokens
        bytes[] memory multicallData = new bytes[](4);
        multicallData[0] = abi.encodeWithSelector(
            IInitCore(CORE).decollateralize.selector,
            _param.initPosId,
            marginPos.collPool,
            _param.collAmt,
            marginPos.collPool
        );
        multicallData[1] = abi.encodeWithSelector(IInitCore(CORE).burnTo.selector, marginPos.collPool, address(this));
        {
            // if expect token out = borr token -> swap all (exact-in)
            // if expect token out = coll token -> swap enough to repay (exact-out)
            SwapType swapType = _param.tokenOut == borrToken ? SwapType.CloseExactIn : SwapType.CloseExactOut;
            SwapInfo memory swapInfo = SwapInfo(_param.initPosId, swapType, collToken, borrToken, repayAmt, _param.data);
            multicallData[2] =
                abi.encodeWithSelector(IInitCore(CORE).callback.selector, address(this), 0, abi.encode(swapInfo));
        }
        multicallData[3] = abi.encodeWithSelector(
            IInitCore(CORE).repay.selector, marginPos.borrPool, _param.repayShares, _param.initPosId
        );

        // do multicall
        IMulticall(CORE).multicall(multicallData);
        amtOut = IERC20(_param.tokenOut).balanceOf(address(this));
        // slippage control check
        _require(amtOut >= _param.minAmtOut, Errors.SLIPPAGE_CONTROL);
        // transfer tokens out
        _transmitTokenOut(_param.tokenOut, amtOut, _param.returnNative);

        // check slippage control on position's health
        health_e18 = _validateHealth(_param.initPosId, _param.minHealth_e18);
        emit ReducePos(_param.initPosId, _param.tokenOut, amtOut, _param.collAmt, repayAmt);
    }

    /// @inheritdoc IMarginTradingHook
    function addStopLossOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId) {
        orderId = _createOrder(_posId, _triggerPrice_e36, _tokenOut, _limitPrice_e36, _collAmt, OrderType.StopLoss);
    }

    /// @inheritdoc IMarginTradingHook
    function addTakeProfitOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId) {
        orderId = _createOrder(_posId, _triggerPrice_e36, _tokenOut, _limitPrice_e36, _collAmt, OrderType.TakeProfit);
    }

    /// @inheritdoc IMarginTradingHook
    function cancelOrder(uint _posId, uint _orderId) external {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        Order storage order = __orders[_orderId];
        _require(order.initPosId == initPosId, Errors.INVALID_INPUT);
        _require(order.status == OrderStatus.Active, Errors.INVALID_INPUT);
        order.status = OrderStatus.Cancelled;
        emit CancelOrder(initPosId, _orderId);
    }

    /// @inheritdoc IMarginTradingHook
    function fillOrder(uint _orderId) external {
        Order memory order = __orders[_orderId];
        _require(order.status == OrderStatus.Active, Errors.INVALID_INPUT);
        MarginPos memory marginPos = __marginPositions[order.initPosId];
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        address borrToken = ILendingPool(marginPos.borrPool).underlyingToken();
        // if position is empty, cancel order
        if (IPosManager(POS_MANAGER).getCollAmt(order.initPosId, marginPos.collPool) == 0) {
            order.status = OrderStatus.Cancelled;
            emit CancelOrder(order.initPosId, _orderId);
            return;
        }
        // validate trigger price condition
        _validateTriggerPrice(order, marginPos);
        // calculate fill order info
        (uint amtOut, uint repayShares, uint repayAmt) = _calculateFillOrderInfo(order, marginPos, collToken);
        // transfer in repay tokens
        IERC20(borrToken).safeTransferFrom(msg.sender, address(this), repayAmt);
        // transfer order owner's desired tokens to the specified recipient
        IERC20(order.tokenOut).safeTransferFrom(msg.sender, order.recipient, amtOut);
        // repay tokens
        _ensureApprove(borrToken, repayAmt);
        IInitCore(CORE).repay(marginPos.borrPool, repayShares, order.initPosId);
        // decollateralize coll pool tokens to executor
        IInitCore(CORE).decollateralize(order.initPosId, marginPos.collPool, order.collAmt, msg.sender);
        // update order status
        __orders[_orderId].status = OrderStatus.Filled;
        emit FillOrder(order.initPosId, _orderId, order.tokenOut, amtOut);
    }

    /// @inheritdoc ICallbackReceiver
    function coreCallback(address _sender, bytes calldata _data) external payable returns (bytes memory result) {
        _require(msg.sender == CORE, Errors.NOT_INIT_CORE);
        _require(_sender == address(this), Errors.NOT_AUTHORIZED);
        SwapInfo memory swapInfo = abi.decode(_data, (SwapInfo));
        MarginPos memory marginPos = __marginPositions[swapInfo.initPosId];
        uint amtIn = IERC20(swapInfo.tokenIn).balanceOf(address(this));
        IERC20(swapInfo.tokenIn).safeTransfer(swapHelper, amtIn); // transfer all token in to swap helper
        // swap helper swap token
        IBaseSwapHelper(swapHelper).swap(swapInfo);
        uint amtOut = IERC20(swapInfo.tokenOut).balanceOf(address(this));
        if (swapInfo.swapType == SwapType.OpenExactIn) {
            // transfer to coll pool to mint
            IERC20(swapInfo.tokenOut).safeTransfer(marginPos.collPool, amtOut);
            emit SwapToIncreasePos(swapInfo.initPosId, swapInfo.tokenIn, swapInfo.tokenOut, amtIn, amtOut);
        } else {
            // transfer to borr pool to repay
            uint amtSwapped = amtIn;
            if (swapInfo.swapType == SwapType.CloseExactOut) {
                // slippage control to make sure that swap helper swap correctly
                _require(IERC20(swapInfo.tokenOut).balanceOf(address(this)) == swapInfo.amtOut, Errors.SLIPPAGE_CONTROL);
                amtSwapped -= IERC20(swapInfo.tokenIn).balanceOf(address(this));
            }
            emit SwapToReducePos(swapInfo.initPosId, swapInfo.tokenIn, swapInfo.tokenOut, amtSwapped, amtOut);
        }
        result = abi.encode(amtOut);
    }

    /// @inheritdoc IMarginTradingHook
    function setQuoteAsset(address _tokenA, address _tokenB, address _quoteAsset) external onlyGovernor {
        _require(_tokenA != address(0) && _tokenB != address(0), Errors.ZERO_VALUE);
        _require(_quoteAsset == _tokenA || _quoteAsset == _tokenB, Errors.INVALID_INPUT);
        _require(_tokenA != _tokenB, Errors.NOT_SORTED_OR_DUPLICATED_INPUT);
        // sort tokenA and tokenB
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        __quoteAssets[token0][token1] = _quoteAsset;
    }

    /// @inheritdoc IMarginTradingHook
    function getBaseAssetAndQuoteAsset(address _tokenA, address _tokenB)
        public
        view
        returns (address baseAsset, address quoteAsset)
    {
        // sort tokenA and tokenB
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        quoteAsset = __quoteAssets[token0][token1];
        _require(quoteAsset != address(0), Errors.ZERO_VALUE);
        baseAsset = quoteAsset == token0 ? token1 : token0;
    }

    /// @inheritdoc IMarginTradingHook
    function getOrder(uint _orderId) external view returns (Order memory) {
        return __orders[_orderId];
    }

    /// @inheritdoc IMarginTradingHook
    function getMarginPos(uint _initPosId) external view returns (MarginPos memory) {
        return __marginPositions[_initPosId];
    }

    /// @inheritdoc IMarginTradingHook
    function getPosOrdersLength(uint _initPosId) external view returns (uint) {
        return __posOrderIds[_initPosId].length;
    }

    /// @notice _collAmt MUST be > 0
    /// @dev create order internal logic
    function _createOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt,
        OrderType _orderType
    ) internal returns (uint orderId) {
        orderId = ++lastOrderId;
        _require(_collAmt != 0, Errors.ZERO_VALUE);
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos memory marginPos = __marginPositions[initPosId];
        _require(_tokenOut == marginPos.baseAsset || _tokenOut == marginPos.quoteAsset, Errors.INVALID_INPUT);
        uint collAmt = IPosManager(POS_MANAGER).getCollAmt(initPosId, marginPos.collPool);
        _require(_collAmt <= collAmt, Errors.INPUT_TOO_HIGH); // check specified coll amt is feasible

        __orders[orderId] = (
            Order({
                initPosId: initPosId,
                triggerPrice_e36: _triggerPrice_e36,
                limitPrice_e36: _limitPrice_e36,
                collAmt: _collAmt,
                tokenOut: _tokenOut,
                orderType: _orderType,
                status: OrderStatus.Active,
                recipient: msg.sender
            })
        );
        __posOrderIds[initPosId].push(orderId);
        emit CreateOrder(initPosId, orderId, _tokenOut, _triggerPrice_e36, _limitPrice_e36, _collAmt, _orderType);
    }

    /// @inheritdoc IMarginTradingHook
    function updateOrder(
        uint _posId,
        uint _orderId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external {
        _require(_collAmt != 0, Errors.ZERO_VALUE);
        Order storage order = __orders[_orderId];
        _require(order.status == OrderStatus.Active, Errors.INVALID_INPUT);
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos memory marginPos = __marginPositions[initPosId];
        uint collAmt = IPosManager(POS_MANAGER).getCollAmt(initPosId, marginPos.collPool);
        _require(_collAmt <= collAmt, Errors.INPUT_TOO_HIGH);

        order.triggerPrice_e36 = _triggerPrice_e36;
        order.limitPrice_e36 = _limitPrice_e36;
        order.collAmt = _collAmt;
        order.tokenOut = _tokenOut;
        emit UpdateOrder(initPosId, _orderId, _tokenOut, _triggerPrice_e36, _limitPrice_e36, _collAmt);
    }

    /// @dev calculate fill order info
    /// @param _order margin order info
    /// @param _marginPos margin pos info
    /// @param _collToken margin pos's collateral token
    function _calculateFillOrderInfo(Order memory _order, MarginPos memory _marginPos, address _collToken)
        internal
        returns (uint amtOut, uint repayShares, uint repayAmt)
    {
        (repayShares, repayAmt) = _calculateRepaySize(_order, _marginPos);
        uint collTokenAmt = ILendingPool(_marginPos.collPool).toAmtCurrent(_order.collAmt);
        // NOTE: all roundings favor the order owner (amtOut)
        if (_collToken == _order.tokenOut) {
            if (_marginPos.isLongBaseAsset) {
                // long eth hold eth
                // (2 * 1500 - 1500) = 1500 / 1500 = 1 eth
                // ((c * limit - borrow) / limit
                amtOut = collTokenAmt - repayAmt * ONE_E36 / _order.limitPrice_e36;
            } else {
                // short eth hold usdc
                // 2000 - 1 * 1500 = 500 usdc
                // (c - borrow * limit)
                amtOut = collTokenAmt - (repayAmt * _order.limitPrice_e36 / ONE_E36);
            }
        } else {
            if (_marginPos.isLongBaseAsset) {
                // long eth hold usdc
                // (2 * 1500 - 1500) = 1500 usdc
                // ((c * limit - borrow)
                amtOut = (collTokenAmt * _order.limitPrice_e36).ceilDiv(ONE_E36) - repayAmt;
            } else {
                // short eth hold eth
                // (3000 - 1 * 1500) / 1500 = 1 eth
                // (c - borrow * limit) / limit
                amtOut = (collTokenAmt * ONE_E36).ceilDiv(_order.limitPrice_e36) - repayAmt;
            }
        }
    }

    /// @dev validate price for margin order for the margin position
    /// @param _order margin order info
    /// @param _marginPos margin position info
    function _validateTriggerPrice(Order memory _order, MarginPos memory _marginPos) internal view {
        address oracle = IInitCore(CORE).oracle();
        uint markPrice_e36 = IInitOracle(oracle).getPrice_e36(_marginPos.baseAsset).mulDiv(
            ONE_E36, IInitOracle(oracle).getPrice_e36(_marginPos.quoteAsset)
        );
        // validate mark price
        // if long base asset, and order type is to take profit -> mark price should pass the trigger price (>=)
        // if long base asset, and order type is to add stop loss -> mark price should be smaller than the trigger price (<=)
        // if short base asset, and order type is to take profit -> mark price should be smaller than the trigger price (<=)
        // if short base asset, and order type is to add stop loss -> mark price should be larger than the trigger price (>=)
        (_order.orderType == OrderType.TakeProfit) == _marginPos.isLongBaseAsset
            ? _require(markPrice_e36 >= _order.triggerPrice_e36, Errors.INVALID_INPUT)
            : _require(markPrice_e36 <= _order.triggerPrice_e36, Errors.INVALID_INPUT);
    }

    /// @notice if the specified order size is larger than the position's collateral, repay size is scaled proportionally.
    /// @dev calculate repay size of the given margin order
    /// @param _order order info
    /// @param _marginPos margin position info
    /// @return repayAmt repay amount
    /// @return repayShares repay shares
    function _calculateRepaySize(Order memory _order, MarginPos memory _marginPos)
        internal
        returns (uint repayAmt, uint repayShares)
    {
        uint totalCollAmt = IPosManager(POS_MANAGER).getCollAmt(_order.initPosId, _marginPos.collPool);
        if (_order.collAmt > totalCollAmt) _order.collAmt = totalCollAmt;
        uint totalDebtShares = IPosManager(POS_MANAGER).getPosDebtShares(_order.initPosId, _marginPos.borrPool);
        repayShares = totalDebtShares * _order.collAmt / totalCollAmt;
        repayAmt = ILendingPool(_marginPos.borrPool).debtShareToAmtCurrent(repayShares);
    }

    /// @notice if msg.value is provided, then _amt to expect for the transfer is the amount needed on top of msg.value
    /// @dev transfer _tokenIn in with specific amount
    /// @param _tokenIn token in address
    /// @param _amt token amount to expect (this amount includes msg.value if _tokenIn is wrapped native)
    function _transmitTokenIn(address _tokenIn, uint _amt) internal {
        uint amtToTransfer = _amt;
        if (msg.value != 0) {
            _require(_tokenIn == WNATIVE, Errors.NOT_WNATIVE);
            amtToTransfer = _amt > msg.value ? amtToTransfer - msg.value : 0;
        }
        if (amtToTransfer != 0) IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), amtToTransfer);
    }

    /// @notice if _returnNative is true, this function does nothing
    /// @dev transfer _tokenOut out with specific amount
    /// @param _tokenOut token out address
    /// @param _amt token amount to transfer
    /// @param _returnNative whether to return in native token (only applies in case _tokenOut is wrapped native)
    function _transmitTokenOut(address _tokenOut, uint _amt, bool _returnNative) internal {
        // note: if token out is wNative and return native is true,
        // leave token in this contract to be handled by refundNative modifier
        // else transfer token out to msg.sender
        if (_tokenOut != WNATIVE || !_returnNative) IERC20(_tokenOut).safeTransfer(msg.sender, _amt);
    }

    /// @dev validate position health
    function _validateHealth(uint _initPosId, uint _minHealth_e18) internal returns (uint health_e18) {
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(_initPosId);
        _require(health_e18 >= _minHealth_e18, Errors.SLIPPAGE_CONTROL);
    }

    /// @inheritdoc IMarginTradingHook
    function getPosOrderIds(uint _initPosId) external view returns (uint[] memory) {
        return __posOrderIds[_initPosId];
    }
}

