// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// lib/forge-std/src/interfaces/IERC20.sol

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERC20 {
    /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
    /// is the new allowance.
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /// @notice Returns the amount of tokens in existence.
    function totalSupply() external view returns (uint256);

    /// @notice Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    /// @notice Moves `amount` tokens from the caller's account to `to`.
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining number of tokens that `spender` is allowed
    /// to spend on behalf of `owner`
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
    /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
    /// `amount` is then deducted from the caller's allowance.
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Returns the name of the token.
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token.
    function symbol() external view returns (string memory);

    /// @notice Returns the decimals places of the token.
    function decimals() external view returns (uint8);
}

// lib/solmate/src/auth/Owned.sol

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// src/CommonTypes.sol

struct SwapInstructions {
    uint8 swapperId;
    bytes swapPayload;
}

struct FeeStructure {
    uint bridgeFee;
    address feeToken;
    uint feeAmount;
}

struct SwapAndExecuteInstructions {
    SwapInstructions swapInstructions;
    address target;
    address paymentOperator;
    address payable refund;
    bytes payload;
}

struct BridgeInstructions {
    SwapInstructions preBridge;
    SwapInstructions postBridge;
    uint8 bridgeId;
    uint256 dstChainId;
    address target;
    address paymentOperator;
    address payable refund;
    bytes payload;
    bytes additionalArgs;
}

// src/interfaces/IUTBExecutor.sol

interface IUTBExecutor {

    function execute(
        address target,
        address paymentOperator,
        bytes memory payload,
        address token,
        uint256 amount,
        address refund
    ) external payable;

    function execute(
        address target,
        address paymentOperator,
        bytes memory payload,
        address token,
        uint256 amount,
        address refund,
        uint256 extraNative
    ) external;
}

// src/swappers/SwapParams.sol

library SwapDirection {
    uint8 constant EXACT_IN = 0;
    uint8 constant EXACT_OUT = 1;
}

struct SwapParams {
    uint256 amountIn;
    uint256 amountOut;
    address tokenIn;
    address tokenOut;
    uint8 direction;
    // if direction is exactAmountIn
    // then amount out will be the minimum amount out
    // if direction is exactAmountOutA
    // then amount in is maximum amount in
    bytes path;
}

// lib/decent-bridge/src/interfaces/IWETH.sol

interface IWETH is IERC20 {

    function deposit() external payable;

    function withdraw(uint) external;
}

// src/interfaces/IBridgeAdapter.sol

interface IBridgeAdapter {
    function getId() external returns (uint8);

    function getBridgeToken(
        bytes calldata additionalArgs
    ) external returns (address);

    function getBridgedAmount(
        uint256 amt2Bridge,
        address preBridgeToken,
        address postBridgeToken
    ) external returns (uint256);

    function bridge(
        uint256 amt2Bridge,
        SwapInstructions memory postBridge,
        uint256 dstChainId,
        address target,
        address paymentOperator,
        bytes memory payload,
        bytes calldata additionalArgs,
        address payable refund
    ) external payable returns (bytes memory);
}

// src/interfaces/IUTBFeeCollector.sol

interface IUTBFeeCollector {

    function collectFees(
      FeeStructure memory fees,
      bytes memory packedInfo,
      bytes memory signature
    ) external payable;

    function redeemFees(address token, uint256 amount) external;

    function setSigner(address _signer) external;

    function setUtb(address _utb) external;
}

// src/interfaces/ISwapper.sol

interface ISwapper {
    function getId() external returns (uint8);

    function swap(
        bytes memory swapPayload
    ) external returns (address tokenOut, uint256 amountOut);

    function updateSwapParams(
        SwapParams memory newSwapParams,
        bytes memory payload
    ) external returns (bytes memory);
}

// src/UTB.sol

contract UTB is Owned {
    constructor() Owned(msg.sender) {}

    IUTBExecutor executor;
    IUTBFeeCollector feeCollector;
    IWETH wrapped;
    mapping(uint8 => address) public swappers;
    mapping(uint8 => address) public bridgeAdapters;

    /**
     * @dev Sets the executor.
     * @param _executor The address of the executor.
     */
    function setExecutor(address _executor) public onlyOwner {
        executor = IUTBExecutor(_executor);
    }

    /**
     * @dev Sets the wrapped native token.
     * @param _wrapped The address of the wrapped token.
     */
    function setWrapped(address payable _wrapped) public onlyOwner {
        wrapped = IWETH(_wrapped);
    }

    /**
     * @dev Sets the fee collector.
     * @param _feeCollector The address of the fee collector.
     */
    function setFeeCollector(address payable _feeCollector) public onlyOwner {
        feeCollector = IUTBFeeCollector(_feeCollector);
    }

    /**
     * @dev Performs a swap with a default setting to retrieve ERC20.
     * @param swapInstructions The swapper ID and calldata to execute a swap.
     */
    function performSwap(
        SwapInstructions memory swapInstructions
    ) private returns (address tokenOut, uint256 amountOut) {
        return performSwap(swapInstructions, true);
    }

    /**
     * @dev Performs a swap with the requested swapper and swap calldata.
     * @param swapInstructions The swapper ID and calldata to execute a swap.
     * @param retrieveTokenIn Flag indicating whether to transfer ERC20 for the swap.
     */
    function performSwap(
        SwapInstructions memory swapInstructions,
        bool retrieveTokenIn
    ) private returns (address tokenOut, uint256 amountOut) {
        ISwapper swapper = ISwapper(swappers[swapInstructions.swapperId]);

        SwapParams memory swapParams = abi.decode(
            swapInstructions.swapPayload,
            (SwapParams)
        );

        if (swapParams.tokenIn == address(0)) {
            require(msg.value >= swapParams.amountIn, "not enough native");
            wrapped.deposit{value: swapParams.amountIn}();
            swapParams.tokenIn = address(wrapped);
            swapInstructions.swapPayload = swapper.updateSwapParams(
                swapParams,
                swapInstructions.swapPayload
            );
        } else if (retrieveTokenIn) {
            IERC20(swapParams.tokenIn).transferFrom(
                msg.sender,
                address(this),
                swapParams.amountIn
            );
        }

        IERC20(swapParams.tokenIn).approve(
            address(swapper),
            swapParams.amountIn
        );

        (tokenOut, amountOut) = swapper.swap(swapInstructions.swapPayload);

        if (tokenOut == address(0)) {
            wrapped.withdraw(amountOut);
        }
    }

    /**
     * @dev Swaps currency from the incoming to the outgoing token and executes a transaction with payment.
     * @param instructions The token swap data and payment transaction payload.
     * @param fees The bridge fee in native, as well as utb fee token and amount.
     * @param signature The ECDSA signature to verify the fee structure.
     */
    function swapAndExecute(
        SwapAndExecuteInstructions calldata instructions,
        FeeStructure calldata fees,
        bytes calldata signature
    )
        public
        payable
        retrieveAndCollectFees(fees, abi.encode(instructions, fees), signature)
    {
        _swapAndExecute(
            instructions.swapInstructions,
            instructions.target,
            instructions.paymentOperator,
            instructions.payload,
            instructions.refund
        );
    }

    /**
     * @dev Swaps currency from the incoming to the outgoing token and executes a transaction with payment.
     * @param swapInstructions The swapper ID and calldata to execute a swap.
     * @param target The address of the target contract for the payment transaction.
     * @param paymentOperator The operator address for payment transfers requiring ERC20 approvals.
     * @param payload The calldata to execute the payment transaction.
     * @param refund The account receiving any refunds, typically the EOA which initiated the transaction.
     */
    function _swapAndExecute(
        SwapInstructions memory swapInstructions,
        address target,
        address paymentOperator,
        bytes memory payload,
        address payable refund
    ) private {
        (address tokenOut, uint256 amountOut) = performSwap(swapInstructions);
        if (tokenOut == address(0)) {
            executor.execute{value: amountOut}(
                target,
                paymentOperator,
                payload,
                tokenOut,
                amountOut,
                refund
            );
        } else {
            IERC20(tokenOut).approve(address(executor), amountOut);
            executor.execute(
                target,
                paymentOperator,
                payload,
                tokenOut,
                amountOut,
                refund
            );
        }
    }

    /**
     * @dev Performs the pre bridge swap and modifies the post bridge swap to utilize the bridged amount.
     * @param instructions The bridge data, token swap data, and payment transaction payload.
     */
    function swapAndModifyPostBridge(
        BridgeInstructions memory instructions
    )
        private
        returns (
            uint256 amount2Bridge,
            BridgeInstructions memory updatedInstructions
        )
    {
        (address tokenOut, uint256 amountOut) = performSwap(
            instructions.preBridge
        );

        SwapParams memory newPostSwapParams = abi.decode(
            instructions.postBridge.swapPayload,
            (SwapParams)
        );

        newPostSwapParams.amountIn = IBridgeAdapter(
            bridgeAdapters[instructions.bridgeId]
        ).getBridgedAmount(amountOut, tokenOut, newPostSwapParams.tokenIn);

        updatedInstructions = instructions;

        updatedInstructions.postBridge.swapPayload = ISwapper(swappers[
            instructions.postBridge.swapperId
        ]).updateSwapParams(
            newPostSwapParams,
            instructions.postBridge.swapPayload
        );

        amount2Bridge = amountOut;
    }

    /**
     * @dev Checks if the bridge token is native, and approves the bridge adapter to transfer ERC20 if required.
     * @param instructions The bridge data, token swap data, and payment transaction payload.
     * @param amt2Bridge The amount of the bridge token being transferred to the bridge adapter.
     */
    function approveAndCheckIfNative(
        BridgeInstructions memory instructions,
        uint256 amt2Bridge
    ) private returns (bool) {
        IBridgeAdapter bridgeAdapter = IBridgeAdapter(bridgeAdapters[instructions.bridgeId]);
        address bridgeToken = bridgeAdapter.getBridgeToken(
            instructions.additionalArgs
        );
        if (bridgeToken != address(0)) {
            IERC20(bridgeToken).approve(address(bridgeAdapter), amt2Bridge);
            return false;
        }
        return true;
    }

    /**
     * @dev Transfers fees from the sender to UTB, and finally to the Fee Collector.
     * @param fees The bridge fee in native, as well as utb fee token and amount.
     * @param packedInfo The fees and swap instructions which were used to generate the signature.
     * @param signature The ECDSA signature to verify the fee structure.
     */
    modifier retrieveAndCollectFees(
        FeeStructure calldata fees,
        bytes memory packedInfo,
        bytes calldata signature
    ) {
        if (address(feeCollector) != address(0)) {
            uint value = 0;
            if (fees.feeToken != address(0)) {
                IERC20(fees.feeToken).transferFrom(
                    msg.sender,
                    address(this),
                    fees.feeAmount
                );
                IERC20(fees.feeToken).approve(
                    address(feeCollector),
                    fees.feeAmount
                );
            } else {
                value = fees.feeAmount;
            }
            feeCollector.collectFees{value: value}(fees, packedInfo, signature);
        }
        _;
    }

    /**
     * @dev Bridges funds in native or ERC20 and a payment transaction payload to the destination chain
     * @param instructions The bridge data, token swap data, and payment transaction payload.
     * @param fees The bridge fee in native, as well as utb fee token and amount.
     * @param signature The ECDSA signature to verify the fee structure.
     */
    function bridgeAndExecute(
        BridgeInstructions calldata instructions,
        FeeStructure calldata fees,
        bytes calldata signature
    )
        public
        payable
        retrieveAndCollectFees(fees, abi.encode(instructions, fees), signature)
        returns (bytes memory)
    {
        (
            uint256 amt2Bridge,
            BridgeInstructions memory updatedInstructions
        ) = swapAndModifyPostBridge(instructions);
        return callBridge(amt2Bridge, fees.bridgeFee, updatedInstructions);
    }

    /**
     * @dev Calls the bridge adapter to bridge funds, and approves the bridge adapter to transfer ERC20 if required.
     * @param amt2Bridge The amount of the bridge token being bridged via the bridge adapter.
     * @param bridgeFee The fee being transferred to the bridge adapter and finally to the bridge.
     * @param instructions The bridge data, token swap data, and payment transaction payload.
     */
    function callBridge(
        uint256 amt2Bridge,
        uint bridgeFee,
        BridgeInstructions memory instructions
    ) private returns (bytes memory) {
        bool native = approveAndCheckIfNative(instructions, amt2Bridge);
        return
            IBridgeAdapter(bridgeAdapters[instructions.bridgeId]).bridge{
                value: bridgeFee + (native ? amt2Bridge : 0)
            }(
                amt2Bridge,
                instructions.postBridge,
                instructions.dstChainId,
                instructions.target,
                instructions.paymentOperator,
                instructions.payload,
                instructions.additionalArgs,
                instructions.refund
            );
    }

    /**
     * @dev Receives funds from the bridge adapter, executes a swap, and executes a payment transaction.
     * @param postBridge The swapper ID and calldata to execute a swap.
     * @param target The address of the target contract for the payment transaction.
     * @param paymentOperator The operator address for payment transfers requiring ERC20 approvals.
     * @param payload The calldata to execute the payment transaction.
     * @param refund The account receiving any refunds, typically the EOA which initiated the transaction.
     */
    function receiveFromBridge(
        SwapInstructions memory postBridge,
        address target,
        address paymentOperator,
        bytes memory payload,
        address payable refund
    ) public {
        _swapAndExecute(postBridge, target, paymentOperator, payload, refund);
    }

    /**
     * @dev Registers and maps a swapper to a swapper ID.
     * @param swapper The address of the swapper.
     */
    function registerSwapper(address swapper) public onlyOwner {
        ISwapper s = ISwapper(swapper);
        swappers[s.getId()] = swapper;
    }

    /**
     * @dev Registers and maps a bridge adapter to a bridge adapter ID.
     * @param bridge The address of the bridge adapter.
     */
    function registerBridge(address bridge) public onlyOwner {
        IBridgeAdapter b = IBridgeAdapter(bridge);
        bridgeAdapters[b.getId()] = bridge;
    }

    receive() external payable {}

    fallback() external payable {}
}

