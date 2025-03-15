// SPDX-License-Identifier: MIT
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

// lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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

// lib/solidity-examples/contracts/token/oft/v2/interfaces/IOFTReceiverV2.sol

interface IOFTReceiverV2 {
    /**
     * @dev Called by the OFT contract when tokens are received from source chain.
     * @param _srcChainId The chain id of the source chain.
     * @param _srcAddress The address of the OFT token contract on the source chain.
     * @param _nonce The nonce of the transaction on the source chain.
     * @param _from The address of the account who calls the sendAndCall() on the source chain.
     * @param _amount The amount of tokens to transfer.
     * @param _payload Additional data with no specified format.
     */
    function onOFTReceived(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes32 _from, uint _amount, bytes calldata _payload) external;
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

// src/interfaces/IDecentEthRouter.sol

interface IDecentEthRouter {

    event ReceivedDecentEth(
        uint8 msgType,
        uint16 _srcChainId,
        address from,
        address _to,
        uint amount,
        bytes payload
    );

    function MT_ETH_TRANSFER() external view returns (uint8);

    function MT_ETH_TRANSFER_WITH_PAYLOAD() external view returns (uint8);

    /**
     * @dev Sets dcntEth to the router
     * @param _addr The address of the deployed DcntEth token
     */
    function registerDcntEth(address _addr) external;

    /**
     * @dev Adds a destination bridge for the bridge
     * @param _dstChainId The lz chainId
     * @param _routerAddress The router address on the dst chain
     */
    function addDestinationBridge(
        uint16 _dstChainId,
        address _routerAddress
    ) external;

    function estimateSendAndCallFee(
        uint8 msgType,
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth,
        bytes memory payload
    ) external view returns (uint nativeFee, uint zroFee);

    /**
     * @param _dstChainId lz endpoint
     * @param _toAddress the destination address (i.e. dst bridge)
     * @param _amount the amount being bridged
     * @param deliverEth if false, delivers WETH
     * @param _dstGasForCall the amount of dst gas
     * @param additionalPayload contains the refundAddress, zroPaymentAddress, and adapterParams
     */
    function bridgeWithPayload(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        bool deliverEth,
        uint64 _dstGasForCall,
        bytes memory additionalPayload
    ) external payable;

    /**
     * @param _dstChainId lz endpoint
     * @param _toAddress destination address
     * @param _amount the amount being bridge
     * @param _dstGasForCall the amount of dst gas
     * @param deliverEth if false, delivers WETH
     */
    function bridge(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth // if false, delivers WETH
    ) external payable;

    /**
     * @dev allows users to redeem their dcntEth for ETH
     * @param amount the amount to be redeemed
     */
    function redeemEth(uint256 amount) external;

    /**
     * @dev allows users to redeem their dcntEth for WETH
     * @param amount the amount to be redeemed
     */
    function redeemWeth(uint256 amount) external;

    /**
     * @dev adds bridge liquidity by paying ETH
     */
    function addLiquidityEth() external payable;

    /**
     * @dev withdraws a users bridge liquidity for ETH
     * @param amount the amount to be redeemed
     */
    function removeLiquidityEth(uint256 amount) external;

    /**
     * @dev adds bridge liquidity by providing WETH
     * @param amount the amount to be added
     */
    function addLiquidityWeth(uint256 amount) external payable;

    /**
     * @dev withdraws a users bridge liquidity for WETH
     * @param amount the amount to be redeemed
     */
    function removeLiquidityWeth(uint256 amount) external;
}

// lib/solidity-examples/contracts/token/oft/v2/interfaces/ICommonOFT.sol

/**
 * @dev Interface of the IOFT core standard
 */
interface ICommonOFT is IERC165 {

    struct LzCallParams {
        address payable refundAddress;
        address zroPaymentAddress;
        bytes adapterParams;
    }

    /**
     * @dev estimate send token `_tokenId` to (`_dstChainId`, `_toAddress`)
     * _dstChainId - L0 defined chain id to send tokens too
     * _toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
     * _amount - amount of the tokens to transfer
     * _useZro - indicates to use zro to pay L0 fees
     * _adapterParam - flexible bytes array to indicate messaging adapter services in L0
     */
    function estimateSendFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);

    function estimateSendAndCallFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);

    /**
     * @dev returns the circulating amount of tokens on current chain
     */
    function circulatingSupply() external view returns (uint);

    /**
     * @dev returns the address of the ERC20 token
     */
    function token() external view returns (address);
}

// src/interfaces/IWETH.sol

interface IWETH is IERC20 {

    function deposit() external payable;

    function withdraw(uint) external;
}

// lib/solidity-examples/contracts/token/oft/v2/interfaces/IOFTV2.sol

/**
 * @dev Interface of the IOFT core standard
 */
interface IOFTV2 is ICommonOFT {

    /**
     * @dev send `_amount` amount of token to (`_dstChainId`, `_toAddress`) from `_from`
     * `_from` the owner of token
     * `_dstChainId` the destination chain identifier
     * `_toAddress` can be any size depending on the `dstChainId`.
     * `_amount` the quantity of tokens in wei
     * `_refundAddress` the address LayerZero refunds if too much message fee is sent
     * `_zroPaymentAddress` set to address(0x0) if not paying in ZRO (LayerZero Token)
     * `_adapterParams` is a flexible bytes array to indicate messaging adapter services
     */
    function sendFrom(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, LzCallParams calldata _callParams) external payable;

    function sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, LzCallParams calldata _callParams) external payable;
}

// src/interfaces/IDcntEth.sol

interface IDcntEth is IOFTV2, IERC20 {

    function setRouter(address _router) external;

    function mint(address _to, uint256 _amount) external;

    function burn(address _from, uint256 _amount) external;

    function mintByOwner(address _to, uint256 _amount) external;

    function burnByOwner(address _from, uint256 _amount) external;
}

// src/interfaces/IDecentBridgeExecutor.sol

interface IDecentBridgeExecutor {

    /**
     * @dev called upon receiving dcntEth in the DecentEthRouter
     * @param from the senders address for refund
     * @param target target contract
     * @param deliverEth delivers WETH if false
     * @param amount amount of the transaction
     * @param callPayload payload for the tx
     */
    function execute(
      address from,
      address target,
      bool deliverEth,
      uint256 amount,
      bytes memory callPayload
    ) external;
}

// src/DecentEthRouter.sol

contract DecentEthRouter is IDecentEthRouter, IOFTReceiverV2, Owned {
    IWETH public weth;
    IDcntEth public dcntEth;
    IDecentBridgeExecutor public executor;

    uint8 public constant MT_ETH_TRANSFER = 0;
    uint8 public constant MT_ETH_TRANSFER_WITH_PAYLOAD = 1;

    uint16 public constant PT_SEND_AND_CALL = 1;

    bool public gasCurrencyIsEth; // for chains that use ETH as gas currency

    mapping(uint16 => address) public destinationBridges;
    mapping(address => uint256) public balanceOf;

    constructor(
        address payable _wethAddress,
        bool gasIsEth,
        address _executor
    ) Owned(msg.sender) {
        weth = IWETH(_wethAddress);
        gasCurrencyIsEth = gasIsEth;
        executor = IDecentBridgeExecutor(payable(_executor));
    }

    modifier onlyEthChain() {
        require(gasCurrencyIsEth, "Gas currency is not ETH");
        _;
    }

    modifier onlyLzApp() {
        require(
            address(dcntEth) == msg.sender,
            "DecentEthRouter: only lz App can call"
        );
        _;
    }

    modifier onlyIfWeHaveEnoughReserves(uint256 amount) {
        require(weth.balanceOf(address(this)) > amount, "not enough reserves");
        _;
    }

    modifier userDepositing(uint256 amount) {
        balanceOf[msg.sender] += amount;
        _;
    }

    modifier userIsWithdrawing(uint256 amount) {
        uint256 balance = balanceOf[msg.sender];
        require(balance >= amount, "not enough balance");
        _;
        balanceOf[msg.sender] -= amount;
    }

    /// @inheritdoc IDecentEthRouter
    function registerDcntEth(address _addr) public onlyOwner {
        dcntEth = IDcntEth(_addr);
    }

    /// @inheritdoc IDecentEthRouter
    function addDestinationBridge(
        uint16 _dstChainId,
        address _routerAddress
    ) public onlyOwner {
        destinationBridges[_dstChainId] = _routerAddress;
    }

    function _getCallParams(
        uint8 msgType,
        address _toAddress,
        uint16 _dstChainId,
        uint64 _dstGasForCall,
        bool deliverEth,
        bytes memory additionalPayload
    )
        private
        view
        returns (
            bytes32 destBridge,
            bytes memory adapterParams,
            bytes memory payload
        )
    {
        uint256 GAS_FOR_RELAY = 100000;
        uint256 gasAmount = GAS_FOR_RELAY + _dstGasForCall;
        adapterParams = abi.encodePacked(PT_SEND_AND_CALL, gasAmount);
        destBridge = bytes32(abi.encode(destinationBridges[_dstChainId]));
        if (msgType == MT_ETH_TRANSFER) {
            payload = abi.encode(msgType, msg.sender, _toAddress, deliverEth);
        } else {
            payload = abi.encode(
                msgType,
                msg.sender,
                _toAddress,
                deliverEth,
                additionalPayload
            );
        }
    }

    function estimateSendAndCallFee(
        uint8 msgType,
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth,
        bytes memory payload
    ) public view returns (uint nativeFee, uint zroFee) {
        (
            bytes32 destinationBridge,
            bytes memory adapterParams,
            bytes memory _payload
        ) = _getCallParams(
                msgType,
                _toAddress,
                _dstChainId,
                _dstGasForCall,
                deliverEth,
                payload
            );

        return
            dcntEth.estimateSendAndCallFee(
                _dstChainId,
                destinationBridge,
                _amount,
                _payload,
                _dstGasForCall,
                false, // useZero
                adapterParams // Relayer adapter parameters
                // contains packet type (send and call in this case) and gasAmount
            );
    }

    function _bridgeWithPayload(
        uint8 msgType,
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bytes memory additionalPayload,
        bool deliverEth
    ) internal {
        (
            bytes32 destinationBridge,
            bytes memory adapterParams,
            bytes memory payload
        ) = _getCallParams(
                msgType,
                _toAddress,
                _dstChainId,
                _dstGasForCall,
                deliverEth,
                additionalPayload
            );

        ICommonOFT.LzCallParams memory callParams = ICommonOFT.LzCallParams({
            refundAddress: payable(msg.sender),
            zroPaymentAddress: address(0x0),
            adapterParams: adapterParams
        });

        uint gasValue;
        if (gasCurrencyIsEth) {
            weth.deposit{value: _amount}();
            gasValue = msg.value - _amount;
        } else {
            weth.transferFrom(msg.sender, address(this), _amount);
            gasValue = msg.value;
        }

        dcntEth.sendAndCall{value: gasValue}(
            address(this), // from address that has dcntEth (so DecentRouter)
            _dstChainId,
            destinationBridge, // toAddress
            _amount, // amount
            payload, //payload (will have recipients address)
            _dstGasForCall, // dstGasForCall
            callParams // refundAddress, zroPaymentAddress, adapterParams
        );
    }

    /// @inheritdoc IDecentEthRouter
    function bridgeWithPayload(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        bool deliverEth,
        uint64 _dstGasForCall,
        bytes memory additionalPayload
    ) public payable {
        return
            _bridgeWithPayload(
                MT_ETH_TRANSFER_WITH_PAYLOAD,
                _dstChainId,
                _toAddress,
                _amount,
                _dstGasForCall,
                additionalPayload,
                deliverEth
            );
    }

    /// @inheritdoc IDecentEthRouter
    function bridge(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth // if false, delivers WETH
    ) public payable {
        _bridgeWithPayload(
            MT_ETH_TRANSFER,
            _dstChainId,
            _toAddress,
            _amount,
            _dstGasForCall,
            bytes(""),
            deliverEth
        );
    }

    /// @inheritdoc IOFTReceiverV2
    function onOFTReceived(
        uint16 _srcChainId,
        bytes calldata,
        uint64,
        bytes32,
        uint _amount,
        bytes memory _payload
    ) external override onlyLzApp {
        (uint8 msgType, address _from, address _to, bool deliverEth) = abi
            .decode(_payload, (uint8, address, address, bool));

        bytes memory callPayload = "";

        if (msgType == MT_ETH_TRANSFER_WITH_PAYLOAD) {
            (, , , , callPayload) = abi.decode(
                _payload,
                (uint8, address, address, bool, bytes)
            );
        }

        emit ReceivedDecentEth(
            msgType,
            _srcChainId,
            _from,
            _to,
            _amount,
            callPayload
        );

        if (weth.balanceOf(address(this)) < _amount) {
            dcntEth.transfer(_to, _amount);
            return;
        }

        if (msgType == MT_ETH_TRANSFER) {
            if (!gasCurrencyIsEth || !deliverEth) {
                weth.transfer(_to, _amount);
            } else {
                weth.withdraw(_amount);
                payable(_to).transfer(_amount);
            }
        } else {
            weth.approve(address(executor), _amount);
            executor.execute(_from, _to, deliverEth, _amount, callPayload);
        }
    }

    /// @inheritdoc IDecentEthRouter
    function redeemEth(
        uint256 amount
    ) public onlyIfWeHaveEnoughReserves(amount) {
        dcntEth.transferFrom(msg.sender, address(this), amount);
        weth.withdraw(amount);
        payable(msg.sender).transfer(amount);
    }

    /// @inheritdoc IDecentEthRouter
    function redeemWeth(
        uint256 amount
    ) public onlyIfWeHaveEnoughReserves(amount) {
        dcntEth.transferFrom(msg.sender, address(this), amount);
        weth.transfer(msg.sender, amount);
    }

    /// @inheritdoc IDecentEthRouter
    function addLiquidityEth()
        public
        payable
        onlyEthChain
        userDepositing(msg.value)
    {
        weth.deposit{value: msg.value}();
        dcntEth.mint(address(this), msg.value);
    }

    /// @inheritdoc IDecentEthRouter
    function removeLiquidityEth(
        uint256 amount
    ) public onlyEthChain userIsWithdrawing(amount) {
        dcntEth.burn(address(this), amount);
        weth.withdraw(amount);
        payable(msg.sender).transfer(amount);
    }

    /// @inheritdoc IDecentEthRouter
    function addLiquidityWeth(
        uint256 amount
    ) public payable userDepositing(amount) {
        weth.transferFrom(msg.sender, address(this), amount);
        dcntEth.mint(address(this), amount);
    }

    /// @inheritdoc IDecentEthRouter
    function removeLiquidityWeth(
        uint256 amount
    ) public userIsWithdrawing(amount) {
        dcntEth.burn(address(this), amount);
        weth.transfer(msg.sender, amount);
    }

    receive() external payable {}

    fallback() external payable {}
}

