// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
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

// lib/solady/src/auth/Ownable.sol

/// @notice Simple single owner authorization mixin.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/auth/Ownable.sol)
///
/// @dev Note:
/// This implementation does NOT auto-initialize the owner to `msg.sender`.
/// You MUST call the `_initializeOwner` in the constructor / initializer.
///
/// While the ownable portion follows
/// [EIP-173](https://eips.ethereum.org/EIPS/eip-173) for compatibility,
/// the nomenclature for the 2-step ownership handover may be unique to this codebase.
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
    /// It is intentionally chosen to be a high value
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

    /// @dev Returns how long a two-step ownership handover is valid for in seconds.
    /// Override to return a different value if needed.
    /// Made internal to conserve bytecode. Wrap it in a public function if needed.
    function _ownershipHandoverValidFor() internal view virtual returns (uint64) {
        return 48 * 3600;
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
    /// The request will automatically expire in 48 hours (172800 seconds) by default.
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + _ownershipHandoverValidFor();
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

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         MODIFIERS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Marks a function as only callable by the owner.
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}

// lib/solady/src/utils/SafeTransferLib.sol

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
///
/// @dev Note:
/// - For ETH transfers, please use `forceSafeTransferETH` for DoS protection.
/// - For ERC20s, this implementation won't check that a token has code,
///   responsibility is delegated to the caller.
library SafeTransferLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The ETH transfer has failed.
    error ETHTransferFailed();

    /// @dev The ERC20 `transferFrom` has failed.
    error TransferFromFailed();

    /// @dev The ERC20 `transfer` has failed.
    error TransferFailed();

    /// @dev The ERC20 `approve` has failed.
    error ApproveFailed();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Suggested gas stipend for contract receiving ETH that disallows any storage writes.
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // If the ETH transfer MUST succeed with a reasonable gas budget, use the force variants.
    //
    // The regular variants:
    // - Forwards all remaining gas to the target.
    // - Reverts if the target reverts.
    // - Reverts if the current contract has insufficient balance.
    //
    // The force variants:
    // - Forwards with an optional gas stipend
    //   (defaults to `GAS_STIPEND_NO_GRIEF`, which is sufficient for most cases).
    // - If the target reverts, or if the gas stipend is exhausted,
    //   creates a temporary contract to force send the ETH via `SELFDESTRUCT`.
    //   Future compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758.
    // - Reverts if the current contract has insufficient balance.
    //
    // The try variants:
    // - Forwards with a mandatory gas stipend.
    // - Instead of reverting, returns whether the transfer succeeded.

    /// @dev Sends `amount` (in wei) ETH to `to`.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gas(), to, amount, gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`.
    function safeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer all the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, selfbalance(), gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) // For gas estimation.
                }
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) // For gas estimation.
                }
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) // `ETHTransferFailed()`.
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) // For gas estimation.
                }
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) // For gas estimation.
                }
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, amount, gas(), 0x00, gas(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), gas(), 0x00, gas(), 0x00)
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      ERC20 OPERATIONS                      */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
    /// the current contract to manage.
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x60, amount) // Store the `amount` argument.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x23b872dd000000000000000000000000) // `transferFrom(address,address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have their entire balance approved for
    /// the current contract to manage.
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        /// @solidity memory-safe-assembly
        assembly {
            let m := mload(0x40) // Cache the free memory pointer.
            mstore(0x40, to) // Store the `to` argument.
            mstore(0x2c, shl(96, from)) // Store the `from` argument.
            mstore(0x0c, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) // `transferFrom(address,address,uint256)`.
            amount := mload(0x60) // The `amount` is already at 0x60. We'll need to return it.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) // `TransferFromFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends `amount` of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransfer(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            // Read the balance, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) // Store the `to` argument.
            amount := mload(0x34) // The `amount` is already at 0x34. We'll need to return it.
            mstore(0x00, 0xa9059cbb000000000000000000000000) // `transfer(address,uint256)`.
            // Perform the transfer, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // `TransferFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, reverting upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// If the initial attempt to approve fails, attempts to reset the approved amount to zero,
    /// then retries the approval again (some tokens, e.g. USDT, requires this).
    /// Reverts upon failure.
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
            // Perform the approval, retrying upon failure.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) // Store 0 for the `amount`.
                mstore(0x00, 0x095ea7b3000000000000000000000000) // `approve(address,uint256)`.
                pop(call(gas(), token, 0, 0x10, 0x44, 0x00, 0x00)) // Reset the approval.
                mstore(0x34, amount) // Store back the original `amount`.
                // Retry the approval, reverting upon failure.
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), // Returned 1 or nothing.
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) // `ApproveFailed()`.
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) // Restore the part of the free memory pointer that was overwritten.
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            mstore(0x00, 0x70a08231000000000000000000000000) // `balanceOf(address)`.
            amount :=
                mul(
                    mload(0x20),
                    and( // The arguments of `and` are evaluated from right to left.
                        gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
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

// lib/solmate/src/tokens/ERC721.sol

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 indexed id);

    event Approval(address indexed owner, address indexed spender, uint256 indexed id);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");

        return _balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");

        require(to != address(0), "INVALID_RECIPIENT");

        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
            interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");

        require(_ownerOf[id] == address(0), "ALREADY_MINTED");

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];

        require(owner != address(0), "NOT_MINTED");

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        emit Transfer(owner, address(0), id);
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }

    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);

        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}

// src/interfaces/BridgeAgentStructs.sol

/*///////////////////////////////////////////////////////////////
                            STRUCTS
//////////////////////////////////////////////////////////////*/

struct GasParams {
    uint256 gasLimit; // gas allocated for the cross-chain call.
    uint256 remoteBranchExecutionGas; //gas allocated for remote branch execution. Must be lower than `gasLimit`.
}

struct Deposit {
    uint8 status;
    address owner;
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
}

struct DepositMultipleInput {
    //Deposit Info
    address[] hTokens; //Input Local hTokens Address.
    address[] tokens; //Input Native / underlying Token Address.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
}

struct DepositMultipleParams {
    //Deposit Info
    uint8 numberOfAssets; //Number of assets to deposit.
    uint32 depositNonce; //Deposit nonce.
    address[] hTokens; //Input Local hTokens Address.
    address[] tokens; //Input Native / underlying Token Address.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
}

struct DepositParams {
    //Deposit Info
    uint32 depositNonce; //Deposit nonce.
    address hToken; //Input Local hTokens Address.
    address token; //Input Native / underlying Token Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
}

struct Settlement {
    uint16 dstChainId; //Destination chain for interaction.
    uint80 status; //Status of the settlement
    address owner; //Owner of the settlement
    address recipient; //Recipient of the settlement.
    address[] hTokens; //Input Local hTokens Addresses.
    address[] tokens; //Input Native / underlying Token Addresses.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
}

struct SettlementInput {
    address globalAddress; //Input Global hTokens Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
}

struct SettlementMultipleInput {
    address[] globalAddresses; //Input Global hTokens Addresses.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
}

struct SettlementParams {
    uint32 settlementNonce; // Settlement nonce.
    address recipient; // Recipient of the settlement.
    address hToken; // Input Local hTokens Address.
    address token; // Input Native / underlying Token Address.
    uint256 amount; // Amount of Local hTokens deposited for interaction.
    uint256 deposit; // Amount of native tokens deposited for interaction.
}

struct SettlementMultipleParams {
    uint8 numberOfAssets; // Number of assets to deposit.
    address recipient; // Recipient of the settlement.
    uint32 settlementNonce; // Settlement nonce.
    address[] hTokens; // Input Local hTokens Addresses.
    address[] tokens; // Input Native / underlying Token Addresses.
    uint256[] amounts; // Amount of Local hTokens deposited for interaction.
    uint256[] deposits; // Amount of native tokens deposited for interaction.
}

// src/interfaces/IERC20hTokenRoot.sol

/**
 * @title  ERC20 hToken Root Contract
 * @author MaiaDAO.
 * @notice ERC20 hToken contract deployed in the Root Chain of the Ulysses Omnichain Liquidity System.
 *         1:1 ERC20 representation of a token deposited in a Branch Chain's Port.
 * @dev    This asset is minted / burned in reflection of it's origin Branch Port balance. Should not
 *         be burned being stored in Root Port instead if Branch hToken mint is requested.
 */
interface IERC20hTokenRoot {
    /*///////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice View Function returns Local Network Identifier.
    /// @return Local Network Identifier.
    function localChainId() external view returns (uint16);

    /// @notice View Function returns the address of the Factory that deployed this token.
    /// @return Address of the Factory that deployed this token.
    function factoryAddress() external view returns (address);

    /**
     * @notice View Function returns Token's balance in a given Branch Chain's Port.
     *   @param chainId Identifier of the Branch Chain.
     *   @return Token's balance in the given Branch Chain's Port.
     */
    function getTokenBalance(uint256 chainId) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to mint hTokens in the Root Chain to match Branch Chain deposit.
     * @param to Address of the user that will receive the hTokens.
     * @param amount Amount of hTokens to be minted.
     * @param chainId Identifier of the Branch Chain.
     * @return Boolean indicating if the mint was successful.
     */
    function mint(address to, uint256 amount, uint256 chainId) external returns (bool);

    /**
     * @notice Function to burn hTokens in the Root Chain to match Branch Chain withdrawal.
     * @param from Address of the user that will burn the hTokens.
     * @param amount Amount of hTokens to be burned.
     * @param chainId Identifier of the Branch Chain.
     */
    function burn(address from, uint256 amount, uint256 chainId) external;

    /*///////////////////////////////////////////////////////////////
                                ERRORS 
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedPort();
}

// src/interfaces/ILayerZeroReceiver.sol

interface ILayerZeroReceiver {
    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}

// lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155Receiver.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// lib/openzeppelin-contracts/contracts/utils/introspection/ERC165.sol

// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// src/interfaces/IVirtualAccount.sol

/// @notice Call structure based off `Multicall2` contract for aggregating calls.
struct Call {
    address target;
    bytes callData;
}

/// @notice Payable call structure based off `Multicall3` contract for aggreagating calls with `msg.value`.
struct PayableCall {
    address target;
    bytes callData;
    uint256 value;
}

/**
 * @title  Virtual Account Contract
 * @author MaiaDAO
 * @notice A Virtual Account allows users to manage assets and perform interactions remotely while
 *         allowing dApps to keep encapsulated user balance for accounting purposes.
 * @dev    This contract is based off `Multicall2` and `Multicall3` contract, executes a set of `Call` or `PayableCall`
 *         objects if any of the performed calls is invalid the whole batch should revert.
 */
interface IVirtualAccount is IERC721Receiver {
    /**
     * @notice Returns the address of the user that owns the VirtualAccount.
     * @return The address of the user that owns the VirtualAccount.
     */
    function userAddress() external view returns (address);

    /**
     * @notice Returns the address of the local port.
     * @return The address of the local port.
     */
    function localPortAddress() external view returns (address);

    /**
     * @notice Withdraws native tokens from the VirtualAccount.
     * @param _amount The amount of tokens to withdraw.
     */
    function withdrawNative(uint256 _amount) external;

    /**
     * @notice Withdraws ERC20 tokens from the VirtualAccount.
     * @param _token The address of the ERC20 token to withdraw.
     * @param _amount The amount of tokens to withdraw.
     */
    function withdrawERC20(address _token, uint256 _amount) external;

    /**
     * @notice Withdraws ERC721 tokens from the VirtualAccount.
     * @param _token The address of the ERC721 token to withdraw.
     * @param _tokenId The id of the token to withdraw.
     */
    function withdrawERC721(address _token, uint256 _tokenId) external;

    /**
     * @notice Aggregate calls ensuring each call is successful. Inspired by `Multicall2` contract.
     * @param callInput The call to make.
     * @return The return data of the call.
     */
    function call(Call[] calldata callInput) external returns (bytes[] memory);

    /**
     * @notice Aggregate calls with a msg value ensuring each call is successful. Inspired by `Multicall3` contract.
     * @param calls The calls to make.
     * @return The return data of the calls.
     * @dev Reverts if msg.value is less than the sum of the call values.
     */
    function payableCall(PayableCall[] calldata calls) external payable returns (bytes[] memory);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error CallFailed();

    error UnauthorizedCaller();
}

// src/interfaces/IRootBridgeAgent.sol

/*///////////////////////////////////////////////////////////////
                            ENUMS
//////////////////////////////////////////////////////////////*/

/**
 * @title  Root Bridge Agent Contract
 * @author MaiaDAO
 * @notice Contract responsible for interfacing with Users and Routers acting as a middleman to
 *         access LayerZero cross-chain messaging and Port communication for asset management.
 * @dev    Bridge Agents allow for the encapsulation of business logic as well as the standardized
 *         cross-chain communication, allowing for the creation of custom Routers to perform
 *         actions as a response to remote user requests. This contract is for deployment in the Root
 *         Chain Omnichain Environment based on Arbitrum.
 *         The Root Bridge Agent is responsible for sending/receiving requests to/from the LayerZero Messaging Layer for
 *         execution, as well as requests tokens clearances and tx execution from the `RootBridgeAgentExecutor`.
 *         Remote execution is "sandboxed" within 2 different layers/nestings:
 *         - 1: Upon receiving a request from LayerZero Messaging Layer to avoid blocking future requests due
 *              to execution reversion, ensuring our app is Non-Blocking.
 *              (See https://github.com/LayerZero-Labs/solidity-examples/blob/8e62ebc886407aafc89dbd2a778e61b7c0a25ca0/contracts/lzApp/NonblockingLzApp.sol)
 *         - 2: The call to `RootBridgeAgentExecutor` is in charge of requesting token deposits for each
 *              remote interaction as well as performing the Router calls if any of the calls initiated
 *              by the Router led to an invalid state change in both the token deposit clearances as well as
 *              the external interactions will be reverted and caught by the `RootBridgeAgent`.
 *
 *          Func IDs for calling these  functions through the messaging layer:
 *
 *       ROOT BRIDGE AGENT DEPOSIT FLAGS
 *       ------------------------------
 *       ID   | DESCRIPTION
 *       -----+------------------------
 *       0x00 | Branch Router System Request / Response.
 *       0x01 | Call to Root Router without Deposit.
 *       0x02 | Call to Root Router with Deposit.
 *       0x03 | Call to Root Router with Deposit of Multiple Tokens.
 *       0x04 | Call to Root Router without Deposit + singned message.
 *       0x05 | Call to Root Router with Deposit + singned message.
 *       0x06 | Call to Root Router with Deposit of Multiple Tokens + signed message.
 *       0x07 | Call to `retrySettlement()´. (retries sending a settlement w/ new calldata for execution + new gas)
 *       0x08 | Call to `retrieveDeposit()´. (clears a deposit that has not been executed yet triggering `_fallback`)
 *       0x09 | Call to `_fallback()`. (reopens a settlement for asset redemption)
 *
 *
 *          Encoding Scheme for different Root Bridge Agent Deposit Flags:
 *
 *           - ht = hToken
 *           - t = Token
 *           - A = Amount
 *           - D = Deposit
 *           - b = bytes
 *           - n = number of assets
 *       _____________________________________________________________________________________________________________
 *      |            Flag               |        Deposit Info        |             Token Info             |   DATA   |
 *      |           1 byte              |         4-25 bytes         |       104 or (128 * n) bytes       |   ---	 |
 *      |                               |                            |           hT - t - A - D           |          |
 *      |_______________________________|____________________________|____________________________________|__________|
 *      | callOutSystem = 0x0   	    |                 4b(nonce)  |            -------------           |   ---	 |
 *      | callOut = 0x1                 |                 4b(nonce)  |            -------------           |   ---	 |
 *      | callOutSingle = 0x2           |                 4b(nonce)  |        20b + 20b + 32b + 32b       |   ---	 |
 *      | callOutMulti = 0x3            |         1b(n) + 4b(nonce)  |   	  32b + 32b + 32b + 32b       |   ---	 |
 *      | callOutSigned = 0x4           |    20b(recip) + 4b(nonce)  |   	      -------------           |   ---    |
 *      | callOutSignedSingle = 0x5     |           20b + 4b(nonce)  |        20b + 20b + 32b + 32b       |   ---	 |
 *      | callOutSignedMultiple = 0x6   |   20b + 1b(n) + 4b(nonce)  |        32b + 32b + 32b + 32b       |   ---	 |
 *      |_______________________________|____________________________|____________________________________|__________|
 *
 *          Generic Contract Interaction Flow:
 *
 *                 BridgeAgent.lzReceive()
 *                           |
 *                           V
 *              BridgeAgentExecutor.execute**()
 *                           |
 *                           V
 *                   Router.execute**()
 *                           |
 *                           V
 *            BridgeAgentExecutor (txExecuted)
 *
 */
interface IRootBridgeAgent is ILayerZeroReceiver {
    /*///////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function that returns the current settlement nonce.
     *   @return nonce bridge agent's current settlement nonce
     *
     */
    function settlementNonce() external view returns (uint32 nonce);

    /**
     * @notice External function that returns a given settlement entry.
     *   @param _settlementNonce Identifier for token settlement.
     *
     */
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory);

    /**
     * @notice External function to get the Bridge Agent Executor Address.
     * @return address Bridge Agent Executor Address.
     */
    function bridgeAgentExecutorAddress() external view returns (address);

    /**
     * @notice External function to get the Root Bridge Agent's Factory Address.
     *   @return address Root Bridge Agent's Factory Address.
     */
    function factoryAddress() external view returns (address);

    /**
     * @notice External function to get the attached Branch Bridge Agent for a given chain.
     *   @param _chainId Chain ID of the Branch Bridge Agent.
     *   @return address Branch Bridge Agent Address.
     */
    function getBranchBridgeAgent(uint256 _chainId) external view returns (address);

    /**
     * @notice External function to verify a given chain has been allowed by the Root Bridge Agent's Manager
     *         for new Branch Bridge Agent creation.
     *   @param _chainId Chain ID of the Branch Bridge Agent.
     *   @return bool True if the chain has been allowed for new Branch Bridge Agent creation.
     */
    function isBranchBridgeAgentAllowed(uint256 _chainId) external view returns (bool);

    /**
     * @notice External function that returns the message value needed for a cross-chain call according to
     *         the destination chain and the given calldata and gas requirements.
     *   @param _dstChainId destination Chain ID.
     *   @param _payload Calldata for branch router execution.
     *   @param _gasLimit Gas limit for cross-chain message.
     *   @param _remoteBranchExecutionGas Gas limit for branch router execution.
     *   @return _fee Message value needed for cross-chain call.
     */
    function getFeeEstimate(
        uint256 _gasLimit,
        uint256 _remoteBranchExecutionGas,
        bytes calldata _payload,
        uint16 _dstChainId
    ) external view returns (uint256 _fee);

    /*///////////////////////////////////////////////////////////////
                        ROOT ROUTER CALL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice External function performs call to LayerZero Endpoint Contract for cross-chain messaging.
     *   @param _recipient address to receive any outstanding gas on the destination chain.
     *   @param _dstChainId Chain to bridge to.
     *   @param _params Calldata for function call.
     *   @param _gParams Gas Parameters for cross-chain message.
     *   @dev Internal function performs call to LayerZero Endpoint Contract for cross-chain messaging.
     */
    function callOut(
        address payable _refundee,
        address _recipient,
        uint16 _dstChainId,
        bytes memory _params,
        GasParams calldata _gParams
    ) external payable;

    /**
     * @notice External function to move assets from root chain to branch omnichain environment.
     *   @param _refundee the effective owner of the settlement this address receives excess gas deposited on source chain
     *                    for a cross-chain call and is allowed to redeeming assets after a failed settlement fallback.
     *                    This address' Virtual Account is also allowed.
     *   @param _recipient recipient of bridged tokens and any outstanding gas on the destination chain.
     *   @param _dstChainId chain to bridge to.
     *   @param _params parameters for function call on branch chain.
     *   @param _sParams settlement parameters for asset bridging to branch chains.
     *   @param _gParams Gas Parameters for cross-chain message.
     *   @param _hasFallbackToggled Flag to toggle fallback function.
     *
     */
    function callOutAndBridge(
        address payable _refundee,
        address _recipient,
        uint16 _dstChainId,
        bytes calldata _params,
        SettlementInput calldata _sParams,
        GasParams calldata _gParams,
        bool _hasFallbackToggled
    ) external payable;

    /**
     * @notice External function to move assets from branch chain to root omnichain environment.
     *   @param _refundee the effective owner of the settlement this address receives excess gas deposited on source chain
     *                    for a cross-chain call and is allowed to redeeming assets after a failed settlement fallback.
     *                    This address' Virtual Account is also allowed.
     *   @param _recipient recipient of bridged tokens.
     *   @param _dstChainId chain to bridge to.
     *   @param _params parameters for function call on branch chain.
     *   @param _sParams settlement parameters for asset bridging to branch chains.
     *   @param _gParams Gas Parameters for cross-chain message.
     *   @param _hasFallbackToggled Flag to toggle fallback function.
     *
     *
     */
    function callOutAndBridgeMultiple(
        address payable _refundee,
        address _recipient,
        uint16 _dstChainId,
        bytes calldata _params,
        SettlementMultipleInput calldata _sParams,
        GasParams calldata _gParams,
        bool _hasFallbackToggled
    ) external payable;

    /*///////////////////////////////////////////////////////////////
                        SETTLEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to retry a user's Settlement balance.
     *   @param _settlementNonce Identifier for token settlement.
     *   @param _recipient recipient of bridged tokens and any outstanding gas on the destination chain.
     *   @param _params Calldata for function call in branch chain.
     *   @param _gParams Gas Parameters for cross-chain message.
     *   @param _hasFallbackToggled Flag to toggle fallback function.
     *
     */
    function retrySettlement(
        uint32 _settlementNonce,
        address _recipient,
        bytes calldata _params,
        GasParams calldata _gParams,
        bool _hasFallbackToggled
    ) external payable;

    /**
     * @notice Function that allows retrieval of failed Settlement's foricng fallback to be triggered.
     *   @param _settlementNonce Identifier for token settlement.
     *   @param _gParams Gas Parameters for cross-chain message.
     *
     */
    function retrieveSettlement(uint32 _settlementNonce, GasParams calldata _gParams) external payable;

    /**
     * @notice Function that allows redemption of failed Settlement's global tokens.
     *   @param _depositNonce Identifier for token deposit.
     *
     */
    function redeemSettlement(uint32 _depositNonce) external;

    /*///////////////////////////////////////////////////////////////
                    TOKEN MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to move assets from branch chain to root omnichain environment.
     * @dev Called in response to Bridge Agent Executor.
     *   @param _recipient recipient of bridged token.
     *   @param _dParams Cross-Chain Deposit of Multiple Tokens Params.
     *   @param _srcChainId chain to bridge from.
     *
     */
    function bridgeIn(address _recipient, DepositParams memory _dParams, uint256 _srcChainId) external;

    /**
     * @notice Function to move assets from branch chain to root omnichain environment.
     * @dev Called in response to Bridge Agent Executor.
     *   @param _recipient recipient of bridged tokens.
     *   @param _dParams Cross-Chain Deposit of Multiple Tokens Params.
     *   @param _srcChainId chain to bridge from.
     *   @dev Since the input data is encodePacked we need to parse it:
     *     1. First byte is the number of assets to be bridged in. Equals length of all arrays.
     *     2. Next 4 bytes are the nonce of the deposit.
     *     3. Last 32 bytes after the token related information are the chain to bridge to.
     *     4. Token related information starts at index PARAMS_TKN_START is encoded as follows:
     *         1. N * 32 bytes for the hToken address.
     *         2. N * 32 bytes for the underlying token address.
     *         3. N * 32 bytes for the amount of hTokens to be bridged in.
     *         4. N * 32 bytes for the amount of underlying tokens to be bridged in.
     *     5. Each of the 4 token related arrays are of length N and start at the following indexes:
     *         1. PARAMS_TKN_START [hToken address has no offset from token information start].
     *         2. PARAMS_TKN_START + (PARAMS_ADDRESS_SIZE * N)
     *         3. PARAMS_TKN_START + (PARAMS_AMT_OFFSET * N)
     *         4. PARAMS_TKN_START + (PARAMS_DEPOSIT_OFFSET * N)
     *
     */
    function bridgeInMultiple(address _recipient, DepositMultipleParams calldata _dParams, uint256 _srcChainId)
        external;

    /*///////////////////////////////////////////////////////////////
                            LAYER ZERO FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice External function to receive cross-chain messages from LayerZero Endpoint Contract without blocking.
     *   @param _endpoint address of the LayerZero Endpoint Contract.
     *   @param _srcChainId Chain ID of the sender.
     *   @param _srcAddress address path of the recipient + sender.
     *   @param _payload Calldata for function call.
     */
    function lzReceiveNonBlocking(
        address _endpoint,
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        bytes calldata _payload
    ) external;

    /*///////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new branch bridge agent to a given branch chainId
     *   @param _branchChainId chainId of the branch chain
     */
    function approveBranchBridgeAgent(uint256 _branchChainId) external;

    /**
     * @notice Updates the address of the branch bridge agent
     *   @param _newBranchBridgeAgent address of the new branch bridge agent
     *   @param _branchChainId chainId of the branch chain
     */
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint256 _branchChainId) external;

    /*///////////////////////////////////////////////////////////////
                             EVENTS
    //////////////////////////////////////////////////////////////*/

    event LogExecute(uint256 indexed depositNonce, uint256 indexed srcChainId);
    event LogFallback(uint256 indexed settlementNonce, uint256 indexed dstChainId);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error ExecutionFailure();
    error GasErrorOrRepeatedTx();
    error AlreadyExecutedTransaction();
    error UnknownFlag();

    error NotDao();

    error LayerZeroUnauthorizedEndpoint();
    error LayerZeroUnauthorizedCaller();

    error AlreadyAddedBridgeAgent();
    error UnrecognizedExecutor();
    error UnrecognizedPort();
    error UnrecognizedBridgeAgent();
    error UnrecognizedLocalBridgeAgent();
    error UnrecognizedBridgeAgentManager();
    error UnrecognizedRouter();

    error UnrecognizedUnderlyingAddress();
    error UnrecognizedLocalAddress();

    error SettlementRetryUnavailable();
    error SettlementRetryUnavailableUseCallout();
    error SettlementRedeemUnavailable();
    error SettlementRetrieveUnavailable();
    error NotSettlementOwner();

    error InsufficientBalanceForSettlement();
    error InsufficientGasForFees();
    error InvalidInputParams();
    error InvalidInputParamsLength();

    error CallerIsNotPool();
    error AmountsAreZero();
}

// lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Receiver.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// src/token/ERC20hTokenRoot.sol

/// @title ERC20 hToken Contract
/// @author MaiaDAO
contract ERC20hTokenRoot is ERC20, Ownable, IERC20hTokenRoot {
    /// @inheritdoc IERC20hTokenRoot
    uint16 public immutable override localChainId;

    /// @inheritdoc IERC20hTokenRoot
    address public immutable override factoryAddress;

    /// @inheritdoc IERC20hTokenRoot
    mapping(uint256 chainId => uint256 balance) public override getTokenBalance;

    /**
     * @notice Constructor for the ERC20hTokenRoot Contract.
     *     @param _localChainId Local Network Identifier.
     *     @param _factoryAddress Address of the Factory Contract.
     *     @param _rootPortAddress Address of the Root Port Contract.
     *     @param _name Name of the Token.
     *     @param _symbol Symbol of the Token.
     *     @param _decimals Decimals of the Token.
     */
    constructor(
        uint16 _localChainId,
        address _factoryAddress,
        address _rootPortAddress,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(string(string.concat(_name)), string(string.concat(_symbol)), _decimals) {
        require(_rootPortAddress != address(0), "Root Port Address cannot be 0");
        require(_factoryAddress != address(0), "Factory Address cannot be 0");

        localChainId = _localChainId;
        factoryAddress = _factoryAddress;
        _initializeOwner(_rootPortAddress);
    }

    /*///////////////////////////////////////////////////////////////
                        ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints new tokens and updates the total supply for the given chain.
     * @param to Address to mint tokens to.
     * @param amount Amount of tokens to mint.
     * @param chainId Chain Id of the chain to mint tokens to.
     */
    function mint(address to, uint256 amount, uint256 chainId) external onlyOwner returns (bool) {
        getTokenBalance[chainId] += amount;
        _mint(to, amount);
        return true;
    }

    /**
     * @notice Burns new tokens and updates the total supply for the given chain.
     * @param from Address to burn tokens from.
     * @param amount Amount of tokens to burn.
     * @param chainId Chain Id of the chain to burn tokens to.
     */
    function burn(address from, uint256 amount, uint256 chainId) external onlyOwner {
        getTokenBalance[chainId] -= amount;
        _burn(from, amount);
    }
}

// src/interfaces/IERC20hTokenRootFactory.sol

/**
 * @title  Factory Contract for Root hTokens
 * @author MaiaDAO
 * @notice Factory contract allowing for permissionless deployment of new Root hTokens in the
 *  	   Root Chain of Ulysses Omnichain Liquidity Protocol.
 * @dev    This contract is called by the chain's Core Root Router.
 */
interface IERC20hTokenRootFactory {
    /*///////////////////////////////////////////////////////////////
                            hTOKEN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to create a new hToken.
     * @param _name Name of the Token.
     * @param _symbol Symbol of the Token.
     * @param _decimals Decimals of the Token.
     */
    function createToken(string memory _name, string memory _symbol, uint8 _decimals)
        external
        returns (ERC20hTokenRoot newToken);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedCoreRouterOrPort();
}

// src/VirtualAccount.sol

/// @title VirtualAccount - Contract for managing a virtual user account on the Root Chain
contract VirtualAccount is IVirtualAccount, ERC1155Receiver {
    using SafeTransferLib for address;

    /// @inheritdoc IVirtualAccount
    address public immutable override userAddress;

    /// @inheritdoc IVirtualAccount
    address public immutable override localPortAddress;

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Constructor for Virtual Account.
     * @param _userAddress Address of the user account.
     * @param _localPortAddress Address of the root port contract.
     */
    constructor(address _userAddress, address _localPortAddress) {
        userAddress = _userAddress;
        localPortAddress = _localPortAddress;
    }

    /*//////////////////////////////////////////////////////////////
                            FALLBACK FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    receive() external payable {}

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IVirtualAccount
    function withdrawNative(uint256 _amount) external override requiresApprovedCaller {
        msg.sender.safeTransferETH(_amount);
    }

    /// @inheritdoc IVirtualAccount
    function withdrawERC20(address _token, uint256 _amount) external override requiresApprovedCaller {
        _token.safeTransfer(msg.sender, _amount);
    }

    /// @inheritdoc IVirtualAccount
    function withdrawERC721(address _token, uint256 _tokenId) external override requiresApprovedCaller {
        ERC721(_token).transferFrom(address(this), msg.sender, _tokenId);
    }

    /// @inheritdoc IVirtualAccount
    function call(Call[] calldata calls) external override requiresApprovedCaller returns (bytes[] memory returnData) {
        uint256 length = calls.length;
        returnData = new bytes[](length);

        for (uint256 i = 0; i < length;) {
            bool success;
            Call calldata _call = calls[i];

            if (isContract(_call.target)) (success, returnData[i]) = _call.target.call(_call.callData);

            if (!success) revert CallFailed();

            unchecked {
                ++i;
            }
        }
    }

    /// @inheritdoc IVirtualAccount
    function payableCall(PayableCall[] calldata calls) public payable returns (bytes[] memory returnData) {
        uint256 valAccumulator;
        uint256 length = calls.length;
        returnData = new bytes[](length);
        PayableCall calldata _call;
        for (uint256 i = 0; i < length;) {
            _call = calls[i];
            uint256 val = _call.value;
            // Humanity will be a Type V Kardashev Civilization before this overflows - andreas
            // ~ 10^25 Wei in existence << ~ 10^76 size uint fits in a uint256
            unchecked {
                valAccumulator += val;
            }

            bool success;

            if (isContract(_call.target)) (success, returnData[i]) = _call.target.call{value: val}(_call.callData);

            if (!success) revert CallFailed();

            unchecked {
                ++i;
            }
        }

        // Finally, make sure the msg.value = SUM(call[0...i].value)
        if (msg.value != valAccumulator) revert CallFailed();
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL HOOKS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC721Receiver
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL HELPERS
    //////////////////////////////////////////////////////////////*/

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /*///////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier that verifies msg sender is the approved to use the virtual account. Either the owner or an approved router.
    modifier requiresApprovedCaller() {
        if (!IRootPort(localPortAddress).isRouterApproved(this, msg.sender)) {
            if (msg.sender != userAddress) {
                revert UnauthorizedCaller();
            }
        }
        _;
    }
}

// src/interfaces/IRootPort.sol

/// @title Core Root Router Interface
interface ICoreRootRouter {
    function bridgeAgentAddress() external view returns (address);
    function hTokenFactoryAddress() external view returns (address);
    function setCoreBranch(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable;
}

/**
 * @title  Root Port - Omnichain Token Management Contract
 * @author MaiaDAO
 * @notice Ulysses `RootPort` implementation for Root Omnichain Environment deployment.
 *         This contract is used to manage the deposit and withdrawal of assets
 *         between the Root Omnichain Environment and every Branch Chain in response to
 *         Root Bridge Agents requests. Manages Bridge Agents and their factories as well as
 *         key governance enabled actions such as adding new chains and bridge agent factories.
 */
interface IRootPort {
    /*///////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice View Function returns True if the chain Id has been added to the system.
     *  @param _chainId The Layer Zero chainId of the chain.
     * @return bool True if the chain Id has been added to the system.
     */
    function isChainId(uint256 _chainId) external view returns (bool);

    /**
     * @notice View Function returns bridge agent manager for a given root bridge agent.
     *  @param _rootBridgeAgent address of the root bridge agent.
     * @return address address of the bridge agent manager.
     */
    function getBridgeAgentManager(address _rootBridgeAgent) external view returns (address);

    /**
     * @notice View Function returns True if the bridge agent factory has been added to the system.
     *  @param _bridgeAgentFactory The address of the bridge agent factory.
     * @return bool True if the bridge agent factory has been added to the system.
     */
    function isBridgeAgentFactory(address _bridgeAgentFactory) external view returns (bool);

    /**
     * @notice View Function returns True if the address corresponds to a global token.
     *  @param _globalAddress The address of the token in the global chain.
     * @return bool True if the address corresponds to a global token.
     */
    function isGlobalAddress(address _globalAddress) external view returns (bool);

    /**
     * @notice View Function returns Token's Global Address from it's local address.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return address The address of the global token.
     */
    function getGlobalTokenFromLocal(address _localAddress, uint256 _srcChainId) external view returns (address);

    /**
     * @notice View Function returns Token's Local Address from it's global address.
     *  @param _globalAddress The address of the token in the global chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return address The address of the local token.
     */
    function getLocalTokenFromGlobal(address _globalAddress, uint256 _srcChainId) external view returns (address);

    /**
     * @notice View Function that returns the local token address from the underlying token address.
     *  @param _underlyingAddress The address of the underlying token.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return address The address of the local token.
     */
    function getLocalTokenFromUnderlying(address _underlyingAddress, uint256 _srcChainId)
        external
        view
        returns (address);

    /**
     * @notice Function that returns Local Token's Local Address on another chain.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     *  @param _dstChainId The chainId of the chain where the token is deployed.
     * @return address The address of the local token in the destination chain.
     */
    function getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (address);

    /**
     * @notice View Function returns a underlying token address from it's local address.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return address The address of the underlying token.
     */
    function getUnderlyingTokenFromLocal(address _localAddress, uint256 _srcChainId) external view returns (address);

    /**
     * @notice Returns the underlying token address given it's global address.
     *  @param _globalAddress The address of the token in the global chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return address The address of the underlying token.
     */
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint256 _srcChainId)
        external
        view
        returns (address);

    /**
     * @notice View Function returns True if Global Token is already added in current chain, false otherwise.
     *  @param _globalAddress The address of the token in the global chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return bool True if Global Token is already added in current chain, false otherwise.
     */
    function isGlobalToken(address _globalAddress, uint256 _srcChainId) external view returns (bool);

    /**
     * @notice View Function returns True if Local Token is already added in current chain, false otherwise.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return bool True if Local Token is already added in current chain, false otherwise.
     */
    function isLocalToken(address _localAddress, uint256 _srcChainId) external view returns (bool);

    /**
     * @notice View Function returns True if Local Token is already added in destination chain, false otherwise.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     *  @param _dstChainId The chainId of the chain where the token is deployed.
     * @return bool True if Local Token is already added in current chain, false otherwise.
     */
    function isLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (bool);

    /**
     * @notice View Function returns True if the underlying Token is already added in given chain, false otherwise.
     *  @param _underlyingToken The address of the underlying token.
     *  @param _srcChainId The chainId of the chain where the token is deployed.
     * @return bool True if the underlying Token is already added in given chain, false otherwise.
     */
    function isUnderlyingToken(address _underlyingToken, uint256 _srcChainId) external view returns (bool);

    /**
     * @notice View Function returns Virtual Account of a given user.
     *  @param _user The address of the user.
     * @return VirtualAccount user virtual account.
     */
    function getUserAccount(address _user) external view returns (VirtualAccount);

    /**
     * @notice View Function returns True if the router is approved by user request to use their virtual account.
     *  @param _userAccount The virtual account of the user.
     *  @param _router The address of the router.
     * @return bool True if the router is approved by user request to use their virtual account.
     */
    function isRouterApproved(VirtualAccount _userAccount, address _router) external returns (bool);

    /*///////////////////////////////////////////////////////////////
                        hTOKEN ACCOUTING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Burns hTokens from the sender address.
     * @param _from sender of the hTokens to burn.
     * @param _hToken address of the hToken to burn.
     * @param _amount amount of hTokens to burn.
     * @param _srcChainId The chainId of the chain where the token is deployed.
     */
    function burn(address _from, address _hToken, uint256 _amount, uint256 _srcChainId) external;

    /**
     * @notice Updates root port state to match a new deposit.
     * @param _recipient recipient of bridged tokens.
     * @param _hToken address of the hToken to bridge.
     * @param _amount amount of hTokens to bridge.
     * @param _deposit amount of underlying tokens to deposit.
     * @param _srcChainId The chainId of the chain where the token is deployed.
     */
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint256 _srcChainId)
        external;

    /**
     * @notice Bridges hTokens from the local branch to the root port.
     * @param _from sender of the hTokens to bridge.
     * @param _hToken address of the hToken to bridge.
     * @param _amount amount of hTokens to bridge.
     */
    function bridgeToRootFromLocalBranch(address _from, address _hToken, uint256 _amount) external;

    /**
     * @notice Bridges hTokens from the root port to the local branch.
     * @param _to recipient of the bridged tokens.
     * @param _hToken address of the hToken to bridge.
     * @param _amount amount of hTokens to bridge.
     */
    function bridgeToLocalBranchFromRoot(address _to, address _hToken, uint256 _amount) external;

    /**
     * @notice Mints new tokens to the recipient address
     * @param _recipient recipient of the newly minted tokens.
     * @param _hToken address of the hToken to mint.
     * @param _amount amount of tokens to mint.
     */
    function mintToLocalBranch(address _recipient, address _hToken, uint256 _amount) external;

    /**
     * @notice Burns tokens from the sender address
     * @param _from sender of the tokens to burn.
     * @param _hToken address of the hToken to burn.
     * @param _amount amount of tokens to burn.
     */
    function burnFromLocalBranch(address _from, address _hToken, uint256 _amount) external;

    /*///////////////////////////////////////////////////////////////
                        hTOKEN MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Setter function to update a Global hToken's Local hToken Address.
     *   @param _globalAddress new hToken address to update.
     *   @param _localAddress new underlying/native token address to set.
     *
     */
    function setAddresses(
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _srcChainId
    ) external;

    /**
     * @notice Setter function to update a Global hToken's Local hToken Address.
     *   @param _globalAddress new hToken address to update.
     *   @param _localAddress new underlying/native token address to set.
     *
     */
    function setLocalAddress(address _globalAddress, address _localAddress, uint256 _srcChainId) external;

    /*///////////////////////////////////////////////////////////////
                    VIRTUAL ACCOUNT MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the virtual account given a user address.
     * @param _user address of the user to get the virtual account for.
     */
    function fetchVirtualAccount(address _user) external returns (VirtualAccount account);

    /**
     * @notice Toggles the approval of a router for a virtual account.
     * @dev Allows for a router to spend from a user's virtual account.
     * @param _userAccount virtual account to toggle the approval for.
     * @param _router router to toggle the approval for.
     */
    function toggleVirtualAccountApproved(VirtualAccount _userAccount, address _router) external;

    /*///////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the address of the bridge agent for a given chain.
     * @param _newBranchBridgeAgent address of the new branch bridge agent.
     * @param _rootBridgeAgent address of the root bridge agent.
     * @param _srcChainId chainId of the chain to set the bridge agent for.
     */
    function syncBranchBridgeAgentWithRoot(address _newBranchBridgeAgent, address _rootBridgeAgent, uint256 _srcChainId)
        external;

    /**
     * @notice Adds a new bridge agent to the list of bridge agents.
     * @param _manager address of the manager of the bridge agent.
     * @param _bridgeAgent address of the bridge agent to add.
     */
    function addBridgeAgent(address _manager, address _bridgeAgent) external;

    /**
     * @notice Toggles the status of a bridge agent.
     * @param _bridgeAgent address of the bridge agent to toggle.
     */
    function toggleBridgeAgent(address _bridgeAgent) external;

    /**
     * @notice Adds a new bridge agent factory to the list of bridge agent factories.
     * @param _bridgeAgentFactory address of the bridge agent factory to add.
     */
    function addBridgeAgentFactory(address _bridgeAgentFactory) external;

    /**
     * @notice Toggles the status of a bridge agent factory.
     * @param _bridgeAgentFactory address of the bridge agent factory to toggle.
     */
    function toggleBridgeAgentFactory(address _bridgeAgentFactory) external;

    /**
     * @notice Adds a new chain to the root port lists of chains
     * @param _coreBranchBridgeAgentAddress address of the core branch bridge agent
     * @param _chainId chainId of the new chain
     * @param _wrappedGasTokenName gas token name of the chain to add
     * @param _wrappedGasTokenSymbol gas token symbol of the chain to add
     * @param _wrappedGasTokenDecimals gas token decimals of the chain to add
     * @param _newLocalBranchWrappedNativeTokenAddress address of the wrapped native token of the new branch
     * @param _newUnderlyingBranchWrappedNativeTokenAddress new branch address of the underlying wrapped native token
     */
    function addNewChain(
        address _coreBranchBridgeAgentAddress,
        uint256 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint8 _wrappedGasTokenDecimals,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external;

    /**
     * @notice Adds an ecosystem hToken to a branch chain
     * @param ecoTokenGlobalAddress ecosystem token global address
     */
    function addEcosystemToken(address ecoTokenGlobalAddress) external;

    /**
     * @notice Sets the core root router and bridge agent
     * @param _coreRootRouter address of the core root router
     * @param _coreRootBridgeAgent address of the core root bridge agent
     */
    function setCoreRootRouter(address _coreRootRouter, address _coreRootBridgeAgent) external;

    /**
     * @notice Sets the core branch router and bridge agent
     * @param _refundee address of the refundee
     * @param _coreBranchRouter address of the core branch router
     * @param _coreBranchBridgeAgent address of the core branch bridge agent
     * @param _dstChainId chainId of the destination chain
     * @param _gParams gas params for the transaction
     */
    function setCoreBranchRouter(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable;

    /**
     * @notice Syncs a newly added core branch router and bridge agent
     * @param _coreBranchRouter address of the core branch router
     * @param _coreBranchBridgeAgent address of the core branch bridge agent
     * @param _dstChainId chainId of the destination chain
     */
    function syncNewCoreBranchRouter(address _coreBranchRouter, address _coreBranchBridgeAgent, uint16 _dstChainId)
        external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    event BridgeAgentFactoryAdded(address indexed bridgeAgentFactory);
    event BridgeAgentFactoryToggled(address indexed bridgeAgentFactory);

    event BridgeAgentAdded(address indexed bridgeAgent, address indexed manager);
    event BridgeAgentToggled(address indexed bridgeAgent);
    event BridgeAgentSynced(address indexed bridgeAgent, address indexed rootBridgeAgent, uint256 indexed srcChainId);

    event NewChainAdded(uint256 indexed chainId);

    event VirtualAccountCreated(address indexed user, address account);

    event LocalTokenAdded(
        address indexed underlyingAddress, address indexed localAddress, address indexed globalAddress, uint256 chainId
    );
    event GlobalTokenAdded(address indexed localAddress, address indexed globalAddress, uint256 indexed chainId);
    event EcosystemTokenAdded(address indexed ecoTokenGlobalAddress);
    event CoreRootSet(address indexed coreRootRouter, address indexed coreRootBridgeAgent);
    event CoreBranchSet(
        address indexed coreBranchRouter, address indexed coreBranchBridgeAgent, uint16 indexed dstChainId
    );
    event CoreBranchSynced(
        address indexed coreBranchRouter, address indexed coreBranchBridgeAgent, uint16 indexed dstChainId
    );

    /*///////////////////////////////////////////////////////////////
                            ERRORS  
    //////////////////////////////////////////////////////////////*/

    error InvalidGlobalAddress();
    error InvalidLocalAddress();
    error InvalidUnderlyingAddress();

    error InvalidUserAddress();

    error InvalidCoreRootRouter();
    error InvalidCoreRootBridgeAgent();
    error InvalidCoreBranchRouter();
    error InvalidCoreBrancBridgeAgent();

    error UnrecognizedBridgeAgentFactory();
    error UnrecognizedBridgeAgent();

    error UnrecognizedToken();
    error UnableToMint();

    error AlreadyAddedChain();
    error AlreadyAddedEcosystemToken();

    error AlreadyAddedBridgeAgent();
    error AlreadyAddedBridgeAgentFactory();
    error BridgeAgentNotAllowed();
    error UnrecognizedCoreRootRouter();
    error UnrecognizedLocalBranchPort();
}

// src/RootPort.sol

/// @title Root Port - Omnichain Token Management Contract
/// @author MaiaDAO
contract RootPort is Ownable, IRootPort {
    using SafeTransferLib for address;

    /*///////////////////////////////////////////////////////////////
                            SETUP STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice True if setup is still ongoing, false otherwise.
    bool internal _setup;

    /// @notice True if core setup is still ongoing, false otherwise.
    bool internal _setupCore;

    /*///////////////////////////////////////////////////////////////
                        ROOT PORT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Local Chain Id
    uint256 public immutable localChainId;

    /// @notice The address of local branch port responsible for handling local transactions.
    address public localBranchPortAddress;

    /// @notice The address of the core router in charge of adding new tokens to the system.
    address public coreRootRouterAddress;

    /// @notice The address of the core router in charge of adding new tokens to the system.
    address public coreRootBridgeAgentAddress;

    /*///////////////////////////////////////////////////////////////
                        VIRTUAL ACCOUNT
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping from user address to Virtual Account.
    mapping(address user => VirtualAccount account) public getUserAccount;

    /// @notice Holds the mapping from Virtual account to router address => bool.
    /// @notice Stores whether a router is approved to spend a virtual account.
    mapping(VirtualAccount acount => mapping(address router => bool allowed)) public isRouterApproved;

    /*///////////////////////////////////////////////////////////////
                        BRIDGE AGENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping from address to Bridge Agent.
    mapping(uint256 chainId => bool isActive) public isChainId;

    /// @notice Mapping from address to isBridgeAgent (bool).
    mapping(address bridgeAgent => bool isActive) public isBridgeAgent;

    /// @notice Bridge Agents deployed in root chain.
    address[] public bridgeAgents;

    /// @notice Mapping address Bridge Agent => address Bridge Agent Manager
    mapping(address bridgeAgent => address bridgeAgentManager) public getBridgeAgentManager;

    /*///////////////////////////////////////////////////////////////
                    BRIDGE AGENT FACTORIES
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping from Underlying Address to isUnderlying (bool).
    mapping(address bridgeAgentFactory => bool isActive) public isBridgeAgentFactory;

    /// @notice Bridge Agents deployed in root chain.
    address[] public bridgeAgentFactories;

    /*///////////////////////////////////////////////////////////////
                            hTOKENS
    //////////////////////////////////////////////////////////////*/

    /// @notice Mapping with all global hTokens deployed in the system.
    mapping(address token => bool isGlobalToken) public isGlobalAddress;

    /// @notice ChainId -> Local Address -> Global Address
    mapping(address chainId => mapping(uint256 localAddress => address globalAddress)) public getGlobalTokenFromLocal;

    /// @notice ChainId -> Global Address -> Local Address
    mapping(address chainId => mapping(uint256 globalAddress => address localAddress)) public getLocalTokenFromGlobal;

    /// @notice ChainId -> Underlying Address -> Local Address
    mapping(address chainId => mapping(uint256 underlyingAddress => address localAddress)) public
        getLocalTokenFromUnderlying;

    /// @notice Mapping from Local Address to Underlying Address.
    mapping(address chainId => mapping(uint256 localAddress => address underlyingAddress)) public
        getUnderlyingTokenFromLocal;

    /*///////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Constructor for Root Port.
     * @param _localChainId layer zero chain id of the local chain.
     */
    constructor(uint256 _localChainId) {
        localChainId = _localChainId;
        isChainId[_localChainId] = true;

        _initializeOwner(msg.sender);
        _setup = true;
        _setupCore = true;
    }

    /*///////////////////////////////////////////////////////////////
                    INITIALIZATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice Function to initialize the Root Port.
     *   @param _bridgeAgentFactory The address of the Bridge Agent Factory.
     *   @param _coreRootRouter The address of the Core Root Router.
     */
    function initialize(address _bridgeAgentFactory, address _coreRootRouter) external onlyOwner {
        require(_bridgeAgentFactory != address(0), "Bridge Agent Factory cannot be 0 address.");
        require(_coreRootRouter != address(0), "Core Root Router cannot be 0 address.");
        require(_setup, "Setup ended.");
        _setup = false;

        isBridgeAgentFactory[_bridgeAgentFactory] = true;
        bridgeAgentFactories.push(_bridgeAgentFactory);

        coreRootRouterAddress = _coreRootRouter;
    }

    /**
     *  @notice Function to initialize the Root Chain Core Contracts in Port Storage.
     *   @param _coreRootBridgeAgent The address of the Core Root Bridge Agent.
     *   @param _coreLocalBranchBridgeAgent The address of the Core Arbitrum Branch Bridge Agent.
     *   @param _localBranchPortAddress The address of the Arbitrum Branch Port.
     */
    function initializeCore(
        address _coreRootBridgeAgent,
        address _coreLocalBranchBridgeAgent,
        address _localBranchPortAddress
    ) external onlyOwner {
        require(_coreRootBridgeAgent != address(0), "Core Root Bridge Agent cannot be 0 address.");
        require(_coreLocalBranchBridgeAgent != address(0), "Core Local Branch Bridge Agent cannot be 0 address.");
        require(_localBranchPortAddress != address(0), "Local Branch Port Address cannot be 0 address.");
        require(isBridgeAgent[_coreRootBridgeAgent], "Core Bridge Agent doesn't exist.");
        require(_setupCore, "Core Setup ended.");
        _setupCore = false;

        coreRootBridgeAgentAddress = _coreRootBridgeAgent;
        localBranchPortAddress = _localBranchPortAddress;
        IRootBridgeAgent(_coreRootBridgeAgent).syncBranchBridgeAgent(_coreLocalBranchBridgeAgent, localChainId);
        getBridgeAgentManager[_coreRootBridgeAgent] = owner();
    }

    /// @notice Function being overriden to prevent mistakenly renouncing ownership.
    function renounceOwnership() public payable override onlyOwner {
        revert("Cannot renounce ownership");
    }

    /*///////////////////////////////////////////////////////////////
                        EXTERNAL VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootPort
    function getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        override
        returns (address)
    {
        return _getLocalToken(_localAddress, _srcChainId, _dstChainId);
    }

    /**
     * @notice View Function returns Local Token's Local Address on another chain.
     * @param _localAddress The address of the token in the local chain.
     * @param _srcChainId The chainId of the chain where the token is deployed.
     * @param _dstChainId The chainId of the chain for which the token address is requested.
     */
    function _getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        internal
        view
        returns (address)
    {
        address globalAddress = getGlobalTokenFromLocal[_localAddress][_srcChainId];
        return getLocalTokenFromGlobal[globalAddress][_dstChainId];
    }

    /// @inheritdoc IRootPort
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint256 _srcChainId)
        external
        view
        override
        returns (address)
    {
        address localAddress = getLocalTokenFromGlobal[_globalAddress][_srcChainId];
        return getUnderlyingTokenFromLocal[localAddress][_srcChainId];
    }

    /// @inheritdoc IRootPort
    function isGlobalToken(address _globalAddress, uint256 _srcChainId) external view override returns (bool) {
        return getLocalTokenFromGlobal[_globalAddress][_srcChainId] != address(0);
    }

    /// @inheritdoc IRootPort
    function isLocalToken(address _localAddress, uint256 _srcChainId) external view override returns (bool) {
        return getGlobalTokenFromLocal[_localAddress][_srcChainId] != address(0);
    }

    /// @inheritdoc IRootPort
    function isLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (bool)
    {
        return _getLocalToken(_localAddress, _srcChainId, _dstChainId) != address(0);
    }

    /// @inheritdoc IRootPort
    function isUnderlyingToken(address _underlyingToken, uint256 _srcChainId) external view override returns (bool) {
        return getLocalTokenFromUnderlying[_underlyingToken][_srcChainId] != address(0);
    }

    /*///////////////////////////////////////////////////////////////
                        hTOKEN MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootPort
    function setAddresses(
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _srcChainId
    ) external override requiresCoreRootRouter {
        if (_globalAddress == address(0)) revert InvalidGlobalAddress();
        if (_localAddress == address(0)) revert InvalidLocalAddress();
        if (_underlyingAddress == address(0)) revert InvalidUnderlyingAddress();

        isGlobalAddress[_globalAddress] = true;
        getGlobalTokenFromLocal[_localAddress][_srcChainId] = _globalAddress;
        getLocalTokenFromGlobal[_globalAddress][_srcChainId] = _localAddress;
        getLocalTokenFromUnderlying[_underlyingAddress][_srcChainId] = _localAddress;
        getUnderlyingTokenFromLocal[_localAddress][_srcChainId] = _underlyingAddress;

        emit LocalTokenAdded(_underlyingAddress, _localAddress, _globalAddress, _srcChainId);
    }

    /// @inheritdoc IRootPort
    function setLocalAddress(address _globalAddress, address _localAddress, uint256 _srcChainId)
        external
        override
        requiresCoreRootRouter
    {
        if (_localAddress == address(0)) revert InvalidLocalAddress();

        getGlobalTokenFromLocal[_localAddress][_srcChainId] = _globalAddress;
        getLocalTokenFromGlobal[_globalAddress][_srcChainId] = _localAddress;

        emit GlobalTokenAdded(_localAddress, _globalAddress, _srcChainId);
    }

    /*///////////////////////////////////////////////////////////////
                        hTOKEN ACCOUNTING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootPort
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint256 _srcChainId)
        external
        override
        requiresBridgeAgent
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();

        if (_amount - _deposit > 0) {
            unchecked {
                _hToken.safeTransfer(_recipient, _amount - _deposit);
            }
        }

        if (_deposit > 0) if (!ERC20hTokenRoot(_hToken).mint(_recipient, _deposit, _srcChainId)) revert UnableToMint();
    }

    /// @inheritdoc IRootPort
    function bridgeToRootFromLocalBranch(address _from, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();

        _hToken.safeTransferFrom(_from, address(this), _amount);
    }

    function bridgeToLocalBranchFromRoot(address _to, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();

        _hToken.safeTransfer(_to, _amount);
    }

    /// @inheritdoc IRootPort
    function burn(address _from, address _hToken, uint256 _amount, uint256 _srcChainId)
        external
        override
        requiresBridgeAgent
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        ERC20hTokenRoot(_hToken).burn(_from, _amount, _srcChainId);
    }

    /// @inheritdoc IRootPort
    function burnFromLocalBranch(address _from, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();

        ERC20hTokenRoot(_hToken).burn(_from, _amount, localChainId);
    }

    /// @inheritdoc IRootPort
    function mintToLocalBranch(address _to, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        if (!ERC20hTokenRoot(_hToken).mint(_to, _amount, localChainId)) revert UnableToMint();
    }

    /*///////////////////////////////////////////////////////////////
                    VIRTUAL ACCOUNT MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootPort
    function fetchVirtualAccount(address _user) external override returns (VirtualAccount account) {
        account = getUserAccount[_user];
        if (address(account) == address(0)) account = addVirtualAccount(_user);
    }

    /**
     * @notice Creates a new virtual account for a user.
     * @param _user address of the user to associate a virtual account with.
     */
    function addVirtualAccount(address _user) internal returns (VirtualAccount newAccount) {
        if (_user == address(0)) revert InvalidUserAddress();

        newAccount = new VirtualAccount{salt: keccak256(abi.encode(_user))}(_user, address(this));
        getUserAccount[_user] = newAccount;

        emit VirtualAccountCreated(_user, address(newAccount));
    }

    /// @inheritdoc IRootPort
    function toggleVirtualAccountApproved(VirtualAccount _userAccount, address _router)
        external
        override
        requiresBridgeAgent
    {
        isRouterApproved[_userAccount][_router] = !isRouterApproved[_userAccount][_router];
    }

    /*///////////////////////////////////////////////////////////////
                        BRIDGE AGENT ADDITION FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootPort
    function addBridgeAgent(address _manager, address _bridgeAgent) external override requiresBridgeAgentFactory {
        if (isBridgeAgent[_bridgeAgent]) revert AlreadyAddedBridgeAgent();

        bridgeAgents.push(_bridgeAgent);
        getBridgeAgentManager[_bridgeAgent] = _manager;
        isBridgeAgent[_bridgeAgent] = true;

        emit BridgeAgentAdded(_bridgeAgent, _manager);
    }

    /// @inheritdoc IRootPort
    function syncBranchBridgeAgentWithRoot(
        address _newBranchBridgeAgent,
        address _rootBridgeAgent,
        uint256 _branchChainId
    ) external override requiresCoreRootRouter {
        if (IRootBridgeAgent(_rootBridgeAgent).getBranchBridgeAgent(_branchChainId) != address(0)) {
            revert AlreadyAddedBridgeAgent();
        }
        if (!IRootBridgeAgent(_rootBridgeAgent).isBranchBridgeAgentAllowed(_branchChainId)) {
            revert BridgeAgentNotAllowed();
        }
        IRootBridgeAgent(_rootBridgeAgent).syncBranchBridgeAgent(_newBranchBridgeAgent, _branchChainId);

        emit BridgeAgentSynced(_newBranchBridgeAgent, _rootBridgeAgent, _branchChainId);
    }

    /*///////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootPort
    function toggleBridgeAgent(address _bridgeAgent) external override onlyOwner {
        isBridgeAgent[_bridgeAgent] = !isBridgeAgent[_bridgeAgent];

        emit BridgeAgentToggled(_bridgeAgent);
    }

    /// @inheritdoc IRootPort
    function addBridgeAgentFactory(address _bridgeAgentFactory) external override onlyOwner {
        if (isBridgeAgentFactory[_bridgeAgentFactory]) revert AlreadyAddedBridgeAgentFactory();

        bridgeAgentFactories.push(_bridgeAgentFactory);
        isBridgeAgentFactory[_bridgeAgentFactory] = true;

        emit BridgeAgentFactoryAdded(_bridgeAgentFactory);
    }

    /// @inheritdoc IRootPort
    function toggleBridgeAgentFactory(address _bridgeAgentFactory) external override onlyOwner {
        isBridgeAgentFactory[_bridgeAgentFactory] = !isBridgeAgentFactory[_bridgeAgentFactory];

        emit BridgeAgentFactoryToggled(_bridgeAgentFactory);
    }

    /// @inheritdoc IRootPort
    function addNewChain(
        address _coreBranchBridgeAgentAddress,
        uint256 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint8 _wrappedGasTokenDecimals,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external override onlyOwner {
        // Check if chain already added
        if (isChainId[_chainId]) revert AlreadyAddedChain();

        // Create new global token for new chain's wrapped native token
        address newGlobalToken = address(
            IERC20hTokenRootFactory(ICoreRootRouter(coreRootRouterAddress).hTokenFactoryAddress()).createToken(
                _wrappedGasTokenName, _wrappedGasTokenSymbol, _wrappedGasTokenDecimals
            )
        );

        // Sync new branch bridge agent with root core bridge agent
        IRootBridgeAgent(ICoreRootRouter(coreRootRouterAddress).bridgeAgentAddress()).syncBranchBridgeAgent(
            _coreBranchBridgeAgentAddress, _chainId
        );

        // Update State

        // 1. Add new chain to chainId mapping
        isChainId[_chainId] = true;
        // 2. Add new chain to global address mapping
        isGlobalAddress[newGlobalToken] = true;
        // 3. Add new branch local token to global token address mapping
        getGlobalTokenFromLocal[_newLocalBranchWrappedNativeTokenAddress][_chainId] = newGlobalToken;
        // 4. Add new global token to branch local token address mapping
        getLocalTokenFromGlobal[newGlobalToken][_chainId] = _newLocalBranchWrappedNativeTokenAddress;
        // 5. Add new branch underlying token to branch local token address mapping
        getLocalTokenFromUnderlying[_newUnderlyingBranchWrappedNativeTokenAddress][_chainId] =
            _newLocalBranchWrappedNativeTokenAddress;
        // 6. Add new branch local token to branch underlying token address mapping
        getUnderlyingTokenFromLocal[_newLocalBranchWrappedNativeTokenAddress][_chainId] =
            _newUnderlyingBranchWrappedNativeTokenAddress;

        emit NewChainAdded(_chainId);
    }

    /// @inheritdoc IRootPort
    function addEcosystemToken(address _ecoTokenGlobalAddress) external override onlyOwner {
        // Check if token already added
        if (isGlobalAddress[_ecoTokenGlobalAddress]) revert AlreadyAddedEcosystemToken();

        // Check if token is already a underlying token in current chain
        if (getUnderlyingTokenFromLocal[_ecoTokenGlobalAddress][localChainId] != address(0)) {
            revert AlreadyAddedEcosystemToken();
        }

        // Check if token is already a local branch token in current chain
        if (getLocalTokenFromUnderlying[_ecoTokenGlobalAddress][localChainId] != address(0)) {
            revert AlreadyAddedEcosystemToken();
        }

        // Update State
        // 1. Add new global token to global address mapping
        isGlobalAddress[_ecoTokenGlobalAddress] = true;
        // 2. Add new branch local token address to global token mapping
        getGlobalTokenFromLocal[_ecoTokenGlobalAddress][localChainId] = _ecoTokenGlobalAddress;
        // 3. Add new global token to branch local token address mapping
        getLocalTokenFromGlobal[_ecoTokenGlobalAddress][localChainId] = _ecoTokenGlobalAddress;

        emit EcosystemTokenAdded(_ecoTokenGlobalAddress);
    }

    /// @inheritdoc IRootPort
    function setCoreRootRouter(address _coreRootRouter, address _coreRootBridgeAgent) external override onlyOwner {
        if (_coreRootRouter == address(0)) revert InvalidCoreRootRouter();
        if (_coreRootBridgeAgent == address(0)) revert InvalidCoreRootBridgeAgent();

        coreRootRouterAddress = _coreRootRouter;
        coreRootBridgeAgentAddress = _coreRootBridgeAgent;
        getBridgeAgentManager[_coreRootBridgeAgent] = owner();

        emit CoreRootSet(_coreRootRouter, _coreRootBridgeAgent);
    }

    /// @inheritdoc IRootPort
    function setCoreBranchRouter(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable override onlyOwner {
        if (_coreBranchRouter == address(0)) revert InvalidCoreBranchRouter();
        if (_coreBranchBridgeAgent == address(0)) revert InvalidCoreBrancBridgeAgent();

        ICoreRootRouter(coreRootRouterAddress).setCoreBranch{value: msg.value}(
            _refundee, _coreBranchRouter, _coreBranchBridgeAgent, _dstChainId, _gParams
        );

        emit CoreBranchSet(_coreBranchRouter, _coreBranchBridgeAgent, _dstChainId);
    }

    /// @inheritdoc IRootPort
    function syncNewCoreBranchRouter(address _coreBranchRouter, address _coreBranchBridgeAgent, uint16 _dstChainId)
        external
        override
        onlyOwner
    {
        if (_coreBranchRouter == address(0)) revert InvalidCoreBranchRouter();
        if (_coreBranchBridgeAgent == address(0)) revert InvalidCoreBrancBridgeAgent();

        IRootBridgeAgent(coreRootBridgeAgentAddress).syncBranchBridgeAgent(_coreBranchBridgeAgent, _dstChainId);

        emit CoreBranchSynced(_coreBranchRouter, _coreBranchBridgeAgent, _dstChainId);
    }

    /*///////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier that verifies msg sender is an active Bridge Agent Factory.
    modifier requiresBridgeAgentFactory() {
        if (!isBridgeAgentFactory[msg.sender]) revert UnrecognizedBridgeAgentFactory();
        _;
    }

    /// @notice Modifier that verifies msg sender is an active Bridge Agent.
    modifier requiresBridgeAgent() {
        if (!isBridgeAgent[msg.sender]) revert UnrecognizedBridgeAgent();
        _;
    }

    /// @notice Modifier that verifies msg sender is the Root Chain's Core Router.
    modifier requiresCoreRootRouter() {
        if (msg.sender != coreRootRouterAddress) revert UnrecognizedCoreRootRouter();
        _;
    }

    /// @notice Modifier that verifies msg sender is the Root Chain's Local Branch Port.
    modifier requiresLocalBranchPort() {
        if (msg.sender != localBranchPortAddress) revert UnrecognizedLocalBranchPort();
        _;
    }
}

