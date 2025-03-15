pragma solidity 0.8.16;

// sol/IERC721Metadata.sol
// SPDX-Identifier: CC0

/// @title ERC-721 Non-Fungible Token Standard (with metadata)
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface IERC721Metadata /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string memory);

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string memory);

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256) external view returns (string memory);
}

// sol/IERC721TokenReceiver.sol
// SPDX-Identifier: CC0

interface IERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns (bytes4);
}

// sol/ISeawaterEvents.sol
// SPDX-Identifier: MIT

interface ISeawaterEvents {
    // positions

    /// @notice emitted when a new position is minted
    /// @param id the position id
    /// @param owner the owner of the position
    /// @param pool the pool the position is associated with
    /// @param lower the lower tick of the position's concentrated liquidity range
    /// @param upper the upper tick of the position's concentrated liquidity range
    event MintPosition(
        uint256 indexed id,
        address indexed owner,
        address indexed pool,
        int32 lower,
        int32 upper
    );

    /// @notice emitted when a position is burned
    /// @param id the id of the position being burned
    /// @param owner the user the owned the position
    event BurnPosition(
        uint256 indexed id,
        address indexed owner
    );

    /// @notice emitted when a position changes owners
    /// @param from the original owner of the position
    /// @param to the new owner of the position
    /// @param id the id of the position being transferred
    event TransferPosition(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    /// @notice emitted when the liquidity in a position is changed.
    /// @param token0, negative if given to the user. Positive if sent to the contract.
    /// @param token1 that was taken or given to the contract.
    event UpdatePositionLiquidity(
        uint256 indexed id,
        int256 token0,
        int256 token1
    );

    /// @notice emitted when a liquidity provider collects the fees associated with a position
    /// @param id the id of the position whose liquidity is being collected
    /// @param pool the address of the pool the position is associated with
    /// @param to the recipient of the fees
    /// @param amount0 the amount of token0 being collected
    /// @param amount1 the amount of token1 being collected
    event CollectFees(
        uint256 indexed id,
        address indexed pool,
        address indexed to,
        uint128 amount0,
        uint128 amount1
    );

    // admin

    /// @notice emitted when a new pool is created
    /// @param token the token0 the pool is associated with (where token1 is a fluid token)
    /// @param fee the fee being used for this pool
    /// @param decimals the decimals for the token
    /// @param tickSpacing the tick spacing for the pool
    event NewPool(
        address indexed token,
        uint32 indexed fee,
        uint8 decimals,
        uint8 tickSpacing
    );

    /// @notice emitted when a protocol admin collects protocol fees
    /// @param pool the pool for which protocol fees are being collected
    /// @param to the account the fees are being sent to
    /// @param amount0 the amount of token0 being collected
    /// @param amount1 the amount of token1 being collected
    event CollectProtocolFees(
        address indexed pool,
        address indexed to,
        uint128 amount0,
        uint128 amount1
    );

    // amm

    /// @notice emitted when a user swaps a nonfluid token for a nonfluid token (2-step swap)
    /// @param user the user performing the swap
    /// @param from the input token
    /// @param to the output token
    /// @param amountIn the amount of `from` the user is paying
    /// @param amountOut the amount of `to` the user is receiving
    /// @param fluidVolume the volume of the internal transfer
    /// @param finalTick0 the tick that the first token's pool ended on
    /// @param finalTick1 the tick that the second token's pool ended on
    event Swap2(
        address indexed user,
        address indexed from,
        address indexed to,
        uint256 amountIn,
        uint256 amountOut,
        uint256 fluidVolume,
        int32 finalTick0,
        int32 finalTick1
    );

    /// @notice emitted when a user swaps a token for the pool's fluid token, or vice-versa
    /// @param user the user performing the swap
    /// @param pool the token being swapped for the fluid token
    /// @param zeroForOne true if the user is swapping token->fluid, false otherwise
    /// @param amount0 the amount of the nonfluid token being transferred
    /// @param amount1 the amount of the fluid token being transferred
    /// @param finalTick the tick the pool ended on
    event Swap1(
        address indexed user,
        address indexed pool,
        bool zeroForOne,
        uint256 amount0,
        uint256 amount1,
        int32 finalTick
    );
}

// sol/ISeawaterExecutors.sol
// SPDX-Identifier: MIT

interface ISeawaterExecutorSwap {
    /// @notice swaps within a pool
    /// @param pool the pool to swap on
    /// @param zeroForOne true if swapping token->fluid token
    /// @param amount the amount of token to swap, positive if exactIn, negative if exactOut
    /// @param priceLimit the price limit for swaps, encoded as a sqrtX96 price
    /// @return (token0, token1) delta
    function swap904369BE(
        address pool,
        bool zeroForOne,
        int256 amount,
        uint256 priceLimit
    ) external returns (int256, int256);

    /// @notice performs a two stage swap across two pools
    /// @param from the input token
    /// @param to the output token
    /// @param amount the amount of the input token to use
    /// @param minOut the minimum valid amount of the output token, reverts if not reached
    /// @return (amount in, amount out)
    function swap2ExactIn41203F1D(
        address from,
        address to,
        uint256 amount,
        uint256 minOut
    ) external returns (uint256, uint256);
}

interface ISeawaterExecutorSwapPermit2 {
    /// @notice swaps within a pool using permit2 for token transfers
    /// @param pool the pool to swap on
    /// @param zeroForOne true if swapping token->fluid token
    /// @param amount the amount of token to swap, positive if exactIn, negative if exactOut
    /// @param priceLimit the price limit for swaps, encoded as a sqrtX96 price
    /// @param nonce the permit2 nonce
    /// @param deadline the permit2 deadline
    /// @param maxAmount the permit2 maxAmount
    /// @param sig the permit2 signature
    /// @return (token0, token1) delta
    function swapPermit2EE84AD91(
        address pool,
        bool zeroForOne,
        int256 amount,
        uint256 priceLimit,
        uint256 nonce,
        uint256 deadline,
        uint256 maxAmount,
        bytes memory sig
    ) external returns (int256, int256);

    /// @notice performs a two stage swap across two pools using permit2 for token transfers
    /// @param from the input token
    /// @param to the output token
    /// @param amount the amount of the input token to use
    /// @param minOut the minimum valid amount of the output token, reverts if not reached
    /// @param nonce the permit2 nonce
    /// @param deadline the permit2 deadline
    /// @param sig the permit2 signature
    /// @notice permit2's max amount must be set to `amount`
    /// @return (amount in, amount out)
    function swap2ExactInPermit236B2FDD8(
        address from,
        address to,
        uint256 amount,
        uint256 minOut,
        uint256 nonce,
        uint256 deadline,
        bytes memory sig
    ) external returns (uint256, uint256);
}

interface ISeawaterExecutorQuote {
    /// @notice reverts with the expected amount of fUSDC or pool token for a swap with the given parameters
    /// @param pool the pool to swap on
    /// @param zeroForOne true if swapping token->fluid token
    /// @param amount the amount of token to swap, positive if exactIn, negative if exactOut
    /// @param priceLimit the price limit for swaps, encoded as a sqrtX96 price
    /// @notice always revert with Error(string(amountOut))
    function quote72E2ADE7(
        address pool,
        bool zeroForOne,
        int256 amount,
        uint256 priceLimit
    ) external;

    /// @notice reverts with the expected amount of tokenOut for a 2-token swap with the given parameters
    /// @param from the input token
    /// @param to the output token
    /// @param amount the amount of the input token to use
    /// @param minOut the minimum valid amount of the output token, reverts if not reached
    /// @notice always revert with Error(string(amountOut))
    function quote2CD06B86E(
        address from,
        address to,
        uint256 amount,
        uint256 minOut
    ) external;
}

interface ISeawaterExecutorPosition {
    struct CollectResult {
        uint128 amount0;
        uint128 amount1;
    }
    /// @notice creates a new position
    /// @param pool the pool to create the position on
    /// @param lower the lower tick of the position (for concentrated liquidity)
    /// @param upper the upper tick of the position
    function mintPositionBC5B086D(
        address pool,
        int32 lower,
        int32 upper
    ) external returns (uint256 id);

    /// @notice burns a position, leaving the liquidity in it inaccessible
    /// @notice id the id of the position to burn
    function burnPositionAE401070(uint256 id) external;

    /// @notice transferPosition transfers a position. usable only by the NFT manager
    /// @param id the id of the position to transfer
    /// @param from the user to transfer the position from
    /// @param to the user to transfer the position to
    function transferPositionEEC7A3CD(uint256 id, address from, address to) external;

    /// @notice gets the owner of a position
    /// @param id the id of the position
    /// @return the owner of the position
    function positionOwnerD7878480(uint256 id) external returns (address);

    /// @notice gets the number of positions owned by a user
    /// @param user the user to get position balance for
    /// @return the number of positions owned by the user
    function positionBalance4F32C7DB(address user) external returns (uint256);

    /// @notice gets the amount of liquidity in a position
    /// @param pool the position belongs to
    /// @param id the id of the position
    /// @return the amount of liquidity contained in the position
    function positionLiquidity8D11C045(address pool, uint256 id) external returns (uint128);

    /// @notice get the lower tick of the position id
    /// @param pool the position belongs to
    /// @param id of the position
    /// @return the lower tick of the position given
    function positionTickLower2F77CCE1(address pool, uint256 id) external returns (int32);

    /// @notice get the upper tick of the position id
    /// @param pool the position belongs to
    /// @param id of the position
    /// @return the lower tick of the position given
    function positionTickUpper67FD55BA(address pool, uint256 id) external returns (int32);

    /// @notice collect a single position's yield
    /// @param pool the position belongs to
    /// @param id of the position to use
    /// @param recipient of the money that's earned
    /// @return amount0 and amount1
    function collectSingleTo6D76575F(
        address pool,
        uint256 id,
        address recipient
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice collects fees from from positions
    /// @param pools to claim accumulated yield from
    /// @param ids to claim the positions of
    function collect7F21947C(
        address[] memory pools,
        uint256[] memory ids
    ) external returns (CollectResult[] memory);
}

interface ISeawaterExecutorUpdatePosition {
    /// @notice refreshes a position's fees, and adds or removes liquidity
    /// @param pool to use this with
    /// @param id the id of the position
    /// @param delta the amount of liquidity to add or remove
    /// @return the deltas for token0 and token1 for the user
    function updatePositionC7F1F740(
        address pool,
        uint256 id,
        int128 delta
    ) external returns (int256, int256);

    /// @notice refreshes a position's fees, and adds liquidity, preventing less than the minimum from being taken.
    /// @param pool of the token to use
    /// @param id the id of the position
    /// @param amount0Min minimum of amount0 to take from the user
    /// @param amount1Min minimum of amount1 to take from the user
    /// @param amount0Desired to take from the user. May exceed.
    /// @param amount1Desired to take from the user. May exceed.
    /// @return the deltas for token0, and token1
    function incrPositionC3AC7CAA(
        address pool,
        uint256 id,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external returns (uint256, uint256);

    /// @notice refreshes a position's fees, and takes liquidity, preventing less than the minimum from being taken.
    /// @param id the id of the position
    /// @param amount0Min minimum of amount0 to take from the user
    /// @param amount1Min minimum of amount1 to take from the user
    /// @param amount0Max to use as the maximum of amount0, used to create the delta
    /// @param amount1Max to use as the maximum of amount1, used to create the delta
    /// @return the deltas for token0, and token1
    function decrPosition09293696(
        uint256 id,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 amount0Max,
        uint256 amount1Max
    ) external returns (uint256, uint256);

    function incrPositionPermit25468326E(
        address /* token */,
        uint256 /* id */,
        uint256 /* amount0Min */,
        uint256 /* amount1Min */,
        uint256 /* nonce0 */,
        uint256 /* deadline0 */,
        uint256 /* amount0Max */,
        bytes memory /* sig0 */,
        uint256 /* nonce1 */,
        uint256 /* deadline1 */,
        uint256 /* amount1Max */,
        bytes memory /* sig1 */
    ) external returns (uint256, uint256);
}

/// @dev contains just the admin functions that are exposed directly
interface ISeawaterExecutorAdminExposed {
    /// @notice initialises a new pool. only usable by the seawater admin
    /// @param pool the token to create the pool with
    /// @param sqrtPriceX96 the starting price for the pool
    /// @param fee the fee to use
    /// @param tickSpacing the spacing for valid liquidity ticks
    /// @param maxLiquidityPerTick the maximum amount of liquidity allowed in a single tick
    function createPoolD650E2D0(
        address pool,
        uint256 sqrtPriceX96,
        uint32 fee,
        uint8 tickSpacing,
        uint128 maxLiquidityPerTick
    ) external;

    /// @notice collects protocol fees. only usable by the seawater admin
    /// @param pool the pool to collect fees for
    /// @param amount0 the maximum amount of token0 fees to collect
    /// @param amount1 the maximum amount of token1 fees to collect
    /// @param recipient of the funds that're earned
    /// @return the amount of token0 and token1 fees collected
    function collectProtocol7540FA9F(
        address pool,
        uint128 amount0,
        uint128 amount1,
        address recipient
    ) external returns (uint128, uint128);

    /// @notice feesOwed to a position ID given.
    /// @param pool to get the fees owed for
    /// @param id of the position to check for
    /// @return the amount of token0 and token1 to get in return
    function feesOwed22F28DBD(address pool, uint256 id) external returns (uint128, uint128);

    /// @notice gets the current sqrt price of the pool
    /// @param pool to get from
    /// @return the current sqrtPriceX96 for the pool
    function sqrtPriceX967B8F5FC5(address pool) external returns (uint256);

    /// @notice gets the currently used tick of the pool
    /// @param pool to get from
    /// @return the current active tick in the pool
    function curTick181C6FD9(address pool) external returns (int32);

    /// @notice gets the tick spacing of the pool
    /// @param pool to get from
    /// @return the tick spacing of the pool
    function tickSpacing653FE28F(address pool) external returns (uint8);

    /// @notice gets the fee for a specific pool
    /// @param pool to get the fee for
    /// @return the fee for the pool
    function feeBB3CF608(address pool) external returns (uint32);

    /// @notice gets the fee growth for token 0
    /// @param pool to get from
    /// @return the fee growth for the other token
    function feeGrowthGlobal038B5665B(address pool) external returns (uint256);

    /// @notice gets the fee growth for token 1
    /// @param pool to get from
    /// @return the fee growth for fUSDC
    function feeGrowthGlobal1A33A5A1B(address pool) external returns (uint256);

    /// @notice enables or disables a pool
    /// @param pool the pool to enable or disable
    /// @param enabled true to enable to pool, false to disable it
    function enablePool579DA658(address pool, bool enabled) external;

    /// @notice authorise an address to create and enable pools on its own
    /// @param enabled to set their status
    function authoriseEnabler5B17C274(address enabler, bool enabled) external;

    /// @notice set the sqrt price for a pool in the event of misconfiguration.
    /// @param pool to set
    /// @param price to use as the starting place
    function setSqrtPriceFF4DB98C(address pool, uint256 price) external;

    /// @notice set the NFT manager.
    /// @param manager address to set to in its new form
    function updateNftManager9BDF41F6(address manager) external;

    /// @notice updateEmergencyCouncil to a new address.
    /// @param newCouncil to set the emergency council to
    function updateEmergencyCouncil7D0C1C58(address newCouncil) external;
}

interface ISeawaterExecutorAdmin  is ISeawaterExecutorAdminExposed {
    /// @notice constructor function
    /// @param seawaterAdmin the account with administrative power on the amm
    /// @param nftManager the account with control over NFT ownership
    /// @param emergencyCouncil to use to control for pool disabling interactions
    function ctor(address seawaterAdmin, address nftManager, address emergencyCouncil) external;
}

interface ISeawaterExecutorFallback {}

// sol/ISeawaterAMM.sol
// SPDX-Identifier: MIT

// ISeawaterAMM is the public facing interface for the SeawaterAMM
interface ISeawaterAMM is
    ISeawaterEvents,
    ISeawaterExecutorSwap,
    ISeawaterExecutorSwapPermit2,
    ISeawaterExecutorQuote,
    ISeawaterExecutorPosition,
    ISeawaterExecutorUpdatePosition,
    ISeawaterExecutorAdminExposed
    {
    /// @notice swaps _token for USDC
    /// @param _token the token to swap
    /// @param _amount input amount (token)
    /// @param _minOut the minimum output amount (usdc), reverting if the actual output is lower
    /// @return amount of usdc out
    function swapIn32502CA71(
        address _token,
        uint256 _amount,
        uint256 _minOut
    ) external returns (int256, int256);

    /// @notice swaps _token for USDC
    /// @param _token the token to swap
    /// @param _amount input amount (token)
    /// @param _minOut the minimum output amount (usdc), reverting if the actual output is lower
    /// @param _nonce the nonce for the token
    /// @param _deadline the deadline for the token
    /// @param _sig the signature for the token
    /// @param _maxAmount the max amount of the token
    /// @return amount of usdc out
    function swapInPermit2CEAAB576(
        address _token,
        uint256 _amount,
        uint256 _minOut,
        uint256 _nonce,
        uint256 _deadline,
        uint256 _maxAmount,
        bytes memory _sig
    ) external returns (int256, int256);

    /// @notice swaps USDC for _token
    /// @param _token the token to swap
    /// @param _amount input amount (usdc)
    /// @param _minOut the minimum output amount (token), reverting if the actual output is lower
    /// @return amount of token out
    function swapOut5E08A399(
        address _token,
        uint256 _amount,
        uint256 _minOut
    ) external returns (int256, int256);

    /// @notice swaps USDC for _token
    /// @param _token the token to swap
    /// @param _amount input amount (usdc)
    /// @param _minOut the minimum output amount (token), reverting if the actual output is lower
    /// @param _nonce the nonce for the token
    /// @param _deadline the deadline for the token
    /// @param _sig the signature for the token
    /// @param _maxAmount the max amount of the token
    /// @return amount of token out
    function swapOutPermit23273373B(
        address _token,
        uint256 _amount,
        uint256 _minOut,
        uint256 _nonce,
        uint256 _deadline,
        uint256 _maxAmount,
        bytes memory _sig
    ) external returns (int256, int256);

    /// @notice swaps tokenA for tokenB
    /// @param _tokenA the input token
    /// @param _tokenB the output token
    /// @param _amount input amount (tokenA)
    /// @param _minOut the minimum output amount (tokenB), reverting if the actual output is lower
    /// @return amount of token A in, amount of token B out
    function swap2ExactIn41203F1D(
        address _tokenA,
        address _tokenB,
        uint256 _amount,
        uint256 _minOut
    ) external returns (uint256, uint256);
}

// sol/OwnershipNFTs.sol
// SPDX-Identifier: MIT

/*
 * OwnershipNFTs is a simple interface for tracking ownership of
 * positions in the Seawater Stylus contract.
 */
contract OwnershipNFTs is IERC721Metadata {
    ISeawaterAMM immutable public SEAWATER;

    /**
     * @notice TOKEN_URI to set as the default token URI for every NFT
     * @dev immutable in practice (not set anywhere)
     */
    string public TOKEN_URI;

    /// @notice name of the NFT, set by the constructor
    string public name;

    /// @notice symbol of the NFT, set during the constructor
    string public symbol;

    /**
     * @notice getApproved that can spend the id of the tokens given
     * @dev required in the NFT spec and we simplify the use here by
     *      naming the storage slot as such
     */
    mapping(uint256 => address) public getApproved;

    /// @notice isApprovedForAll[owner][spender] == true if `spender` can spend any of `owner`'s NFTs
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        ISeawaterAMM _seawater
    ) {
        name = _name;
        symbol = _symbol;
        TOKEN_URI = _tokenURI;
        SEAWATER = _seawater;
    }

    /**
     * @notice ownerOf a NFT given by looking it up with the tracked Seawater contract
     * @param _tokenId to look up
     */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        (bool ok, bytes memory rc) = address(SEAWATER).staticcall(abi.encodeWithSelector(
            SEAWATER.positionOwnerD7878480.selector,
            _tokenId
        ));
        require(ok, "position owner revert");
        (address owner) = abi.decode(rc, (address));
        return owner;
    }

    /**
     * @notice _onTransferReceived by calling the callback `onERC721Received`
     *         in the recipient if they have codesize > 0. if the callback
     *         doesn't return the selector, revert!
     * @param _sender that did the transfer
     * @param _from owner of the NFT that the sender is transferring
     * @param _to recipient of the NFT that we're calling the function on
     * @param _tokenId that we're transferring from our internal storage
     */
    function _onTransferReceived(
        address _sender,
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        // only call the callback if the receiver is a contract
        if (_to.code.length == 0) return;

        bytes4 data = IERC721TokenReceiver(_to).onERC721Received(
            _sender,
            _from,
            _tokenId,

            // this is empty byte data that can be optionally passed to
            // the contract we're confirming is able to receive NFTs
            ""
        );

        require(
            data != IERC721TokenReceiver.onERC721Received.selector,
            "bad nft transfer received data"
        );
    }

    function _requireAuthorised(address _from, uint256 _tokenId) internal view {
        // revert if the sender is not authorised or the owner
        bool isAllowed =
            msg.sender == _from ||
            isApprovedForAll[_from][msg.sender] ||
            msg.sender == getApproved[_tokenId];

        require(isAllowed, "not allowed");
        require(ownerOf(_tokenId) == _from, "_from is not the owner!");
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        _requireAuthorised(_from, _tokenId);
        SEAWATER.transferPositionEEC7A3CD(_tokenId, _from, _to);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata /* _data */
    ) external payable {
        // checks that the user is authorised
        _transfer(_from, _to, _tokenId);
    }

    /// @inheritdoc IERC721Metadata
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        // checks that the user is authorised
        _transfer(_from, _to, _tokenId);
    }

    /// @inheritdoc IERC721Metadata
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transfer(_from, _to, _tokenId);
        _onTransferReceived(msg.sender, _from, _to, _tokenId);
    }

    /// @inheritdoc IERC721Metadata
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata /* _data */
    ) external payable {
        _transfer(_from, _to, _tokenId);
        _onTransferReceived(msg.sender, _from, _to, _tokenId);
    }

    /// @inheritdoc IERC721Metadata
    function approve(address _approved, uint256 _tokenId) external payable {
        _requireAuthorised(msg.sender, _tokenId);
        getApproved[_tokenId] = _approved;
    }

    /// @inheritdoc IERC721Metadata
    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;
    }

    /// @inheritdoc IERC721Metadata
    function balanceOf(address _spender) external view returns (uint256) {
        (bool ok, bytes memory rc) = address(SEAWATER).staticcall(abi.encodeWithSelector(
            SEAWATER.positionBalance4F32C7DB.selector,
            _spender
        ));
        require(ok, "position balance revert");
        (uint256 balance) = abi.decode(rc, (uint256));
        return balance;
    }

    /// @inheritdoc IERC721Metadata
    function tokenURI(uint256 /* _tokenId */) external view returns (string memory) {
        return TOKEN_URI;
    }
}

