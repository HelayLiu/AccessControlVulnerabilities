pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)


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
    function transferFrom(
        address from,
        address to,
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


// File @openzeppelin/contracts/utils/Address.sol@v4.5.0

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)


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
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
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
        return functionCall(target, data, "Address: low-level call failed");
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.5.0

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)



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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.5.0

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)


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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File interfaces/IPreparable.sol


interface IPreparable {
    event ConfigPreparedAddress(bytes32 indexed key, address value, uint256 delay);
    event ConfigPreparedNumber(bytes32 indexed key, uint256 value, uint256 delay);

    event ConfigUpdatedAddress(bytes32 indexed key, address oldValue, address newValue);
    event ConfigUpdatedNumber(bytes32 indexed key, uint256 oldValue, uint256 newValue);

    event ConfigReset(bytes32 indexed key);
}


// File interfaces/strategies/IStrategy.sol


interface IStrategy {
    function deposit() external payable returns (bool);

    function withdraw(uint256 amount) external returns (bool);

    function withdrawAll() external returns (uint256);

    function harvest() external returns (uint256);

    function shutdown() external returns (bool);

    function setCommunityReserve(address _communityReserve) external returns (bool);

    function setStrategist(address strategist_) external returns (bool);

    function name() external view returns (string memory);

    function balance() external view returns (uint256);

    function harvestable() external view returns (uint256);

    function strategist() external view returns (address);

    function hasPendingFunds() external view returns (bool);
}


// File interfaces/IVault.sol



/**
 * @title Interface for a Vault
 */

interface IVault is IPreparable {
    event StrategyActivated(address indexed strategy);

    event StrategyDeactivated(address indexed strategy);

    /**
     * @dev 'netProfit' is the profit after all fees have been deducted
     */
    event Harvest(uint256 indexed netProfit, uint256 indexed loss);

    function initialize(
        address _pool,
        uint256 _debtLimit,
        uint256 _targetAllocation,
        uint256 _bound
    ) external;

    function withdrawFromStrategyWaitingForRemoval(address strategy) external returns (uint256);

    function deposit() external payable;

    function withdraw(uint256 amount) external returns (bool);

    function initializeStrategy(address strategy_) external returns (bool);

    function withdrawAll() external;

    function withdrawFromReserve(uint256 amount) external;

    function executeNewStrategy() external returns (address);

    function prepareNewStrategy(address newStrategy) external returns (bool);

    function activateStrategy() external returns (bool);

    function deactivateStrategy() external returns (bool);

    function resetNewStrategy() external returns (bool);

    function preparePerformanceFee(uint256 newPerformanceFee) external returns (bool);

    function executePerformanceFee() external returns (uint256);

    function resetPerformanceFee() external returns (bool);

    function prepareStrategistFee(uint256 newStrategistFee) external returns (bool);

    function executeStrategistFee() external returns (uint256);

    function resetStrategistFee() external returns (bool);

    function prepareDebtLimit(uint256 newDebtLimit) external returns (bool);

    function executeDebtLimit() external returns (uint256);

    function resetDebtLimit() external returns (bool);

    function prepareTargetAllocation(uint256 newTargetAllocation) external returns (bool);

    function executeTargetAllocation() external returns (uint256);

    function resetTargetAllocation() external returns (bool);

    function prepareReserveFee(uint256 newReserveFee) external returns (bool);

    function executeReserveFee() external returns (uint256);

    function resetReserveFee() external returns (bool);

    function prepareBound(uint256 newBound) external returns (bool);

    function executeBound() external returns (uint256);

    function resetBound() external returns (bool);

    function withdrawFromStrategy(uint256 amount) external returns (bool);

    function withdrawAllFromStrategy() external returns (bool);

    function harvest() external returns (bool);

    function getStrategiesWaitingForRemoval() external view returns (address[] memory);

    function getAllocatedToStrategyWaitingForRemoval(address strategy)
        external
        view
        returns (uint256);

    function getStrategy() external view returns (IStrategy);

    function getTotalUnderlying() external view returns (uint256);

    function getUnderlying() external view returns (address);

    function getStrategistFee() external view returns (uint256);

    function getReserveFee() external view returns (uint256);

    function getPerformanceFee() external view returns (uint256);

    function getBound() external view returns (uint256);

    function getTargetAllocation() external view returns (uint256);

    function getDebtLimit() external view returns (uint256);
}


// File interfaces/pool/ILiquidityPool.sol



interface ILiquidityPool is IPreparable {
    event Deposit(address indexed minter, uint256 depositAmount, uint256 mintedLpTokens);

    event DepositFor(
        address indexed minter,
        address indexed mintee,
        uint256 depositAmount,
        uint256 mintedLpTokens
    );

    event Redeem(address indexed redeemer, uint256 redeemAmount, uint256 redeemTokens);

    event LpTokenSet(address indexed lpToken);

    event StakerVaultSet(address indexed stakerVault);

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeem(uint256 redeemTokens, uint256 minRedeemAmount) external returns (uint256);

    function calcRedeem(address account, uint256 underlyingAmount) external returns (uint256);

    function deposit(uint256 mintAmount) external payable returns (uint256);

    function deposit(uint256 mintAmount, uint256 minTokenAmount) external payable returns (uint256);

    function depositAndStake(uint256 depositAmount, uint256 minTokenAmount)
        external
        payable
        returns (uint256);

    function depositFor(address account, uint256 depositAmount) external payable returns (uint256);

    function depositFor(
        address account,
        uint256 depositAmount,
        uint256 minTokenAmount
    ) external payable returns (uint256);

    function unstakeAndRedeem(uint256 redeemLpTokens, uint256 minRedeemAmount)
        external
        returns (uint256);

    function handleLpTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) external;

    function prepareNewVault(address _vault) external returns (bool);

    function executeNewVault() external returns (address);

    function executeNewMaxWithdrawalFee() external returns (uint256);

    function executeNewRequiredReserves() external returns (uint256);

    function executeNewReserveDeviation() external returns (uint256);

    function setLpToken(address _lpToken) external returns (bool);

    function setStaker() external returns (bool);

    function withdrawAll() external;

    function prepareNewRequiredReserves(uint256 _newRatio) external returns (bool);

    function resetRequiredReserves() external returns (bool);

    function prepareNewReserveDeviation(uint256 newRatio) external returns (bool);

    function resetNewReserveDeviation() external returns (bool);

    function prepareNewMinWithdrawalFee(uint256 newFee) external returns (bool);

    function executeNewMinWithdrawalFee() external returns (uint256);

    function resetNewMinWithdrawalFee() external returns (bool);

    function prepareNewMaxWithdrawalFee(uint256 newFee) external returns (bool);

    function resetNewMaxWithdrawalFee() external returns (bool);

    function prepareNewWithdrawalFeeDecreasePeriod(uint256 newPeriod) external returns (bool);

    function executeNewWithdrawalFeeDecreasePeriod() external returns (uint256);

    function resetNewWithdrawalFeeDecreasePeriod() external returns (bool);

    function resetNewVault() external returns (bool);

    function rebalanceVault() external;

    function getRequiredReserveRatio() external view returns (uint256);

    function getMaxReserveDeviationRatio() external view returns (uint256);

    function getMinWithdrawalFee() external view returns (uint256);

    function getMaxWithdrawalFee() external view returns (uint256);

    function getWithdrawalFeeDecreasePeriod() external view returns (uint256);

    function getNewCurrentFees(
        uint256 timeToWait,
        uint256 lastActionTimestamp,
        uint256 feeRatio
    ) external view returns (uint256);

    function getUnderlying() external view returns (address);

    function getLpToken() external view returns (address);

    function getWithdrawalFee(address account, uint256 amount) external view returns (uint256);

    function getVault() external view returns (IVault);

    function exchangeRate() external view returns (uint256);

    function totalUnderlying() external view returns (uint256);
}


// File interfaces/IGasBank.sol


interface IGasBank {
    event Deposit(address indexed account, uint256 value);
    event Withdraw(address indexed account, address indexed receiver, uint256 value);

    function depositFor(address account) external payable;

    function withdrawUnused(address account) external;

    function withdrawFrom(address account, uint256 amount) external;

    function withdrawFrom(
        address account,
        address payable to,
        uint256 amount
    ) external;

    function balanceOf(address account) external view returns (uint256);
}


// File interfaces/oracles/IOracleProvider.sol


interface IOracleProvider {
    /// @notice Quotes the USD price of `baseAsset`
    /// @param baseAsset the asset of which the price is to be quoted
    /// @return the USD price of the asset
    function getPriceUSD(address baseAsset) external view returns (uint256);

    /// @notice Quotes the ETH price of `baseAsset`
    /// @param baseAsset the asset of which the price is to be quoted
    /// @return the ETH price of the asset
    function getPriceETH(address baseAsset) external view returns (uint256);
}


// File libraries/AddressProviderMeta.sol


library AddressProviderMeta {
    struct Meta {
        bool freezable;
        bool frozen;
    }

    function fromUInt(uint256 value) internal pure returns (Meta memory) {
        Meta memory meta;
        meta.freezable = (value & 1) == 1;
        meta.frozen = ((value >> 1) & 1) == 1;
        return meta;
    }

    function toUInt(Meta memory meta) internal pure returns (uint256) {
        uint256 value;
        value |= meta.freezable ? 1 : 0;
        value |= meta.frozen ? 1 << 1 : 0;
        return value;
    }
}


// File interfaces/IAddressProvider.sol






// solhint-disable ordering

interface IAddressProvider is IPreparable {
    event KnownAddressKeyAdded(bytes32 indexed key);
    event StakerVaultListed(address indexed stakerVault);
    event StakerVaultDelisted(address indexed stakerVault);
    event ActionListed(address indexed action);
    event PoolListed(address indexed pool);
    event PoolDelisted(address indexed pool);
    event VaultUpdated(address indexed previousVault, address indexed newVault);
    event FeeHandlerAdded(address feeHandler);
    event FeeHandlerRemoved(address feeHandler);

    /** Key functions */
    function getKnownAddressKeys() external view returns (bytes32[] memory);

    function freezeAddress(bytes32 key) external;

    /** Pool functions */

    function allPools() external view returns (address[] memory);

    function addPool(address pool) external;

    function poolsCount() external view returns (uint256);

    function getPoolAtIndex(uint256 index) external view returns (address);

    function isPool(address pool) external view returns (bool);

    function removePool(address pool) external returns (bool);

    function getPoolForToken(address token) external view returns (ILiquidityPool);

    function safeGetPoolForToken(address token) external view returns (address);

    /** Vault functions  */

    function updateVault(address previousVault, address newVault) external;

    function allVaults() external view returns (address[] memory);

    function vaultsCount() external view returns (uint256);

    function getVaultAtIndex(uint256 index) external view returns (address);

    function isVault(address vault) external view returns (bool);

    /** Action functions */

    function allActions() external view returns (address[] memory);

    function addAction(address action) external returns (bool);

    function isAction(address action) external view returns (bool);

    /** Address functions */
    function initializeAddress(bytes32 key, address initialAddress) external;

    function initializeAddress(
        bytes32 key,
        address initialAddress,
        bool frezable
    ) external;

    function initializeAndFreezeAddress(bytes32 key, address initialAddress) external;

    function getAddress(bytes32 key) external view returns (address);

    function getAddress(bytes32 key, bool checkExists) external view returns (address);

    function getAddressMeta(bytes32 key) external view returns (AddressProviderMeta.Meta memory);

    function prepareAddress(bytes32 key, address newAddress) external returns (bool);

    function executeAddress(bytes32 key) external returns (address);

    function resetAddress(bytes32 key) external returns (bool);

    /** Staker vault functions */
    function allStakerVaults() external view returns (address[] memory);

    function tryGetStakerVault(address token) external view returns (bool, address);

    function getStakerVault(address token) external view returns (address);

    function addStakerVault(address stakerVault) external returns (bool);

    function isStakerVault(address stakerVault, address token) external view returns (bool);

    function isStakerVaultRegistered(address stakerVault) external view returns (bool);

    function isWhiteListedFeeHandler(address feeHandler) external view returns (bool);

    /** Fee Handler function */
    function addFeeHandler(address feeHandler) external returns (bool);

    function removeFeeHandler(address feeHandler) external returns (bool);
}


// File interfaces/tokenomics/IInflationManager.sol


interface IInflationManager {
    event KeeperGaugeListed(address indexed pool, address indexed keeperGauge);
    event AmmGaugeListed(address indexed token, address indexed ammGauge);
    event KeeperGaugeDelisted(address indexed pool, address indexed keeperGauge);
    event AmmGaugeDelisted(address indexed token, address indexed ammGauge);

    /** Pool functions */

    function setKeeperGauge(address pool, address _keeperGauge) external returns (bool);

    function setAmmGauge(address token, address _ammGauge) external returns (bool);

    function setMinter(address _minter) external returns (bool);

    function advanceKeeperGaugeEpoch(address pool) external returns (bool);

    function whitelistGauge(address gauge) external;

    function removeStakerVaultFromInflation(address stakerVault, address lpToken) external;

    function addStrategyToDepositStakerVault(address depositStakerVault, address strategyPool)
        external
        returns (bool);

    function removeAmmGauge(address token) external returns (bool);

    function addGaugeForVault(address lpToken) external returns (bool);

    function checkpointAllGauges() external returns (bool);

    function mintRewards(address beneficiary, uint256 amount) external;

    function getAllAmmGauges() external view returns (address[] memory);

    function getLpRateForStakerVault(address stakerVault) external view returns (uint256);

    function getKeeperRateForPool(address pool) external view returns (uint256);

    function getAmmRateForToken(address token) external view returns (uint256);

    function getKeeperWeightForPool(address pool) external view returns (uint256);

    function getAmmWeightForToken(address pool) external view returns (uint256);

    function getLpPoolWeight(address pool) external view returns (uint256);

    function getKeeperGaugeForPool(address pool) external view returns (address);

    function getAmmGaugeForToken(address token) external view returns (address);

    function isInflationWeightManager(address account) external view returns (bool);

    /** Weight setter functions **/

    function prepareLpPoolWeight(address lpToken, uint256 newPoolWeight) external returns (bool);

    function prepareAmmTokenWeight(address token, uint256 newTokenWeight) external returns (bool);

    function prepareKeeperPoolWeight(address pool, uint256 newPoolWeight) external returns (bool);

    function executeLpPoolWeight(address lpToken) external returns (uint256);

    function executeAmmTokenWeight(address token) external returns (uint256);

    function executeKeeperPoolWeight(address pool) external returns (uint256);

    function batchPrepareLpPoolWeights(address[] calldata lpTokens, uint256[] calldata weights)
        external
        returns (bool);

    function batchPrepareAmmTokenWeights(address[] calldata tokens, uint256[] calldata weights)
        external
        returns (bool);

    function batchPrepareKeeperPoolWeights(address[] calldata pools, uint256[] calldata weights)
        external
        returns (bool);

    function batchExecuteLpPoolWeights(address[] calldata lpTokens) external returns (bool);

    function batchExecuteAmmTokenWeights(address[] calldata tokens) external returns (bool);

    function batchExecuteKeeperPoolWeights(address[] calldata pools) external returns (bool);

    function deactivateWeightBasedKeeperDistribution() external returns (bool);
}


// File interfaces/IController.sol






// solhint-disable ordering

interface IController is IPreparable {
    function addressProvider() external view returns (IAddressProvider);

    function inflationManager() external view returns (IInflationManager);

    function addStakerVault(address stakerVault) external returns (bool);

    function removePool(address pool) external returns (bool);

    /** Keeper functions */
    function prepareKeeperRequiredStakedBKD(uint256 amount) external;

    function resetKeeperRequiredStakedBKD() external;

    function executeKeeperRequiredStakedBKD() external;

    function getKeeperRequiredStakedBKD() external view returns (uint256);

    function canKeeperExecuteAction(address keeper) external view returns (bool);

    /** Miscellaneous functions */

    function getTotalEthRequiredForGas(address payer) external view returns (uint256);
}


// File interfaces/tokenomics/IBkdToken.sol


interface IBkdToken is IERC20 {
    function mint(address account, uint256 amount) external;
}


// File interfaces/tokenomics/IMinter.sol


interface IMinter {
    function setToken(address _token) external;

    function startInflation() external;

    function executeInflationRateUpdate() external returns (bool);

    function mint(address beneficiary, uint256 amount) external returns (bool);

    function mintNonInflationTokens(address beneficiary, uint256 amount) external returns (bool);

    function getLpInflationRate() external view returns (uint256);

    function getKeeperInflationRate() external view returns (uint256);

    function getAmmInflationRate() external view returns (uint256);
}


// File libraries/Errors.sol


// solhint-disable private-vars-leading-underscore

library Error {
    string internal constant ADDRESS_WHITELISTED = "address already whitelisted";
    string internal constant ADMIN_ALREADY_SET = "admin has already been set once";
    string internal constant ADDRESS_NOT_WHITELISTED = "address not whitelisted";
    string internal constant ADDRESS_NOT_FOUND = "address not found";
    string internal constant CONTRACT_INITIALIZED = "contract can only be initialized once";
    string internal constant CONTRACT_PAUSED = "contract is paused";
    string internal constant UNAUTHORIZED_PAUSE = "not authorized to pause";
    string internal constant INVALID_AMOUNT = "invalid amount";
    string internal constant INVALID_INDEX = "invalid index";
    string internal constant INVALID_VALUE = "invalid msg.value";
    string internal constant INVALID_SENDER = "invalid msg.sender";
    string internal constant INVALID_TOKEN = "token address does not match pool's LP token address";
    string internal constant INVALID_DECIMALS = "incorrect number of decimals";
    string internal constant INVALID_ARGUMENT = "invalid argument";
    string internal constant INVALID_PARAMETER_VALUE = "invalid parameter value attempted";
    string internal constant INVALID_IMPLEMENTATION = "invalid pool implementation for given coin";
    string internal constant INVALID_POOL_IMPLEMENTATION =
        "invalid pool implementation for given coin";
    string internal constant INVALID_LP_TOKEN_IMPLEMENTATION =
        "invalid LP Token implementation for given coin";
    string internal constant INVALID_VAULT_IMPLEMENTATION =
        "invalid vault implementation for given coin";
    string internal constant INVALID_STAKER_VAULT_IMPLEMENTATION =
        "invalid stakerVault implementation for given coin";
    string internal constant INSUFFICIENT_ALLOWANCE = "insufficient allowance";
    string internal constant INSUFFICIENT_BALANCE = "insufficient balance";
    string internal constant INSUFFICIENT_AMOUNT_OUT = "Amount received less than min amount";
    string internal constant INSUFFICIENT_AMOUNT_IN = "Amount spent more than max amount";
    string internal constant ADDRESS_ALREADY_SET = "Address is already set";
    string internal constant INSUFFICIENT_STRATEGY_BALANCE = "insufficient strategy balance";
    string internal constant INSUFFICIENT_FUNDS_RECEIVED = "insufficient funds received";
    string internal constant ADDRESS_DOES_NOT_EXIST = "address does not exist";
    string internal constant ADDRESS_FROZEN = "address is frozen";
    string internal constant ROLE_EXISTS = "role already exists";
    string internal constant CANNOT_REVOKE_ROLE = "cannot revoke role";
    string internal constant UNAUTHORIZED_ACCESS = "unauthorized access";
    string internal constant SAME_ADDRESS_NOT_ALLOWED = "same address not allowed";
    string internal constant SELF_TRANSFER_NOT_ALLOWED = "self-transfer not allowed";
    string internal constant ZERO_ADDRESS_NOT_ALLOWED = "zero address not allowed";
    string internal constant ZERO_TRANSFER_NOT_ALLOWED = "zero transfer not allowed";
    string internal constant THRESHOLD_TOO_HIGH = "threshold is too high, must be under 10";
    string internal constant INSUFFICIENT_THRESHOLD = "insufficient threshold";
    string internal constant NO_POSITION_EXISTS = "no position exists";
    string internal constant POSITION_ALREADY_EXISTS = "position already exists";
    string internal constant CANNOT_EXECUTE_IN_SAME_BLOCK = "cannot execute action in same block";
    string internal constant PROTOCOL_NOT_FOUND = "protocol not found";
    string internal constant TOP_UP_FAILED = "top up failed";
    string internal constant SWAP_PATH_NOT_FOUND = "swap path not found";
    string internal constant UNDERLYING_NOT_SUPPORTED = "underlying token not supported";
    string internal constant NOT_ENOUGH_FUNDS_WITHDRAWN =
        "not enough funds were withdrawn from the pool";
    string internal constant FAILED_TRANSFER = "transfer failed";
    string internal constant FAILED_MINT = "mint failed";
    string internal constant FAILED_REPAY_BORROW = "repay borrow failed";
    string internal constant FAILED_METHOD_CALL = "method call failed";
    string internal constant NOTHING_TO_CLAIM = "there is no claimable balance";
    string internal constant ERC20_BALANCE_EXCEEDED = "ERC20: transfer amount exceeds balance";
    string internal constant INVALID_MINTER =
        "the minter address of the LP token and the pool address do not match";
    string internal constant STAKER_VAULT_EXISTS = "a staker vault already exists for the token";
    string internal constant DEADLINE_NOT_ZERO = "deadline must be 0";
    string internal constant NOTHING_PENDING = "no pending change to reset";
    string internal constant DEADLINE_NOT_SET = "deadline is 0";
    string internal constant DEADLINE_NOT_REACHED = "deadline has not been reached yet";
    string internal constant DELAY_TOO_SHORT = "delay be at least 3 days";
    string internal constant INSUFFICIENT_UPDATE_BALANCE =
        "insufficient funds for updating the position";
    string internal constant SAME_AS_CURRENT = "value must be different to existing value";
    string internal constant NOT_CAPPED = "the pool is not currently capped";
    string internal constant ALREADY_CAPPED = "the pool is already capped";
    string internal constant EXCEEDS_DEPOSIT_CAP = "deposit exceeds deposit cap";
    string internal constant VALUE_TOO_LOW_FOR_GAS = "value too low to cover gas";
    string internal constant NOT_ENOUGH_FUNDS = "not enough funds to withdraw";
    string internal constant ESTIMATED_GAS_TOO_HIGH = "too much ETH will be used for gas";
    string internal constant INVALID_TARGET = "Invalid Target";
    string internal constant DEPOSIT_FAILED = "deposit failed";
    string internal constant GAS_TOO_HIGH = "too much ETH used for gas";
    string internal constant GAS_BANK_BALANCE_TOO_LOW = "not enough ETH in gas bank to cover gas";
    string internal constant INVALID_TOKEN_TO_ADD = "Invalid token to add";
    string internal constant INVALID_TOKEN_TO_REMOVE = "token can not be removed";
    string internal constant TIME_DELAY_NOT_EXPIRED = "time delay not expired yet";
    string internal constant UNDERLYING_NOT_WITHDRAWABLE =
        "pool does not support additional underlying coins to be withdrawn";
    string internal constant STRATEGY_SHUT_DOWN = "Strategy is shut down";
    string internal constant STRATEGY_DOES_NOT_EXIST = "Strategy does not exist";
    string internal constant UNSUPPORTED_UNDERLYING = "Underlying not supported";
    string internal constant NO_DEX_SET = "no dex has been set for token";
    string internal constant INVALID_TOKEN_PAIR = "invalid token pair";
    string internal constant TOKEN_NOT_USABLE = "token not usable for the specific action";
    string internal constant ADDRESS_NOT_ACTION = "address is not registered action";
    string internal constant INVALID_SLIPPAGE_TOLERANCE = "Invalid slippage tolerance";
    string internal constant INVALID_MAX_FEE = "invalid max fee";
    string internal constant POOL_NOT_PAUSED = "Pool must be paused to withdraw from reserve";
    string internal constant INTERACTION_LIMIT = "Max of one deposit and withdraw per block";
    string internal constant GAUGE_EXISTS = "Gauge already exists";
    string internal constant GAUGE_DOES_NOT_EXIST = "Gauge does not exist";
    string internal constant EXCEEDS_MAX_BOOST = "Not allowed to exceed maximum boost on Convex";
    string internal constant PREPARED_WITHDRAWAL =
        "Cannot relock funds when withdrawal is being prepared";
    string internal constant ASSET_NOT_SUPPORTED = "Asset not supported";
    string internal constant STALE_PRICE = "Price is stale";
    string internal constant NEGATIVE_PRICE = "Price is negative";
    string internal constant ROUND_NOT_COMPLETE = "Round not complete";
    string internal constant NOT_ENOUGH_BKD_STAKED = "Not enough BKD tokens staked";
    string internal constant RESERVE_ACCESS_EXCEEDED = "Reserve access exceeded";
}


// File libraries/ScaledMath.sol


/*
 * @dev To use functions of this contract, at least one of the numbers must
 * be scaled to `DECIMAL_SCALE`. The result will scaled to `DECIMAL_SCALE`
 * if both numbers are scaled to `DECIMAL_SCALE`, otherwise to the scale
 * of the number not scaled by `DECIMAL_SCALE`
 */
library ScaledMath {
    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant DECIMAL_SCALE = 1e18;
    // solhint-disable-next-line private-vars-leading-underscore
    uint256 internal constant ONE = 1e18;

    /**
     * @notice Performs a multiplication between two scaled numbers
     */
    function scaledMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b) / DECIMAL_SCALE;
    }

    /**
     * @notice Performs a division between two scaled numbers
     */
    function scaledDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * DECIMAL_SCALE) / b;
    }

    /**
     * @notice Performs a division between two numbers, rounding up the result
     */
    function scaledDivRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * DECIMAL_SCALE + b - 1) / b;
    }

    /**
     * @notice Performs a division between two numbers, ignoring any scaling and rounding up the result
     */
    function divRoundUp(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a + b - 1) / b;
    }
}


// File interfaces/IVaultReserve.sol


interface IVaultReserve {
    event Deposit(address indexed vault, address indexed token, uint256 amount);
    event Withdraw(address indexed vault, address indexed token, uint256 amount);
    event VaultListed(address indexed vault);

    function deposit(address token, uint256 amount) external payable returns (bool);

    function withdraw(address token, uint256 amount) external returns (bool);

    function getBalance(address vault, address token) external view returns (uint256);

    function canWithdraw(address vault) external view returns (bool);
}


// File interfaces/IRoleManager.sol


interface IRoleManager {
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function grantRole(bytes32 role, address account) external;

    function addGovernor(address newGovernor) external;

    function renounceGovernance() external;

    function addGaugeZap(address zap) external;

    function removeGaugeZap(address zap) external;

    function revokeRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account) external view returns (bool);

    function hasAnyRole(bytes32[] memory roles, address account) external view returns (bool);

    function hasAnyRole(
        bytes32 role1,
        bytes32 role2,
        address account
    ) external view returns (bool);

    function hasAnyRole(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3,
        address account
    ) external view returns (bool);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
}


// File interfaces/IFeeBurner.sol


interface IFeeBurner {
    function burnToTarget(address[] memory tokens, address targetLpToken)
        external
        payable
        returns (uint256);
}


// File interfaces/ISwapperRouter.sol


interface ISwapperRouter {
    function swapAll(address fromToken, address toToken) external payable returns (uint256);

    function setSlippageTolerance(uint256 slippageTolerance_) external;

    function setCurvePool(address token_, address curvePool_) external;

    function swap(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) external payable returns (uint256);

    function getAmountOut(
        address fromToken,
        address toToken,
        uint256 amountIn
    ) external view returns (uint256 amountOut);
}


// File libraries/AddressProviderKeys.sol


library AddressProviderKeys {
    bytes32 internal constant _TREASURY_KEY = "treasury";
    bytes32 internal constant _REWARD_HANDLER_KEY = "rewardHandler";
    bytes32 internal constant _GAS_BANK_KEY = "gasBank";
    bytes32 internal constant _VAULT_RESERVE_KEY = "vaultReserve";
    bytes32 internal constant _ORACLE_PROVIDER_KEY = "oracleProvider";
    bytes32 internal constant _POOL_FACTORY_KEY = "poolFactory";
    bytes32 internal constant _CONTROLLER_KEY = "controller";
    bytes32 internal constant _BKD_LOCKER_KEY = "bkdLocker";
    bytes32 internal constant _FEE_BURNER_KEY = "feeBurner";
    bytes32 internal constant _ROLE_MANAGER_KEY = "roleManager";
    bytes32 internal constant _SWAPPER_ROUTER_KEY = "swapperRouter";
}


// File libraries/AddressProviderHelpers.sol










library AddressProviderHelpers {
    /**
     * @return The address of the treasury.
     */
    function getTreasury(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._TREASURY_KEY);
    }

    /**
     * @return The address of the reward handler.
     */
    function getRewardHandler(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._REWARD_HANDLER_KEY);
    }

    /**
     * @dev Returns zero address if no reward handler is set.
     * @return The address of the reward handler.
     */
    function getSafeRewardHandler(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._REWARD_HANDLER_KEY, false);
    }

    /**
     * @return The address of the fee burner.
     */
    function getFeeBurner(IAddressProvider provider) internal view returns (IFeeBurner) {
        return IFeeBurner(provider.getAddress(AddressProviderKeys._FEE_BURNER_KEY));
    }

    /**
     * @return The gas bank.
     */
    function getGasBank(IAddressProvider provider) internal view returns (IGasBank) {
        return IGasBank(provider.getAddress(AddressProviderKeys._GAS_BANK_KEY));
    }

    /**
     * @return The address of the vault reserve.
     */
    function getVaultReserve(IAddressProvider provider) internal view returns (IVaultReserve) {
        return IVaultReserve(provider.getAddress(AddressProviderKeys._VAULT_RESERVE_KEY));
    }

    /**
     * @return The oracleProvider.
     */
    function getOracleProvider(IAddressProvider provider) internal view returns (IOracleProvider) {
        return IOracleProvider(provider.getAddress(AddressProviderKeys._ORACLE_PROVIDER_KEY));
    }

    /**
     * @return the address of the BKD locker
     */
    function getBKDLocker(IAddressProvider provider) internal view returns (address) {
        return provider.getAddress(AddressProviderKeys._BKD_LOCKER_KEY);
    }

    /**
     * @return the address of the BKD locker
     */
    function getRoleManager(IAddressProvider provider) internal view returns (IRoleManager) {
        return IRoleManager(provider.getAddress(AddressProviderKeys._ROLE_MANAGER_KEY));
    }

    /**
     * @return the controller
     */
    function getController(IAddressProvider provider) internal view returns (IController) {
        return IController(provider.getAddress(AddressProviderKeys._CONTROLLER_KEY));
    }

    /**
     * @return the swapper router
     */
    function getSwapperRouter(IAddressProvider provider) internal view returns (ISwapperRouter) {
        return ISwapperRouter(provider.getAddress(AddressProviderKeys._SWAPPER_ROUTER_KEY));
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.5.0

// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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


// File @openzeppelin/contracts/utils/Context.sol@v4.5.0

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


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.5.0

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/tokenomics/BkdToken.sol



contract BkdToken is IBkdToken, ERC20 {
    using ScaledMath for uint256;

    address public immutable minter;

    constructor(
        string memory name_,
        string memory symbol_,
        address _minter
    ) ERC20(name_, symbol_) {
        minter = _minter;
    }

    /**
     * @notice Mints tokens for a given address.
     * @dev Fails if msg.sender is not the minter.
     * @param account Account for which tokens should be minted.
     * @param amount Amount of tokens to mint.
     */
    function mint(address account, uint256 amount) external override {
        require(msg.sender == minter, Error.UNAUTHORIZED_ACCESS);
        _mint(account, amount);
    }
}


// File libraries/Roles.sol


// solhint-disable private-vars-leading-underscore

library Roles {
    bytes32 internal constant GOVERNANCE = "governance";
    bytes32 internal constant ADDRESS_PROVIDER = "address_provider";
    bytes32 internal constant POOL_FACTORY = "pool_factory";
    bytes32 internal constant CONTROLLER = "controller";
    bytes32 internal constant GAUGE_ZAP = "gauge_zap";
    bytes32 internal constant MAINTENANCE = "maintenance";
    bytes32 internal constant INFLATION_MANAGER = "inflation_manager";
    bytes32 internal constant POOL = "pool";
    bytes32 internal constant VAULT = "vault";
}


// File contracts/access/AuthorizationBase.sol



/**
 * @notice Provides modifiers for authorization
 */
abstract contract AuthorizationBase {
    /**
     * @notice Only allows a sender with `role` to perform the given action
     */
    modifier onlyRole(bytes32 role) {
        require(_roleManager().hasRole(role, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    /**
     * @notice Only allows a sender with GOVERNANCE role to perform the given action
     */
    modifier onlyGovernance() {
        require(_roleManager().hasRole(Roles.GOVERNANCE, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    /**
     * @notice Only allows a sender with any of `roles` to perform the given action
     */
    modifier onlyRoles2(bytes32 role1, bytes32 role2) {
        require(_roleManager().hasAnyRole(role1, role2, msg.sender), Error.UNAUTHORIZED_ACCESS);
        _;
    }

    /**
     * @notice Only allows a sender with any of `roles` to perform the given action
     */
    modifier onlyRoles3(
        bytes32 role1,
        bytes32 role2,
        bytes32 role3
    ) {
        require(
            _roleManager().hasAnyRole(role1, role2, role3, msg.sender),
            Error.UNAUTHORIZED_ACCESS
        );
        _;
    }

    function roleManager() external view virtual returns (IRoleManager) {
        return _roleManager();
    }

    function _roleManager() internal view virtual returns (IRoleManager);
}


// File contracts/access/Authorization.sol


contract Authorization is AuthorizationBase {
    IRoleManager internal immutable __roleManager;

    constructor(IRoleManager roleManager) {
        __roleManager = roleManager;
    }

    function _roleManager() internal view override returns (IRoleManager) {
        return __roleManager;
    }
}


// File contracts/tokenomics/Minter.sol








contract Minter is IMinter, Authorization, ReentrancyGuard {
    using ScaledMath for uint256;
    using AddressProviderHelpers for IAddressProvider;

    uint256 private constant _INFLATION_DECAY_PERIOD = 365 days;

    // Lp Rates
    uint256 public immutable initialAnnualInflationRateLp;
    uint256 public immutable annualInflationDecayLp;
    uint256 public currentInflationAmountLp;

    // Keeper Rates
    uint256 public immutable initialPeriodKeeperInflation;
    uint256 public immutable initialAnnualInflationRateKeeper;
    uint256 public immutable annualInflationDecayKeeper;
    uint256 public currentInflationAmountKeeper;

    // AMM Rates
    uint256 public immutable initialPeriodAmmInflation;
    uint256 public immutable initialAnnualInflationRateAmm;
    uint256 public immutable annualInflationDecayAmm;
    uint256 public currentInflationAmountAmm;

    bool public initialPeriodEnded;

    // Non-inflation rates
    uint256 public immutable nonInflationDistribution;
    uint256 public issuedNonInflationSupply;

    uint256 public lastInflationDecay;
    uint256 public currentTotalInflation;

    // Used for final safety check to ensure inflation is not exceeded
    uint256 public totalAvailableToNow;
    uint256 public totalMintedToNow;
    uint256 public lastEvent;

    IController public immutable controller;
    BkdToken public token;

    event TokensMinted(address beneficiary, uint256 amount);

    constructor(
        uint256 _annualInflationRateLp,
        uint256 _annualInflationRateKeeper,
        uint256 _annualInflationRateAmm,
        uint256 _annualInflationDecayLp,
        uint256 _annualInflationDecayKeeper,
        uint256 _annualInflationDecayAmm,
        uint256 _initialPeriodKeeperInflation,
        uint256 _initialPeriodAmmInflation,
        uint256 _nonInflationDistribution,
        IController _controller
    ) Authorization(_controller.addressProvider().getRoleManager()) {
        require(_annualInflationDecayLp < ScaledMath.ONE, Error.INVALID_PARAMETER_VALUE);
        require(_annualInflationDecayKeeper < ScaledMath.ONE, Error.INVALID_PARAMETER_VALUE);
        require(_annualInflationDecayAmm < ScaledMath.ONE, Error.INVALID_PARAMETER_VALUE);
        initialAnnualInflationRateLp = _annualInflationRateLp;
        initialAnnualInflationRateKeeper = _annualInflationRateKeeper;
        initialAnnualInflationRateAmm = _annualInflationRateAmm;

        annualInflationDecayLp = _annualInflationDecayLp;
        annualInflationDecayKeeper = _annualInflationDecayKeeper;
        annualInflationDecayAmm = _annualInflationDecayAmm;

        initialPeriodKeeperInflation = _initialPeriodKeeperInflation;
        initialPeriodAmmInflation = _initialPeriodAmmInflation;

        currentInflationAmountLp = _annualInflationRateLp / _INFLATION_DECAY_PERIOD;
        currentInflationAmountKeeper = _initialPeriodKeeperInflation / _INFLATION_DECAY_PERIOD;
        currentInflationAmountAmm = _initialPeriodAmmInflation / _INFLATION_DECAY_PERIOD;

        currentTotalInflation =
            currentInflationAmountLp +
            currentInflationAmountKeeper +
            currentInflationAmountAmm;

        nonInflationDistribution = _nonInflationDistribution;
        controller = _controller;
    }

    function setToken(address _token) external override onlyGovernance {
        require(address(token) == address(0), "Token already set!");
        token = BkdToken(_token);
    }

    function startInflation() external override onlyGovernance {
        require(lastEvent == 0, "Inflation has already started.");
        lastEvent = block.timestamp;
        lastInflationDecay = block.timestamp;
    }

    /**
     * @notice Update the inflation rate according to the piecewise linear schedule.
     * @dev This updates the inflation rate to the next linear segment in the inflations schedule.
     * @return `true` if successful.
     */
    function executeInflationRateUpdate() external override returns (bool) {
        return _executeInflationRateUpdate();
    }

    /**
     * @notice Mints BKD tokens to a specified address.
     * @dev Can only be called by the controller.
     * @param beneficiary Address to mint tokens for.
     * @param amount Amount of tokens to mint.
     * @return `true` if successful.
     */
    function mint(address beneficiary, uint256 amount)
        external
        override
        nonReentrant
        returns (bool)
    {
        require(msg.sender == address(controller.inflationManager()), Error.UNAUTHORIZED_ACCESS);
        if (lastEvent == 0) return false;
        return _mint(beneficiary, amount);
    }

    /**
     * @notice Mint tokens that are not part of the inflation schedule.
     * @dev The amount of tokens that can be minted in total is subject to a pre-set upper limit.
     * @param beneficiary Address to mint tokens for.
     * @param amount Amount of tokens to mint.
     * @return `true` if successful.
     */
    function mintNonInflationTokens(address beneficiary, uint256 amount)
        external
        override
        onlyGovernance
        returns (bool)
    {
        require(
            issuedNonInflationSupply + amount <= nonInflationDistribution,
            "Maximum non-inflation amount exceeded."
        );
        issuedNonInflationSupply += amount;
        token.mint(beneficiary, amount);
        emit TokensMinted(beneficiary, amount);
        return true;
    }

    /**
     * @notice Supplies the inflation rate for LPs per unit of time (seconds).
     * @return LP inflation rate.
     */
    function getLpInflationRate() external view override returns (uint256) {
        if (lastEvent == 0) return 0;
        return currentInflationAmountLp;
    }

    /**
     * @notice Supplies the inflation rate for keepers per unit of time (seconds).
     * @return keeper inflation rate.
     */
    function getKeeperInflationRate() external view override returns (uint256) {
        if (lastEvent == 0) return 0;
        return currentInflationAmountKeeper;
    }

    /**
     * @notice Supplies the inflation rate for LPs on AMMs per unit of time (seconds).
     * @return AMM inflation rate.
     */
    function getAmmInflationRate() external view override returns (uint256) {
        if (lastEvent == 0) return 0;
        return currentInflationAmountAmm;
    }

    function _executeInflationRateUpdate() internal returns (bool) {
        totalAvailableToNow += (currentTotalInflation * (block.timestamp - lastEvent));
        lastEvent = block.timestamp;
        if (block.timestamp >= lastInflationDecay + _INFLATION_DECAY_PERIOD) {
            currentInflationAmountLp = currentInflationAmountLp.scaledMul(annualInflationDecayLp);
            if (initialPeriodEnded) {
                currentInflationAmountKeeper = currentInflationAmountKeeper.scaledMul(
                    annualInflationDecayKeeper
                );
                currentInflationAmountAmm = currentInflationAmountAmm.scaledMul(
                    annualInflationDecayAmm
                );
            } else {
                currentInflationAmountKeeper =
                    initialAnnualInflationRateKeeper /
                    _INFLATION_DECAY_PERIOD;

                currentInflationAmountAmm = initialAnnualInflationRateAmm / _INFLATION_DECAY_PERIOD;
                initialPeriodEnded = true;
            }
            currentTotalInflation =
                currentInflationAmountLp +
                currentInflationAmountKeeper +
                currentInflationAmountAmm;
            controller.inflationManager().checkpointAllGauges();
            lastInflationDecay = block.timestamp;
        }
        return true;
    }

    function _mint(address beneficiary, uint256 amount) internal returns (bool) {
        totalAvailableToNow += ((block.timestamp - lastEvent) * currentTotalInflation);
        uint256 newTotalMintedToNow = totalMintedToNow + amount;
        require(newTotalMintedToNow <= totalAvailableToNow, "Mintable amount exceeded");
        totalMintedToNow = newTotalMintedToNow;
        lastEvent = block.timestamp;
        token.mint(beneficiary, amount);
        _executeInflationRateUpdate();
        emit TokensMinted(beneficiary, amount);
        return true;
    }
}
