// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// lib/solady/src/auth/Ownable.sol

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
/// @dev While the ownable portion follows [EIP-173](https://eips.ethereum.org/EIPS/eip-173)
/// for compatibility, the nomenclature for the 2-step ownership handover
/// may be unique to this codebase.
abstract contract Ownable {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The caller is not authorized to call the function.
    error Unauthorized();

    /// @dev The `newOwner` cannot be the zero address.
    error NewOwnerIsZeroAddress();

    /// @dev The `pendingOwner` does not have a valid handover request.
    error NoHandoverRequest();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ownership is transferred from `oldOwner` to `newOwner`.
    /// This event is intentionally kept the same as OpenZeppelin's Ownable to be
    /// compatible with indexers and [EIP-173](https://eips.ethereum.org/EIPS/eip-173),
    /// despite it not being as lightweight as a single argument event.
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    /// @dev An ownership handover to `pendingOwner` has been requested.
    event OwnershipHandoverRequested(address indexed pendingOwner);

    /// @dev The ownership handover to `pendingOwner` has been canceled.
    event OwnershipHandoverCanceled(address indexed pendingOwner);

    /// @dev `keccak256(bytes("OwnershipTransferred(address,address)"))`.
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;

    /// @dev `keccak256(bytes("OwnershipHandoverRequested(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;

    /// @dev `keccak256(bytes("OwnershipHandoverCanceled(address)"))`.
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The owner slot is given by: `not(_OWNER_SLOT_NOT)`.
    /// It is intentionally choosen to be a high value
    /// to avoid collision with lower slots.
    /// The choice of manual storage layout is to enable compatibility
    /// with both regular and upgradeable contracts.
    uint256 private constant _OWNER_SLOT_NOT = 0x8b78c6d8;

    /// The ownership handover slot of `newOwner` is given by:
    /// ```
    ///     mstore(0x00, or(shl(96, user), _HANDOVER_SLOT_SEED))
    ///     let handoverSlot := keccak256(0x00, 0x20)
    /// ```
    /// It stores the expiry timestamp of the two-step ownership handover.
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Initializes the owner directly without authorization guard.
    /// This function must be called upon initialization,
    /// regardless of whether the contract is upgradeable or not.
    /// This is to enable generalization to both regular and upgradeable contracts,
    /// and to save gas in case the initial owner is not the caller.
    /// For performance reasons, this function will not check if there
    /// is an existing owner.
    function _initializeOwner(address newOwner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Store the new value.
            sstore(not(_OWNER_SLOT_NOT), newOwner)
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
        }
    }

    /// @dev Sets the owner directly without authorization guard.
    function _setOwner(address newOwner) internal virtual {
        /// @solidity memory-safe-assembly
        assembly {
            let ownerSlot := not(_OWNER_SLOT_NOT)
            // Clean the upper 96 bits.
            newOwner := shr(96, shl(96, newOwner))
            // Emit the {OwnershipTransferred} event.
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
            // Store the new value.
            sstore(ownerSlot, newOwner)
        }
    }

    /// @dev Throws if the sender is not the owner.
    function _checkOwner() internal view virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // If the caller is not the stored owner, revert.
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Allows the owner to transfer the ownership to `newOwner`.
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) // `NewOwnerIsZeroAddress()`.
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }

    /// @dev Allows the owner to renounce their ownership.
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }

    /// @dev Request a two-step ownership handover to the caller.
    /// The request will be automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + ownershipHandoverValidFor();
            /// @solidity memory-safe-assembly
            assembly {
                // Compute and set the handover slot to `expires`.
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                // Emit the {OwnershipHandoverRequested} event.
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }

    /// @dev Cancels the two-step ownership handover to the caller, if any.
    function cancelOwnershipHandover() public payable virtual {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            // Emit the {OwnershipHandoverCanceled} event.
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }

    /// @dev Allows the owner to complete the two-step ownership handover to `pendingOwner`.
    /// Reverts if there is no existing ownership handover requested by `pendingOwner`.
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute and set the handover slot to 0.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            // If the handover does not exist, or has expired.
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) // `NoHandoverRequest()`.
                revert(0x1c, 0x04)
            }
            // Set the handover slot to 0.
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   PUBLIC READ FUNCTIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns the owner of the contract.
    function owner() public view virtual returns (address result) {
        /// @solidity memory-safe-assembly
        assembly {
            result := sload(not(_OWNER_SLOT_NOT))
        }
    }

    /// @dev Returns the expiry timestamp for the two-step ownership handover to `pendingOwner`.
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Compute the handover slot.
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            // Load the handover slot.
            result := sload(keccak256(0x0c, 0x20))
        }
    }

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    function ownershipHandoverValidFor() public view virtual returns (uint64) {
        return 48 * 3600;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}

// lib/solmate/src/tokens/ERC20.sol

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

// src/ulysses-omnichain/interfaces/IApp.sol

/// IApp interface of the application
interface IApp {
    /**
     * @notice anyExecute is the function that will be called on the destination chain to execute interaction (required).
     *     @param _data interaction arguments to exec on the destination chain.
     *     @return success whether the interaction was successful.
     *     @return result the result of the interaction.
     */
    function anyExecute(bytes calldata _data) external returns (bool success, bytes memory result);

    /**
     * @notice anyFallback is the function that will be called on the originating chain if the cross chain interaction fails (optional, advised).
     *     @param _data interaction arguments to exec on the destination chain.
     *     @return success whether the interaction was successful.
     *     @return result the result of the interaction.
     */
    function anyFallback(bytes calldata _data) external returns (bool success, bytes memory result);
}

// src/ulysses-omnichain/interfaces/IBranchBridgeAgentFactory.sol

/**
 * @title  Branch Bridge Agent Factory Contract
 * @author MaiaDAO
 * @notice Factory contract for allowing permissionless deployment of
 *         new Branch Bridge Agents which are in charge of managing the
 *         deposit and withdrawal of assets between the branch chains
 *         and the omnichain environment.
 */
interface IBranchBridgeAgentFactory {
    /*///////////////////////////////////////////////////////////////
                        BRIDGE AGENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createBridgeAgent(
        address newRootRouterAddress,
        address rootBridgeAgentAddress,
        address _rootBridgeAgentFactoryAddress
    ) external returns (address newBridgeAgent);
}

// src/ulysses-omnichain/interfaces/IBranchPort.sol

/**
 * @title  Branch Port - Omnichain Token Management Contract
 * @author MaiaDAO
 * @notice Ulyses `Port` implementation for Branch Chain deployment. This contract
 *         is used to manage the deposit and withdrawal of underlying assets from
 *         the Branch Chain in response to Branch Bridge Agents' requests.
 *         Manages Bridge Agents and their factories as well as the chain's strategies and
 *         their tokens.
 */
interface IBranchPort {
    /*///////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns true if the address is a Bridge Agent.
     *   @param _bridgeAgent Bridge Agent address.
     *   @return bool.
     */
    function isBridgeAgent(address _bridgeAgent) external view returns (bool);

    /**
     * @notice Returns true if the address is a Strategy Token.
     *   @param _token token address.
     *   @return bool.
     */
    function isStrategyToken(address _token) external view returns (bool);

    /**
     * @notice Returns true if the address is a Port Strategy.
     *   @param _strategy strategy address.
     *   @param _token token address.
     *   @return bool.
     */
    function isPortStrategy(address _strategy, address _token) external view returns (bool);

    /**
     * @notice Returns true if the address is a Bridge Agent Factory.
     *   @param _bridgeAgentFactory Bridge Agent Factory address.
     *   @return bool.
     */
    function isBridgeAgentFactory(address _bridgeAgentFactory) external view returns (bool);

    /*///////////////////////////////////////////////////////////////
                          PORT STRATEGY MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Allows active Port Strategy addresses to withdraw assets.
     *     @param _token token address.
     *     @param _amount amount of tokens.
     */
    function manage(address _token, uint256 _amount) external;

    /**
     * @notice allow approved address to repay borrowed reserves with reserves
     *     @param _amount uint
     *     @param _token address
     */
    function replenishReserves(address _strategy, address _token, uint256 _amount) external;

    /*///////////////////////////////////////////////////////////////
                          hTOKEN MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to withdraw underlying / native token amount into Port in exchange for Local hToken.
     *   @param _recipient hToken receiver.
     *   @param _underlyingAddress underlying / native token address.
     *   @param _amount amount of tokens.
     *
     */
    function withdraw(address _recipient, address _underlyingAddress, uint256 _amount) external;

    /**
     * @notice Setter function to increase local hToken supply.
     *   @param _recipient hToken receiver.
     *   @param _localAddress token address.
     *   @param _amount amount of tokens.
     *
     */
    function bridgeIn(address _recipient, address _localAddress, uint256 _amount) external;

    /**
     * @notice Setter function to increase local hToken supply.
     *   @param _recipient hToken receiver.
     *   @param _localAddresses token addresses.
     *   @param _amounts amount of tokens.
     *
     */
    function bridgeInMultiple(address _recipient, address[] memory _localAddresses, uint256[] memory _amounts)
        external;

    /**
     * @notice Setter function to decrease local hToken supply.
     *   @param _localAddress token address.
     *   @param _amount amount of tokens.
     *
     */
    function bridgeOut(
        address _depositor,
        address _localAddress,
        address _underlyingAddress,
        uint256 _amount,
        uint256 _deposit
    ) external;

    /**
     * @notice Setter function to decrease local hToken supply.
     *   @param _depositor user to deduct balance from.
     *   @param _localAddresses local token addresses.
     *   @param _underlyingAddresses local token address.
     *   @param _amounts amount of local tokens.
     *   @param _deposits amount of underlying tokens.
     *
     */
    function bridgeOutMultiple(
        address _depositor,
        address[] memory _localAddresses,
        address[] memory _underlyingAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits
    ) external;

    /*///////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new bridge agent address to the branch port.
     *   @param _bridgeAgent address of the bridge agent to add to the Port
     */
    function addBridgeAgent(address _bridgeAgent) external;

    /**
     * @notice Sets the core router address for the branch port.
     *   @param _newCoreRouter address of the new core router
     */
    function setCoreRouter(address _newCoreRouter) external;

    /**
     * @notice Adds a new bridge agent factory address to the branch port.
     *   @param _bridgeAgentFactory address of the bridge agent factory to add to the Port
     */
    function addBridgeAgentFactory(address _bridgeAgentFactory) external;

    /**
     * @notice Reverts the toggle on the given bridge agent factory. If it's active, it will de-activate it and vice-versa.
     *   @param _newBridgeAgentFactory address of the bridge agent factory to add to the Port
     */
    function toggleBridgeAgentFactory(address _newBridgeAgentFactory) external;

    /**
     * @notice Reverts thfe toggle on the given bridge agent  If it's active, it will de-activate it and vice-versa.
     *   @param _bridgeAgent address of the bridge agent to add to the Port
     */
    function toggleBridgeAgent(address _bridgeAgent) external;

    /**
     * @notice Adds a new strategy token.
     * @param _token address of the token to add to the Strategy Tokens
     */
    function addStrategyToken(address _token, uint256 _minimumReservesRatio) external;

    /**
     * @notice Reverts the toggle on the given strategy token. If it's active, it will de-activate it and vice-versa.
     * @param _token address of the token to add to the Strategy Tokens
     */
    function toggleStrategyToken(address _token) external;

    /**
     * @notice Adds a new Port strategy to the given port
     * @param _portStrategy address of the bridge agent factory to add to the Port
     */
    function addPortStrategy(address _portStrategy, address _token, uint256 _dailyManagementLimit) external;

    /**
     * @notice Reverts the toggle on the given port strategy. If it's active, it will de-activate it and vice-versa.
     * @param _portStrategy address of the bridge agent factory to add to the Port
     */
    function togglePortStrategy(address _portStrategy, address _token) external;

    /**
     * @notice Updates the daily management limit for the given port strategy.
     * @param _portStrategy address of the bridge agent factory to add to the Port
     * @param _token address of the token to update the limit for
     * @param _dailyManagementLimit new daily management limit
     */
    function updatePortStrategy(address _portStrategy, address _token, uint256 _dailyManagementLimit) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    event DebtCreated(address indexed _strategy, address indexed _token, uint256 _amount);
    event DebtRepaid(address indexed _strategy, address indexed _token, uint256 _amount);

    event StrategyTokenAdded(address indexed _token, uint256 _minimumReservesRatio);
    event StrategyTokenToggled(address indexed _token);

    event PortStrategyAdded(address indexed _portStrategy, address indexed _token, uint256 _dailyManagementLimit);
    event PortStrategyToggled(address indexed _portStrategy, address indexed _token);
    event PortStrategyUpdated(address indexed _portStrategy, address indexed _token, uint256 _dailyManagementLimit);

    event BridgeAgentFactoryAdded(address indexed _bridgeAgentFactory);
    event BridgeAgentFactoryToggled(address indexed _bridgeAgentFactory);

    event BridgeAgentToggled(address indexed _bridgeAgent);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error InvalidMinimumReservesRatio();
    error InsufficientReserves();
    error UnrecognizedCore();
    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentFactory();
    error UnrecognizedPortStrategy();
    error UnrecognizedStrategyToken();
}

// src/ulysses-omnichain/interfaces/ICoreBranchRouter.sol

/**
 * @title  Core Branch Router Contract
 * @author MaiaDAO
 * @notice Core Branch Router implementation for deployment in Branch Chains.
 *         This contract is allows users to permissionlessly add new tokens
 *         or Bridge Agents to the system. As well as executes key governance
 *         enabled system functions (i.e. `addBridgeAgentFactory`).
 * @dev    Func IDs for calling these functions through messaging layer:
 *
 *         CROSS-CHAIN MESSAGING FUNCIDs
 *         -----------------------------
 *         FUNC ID      | FUNC NAME
 *         -------------+---------------
 *         0x01         | addGlobalToken
 *         0x02         | addBridgeAgent
 *         0x03         | toggleBranchBridgeAgentFactory
 *         0x04         | removeBranchBridgeAgent
 *         0x05         | manageStrategyToken
 *         0x06         | managePortStrategy
 *
 */
interface ICoreBranchRouter {
    /*///////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to deploy/add a token already present in the global environment to a branch chain.
     * @param _globalAddress the address of the global virtualized token.
     * @param _toChain the chain to which the token will be added.
     * @param _remoteExecutionGas the amount of gas to be sent to the remote chain.
     * @param _rootExecutionGas the amount of gas to be sent to the root chain.
     */
    function addGlobalToken(
        address _globalAddress,
        uint256 _toChain,
        uint128 _remoteExecutionGas,
        uint128 _rootExecutionGas
    ) external payable;

    /**
     * @notice Function to add a token that's not available in the global environment from this branch chain.
     * @param _underlyingAddress the address of the token to be added.
     */
    function addLocalToken(address _underlyingAddress) external payable;

    /**
     * @notice Function to link a new bridge agent to the root bridge agent (which resides in Arbitrum).
     * @param _newBridgeAgentAddress the address of the new local bridge agent.
     * @param _rootBridgeAgentAddress the address of the root bridge agent.
     */
    function syncBridgeAgent(address _newBridgeAgentAddress, address _rootBridgeAgentAddress) external payable;
}

// src/ulysses-omnichain/interfaces/IERC20hTokenBranch.sol

/**
 * @title  ERC20 hToken Branch Contract
 * @author MaiaDAO.
 * @notice ERC20 hToken contract deployed in the Branch Chains of the Ulysses Omnichain Liquidity System.
 *         1:1 ERC20 representation of a token deposited in a  Branch Chain's Port. Is only minted upon
 *         user request otherwise underlying tokens are cleared and the matching Root hToken has been burned.
 */
interface IERC20hTokenBranch {
    /*///////////////////////////////////////////////////////////////
                        ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to mint tokens in the Branch Chain.
     * @param account Address of the account to receive the tokens.
     * @param amount Amount of tokens to be minted.
     * @return Boolean indicating if the operation was successful.
     */
    function mint(address account, uint256 amount) external returns (bool);

    /**
     * @notice Function to burn tokens in the Branch Chain.
     * @param value Amount of tokens to be burned.
     */
    function burn(uint256 value) external;
}

// src/ulysses-omnichain/interfaces/IBranchBridgeAgent.sol

struct UserFeeInfo {
    uint256 depositedGas;
    uint256 feesOwed;
}

enum DepositStatus {
    Success,
    Failed
}

struct Deposit {
    uint128 depositedGas;
    address owner;
    DepositStatus status;
    address[] hTokens;
    address[] tokens;
    uint256[] amounts;
    uint256[] deposits;
}

struct DepositInput {
    //Deposit Info
    address hToken; //Input Local hTokens Address.
    address token; //Input Native / underlying Token Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
}

struct DepositMultipleInput {
    //Deposit Info
    address[] hTokens; //Input Local hTokens Address.
    address[] tokens; //Input Native / underlying Token Address.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
}

struct DepositParams {
    //Deposit Info
    uint32 depositNonce; //Deposit nonce.
    address hToken; //Input Local hTokens Address.
    address token; //Input Native / underlying Token Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
    uint128 depositedGas; //BRanch chain gas token amount sent with request.
}

struct DepositMultipleParams {
    //Deposit Info
    uint8 numberOfAssets; //Number of assets to deposit.
    uint32 depositNonce; //Deposit nonce.
    address[] hTokens; //Input Local hTokens Address.
    address[] tokens; //Input Native / underlying Token Address.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
    uint128 depositedGas; //BRanch chain gas token amount sent with request.
}

struct SettlementParams {
    uint32 settlementNonce;
    address recipient;
    address hToken;
    address token;
    uint256 amount;
    uint256 deposit;
}

struct SettlementMultipleParams {
    uint8 numberOfAssets; //Number of assets to deposit.
    address recipient;
    uint32 settlementNonce;
    address[] hTokens;
    address[] tokens;
    uint256[] amounts;
    uint256[] deposits;
}

/**
 * @title  Branch Bridge Agent Contract
 * @author MaiaDAO
 * @notice Contract for deployment in Branch Chains of Omnichain System, responible for
 *         interfacing with Users and Routers acting as a middleman to access Anycall cross-chain
 *         messaging and  requesting / depositing  assets in the Branch Chain's Ports.
 * @dev    Bridge Agents allow for the encapsulation of business logic as well as the standardize
 *         cross-chain communication, allowing for the creation of custom Routers to perform
 *         actions as a response to remote user requests. This contract for deployment in the Branch
 *         Chains of the Ulysses Omnichain Liquidity System.
 *         This contract manages gas spenditure calling `_replenishingGas` after each remote initiated
 *         execution, as well as requests tokens clearances and tx execution to the `BranchBridgeAgentExecutor`.
 *         Remote execution is "sandboxed" in 3 different nestings:
 *         - 1: Anycall Messaging Layer will revert execution if by the end of the call the
 *              balance in the executionBudget AnycallConfig contract for the Branch Bridge Agent
 *              being called is inferior to the executionGasSpent, throwing the error `no enough budget`.
 *         - 2: The `BranchBridgeAgent` will trigger a revert all state changes if by the end of the remote initiated call
 *              Router interaction the userDepositedGas < executionGasSpent. This is done by calling the `_forceRevert()`
 *              internal function clearing all executionBudget from the AnycallConfig contract forcing the error `no enough budget`.
 *         - 3: The `BranchBridgeAgentExecutor` is in charge of requesting token deposits for each remote interaction as well
 *              as performing the Router calls, if any of the calls initiated by the Router lead to an invlaid state change
 *              both the token deposit clearances as well as the external interactions will be reverted. Yet executionGas
 *              will still be credited by the `BranchBridgeAgent`.
 *
 *         Func IDs for calling these functions through messaging layer:
 *
 *         BRANCH BRIDGE AGENT SETTLEMENT FLAGS
 *         --------------------------------------
 *         ID           | DESCRIPTION
 *         -------------+------------------------
 *         0x00         | Call to Branch without Settlement.
 *         0x01         | Call to Branch with Settlement.
 *         0x02         | Call to Branch with Settlement of Multiple Tokens.
 *
 *         Encoding Scheme for different Root Bridge Agent Deposit Flags:
 *
 *           - ht = hToken
 *           - t = Token
 *           - A = Amount
 *           - D = Destination
 *           - b = bytes
 *           - n = number of assets
 *           ________________________________________________________________________________________________________________________________
 *          |            Flag               |           Deposit Info           |             Token Info             |   DATA   |  Gas Info   |
 *          |           1 byte              |            4-25 bytes            |        (105 or 128) * n bytes      |   ---	   |  16 bytes   |
 *          |                               |                                  |            hT - t - A - D          |          |             |
 *          |_______________________________|__________________________________|____________________________________|__________|_____________|
 *          | callOut = 0x0                 |  20b(recipient) + 4b(nonce)      |            -------------           |   ---	   |     dep     |
 *          | callOutSingle = 0x1           |  20b(recipient) + 4b(nonce)      |         20b + 20b + 32b + 32b      |   ---	   |     16b     |
 *          | callOutMulti = 0x2            |  1b(n) + 20b(recipient) + 4b     |   	     32b + 32b + 32b + 32b      |   ---	   |     16b     |
 *          |_______________________________|__________________________________|____________________________________|__________|_____________|
 *
 *          Contract Remote Interaction Flow:
 *
 *          BranchBridgeAgent.anyExecute**() -> BridgeAgentExecutor.execute**() -> Router.anyExecute**() -> BridgeAgentExecutor (txExecuted) -> BranchBridgeAgent (replenishedGas)
 *
 *
 */
interface IBranchBridgeAgent is IApp {
    /**
     * @notice External function to return the Branch Bridge Agent Executor Address.
     */
    function bridgeAgentExecutorAddress() external view returns (address);

    /**
     * @dev External function that returns a given deposit entry.
     *     @param _depositNonce Identifier for user deposit.
     *
     */
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory);

    /*///////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to perform a call to the Root Omnichain Router without token deposit.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param remoteExecutionGas gas allocated for remote branch execution.
     *   @dev DEPOSIT ID: 1 (Call without deposit)
     *
     */
    function callOut(bytes calldata params, uint128 remoteExecutionGas) external payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing a single asset.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param dParams additional token deposit parameters.
     *   @param remoteExecutionGas gas allocated for remote branch execution.
     *   @dev DEPOSIT ID: 2 (Call with single deposit)
     *
     */
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing two or more assets.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param dParams additional token deposit parameters.
     *   @param remoteExecutionGas gas allocated for remote branch execution.
     *   @dev DEPOSIT ID: 3 (Call with multiple deposit)
     *
     */
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router without token deposit with msg.sender information.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param remoteExecutionGas gas allocated for remote branch execution.
     *   @dev DEPOSIT ID: 4 (Call without deposit and verified sender)
     *
     */
    function callOutSigned(bytes calldata params, uint128 remoteExecutionGas) external payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing a single asset msg.sender.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param dParams additional token deposit parameters.
     *   @param remoteExecutionGas gas allocated for remote branch execution.
     *   @dev DEPOSIT ID: 5 (Call with single deposit and verified sender)
     *
     */
    function callOutSignedAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing two or more assets with msg.sender.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param dParams additional token deposit parameters.
     *   @param remoteExecutionGas gas allocated for remote branch execution.
     *   @dev DEPOSIT ID: 6 (Call with multiple deposit and verified sender)
     *
     */
    function callOutSignedAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Environment retrying a failed deposit that hasn't been executed yet.
     *     @param _isSigned Flag to indicate if the deposit was signed.
     *     @param _depositNonce Identifier for user deposit.
     *     @param _params parameters to execute on the root chain router.
     *     @param _remoteExecutionGas gas allocated for remote branch execution.
     *     @param _toChain Destination chain for interaction.
     */
    function retryDeposit(
        bool _isSigned,
        uint32 _depositNonce,
        bytes calldata _params,
        uint128 _remoteExecutionGas,
        uint24 _toChain
    ) external payable;

    /**
     * @notice External function to retry a failed Settlement entry on the root chain.
     *     @param _settlementNonce Identifier for user settlement.
     *     @param _gasToBoostSettlement Amount of gas to boost settlement.
     *     @dev DEPOSIT ID: 7
     *
     */
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable;

    /**
     * @notice External function to request tokens back to branch chain after a failed omnichain environment interaction.
     *     @param _depositNonce Identifier for user deposit to retrieve.
     *     @dev DEPOSIT ID: 8
     *
     */
    function retrieveDeposit(uint32 _depositNonce) external payable;

    /**
     * @notice External function to retry a failed Deposit entry on this branch chain.
     *     @param _depositNonce Identifier for user deposit.
     *
     */
    function redeemDeposit(uint32 _depositNonce) external;

    /**
     * @notice Function to request balance clearance from a Port to a given user.
     *     @param _recipient token receiver.
     *     @param _hToken  local hToken addresse to clear balance for.
     *     @param _token  native / underlying token addresse to clear balance for.
     *     @param _amount amounts of hToken to clear balance for.
     *     @param _deposit amount of native / underlying tokens to clear balance for.
     *
     */
    function clearToken(address _recipient, address _hToken, address _token, uint256 _amount, uint256 _deposit)
        external;

    /**
     * @notice Function to request balance clearance from a Port to a given address.
     *     @param _sParams encode packed multiple settlement info.
     *
     */
    function clearTokens(bytes calldata _sParams, address _recipient)
        external
        returns (SettlementMultipleParams memory);

    /*///////////////////////////////////////////////////////////////
                        BRANCH ROUTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Internal function performs call to AnycallProxy Contract for cross-chain messaging.
     *   @param params calldata for omnichain execution.
     *   @param depositor address of user depositing assets.
     *   @param gasToBridgeOut gas allocated for the cross-chain call.
     *   @param remoteExecutionGas gas allocated for omnichain execution.
     *   @dev DEPOSIT ID: 0 (System Call / Response)
     *   @dev 0x00 flag allows for identifying system emitted request/responses.
     *
     */
    function performSystemCallOut(
        address depositor,
        bytes memory params,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;

    /**
     * @notice Internal function performs call to AnycallProxy Contract for cross-chain messaging.
     *   @param depositor address of user depositing assets.
     *   @param params calldata for omnichain execution.
     *   @param depositor address of user depositing assets.
     *   @param gasToBridgeOut gas allocated for the cross-chain call.
     *   @param remoteExecutionGas gas allocated for omnichain execution.
     *   @dev DEPOSIT ID: 1 (Call without Deposit)
     *
     */
    function performCallOut(address depositor, bytes memory params, uint128 gasToBridgeOut, uint128 remoteExecutionGas)
        external
        payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing a single asset.
     *   @param depositor address of user depositing assets.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param dParams additional token deposit parameters.
     *   @param gasToBridgeOut gas allocated for the cross-chain call.
     *   @param remoteExecutionGas gas allocated for omnichain execution.
     *   @dev DEPOSIT ID: 2 (Call with single asset Deposit)
     *
     */
    function performCallOutAndBridge(
        address depositor,
        bytes calldata params,
        DepositInput memory dParams,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing two or more assets.
     *   @param depositor address of user depositing assets.
     *   @param params enconded parameters to execute on the root chain router.
     *   @param dParams additional token deposit parameters.
     *   @param gasToBridgeOut gas allocated for the cross-chain call.
     *   @param remoteExecutionGas gas allocated for omnichain execution.
     *   @dev DEPOSIT ID: 3 (Call with multiple deposit)
     *
     */
    function performCallOutAndBridgeMultiple(
        address depositor,
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;

    /*///////////////////////////////////////////////////////////////
                        ANYCALL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to force revert when a remote action does not have enough gas or is being retried after having been previously executed.
     */
    function forceRevert() external;

    /**
     * @notice Function to deposit gas for use by the Branch Bridge Agent.
     */
    function depositGasAnycallConfig() external payable;

    /*///////////////////////////////////////////////////////////////
                        EVENTS
    //////////////////////////////////////////////////////////////*/

    event LogCallin(bytes1 selector, bytes data, uint256 fromChainId);
    event LogCallout(bytes1 selector, bytes data, uint256, uint256 toChainId);
    event LogCalloutFail(bytes1 selector, bytes data, uint256 toChainId);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error AnycallUnauthorizedCaller();
    error AlreadyExecutedTransaction();

    error InvalidInput();
    error InvalidChain();
    error InsufficientGas();

    error NotDepositOwner();
    error DepositRedeemUnavailable();

    error UnrecognizedCallerNotRouter();
    error UnrecognizedBridgeAgentExecutor();
}

// src/ulysses-omnichain/interfaces/IBranchRouter.sol

/**
 * @title  BaseBranchRouter Contract
 * @author MaiaDAO
 * @notice Base Branch Contract for interfacing with Branch Bridge Agents.
 *         This contract for deployment in Branch Chains of the Ulysses Omnichain System,
 *         additional logic can be implemented to perform actions before sending cross-chain
 *         requests, as well as in response to requests from the Root Omnichain Environment.
 */
interface IBranchRouter {
    /*///////////////////////////////////////////////////////////////
                            VIEW / STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Address for local Branch Bridge Agent who processes requests and ineracts with local port.
    function localBridgeAgentAddress() external view returns (address);

    /// @notice Local Bridge Agent Executor Address.
    function bridgeAgentExecutorAddress() external view returns (address);

    /*///////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to perform a call to the Root Omnichain Router without token deposit.
     *   @param params RLP enconded parameters to execute on the root chain.
     *   @param rootExecutionGas gas allocated for remote execution.
     *   @dev ACTION ID: 1 (Call without deposit)
     *
     */
    function callOut(bytes calldata params, uint128 rootExecutionGas) external payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing a single asset.
     *   @param params RLP enconded parameters to execute on the root chain.
     *   @param dParams additional token deposit parameters.
     *   @param rootExecutionGas gas allocated for remote execution.
     *   @dev ACTION ID: 2 (Call with single deposit)
     *
     */
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 rootExecutionGas)
        external
        payable;

    /**
     * @notice Function to perform a call to the Root Omnichain Router while depositing two or more assets.
     *   @param params RLP enconded parameters to execute on the root chain.
     *   @param dParams additional token deposit parameters.
     *   @param rootExecutionGas gas allocated for remote execution.
     *   @dev ACTION ID: 3 (Call with multiple deposit)
     *
     */
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 rootExecutionGas
    ) external payable;

    /**
     * @notice External function to retry a failed Settlement entry on the root chain.
     *     @param _settlementNonce Identifier for user settlement.
     *     @param _gasToBoostSettlement Additional gas to boost settlement.
     *
     */
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable;

    /**
     * @notice External function to retry a failed Deposit entry on this branch chain.
     *     @param _depositNonce Identifier for user deposit.
     *
     */
    function redeemDeposit(uint32 _depositNonce) external;

    /**
     * @notice External function that returns a given deposit entry.
     *     @param _depositNonce Identifier for user deposit.
     *
     */
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory);

    /*///////////////////////////////////////////////////////////////
                        ANYCALL EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function responsible of executing a branch router response.
     *     @param data data received from messaging layer.
     */
    function anyExecuteNoSettlement(bytes calldata data) external returns (bool success, bytes memory result);

    /**
     * @dev Function responsible of executing a crosschain request without any deposit.
     *     @param data data received from messaging layer.
     *     @param sParams SettlementParams struct.
     */
    function anyExecuteSettlement(bytes calldata data, SettlementParams memory sParams)
        external
        returns (bool success, bytes memory result);

    /**
     * @dev Function responsible of executing a crosschain request which contains cross-chain deposit information attached.
     *     @param data data received from messaging layer.
     *     @param sParams SettlementParams struct containing deposit information.
     *
     */
    function anyExecuteSettlementMultiple(bytes calldata data, SettlementMultipleParams memory sParams)
        external
        returns (bool success, bytes memory result);

    /*///////////////////////////////////////////////////////////////
                             ERRORS
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedBridgeAgentExecutor();
}

// src/ulysses-omnichain/token/ERC20hTokenBranch.sol

/// @title ERC20 hToken Branch Contract
contract ERC20hTokenBranch is ERC20, Ownable, IERC20hTokenBranch {
    constructor(string memory _name, string memory _symbol, address _owner)
        ERC20(string(string.concat("Hermes - ", _name)), string(string.concat("h-", _symbol)), 18)
    {
        _initializeOwner(_owner);
    }

    /*///////////////////////////////////////////////////////////////
                        ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20hTokenBranch
    function mint(address account, uint256 amount) external override onlyOwner returns (bool) {
        _mint(account, amount);
        return true;
    }

    /// @inheritdoc IERC20hTokenBranch
    function burn(uint256 value) public override onlyOwner {
        _burn(msg.sender, value);
    }
}

// src/ulysses-omnichain/BaseBranchRouter.sol

/// @title Base Branch Router Contract
contract BaseBranchRouter is IBranchRouter, Ownable {
    /// @inheritdoc IBranchRouter
    address public localBridgeAgentAddress;

    /// @inheritdoc IBranchRouter
    address public bridgeAgentExecutorAddress;

    constructor() {
        _initializeOwner(msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                        OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Contract state initialization function.
    function initialize(address _localBridgeAgentAddress) external onlyOwner {
        require(_localBridgeAgentAddress != address(0), "Bridge Agent address cannot be 0");
        localBridgeAgentAddress = _localBridgeAgentAddress;
        bridgeAgentExecutorAddress = IBranchBridgeAgent(localBridgeAgentAddress).bridgeAgentExecutorAddress();
        renounceOwnership();
    }

    /*///////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBranchRouter
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory) {
        return IBranchBridgeAgent(localBridgeAgentAddress).getDepositEntry(_depositNonce);
    }

    /*///////////////////////////////////////////////////////////////
                        EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBranchRouter
    function callOut(bytes calldata params, uint128 remoteExecutionGas) external payable lock {
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(
            msg.sender, params, 0, remoteExecutionGas
        );
    }

    /// @inheritdoc IBranchRouter
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable
        lock
    {
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOutAndBridge{value: msg.value}(
            msg.sender, params, dParams, 0, remoteExecutionGas
        );
    }

    /// @inheritdoc IBranchRouter
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable lock {
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOutAndBridgeMultiple{value: msg.value}(
            msg.sender, params, dParams, 0, remoteExecutionGas
        );
    }

    /// @inheritdoc IBranchRouter
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable lock {
        IBranchBridgeAgent(localBridgeAgentAddress).retrySettlement{value: msg.value}(_settlementNonce, _gasToBoostSettlement);
    }

    /// @inheritdoc IBranchRouter
    function redeemDeposit(uint32 _depositNonce) external lock {
        IBranchBridgeAgent(localBridgeAgentAddress).redeemDeposit(_depositNonce);
    }

    /*///////////////////////////////////////////////////////////////
                        ANYCALL EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBranchRouter
    function anyExecuteNoSettlement(bytes calldata)
        external
        virtual
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        /// Unrecognized Function Selector
        return (false, "unknown selector");
    }

    /// @inheritdoc IBranchRouter
    function anyExecuteSettlement(bytes calldata, SettlementParams memory)
        external
        virtual
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        /// Unrecognized Function Selector
        return (false, "unknown selector");
    }

    /// @inheritdoc IBranchRouter
    function anyExecuteSettlementMultiple(bytes calldata, SettlementMultipleParams memory)
        external
        virtual
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        /// Unrecognized Function Selector
        return (false, "unknown selector");
    }

    /*///////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier that verifies msg sender is the Bridge Agent Executor.
    modifier requiresAgentExecutor() {
        if (msg.sender != bridgeAgentExecutorAddress) revert UnrecognizedBridgeAgentExecutor();
        _;
    }

    uint256 internal _unlocked = 1;

    /// @notice Modifier for a simple re-entrancy check.
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }
}

// src/ulysses-omnichain/interfaces/IERC20hTokenBranchFactory.sol

/**
 * @title  ERC20hTokenBranchFactory Interface
 * @author MaiaDAO
 * @notice Factory contract allowing for permissionless deployment of new Branch hTokens in Branch
 *  	   Chains of Ulysses Omnichain Liquidity Protocol.
 * @dev    This contract is called by the chain's Core Branch Router.
 */
interface IERC20hTokenBranchFactory {
    /*///////////////////////////////////////////////////////////////
                            hTOKEN FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Function to create a new Branch hToken.
     * @param _name Name of the Token.
     * @param _symbol Symbol of the Token.
     */
    function createToken(string memory _name, string memory _symbol) external returns (ERC20hTokenBranch newToken);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedCoreRouter();

    error UnrecognizedPort();
}

// src/ulysses-omnichain/CoreBranchRouter.sol

/// @title Core Branch Router Contract
contract CoreBranchRouter is BaseBranchRouter {
    /// @notice hToken Factory Address.
    address public hTokenFactoryAddress;

    /// @notice Local Port Address.
    address public localPortAddress;

    constructor(address _hTokenFactoryAddress, address _localPortAddress) BaseBranchRouter() {
        localPortAddress = _localPortAddress;
        hTokenFactoryAddress = _hTokenFactoryAddress;
    }

    /*///////////////////////////////////////////////////////////////
                 TOKEN MANAGEMENT EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice This function is used to add a global token to a branch.
     * @param _globalAddress Address of the token to be added.
     * @param _toChain Chain Id of the chain to which the deposit is being added.
     * @param _remoteExecutionGas Gas to be used for the remote execution in destination chain.
     * @param _rootExecutionGas Gas to be saved for the final root execution.
     */
    function addGlobalToken(
        address _globalAddress,
        uint24 _toChain,
        uint128 _remoteExecutionGas,
        uint128 _rootExecutionGas
    ) external payable {
        //Encode Call Data
        bytes memory data = abi.encode(msg.sender, _globalAddress, _toChain, _rootExecutionGas);

        //Pack FuncId
        bytes memory packedData = abi.encodePacked(bytes1(0x01), data);

        //Send Cross-Chain request (System Response/Request)
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(
            msg.sender, packedData, 0, _remoteExecutionGas
        );
    }

    /**
     * @notice This function is used to add a local token to the system.
     * @param _underlyingAddress Address of the underlying token to be added.
     */
    function addLocalToken(address _underlyingAddress) external payable virtual {
        //Get Token Info
        string memory name = ERC20(_underlyingAddress).name();
        string memory symbol = ERC20(_underlyingAddress).symbol();

        //Create Token
        ERC20hTokenBranch newToken = IERC20hTokenBranchFactory(hTokenFactoryAddress).createToken(name, symbol);

        //Encode Data
        bytes memory data = abi.encode(_underlyingAddress, newToken, name, symbol);

        //Pack FuncId
        bytes memory packedData = abi.encodePacked(bytes1(0x02), data);

        //Send Cross-Chain request (System Response/Request)
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(msg.sender, packedData, 0, 0);
    }

    /*///////////////////////////////////////////////////////////////
                 TOKEN MANAGEMENT INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to deploy/add a token already active in the global environment in the Root Chain. Must be called from another chain.
     *  @param _globalAddress the address of the global virtualized token.
     *  @param _name token name.
     *  @param _symbol token symbol.
     *  @param _rootExecutionGas the amount of gas to be used in the root execution.
     *  @dev FUNC ID: 1
     *  @dev all hTokens have 18 decimals.
     *
     */
    function _receiveAddGlobalToken(
        address _globalAddress,
        string memory _name,
        string memory _symbol,
        uint128 _rootExecutionGas
    ) internal {
        //Create Token
        ERC20hTokenBranch newToken = IERC20hTokenBranchFactory(hTokenFactoryAddress).createToken(_name, _symbol);

        //Encode Data
        bytes memory data = abi.encode(_globalAddress, newToken);

        //Pack FuncId
        bytes memory packedData = abi.encodePacked(bytes1(0x03), data);

        //Send Cross-Chain request
        IBranchBridgeAgent(localBridgeAgentAddress).performSystemCallOut(address(this), packedData, _rootExecutionGas, 0);
    }

    /**
     * @notice Function to deploy/add a token already active in the global environment in the Root Chain. Must be called from another chain.
     *  @param _newBranchRouter the address of the new branch router.
     *  @param _branchBridgeAgentFactory the address of the branch bridge agent factory.
     *  @param _rootBridgeAgent the address of the root bridge agent.
     *  @param _rootBridgeAgentFactory the address of the root bridge agent factory.
     *  @param _remoteExecutionGas the amount of gas to be used in the remote execution.
     *  @dev FUNC ID: 2
     *  @dev all hTokens have 18 decimals.
     *
     */
    function _receiveAddBridgeAgent(
        address _newBranchRouter,
        address _branchBridgeAgentFactory,
        address _rootBridgeAgent,
        address _rootBridgeAgentFactory,
        uint128 _remoteExecutionGas
    ) internal virtual {
        //Check if msg.sender is a valid BridgeAgentFactory
        if (!IBranchPort(localPortAddress).isBridgeAgentFactory(_branchBridgeAgentFactory)) {
            revert UnrecognizedBridgeAgentFactory();
        }

        //Create Token
        address newBridgeAgent = IBranchBridgeAgentFactory(_branchBridgeAgentFactory).createBridgeAgent(
            _newBranchRouter, _rootBridgeAgent, _rootBridgeAgentFactory
        );

        //Check BridgeAgent Address
        if (!IBranchPort(localPortAddress).isBridgeAgent(newBridgeAgent)) {
            revert UnrecognizedBridgeAgent();
        }

        //Encode Data
        bytes memory data = abi.encode(newBridgeAgent, _rootBridgeAgent);

        //Pack FuncId
        bytes memory packedData = abi.encodePacked(bytes1(0x04), data);

        //Send Cross-Chain request
        IBranchBridgeAgent(localBridgeAgentAddress).performSystemCallOut(address(this), packedData, _remoteExecutionGas, 0);
    }

    /**
     * @notice Function to add/deactivate a Branch Bridge Agent Factory.
     *  @param _newBridgeAgentFactoryAddress the address of the new local bridge agent factory.
     *  @dev FUNC ID: 3
     *
     */
    function _toggleBranchBridgeAgentFactory(address _newBridgeAgentFactoryAddress) internal {
        if (!IBranchPort(localPortAddress).isBridgeAgentFactory(_newBridgeAgentFactoryAddress)) {
            IBranchPort(localPortAddress).addBridgeAgentFactory(_newBridgeAgentFactoryAddress);
        } else {
            IBranchPort(localPortAddress).toggleBridgeAgentFactory(_newBridgeAgentFactoryAddress);
        }
    }

    /**
     * @notice Function to remove an active Branch Bridge Agent from the system.
     *  @param _branchBridgeAgent the address of the local Bridge Agent to be removed.
     *  @dev FUNC ID: 4
     *
     */
    function _removeBranchBridgeAgent(address _branchBridgeAgent) internal {
        if (!IBranchPort(localPortAddress).isBridgeAgent(_branchBridgeAgent)) revert UnrecognizedBridgeAgent();
        IBranchPort(localPortAddress).toggleBridgeAgent(_branchBridgeAgent);
    }

    /**
     * @notice Function to add / remove a token to be used by Port Strategies.
     *  @param _underlyingToken the address of the underlying token.
     *  @param _minimumReservesRatio the minimum reserves ratio the Port must have.
     *  @dev FUNC ID: 5
     *
     */
    function _manageStrategyToken(address _underlyingToken, uint256 _minimumReservesRatio) internal {
        if (!IBranchPort(localPortAddress).isStrategyToken(_underlyingToken)) {
            IBranchPort(localPortAddress).addStrategyToken(_underlyingToken, _minimumReservesRatio);
        } else {
            IBranchPort(localPortAddress).toggleStrategyToken(_underlyingToken);
        }
    }

    /**
     * @notice Function to deploy/add a token already active in the global enviornment in the Root Chain. Must be called from another chain.
     *  @param _portStrategy the address of the port strategy.
     *  @param _underlyingToken the address of the underlying token.
     *  @param _dailyManagementLimit the daily management limit.
     *  @param _isUpdateDailyLimit if the daily limit is being updated.
     *  @dev FUNC ID: 6
     *
     */
    function _managePortStrategy(
        address _portStrategy,
        address _underlyingToken,
        uint256 _dailyManagementLimit,
        bool _isUpdateDailyLimit
    ) internal {
        if (!IBranchPort(localPortAddress).isPortStrategy(_portStrategy, _underlyingToken)) {
            //Add new Port Strategy if new.
            IBranchPort(localPortAddress).addPortStrategy(_portStrategy, _underlyingToken, _dailyManagementLimit);
        } else if (_isUpdateDailyLimit) {
            //Or Update daily limit.
            IBranchPort(localPortAddress).updatePortStrategy(_portStrategy, _underlyingToken, _dailyManagementLimit);
        } else {
            //Or Toggle Port Strategy.
            IBranchPort(localPortAddress).togglePortStrategy(_portStrategy, _underlyingToken);
        }
    }

    /*///////////////////////////////////////////////////////////////
                    ANYCALL EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBranchRouter
    function anyExecuteNoSettlement(bytes calldata _data)
        external
        virtual
        override
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        /// _receiveAddGlobalToken
        if (_data[0] == 0x01) {
            (address globalAddress, string memory name, string memory symbol, uint128 gasToBridgeOut) =
                abi.decode(_data[1:], (address, string, string, uint128));

            _receiveAddGlobalToken(globalAddress, name, symbol, gasToBridgeOut);
            /// _receiveAddBridgeAgent
        } else if (_data[0] == 0x02) {
            (
                address newBranchRouter,
                address branchBridgeAgentFactory,
                address rootBridgeAgent,
                address rootBridgeAgentFactory,
                uint128 remoteExecutionGas
            ) = abi.decode(_data[1:], (address, address, address, address, uint128));

            _receiveAddBridgeAgent(
                newBranchRouter, branchBridgeAgentFactory, rootBridgeAgent, rootBridgeAgentFactory, remoteExecutionGas
            );

            /// _toggleBranchBridgeAgentFactory
        } else if (_data[0] == 0x03) {
            (address bridgeAgentFactoryAddress) = abi.decode(_data[1:], (address));
            _toggleBranchBridgeAgentFactory(bridgeAgentFactoryAddress);

            /// _removeBranchBridgeAgent
        } else if (_data[0] == 0x04) {
            (address branchBridgeAgent) = abi.decode(_data[1:], (address));
            _removeBranchBridgeAgent(branchBridgeAgent);

            /// _manageStrategyToken
        } else if (_data[0] == 0x05) {
            (address underlyingToken, uint256 minimumReservesRatio) = abi.decode(_data[1:], (address, uint256));
            _manageStrategyToken(underlyingToken, minimumReservesRatio);

            /// _managePortStrategy
        } else if (_data[0] == 0x06) {
            (address portStrategy, address underlyingToken, uint256 dailyManagementLimit, bool isUpdateDailyLimit) =
                abi.decode(_data[1:], (address, address, uint256, bool));
            _managePortStrategy(portStrategy, underlyingToken, dailyManagementLimit, isUpdateDailyLimit);

            /// Unrecognized Function Selector
        } else {
            return (false, "unknown selector");
        }
        return (true, "");
    }

    fallback() external payable {}

    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentFactory();
}

