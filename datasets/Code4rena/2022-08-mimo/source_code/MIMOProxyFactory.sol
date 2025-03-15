// Sources flattened with hardhat v2.9.9 https://hardhat.org

// File @openzeppelin/contracts/proxy/Clones.sol@v4.6.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/Clones.sol)

pragma solidity ^0.8.10;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File contracts/proxy/interfaces/IMIMOProxy.sol




/// @title IMIMOProxy
/// @notice Proxy contract to compose transactions on owner's behalf.
interface IMIMOProxy {
  /// EVENTS ///

  event Execute(address indexed target, bytes data, bytes response);

  event TransferOwnership(address indexed oldOwner, address indexed newOwner);

  /// PUBLIC CONSTANT FUNCTIONS ///

  /// @notice Initializes the MIMOProxy contract
  /// @dev This replaces the constructor function and can only be called once per contract instance 
  function initialize() external;

  /// @notice Returns a boolean flag that indicates whether the envoy has permission to call the given target contract's given selector method 
  /// @param envoy The caller 
  /// @param target The target contract called by the envoy  
  /// @param selector The selector of the method of the target contract called by the envoy
  /// contract and function selector.
  function getPermission(
    address envoy,
    address target,
    bytes4 selector
  ) external view returns (bool);

  /// @notice The address of the owner account or contract.
  function owner() external view returns (address);

  /// @notice How much gas to reserve for running the remainder of the "execute" function after the DELEGATECALL.
  /// @dev This prevents the proxy from becoming unusable if EVM opcode gas costs change in the future.
  function minGasReserve() external view returns (uint256);

  /// PUBLIC NON-CONSTANT FUNCTIONS ///

  /// @notice Delegate calls to the target contract by forwarding the call data. Returns the data it gets back,
  /// including when the contract call reverts with a reason or custom error.
  ///
  /// @dev Requirements:
  /// - The caller must be either an owner or an envoy.
  /// - `target` must be a deployed contract.
  /// - The owner cannot be changed during the DELEGATECALL.
  ///
  /// @param target The address of the target contract.
  /// @param data Function selector plus ABI encoded data.
  /// @return response The response received from the target contract.
  function execute(address target, bytes calldata data) external payable returns (bytes memory response);

  /// @notice Gives or takes a permission from an envoy to call the given target contract and function selector
  /// on behalf of the owner.
  /// @dev It is not an error to reset a permission on the same (envoy,target,selector) tuple multiple types.
  ///
  /// Requirements:
  /// - The caller must be the owner.
  ///
  /// @param envoy The address of the envoy account.
  /// @param target The address of the target contract.
  /// @param selector The 4 byte function selector on the target contract.
  /// @param permission The boolean permission to set.
  function setPermission(
    address envoy,
    address target,
    bytes4 selector,
    bool permission
  ) external;

  /// @notice Transfers the owner of the contract to a new account.
  /// @dev Requirements:
  /// - The caller must be the owner.
  /// @param newOwner The address of the new owner account.
  function transferOwnership(address newOwner) external;

  /// @notice Batches multiple proxy calls within a same transaction. 
  /// @param targets An array of contract addresses to call 
  /// @param data The bytes for each batched function call 
  function multicall(address[] calldata targets, bytes[] calldata data) external returns (bytes[] memory);
}


// File contracts/proxy/interfaces/IMIMOProxyFactory.sol




/// @title IMIMOProxyFactory
/// @notice Deploys new proxies with CREATE2.
interface IMIMOProxyFactory {
  /// EVENTS ///

  event DeployProxy(address indexed deployer, address indexed owner, address proxy);

  /// PUBLIC CONSTANT FUNCTIONS ///

  /// @notice Mapping to track all deployed proxies.
  /// @param proxy The address of the proxy to make the check for.
  function isProxy(address proxy) external view returns (bool result);

  /// @notice The release version of PRBProxy.
  /// @dev This is stored in the factory rather than the proxy to save gas for end users.
  function VERSION() external view returns (uint256);

  /// PUBLIC NON-CONSTANT FUNCTIONS ///

  /// @notice Deploys a new proxy 
  /// @dev Sets "msg.sender" as the owner of the proxy.
  /// @return proxy The address of the newly deployed proxy contract.
  function deploy() external returns (IMIMOProxy proxy);

  /// @notice Deploys a new proxy for a given owner and returns the address of the newly created proxy
  /// @param owner The owner of the proxy.
  /// @return proxy The address of the newly deployed proxy contract.
  function deployFor(address owner) external returns (IMIMOProxy proxy);
}


// File @openzeppelin/contracts/utils/Address.sol@v4.6.0


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


// File @openzeppelin/contracts/proxy/utils/Initializable.sol@v4.6.0


// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)



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
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
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
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
     */
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}


// File contracts/libraries/BoringBatchable.sol



pragma experimental ABIEncoderV2;

// solhint-disable avoid-low-level-calls
// solhint-disable no-inline-assembly

// WARNING!!!
// Combining BoringBatchable with msg.value can cause double spending issues
// https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong/

contract BoringBatchable {
  error BatchError(bytes innerError);

  /// @dev Helper function to extract a useful revert message from a failed call.
  /// If the returned data is malformed or not correctly abi encoded then this call can fail itself.
  function _getRevertMsg(bytes memory _returnData) internal pure {
    // If the _res length is less than 68, then
    // the transaction failed with custom error or silently (without a revert message)
    if (_returnData.length < 68) revert BatchError(_returnData);

    assembly {
      // Slice the sighash.
      _returnData := add(_returnData, 0x04)
    }
    revert(abi.decode(_returnData, (string))); // All that remains is the revert string
  }

  /// @notice Allows batched call to self (this contract).
  /// @param calls An array of inputs for each call.
  /// @param revertOnFail If True then reverts after a failed call and stops doing further calls.
  // F1: External is ok here because this is the batch function, adding it to a batch makes no sense
  // F2: Calls in the batch may be payable, delegatecall operates in the same context, so each call in the batch has access to msg.value
  // C3: The length of the loop is fully under user control, so can't be exploited
  // C7: Delegatecall is only used on the same contract, so it's safe
  function batch(bytes[] calldata calls, bool revertOnFail) external payable {
    for (uint256 i = 0; i < calls.length; i++) {
      (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
      if (!success && revertOnFail) {
        _getRevertMsg(result);
      }
    }
  }
}


// File contracts/libraries/CustomErrors.sol




/**
    @title Errors library
    @author MIMO
    @notice Defines the error messages emtted by the different contracts of the MIMO protocol
 */

library CustomErrors {
  error CANNOT_SET_TO_ADDRESS_ZERO();
  error INITIATOR_NOT_AUTHORIZED(address actual, address expected);
  error CALLER_NOT_LENDING_POOL(address actual, address expected);
  error CANNOT_REPAY_FLASHLOAN();
  error INVALID_AGGREGATOR();
  error AGGREGATOR_CALL_FAILED();
  error EXECUTION_NOT_AUTHORIZED(address owner, address caller, address target, bytes4 selector);
  error EXECUTION_REVERTED();
  error NOT_OWNER(address owner, address caller);
  error OWNER_CHANGED(address originalOwner, address newOwner);
  error TARGET_INVALID(address target);
  error CALLER_NOT_VAULT_OWNER(address callerProxy, address vaultOwner);
  error CALLER_NOT_PROTOCOL_MANAGER();
  error MANAGER_NOT_LISTED();
  error VAULT_NOT_UNDER_MANAGEMENT();
  error CALLER_NOT_SELECTED_MANAGER();
  error PROXY_ALREADY_EXISTS(address owner);
  error MAX_OPERATIONS_REACHED();
  error MINT_AMOUNT_GREATER_THAN_VAULT_DEBT();
  error VAULT_VALUE_CHANGE_TOO_HIGH();
  error FINAL_VAULT_RATIO_TOO_LOW(uint256 minRatio, uint256 actualRatio);
  error VAULT_NOT_AUTOMATED();
  error VAULT_TRIGGER_RATIO_NOT_REACHED(uint256 actual, uint256 expected);
  error TARGETS_LENGTH_DIFFERENT_THAN_DATA_LENGTH(uint256 targetsLength, uint256 dataLength);
  error LOW_LEVEL_CALL_FAILED();
  error REBALANCE_AMOUNT_CANNOT_BE_ZERO();
  error VARIABLE_FEE_TOO_HIGH(uint256 maxVarFee, uint256 actualVarFee);
}


// File contracts/proxy/MIMOProxy.sol





/// @title MIMOProxy
/// @notice Used as a proxy to access VaultsCore from a user or a rebalancer
contract MIMOProxy is IMIMOProxy, Initializable, BoringBatchable {
  /// PUBLIC STORAGE ///

  /// @inheritdoc IMIMOProxy
  address public override owner;

  /// @inheritdoc IMIMOProxy
  uint256 public override minGasReserve;

  /// INTERNAL STORAGE ///

  /// @notice Maps envoys to target contracts to function selectors to boolean flags.
  mapping(address => mapping(address => mapping(bytes4 => bool))) internal _permissions;

  /// CONSTRUCTOR ///

  /// @inheritdoc IMIMOProxy
  function initialize() external initializer {
    minGasReserve = 5_000;
    owner = msg.sender;
    emit TransferOwnership(address(0), msg.sender);
  }

  /// FALLBACK FUNCTION ///

  /// @dev Called when Ether is sent and the call data is empty.
  receive() external payable {}

  /// PUBLIC CONSTANT FUNCTIONS ///

  /// @inheritdoc IMIMOProxy
  function getPermission(
    address envoy,
    address target,
    bytes4 selector
  ) external view override returns (bool) {
    return _permissions[envoy][target][selector];
  }

  /// PUBLIC NON-CONSTANT FUNCTIONS ///

  /// @inheritdoc IMIMOProxy
  function execute(address target, bytes calldata data) public payable override returns (bytes memory response) {
    // Check that the caller is either the owner or an envoy.
    if (owner != msg.sender) {
      bytes4 selector;
      assembly {
        selector := calldataload(data.offset)
      }
      if (!_permissions[msg.sender][target][selector]) {
        revert CustomErrors.EXECUTION_NOT_AUTHORIZED(owner, msg.sender, target, selector);
      }
    }

    // Check that the target is a valid contract.
    if (target.code.length == 0) {
      revert CustomErrors.TARGET_INVALID(target);
    }

    // Save the owner address in memory. This local variable cannot be modified during the DELEGATECALL.
    address owner_ = owner;

    // Reserve some gas to ensure that the function has enough to finish the execution.
    uint256 stipend = gasleft() - minGasReserve;

    // Delegate call to the target contract.
    bool success;
    (success, response) = target.delegatecall{ gas: stipend }(data);

    // Check that the owner has not been changed.
    if (owner_ != owner) {
      revert CustomErrors.OWNER_CHANGED(owner_, owner);
    }

    // Log the execution.
    emit Execute(target, data, response);

    // Check if the call was successful or not.
    if (!success) {
      // If there is return data, the call reverted with a reason or a custom error.
      if (response.length > 0) {
        assembly {
          let returndata_size := mload(response)
          revert(add(32, response), returndata_size)
        }
      } else {
        revert CustomErrors.EXECUTION_REVERTED();
      }
    }
  }

  /// @inheritdoc IMIMOProxy
  function setPermission(
    address envoy,
    address target,
    bytes4 selector,
    bool permission
  ) public override {
    if (owner != msg.sender) {
      revert CustomErrors.NOT_OWNER(owner, msg.sender);
    }
    _permissions[envoy][target][selector] = permission;
  }

  /// @inheritdoc IMIMOProxy
  function transferOwnership(address newOwner) external override {
    address oldOwner = owner;
    if (oldOwner != msg.sender) {
      revert CustomErrors.NOT_OWNER(oldOwner, msg.sender);
    }
    owner = newOwner;
    emit TransferOwnership(oldOwner, newOwner);
  }

  /// @inheritdoc IMIMOProxy
  function multicall(address[] calldata targets, bytes[] calldata data) external override returns (bytes[] memory) {
    if (msg.sender != owner) {
      revert CustomErrors.NOT_OWNER(owner, msg.sender);
    }
    bytes[] memory results = new bytes[](data.length);
    for (uint256 i = 0; i < targets.length; i++) {
      (bool success, bytes memory response) = targets[i].call(data[i]);
      if (!success) {
        if (response.length > 0) {
          assembly {
            let returndata_size := mload(response)
            revert(add(32, response), returndata_size)
          }
        } else {
          revert CustomErrors.LOW_LEVEL_CALL_FAILED();
        }
      }
      results[i] = response;
    }
    return results;
  }
}


// File contracts/proxy/MIMOProxyFactory.sol





/// @title MIMOProxyFactory
/// @notice Used to make clones of MIMOProxy for each user
contract MIMOProxyFactory is IMIMOProxyFactory {
  using Clones for address;
  /// PUBLIC STORAGE ///

  address public immutable mimoProxyBase;

  /// @inheritdoc IMIMOProxyFactory
  uint256 public constant override VERSION = 1;

  /// INTERNAL STORAGE ///

  /// @dev Internal mapping to track all deployed proxies.
  mapping(address => bool) internal _proxies;

  constructor(address _mimoProxyBase) {
    mimoProxyBase = _mimoProxyBase;
  }

  /// PUBLIC CONSTANT FUNCTIONS ///

  /// @inheritdoc IMIMOProxyFactory
  function isProxy(address proxy) external view override returns (bool result) {
    result = _proxies[proxy];
  }

  /// PUBLIC NON-CONSTANT FUNCTIONS ///

  /// @inheritdoc IMIMOProxyFactory
  function deploy() external override returns (IMIMOProxy proxy) {
    proxy = deployFor(msg.sender);
  }

  /// @inheritdoc IMIMOProxyFactory
  function deployFor(address owner) public override returns (IMIMOProxy proxy) {
    proxy = IMIMOProxy(mimoProxyBase.clone());
    proxy.initialize();

    // Transfer the ownership from this factory contract to the specified owner.
    proxy.transferOwnership(owner);

    // Mark the proxy as deployed.
    _proxies[address(proxy)] = true;

    // Log the proxy via en event.
    emit DeployProxy(msg.sender, owner, address(proxy));
  }
}
