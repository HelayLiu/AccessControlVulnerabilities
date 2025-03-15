// SPDX-License-Identifier: BUSL 1.1
pragma solidity 0.8.22;

// lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
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

// lib/openzeppelin-contracts/contracts/utils/Context.sol

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

// src/dao/interfaces/IDAOConfig.sol

interface IDAOConfig
	{
	function changeBootstrappingRewards(bool increase) external; // onlyOwner
	function changePercentPolRewardsBurned(bool increase) external; // onlyOwner
	function changeBaseBallotQuorumPercent(bool increase) external; // onlyOwner
	function changeBallotDuration(bool increase) external; // onlyOwner
	function changeRequiredProposalPercentStake(bool increase) external; // onlyOwner
	function changeMaxPendingTokensForWhitelisting(bool increase) external; // onlyOwner
	function changeArbitrageProfitsPercentPOL(bool increase) external; // onlyOwner
	function changeUpkeepRewardPercent(bool increase) external; // onlyOwner

	// Views
    function bootstrappingRewards() external view returns (uint256);
    function percentPolRewardsBurned() external view returns (uint256);
    function baseBallotQuorumPercentTimes1000() external view returns (uint256);
    function ballotMinimumDuration() external view returns (uint256);
    function requiredProposalPercentStakeTimes1000() external view returns (uint256);
    function maxPendingTokensForWhitelisting() external view returns (uint256);
    function arbitrageProfitsPercentPOL() external view returns (uint256);
    function upkeepRewardPercent() external view returns (uint256);
	}

// src/interfaces/IAccessManager.sol

interface IAccessManager
	{
	function excludedCountriesUpdated() external;
	function grantAccess(bytes calldata signature) external;

	// Views
	function geoVersion() external view returns (uint256);
	function walletHasAccess(address wallet) external view returns (bool);
	}

// src/interfaces/IManagedWallet.sol

interface IManagedWallet
	{
	function proposeWallets( address _proposedMainWallet, address _proposedConfirmationWallet ) external;
	function changeWallets() external;

	// Views
	function mainWallet() external view returns (address wallet);
	function confirmationWallet() external view returns (address wallet);
	function proposedMainWallet() external view returns (address wallet);
	function proposedConfirmationWallet() external view returns (address wallet);
    function activeTimelock() external view returns (uint256);
	}

// src/interfaces/IUpkeep.sol

interface IUpkeep
	{
	function performUpkeep() external;

	// Views
	function currentRewardsForCallingPerformUpkeep() external view returns (uint256);
	function lastUpkeepTimeEmissions() external view returns (uint256);
	function lastUpkeepTimeRewardsEmitters() external view returns (uint256);
	}

// src/launch/interfaces/IAirdrop.sol

interface IAirdrop
	{
	function authorizeWallet( address wallet ) external;
	function allowClaiming() external;
	function claimAirdrop() external;

	// Views
	function saltAmountForEachUser() external view returns (uint256);
	function claimingAllowed() external view returns (bool);
	function claimed(address wallet) external view returns (bool);

	function isAuthorized(address wallet) external view returns (bool);
	function numberAuthorized() external view returns (uint256);
	}

// src/launch/interfaces/IBootstrapBallot.sol

interface IBootstrapBallot
	{
	function vote( bool voteStartExchangeYes, bytes memory signature  ) external;
	function finalizeBallot() external;

	// Views
	function completionTimestamp() external view returns (uint256);
	function hasVoted(address user) external view returns (bool);

	function ballotFinalized() external view returns (bool);

	function startExchangeYes() external view returns (uint256);
	function startExchangeNo() external view returns (uint256);
	}

// src/pools/interfaces/IPoolStats.sol

interface IPoolStats
	{
	// These are the indicies (in terms of a poolIDs location in the current whitelistedPoolIDs array) of pools involved in an arbitrage path
	struct ArbitrageIndicies
		{
		uint64 index1;
		uint64 index2;
		uint64 index3;
		}

	function clearProfitsForPools() external;
	function updateArbitrageIndicies() external;

	// Views
	function profitsForWhitelistedPools() external view returns (uint256[] memory _calculatedProfits);
	function arbitrageIndicies(bytes32 poolID) external view returns (ArbitrageIndicies memory);
	}

// src/price_feed/interfaces/IPriceFeed.sol

interface IPriceFeed
	{
	// USD prices for BTC and ETH with 18 decimals
	function getPriceBTC() external view returns (uint256);
	function getPriceETH() external view returns (uint256);
	}

// src/rewards/interfaces/IEmissions.sol

interface IEmissions
	{
	function performUpkeep( uint256 timeSinceLastUpkeep ) external;
    }

// src/stable/interfaces/IStableConfig.sol

interface IStableConfig
	{
	function changeRewardPercentForCallingLiquidation(bool increase) external; // onlyOwner
	function changeMaxRewardValueForCallingLiquidation(bool increase) external; // onlyOwner
	function changeMinimumCollateralValueForBorrowing(bool increase) external; // onlyOwner
	function changeInitialCollateralRatioPercent(bool increase) external; // onlyOwner
	function changeMinimumCollateralRatioPercent(bool increase) external; // onlyOwner
	function changePercentArbitrageProfitsForStablePOL(bool increase) external; // onlyOwner

	// Views
    function rewardPercentForCallingLiquidation() external view returns (uint256);
    function maxRewardValueForCallingLiquidation() external view returns (uint256);
    function minimumCollateralValueForBorrowing() external view returns (uint256);
	function initialCollateralRatioPercent() external view returns (uint256);
	function minimumCollateralRatioPercent() external view returns (uint256);
	function percentArbitrageProfitsForStablePOL() external view returns (uint256);
	}

// src/staking/interfaces/IStakingRewards.sol

struct AddedReward
	{
	bytes32 poolID;							// The pool to add rewards to
	uint256 amountToAdd;				// The amount of rewards (as SALT) to add
	}

struct UserShareInfo
	{
	uint128 userShare;					// A user's share for a given poolID
	uint128 virtualRewards;				// The amount of rewards that were added to maintain proper rewards/share ratio - and will be deducted from a user's pending rewards.
	uint256 cooldownExpiration;		// The timestamp when the user can modify their share
	}

interface IStakingRewards
	{
	function claimAllRewards( bytes32[] calldata poolIDs ) external returns (uint256 rewardsAmount);
	function addSALTRewards( AddedReward[] calldata addedRewards ) external;

	// Views
	function totalShares(bytes32 poolID) external view returns (uint256);
	function totalSharesForPools( bytes32[] calldata poolIDs ) external view returns (uint256[] calldata shares);
	function totalRewardsForPools( bytes32[] calldata poolIDs ) external view returns (uint256[] calldata rewards);

	function userRewardForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userShareForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userVirtualRewardsForPool( address wallet, bytes32 poolID ) external view returns (uint256);

	function userRewardsForPools( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata rewards);
	function userShareForPools( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata shares);
	function userCooldowns( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata cooldowns);
	}

// src/interfaces/ISalt.sol

interface ISalt is IERC20
	{
	function burnTokensInContract() external;

	// Views
	function totalBurned() external view returns (uint256);
	}

// src/launch/interfaces/IInitialDistribution.sol

interface IInitialDistribution
	{
	function distributionApproved() external;

	// Views
	function bootstrapBallot() external view returns (IBootstrapBallot);
	}

// src/price_feed/interfaces/IPriceAggregator.sol

interface IPriceAggregator
	{
	function setInitialFeeds( IPriceFeed _priceFeed1, IPriceFeed _priceFeed2, IPriceFeed _priceFeed3 ) external;
	function setPriceFeed( uint256 priceFeedNum, IPriceFeed newPriceFeed ) external; // onlyOwner
	function changeMaximumPriceFeedPercentDifferenceTimes1000(bool increase) external; // onlyOwner
	function changePriceFeedModificationCooldown(bool increase) external; // onlyOwner

	// Views
	function maximumPriceFeedPercentDifferenceTimes1000() external view returns (uint256);
	function priceFeedModificationCooldown() external view returns (uint256);

	function priceFeed1() external view returns (IPriceFeed);
	function priceFeed2() external view returns (IPriceFeed);
	function priceFeed3() external view returns (IPriceFeed);
	function getPriceBTC() external view returns (uint256);
	function getPriceETH() external view returns (uint256);
	}

// src/rewards/interfaces/IRewardsEmitter.sol

interface IRewardsEmitter
	{
	function addSALTRewards( AddedReward[] calldata addedRewards ) external;
	function performUpkeep( uint256 timeSinceLastUpkeep ) external;

	// Views
	function pendingRewardsForPools( bytes32[] calldata pools ) external view returns (uint256[] calldata);
	}

// src/rewards/interfaces/ISaltRewards.sol

interface ISaltRewards
	{
	function sendInitialSaltRewards( uint256 liquidityBootstrapAmount, bytes32[] calldata poolIDs ) external;
    function performUpkeep( bytes32[] calldata poolIDs, uint256[] calldata profitsForPools ) external;

    // Views
    function stakingRewardsEmitter() external view returns (IRewardsEmitter);
    function liquidityRewardsEmitter() external view returns (IRewardsEmitter);
    }

// src/staking/interfaces/ILiquidity.sol

interface ILiquidity is IStakingRewards
	{
	function depositLiquidityAndIncreaseShare( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minLiquidityReceived, uint256 deadline, bool useZapping ) external returns (uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity);
	function withdrawLiquidityAndClaim( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToWithdraw, uint256 minReclaimedA, uint256 minReclaimedB, uint256 deadline ) external returns (uint256 reclaimedA, uint256 reclaimedB);
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

// lib/openzeppelin-contracts/contracts/finance/VestingWallet.sol

// OpenZeppelin Contracts (last updated v4.9.0) (finance/VestingWallet.sol)

/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */
contract VestingWallet is Context {
    event EtherReleased(uint256 amount);
    event ERC20Released(address indexed token, uint256 amount);

    uint256 private _released;
    mapping(address => uint256) private _erc20Released;
    address private immutable _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(address beneficiaryAddress, uint64 startTimestamp, uint64 durationSeconds) payable {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

    /**
     * @dev Getter for the beneficiary address.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Getter for the start timestamp.
     */
    function start() public view virtual returns (uint256) {
        return _start;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /**
     * @dev Amount of eth already released
     */
    function released() public view virtual returns (uint256) {
        return _released;
    }

    /**
     * @dev Amount of token already released
     */
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }

    /**
     * @dev Getter for the amount of releasable eth.
     */
    function releasable() public view virtual returns (uint256) {
        return vestedAmount(uint64(block.timestamp)) - released();
    }

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(address token) public view virtual returns (uint256) {
        return vestedAmount(token, uint64(block.timestamp)) - released(token);
    }

    /**
     * @dev Release the native token (ether) that have already vested.
     *
     * Emits a {EtherReleased} event.
     */
    function release() public virtual {
        uint256 amount = releasable();
        _released += amount;
        emit EtherReleased(amount);
        Address.sendValue(payable(beneficiary()), amount);
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release(address token) public virtual {
        uint256 amount = releasable(token);
        _erc20Released[token] += amount;
        emit ERC20Released(token, amount);
        SafeERC20.safeTransfer(IERC20(token), beneficiary(), amount);
    }

    /**
     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(address(this).balance + released(), timestamp);
    }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}

// src/dao/interfaces/IDAO.sol

interface IDAO
	{
	function finalizeBallot( uint256 ballotID ) external;

	function withdrawArbitrageProfits( IERC20 weth ) external returns (uint256 withdrawnAmount);
	function formPOL( IERC20 tokenA, IERC20 tokenB, uint256 amountA, uint256 amountB ) external;
	function processRewardsFromPOL() external;
	function withdrawPOL( IERC20 tokenA, IERC20 tokenB, uint256 percentToLiquidate ) external;

	// Views
	function pools() external view returns (IPools);
	function websiteURL() external view returns (string memory);
	function countryIsExcluded( string calldata country ) external view returns (bool);
	}

// src/interfaces/IExchangeConfig.sol

interface IExchangeConfig
	{
	function setContracts( IDAO _dao, IUpkeep _upkeep, IInitialDistribution _initialDistribution, IAirdrop _airdrop, VestingWallet _teamVestingWallet, VestingWallet _daoVestingWallet ) external; // onlyOwner
	function setAccessManager( IAccessManager _accessManager ) external; // onlyOwner

	// Views
	function salt() external view returns (ISalt);
	function wbtc() external view returns (IERC20);
	function weth() external view returns (IERC20);
	function dai() external view returns (IERC20);
	function usds() external view returns (IUSDS);

	function managedTeamWallet() external view returns (IManagedWallet);
	function daoVestingWallet() external view returns (VestingWallet);
    function teamVestingWallet() external view returns (VestingWallet);
    function initialDistribution() external view returns (IInitialDistribution);

	function accessManager() external view returns (IAccessManager);
	function dao() external view returns (IDAO);
	function upkeep() external view returns (IUpkeep);
	function airdrop() external view returns (IAirdrop);

	function walletHasAccess( address wallet ) external view returns (bool);
	}

// src/pools/interfaces/IPools.sol

interface IPools is IPoolStats
	{
	function startExchangeApproved() external;
	function setContracts( IDAO _dao, ICollateralAndLiquidity _collateralAndLiquidity ) external; // onlyOwner

	function addLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minLiquidityReceived, uint256 totalLiquidity ) external returns (uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity);
	function removeLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToRemove, uint256 minReclaimedA, uint256 minReclaimedB, uint256 totalLiquidity ) external returns (uint256 reclaimedA, uint256 reclaimedB);

	function deposit( IERC20 token, uint256 amount ) external;
	function withdraw( IERC20 token, uint256 amount ) external;
	function swap( IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositSwapWithdraw(IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositDoubleSwapWithdraw( IERC20 swapTokenIn, IERC20 swapTokenMiddle, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);

	// Views
	function exchangeIsLive() external view returns (bool);
	function getPoolReserves(IERC20 tokenA, IERC20 tokenB) external view returns (uint256 reserveA, uint256 reserveB);
	function depositedUserBalance(address user, IERC20 token) external view returns (uint256);
	}

// src/stable/interfaces/ICollateralAndLiquidity.sol

interface ICollateralAndLiquidity is ILiquidity
	{
	function depositCollateralAndIncreaseShare( uint256 maxAmountWBTC, uint256 maxAmountWETH, uint256 minLiquidityReceived, uint256 deadline, bool useZapping ) external returns (uint256 addedAmountWBTC, uint256 addedAmountWETH, uint256 addedLiquidity);
	function withdrawCollateralAndClaim( uint256 collateralToWithdraw, uint256 minReclaimedWBTC, uint256 minReclaimedWETH, uint256 deadline ) external returns (uint256 reclaimedWBTC, uint256 reclaimedWETH);
	function borrowUSDS( uint256 amountBorrowed ) external;
	function repayUSDS( uint256 amountRepaid ) external;
	function liquidateUser( address wallet ) external;

	// Views
	function liquidizer() external view returns (ILiquidizer);
	function usdsBorrowedByUsers( address wallet ) external view returns (uint256);

	function maxWithdrawableCollateral( address wallet ) external view returns (uint256);
	function maxBorrowableUSDS( address wallet ) external view returns (uint256);
	function numberOfUsersWithBorrowedUSDS() external view returns (uint256);
	function canUserBeLiquidated( address wallet ) external view returns (bool);
	function findLiquidatableUsers( uint256 startIndex, uint256 endIndex ) external view returns (address[] calldata);
	function findLiquidatableUsers() external view returns (address[] calldata);

	function underlyingTokenValueInUSD( uint256 amountBTC, uint256 amountETH ) external view returns (uint256);
	function totalCollateralValueInUSD() external view returns (uint256);
	function userCollateralValueInUSD( address wallet ) external view returns (uint256);
	}

// src/stable/interfaces/ILiquidizer.sol

interface ILiquidizer
	{
	function setContracts(ICollateralAndLiquidity _collateralAndLiquidity, IPools _pools, IDAO _dao) external; // onlyOwner
	function incrementBurnableUSDS( uint256 usdsToBurn ) external;
	function performUpkeep() external;

	// Views
	function usdsThatShouldBeBurned() external view returns (uint256 _usdsThatShouldBeBurned);
	}

// src/stable/interfaces/IUSDS.sol

interface IUSDS is IERC20
	{
	function setCollateralAndLiquidity( ICollateralAndLiquidity _collateralAndLiquidity ) external; // onlyOwner
	function mintTo( address wallet, uint256 amount ) external;
	function burnTokensInContract() external;
	}

// src/pools/interfaces/IPoolsConfig.sol

interface IPoolsConfig
	{
	function whitelistPool(  IPools pools, IERC20 tokenA, IERC20 tokenB ) external; // onlyOwner
	function unwhitelistPool( IPools pools, IERC20 tokenA, IERC20 tokenB ) external; // onlyOwner
	function changeMaximumWhitelistedPools(bool increase) external; // onlyOwner
	function changeMaximumInternalSwapPercentTimes1000(bool increase) external; // onlyOwner

	// Views
    function maximumWhitelistedPools() external view returns (uint256);
    function maximumInternalSwapPercentTimes1000() external view returns (uint256);

	function numberOfWhitelistedPools() external view returns (uint256);
	function isWhitelisted( bytes32 poolID ) external view returns (bool);
	function whitelistedPools() external view returns (bytes32[] calldata);
	function underlyingTokenPair( bytes32 poolID ) external view returns (IERC20 tokenA, IERC20 tokenB);

	// Returns true if the token has been whitelisted (meaning it has been pooled with either WBTC and WETH)
	function tokenHasBeenWhitelisted( IERC20 token, IERC20 wbtc, IERC20 weth ) external view returns (bool);
	}

// src/Upkeep.sol

// Performs the following upkeep for each call to performUpkeep():
// (Uses a maximum of 2.3 million gas with 100 whitelisted pools according to UpkeepGasUsage.t.sol)

// 1. Swaps tokens previously sent to the Liquidizer contract for USDS and burns specified amounts of USDS.

// 2. Withdraws existing WETH arbitrage profits from the Pools contract and rewards the caller of performUpkeep() with default 5% of the withdrawn amount.
// 3. Converts a default 5% of the remaining WETH to USDS/DAI Protocol Owned Liquidity.
// 4. Converts a default 20% of the remaining WETH to SALT/USDS Protocol Owned Liquidity.
// 5. Converts remaining WETH to SALT and sends it to SaltRewards.

// 6. Sends SALT Emissions to the SaltRewards contract.
// 7. Distributes SALT from SaltRewards to the stakingRewardsEmitter and liquidityRewardsEmitter.
// 8. Distributes SALT rewards from the stakingRewardsEmitter and liquidityRewardsEmitter.

// 9. Collects SALT rewards from the DAO's Protocol Owned Liquidity (SALT/USDS from formed POL), sends 10% to the initial dev team and burns a default 50% of the remaining - the rest stays in the DAO.
// 10. Sends SALT from the DAO vesting wallet to the DAO (linear distribution over 10 years).
// 11. Sends SALT from the team vesting wallet to the team (linear distribution over 10 years).

// WETH arbitrage profits are converted directly via depositSwapWithdraw - as performUpkeep is called often and the generated arbitrage profits should be manageable compared to the size of the reserves.
// Additionally, simulations show that the impact from sandwich attacks on swap transactions (even without specifying slippage) is limited due to the atomic arbitrage process.
// See PoolUtils.__placeInternalSwap and Sandwich.t.sol for more details.

contract Upkeep is IUpkeep, ReentrancyGuard
    {
	using SafeERC20 for ISalt;
	using SafeERC20 for IUSDS;
	using SafeERC20 for IERC20;

    event UpkeepError(string description, bytes error);

	IPools immutable public pools;
	IExchangeConfig  immutable public exchangeConfig;
	IPoolsConfig immutable public poolsConfig;
	IDAOConfig immutable public daoConfig;
	IStableConfig immutable public stableConfig;
	IPriceAggregator immutable public priceAggregator;
	ISaltRewards immutable public saltRewards;
	ICollateralAndLiquidity immutable public collateralAndLiquidity;
	IEmissions immutable public emissions;
	IDAO immutable public dao;

	IERC20  immutable public weth;
	ISalt  immutable public salt;
	IUSDS  immutable public usds;
	IERC20  immutable public dai;

	uint256 public lastUpkeepTimeEmissions;
	uint256 public lastUpkeepTimeRewardsEmitters;

    constructor( IPools _pools, IExchangeConfig _exchangeConfig, IPoolsConfig _poolsConfig, IDAOConfig _daoConfig, IStableConfig _stableConfig, IPriceAggregator _priceAggregator, ISaltRewards _saltRewards, ICollateralAndLiquidity _collateralAndLiquidity, IEmissions _emissions, IDAO _dao )
		{
		pools = _pools;
		exchangeConfig = _exchangeConfig;
		poolsConfig = _poolsConfig;
		daoConfig = _daoConfig;
		stableConfig = _stableConfig;
		priceAggregator = _priceAggregator;
		saltRewards = _saltRewards;
		collateralAndLiquidity = _collateralAndLiquidity;
		emissions = _emissions;
		dao = _dao;

		// Cached for efficiency
		weth = _exchangeConfig.weth();
		salt = _exchangeConfig.salt();
		usds = _exchangeConfig.usds();
		dai = _exchangeConfig.dai();

		lastUpkeepTimeEmissions = block.timestamp;
		lastUpkeepTimeRewardsEmitters = block.timestamp;

		// Approve for future WETH swaps.
		// This contract only has a temporary WETH balance within the performUpkeep() function itself.
		weth.approve( address(pools), type(uint256).max );
		}

	modifier onlySameContract()
		{
    	require(msg.sender == address(this), "Only callable from within the same contract");
    	_;
		}

	// Note - while the following steps are public so that they can be wrapped in a try/catch, they are all still only callable from this same contract.

	// 1. Swap tokens previously sent to the Liquidizer contract for USDS and burn specified amounts of USDS.
	function step1() public onlySameContract
		{
		collateralAndLiquidity.liquidizer().performUpkeep();
		}

	// 2. Withdraw existing WETH arbitrage profits from the Pools contract and reward the caller of performUpkeep() with default 5% of the withdrawn amount.
	function step2(address receiver) public onlySameContract
		{
		uint256 withdrawnAmount = exchangeConfig.dao().withdrawArbitrageProfits(weth);
		if ( withdrawnAmount == 0 )
			return;

		// Default 5% of the arbitrage profits for the caller of performUpkeep()
		uint256 rewardAmount = withdrawnAmount * daoConfig.upkeepRewardPercent() / 100;

		// Send the reward
		weth.safeTransfer(receiver, rewardAmount);
		}

	// Have the DAO form the specified Protocol Owned Liquidity with the given amount of WETH
	function _formPOL( IERC20 tokenA, IERC20 tokenB, uint256 amountWETH) internal
		{
		uint256 wethAmountPerToken = amountWETH >> 1;

		// Swap WETH for the specified tokens
		uint256 amountA = pools.depositSwapWithdraw( weth, tokenA, wethAmountPerToken, 0, block.timestamp );
		uint256 amountB = pools.depositSwapWithdraw( weth, tokenB, wethAmountPerToken, 0, block.timestamp );

		// Transfer the tokens to the DAO
		tokenA.safeTransfer( address(dao), amountA );
		tokenB.safeTransfer( address(dao), amountB );

		// Have the DAO form POL
		dao.formPOL(tokenA, tokenB, amountA, amountB);
		}

	// 3. Convert a default 5% of the remaining WETH to USDS/DAI Protocol Owned Liquidity.
	function step3() public onlySameContract
		{
		uint256 wethBalance = weth.balanceOf( address(this) );
		if ( wethBalance == 0 )
			return;

		// A default 5% of the remaining WETH will be swapped for USDS/DAI POL.
		uint256 amountOfWETH = wethBalance * stableConfig.percentArbitrageProfitsForStablePOL() / 100;
		_formPOL(usds, dai, amountOfWETH);
		}

	// 4. Convert a default 20% of the remaining WETH to SALT/USDS Protocol Owned Liquidity.
	function step4() public onlySameContract
		{
		uint256 wethBalance = weth.balanceOf( address(this) );
		if ( wethBalance == 0 )
			return;

		// A default 20% of the remaining WETH will be swapped for SALT/USDS POL.
		uint256 amountOfWETH = wethBalance * daoConfig.arbitrageProfitsPercentPOL() / 100;
		_formPOL(salt, usds, amountOfWETH);
		}

	// 5. Convert remaining WETH to SALT and sends it to SaltRewards.
	function step5() public onlySameContract
		{
		uint256 wethBalance = weth.balanceOf( address(this) );
		if ( wethBalance == 0 )
			return;

		// Convert remaining WETH to SALT and send it to SaltRewards
		uint256 amountSALT = pools.depositSwapWithdraw( weth, salt, wethBalance, 0, block.timestamp );
		salt.safeTransfer(address(saltRewards), amountSALT);
		}

	// 6. Send SALT Emissions to the SaltRewards contract.
	function step6() public onlySameContract
		{
		uint256 timeSinceLastUpkeep = block.timestamp - lastUpkeepTimeEmissions;
		emissions.performUpkeep(timeSinceLastUpkeep);

		lastUpkeepTimeEmissions = block.timestamp;
		}

	// 7. Distribute SALT from SaltRewards to the stakingRewardsEmitter and liquidityRewardsEmitter.
	function step7() public onlySameContract
		{
		uint256[] memory profitsForPools = pools.profitsForWhitelistedPools();

		bytes32[] memory poolIDs = poolsConfig.whitelistedPools();
		saltRewards.performUpkeep(poolIDs, profitsForPools );
		pools.clearProfitsForPools();
		}

	// 8. Distribute SALT rewards from the stakingRewardsEmitter and liquidityRewardsEmitter.
	function step8() public onlySameContract
		{
		uint256 timeSinceLastUpkeep = block.timestamp - lastUpkeepTimeRewardsEmitters;

		saltRewards.stakingRewardsEmitter().performUpkeep(timeSinceLastUpkeep);
		saltRewards.liquidityRewardsEmitter().performUpkeep(timeSinceLastUpkeep);

		lastUpkeepTimeRewardsEmitters = block.timestamp;
		}

	// 9. Collect SALT rewards from the DAO's Protocol Owned Liquidity (SALT/USDS from formed POL), send 10% to the initial dev team and burn a default 50% of the remaining - the rest stays in the DAO.
	function step9() public onlySameContract
		{
		dao.processRewardsFromPOL();
		}

	// 10. Send SALT from the DAO vesting wallet to the DAO (linear distribution over 10 years).
	function step10() public onlySameContract
		{
		VestingWallet(payable(exchangeConfig.daoVestingWallet())).release(address(salt));
		}

	// 11. Sends SALT from the team vesting wallet to the team (linear distribution over 10 years).
	function step11() public onlySameContract
		{
		uint256 releaseableAmount = VestingWallet(payable(exchangeConfig.teamVestingWallet())).releasable(address(salt));

		// teamVestingWallet actually sends the vested SALT to this contract - which will then need to be sent to the active teamWallet
		VestingWallet(payable(exchangeConfig.teamVestingWallet())).release(address(salt));

		salt.safeTransfer( exchangeConfig.managedTeamWallet().mainWallet(), releaseableAmount );
		}

	// Perform the various steps of performUpkeep as outlined at the top of the contract.
	// Each step is wrapped in a try/catch to prevent reversions from cascading through the performUpkeep.
	function performUpkeep() public nonReentrant
		{
		// Perform the multiple steps of performUpkeep()
 		try this.step1() {}
		catch (bytes memory error) { emit UpkeepError("Step 1", error); }

 		try this.step2(msg.sender) {}
		catch (bytes memory error) { emit UpkeepError("Step 2", error); }

 		try this.step3() {}
		catch (bytes memory error) { emit UpkeepError("Step 3", error); }

 		try this.step4() {}
		catch (bytes memory error) { emit UpkeepError("Step 4", error); }

 		try this.step5() {}
		catch (bytes memory error) { emit UpkeepError("Step 5", error); }

 		try this.step6() {}
		catch (bytes memory error) { emit UpkeepError("Step 6", error); }

 		try this.step7() {}
		catch (bytes memory error) { emit UpkeepError("Step 7", error); }

 		try this.step8() {}
		catch (bytes memory error) { emit UpkeepError("Step 8", error); }

 		try this.step9() {}
		catch (bytes memory error) { emit UpkeepError("Step 9", error); }

 		try this.step10() {}
		catch (bytes memory error) { emit UpkeepError("Step 10", error); }

 		try this.step11() {}
		catch (bytes memory error) { emit UpkeepError("Step 11", error); }
		}

	// ==== VIEWS ====
	// Returns the amount of WETH that will currently be rewarded for calling performUpkeep().
	// Useful for potential callers to know if calling the function will be profitable in comparison to current gas costs.
	function currentRewardsForCallingPerformUpkeep() public view returns (uint256)
		{
		uint256 daoWETH = pools.depositedUserBalance( address(dao), weth );

		return daoWETH * daoConfig.upkeepRewardPercent() / 100;
		}
	}

