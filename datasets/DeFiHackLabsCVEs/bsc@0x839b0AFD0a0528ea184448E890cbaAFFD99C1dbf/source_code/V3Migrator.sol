// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.16;

interface IBiswapFactoryV3 {

    /// @notice emit when successfully create a new pool (calling iBiswapFactoryV3#newPool)
    /// @param tokenX address of erc-20 tokenX
    /// @param tokenY address of erc-20 tokenY
    /// @param fee fee amount of swap (3000 means 0.3%)
    /// @param pointDelta minimum number of distance between initialized or limitorder points
    /// @param pool address of swap pool
    event NewPool(
        address indexed tokenX,
        address indexed tokenY,
        uint16 indexed fee,
        uint24 pointDelta,
        address pool
    );

    /// @notice emit when enabled new fee
    /// @param fee new available fee
    /// @param pointDelta delta between points on new fee
    event NewFeeEnabled(uint16 fee, uint24 pointDelta);

    /// @notice emit when owner change delta fee on pools
    /// @param fee fee
    /// @param oldDelta delta was before
    /// @param newDelta new delta
    event FeeDeltaChanged(uint16 fee, uint16 oldDelta, uint16 newDelta);

    /// @notice emit when owner change discount setters address
    /// @param newDiscountSetter new discount setter address
    event NewDiscountSetter(address newDiscountSetter);

    /// @notice emit when owner change farms contract address
    /// @param newFarmsContract new farms contract address
    event NewFarmsContract(address newFarmsContract);

    /// @notice emit when set new ratio on pool
    event NewFarmsRatio(address pool, uint ratio);

    /// @notice emit when new discount was set
    /// @param discounts info for new discounts
    event SetDiscounts(DiscountStr[] discounts);

    struct DiscountStr {
        address user;
        address pool;
        uint16 discount;
    }

    struct Addresses {
        address swapX2YModule;
        address  swapY2XModule;
        address  liquidityModule;
        address  limitOrderModule;
        address  flashModule;
    }

    /// @notice Add struct to save gas
    /// @return swapX2YModule address of module to support swapX2Y(DesireY)
    /// @return swapY2XModule address of module to support swapY2X(DesireX)
    /// @return liquidityModule address of module to support liquidity
    /// @return limitOrderModule address of module for user to manage limit orders
    /// @return flashModule address of module to support flash loan
    function addresses() external returns(
        address swapX2YModule,
        address swapY2XModule,
        address liquidityModule,
        address limitOrderModule,
        address flashModule
    );

    /// @notice Set new Swap discounts for addresses
    /// @dev Only DiscountSetter calls
    /// @param discounts info for new discounts
    function setDiscount(DiscountStr[] calldata discounts) external;

    /// @notice Set new farm ratio for pool
    /// @dev Only farm address calls
    /// @param _pool pool address
    /// @param ratio new ratio for pool
    function setFarmsRatio(address _pool, uint256 ratio) external;

    /// @notice default fee rate from miner's fee gain
    /// @return defaultFeeChargePercent default fee rate * 100
    function defaultFeeChargePercent() external returns (uint24);

    /// @notice Enables a fee amount with the given pointDelta
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee fee amount (3000 means 0.3%)
    /// @param pointDelta The spacing between points to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint16 fee, uint24 pointDelta) external;

    /// @notice Create a new pool which not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @param currentPoint initial point (log 1.0001 of price)
    /// @return address of newly created pool
    function newPool(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint
    ) external returns (address);

    /// @notice Charge receiver of all pools.
    /// @return address of charge receiver
    function chargeReceiver() external view returns(address);

    /// @notice Get pool of (tokenX, tokenY, fee), address(0) for not exists.
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee fee amount
    /// @return address of pool
    function pool(
        address tokenX,
        address tokenY,
        uint16 fee
    ) external view returns(address);

    /// @notice farms ratio for pool
    /// @param _pool pool address
    /// @return farmRatio ratio for asked pool
    function farmsRatio(address _pool) external view returns(uint256 farmRatio);

    /// @notice get farms reward contract address
    /// @return farms reward contract address
    function farmsContract() external view returns(address);

    /// @notice Get point delta of a given fee amount.
    /// @param fee fee amount
    /// @return pointDelta the point delta
    function fee2pointDelta(uint16 fee) external view returns (int24 pointDelta);

    /// @notice Get delta fee of a given fee amount.
    /// @param fee fee amount
    /// @return deltaFee fee delta [fee - %delta; fee + %delta] delta in percent base 10000
    function fee2DeltaFee(uint16 fee) external view returns (uint16 deltaFee);

    /// @notice Change charge receiver, only owner of factory can call.
    /// @param _chargeReceiver address of new receiver
    function modifyChargeReceiver(address _chargeReceiver) external;

    /// @notice Change defaultFeeChargePercent
    /// @param _defaultFeeChargePercent new charge percent
    function modifyDefaultFeeChargePercent(uint24 _defaultFeeChargePercent) external;

    /// @notice return range of fee change
    /// @param fee fee for get range
    /// @return lowFee low range border
    /// @return highFee high range border
    function getFeeRange(uint16 fee) external view returns(uint16 lowFee, uint16 highFee);

    /// @notice set fee delta to pools
    /// @param fee fee of pools on which the delta change
    /// @param delta new delta in base 10000
    function setFeeDelta(uint16 fee, uint16 delta) external;

    /// @notice change discount setters address
    /// @param newDiscountSetter new discount setter address
    function setDiscountSetter(address newDiscountSetter) external;

    /// @notice set new farms contract
    /// @param newFarmsContract address of new farms contract
    function setFarmsContract(address newFarmsContract) external;

    /// @notice get discount from user address and pool
    /// @param user user address
    /// @param _pool pool address
    /// @return discount value of the discount base 10000
    function feeDiscount(address user, address _pool) external returns(uint16 discount);

    function deployPoolParams() external view returns(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint,
        int24 pointDelta,
        uint24 feeChargePercent
    );

    /// @notice check fee in range
    /// @param fee fee of pools on which the delta change
    /// @param initFee initialize fee when pool created
    function checkFeeInRange(uint16 fee, uint16 initFee) external view returns(bool);

    /// @notice return Init code hash
    function INIT_CODE_HASH() external pure returns(bytes32);

}



interface IBiswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function swapFee() external view returns (uint32);
    function devFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setSwapFee(uint32) external;
    function setDevFee(uint32) external;
}
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


/// @title Interface for LiquidityManager
interface ILiquidityManager is IERC721Enumerable {

    /// @notice Emitted when miner successfully add liquidity on an existing liquidity-nft
    /// @param nftId id of minted liquidity nft
    /// @param pool address of swap pool
    /// @param liquidityDelta the amount of liquidity added
    /// @param amountX amount of tokenX deposit
    /// @param amountY amount of tokenY deposit
    event AddLiquidity(
        uint256 indexed nftId,
        address pool,
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when miner successfully add decrease liquidity on an existing liquidity-nft
    /// @param nftId id of minted liquidity nft
    /// @param pool address of swap pool
    /// @param liquidityDelta the amount of liquidity decreased
    /// @param amountX amount of tokenX withdrawn
    /// @param amountY amount of tokenY withdrawn
    event DecLiquidity(
        uint256 indexed nftId,
        address pool,
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Emitted when set new bonus pool manager contract
    /// @param _bonusPoolManager new bonus pool manager address
    event SetBonusPoolManager(address _bonusPoolManager);

    /// @notice Emitted when get error on hook call
    /// @param receiver hook receiver address
    /// @param returnData retern revert data
    event HookError(address receiver,  bytes returnData);

    /// @nitice parameters when calling mint, grouped together to avoid stake too deep
    /// @param miner miner address
    /// @param tokenX address of tokenX
    /// @param tokenY address of tokenY
    /// @param fee current fee of pool
    /// @param pl left point of added liquidity
    /// @param pr right point of added liquidity
    /// @param xLim amount limit of tokenX miner willing to deposit
    /// @param yLim amount limit tokenY miner willing to deposit
    /// @param amountXMin minimum amount of tokenX miner willing to deposit
    /// @param amountYMin minimum amount of tokenY miner willing to deposit
    /// @param deadline deadline of transaction
    struct MintParam {
        address miner;
        address tokenX;
        address tokenY;
        uint16 fee;
        int24 pl;
        int24 pr;
        uint128 xLim;
        uint128 yLim;
        uint128 amountXMin;
        uint128 amountYMin;
        uint256 deadline;
    }

    /// @notice parameters when calling addLiquidity, grouped together
    /// @dev to avoid stake too deep
    /// @param lid id of nft
    /// @param xLim amount limit of tokenX user willing to deposit
    /// @param yLim amount limit of tokenY user willing to deposit
    /// @param amountXMin min amount of tokenX user willing to deposit
    /// @param amountYMin min amount of tokenY user willing to deposit
    /// @param deadline deadline for completing transaction
    struct AddLiquidityParam {
        uint256 lid;
        uint128 xLim;
        uint128 yLim;
        uint128 amountXMin;
        uint128 amountYMin;
        uint256 deadline;
    }

    /// @notice pool data
    /// @param tokenX address of token X
    /// @param fee fee of pool
    /// @param tokenY address of token X
    /// @param pool pool address
    struct PoolMeta {
        address tokenX;
        uint16 fee;
        address tokenY;
        address pool;
    }

    /// @notice information of liquidity provided by miner
    /// @param leftPt left point of liquidity-token, the range is [leftPt, rightPt)
    /// @param rightPt right point of liquidity-token, the range is [leftPt, rightPt)
    /// @param feeVote Vote for fee on liquidity position
    /// @param liquidity amount of liquidity on each point in [leftPt, rightPt)
    /// @param lastFeeScaleX_128 a 128-fixpoint number, as integral of { fee(pt, t)/L(pt, t) }
    /// @param lastFeeScaleY_128 a 128-fixpoint number, as integral of { fee(pt, t)/L(pt, t) }
    /// @dev here fee(pt, t) denotes fee generated on point pt at time t
    /// L(pt, t) denotes liquidity on point pt at time t
    /// pt varies in [leftPt, rightPt)
    /// t moves from pool created until miner last modify this liquidity-token (mint/addLiquidity/decreaseLiquidity/create)
    /// @param lastFPScale_128 a 128-fixpoint number last FPScale of 1 liquidity
    /// @param remainTokenX remained tokenX miner can collect, including fee and withdrawn token
    /// @param remainTokenY remained tokenY miner can collect, including fee and withdrawn token
    /// @param fpOwed Accrued fp for liquidity position
    /// @param poolId id of pool in which this liquidity is added
    struct Liquidity {
        int24 leftPt;
        int24 rightPt;
        uint16 feeVote;
        uint128 liquidity;
        uint256 lastFeeScaleX_128;
        uint256 lastFeeScaleY_128;
        uint256 lastFPScale_128;
        uint256 remainTokenX;
        uint256 remainTokenY;
        uint256 fpOwed;
        uint128 poolId;
    }

    /// @notice callback data passed through BiswapPoolV3#mint to the callback
    /// @param tokenX tokenX of swap
    /// @param tokenY tokenY of swap
    /// @param fee fee amount of swap
    /// @param payer address to pay tokenX and tokenY to BiswapPoolV3
    struct MintCallbackData {
        address tokenX;
        address tokenY;
        uint16 fee;
        address payer;
    }


    /// @notice Add a new liquidity and generate a nft.
    /// @param mintParam params, see MintParam for more
    /// @return lid id of nft
    /// @return liquidity amount of liquidity added
    /// @return amountX amount of tokenX deposited
    /// @return amountY amount of tokenY depsoited
    function mint(MintParam calldata mintParam) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Add a new liquidity and generate a nft.
    /// @param mintParam params, see MintParam for more
    /// @param feeVote vote for fee at liquidity position
    /// @return lid id of nft
    /// @return liquidity amount of liquidity added
    /// @return amountX amount of tokenX deposited
    /// @return amountY amount of tokenY deposited
    function mintWithFeeVote(MintParam calldata mintParam, uint16 feeVote) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Burn a generated nft.
    /// @param lid nft (liquidity) id
    /// @return success successfully burn or not
    function burn(uint256 lid) external returns (bool success);

    /// @notice Add liquidity to a existing nft.
    /// @param addLiquidityParam see AddLiquidityParam for more
    /// @return liquidityDelta amount of added liquidity
    /// @return amountX amount of tokenX deposited
    /// @return amountY amonut of tokenY deposited
    function addLiquidity(
        AddLiquidityParam calldata addLiquidityParam
    ) external payable returns (
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Decrease liquidity from a nft.
    /// @param lid id of nft
    /// @param liquidDelta amount of liqudity to decrease
    /// @param amountXMin min amount of tokenX user want to withdraw
    /// @param amountYMin min amount of tokenY user want to withdraw
    /// @param deadline deadline timestamp of transaction
    /// @return amountX amount of tokenX refund to user
    /// @return amountY amount of tokenY refund to user
    function decLiquidity(
        uint256 lid,
        uint128 liquidDelta,
        uint256 amountXMin,
        uint256 amountYMin,
        uint256 deadline
    ) external returns (
        uint256 amountX,
        uint256 amountY
    );

    /// @notice Change vote for fee on exist NFT
    /// @param lid NFT Id
    /// @param newFeeVote new vote for fee on NFT position
    function changeFeeVote(uint256 lid, uint16 newFeeVote) external;

    /// @notice get liquidity info from NFT Id
    /// @param lid NFT id
    /// @return leftPt left point of liquidity-token, the range is [leftPt, rightPt)
    /// @return rightPt right point of liquidity-token, the range is [leftPt, rightPt)
    /// @return feeVote Vote for fee on liquidity position
    /// @return liquidity amount of liquidity on each point in [leftPt, rightPt)
    /// @return lastFeeScaleX_128 a 128-fixpoint number, as integral of { fee(pt, t)/L(pt, t) }
    /// @return lastFeeScaleY_128 a 128-fixpoint number, as integral of { fee(pt, t)/L(pt, t) }
    /// @dev here fee(pt, t) denotes fee generated on point pt at time t
    /// L(pt, t) denotes liquidity on point pt at time t
    /// pt varies in [leftPt, rightPt)
    /// t moves from pool created until miner last modify this liquidity-token (mint/addLiquidity/decreaseLiquidity/create)
    /// @return lastFPScale_128 a 128-fixpoint number last FPScale of 1 liquidity
    /// @return remainTokenX remained tokenX miner can collect, including fee and withdrawn token
    /// @return remainTokenY remained tokenY miner can collect, including fee and withdrawn token
    /// @return fpOwed Accrued fp for liquidity position
    /// @return poolId id of pool in which this liquidity is added
    function liquidities(uint256 lid) external view returns(
        int24 leftPt,
        int24 rightPt,
        uint16 feeVote,
        uint128 liquidity,
        uint256 lastFeeScaleX_128,
        uint256 lastFeeScaleY_128,
        uint256 lastFPScale_128,
        uint256 remainTokenX,
        uint256 remainTokenY,
        uint256 fpOwed,
        uint128 poolId
    );

    /// @notice info of pool from poolId
    /// @param poolId pool Id
    /// @return tokenX address of token X
    /// @return fee fee of pool
    /// @return tokenY address of token X
    /// @return pool pool address
    function poolMetas(uint128 poolId) external view returns(
        address tokenX,
        uint16 fee,
        address tokenY,
        address pool
    );

    /// @notice Collect fee gained of token withdrawn from nft.
    /// @param recipient address to receive token
    /// @param lid id of nft
    /// @param amountXLim amount limit of tokenX to collect
    /// @param amountYLim amount limit of tokenY to collect
    /// @return amountX amount of tokenX actually collect
    /// @return amountY amount of tokenY actually collect
    function collect(
        address recipient,
        uint256 lid,
        uint128 amountXLim,
        uint128 amountYLim
    ) external payable returns (
        uint256 amountX,
        uint256 amountY
    );

    /// @notice update farm point from pool
    /// @param lid NFT Id
    function updateFpOwed(uint256 lid) external;

    /// @notice Set new bonus pool manager contract
    /// @dev only owner call
    /// @param _bonusPoolManager new bonus pool manager address
    function setBonusPoolManager(address _bonusPoolManager) external;
}



/// @title V3 Migrator
/// @notice Enables migration of liqudity from Uniswap v2-compatible pairs into Uniswap v3 pools
interface IV3Migrator {
    struct MigrateParams {
        address pair; // the Uniswap v2-compatible pair
        uint256 liquidityToMigrate; // expected to be balanceOf(msg.sender)
        address token0;
        address token1;
        uint16 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 amount0Min; // must be discounted by percentageToMigrate
        uint128 amount1Min; // must be discounted by percentageToMigrate
        address recipient;
        uint256 deadline;
        bool refundAsETH;
    }

    /// @notice Migrates liquidity to v3 by burning v2 liquidity and minting a new position for v3
    /// @dev Slippage protection is enforced via `amount{0,1}Min`, which should be a discount of the expected values of
    /// the maximum amount of v3 liquidity that the v2 liquidity can get. For the special case of migrating to an
    /// out-of-range position, `amount{0,1}Min` may be set to 0, enforcing that the position remains out of range
    /// @param params The params necessary to migrate v2 liquidity, encoded as `MigrateParams` in calldata
    function migrate(MigrateParams calldata params) external returns(uint refund0, uint refund1);

    /// @notice Add a new liquidity and generate a nft at liquidity manager.
    /// @param mintParam params, see MintParam for more
    /// @return lid id of nft
    /// @return liquidity amount of liquidity added
    /// @return amountX amount of tokenX deposited
    /// @return amountY amount of tokenY depsoited
    function mint(ILiquidityManager.MintParam calldata mintParam) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );
}

/// @title Interface for WETH9
interface IWETH9 is IERC20 {
    /// @notice Deposit ether to get wrapped ether
    function deposit() external payable;

    /// @notice Withdraw wrapped ether to get ether
    function withdraw(uint256) external;
}

abstract contract Base {
    /// @notice address of BiswapFactoryV3
    address public immutable factory;

    /// @notice address of weth9 token
    address public immutable WETH9;

    /// @notice factory provided init code hash
    bytes32  public immutable INIT_CODE_HASH;

    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, 'Out of time');
        _;
    }

    receive() external payable {}

    /// @notice Constructor of base.
    /// @param _factory address of BiswapFactoryV3
    /// @param _WETH9 address of weth9 token
    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
        INIT_CODE_HASH = IBiswapFactoryV3(_factory).INIT_CODE_HASH();
    }

    /// @notice Make multiple function calls in this contract in a single transaction
    ///     and return the data for each function call, revert if any function call fails
    /// @param data The encoded function data for each function call
    /// @return results result of each function call
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    /// @notice Transfer tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfer tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approve the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfer ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }

    /// @notice Withdraw all weth9 token of this contract and send the withdrawn eth to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal eth from this contract
    /// @param minAmount The minimum amount of WETH9 to withdraw
    /// @param recipient The address to receive all withdrawn eth from this contract
    function unwrapWETH9(uint256 minAmount, address recipient) external payable {
        uint256 all = IWETH9(WETH9).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            IWETH9(WETH9).withdraw(all);
            safeTransferETH(recipient, all);
        }
    }

    /// @notice Send all balance of specified token in this contract to recipient
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    /// @param token address of the token
    /// @param minAmount balance should >= minAmount
    /// @param recipient the address to receive specified token from this contract
    function sweepToken(
        address token,
        uint256 minAmount,
        address recipient
    ) external payable {
        uint256 all = IERC20(token).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');

        if (all > 0) {
            safeTransfer(token, recipient, all);
        }
    }

    /// @notice Send all balance of eth in this contract to msg.sender
    ///    usually used in multicall when mint/swap/update limitorder with eth
    ///    normally this contract has no any erc20 token or eth after or before a transaction
    ///    we donot need to worry that some one can steal some token from this contract
    function refundETH() external payable {
        if (address(this).balance > 0) safeTransferETH(msg.sender, address(this).balance);
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            // pay with WETH9
            IWETH9(WETH9).deposit{value: value}(); // wrap only what is needed to pay
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            safeTransfer(token, recipient, value);
        } else {
            // pull payment
            safeTransferFrom(token, payer, recipient, value);
        }
    }

    /// @notice Query pool address from factory by (tokenX, tokenY, fee).
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    function pool(address tokenX, address tokenY, uint16 fee) public view returns(address) {
        (address token0, address token1) = tokenX < tokenY ? (tokenX, tokenY) : (tokenY, tokenX);
        return address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encode(token0, token1, fee)),
            INIT_CODE_HASH
        )))));
    }

    /// @notice Get or create a pool for (tokenX/tokenY/fee) if not exists.
    /// @param tokenX tokenX of swap pool
    /// @param tokenY tokenY of swap pool
    /// @param fee fee amount of swap pool
    /// @param initialPoint initial point if need to create a new pool
    /// @return corresponding pool address
    function createPool(address tokenX, address tokenY, uint16 fee, int24 initialPoint) external payable returns (address) {
        return IBiswapFactoryV3(factory).newPool(tokenX, tokenY, fee, initialPoint);
    }

    //
    function verify(address tokenX, address tokenY, uint16 fee) internal view {
        require (msg.sender == pool(tokenX, tokenY, fee), "sp");
    }
}
/// @title Biswap V3 Migrator
/// @notice You can use this contract to migrate your V2 liquidity to V3 pool.
contract V3Migrator is Base, IV3Migrator {

    address public immutable liquidityManager;

    int24 fullRangeLength = 800000;

    event Migrate(
        MigrateParams params,
        uint amountRemoved0,
        uint amountRemoved1,
        uint amountAdded0,
        uint amountAdded1
    );

    constructor(
        address _factory,
        address _WETH9,
        address _liquidityManager
    ) Base(_factory, _WETH9) {
        liquidityManager = _liquidityManager;
    }

    /// @inheritdoc IV3Migrator
    function mint(ILiquidityManager.MintParam calldata mintParam) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    ){
        return ILiquidityManager(liquidityManager).mint(mintParam);
    }

    /// @notice This function burn V2 liquidity, and mint V3 liquidity with received tokens
    /// @param params see IV3Migrator.MigrateParams
    /// @return refund0 amount of token0 that burned from V2 but not used to mint V3 liquidity
    /// @return refund1 amount of token1 that burned from V2 but not used to mint V3 liquidity
    function migrate(MigrateParams calldata params) external override returns(uint refund0, uint refund1){

        // burn v2 liquidity to this address
        IBiswapPair(params.pair).transferFrom(params.recipient, params.pair, params.liquidityToMigrate);
        (uint256 amount0V2, uint256 amount1V2) = IBiswapPair(params.pair).burn(address(this));

        // calculate the amounts to migrate to v3
        uint128 amount0V2ToMigrate = uint128(amount0V2);
        uint128 amount1V2ToMigrate = uint128(amount1V2);

        // approve the position manager up to the maximum token amounts
        safeApprove(params.token0, liquidityManager, amount0V2ToMigrate);
        safeApprove(params.token1, liquidityManager, amount1V2ToMigrate);

        // mint v3 position
        (, , uint256 amount0V3, uint256 amount1V3) = ILiquidityManager(liquidityManager).mint(
            ILiquidityManager.MintParam({
                miner: params.recipient,
                tokenX: params.token0,
                tokenY: params.token1,
                fee: params.fee,
                pl: params.tickLower,
                pr: params.tickUpper,
                xLim: amount0V2ToMigrate,
                yLim: amount1V2ToMigrate,
                amountXMin: params.amount0Min,
                amountYMin: params.amount1Min,
                deadline: params.deadline
            })
        );

        // if necessary, clear allowance and refund dust
        if (amount0V3 < amount0V2) {
            if (amount0V3 < amount0V2ToMigrate) {
                safeApprove(params.token0, liquidityManager, 0);
            }

            refund0 = amount0V2 - amount0V3;
            if (params.refundAsETH && params.token0 == WETH9) {
                IWETH9(WETH9).withdraw(refund0);
                safeTransferETH(params.recipient, refund0);
            } else {
                safeTransfer(params.token0, params.recipient, refund0);
            }
        }
        if (amount1V3 < amount1V2) {
            if (amount1V3 < amount1V2ToMigrate) {
                safeApprove(params.token1, liquidityManager, 0);
            }

            refund1 = amount1V2 - amount1V3;
            if (params.refundAsETH && params.token1 == WETH9) {
                IWETH9(WETH9).withdraw(refund1);
                safeTransferETH(params.recipient, refund1);
            } else {
                safeTransfer(params.token1, params.recipient, refund1);
            }
        }

        emit Migrate(
            params,
            amount0V2,
            amount1V2,
            amount0V3,
            amount1V3
        );
    }

    function stretchToPD(int24 point, int24 pd) private pure returns(int24 stretchedPoint){
        if (point < -pd) return ((point / pd) * pd) + pd;
        if (point > pd) return ((point / pd) * pd);
        return 0;
    }

    /// @notice returns maximum possible range in points, used in 'full range' mint variant
    /// @param cp "current point"
    /// @param pd "point delta"
    /// @return pl calculated left point for full range
    /// @return pr calculated right point for full range
    function getFullRangeTicks(int24 cp, int24 pd) public view returns(int24 pl, int24 pr){
        cp = (cp / pd) * pd;
        int24 minPoint = -800000;
        int24 maxPoint = 800000;

        if (cp >= fullRangeLength/2)  return (stretchToPD(maxPoint - fullRangeLength, pd), stretchToPD(maxPoint, pd));
        if (cp <= -fullRangeLength/2) return (stretchToPD(minPoint, pd),  stretchToPD(minPoint + fullRangeLength, pd));
        return (stretchToPD(cp - fullRangeLength/2, pd), stretchToPD(cp + fullRangeLength/2, pd));
    }

    /// @notice returns all requiered info for creating full range position
    /// @param _tokenX target pool tokenX
    /// @param _tokenY target pool tokenY
    /// @param _fee target pool swap fee
    /// @return currentPoint pool current point
    /// @return leftTick calculated left point for full range
    /// @return rightTick calculated right point for full range
    function getPoolState(address _tokenX, address _tokenY, uint16 _fee) public view returns(
        int24 currentPoint,
        int24 leftTick,
        int24 rightTick
    ){
        address poolAddress = pool(_tokenX, _tokenY, _fee);
        (bool success, bytes memory d_state) = poolAddress.staticcall(abi.encodeWithSelector(0xc19d93fb)); //"state()"
        if (!success) revert('pool not created yet!');
        (, bytes memory d_pointDelta) = poolAddress.staticcall(abi.encodeWithSelector(0x58c51ce6)); //"pointDelta()"

        (,currentPoint,,,,,,,,) = abi.decode(d_state, (uint160,int24,uint16,uint16,uint16,bool,uint240,uint16,uint128,uint128));
        (int24 pointDelta) = abi.decode(d_pointDelta, (int24));
        (leftTick, rightTick) = getFullRangeTicks(currentPoint, pointDelta);

        return (currentPoint, leftTick, rightTick);
    }
}