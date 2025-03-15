// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
pragma abicoder v2;

// lib/EnumerableSet.sol

// OpenZeppelin Contracts v4.4.1 (utils/structs/EnumerableSet.sol)

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
 * ```
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
        return _values(set._inner);
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
     * @dev Returns the number of values on the set. O(1).
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

        assembly {
            result := store
        }

        return result;
    }
}

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

// lib/solady/src/utils/FixedPointMathLib.sol

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
library FixedPointMathLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error ExpOverflow();

    /// @dev The operation failed, as the output exceeds the maximum value of uint256.
    error FactorialOverflow();

    /// @dev The operation failed, due to an multiplication overflow.
    error MulWadFailed();

    /// @dev The operation failed, either due to a
    /// multiplication overflow, or a division by a zero.
    error DivWadFailed();

    /// @dev The multiply-divide operation failed, either due to a
    /// multiplication overflow, or a division by a zero.
    error MulDivFailed();

    /// @dev The division failed, as the denominator is zero.
    error DivFailed();

    /// @dev The full precision multiply-divide operation failed, either due
    /// to the result being larger than 256 bits, or a division by a zero.
    error FullMulDivFailed();

    /// @dev The output is undefined, as the input is less-than-or-equal to zero.
    error LnWadUndefined();

    /// @dev The output is undefined, as the input is zero.
    error Log2Undefined();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                         CONSTANTS                          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev The scalar of ETH and most ERC20s.
    uint256 internal constant WAD = 1e18;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*              SIMPLIFIED FIXED POINT OPERATIONS             */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Equivalent to `(x * y) / WAD` rounded down.
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                // Store the function selector of `MulWadFailed()`.
                mstore(0x00, 0xbac65e5b)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }

    /// @dev Equivalent to `(x * y) / WAD` rounded up.
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(y, gt(x, div(not(0), y))) {
                // Store the function selector of `MulWadFailed()`.
                mstore(0x00, 0xbac65e5b)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded down.
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                // Store the function selector of `DivWadFailed()`.
                mstore(0x00, 0x7c5f487d)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }

    /// @dev Equivalent to `(x * WAD) / y` rounded up.
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `require(y != 0 && (WAD == 0 || x <= type(uint256).max / WAD))`.
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                // Store the function selector of `DivWadFailed()`.
                mstore(0x00, 0x7c5f487d)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }

    /// @dev Equivalent to `x` to the power of `y`.
    /// because `x ** y = (e ** ln(x)) ** y = e ** (ln(x) * y)`.
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        // Using `ln(x)` means `x` must be greater than 0.
        return expWad((lnWad(x) * y) / int256(WAD));
    }

    /// @dev Returns `exp(x)`, denominated in `WAD`.
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            // When the result is < 0.5 we return zero. This happens when
            // x <= floor(log(0.5e18) * 1e18) ~ -42e18
            if (x <= -42139678854452767551) return r;

            /// @solidity memory-safe-assembly
            assembly {
                // When the result is > (2**255 - 1) / 1e18 we can not represent it as an
                // int. This happens when x >= floor(log((2**255 - 1) / 1e18) * 1e18) ~ 135.
                if iszero(slt(x, 135305999368893231589)) {
                    // Store the function selector of `ExpOverflow()`.
                    mstore(0x00, 0xa37bfec9)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }
            }

            // x is now in the range (-42, 136) * 1e18. Convert to (-42, 136) * 2**96
            // for more intermediate precision and a binary basis. This base conversion
            // is a multiplication by 1e18 / 2**96 = 5**18 / 2**78.
            x = (x << 78) / 5 ** 18;

            // Reduce range of x to (-½ ln 2, ½ ln 2) * 2**96 by factoring out powers
            // of two such that exp(x) = exp(x') * 2**k, where k is an integer.
            // Solving this gives k = round(x / log(2)) and x' = x - k * log(2).
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;

            // k is in the range [-61, 195].

            // Evaluate using a (6, 7)-term rational approximation.
            // p is made monic, we'll multiply by a scale factor later.
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;

            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial won't have zeros in the domain as all its roots are complex.
                // No scaling is necessary because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r should be in the range (0.09, 0.25) * 2**96.

            // We now need to multiply r by:
            // * the scale factor s = ~6.031367120.
            // * the 2**k factor from the range reduction.
            // * the 1e18 / 2**96 factor for base conversion.
            // We do this all at once, with an intermediate result in 2**213
            // basis, so the final right shift is always by a positive amount.
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }

    /// @dev Returns `ln(x)`, denominated in `WAD`.
    function lnWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            /// @solidity memory-safe-assembly
            assembly {
                if iszero(sgt(x, 0)) {
                    // Store the function selector of `LnWadUndefined()`.
                    mstore(0x00, 0x1615e638)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }
            }

            // We want to convert x from 10**18 fixed point to 2**96 fixed point.
            // We do this by multiplying by 2**96 / 10**18. But since
            // ln(x * C) = ln(x) + ln(C), we can simply do nothing here
            // and add ln(2**96 / 10**18) at the end.

            // Compute k = log2(x) - 96.
            int256 k;
            /// @solidity memory-safe-assembly
            assembly {
                let v := x
                k := shl(7, lt(0xffffffffffffffffffffffffffffffff, v))
                k := or(k, shl(6, lt(0xffffffffffffffff, shr(k, v))))
                k := or(k, shl(5, lt(0xffffffff, shr(k, v))))

                // For the remaining 32 bits, use a De Bruijn lookup.
                // See: https://graphics.stanford.edu/~seander/bithacks.html
                v := shr(k, v)
                v := or(v, shr(1, v))
                v := or(v, shr(2, v))
                v := or(v, shr(4, v))
                v := or(v, shr(8, v))
                v := or(v, shr(16, v))

                // forgefmt: disable-next-item
                k := sub(or(k, byte(shr(251, mul(v, shl(224, 0x07c4acdd))),
                    0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f)), 96)
            }

            // Reduce range of x to (1, 2) * 2**96
            // ln(2^k * x) = k * ln(2) + ln(x)
            x <<= uint256(159 - k);
            x = int256(uint256(x) >> 159);

            // Evaluate using a (8, 8)-term rational approximation.
            // p is made monic, we will multiply by a scale factor later.
            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);

            // We leave p in 2**192 basis so we don't need to scale it back up for the division.
            // q is monic by convention.
            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;
            /// @solidity memory-safe-assembly
            assembly {
                // Div in assembly because solidity adds a zero check despite the unchecked.
                // The q polynomial is known not to have zeros in the domain.
                // No scaling required because p is already 2**96 too large.
                r := sdiv(p, q)
            }

            // r is in the range (0, 0.125) * 2**96

            // Finalization, we need to:
            // * multiply by the scale factor s = 5.549…
            // * add ln(2**96 / 10**18)
            // * add k * ln(2)
            // * multiply by 10**18 / 2**96 = 5**18 >> 78

            // mul s * 5e18 * 2**96, base is now 5**18 * 2**192
            r *= 1677202110996718588342820967067443963516166;
            // add ln(2) * k * 5e18 * 2**192
            r += 16597577552685614221487285958193947469193820559219878177908093499208371 * k;
            // add ln(2**96 / 10**18) * 5e18 * 2**192
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            // base conversion: mul 2**18 / 2**192
            r >>= 174;
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  GENERAL NUMBER UTILITIES                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Calculates `floor(a * b / d)` with full precision.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Remco Bloemen under MIT license: https://2π.com/21/muldiv
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            for {} 1 {} {
                // 512-bit multiply `[prod1 prod0] = x * y`.
                // Compute the product mod `2**256` and mod `2**256 - 1`
                // then use the Chinese Remainder Theorem to reconstruct
                // the 512 bit result. The result is stored in two 256
                // variables such that `product = prod1 * 2**256 + prod0`.

                // Least significant 256 bits of the product.
                let prod0 := mul(x, y)
                let mm := mulmod(x, y, not(0))
                // Most significant 256 bits of the product.
                let prod1 := sub(mm, add(prod0, lt(mm, prod0)))

                // Handle non-overflow cases, 256 by 256 division.
                if iszero(prod1) {
                    if iszero(d) {
                        // Store the function selector of `FullMulDivFailed()`.
                        mstore(0x00, 0xae47f702)
                        // Revert with (offset, size).
                        revert(0x1c, 0x04)
                    }
                    result := div(prod0, d)
                    break       
                }

                // Make sure the result is less than `2**256`.
                // Also prevents `d == 0`.
                if iszero(gt(d, prod1)) {
                    // Store the function selector of `FullMulDivFailed()`.
                    mstore(0x00, 0xae47f702)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }

                ///////////////////////////////////////////////
                // 512 by 256 division.
                ///////////////////////////////////////////////

                // Make division exact by subtracting the remainder from `[prod1 prod0]`.
                // Compute remainder using mulmod.
                let remainder := mulmod(x, y, d)
                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
                // Factor powers of two out of `d`.
                // Compute largest power of two divisor of `d`.
                // Always greater or equal to 1.
                let twos := and(d, sub(0, d))
                // Divide d by power of two.
                d := div(d, twos)
                // Divide [prod1 prod0] by the factors of two.
                prod0 := div(prod0, twos)
                // Shift in bits from `prod1` into `prod0`. For this we need
                // to flip `twos` such that it is `2**256 / twos`.
                // If `twos` is zero, then it becomes one.
                prod0 := or(prod0, mul(prod1, add(div(sub(0, twos), twos), 1)))
                // Invert `d mod 2**256`
                // Now that `d` is an odd number, it has an inverse
                // modulo `2**256` such that `d * inv = 1 mod 2**256`.
                // Compute the inverse by starting with a seed that is correct
                // correct for four bits. That is, `d * inv = 1 mod 2**4`.
                let inv := xor(mul(3, d), 2)
                // Now use Newton-Raphson iteration to improve the precision.
                // Thanks to Hensel's lifting lemma, this also works in modular
                // arithmetic, doubling the correct bits in each step.
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**8
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**16
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**32
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**64
                inv := mul(inv, sub(2, mul(d, inv))) // inverse mod 2**128
                result := mul(prod0, mul(inv, sub(2, mul(d, inv)))) // inverse mod 2**256
                break
            }
        }
    }

    /// @dev Calculates `floor(x * y / d)` with full precision, rounded up.
    /// Throws if result overflows a uint256 or when `d` is zero.
    /// Credit to Uniswap-v3-core under MIT license:
    /// https://github.com/Uniswap/v3-core/blob/contracts/libraries/FullMath.sol
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        /// @solidity memory-safe-assembly
        assembly {
            if mulmod(x, y, d) {
                if iszero(add(result, 1)) {
                    // Store the function selector of `FullMulDivFailed()`.
                    mstore(0x00, 0xae47f702)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }
                result := add(result, 1)
            }
        }
    }

    /// @dev Returns `floor(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), d)
        }
    }

    /// @dev Returns `ceil(x * y / d)`.
    /// Reverts if `x * y` overflows, or `d` is zero.
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(d != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
        }
    }

    /// @dev Returns `ceil(x / d)`.
    /// Reverts if `d` is zero.
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(d) {
                // Store the function selector of `DivFailed()`.
                mstore(0x00, 0x65244e4e)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }

    /// @dev Returns `max(0, x - y)`.
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }

    /// @dev Returns the square root of `x`.
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // `floor(sqrt(2**15)) = 181`. `sqrt(2**15) - 181 = 2.84`.
            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // Let `y = x / 2**r`.
            // We check `y >= 2**(k + 8)` but shift right by `k` bits
            // each branch to ensure that if `x >= 256`, then `y >= 256`.
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)

            // Goal was to get `z*z*y` within a small factor of `x`. More iterations could
            // get y in a tighter range. Currently, we will have y in `[256, 256*(2**16))`.
            // We ensured `y >= 256` so that the relative difference between `y` and `y+1` is small.
            // That's not possible if `x < 256` but we can just verify those cases exhaustively.

            // Now, `z*z*y <= x < z*z*(y+1)`, and `y <= 2**(16+8)`, and either `y >= 256`, or `x < 256`.
            // Correctness can be checked exhaustively for `x < 256`, so we assume `y >= 256`.
            // Then `z*sqrt(y)` is within `sqrt(257)/sqrt(256)` of `sqrt(x)`, or about 20bps.

            // For `s` in the range `[1/256, 256]`, the estimate `f(s) = (181/1024) * (s+1)`
            // is in the range `(1/2.84 * sqrt(s), 2.84 * sqrt(s))`,
            // with largest error when `s = 1` and when `s = 256` or `1/256`.

            // Since `y` is in `[256, 256*(2**16))`, let `a = y/65536`, so that `a` is in `[1/256, 256)`.
            // Then we can estimate `sqrt(y)` using
            // `sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2**18`.

            // There is no overflow risk here since `y < 2**136` after the first branch above.
            z := shr(18, mul(z, add(shr(r, x), 65536))) // A `mul()` is saved from starting `z` at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If `x+1` is a perfect square, the Babylonian method cycles between
            // `floor(sqrt(x))` and `ceil(sqrt(x))`. This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    /// @dev Returns the cube root of `x`.
    /// Credit to bout3fiddy and pcaversaccio under AGPLv3 license:
    /// https://github.com/pcaversaccio/snekmate/blob/main/src/utils/Math.vy
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))

            z := shl(add(div(r, 3), lt(0xf, shr(r, x))), 0xff)
            z := div(z, byte(mod(r, 3), shl(232, 0x7f624b)))

            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)

            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }

    /// @dev Returns the factorial of `x`.
    function factorial(uint256 x) internal pure returns (uint256 result) {
        /// @solidity memory-safe-assembly
        assembly {
            for {} 1 {} {
                if iszero(lt(10, x)) {
                    // forgefmt: disable-next-item
                    result := and(
                        shr(mul(22, x), 0x375f0016260009d80004ec0002d00001e0000180000180000200000400001),
                        0x3fffff
                    )
                    break
                }
                if iszero(lt(57, x)) {
                    let end := 31
                    result := 8222838654177922817725562880000000
                    if iszero(lt(end, x)) {
                        end := 10
                        result := 3628800
                    }
                    for { let w := not(0) } 1 {} {
                        result := mul(result, x)
                        x := add(x, w)
                        if eq(x, end) { break }
                    }
                    break
                }
                // Store the function selector of `FactorialOverflow()`.
                mstore(0x00, 0xaba0f2a2)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Returns the log2 of `x`.
    /// Equivalent to computing the index of the most significant bit (MSB) of `x`.
    function log2(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(x) {
                // Store the function selector of `Log2Undefined()`.
                mstore(0x00, 0x5be3aa5c)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            // See: https://graphics.stanford.edu/~seander/bithacks.html
            x := shr(r, x)
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))

            // forgefmt: disable-next-item
            r := or(r, byte(shr(251, mul(x, shl(224, 0x07c4acdd))),
                0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f))
        }
    }

    /// @dev Returns the log2 of `x`, rounded up.
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        unchecked {
            uint256 isNotPo2;
            assembly {
                isNotPo2 := iszero(iszero(and(x, sub(x, 1))))
            }
            return log2(x) + isNotPo2;
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }

    /// @dev Returns the average of `x` and `y`.
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (((x & 1) + (y & 1)) >> 1);
        }
    }

    /// @dev Returns the absolute value of `x`.
    function abs(int256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let mask := sub(0, shr(255, x))
            z := xor(mask, add(mask, x))
        }
    }

    /// @dev Returns the absolute distance between `x` and `y`.
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let a := sub(y, x)
            z := xor(a, mul(xor(a, sub(x, y)), sgt(x, y)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }

    /// @dev Returns the minimum of `x` and `y`.
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }

    /// @dev Returns the maximum of `x` and `y`.
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        z = min(max(x, minValue), maxValue);
    }

    /// @dev Returns `x`, bounded to `minValue` and `maxValue`.
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        z = min(max(x, minValue), maxValue);
    }

    /// @dev Returns greatest common divisor of `x` and `y`.
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                   RAW NUMBER OPERATIONS                    */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x + y`, without checking for overflow.
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x - y`, without checking for underflow.
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x * y`, without checking for overflow.
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := div(x, y)
        }
    }

    /// @dev Returns `x / y`, returning 0 if `y` is zero.
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := sdiv(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mod(x, y)
        }
    }

    /// @dev Returns `x % y`, returning 0 if `y` is zero.
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := smod(x, y)
        }
    }

    /// @dev Returns `(x + y) % d`, return 0 if `d` if zero.
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := addmod(x, y, d)
        }
    }

    /// @dev Returns `(x * y) % d`, return 0 if `d` if zero.
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := mulmod(x, y, d)
        }
    }
}

// lib/solady/src/utils/Multicallable.sol

/// @notice Contract that enables a single call to call multiple methods on itself.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/Multicallable.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/Multicallable.sol)
abstract contract Multicallable {
    /// @dev Apply `DELEGATECALL` with the current contract to each calldata in `data`,
    /// and store the `abi.encode` formatted results of each `DELEGATECALL` into `results`.
    /// If any of the `DELEGATECALL`s reverts, the entire context is reverted,
    /// and the error is bubbled up.
    ///
    /// This function is deliberately made non-payable to guard against double-spending.
    /// (See: https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong)
    ///
    /// For efficiency, this function will directly return the results, terminating the context.
    /// If called internally, it must be called at the end of a function
    /// that returns `(bytes[] memory)`.
    function multicall(bytes[] calldata data) public virtual returns (bytes[] memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x20, data.length) // Store `data.length` into `results`.
            // Early return if no data.
            if iszero(data.length) { return(0x00, 0x40) }

            let results := 0x40
            // `shl` 5 is equivalent to multiplying by 0x20.
            let end := shl(5, data.length)
            // Copy the offsets from calldata into memory.
            calldatacopy(0x40, data.offset, end)
            // Offset into `results`.
            let resultsOffset := end
            // Pointer to the end of `results`.
            end := add(results, end)

            for {} 1 {} {
                // The offset of the current bytes in the calldata.
                let o := add(data.offset, mload(results))
                let memPtr := add(resultsOffset, 0x40)
                // Copy the current bytes from calldata to the memory.
                calldatacopy(
                    memPtr,
                    add(o, 0x20), // The offset of the current bytes' bytes.
                    calldataload(o) // The length of the current bytes.
                )
                if iszero(delegatecall(gas(), address(), memPtr, calldataload(o), 0x00, 0x00)) {
                    // Bubble up the revert if the delegatecall reverts.
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
                // Append the current `resultsOffset` into `results`.
                mstore(results, resultsOffset)
                results := add(results, 0x20)
                // Append the `returndatasize()`, and the return data.
                mstore(memPtr, returndatasize())
                returndatacopy(add(memPtr, 0x20), 0x00, returndatasize())
                // Advance the `resultsOffset` by `returndatasize() + 0x20`,
                // rounded up to the next multiple of 32.
                resultsOffset :=
                    and(add(add(resultsOffset, returndatasize()), 0x3f), 0xffffffffffffffe0)
                if iszero(lt(results, end)) { break }
            }
            return(0x00, add(resultsOffset, 0x40))
        }
    }
}

// lib/solady/src/utils/SafeCastLib.sol

/// @notice Safe integer casting library that reverts on overflow.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeCastLib.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeCast.sol)
library SafeCastLib {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error Overflow();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*          UNSIGNED INTEGER SAFE CASTING OPERATIONS          */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toUint8(uint256 x) internal pure returns (uint8) {
        if (x >= 1 << 8) _revertOverflow();
        return uint8(x);
    }

    function toUint16(uint256 x) internal pure returns (uint16) {
        if (x >= 1 << 16) _revertOverflow();
        return uint16(x);
    }

    function toUint24(uint256 x) internal pure returns (uint24) {
        if (x >= 1 << 24) _revertOverflow();
        return uint24(x);
    }

    function toUint32(uint256 x) internal pure returns (uint32) {
        if (x >= 1 << 32) _revertOverflow();
        return uint32(x);
    }

    function toUint40(uint256 x) internal pure returns (uint40) {
        if (x >= 1 << 40) _revertOverflow();
        return uint40(x);
    }

    function toUint48(uint256 x) internal pure returns (uint48) {
        if (x >= 1 << 48) _revertOverflow();
        return uint48(x);
    }

    function toUint56(uint256 x) internal pure returns (uint56) {
        if (x >= 1 << 56) _revertOverflow();
        return uint56(x);
    }

    function toUint64(uint256 x) internal pure returns (uint64) {
        if (x >= 1 << 64) _revertOverflow();
        return uint64(x);
    }

    function toUint72(uint256 x) internal pure returns (uint72) {
        if (x >= 1 << 72) _revertOverflow();
        return uint72(x);
    }

    function toUint80(uint256 x) internal pure returns (uint80) {
        if (x >= 1 << 80) _revertOverflow();
        return uint80(x);
    }

    function toUint88(uint256 x) internal pure returns (uint88) {
        if (x >= 1 << 88) _revertOverflow();
        return uint88(x);
    }

    function toUint96(uint256 x) internal pure returns (uint96) {
        if (x >= 1 << 96) _revertOverflow();
        return uint96(x);
    }

    function toUint104(uint256 x) internal pure returns (uint104) {
        if (x >= 1 << 104) _revertOverflow();
        return uint104(x);
    }

    function toUint112(uint256 x) internal pure returns (uint112) {
        if (x >= 1 << 112) _revertOverflow();
        return uint112(x);
    }

    function toUint120(uint256 x) internal pure returns (uint120) {
        if (x >= 1 << 120) _revertOverflow();
        return uint120(x);
    }

    function toUint128(uint256 x) internal pure returns (uint128) {
        if (x >= 1 << 128) _revertOverflow();
        return uint128(x);
    }

    function toUint136(uint256 x) internal pure returns (uint136) {
        if (x >= 1 << 136) _revertOverflow();
        return uint136(x);
    }

    function toUint144(uint256 x) internal pure returns (uint144) {
        if (x >= 1 << 144) _revertOverflow();
        return uint144(x);
    }

    function toUint152(uint256 x) internal pure returns (uint152) {
        if (x >= 1 << 152) _revertOverflow();
        return uint152(x);
    }

    function toUint160(uint256 x) internal pure returns (uint160) {
        if (x >= 1 << 160) _revertOverflow();
        return uint160(x);
    }

    function toUint168(uint256 x) internal pure returns (uint168) {
        if (x >= 1 << 168) _revertOverflow();
        return uint168(x);
    }

    function toUint176(uint256 x) internal pure returns (uint176) {
        if (x >= 1 << 176) _revertOverflow();
        return uint176(x);
    }

    function toUint184(uint256 x) internal pure returns (uint184) {
        if (x >= 1 << 184) _revertOverflow();
        return uint184(x);
    }

    function toUint192(uint256 x) internal pure returns (uint192) {
        if (x >= 1 << 192) _revertOverflow();
        return uint192(x);
    }

    function toUint200(uint256 x) internal pure returns (uint200) {
        if (x >= 1 << 200) _revertOverflow();
        return uint200(x);
    }

    function toUint208(uint256 x) internal pure returns (uint208) {
        if (x >= 1 << 208) _revertOverflow();
        return uint208(x);
    }

    function toUint216(uint256 x) internal pure returns (uint216) {
        if (x >= 1 << 216) _revertOverflow();
        return uint216(x);
    }

    function toUint224(uint256 x) internal pure returns (uint224) {
        if (x >= 1 << 224) _revertOverflow();
        return uint224(x);
    }

    function toUint232(uint256 x) internal pure returns (uint232) {
        if (x >= 1 << 232) _revertOverflow();
        return uint232(x);
    }

    function toUint240(uint256 x) internal pure returns (uint240) {
        if (x >= 1 << 240) _revertOverflow();
        return uint240(x);
    }

    function toUint248(uint256 x) internal pure returns (uint248) {
        if (x >= 1 << 248) _revertOverflow();
        return uint248(x);
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*           SIGNED INTEGER SAFE CASTING OPERATIONS           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function toInt8(int256 x) internal pure returns (int8) {
        int8 y = int8(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt16(int256 x) internal pure returns (int16) {
        int16 y = int16(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt24(int256 x) internal pure returns (int24) {
        int24 y = int24(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt32(int256 x) internal pure returns (int32) {
        int32 y = int32(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt40(int256 x) internal pure returns (int40) {
        int40 y = int40(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt48(int256 x) internal pure returns (int48) {
        int48 y = int48(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt56(int256 x) internal pure returns (int56) {
        int56 y = int56(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt64(int256 x) internal pure returns (int64) {
        int64 y = int64(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt72(int256 x) internal pure returns (int72) {
        int72 y = int72(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt80(int256 x) internal pure returns (int80) {
        int80 y = int80(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt88(int256 x) internal pure returns (int88) {
        int88 y = int88(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt96(int256 x) internal pure returns (int96) {
        int96 y = int96(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt104(int256 x) internal pure returns (int104) {
        int104 y = int104(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt112(int256 x) internal pure returns (int112) {
        int112 y = int112(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt120(int256 x) internal pure returns (int120) {
        int120 y = int120(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt128(int256 x) internal pure returns (int128) {
        int128 y = int128(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt136(int256 x) internal pure returns (int136) {
        int136 y = int136(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt144(int256 x) internal pure returns (int144) {
        int144 y = int144(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt152(int256 x) internal pure returns (int152) {
        int152 y = int152(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt160(int256 x) internal pure returns (int160) {
        int160 y = int160(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt168(int256 x) internal pure returns (int168) {
        int168 y = int168(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt176(int256 x) internal pure returns (int176) {
        int176 y = int176(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt184(int256 x) internal pure returns (int184) {
        int184 y = int184(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt192(int256 x) internal pure returns (int192) {
        int192 y = int192(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt200(int256 x) internal pure returns (int200) {
        int200 y = int200(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt208(int256 x) internal pure returns (int208) {
        int208 y = int208(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt216(int256 x) internal pure returns (int216) {
        int216 y = int216(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt224(int256 x) internal pure returns (int224) {
        int224 y = int224(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt232(int256 x) internal pure returns (int232) {
        int232 y = int232(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt240(int256 x) internal pure returns (int240) {
        int240 y = int240(x);
        if (x != y) _revertOverflow();
        return y;
    }

    function toInt248(int256 x) internal pure returns (int248) {
        int248 y = int248(x);
        if (x != y) _revertOverflow();
        return y;
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                      PRIVATE HELPERS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function _revertOverflow() private pure {
        /// @solidity memory-safe-assembly
        assembly {
            // Store the function selector of `Overflow()`.
            mstore(0x00, 0x35278d12)
            // Revert with (offset, size).
            revert(0x1c, 0x04)
        }
    }
}

// lib/solady/src/utils/SafeTransferLib.sol

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/SafeTransferLib.sol)
/// @author Modified from Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Caution! This library won't check that a token has code, responsibility is delegated to the caller.
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

    /// @dev Suggested gas stipend for contract receiving ETH
    /// that disallows any storage writes.
    uint256 internal constant _GAS_STIPEND_NO_STORAGE_WRITES = 2300;

    /// @dev Suggested gas stipend for contract receiving ETH to perform a few
    /// storage reads and writes, but low enough to prevent griefing.
    /// Multiply by a small constant (e.g. 2), if needed.
    uint256 internal constant _GAS_STIPEND_NO_GRIEF = 100000;

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ETH OPERATIONS                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Sends `amount` (in wei) ETH to `to`.
    /// Reverts upon failure.
    function safeTransferETH(address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(gasStipend, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Force sends `amount` (in wei) ETH to `to`, with a gas stipend
    /// equal to `_GAS_STIPEND_NO_GRIEF`. This gas stipend is a reasonable default
    /// for 99% of cases and can be overriden with the three-argument version of this
    /// function if necessary.
    ///
    /// If sending via the normal procedure fails, force sends the ETH by
    /// creating a temporary contract which uses `SELFDESTRUCT` to force send the ETH.
    ///
    /// Reverts if the current contract has insufficient balance.
    function forceSafeTransferETH(address to, uint256 amount) internal {
        // Manually inlined because the compiler doesn't inline functions with branches.
        /// @solidity memory-safe-assembly
        assembly {
            // If insufficient balance, revert.
            if lt(selfbalance(), amount) {
                // Store the function selector of `ETHTransferFailed()`.
                mstore(0x00, 0xb12d13eb)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Transfer the ETH and check if it succeeded or not.
            if iszero(call(_GAS_STIPEND_NO_GRIEF, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                // We can directly use `SELFDESTRUCT` in the contract creation.
                // Compatible with `SENDALL`: https://eips.ethereum.org/EIPS/eip-4758
                if iszero(create(amount, 0x0b, 0x16)) {
                    // For better gas estimation.
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }

    /// @dev Sends `amount` (in wei) ETH to `to`, with a `gasStipend`.
    /// The `gasStipend` can be set to a low enough value to prevent
    /// storage writes or gas griefing.
    ///
    /// Simply use `gasleft()` for `gasStipend` if you don't need a gas stipend.
    ///
    /// Note: Does NOT revert upon failure.
    /// Returns whether the transfer of ETH is successful instead.
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and check if it succeeded or not.
            success := call(gasStipend, to, amount, 0, 0, 0, 0)
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
            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x0c, 0x23b872dd000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x60, 0) // Restore the zero slot to zero.
            mstore(0x40, m) // Restore the free memory pointer.
        }
    }

    /// @dev Sends all of ERC20 `token` from `from` to `to`.
    /// Reverts upon failure.
    ///
    /// The `from` account must have at least `amount` approved for
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
            // Store the function selector of `balanceOf(address)`.
            mstore(0x0c, 0x70a08231000000000000000000000000)
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Store the function selector of `transferFrom(address,address,uint256)`.
            mstore(0x00, 0x23b872dd)
            // The `amount` argument is already written to the memory word at 0x6c.
            amount := mload(0x60)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFromFailed()`.
                mstore(0x00, 0x7939f424)
                // Revert with (offset, size).
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
            // Store the function selector of `transfer(address,uint256)`.
            mstore(0x00, 0xa9059cbb000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Sends all of ERC20 `token` from the current contract to `to`.
    /// Reverts upon failure.
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, 0x70a08231) // Store the function selector of `balanceOf(address)`.
            mstore(0x20, address()) // Store the address of the current contract.
            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    gt(returndatasize(), 0x1f), // At least 32 bytes returned.
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            mstore(0x14, to) // Store the `to` argument.
            // The `amount` argument is already written to the memory word at 0x34.
            amount := mload(0x34)
            // Store the function selector of `transfer(address,uint256)`.
            mstore(0x00, 0xa9059cbb000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `TransferFailed()`.
                mstore(0x00, 0x90b8ec18)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Sets `amount` of ERC20 `token` for `to` to manage on behalf of the current contract.
    /// Reverts upon failure.
    function safeApprove(address token, address to, uint256 amount) internal {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, to) // Store the `to` argument.
            mstore(0x34, amount) // Store the `amount` argument.
            // Store the function selector of `approve(address,uint256)`.
            mstore(0x00, 0x095ea7b3000000000000000000000000)

            if iszero(
                and( // The arguments of `and` are evaluated from right to left.
                    // Set success to whether the call reverted, if not we check it either
                    // returned exactly 1 (can't just be non-zero data), or had no return data.
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                // Store the function selector of `ApproveFailed()`.
                mstore(0x00, 0x3e3f8f73)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Restore the part of the free memory pointer that was overwritten.
            mstore(0x34, 0)
        }
    }

    /// @dev Returns the amount of ERC20 `token` owned by `account`.
    /// Returns zero if the `token` does not exist.
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x14, account) // Store the `account` argument.
            // Store the function selector of `balanceOf(address)`.
            mstore(0x00, 0x70a08231000000000000000000000000)
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

// lib/solmate/src/utils/ReentrancyGuard.sol

/// @notice Gas optimized reentrancy protection for smart contracts.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/ReentrancyGuard.sol)
/// @author Modified from OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol)
abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}

// lib/v3-core/contracts/interfaces/IUniswapV3Factory.sol

/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol

/// @title Permissionless pool actions
/// @notice Contains pool methods that can be called by anyone
interface IUniswapV3PoolActions {
    /// @notice Sets the initial price for the pool
    /// @dev Price is represented as a sqrt(amountToken1/amountToken0) Q64.96 value
    /// @param sqrtPriceX96 the initial sqrt price of the pool as a Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice Adds liquidity for the given recipient/tickLower/tickUpper position
    /// @dev The caller of this method receives a callback in the form of IUniswapV3MintCallback#uniswapV3MintCallback
    /// in which they must pay any token0 or token1 owed for the liquidity. The amount of token0/token1 due depends
    /// on tickLower, tickUpper, the amount of liquidity, and the current price.
    /// @param recipient The address for which the liquidity will be created
    /// @param tickLower The lower tick of the position in which to add liquidity
    /// @param tickUpper The upper tick of the position in which to add liquidity
    /// @param amount The amount of liquidity to mint
    /// @param data Any data that should be passed through to the callback
    /// @return amount0 The amount of token0 that was paid to mint the given amount of liquidity. Matches the value in the callback
    /// @return amount1 The amount of token1 that was paid to mint the given amount of liquidity. Matches the value in the callback
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Collects tokens owed to a position
    /// @dev Does not recompute fees earned, which must be done either via mint or burn of any amount of liquidity.
    /// Collect must be called by the position owner. To withdraw only token0 or only token1, amount0Requested or
    /// amount1Requested may be set to zero. To withdraw all tokens owed, caller may pass any value greater than the
    /// actual tokens owed, e.g. type(uint128).max. Tokens owed may be from accumulated swap fees or burned liquidity.
    /// @param recipient The address which should receive the fees collected
    /// @param tickLower The lower tick of the position for which to collect fees
    /// @param tickUpper The upper tick of the position for which to collect fees
    /// @param amount0Requested How much token0 should be withdrawn from the fees owed
    /// @param amount1Requested How much token1 should be withdrawn from the fees owed
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice Burn liquidity from the sender and account tokens owed for the liquidity to the position
    /// @dev Can be used to trigger a recalculation of fees owed to a position by calling with an amount of 0
    /// @dev Fees must be collected separately via a call to #collect
    /// @param tickLower The lower tick of the position for which to burn liquidity
    /// @param tickUpper The upper tick of the position for which to burn liquidity
    /// @param amount How much liquidity to burn
    /// @return amount0 The amount of token0 sent to the recipient
    /// @return amount1 The amount of token1 sent to the recipient
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice Swap token0 for token1, or token1 for token0
    /// @dev The caller of this method receives a callback in the form of IUniswapV3SwapCallback#uniswapV3SwapCallback
    /// @param recipient The address to receive the output of the swap
    /// @param zeroForOne The direction of the swap, true for token0 to token1, false for token1 to token0
    /// @param amountSpecified The amount of the swap, which implicitly configures the swap as exact input (positive), or exact output (negative)
    /// @param sqrtPriceLimitX96 The Q64.96 sqrt price limit. If zero for one, the price cannot be less than this
    /// value after the swap. If one for zero, the price cannot be greater than this value after the swap
    /// @param data Any data to be passed through to the callback
    /// @return amount0 The delta of the balance of token0 of the pool, exact when negative, minimum when positive
    /// @return amount1 The delta of the balance of token1 of the pool, exact when negative, minimum when positive
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice Receive token0 and/or token1 and pay it back, plus a fee, in the callback
    /// @dev The caller of this method receives a callback in the form of IUniswapV3FlashCallback#uniswapV3FlashCallback
    /// @dev Can be used to donate underlying tokens pro-rata to currently in-range liquidity providers by calling
    /// with 0 amount{0,1} and sending the donation amount(s) from the callback
    /// @param recipient The address which will receive the token0 and token1 amounts
    /// @param amount0 The amount of token0 to send
    /// @param amount1 The amount of token1 to send
    /// @param data Any data to be passed through to the callback
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice Increase the maximum number of price and liquidity observations that this pool will store
    /// @dev This method is no-op if the pool already has an observationCardinalityNext greater than or equal to
    /// the input observationCardinalityNext.
    /// @param observationCardinalityNext The desired minimum number of observations for the pool to store
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol

/// @title Pool state that is not stored
/// @notice Contains view functions to provide information about the pool that is computed rather than stored on the
/// blockchain. The functions here may have variable gas costs.
interface IUniswapV3PoolDerivedState {
    /// @notice Returns the cumulative tick and liquidity as of each timestamp `secondsAgo` from the current block timestamp
    /// @dev To get a time weighted average tick or liquidity-in-range, you must call this with two values, one representing
    /// the beginning of the period and another for the end of the period. E.g., to get the last hour time-weighted average tick,
    /// you must call it with secondsAgos = [3600, 0].
    /// @dev The time weighted average tick represents the geometric time weighted average price of the pool, in
    /// log base sqrt(1.0001) of token1 / token0. The TickMath library can be used to go from a tick value to a ratio.
    /// @param secondsAgos From how long ago each cumulative tick and liquidity value should be returned
    /// @return tickCumulatives Cumulative tick values as of each `secondsAgos` from the current block timestamp
    /// @return secondsPerLiquidityCumulativeX128s Cumulative seconds per liquidity-in-range value as of each `secondsAgos` from the current block
    /// timestamp
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice Returns a snapshot of the tick cumulative, seconds per liquidity and seconds inside a tick range
    /// @dev Snapshots must only be compared to other snapshots, taken over a period for which a position existed.
    /// I.e., snapshots cannot be compared if a position is not held for the entire period between when the first
    /// snapshot is taken and the second snapshot is taken.
    /// @param tickLower The lower tick of the range
    /// @param tickUpper The upper tick of the range
    /// @return tickCumulativeInside The snapshot of the tick accumulator for the range
    /// @return secondsPerLiquidityInsideX128 The snapshot of seconds per liquidity for the range
    /// @return secondsInside The snapshot of seconds per liquidity for the range
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolErrors.sol

/// @title Errors emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolErrors {
    error LOK();
    error TLU();
    error TLM();
    error TUM();
    error AI();
    error M0();
    error M1();
    error AS();
    error IIA();
    error L();
    error F0();
    error F1();
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol

/// @title Events emitted by a pool
/// @notice Contains all events emitted by the pool
interface IUniswapV3PoolEvents {
    /// @notice Emitted exactly once by a pool when #initialize is first called on the pool
    /// @dev Mint/Burn/Swap cannot be emitted by the pool before Initialize
    /// @param sqrtPriceX96 The initial sqrt price of the pool, as a Q64.96
    /// @param tick The initial tick of the pool, i.e. log base 1.0001 of the starting price of the pool
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice Emitted when liquidity is minted for a given position
    /// @param sender The address that minted the liquidity
    /// @param owner The owner of the position and recipient of any minted liquidity
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity minted to the position range
    /// @param amount0 How much token0 was required for the minted liquidity
    /// @param amount1 How much token1 was required for the minted liquidity
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted when fees are collected by the owner of a position
    /// @dev Collect events may be emitted with zero amount0 and amount1 when the caller chooses not to collect fees
    /// @param owner The owner of the position for which fees are collected
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount0 The amount of token0 fees collected
    /// @param amount1 The amount of token1 fees collected
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice Emitted when a position's liquidity is removed
    /// @dev Does not withdraw any fees earned by the liquidity position, which must be withdrawn via #collect
    /// @param owner The owner of the position for which liquidity is removed
    /// @param tickLower The lower tick of the position
    /// @param tickUpper The upper tick of the position
    /// @param amount The amount of liquidity to remove
    /// @param amount0 The amount of token0 withdrawn
    /// @param amount1 The amount of token1 withdrawn
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice Emitted by the pool for any swaps between token0 and token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the output of the swap
    /// @param amount0 The delta of the token0 balance of the pool
    /// @param amount1 The delta of the token1 balance of the pool
    /// @param sqrtPriceX96 The sqrt(price) of the pool after the swap, as a Q64.96
    /// @param liquidity The liquidity of the pool after the swap
    /// @param tick The log base 1.0001 of price of the pool after the swap
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice Emitted by the pool for any flashes of token0/token1
    /// @param sender The address that initiated the swap call, and that received the callback
    /// @param recipient The address that received the tokens from flash
    /// @param amount0 The amount of token0 that was flashed
    /// @param amount1 The amount of token1 that was flashed
    /// @param paid0 The amount of token0 paid for the flash, which can exceed the amount0 plus the fee
    /// @param paid1 The amount of token1 paid for the flash, which can exceed the amount1 plus the fee
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice Emitted by the pool for increases to the number of observations that can be stored
    /// @dev observationCardinalityNext is not the observation cardinality until an observation is written at the index
    /// just before a mint/swap/burn.
    /// @param observationCardinalityNextOld The previous value of the next observation cardinality
    /// @param observationCardinalityNextNew The updated value of the next observation cardinality
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice Emitted when the protocol fee is changed by the pool
    /// @param feeProtocol0Old The previous value of the token0 protocol fee
    /// @param feeProtocol1Old The previous value of the token1 protocol fee
    /// @param feeProtocol0New The updated value of the token0 protocol fee
    /// @param feeProtocol1New The updated value of the token1 protocol fee
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice Emitted when the collected protocol fees are withdrawn by the factory owner
    /// @param sender The address that collects the protocol fees
    /// @param recipient The address that receives the collected protocol fees
    /// @param amount0 The amount of token0 protocol fees that is withdrawn
    /// @param amount0 The amount of token1 protocol fees that is withdrawn
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol

/// @title Pool state that never changes
/// @notice These parameters are fixed for a pool forever, i.e., the methods will always return the same values
interface IUniswapV3PoolImmutables {
    /// @notice The contract that deployed the pool, which must adhere to the IUniswapV3Factory interface
    /// @return The contract address
    function factory() external view returns (address);

    /// @notice The first of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token0() external view returns (address);

    /// @notice The second of the two tokens of the pool, sorted by address
    /// @return The token contract address
    function token1() external view returns (address);

    /// @notice The pool's fee in hundredths of a bip, i.e. 1e-6
    /// @return The fee
    function fee() external view returns (uint24);

    /// @notice The pool tick spacing
    /// @dev Ticks can only be used at multiples of this value, minimum of 1 and always positive
    /// e.g.: a tickSpacing of 3 means ticks can be initialized every 3rd tick, i.e., ..., -6, -3, 0, 3, 6, ...
    /// This value is an int24 to avoid casting even though it is always positive.
    /// @return The tick spacing
    function tickSpacing() external view returns (int24);

    /// @notice The maximum amount of position liquidity that can use any tick in the range
    /// @dev This parameter is enforced per tick to prevent liquidity from overflowing a uint128 at any point, and
    /// also prevents out-of-range liquidity from being used to prevent adding in-range liquidity to a pool
    /// @return The max amount of liquidity per tick
    function maxLiquidityPerTick() external view returns (uint128);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol

/// @title Permissioned pool actions
/// @notice Contains pool methods that may only be called by the factory owner
interface IUniswapV3PoolOwnerActions {
    /// @notice Set the denominator of the protocol's % share of the fees
    /// @param feeProtocol0 new protocol fee for token0 of the pool
    /// @param feeProtocol1 new protocol fee for token1 of the pool
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice Collect the protocol fee accrued to the pool
    /// @param recipient The address to which collected protocol fees should be sent
    /// @param amount0Requested The maximum amount of token0 to send, can be 0 to collect fees in only token1
    /// @param amount1Requested The maximum amount of token1 to send, can be 0 to collect fees in only token0
    /// @return amount0 The protocol fee collected in token0
    /// @return amount1 The protocol fee collected in token1
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}

// lib/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol

/// @title Pool state that can change
/// @notice These methods compose the pool's state, and can change with any frequency including multiple times
/// per transaction
interface IUniswapV3PoolState {
    /// @notice The 0th storage slot in the pool stores many values, and is exposed as a single method to save gas
    /// when accessed externally.
    /// @return sqrtPriceX96 The current price of the pool as a sqrt(token1/token0) Q64.96 value
    /// @return tick The current tick of the pool, i.e. according to the last tick transition that was run.
    /// This value may not always be equal to SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96) if the price is on a tick
    /// boundary.
    /// @return observationIndex The index of the last oracle observation that was written,
    /// @return observationCardinality The current maximum number of observations stored in the pool,
    /// @return observationCardinalityNext The next maximum number of observations, to be updated when the observation.
    /// @return feeProtocol The protocol fee for both tokens of the pool.
    /// Encoded as two 4 bit values, where the protocol fee of token1 is shifted 4 bits and the protocol fee of token0
    /// is the lower 4 bits. Used as the denominator of a fraction of the swap fee, e.g. 4 means 1/4th of the swap fee.
    /// unlocked Whether the pool is currently locked to reentrancy
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice The fee growth as a Q128.128 fees of token0 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice The fee growth as a Q128.128 fees of token1 collected per unit of liquidity for the entire life of the pool
    /// @dev This value can overflow the uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice The amounts of token0 and token1 that are owed to the protocol
    /// @dev Protocol fees will never exceed uint128 max in either token
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice The currently in range liquidity available to the pool
    /// @dev This value has no relationship to the total liquidity across all ticks
    /// @return The liquidity at the current price of the pool
    function liquidity() external view returns (uint128);

    /// @notice Look up information about a specific tick in the pool
    /// @param tick The tick to look up
    /// @return liquidityGross the total amount of position liquidity that uses the pool either as tick lower or
    /// tick upper
    /// @return liquidityNet how much liquidity changes when the pool price crosses the tick,
    /// @return feeGrowthOutside0X128 the fee growth on the other side of the tick from the current tick in token0,
    /// @return feeGrowthOutside1X128 the fee growth on the other side of the tick from the current tick in token1,
    /// @return tickCumulativeOutside the cumulative tick value on the other side of the tick from the current tick
    /// @return secondsPerLiquidityOutsideX128 the seconds spent per liquidity on the other side of the tick from the current tick,
    /// @return secondsOutside the seconds spent on the other side of the tick from the current tick,
    /// @return initialized Set to true if the tick is initialized, i.e. liquidityGross is greater than 0, otherwise equal to false.
    /// Outside values can only be used if the tick is initialized, i.e. if liquidityGross is greater than 0.
    /// In addition, these values are only relative and must be used only in comparison to previous snapshots for
    /// a specific position.
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice Returns 256 packed tick initialized boolean values. See TickBitmap for more information
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice Returns the information about a position by the position's key
    /// @param key The position's key is a hash of a preimage composed by the owner, tickLower and tickUpper
    /// @return liquidity The amount of liquidity in the position,
    /// @return feeGrowthInside0LastX128 fee growth of token0 inside the tick range as of the last mint/burn/poke,
    /// @return feeGrowthInside1LastX128 fee growth of token1 inside the tick range as of the last mint/burn/poke,
    /// @return tokensOwed0 the computed amount of token0 owed to the position as of the last mint/burn/poke,
    /// @return tokensOwed1 the computed amount of token1 owed to the position as of the last mint/burn/poke
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Returns data about a specific observation index
    /// @param index The element of the observations array to fetch
    /// @dev You most likely want to use #observe() instead of this method to get an observation as of some amount of time
    /// ago, rather than at a specific index in the array.
    /// @return blockTimestamp The timestamp of the observation,
    /// @return tickCumulative the tick multiplied by seconds elapsed for the life of the pool as of the observation timestamp,
    /// @return secondsPerLiquidityCumulativeX128 the seconds per in range liquidity for the life of the pool as of the observation timestamp,
    /// @return initialized whether the observation has been initialized and the values are safe to use
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}

// lib/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol

/// @title Immutable state
/// @notice Functions that return immutable state of the router
interface IPeripheryImmutableState {
    /// @return Returns the address of the Uniswap V3 factory
    function factory() external view returns (address);

    /// @return Returns the address of WETH9
    function WETH9() external view returns (address);
}

// lib/v3-periphery/contracts/interfaces/IPeripheryPayments.sol

/// @title Periphery Payments
/// @notice Functions to ease deposits and withdrawals of ETH
interface IPeripheryPayments {
    /// @notice Unwraps the contract's WETH9 balance and sends it to recipient as ETH.
    /// @dev The amountMinimum parameter prevents malicious contracts from stealing WETH9 from users.
    /// @param amountMinimum The minimum amount of WETH9 to unwrap
    /// @param recipient The address receiving ETH
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    /// @notice Refunds any ETH balance held by this contract to the `msg.sender`
    /// @dev Useful for bundling with mint or increase liquidity that uses ether, or exact output swaps
    /// that use ether for the input amount
    function refundETH() external payable;

    /// @notice Transfers the full amount of a token held by this contract to recipient
    /// @dev The amountMinimum parameter prevents malicious contracts from stealing the token from users
    /// @param token The contract address of the token which will be transferred to `recipient`
    /// @param amountMinimum The minimum amount of token required for a transfer
    /// @param recipient The destination address of the token
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}

// lib/v3-periphery/contracts/interfaces/IPoolInitializer.sol

/// @title Creates and initializes V3 Pools
/// @notice Provides a method for creating and initializing a pool, if necessary, for bundling with other methods that
/// require the pool to exist.
interface IPoolInitializer {
    /// @notice Creates a new pool if it does not exist, then initializes if not initialized
    /// @dev This method can be bundled with others via IMulticall for the first action (e.g. mint) performed against a pool
    /// @param token0 The contract address of token0 of the pool
    /// @param token1 The contract address of token1 of the pool
    /// @param fee The fee amount of the v3 pool for the specified token pair
    /// @param sqrtPriceX96 The initial square root price of the pool as a Q64.96 value
    /// @return pool Returns the pool address based on the pair of tokens and fee, will return the newly created pool address if necessary
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}

// lib/v3-periphery/contracts/libraries/PoolAddress.sol

/// @title Provides functions for deriving a pool address from the factory, tokens, and the fee
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0x995089ad791508a023ec76172d56c12f2049e3382b7c2a78f2747b2b0ac7db69;

    /// @notice The identifying key of the pool
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }

    /// @notice Returns PoolKey: the ordered tokens with the matched fee levels
    /// @param tokenA The first token of a pool, unsorted
    /// @param tokenB The second token of a pool, unsorted
    /// @param fee The fee level of the pool
    /// @return Poolkey The pool details with ordered token0 and token1 assignments
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param factory The Uniswap V3 factory contract address
    /// @param key The PoolKey
    /// @return pool The contract address of the V3 pool
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}

// src/erc-20/interfaces/Errors.sol

/**
 * @title Shared Errors
 */
interface Errors {
    /// @notice thrown when attempting to approve an EOA that must be a contract
    error NonContractError();
}

// src/erc-20/interfaces/IERC20Boost.sol

/**
 * @title  An ERC20 with an embedded attachment mechanism to keep track of boost allocations to gauges.
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This contract is meant to be used to represent a token that can boost holders' rewards in other contracts.
 *          Holders can have their boost attached to gauges and cannot transfer their bHermes until they remove their boost.
 *          Only gauges can attach and detach boost from a user. The current user's boost and total supply are stored when attaching.
 *          The boost is then detached when the user removes their boost or when the gauge is removed.
 *          A "gauge" is represented by an address that distributes rewards to users periodically or continuously.
 *
 *          For example, gauges can be used to direct token emissions, similar to Curve or Hermes V1.
 *          Alternatively, gauges can be used to direct another quantity such as relative access to a line of credit.
 *          This contract should serve as reference for the amount of boost a user has allocated to a gauge.
 *          Then liquidity per user should be caculated by using this formula, from curve finance:
 *          min(UserLiquidity, (40 * UserLiquidity) + (60 * TotalLiquidity * UserBoostBalance / BoostTotal))
 *
 *          "Live" gauges are in the set.
 *          Users can only be attached to live gauges but can detach from live or deprecated gauges.
 *          Gauges can be deprecated and reinstated; and will maintain any non-removed boost from before.
 *
 *  @dev    SECURITY NOTES: decrementGaugeAllBoost can run out of gas.
 *          Gauges should be removed individually until decrementGaugeAllBoost can be called.
 *
 *          After having the boost attached, getUserBoost() will return the maximum boost a user had allocated to all gauges.
 *
 *          Boost state is preserved on the gauge and user level even when a gauge is removed, in case it is re-added.
 */
interface IERC20Boost {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice User allocated boost to a gauge and bHermes total supply.
     * @param userGaugeBoost User allocated boost to a gauge.
     * @param totalGaugeBoost bHermes total supply when a user allocated the boost.
     */
    struct GaugeState {
        uint128 userGaugeBoost;
        uint128 totalGaugeBoost;
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice User allocated boost to a gauge and the bHermes total supply.
     * @param user User address.
     * @param gauge Gauge address.
     * @return userGaugeBoost User allocated boost to a gauge.
     * @return totalGaugeBoost The bHermes total supply when a user allocated the boost.
     */
    function getUserGaugeBoost(address user, address gauge)
        external
        view
        returns (uint128 userGaugeBoost, uint128 totalGaugeBoost);

    /*///////////////////////////////////////////////////////////////
                            VIEW HELPERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Maximum boost a user had allocated to all gauges since he last called decrementAllGaugesAllBoost().
     * @param user User address.
     * @return boost Maximum user allocated boost.
     */
    function getUserBoost(address user) external view returns (uint256 boost);

    /**
     * @notice returns the set of live gauges
     */
    function gauges() external view returns (address[] memory);

    /**
     * @notice returns a paginated subset of live gauges
     *   @param offset the index of the first gauge element to read
     *   @param num the number of gauges to return
     */
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values);

    /**
     * @notice returns true if `gauge` is not in deprecated gauges
     */
    function isGauge(address gauge) external view returns (bool);

    /**
     * @notice returns the number of live gauges
     */
    function numGauges() external view returns (uint256);

    /**
     * @notice returns the set of previously live but now deprecated gauges
     */
    function deprecatedGauges() external view returns (address[] memory);

    /**
     * @notice returns the number of live gauges
     */
    function numDeprecatedGauges() external view returns (uint256);

    /**
     * @notice returns the set of gauges the user has allocated to, they may be live or deprecated.
     */
    function freeGaugeBoost(address user) external view returns (uint256);

    /**
     * @notice returns the set of gauges the user has allocated to, they may be live or deprecated.
     */
    function userGauges(address user) external view returns (address[] memory);

    /**
     * @notice returns true if `gauge` is in user gauges
     */
    function isUserGauge(address user, address gauge) external view returns (bool);

    /**
     *  @notice returns a paginated subset of gauges the user has allocated to, they may be live or deprecated.
     *  @param user the user to return gauges from.
     *  @param offset the index of the first gauge element to read.
     *  @param num the number of gauges to return.
     */
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values);

    /**
     * @notice returns the number of user gauges
     */
    function numUserGauges(address user) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice attach all user's boost to a gauge, only callable by the gauge.
     *  @param user the user to attach the gauge to.
     */
    function attach(address user) external;

    /**
     * @notice detach all user's boost from a gauge, only callable by the gauge.
     * @param user the user to detach the gauge from.
     */
    function detach(address user) external;

    /*///////////////////////////////////////////////////////////////
                        USER GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Update geUserBoost for a user, loop through all _userGauges
     * @param user the user to update the boost for.
     */
    function updateUserBoost(address user) external;

    /**
     * @notice Remove an amount of boost from a gauge
     * @param gauge the gauge to remove boost from.
     * @param boost the amount of boost to remove.
     */
    function decrementGaugeBoost(address gauge, uint256 boost) external;

    /**
     * @notice Remove all the boost from a gauge
     * @param gauge the gauge to remove boost from.
     */
    function decrementGaugeAllBoost(address gauge) external;

    /**
     * @notice Remove an amount of boost from all user gauges
     * @param boost the amount of boost to remove.
     */
    function decrementAllGaugesBoost(uint256 boost) external;

    /**
     * @notice Remove an amount of boost from all user gauges indexed
     * @param boost the amount of boost to remove.
     * @param offset the index of the first gauge element to read.
     * @param num the number of gauges to return.
     */
    function decrementGaugesBoostIndexed(uint256 boost, uint256 offset, uint256 num) external;

    /**
     * @notice Remove all the boost from all user gauges
     */
    function decrementAllGaugesAllBoost() external;

    /**
     * @notice add a new gauge. Requires auth by `authority`.
     */
    function addGauge(address gauge) external;

    /**
     * @notice remove a new gauge. Requires auth by `authority`.
     */
    function removeGauge(address gauge) external;

    /**
     * @notice replace a gauge. Requires auth by `authority`.
     */
    function replaceGauge(address oldGauge, address newGauge) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice emitted when adding a new gauge to the live set.
    event AddGauge(address indexed gauge);

    /// @notice emitted when removing a gauge from the live set.
    event RemoveGauge(address indexed gauge);

    /// @notice emmitted when a user attaches boost to a gauge.
    event Attach(address indexed user, address indexed gauge, uint256 boost);

    /// @notice emmitted when a user detaches boost from a gauge.
    event Detach(address indexed user, address indexed gauge);

    /// @notice emmitted when a user updates their boost.
    event UpdateUserBoost(address indexed user, uint256 updatedBoost);

    /// @notice emmitted when a user decrements their gauge boost.
    event DecrementUserGaugeBoost(address indexed user, address indexed gauge, uint256 UpdatedBoost);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when trying to increment or remove a non-live gauge, or add a live gauge.
    error InvalidGauge();

    /// @notice thrown when a gauge tries to attach a position and already has one attached.
    error GaugeAlreadyAttached();

    /// @notice thrown when a gauge tries to transfer a position but does not have enough free balance.
    error AttachedBoost();
}

// src/erc-20/interfaces/IERC20Gauges.sol

// Gauge weight logic inspired by Tribe DAO Contracts (flywheel-v2/src/token/ERC20Gauges.sol)

/**
 * @title  An ERC20 with an embedded "Gauge" style vote with liquid weights
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This contract is meant to be used to support gauge style votes with weights associated with resource allocation.
 *          Only after delegating to himself can a user allocate weight to a gauge.
 *          Holders can allocate weight in any proportion to supported gauges.
 *          A "gauge" is represented by an address that would receive the resources periodically or continuously.
 *
 *          For example, gauges can be used to direct token emissions, similar to Curve or Hermes V1.
 *          Alternatively, gauges can be used to direct another quantity such as relative access to a line of credit.
 *
 *          The contract's Ownable <https://github.com/Vectorized/solady/blob/main/src/auth/Ownable.sol> manages the gauge set and cap.
 *          "Live" gauges are in the set.
 *          Users can only add weight to live gauges but can remove weight from live or deprecated gauges.
 *          Gauges can be deprecated and reinstated; and will maintain any non-removed weight from before.
 *
 *  @dev    SECURITY NOTES: `maxGauges` is a critical variable to protect against gas DOS attacks upon token transfer.
 *          This must be low enough to allow complicated transactions to fit in a block.
 *
 *          Weight state is preserved on the gauge and user level even when a gauge is removed, in case it is re-added.
 *          This maintains the state efficiently, and global accounting is managed only on the `_totalWeight`
 */
interface IERC20Gauges {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice a struct representing a user's weight allocation to a gauge
     * @param storedWeight weight allocated to a gauge at the end of the last cycle
     * @param currentWeight current weight allocated to a gauge
     * @param currentCycle cycle in which the current weight was allocated
     */
    struct Weight {
        uint112 storedWeight;
        uint112 currentWeight;
        uint32 currentCycle;
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE STATE
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice a mapping from a user to their total allocated weight across all gauges
     */
    function getUserWeight(address) external view returns (uint112);

    /**
     * @notice the length of a gauge cycle
     */
    function gaugeCycleLength() external view returns (uint32);

    /**
     * @notice the period at the end of a cycle where votes cannot increment
     */
    function incrementFreezeWindow() external view returns (uint32);

    /**
     * @notice a mapping from users to gauges to a user's allocated weight to that gauge
     */
    function getUserGaugeWeight(address, address) external view returns (uint112);

    /*///////////////////////////////////////////////////////////////
                              VIEW HELPERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice returns the end of the current cycle. This is the next unix timestamp which evenly divides `gaugeCycleLength`
     */
    function getGaugeCycleEnd() external view returns (uint32);

    /**
     * @notice returns the current weight of a given gauge
     * @param gauge address of the gauge to get the weight from
     */
    function getGaugeWeight(address gauge) external view returns (uint112);

    /**
     * @notice returns the stored weight of a given gauge. This is the snapshotted weight as-of the end of the last cycle.
     */
    function getStoredGaugeWeight(address gauge) external view returns (uint112);

    /**
     * @notice returns the current total allocated weight
     */
    function totalWeight() external view returns (uint112);

    /**
     * @notice returns the stored total allocated weight
     */
    function storedTotalWeight() external view returns (uint112);

    /**
     * @notice returns the set of live gauges
     */
    function gauges() external view returns (address[] memory);

    /**
     * @notice returns a paginated subset of live gauges
     *   @param offset the index of the first gauge element to read
     *   @param num the number of gauges to return
     */
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values);

    /**
     * @notice returns true if `gauge` is not in deprecated gauges
     */
    function isGauge(address gauge) external view returns (bool);

    /**
     * @notice returns the number of live gauges
     */
    function numGauges() external view returns (uint256);

    /**
     * @notice returns the set of previously live but now deprecated gauges
     */
    function deprecatedGauges() external view returns (address[] memory);

    /**
     * @notice returns the number of live gauges
     */
    function numDeprecatedGauges() external view returns (uint256);

    /**
     * @notice returns the set of gauges the user has allocated to, may be live or deprecated.
     */
    function userGauges(address user) external view returns (address[] memory);

    /**
     * @notice returns true if `gauge` is in user gauges
     */
    function isUserGauge(address user, address gauge) external view returns (bool);

    /**
     * @notice returns a paginated subset of gauges the user has allocated to, may be live or deprecated.
     *   @param user the user to return gauges from.
     *   @param offset the index of the first gauge element to read.
     *   @param num the number of gauges to return.
     */
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values);

    /**
     * @notice returns the number of user gauges
     */
    function numUserGauges(address user) external view returns (uint256);

    /**
     * @notice helper function for calculating the proportion of a `quantity` allocated to a gauge
     *  @param gauge the gauge to calculate the allocation of
     *  @param quantity a representation of a resource to be shared among all gauges
     *  @return the proportion of `quantity` allocated to `gauge`. Returns 0 if a gauge is not live, even if it has weight.
     */
    function calculateGaugeAllocation(address gauge, uint256 quantity) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        USER GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice increment a gauge with some weight for the caller
     *  @param gauge the gauge to increment
     *  @param weight the amount of weight to increment on a gauge
     *  @return newUserWeight the new user weight
     */
    function incrementGauge(address gauge, uint112 weight) external returns (uint112 newUserWeight);

    /**
     * @notice increment a list of gauges with some weights for the caller
     *  @param gaugeList the gauges to increment
     *  @param weights the weights to increment by
     *  @return newUserWeight the new user weight
     */
    function incrementGauges(address[] memory gaugeList, uint112[] memory weights)
        external
        returns (uint256 newUserWeight);

    /**
     * @notice decrement a gauge with some weight for the caller
     *  @param gauge the gauge to decrement
     *  @param weight the amount of weight to decrement on a gauge
     *  @return newUserWeight the new user weight
     */
    function decrementGauge(address gauge, uint112 weight) external returns (uint112 newUserWeight);

    /**
     * @notice decrement a list of gauges with some weights for the caller
     *  @param gaugeList the gauges to decrement
     *  @param weights the list of weights to decrement on the gauges
     *  @return newUserWeight the new user weight
     */
    function decrementGauges(address[] memory gaugeList, uint112[] memory weights)
        external
        returns (uint112 newUserWeight);

    /*///////////////////////////////////////////////////////////////
                        ADMIN GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice the default maximum amount of gauges a user can allocate to.
     * @dev if this number is ever lowered, or a contract has an override, then existing addresses MAY have more gauges allocated to. Use `numUserGauges` to check this.
     */
    function maxGauges() external view returns (uint256);

    /**
     * @notice an approved list for contracts to go above the max gauge limit.
     */
    function canContractExceedMaxGauges(address) external view returns (bool);

    /**
     * @notice add a new gauge. Requires auth by `authority`.
     */
    function addGauge(address gauge) external returns (uint112);

    /**
     * @notice remove a new gauge. Requires auth by `authority`.
     */
    function removeGauge(address gauge) external;

    /**
     * @notice replace a gauge. Requires auth by `authority`.
     */
    function replaceGauge(address oldGauge, address newGauge) external;

    /**
     * @notice set the new max gauges. Requires auth by `authority`.
     * @dev if this is set to a lower number than the current max, users MAY have more gauges active than the max. Use `numUserGauges` to check this.
     */
    function setMaxGauges(uint256 newMax) external;

    /**
     * @notice set the canContractExceedMaxGauges flag for an account.
     */
    function setContractExceedMaxGauges(address account, bool canExceedMax) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice emitted when incrementing a gauge
    event IncrementGaugeWeight(address indexed user, address indexed gauge, uint256 weight, uint32 cycleEnd);

    /// @notice emitted when decrementing a gauge
    event DecrementGaugeWeight(address indexed user, address indexed gauge, uint256 weight, uint32 cycleEnd);

    /// @notice emitted when adding a new gauge to the live set.
    event AddGauge(address indexed gauge);

    /// @notice emitted when removing a gauge from the live set.
    event RemoveGauge(address indexed gauge);

    /// @notice emitted when updating the max number of gauges a user can delegate to.
    event MaxGaugesUpdate(uint256 oldMaxGauges, uint256 newMaxGauges);

    /// @notice emitted when changing a contract's approval to go over the max gauges.
    event CanContractExceedMaxGaugesUpdate(address indexed account, bool canContractExceedMaxGauges);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when trying to increment/decrement a mismatched number of gauges and weights.
    error SizeMismatchError();

    /// @notice thrown when trying to increment over the max allowed gauges.
    error MaxGaugeError();

    /// @notice thrown when incrementing over a user's free weight.
    error OverWeightError();

    /// @notice thrown when incrementing during the frozen window.
    error IncrementFreezeError();

    /// @notice thrown when trying to increment or remove a non-live gauge, or add a live gauge.
    error InvalidGaugeError();
}

// src/erc-20/interfaces/IERC20MultiVotes.sol

// Voting logic inspired by OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Votes.sol)

/**
 * @title ERC20 Multi-Delegation Voting contract
 *  @notice an ERC20 extension that allows delegations to multiple delegatees up to a user's balance on a given block.
 */
interface IERC20MultiVotes {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice A checkpoint for marking the number of votes from a given block.
     * @param fromBlock the block number that the votes were delegated.
     * @param votes the number of votes delegated.
     */
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    /*///////////////////////////////////////////////////////////////
                        VOTE CALCULATION LOGIC
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Get the `pos`-th checkpoint for `account`.
     */
    function checkpoints(address account, uint32 pos) external view returns (Checkpoint memory);

    /**
     * @notice Get number of checkpoints for `account`.
     */
    function numCheckpoints(address account) external view returns (uint32);

    /**
     * @notice Gets the amount of unallocated votes for `account`.
     * @param account the address to get free votes of.
     * @return the amount of unallocated votes.
     */
    function freeVotes(address account) external view returns (uint256);

    /**
     * @notice Gets the current votes balance for `account`.
     * @param account the address to get votes of.
     * @return the amount of votes.
     */
    function getVotes(address account) external view returns (uint256);

    /**
     * @notice helper function exposing the amount of weight available to allocate for a user
     */
    function userUnusedVotes(address user) external view returns (uint256);

    /**
     * @notice Retrieve the number of votes for `account` at the end of `blockNumber`.
     * @param account the address to get votes of.
     * @param blockNumber the block to calculate votes for.
     * @return the amount of votes.
     */
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        ADMIN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice the maximum amount of delegates for a user at a given time
     */
    function maxDelegates() external view returns (uint256);

    /**
     * @notice an approve list for contracts to go above the max delegate limit.
     */
    function canContractExceedMaxDelegates(address) external view returns (bool);

    /**
     * @notice set the new max delegates per user. Requires auth by `authority`.
     */
    function setMaxDelegates(uint256 newMax) external;

    /**
     * @notice set the canContractExceedMaxDelegates flag for an account.
     */
    function setContractExceedMaxDelegates(address account, bool canExceedMax) external;

    /**
     * @notice mapping from a delegator to the total number of delegated votes.
     */
    function userDelegatedVotes(address) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        DELEGATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get the amount of votes currently delegated by `delegator` to `delegatee`.
     * @param delegator the account which is delegating votes to `delegatee`.
     * @param delegatee the account receiving votes from `delegator`.
     * @return the total amount of votes delegated to `delegatee` by `delegator`
     */
    function delegatesVotesCount(address delegator, address delegatee) external view returns (uint256);

    /**
     * @notice Get the list of delegates from `delegator`.
     * @param delegator the account which is delegating votes to delegates.
     * @return the list of delegated accounts.
     */
    function delegates(address delegator) external view returns (address[] memory);

    /**
     * @notice Get the number of delegates from `delegator`.
     * @param delegator the account which is delegating votes to delegates.
     * @return the number of delegated accounts.
     */
    function delegateCount(address delegator) external view returns (uint256);

    /**
     * @notice Delegate `amount` votes from the sender to `delegatee`.
     * @param delegatee the receivier of votes.
     * @param amount the amount of votes received.
     * @dev requires "freeVotes(msg.sender) > amount" and will not exceed max delegates
     */
    function incrementDelegation(address delegatee, uint256 amount) external;

    /**
     * @notice Undelegate `amount` votes from the sender from `delegatee`.
     * @param delegatee the receivier of undelegation.
     * @param amount the amount of votes taken away.
     */
    function undelegate(address delegatee, uint256 amount) external;

    /**
     * @notice Delegate all votes `newDelegatee`. First undelegates from an existing delegate. If `newDelegatee` is zero, only undelegates.
     * @param newDelegatee the receiver of votes.
     * @dev undefined for `delegateCount(msg.sender) > 1`
     * NOTE This is meant for backward compatibility with the `ERC20Votes` and `ERC20VotesComp` interfaces from OpenZeppelin.
     */
    function delegate(address newDelegatee) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice emitted when updating the maximum amount of delegates per user
    event MaxDelegatesUpdate(uint256 oldMaxDelegates, uint256 newMaxDelegates);

    /// @notice emitted when updating the canContractExceedMaxDelegates flag for an account
    event CanContractExceedMaxDelegatesUpdate(address indexed account, bool canContractExceedMaxDelegates);

    /// @dev Emitted when a `delegator` delegates `amount` votes to `delegate`.
    event Delegation(address indexed delegator, address indexed delegate, uint256 amount);

    /// @dev Emitted when a `delegator` undelegates `amount` votes from `delegate`.
    event Undelegation(address indexed delegator, address indexed delegate, uint256 amount);

    /// @dev Emitted when a token transfer or delegate change results in changes to an account's voting power.
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

    /// @notice An event thats emitted when an account changes its delegate
    /// @dev this is used for backward compatibility with OZ interfaces for ERC20Votes and ERC20VotesComp.
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when trying to read from an invalid block.
    error BlockError();

    /// @dev thrown when attempting to delegate more votes than an address has free, or exceeding the max delegates
    error DelegationError();

    /// @dev thrown when attempting to undelegate more votes than the delegatee has unused.
    error UndelegationVoteError();
}

// src/erc-4626/interfaces/IERC4626.sol

interface IERC4626 {
    /**
     * @notice Deposit assets into the Vault.
     * @param assets The amount of assets to deposit.
     * @param receiver The address to receive the shares.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @notice Mint shares from the Vault.
     * @param shares The amount of shares to mint.
     * @param receiver The address to receive the shares.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @notice Withdraw assets from the Vault.
     * @param assets The amount of assets to withdraw.
     * @param receiver The address to receive the assets.
     * @param owner The address to receive the shares.
     */
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);

    /**
     * @notice  Redeem shares from the Vault.
     * @param shares The amount of shares to redeem.
     * @param receiver The address to receive the assets.
     * @param owner The address to receive the shares.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    /**
     * @notice Calculates the amount of shares that would be received for a given amount of assets.
     * @param assets The amount of assets to deposit.
     */
    function convertToShares(uint256 assets) external view returns (uint256);

    /**
     * @notice  Calculates the amount of assets that would be received for a given amount of shares.
     * @param shares The amount of shares to redeem.
     */
    function convertToAssets(uint256 shares) external view returns (uint256);

    /**
     * @notice Preview the amount of shares that would be received for a given amount of assets.
     */
    function previewDeposit(uint256 assets) external view returns (uint256);

    /**
     * @notice Previews the amount of assets that would be received for minting a given amount of shares
     * @param shares The amount of shares to mint
     */
    function previewMint(uint256 shares) external view returns (uint256);

    /**
     * @notice Previews the amount of shares that would be received for a withdraw of a given amount of assets.
     * @param assets The amount of assets to withdraw.
     */
    function previewWithdraw(uint256 assets) external view returns (uint256);

    /**
     * @notice Previews the amount of assets that would be received for a redeem of a given amount of shares.
     */
    function previewRedeem(uint256 shares) external view returns (uint256);

    /**
     * @notice Returns the max amount of assets that can be deposited into the Vault.
     */
    function maxDeposit(address) external view returns (uint256);

    /**
     * @notice Returns the max amount of shares that can be minted from the Vault.
     */
    function maxMint(address) external view returns (uint256);

    /**
     * @notice Returns the max amount of assets that can be withdrawn from the Vault.
     */
    function maxWithdraw(address owner) external view returns (uint256);

    /**
     * @notice Returns the max amount of shares that can be redeemed from the Vault.
     */
    function maxRedeem(address owner) external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
}

// src/erc-4626/interfaces/IERC4626DepositOnly.sol

interface IERC4626DepositOnly {
    /**
     * @notice Gets the total amount of underlying assets held by the contract.
     * @return _totalAssets total number of underlying assets.
     */
    function totalAssets() external view returns (uint256 _totalAssets);

    /**
     * @notice Deposit assets into the Vault.
     * @param assets The amount of assets to deposit.
     * @param receiver The address to receive the shares.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @notice Mint shares from the Vault.
     * @param shares The amount of shares to mint.
     * @param receiver The address to receive the shares.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @notice Calculates the amount of shares that would be received for a given amount of assets.
     * @param assets The amount of assets to deposit.
     */
    function convertToShares(uint256 assets) external view returns (uint256);

    /**
     * @notice  Calculates the amount of assets that would be received for a given amount of shares.
     * @param shares The amount of shares to redeem.
     */
    function convertToAssets(uint256 shares) external view returns (uint256);

    /**
     * @notice Previews the amount of shares that would be received for a given amount of assets.
     *  @param assets The amount of assets to deposit.
     */
    function previewDeposit(uint256 assets) external view returns (uint256);

    /**
     * @notice Previews the amount of assets that would be received for minting a given amount of shares
     *  @param shares The amount of shares to mint
     */
    function previewMint(uint256 shares) external view returns (uint256);

    /**
     * @notice Returns the maximum amount of assets that can be deposited.
     *  @param owner The address of the owner of the assets.
     */
    function maxDeposit(address owner) external view returns (uint256);

    /**
     * @notice Returns the maximum amount of shares that can be minted.
     *  @param owner The address of the owner of the shares.
     */
    function maxMint(address owner) external view returns (uint256);
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
}

// src/gauges/interfaces/IUniswapV3Gauge.sol

/**
 * @title Uniswap V3 Gauge, implementation of Base V2 Gauge.
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Handles rewards for distribution, boost attaching/detaching
 *          and accruing bribes for a strategy.
 *          This gauge was designed for Uniswap V3 liquidity mining,
 *          it is responsible for creating and depositing weekly
 *          rewards in UniswapV3Staker.
 *
 *          The minimum width represents the minimum range a UniV3 NFT
 *          must have to be illegible for staking.
 *
 *  @dev    `distribute()` must be called during the 12-hour offset after
 *           an epoch ends or rewards will be queued for the next epoch.
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⠒⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠦⣄⠀⠀⢀⣠⠖⢶⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⢤⡈⠳⣦⡀⠀⠀⠀⠀⠀⠀⠒⢦⣀⠀⠀⠈⢱⠖⠉⠀⠀⠀⠳⡄⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣌⣻⣦⡀⠀⠀⠀⠀⠀⠀⠈⠳⢄⢠⡏⠀⠀⠐⠀⠀⠀⠘⡀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠙⢿⣿⣄⠈⠓⢄⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢀⡴⠁⠀⠀⠀⡠⠂⠀⠀⠀⡾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢦⠀⠀⠀⠀⠀⠑⢄⠀⠀⠙⢿⣦⠀⠀⠑⢄⠀⠀⢰⠃⠀⠀⠀⠀⢀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⢠⠞⠀⠀⠀⠀⢰⠃⠀⠀⠀⠀⠧⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠈⢧⠀⠀⠀⠀⠀⠈⠳⣄⠀⠀⠙⢷⡀⠀⠀⠙⢦⡘⢦⠀⠀⠀⠺⢿⠇⢀⠀⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⢠⠎⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⡆⡀⠀⠀⠀⠈⣦⠀⠀⠀⠀⠀⠀⠈⢦⡀⠀⠀⠙⢦⡀⠀⠀⠑⢾⡇⠀⠀⠀⠈⢠⡟⠁⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠁⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⢳⠀⢣⣧⠀⠀⠀⠀⠘⡆⠑⡀⠀⠀⠀⠀⠐⡝⢄⠀⠀⠀⠹⢆⠀⠀⢈⡷⠀⠀⠀⢠⡟⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸⣦⠀⠀⠀⠀⠀⢸⡄⢸⢹⣄⣆⠀⠀⠀⠸⡄⠹⡄⠀⠀⠀⠀⠈⢎⢧⡀⠀⠀⠈⠳⣤⡿⠛⠳⡀⠀⡉⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⠇⠀⠀⠀⡇⠀⢸⢸⠀⠀⠀⠀⠀⠘⣿⠀⣿⣿⡙⡄⠀⠀⠀⠹⡄⠘⡄⠀⠀⠀⠀⠈⢧⡱⡄⠀⠀⠀⠛⢷⣦⣤⣽⣶⣶⣶⣦⣤⣸⣀⡀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠀⠀⠀⡇⠀⢸⡸⡆⠀⠀⠀⠀⠀⣿⣇⣿⣿⣷⣽⡖⠒⠒⠊⢻⡉⠹⡏⠒⠂⠀⠀⠀⠳⡜⣦⡀⠀⠀⠀⠹⣿⡟⠋⣿⡻⣯⣍⠉⡉⠛⠶⣄⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⡇⡀⠸⡇⣧⢂⠀⠀⠀⢰⡸⣿⡿⢻⡇⠁⠹⣆⠀⠀⠈⢷⡀⠹⡾⣆⠀⠀⠀⠀⠙⣎⠟⣦⣀⣀⣴⣿⠀⣼⣿⢷⣌⠻⢷⣦⣄⣸⠇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⢹⣇⠀⣧⢹⡟⡄⠀⠀⠀⣿⢿⠀⡀⢻⡀⠘⣎⢇⢀⣀⣨⣿⣦⠹⣾⣧⡀⠀⠀⣀⣨⠶⠾⣿⣿⣿⣿⣶⡿⣼⡞⠙⢷⣵⡈⠉⠉⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⢠⣠⠤⠒⢺⣿⠒⢿⡼⣿⣳⡀⠀⣠⠋⢿⠆⠰⡄⢳⣤⠼⣿⣯⣶⠿⠿⠿⠿⢿⣿⣷⣶⣿⠁⠀⠀⠀⣻⣿⣿⣿⣿⣷⣿⢡⢇⣾⢻⣿⣶⣄⡀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢰⣼⢾⡀⠀⠀⠸⣿⡇⠈⣧⢹⡛⢣⡴⠃⠀⠘⣿⡀⣨⠾⣿⣾⠟⢩⣷⣿⣶⣤⠀⠀⠈⢿⡿⣿⠀⠀⠀⠀⢹⢿⣿⣿⣿⣿⠋⢻⠏⢹⣸⠁⠈⠛⠿⣶⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣇⠀⠀⠀⣿⢹⡄⢻⣧⢷⠛⣧⠀⠀⠀⠈⣿⣧⣾⣿⠁⠀⣾⣿⣿⣷⣾⡇⠀⠀⡜⠀⢸⠀⠀⠀⠀⢸⡄⢻⣿⣿⠋⠀⢸⠀⠀⣿⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⢸⣄⠠⣶⣻⣖⣷⡘⣇⠈⢧⠘⣷⠶⠒⠊⠙⣿⠟⠁⠀⠀⢹⡿⣿⣿⢿⠇⠀⠐⠁⠀⢼⠀⠀⠀⠀⡼⢸⠻⣿⣧⣀⠀⠀⢀⣼⢹⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⠟⠛⠛⣿⣿⣿⣦⡈⠠⠘⠆⠀⠀⠈⠁⠀⠀⠀⠀⠈⠛⠶⠞⠋⠀⠀⠀⡀⢠⡏⠀⠀⠀⢠⡇⣼⢸⣿⡟⠉⢣⣠⢾⡇⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢀⣨⢿⡿⣟⢿⡄⠀⠀⣿⣿⣯⣿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⣼⡿⢱⣿⣿⠁⠀⠈⡇⢸⡇⢠⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢋⠁⠈⡇⠘⣆⠑⢄⠀⠘⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠇⠀⠀⢠⢿⣷⣿⣿⣿⡄⠀⠰⠃⣼⡇⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⢻⠀⢹⣆⠀⠁⢤⡌⠓⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠀⠀⢠⡏⢸⣿⣿⣿⡿⠻⡄⣠⣾⣿⡇⢸⠦⠀⠀⠀ ⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⢸⡆⢸⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡸⡏⠀⢀⡟⠀⣾⣿⣿⣿⠀⠀⣽⠁⢸⣿⣷⢸⡇⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⢸⡇⢸⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⠁⢠⡟⠀⢰⣿⣿⣿⣿⠀⢠⠇⢠⣾⡇⢿⡈⡇⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠈⠃⢸⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⡏⢀⠎⠀⠀⡼⣽⠋⠁⠈⢀⣾⣴⣿⣿⡇⠸⡇⢱⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⠀⢸⣿⠑⢹⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠐⠂⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠋⢠⠟⠀⠀⣸⣷⠃⠀⢀⡞⠁⢸⣿⣿⣿⣧⠀⢿⣸⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢻⠃⠀⠀⠀⣿⡇⠀⣼⣿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⠇⡴⠃⠀⠀⣰⣟⡏⠀⡠⠋⢀⣠⣿⣿⡏⠈⣿⡇⠘⣏⣆⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢀⡾⠀⠀⠀⢠⣿⠀⠀⣿⣿⡿⢹⣿⡿⠷⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣷⢧⡞⠁⠀⠀⣸⣿⠼⠷⢶⣶⣾⣿⡿⣿⡿⠀⠀⠘⣷⠀⠸⣿⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠊⠀⠀⠀⠀⣼⠇⠀⣸⣿⡿⢡⣿⡟⠀⣠⣾⣿⣿⣿⣷⣦⣤⣀⣠⣾⣿⣿⣿⣿⣛⣋⣀⣀⣠⢞⡟⠀⣀⡠⢾⣿⣿⡟⠀⢿⣧⠀⠀⠀⠘⡆⠀⠙⡇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠀⢠⣿⠟⢀⣿⡟⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠉⠁⠀⠉⠉⠉⠑⠻⢭⡉⠉⠀⢸⡆⢿⡗⠀⠈⢿⡀⠀⠀⠀⠹⡄⠀⢱⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠁⠀⢀⡞⠉⢠⡿⣌⣴⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣄⢸⡇⠘⡇⠀⠀⠈⢧⠀⠀⠀⠀⢱⡀⠈⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⣠⠏⠀⣰⣿⣿⣿⡿⠟⠿⠛⣩⣾⡿⠛⠁⠀⢀⣼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⡇⠀⠸⡄⠀⠀⠈⢇⠀⠀⠀⠀⢻⡀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⣠⠇⣠⣾⣿⠿⠛⠁⢀⣠⣴⣿⠟⠁⠀⠀⠀⢰⠋⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡀⠀⠹⡄⠀⠀⠘⢆⠀⠀⠀⠀⠳⡀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣫⡾⠟⠋⢁⣀⣤⣶⣿⡟⠋⠀⠀⣀⣠⣤⣾⡿⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⢹⡄⠀⠀⠈⢧⡀⠀⠀⠀⠙⣔⡄⠀
 */
interface IUniswapV3Gauge {
    /*//////////////////////////////////////////////////////////////
                         GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The Uniswap V3 Staker contract
    function uniswapV3Staker() external view returns (address);

    /// @notice The minimum width of the Uniswap V3 position to be eligible for staking
    function minimumWidth() external view returns (uint24);

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when the minimum width is updated
    event NewMinimumWidth(uint24 minimumWidth);

    /*//////////////////////////////////////////////////////////////
                         ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets the minimum width
    /// @dev Only the owner can call this function
    function setMinimumWidth(uint24 _minimumWidth) external;
}

// src/hermes/interfaces/IbHermesUnderlying.sol

/**
 * @title bHermes Underlying
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Represents the underlying position of the bHermes token.
 *   ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⠀⣀⣀⠀⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣇⠸⣿⣿⠇⣸⣿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀
 *  ⢀⣠⣴⣶⠿⠋⣩⡿⣿⡿⠻⣿⡇⢠⡄⢸⣿⠟⢿⣿⢿⣍⠙⠿⣶⣦⣄⡀⠀
 *  ⠀⠉⠉⠁⠶⠟⠋⠀⠉⠀⢀⣈⣁⡈⢁⣈⣁⡀⠀⠉⠀⠙⠻⠶⠈⠉⠉⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⡿⠛⢁⡈⠛⢿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⣿⣦⣤⣈⠁⢠⣴⣿⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠻⢿⣿⣦⡉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⣦⣈⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⠦⠈⠙⠿⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣤⡈⠁⢤⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠑⢶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠁⢰⡆⠈⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⠈⣡⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *
 *      ⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⣿⡿⠛⠛⢿⣿⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⢿⠁⠀⠀⠈⡿⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢀⣤⣄
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣀⣀⣀⣸⣿⣿
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢸⣿⣿
 *      ⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠉⠁
 *      ⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀
 *      ⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀
 *      ⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿
 */
interface IbHermesUnderlying {
    /// @notice thrown when minter is not bHermes contract.
    error NotbHermes();

    /**
     * @notice
     */
    function bHermes() external view returns (address);

    /**
     * @notice Mints new bHermes underlying tokens to a specific account.
     * @param to account to transfer bHermes underlying tokens to
     * @param amount amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external;
}

// src/rewards/interfaces/IMultiRewardsDepot.sol

/**
 * @title Multiple Rewards Depot
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Holds multiple rewards to be distributed to Flywheel Rewards distributor contracts.
 *          When `getRewards()` is called by an added flywheel rewards, it transfers
 *          its balance of the associated assets to its flywheel rewards contract.
 *
 *             ⠉⠉⠉⠉⠉⠉⠉⠉⢉⠟⣩⠋⠉⠉⢩⠟⠉⣹⠋⡽⠉⠉⠉⠉⠉⠉⠉⠉⡏⠉⠉⠉⠉⠉⠉⠹⠹⡉⠉⠉⢙⠻⡍⠉⠉⠹⡍⠉⠉⠉
 *         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠈⢻⡽⣄⠀⠀⠀⠙⣄⠀⠻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢯⣎⢧⡀⠀⠀⠘⢦⠀⢹⡄⠀⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⢀⣀⣠⣤⣶⠾⠷⠞⢿⡏⠻⣄⠀⠀⠈⢧⡀⢻⡄⠀⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⡾⠟⠛⠉⠁⠀⠀⠀⠀⠈⢳⡀⠈⢳⡀⠀⠀⠻⣄⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣄⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠸⠉⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠙⢦⡀⠀⠘⢦⣻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠀⠀⠀⠀⡆⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠀⠈⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⣄⠀⠀⠙⢦⡀⠀⠉⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⣟⠀⠀⠀⠀⣷⢣⣀⣀⠘⣧⠀⠀⠀⣶⠀⠀⠀⠀⢹⡄⠀⠀⠸⡆⠀⠀⠀⣀⣀⡤⠴⠶⠶⠶⠶⠘⠦⠤⣀⡀⠉⠳⢤⡀⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⡼
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⡆⠀⠀⠀⠸⣾⠉⠉⠁⢿⡆⠀⠀⠘⢧⠀⠀⠀⠀⢳⡀⠀⠀⢳⡴⠚⠉⢀⣀⢀⣠⣶⣶⣿⣿⣿⣿⣧⣤⣀⣀⠀⠀⠈⠓⢧⡀⠀⠀⠀⠀⠀⠀⢰⡁
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠠⣧⢿⡆⠀⠀⠀⡜⣇⠀⠀⠘⣿⣄⡀⠀⠈⢣⡀⠀⠀⠀⢻⣆⠀⠈⢷⡀⣺⢿⣾⣿⡿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠈⢷⠀⠀⠀⠀⠀⢀⠿⠃
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⢳⡀⠀⠀⢧⠈⢦⡀⠀⠘⣏⠛⣦⣀⣀⣙⠦⠤⢤⠤⠽⠗⠀⠀⢸⣭⣾⡿⠋⠀⣤⣤⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⢸⠀⠀⠀⠀⠀⢀⣀⠀
 * ⠀⠀⠀⠀⠀⣦⠀⠀⠀⠘⡆⠀⢳⠲⣄⢘⣷⠬⣥⣄⡀⠈⠂⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠙⠃⠀⠀⣼⣿⣿⣿⡿⠿⠁⠛⢛⣿⣿⣿⣿⡟⣿⢺⠀⠀⠀⠀⠀⢸⣿⡇
 * ⠸⡄⢆⠀⠀⠈⣷⣄⠀⠀⠹⡆⢀⡴⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠺⣿⣿⡿⠿⠀⠀⠀⠘⠿⢿⣿⣿⠇⠟⢨⠀⡄⠀⠀⠀⠀⢻⣷
 * ⢰⣳⡸⣧⡀⠀⠘⣿⣶⣄⣀⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⡀⢀⠀⢀⠐⠞⢀⣼⠿⠃⠀⠀⢸⣼⠁⠀⠀⠀⠀⠈⠏
 * ⠈⢇⠹⡟⠙⢦⡀⠘⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠿⠤⠴⠾⠟⠛⠉⠁⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⠀⢸⠀
 * ⢃⡘⣆⠘⣦⡀⠋⠀⠈⠛⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠏⠀⠀⠀⠀⠀⠀⠟⠁
 * ⠀⣷⡘⣆⠈⢷⣄⡀⠀⠐⣽⡄⠀⠀⠀⢀⣠⣾⣿⣶⣶⣶⠶⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⠀⠀⠀⠀⠀⠀⡀⠀⠀
 * ⠀⠉⢳⡘⢆⠈⢦⢁⡤⢄⡀⢷⡀⢀⢰⣿⡿⠟⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀
 * ⠀⠀⢸⠛⣌⠇⠀⢻⠀⠀⠙⢎⢷⣀⡿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣇
 * ⠀⠀⠀⠀⠈⢳⣄⡘⡆⠀⠀⠘⢧⡩⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠏⠈
 * ⠀⠀⠀⠀⠀⠀⡟⢽⣧⠀⠀⠀⠈⢿⣮⣳⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡏⠀⠀
 * ⠀⠀⠀⠀⠀⣸⡇⠈⠹⣇⠀⠀⠀⠘⣿⡀⠈⠙⠒⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠀⠀⠀
 * ⠀⠀⠀⠀⠀⣿⠁⠀⠀⢿⡀⠀⠀⠀⠹⡷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣾⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⠃⠀⠀⠀
 * ⢷⡇⠀⠀⢠⠇⠀⠀⡄⢀⣇⠀⠀⠀⠀⢷⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡤⠤⠖⣚⣯⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⡟⠀⠀⠀⠀
 * ⠀⠙⣦⠀⡜⠀⠀⢸⠁⣸⣻⡄⠀⠀⠀⠸⣇⢹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣤⣖⣞⣩⣥⣴⠶⠾⠟⠋⠄⠀⠀⠈⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⡿⠀⠀⠀⠀⠀
 * ⠀⠀⠈⢳⡄⠀⢀⡟⢠⡇⠙⣇⠀⠀⠀⠀⢻⡀⠘⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⡏⢻⣇⠀⠀⠀⠀⠀⠀⣠⠞⡽⠁⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⠃⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠙⣆⡘⠀⡞⠀⠀⢿⡀⠀⠀⠀⠀⣧⠀⠀⣿⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⡙⢦⣀⣀⡠⠴⢊⡡⠞⠁⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀
 * ⢄⠀⠀⠀⠀⠈⠳⣼⠄⠀⢀⣼⣧⠀⠀⠀⠀⢸⣆⢠⡧⣼⠉⠳⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠒⠶⠖⠊⣉⡀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠠
 * ⠀⠳⡄⠀⠀⠀⠀⠙⢧⡀⢠⡿⢻⡀⠀⠀⠀⠀⢻⣤⠼⠿⠤⢤⣄⣈⡿⠲⠤⣄⣀⡤⠖⢶⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠂
 * ⠀⠀⠙⣄⠀⠀⠀⠀⠈⢳⣼⠃⢠⡇⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⢉⡓⣶⣴⠞⠉⠀⢀⢻⣧⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠙⣧⠀⠀⠀⠀⠀⠹⣦⣶⢿⣦⠀⠀⠀⠀⠹⡄⠀⠀⠀⠀⣰⣿⡟⠁⠀⠀⢠⢿⣟⠛⠛⠛⠛⠒⠦⣤⣄⡀⠀⠀⢀⣠⣴⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠐⠋⣧⠀⠀⠀⠀⠀⠈⠧⣼⢹⠀⠀⠀⠀⠀⢱⡀⠀⠀⢰⣿⡟⠀⠀⠀⢀⢏⣿⡙⠲⢦⣄⣀⡀⠀⠀⠀⣿⠋⠉⠹⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⡐⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⡨⣉⡀⠈⠀⠀⠀⠀⢷⡀⠀⣾⡿⠀⠀⠀⠀⡞⣾⣿⣿⣷⣶⣤⣤⣭⣽⣶⣿⡏⠀⠀⠀⠹⢿⣿⣿⣿⠿⠋⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⢀⣀⡞⢻⠃⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⣰⡿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠘⠛⢧⣄⡀⠀⠀⢀⣶⠞⠋⠀⠀⠀⠀⠀⠀⠀
 */
interface IMultiRewardsDepot {
    /*///////////////////////////////////////////////////////////////
                        GET REWARDS LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice returns available reward amount and transfer them to rewardsContract.
     *  @dev msg.sender needs to be an added Flywheel Rewards distributor contract.
     *       Transfers all associated assets to msg.sender.
     *  @return balance available reward amount for strategy.
     */
    function getRewards() external returns (uint256 balance);

    /*///////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     *  @notice Adds an asset to be distributed by a given contract.
     *  @param rewardsContract address of the rewards contract to attach the asset to.
     *  @param asset address of the asset to be distributed.
     */
    function addAsset(address rewardsContract, address asset) external;

    /**
     *  @notice Removes an asset from the reward contract that distributes the rewards.
     *  @param rewardsContract address of the contract to remove the asset from being distributed.
     */
    function removeAsset(address rewardsContract) external;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a new asset and rewards contract are added.
     * @param rewardsContract address of the rewards contract.
     * @param asset address of the asset to be distributed.
     */
    event AssetAdded(address indexed rewardsContract, address indexed asset);

    /**
     * @notice Emitted when an asset is removed from a rewards contract.
     * @param rewardsContract address of the rewards contract.
     * @param asset address of the asset to be distributed.
     */
    event AssetRemoved(address indexed rewardsContract, address indexed asset);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error thrown when trying to add existing flywheel rewards or assets.
    error ErrorAddingAsset();

    /// @notice Error thrown when trying to remove non-existing flywheel rewards.
    error ErrorRemovingAsset();
}

// src/rewards/interfaces/IRewardsDepot.sol

/**
 * @title Rewards Depot
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Holds rewards to be distributed by a Flywheel Rewards distributor contract.
 *          The `getRewards()` hook should transfer all available rewards to a
 *          flywheel rewards contract to ensure proper accounting.
 *             ⠉⠉⠉⠉⠉⠉⠉⠉⢉⠟⣩⠋⠉⠉⢩⠟⠉⣹⠋⡽⠉⠉⠉⠉⠉⠉⠉⠉⡏⠉⠉⠉⠉⠉⠉⠹⠹⡉⠉⠉⢙⠻⡍⠉⠉⠹⡍⠉⠉⠉
 *         ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⠀⠀⠀⠀⠀⠀⠀⠈⢻⡽⣄⠀⠀⠀⠙⣄⠀⠻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢯⣎⢧⡀⠀⠀⠘⢦⠀⢹⡄⠀⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⢀⣀⣠⣤⣶⠾⠷⠞⢿⡏⠻⣄⠀⠀⠈⢧⡀⢻⡄⠀⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⡾⠟⠛⠉⠁⠀⠀⠀⠀⠈⢳⡀⠈⢳⡀⠀⠀⠻⣄⢹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣄⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠸⠉⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠙⢦⡀⠀⠘⢦⣻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠀⠀⠀⠀⡆⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠀⠈⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠱⣄⠀⠀⠙⢦⡀⠀⠉⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⣟⠀⠀⠀⠀⣷⢣⣀⣀⠘⣧⠀⠀⠀⣶⠀⠀⠀⠀⢹⡄⠀⠀⠸⡆⠀⠀⠀⣀⣀⡤⠴⠶⠶⠶⠶⠘⠦⠤⣀⡀⠉⠳⢤⡀⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⡼
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⡿⡆⠀⠀⠀⠸⣾⠉⠉⠁⢿⡆⠀⠀⠘⢧⠀⠀⠀⠀⢳⡀⠀⠀⢳⡴⠚⠉⢀⣀⢀⣠⣶⣶⣿⣿⣿⣿⣧⣤⣀⣀⠀⠀⠈⠓⢧⡀⠀⠀⠀⠀⠀⠀⢰⡁
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠠⣧⢿⡆⠀⠀⠀⡜⣇⠀⠀⠘⣿⣄⡀⠀⠈⢣⡀⠀⠀⠀⢻⣆⠀⠈⢷⡀⣺⢿⣾⣿⡿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠈⢷⠀⠀⠀⠀⠀⢀⠿⠃
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⢳⡀⠀⠀⢧⠈⢦⡀⠀⠘⣏⠛⣦⣀⣀⣙⠦⠤⢤⠤⠽⠗⠀⠀⢸⣭⣾⡿⠋⠀⣤⣤⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⢸⠀⠀⠀⠀⠀⢀⣀⠀
 * ⠀⠀⠀⠀⠀⣦⠀⠀⠀⠘⡆⠀⢳⠲⣄⢘⣷⠬⣥⣄⡀⠈⠂⠀⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠙⠃⠀⠀⣼⣿⣿⣿⡿⠿⠁⠛⢛⣿⣿⣿⣿⡟⣿⢺⠀⠀⠀⠀⠀⢸⣿⡇
 * ⠸⡄⢆⠀⠀⠈⣷⣄⠀⠀⠹⡆⢀⡴⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠺⣿⣿⡿⠿⠀⠀⠀⠘⠿⢿⣿⣿⠇⠟⢨⠀⡄⠀⠀⠀⠀⢻⣷
 * ⢰⣳⡸⣧⡀⠀⠘⣿⣶⣄⣀⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⡀⢀⠀⢀⠐⠞⢀⣼⠿⠃⠀⠀⢸⣼⠁⠀⠀⠀⠀⠈⠏
 * ⠈⢇⠹⡟⠙⢦⡀⠘⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⠿⠤⠴⠾⠟⠛⠉⠁⠀⠀⠀⠀⢸⠃⠀⠀⠀⠀⠀⢸⠀
 * ⢃⡘⣆⠘⣦⡀⠋⠀⠈⠛⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠏⠀⠀⠀⠀⠀⠀⠟⠁
 * ⠀⣷⡘⣆⠈⢷⣄⡀⠀⠐⣽⡄⠀⠀⠀⢀⣠⣾⣿⣶⣶⣶⠶⠤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠏⠀⠀⠀⠀⠀⠀⡀⠀⠀
 * ⠀⠉⢳⡘⢆⠈⢦⢁⡤⢄⡀⢷⡀⢀⢰⣿⡿⠟⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀
 * ⠀⠀⢸⠛⣌⠇⠀⢻⠀⠀⠙⢎⢷⣀⡿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣇
 * ⠀⠀⠀⠀⠈⢳⣄⡘⡆⠀⠀⠘⢧⡩⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠏⠈
 * ⠀⠀⠀⠀⠀⠀⡟⢽⣧⠀⠀⠀⠈⢿⣮⣳⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⡏⠀⠀
 * ⠀⠀⠀⠀⠀⣸⡇⠈⠹⣇⠀⠀⠀⠘⣿⡀⠈⠙⠒⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠀⠀⠀
 * ⠀⠀⠀⠀⠀⣿⠁⠀⠀⢿⡀⠀⠀⠀⠹⡷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣾⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⠃⠀⠀⠀
 * ⢷⡇⠀⠀⢠⠇⠀⠀⡄⢀⣇⠀⠀⠀⠀⢷⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡤⠤⠖⣚⣯⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⡟⠀⠀⠀⠀
 * ⠀⠙⣦⠀⡜⠀⠀⢸⠁⣸⣻⡄⠀⠀⠀⠸⣇⢹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣤⣖⣞⣩⣥⣴⠶⠾⠟⠋⠄⠀⠀⠈⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⣠⣿⣿⡿⠀⠀⠀⠀⠀
 * ⠀⠀⠈⢳⡄⠀⢀⡟⢠⡇⠙⣇⠀⠀⠀⠀⢻⡀⠘⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢿⡏⢻⣇⠀⠀⠀⠀⠀⠀⣠⠞⡽⠁⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⠃⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠙⣆⡘⠀⡞⠀⠀⢿⡀⠀⠀⠀⠀⣧⠀⠀⣿⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠦⡙⢦⣀⣀⡠⠴⢊⡡⠞⠁⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀
 * ⢄⠀⠀⠀⠀⠈⠳⣼⠄⠀⢀⣼⣧⠀⠀⠀⠀⢸⣆⢠⡧⣼⠉⠳⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠒⠶⠖⠊⣉⡀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠠
 * ⠀⠳⡄⠀⠀⠀⠀⠙⢧⡀⢠⡿⢻⡀⠀⠀⠀⠀⢻⣤⠼⠿⠤⢤⣄⣈⡿⠲⠤⣄⣀⡤⠖⢶⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠂
 * ⠀⠀⠙⣄⠀⠀⠀⠀⠈⢳⣼⠃⢠⡇⠀⠀⠀⠀⠘⡇⠀⠀⠀⠀⠀⢉⡓⣶⣴⠞⠉⠀⢀⢻⣧⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠙⣧⠀⠀⠀⠀⠀⠹⣦⣶⢿⣦⠀⠀⠀⠀⠹⡄⠀⠀⠀⠀⣰⣿⡟⠁⠀⠀⢠⢿⣟⠛⠛⠛⠛⠒⠦⣤⣄⡀⠀⠀⢀⣠⣴⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠐⠋⣧⠀⠀⠀⠀⠀⠈⠧⣼⢹⠀⠀⠀⠀⠀⢱⡀⠀⠀⢰⣿⡟⠀⠀⠀⢀⢏⣿⡙⠲⢦⣄⣀⡀⠀⠀⠀⣿⠋⠉⠹⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⡐⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⡨⣉⡀⠈⠀⠀⠀⠀⢷⡀⠀⣾⡿⠀⠀⠀⠀⡞⣾⣿⣿⣷⣶⣤⣤⣭⣽⣶⣿⡏⠀⠀⠀⠹⢿⣿⣿⣿⠿⠋⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⢀⣀⡞⢻⠃⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⣰⡿⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠘⠛⢧⣄⡀⠀⠀⢀⣶⠞⠋⠀⠀⠀⠀⠀⠀⠀
 */
interface IRewardsDepot {
    /**
     * @notice returns available reward amount and transfer them to rewardsContract.
     *  @dev Can only be called by Flywheel Rewards distributor contract.
     *  @return balance available reward amount for strategy.
     */
    function getRewards() external returns (uint256 balance);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when msg.sender is not the flywheel rewards
    error FlywheelRewardsError();
}

// src/uni-v3-staker/libraries/IncentiveTime.sol

/**
 * @title Incentive Time library
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This library is responsible for computing the incentive start and end times.
 */
library IncentiveTime {
    /// @notice Throws when the staked timestamp is before the incentive start time.
    error InvalidStartTime();

    uint256 private constant INCENTIVES_DURATION = 1 weeks; // Incentives are 1 week long and start at THURSDAY 12:00:00 UTC (00:00:00 UTC + 12 hours (INCENTIVE_OFFSET))

    uint256 private constant INCENTIVES_OFFSET = 12 hours;

    function computeStart(uint256 timestamp) internal pure returns (uint96 start) {
        /// @dev The start of the incentive is the start of the week (Thursday 12:00:00 UTC) that the timestamp falls in
        /// Remove Offset, rounds down to nearest week, adds offset back
        return uint96(((timestamp - INCENTIVES_OFFSET) / INCENTIVES_DURATION) * INCENTIVES_DURATION + INCENTIVES_OFFSET);
    }

    function computeEnd(uint256 timestamp) internal pure returns (uint96 end) {
        /// @dev The end of the incentive is the end of the week (Thursday 12:00:00 UTC) that the timestamp falls in
        /// Remove Offset, rounds up to nearest week, adds offset back
        return uint96(
            (((timestamp - INCENTIVES_OFFSET) / INCENTIVES_DURATION) + 1) * INCENTIVES_DURATION + INCENTIVES_OFFSET
        );
    }

    function getEnd(uint96 start) internal pure returns (uint96 end) {
        end = start + uint96(INCENTIVES_DURATION);
    }

    function getEndAndDuration(uint96 start, uint40 stakedTimestamp, uint256 timestamp)
        internal
        pure
        returns (uint96 end, uint256 stakedDuration)
    {
        if (stakedTimestamp < start) revert InvalidStartTime();
        end = start + uint96(INCENTIVES_DURATION);

        // get earliest, block.timestamp or endTime
        uint256 earliest = timestamp < end ? timestamp : end;

        stakedDuration = earliest - stakedTimestamp;
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

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

// src/rewards/interfaces/IFlywheelAcummulatedRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/FlywheelDynamicRewards.sol)

/**
 * @title Flywheel Accumulated Rewards.
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This contract is responsible for strategy rewards management.
 *          Once every cycle all the rewards can be accrued from the strategy's corresponding rewards depot for subsequent distribution.
 *          The reward depot serves as a pool of rewards.
 *          The getNextCycleRewards() hook should also transfer the next cycle's rewards to this contract to ensure proper accounting.
 */
interface IFlywheelAcummulatedRewards {
    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice the length of a rewards cycle
    function rewardsCycleLength() external view returns (uint256);

    /// @notice end of current active rewards cycle's UNIX timestamp.
    function endCycle() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                        FLYWHEEL CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice calculate and transfer accrued rewards to flywheel core
     *  @param strategy the strategy to accrue rewards for
     *  @return amount amounts of tokens accrued and transferred
     */
    function getAccruedRewards(ERC20 strategy) external returns (uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice emitted every time a new rewards cycle begins
    event NewRewardsCycle(uint32 indexed start, uint256 indexed end, uint256 reward);
}

// src/rewards/interfaces/IFlywheelBooster.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/IFlywheelBooster.sol)

/**
 * @title Balance Booster Module for Flywheel
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Flywheel is a general framework for managing token incentives.
 *          It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.
 *
 *          The Booster module is an optional module for virtually boosting or otherwise transforming user balances.
 *          If a booster is not configured, the strategies ERC-20 balanceOf/totalSupply will be used instead.
 *
 *          Boosting logic can be associated with referrals, vote-escrow, or other strategies.
 *
 *          SECURITY NOTE: similar to how Core needs to be notified any time the strategy user composition changes, the booster would need to be notified of any conditions which change the boosted balances atomically.
 *          This prevents gaming of the reward calculation function by using manipulated balances when accruing.
 */
interface IFlywheelBooster {
    /**
     * @notice calculate the boosted supply of a strategy.
     *   @param strategy the strategy to calculate boosted supply of
     *   @return the boosted supply
     */
    function boostedTotalSupply(ERC20 strategy) external view returns (uint256);

    /**
     * @notice Calculate the boosted balance of a user in a given strategy.
     *   @param strategy the strategy to calculate boosted balance of
     *   @param user the user to calculate boosted balance of
     *   @return the boosted balance
     */
    function boostedBalanceOf(ERC20 strategy, address user) external view returns (uint256);
}

// src/uni-v3-staker/libraries/RewardMath.sol

// Rewards logic inspired by Uniswap V3 Contracts (Uniswap/v3-staker/contracts/libraries/RewardMath.sol)

/// @title Math for computing rewards for Uniswap V3 LPs with boost
/// @notice Allows computing rewards given some parameters of boost, stakes and incentives
library RewardMath {
    using FixedPointMathLib for uint256;

    /// @notice Compute the amount of rewards owed given parameters of the incentive and stake
    /// @param stakedDuration The duration staked or 1 week if larger than 1 week
    /// @param liquidity The amount of liquidity, assumed to be constant over the period over which the snapshots are measured
    /// @param boostAmount The amount of boost tokens staked
    /// @param boostTotalSupply The total amount of boost tokens staked
    /// @param secondsPerLiquidityInsideInitialX128 The seconds per liquidity of the liquidity tick range as of the beginning of the period
    /// @param secondsPerLiquidityInsideX128 The seconds per liquidity of the liquidity tick range as of the current block timestamp
    /// @return boostedSecondsInsideX128 The total liquidity seconds inside the position's range for the duration of the stake, adjusted to account for boost
    function computeBoostedSecondsInsideX128(
        uint256 stakedDuration,
        uint128 liquidity,
        uint128 boostAmount,
        uint128 boostTotalSupply,
        uint160 secondsPerLiquidityInsideInitialX128,
        uint160 secondsPerLiquidityInsideX128
    ) internal pure returns (uint160 boostedSecondsInsideX128) {
        // this operation is safe, as the difference cannot be greater than 1/stake.liquidity
        uint160 secondsInsideX128 = (secondsPerLiquidityInsideX128 - secondsPerLiquidityInsideInitialX128) * liquidity;

        if (boostTotalSupply > 0) {
            // calculate boosted seconds insisde
            // 40% of original value + 60% of ((staked duration * boost amount) / boost total supply)
            boostedSecondsInsideX128 = uint160(
                ((secondsInsideX128 * 4) / 10) + ((((stakedDuration << 128) * boostAmount) / boostTotalSupply) * 6) / 10
            );

            // calculate boosted seconds inside, can't be larger than the original reward amount
            if (boostedSecondsInsideX128 > secondsInsideX128) {
                boostedSecondsInsideX128 = secondsInsideX128;
            }
        } else {
            // if no boost supply, then just use 40% of original value
            boostedSecondsInsideX128 = (secondsInsideX128 * 4) / 10;
        }
    }

    /// @notice Compute the amount of rewards owed given parameters of the incentive and stake
    /// @param totalRewardUnclaimed The total amount of unclaimed rewards left for an incentive
    /// @param totalSecondsClaimedX128 How many full liquidity seconds have been already claimed for the incentive
    /// @param startTime When the incentive rewards began in epoch seconds
    /// @param endTime When rewards are no longer being dripped out in epoch seconds
    /// @param secondsInsideX128 The total liquidity seconds inside the position's range for the duration of the stake
    /// @param currentTime The current block timestamp, which must be greater than or equal to the start time
    /// @return reward The amount of rewards owed
    function computeBoostedRewardAmount(
        uint256 totalRewardUnclaimed,
        uint160 totalSecondsClaimedX128,
        uint256 startTime,
        uint256 endTime,
        uint160 secondsInsideX128,
        uint256 currentTime
    ) internal pure returns (uint256) {
        // this should never be called before the start time
        assert(currentTime >= startTime);

        uint256 totalSecondsUnclaimedX128 = ((endTime.max(currentTime) - startTime) << 128) - totalSecondsClaimedX128;

        return totalRewardUnclaimed.mulDiv(secondsInsideX128, totalSecondsUnclaimedX128);
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

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

// lib/openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Metadata.sol

// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// lib/v3-periphery/contracts/interfaces/IERC721Permit.sol

/// @title ERC721 with permit
/// @notice Extension to ERC721 that includes a permit function for signature based approvals
interface IERC721Permit is IERC721 {
    /// @notice The permit typehash used in the permit signature
    /// @return The typehash for the permit
    function PERMIT_TYPEHASH() external pure returns (bytes32);

    /// @notice The domain separator used in the permit signature
    /// @return The domain seperator used in encoding of permit signature
    function DOMAIN_SEPARATOR() external view returns (bytes32);

    /// @notice Approve of a specific token ID for spending by spender via signature
    /// @param spender The account that is being approved
    /// @param tokenId The ID of the token that is being approved for spending
    /// @param deadline The deadline timestamp by which the call must be mined for the approve to work
    /// @param v Must produce valid secp256k1 signature from the holder along with `r` and `s`
    /// @param r Must produce valid secp256k1 signature from the holder along with `v` and `s`
    /// @param s Must produce valid secp256k1 signature from the holder along with `r` and `v`
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}

// src/hermes/tokens/HERMES.sol

/**
 * @title Hermes ERC20 token - Native token for the Hermes Incentive System 
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Native token for the Hermes Incentive System.
 *
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣶⣾⡿⢻⣿⣿⣿⣟⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣟⡿⣷⣿⣿⢤⣾⣿⣻⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣽⣿⣿⣿⣿⡿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣻⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡛⠛⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣴⣯⣛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⠟⠋⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣍⣻⣿⣿⣿⣿⣿⢧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⡏⠀⠀⣺⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣻⠾⠿⠻⣿⠇⣿⣿⡿⠟⢠⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⡇⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣻⣿⣧⣤⣽⣤⣯⣿⣾⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⡇⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡵⠾⢿⣿⡿⢟⣿⣿⣿⣿⣿⣿⡟⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡿⣿⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣼⣯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢳⠁⠀⠀⠈⠻⣿⣿⣿⣿⣿⡿⢋⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣸⢳⣿⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⢠⣿⣿⣿⣿⡿⣽⣿⣿⣿⣿⣿⡋⣰⡟⣸⣿⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢰⡟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠻⣿⣷⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣟⣫⣾⣿⣿⣿⣿⣿⡟⣱⠟⢰⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢀⡿⢱⣿⣿⢯⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣰⡇⠉⠉⠉⠁⠀⠀⠀⠀⠀⣠⠄⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⡋⣴⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢀⣾⢡⣿⣿⡿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢻⡇⡏⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣦⣤⣤⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢀⡾⢃⣾⣿⣿⠗⣮⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣼⡇⡇⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⡏⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⢀⡿⢃⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡁⠸⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⡇⢻⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⣠⡿⢁⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣷⠀⠀⠀⠀⠀⢀⣀⣠⣶⣿⣿⣿⣿⣿⣷⢟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣄⣀⣀⠀⠀⠀
 * ⠀⠀⣰⠟⣠⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⠋⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠸⣿⣿⣷⣶⣶⣶⣿⣿⣿⠿⠿⠿⢿⣿⣿⣿⣿⡾⣞⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣭⣟⣛⣛
 * ⢠⡾⠋⣴⣿⣿⣿⣿⡿⠟⠛⠯⣵⡦⣄⣸⣿⣿⣿⣿⣿⣿⡟⣿⣿⣿⣿⣿⣇⠈⢿⡈⢻⣿⢿⡋⠑⣷⠀⠀⠀⠀⠹⣿⣿⣿⣿⣽⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 * ⢟⣥⣾⣿⣿⣿⠋⠁⠀⠀⠀⠀⠀⠙⢮⣿⣿⢻⣿⣿⣿⣿⡇⠈⡿⣿⣿⣿⣿⣷⠤⠵⠶⠊⠑⣮⠶⠥⠀⠀⠀⠀⠀⢻⡎⠿⣿⣏⣿⣮⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 * ⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⢹⣿⢸⣿⣿⣿⣿⣿⠶⢅⣽⣿⣿⣿⣿⣷⣤⡴⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠘⣿⡀⠙⣿⣿⣿⣿⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 * ⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠀⡞⢻⡼⣿⣿⣿⣿⣿⣧⠀⠈⢿⣿⣿⣿⣿⣿⣿⣦⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣇⠀⠘⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 * ⣿⣿⡏⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠁⣼⠇⠈⣧⢹⣿⣿⣿⣿⣿⡆⠀⠀⠻⣧⠙⢿⣿⣿⣿⣿⣿⣿⣶⣤⣀⠀⠀⠀⣀⣠⠽⣆⠀⠘⣿⣿⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 * ⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⣠⣾⠁⢀⣿⠀⣴⡿⣿⢿⣿⣿⣿⣿⣿⡀⠀⠀⢙⣷⣄⣉⢿⣿⣿⣿⣿⣿⣿⣿⣷⣾⡛⢋⠀⠀⢻⣧⠀⠈⢿⣷⡙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⡛⠿
 * ⣿⠃⠀⠀⠀⠀⠀⠀⢀⡴⣹⠃⠀⣸⣹⠀⢻⢇⠘⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⢀⣻⣷⣄⡈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣠⠶⠚⠛⣦⣴⣦⡹⣿⣎⠻⣮⡛⠿⣿⣿⣿⣿⣿⣿⣷
 * ⠇⠀⠀⠀⠀⠀⢀⡴⠋⣰⠃⠀⠀⡇⣿⠀⣾⢸⡄⠈⢿⣿⣿⣿⣿⣿⣿⣦⣠⠟⠀⢸⡇⢙⡳⢦⣽⡛⠻⢿⣿⣿⣿⣿⣿⣶⣺⡆⢹⣿⣿⣿⣿⣿⣶⡈⠻⣦⡈⠻⢿⣿⣿⣿⣿
 * ⠀⠀⠀⠀⠀⣠⠏⠀⣰⠃⠀⠀⣸⠀⠸⡄⣿⠈⡇⠀⠀⢿⢿⣿⣿⣿⣿⣿⣯⣀⢰⡋⠀⣟⣉⣉⣿⣿⣶⣾⠉⢻⣿⣿⣿⣿⣿⡇⢸⣿⣿⠻⣿⣿⣟⢿⣷⡈⠻⣦⣠⣿⣿⣿⣿
 * ⠀⠀⠀⠀⡜⠁⠀⣰⠃⠀⠀⠀⡿⠀⠀⢣⡟⠀⡗⠀⠀⠸⡆⠙⢿⣿⡻⣿⣿⣿⣿⣗⡒⠚⠛⠓⠋⠉⢁⣈⣳⣾⠋⠙⢿⣿⣿⣿⣼⣿⣿⣇⠈⢿⣿⣧⣽⣿⣆⢨⣿⣿⣿⠋⠚
 * ⠀⠀⠀⣾⠁⠀⢰⠇⠀⠀⠀⠀⡇⠀⠀⣸⣷⡞⠁⠀⠀⠀⣧⠀⠀⢽⡿⣯⠙⣿⣿⣿⣿⣦⣴⠒⠒⠋⠉⠉⠀⠙⣦⡀⠈⢹⣿⣿⣿⢿⣿⣿⣆⠀⢙⣿⣿⣿⢻⣿⣿⣟⢧⠀⠀
 * ⠀⠀⠀⡇⠀⠉⡅⢾⡡⢖⣈⡀⣷⣶⠾⣟⠋⠙⢦⡀⠀⠀⢸⠀⠀⠈⠷⠾⢿⣇⠀⠙⠿⣿⣿⣷⣄⣤⡤⠴⠶⠚⠛⣿⠉⠉⠹⣿⣿⢸⣿⣿⣘⣶⣾⣿⣿⣿⣿⣿⡟⠈⠈⢷⣠
 * ⠀⠀⠀⣇⠀⠀⠇⠀⠀⠀⠐⠯⠿⡄⠀⣿⡷⠀⠀⠈⠓⢤⣈⣧⣀⣀⣀⣠⠤⠿⣿⠛⠛⠉⠻⣿⣿⣧⡀⠀⠀⠀⠀⠘⣧⠀⠀⢻⣿⢸⣿⣿⡟⢁⣿⣿⣇⣿⣿⡿⡆⣀⣴⣿⡟
 * ⠀⠀⠀⠘⠄⠀⠀⠀⠀⠀⠀⠀⠀⠳⣴⡗⠈⠀⠀⠀⠀⠀⠙⢦⣄⠀⠀⠀⠀⠀⠘⡆⠀⠀⠀⢻⣿⣿⣿⣄⠀⠀⠀⠀⢫⠃⠀⢸⣿⣿⣿⣿⣧⢸⣿⣿⢿⣿⡟⣸⣿⡿⠋⠀⣇
 */
contract HERMES is ERC20, Ownable {
    constructor(address _owner) ERC20("Hermes", "HERMES", 18) {
        _initializeOwner(_owner);
    }

    /*///////////////////////////////////////////////////////////////
                        ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Responsible for minting new hermes tokens.
     * @dev Checks if the sender is an allowed minter.
     * @param account account to mint tokens to.
     * @param amount amount of hermes to mint.
     */
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}

// src/rewards/interfaces/IFlywheelCore.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/FlywheelCore.sol)

/**
 * @title Flywheel Core Incentives Manager
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Flywheel is a general framework for managing token incentives.
 *          It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.
 *
 *          The Core contract maintains three important pieces of state:
 * the rewards index which determines how many rewards are owed per token per strategy. User indexes track how far behind the strategy they are to lazily calculate all catch-up rewards.
 * the accrued (unclaimed) rewards per user.
 * references to the booster and rewards module described below.
 *
 *          Core does not manage any tokens directly. The rewards module maintains token balances, and approves core to pull transfer them to users when they claim.
 *
 *          SECURITY NOTE: For maximum accuracy and to avoid exploits, rewards accrual should be notified atomically through the accrue hook.
 *          Accrue should be called any time tokens are transferred, minted, or burned.
 */
interface IFlywheelCore {
    /*///////////////////////////////////////////////////////////////
                        FLYWHEEL CORE STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The token to reward
    function rewardToken() external view returns (address);

    /// @notice append-only list of strategies added
    function allStrategies(uint256) external view returns (ERC20);

    /// @notice The strategy index in allStrategies
    function strategyIds(ERC20) external view returns (uint256);

    /// @notice the rewards contract for managing streams
    function flywheelRewards() external view returns (address);

    /// @notice optional booster module for calculating virtual balances on strategies
    function flywheelBooster() external view returns (IFlywheelBooster);

    /// @notice The accrued but not yet transferred rewards for each user
    function rewardsAccrued(address) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        ACCRUE/CLAIM LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice accrue rewards for a single user for msg.sender
     *   @param user the user to be accrued
     *   @return the cumulative amount of rewards accrued to user (including prior)
     */
    function accrue(address user) external returns (uint256);

    /**
     * @notice accrue rewards for a single user on a strategy
     *   @param strategy the strategy to accrue a user's rewards on
     *   @param user the user to be accrued
     *   @return the cumulative amount of rewards accrued to user (including prior)
     */
    function accrue(ERC20 strategy, address user) external returns (uint256);

    /**
     * @notice accrue rewards for a two users on a strategy
     *   @param strategy the strategy to accrue a user's rewards on
     *   @param user the first user to be accrued
     *   @param user the second user to be accrued
     *   @return the cumulative amount of rewards accrued to the first user (including prior)
     *   @return the cumulative amount of rewards accrued to the second user (including prior)
     */
    function accrue(ERC20 strategy, address user, address secondUser) external returns (uint256, uint256);

    /**
     * @notice claim rewards for a given user
     *   @param user the user claiming rewards
     *   @dev this function is public, and all rewards transfer to the user
     */
    function claimRewards(address user) external;

    /*///////////////////////////////////////////////////////////////
                          ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice initialize a new strategy
    function addStrategyForRewards(ERC20 strategy) external;

    /// @notice Returns all strategies added to flywheel.
    function getAllStrategies() external view returns (ERC20[] memory);

    /// @notice swap out the flywheel rewards contract
    function setFlywheelRewards(address newFlywheelRewards) external;

    /// @notice swap out the flywheel booster contract
    function setBooster(IFlywheelBooster newBooster) external;

    /*///////////////////////////////////////////////////////////////
                    INTERNAL ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice The last updated index per strategy
    function strategyIndex(ERC20) external view returns (uint256);

    /// @notice The last updated index per strategy
    function userIndex(ERC20, address) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a user's rewards accrue to a given strategy.
     *   @param strategy the updated rewards strategy
     *   @param user the user of the rewards
     *   @param rewardsDelta how many new rewards accrued to the user
     *   @param rewardsIndex the market index for rewards per token accrued
     */
    event AccrueRewards(ERC20 indexed strategy, address indexed user, uint256 rewardsDelta, uint256 rewardsIndex);

    /**
     * @notice Emitted when a user claims accrued rewards.
     *   @param user the user of the rewards
     *   @param amount the amount of rewards claimed
     */
    event ClaimRewards(address indexed user, uint256 amount);

    /**
     * @notice Emitted when a new strategy is added to flywheel by the admin
     *   @param newStrategy the new added strategy
     */
    event AddStrategy(address indexed newStrategy);

    /**
     * @notice Emitted when the rewards module changes
     *   @param newFlywheelRewards the new rewards module
     */
    event FlywheelRewardsUpdate(address indexed newFlywheelRewards);

    /**
     * @notice Emitted when the booster module changes
     *   @param newBooster the new booster module
     */
    event FlywheelBoosterUpdate(address indexed newBooster);
}

// src/erc-4626/ERC4626.sol

/// @title Minimal ERC4626 tokenized Vault implementation
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/mixins/ERC4626.sol)
abstract contract ERC4626 is ERC20, IERC4626 {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable asset;

    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        address(asset).safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    /// @inheritdoc IERC4626
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        address(asset).safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    /// @inheritdoc IERC4626
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        address(asset).safeTransfer(receiver, assets);
    }

    /// @inheritdoc IERC4626
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        // Check for rounding error since we round down in previewRedeem.
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");

        beforeWithdraw(assets, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        address(asset).safeTransfer(receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    /// @inheritdoc IERC4626
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDiv(supply, totalAssets());
    }

    /// @inheritdoc IERC4626
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDiv(totalAssets(), supply);
    }

    /// @inheritdoc IERC4626
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    /// @inheritdoc IERC4626
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    /// @inheritdoc IERC4626
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }

    /// @inheritdoc IERC4626
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }

    /// @inheritdoc IERC4626
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}

// src/erc-4626/ERC4626DepositOnly.sol

/// @title Minimal Deposit Only ERC4626 tokenized Vault implementation
/// @author Maia DAO (https://github.com/Maia-DAO)
abstract contract ERC4626DepositOnly is ERC20, IERC4626DepositOnly {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    ERC20 public immutable asset;

    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626DepositOnly
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        address(asset).safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    /// @inheritdoc IERC4626DepositOnly
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        address(asset).safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);

        afterDeposit(assets, shares);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626DepositOnly
    function totalAssets() public view virtual returns (uint256);

    /// @inheritdoc IERC4626DepositOnly
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? assets : assets.mulDiv(supply, totalAssets());
    }

    /// TODO: @inheritdoc IERC4626DepositOnly
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDiv(totalAssets(), supply);
    }

    /// @inheritdoc IERC4626DepositOnly
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }

    /// @inheritdoc IERC4626DepositOnly
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; // Saves an extra SLOAD if totalSupply is non-zero.

        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626DepositOnly
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626DepositOnly
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}

// src/rewards/depots/RewardsDepot.sol

/// @title Rewards Depot - Base contract for reward token storage
abstract contract RewardsDepot is IRewardsDepot {
    using SafeTransferLib for address;

    ///  @inheritdoc IRewardsDepot
    function getRewards() external virtual returns (uint256);

    /// @notice Transfer balance of token to rewards contract
    function transferRewards(address _asset, address _rewardsContract) internal returns (uint256 balance) {
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(_rewardsContract, balance);
    }

    modifier onlyFlywheelRewards() virtual;
}

// src/rewards/base/FlywheelCore.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/FlywheelCore.sol)

/// @title Flywheel Core Incentives Manager
abstract contract FlywheelCore_0 is Ownable, IFlywheelCore {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;

    /*///////////////////////////////////////////////////////////////
                        FLYWHEEL CORE STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelCore
    address public immutable override rewardToken;

    /// @inheritdoc IFlywheelCore
    ERC20[] public override allStrategies;

    /// @inheritdoc IFlywheelCore
    mapping(ERC20 => uint256) public override strategyIds;

    /// @inheritdoc IFlywheelCore
    address public override flywheelRewards;

    /// @inheritdoc IFlywheelCore
    IFlywheelBooster public override flywheelBooster;

    /**
     * @notice Flywheel Core constructor.
     *  @param _rewardToken the reward token
     *  @param _flywheelRewards the flywheel rewards contract
     *  @param _flywheelBooster the flywheel booster contract
     *  @param _owner the owner of this contract
     */
    constructor(address _rewardToken, address _flywheelRewards, IFlywheelBooster _flywheelBooster, address _owner) {
        _initializeOwner(_owner);
        rewardToken = _rewardToken;
        flywheelRewards = _flywheelRewards;
        flywheelBooster = _flywheelBooster;
    }

    /// @inheritdoc IFlywheelCore
    function getAllStrategies() external view returns (ERC20[] memory) {
        return allStrategies;
    }

    /*///////////////////////////////////////////////////////////////
                        ACCRUE/CLAIM LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelCore
    mapping(address => uint256) public override rewardsAccrued;

    /// @inheritdoc IFlywheelCore
    function accrue(address user) external returns (uint256) {
        return _accrue(ERC20(msg.sender), user);
    }

    /// @inheritdoc IFlywheelCore
    function accrue(ERC20 strategy, address user) external returns (uint256) {
        return _accrue(strategy, user);
    }

    function _accrue(ERC20 strategy, address user) internal returns (uint256) {
        uint256 index = strategyIndex[strategy];

        if (index == 0) return 0;

        index = accrueStrategy(strategy, index);
        return accrueUser(strategy, user, index);
    }

    /// @inheritdoc IFlywheelCore
    function accrue(ERC20 strategy, address user, address secondUser) public returns (uint256, uint256) {
        uint256 index = strategyIndex[strategy];

        if (index == 0) return (0, 0);

        index = accrueStrategy(strategy, index);
        return (accrueUser(strategy, user, index), accrueUser(strategy, secondUser, index));
    }

    /// @inheritdoc IFlywheelCore
    function claimRewards(address user) external {
        uint256 accrued = rewardsAccrued[user];

        if (accrued != 0) {
            rewardsAccrued[user] = 0;

            rewardToken.safeTransferFrom(address(flywheelRewards), user, accrued);

            emit ClaimRewards(user, accrued);
        }
    }

    /*///////////////////////////////////////////////////////////////
                          ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelCore
    function addStrategyForRewards(ERC20 strategy) external onlyOwner {
        _addStrategyForRewards(strategy);
    }

    function _addStrategyForRewards(ERC20 strategy) internal {
        require(strategyIndex[strategy] == 0, "strategy");
        strategyIndex[strategy] = ONE;

        strategyIds[strategy] = allStrategies.length;
        allStrategies.push(strategy);
        emit AddStrategy(address(strategy));
    }

    /// @inheritdoc IFlywheelCore
    function setFlywheelRewards(address newFlywheelRewards) external onlyOwner {
        uint256 oldRewardBalance = rewardToken.balanceOf(address(flywheelRewards));
        if (oldRewardBalance > 0) {
            rewardToken.safeTransferFrom(address(flywheelRewards), address(newFlywheelRewards), oldRewardBalance);
        }

        flywheelRewards = newFlywheelRewards;

        emit FlywheelRewardsUpdate(address(newFlywheelRewards));
    }

    /// @inheritdoc IFlywheelCore
    function setBooster(IFlywheelBooster newBooster) external onlyOwner {
        flywheelBooster = newBooster;

        emit FlywheelBoosterUpdate(address(newBooster));
    }

    /*///////////////////////////////////////////////////////////////
                    INTERNAL ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice the fixed point factor of flywheel
    uint256 private constant ONE = 1e18;

    /// @inheritdoc IFlywheelCore
    mapping(ERC20 => uint256) public strategyIndex;

    /// @inheritdoc IFlywheelCore
    mapping(ERC20 => mapping(address => uint256)) public userIndex;

    /// @notice accumulate global rewards on a strategy
    function accrueStrategy(ERC20 strategy, uint256 state) private returns (uint256 rewardsIndex) {
        // calculate accrued rewards through rewards module
        uint256 strategyRewardsAccrued = _getAccruedRewards(strategy);

        rewardsIndex = state;
        if (strategyRewardsAccrued > 0) {
            // use the booster or token supply to calculate the reward index denominator
            uint256 supplyTokens = address(flywheelBooster) != address(0)
                ? flywheelBooster.boostedTotalSupply(strategy)
                : strategy.totalSupply();

            uint224 deltaIndex;

            if (supplyTokens != 0) {
                deltaIndex = ((strategyRewardsAccrued * ONE) / supplyTokens).toUint224();
            }

            // accumulate rewards per token onto the index, multiplied by a fixed-point factor
            rewardsIndex += deltaIndex;
            strategyIndex[strategy] = rewardsIndex;
        }
    }

    /// @notice accumulate rewards on a strategy for a specific user
    function accrueUser(ERC20 strategy, address user, uint256 index) private returns (uint256) {
        // load indices
        uint256 supplierIndex = userIndex[strategy][user];

        // sync user index to global
        userIndex[strategy][user] = index;

        // if user hasn't yet accrued rewards, grant them interest from the strategy beginning if they have a balance
        // zero balances will have no effect other than syncing to global index
        if (supplierIndex == 0) {
            supplierIndex = ONE;
        }

        uint256 deltaIndex = index - supplierIndex;
        // use the booster or token balance to calculate reward balance multiplier
        uint256 supplierTokens = address(flywheelBooster) != address(0)
            ? flywheelBooster.boostedBalanceOf(strategy, user)
            : strategy.balanceOf(user);

        // accumulate rewards by multiplying user tokens by rewardsPerToken index and adding on unclaimed
        uint256 supplierDelta = (supplierTokens * deltaIndex) / ONE;
        uint256 supplierAccrued = rewardsAccrued[user] + supplierDelta;

        rewardsAccrued[user] = supplierAccrued;

        emit AccrueRewards(strategy, user, supplierDelta, index);

        return supplierAccrued;
    }

    function _getAccruedRewards(ERC20 strategy) internal virtual returns (uint256);
}

// src/rewards/interfaces/IFlywheelBribeRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/FlywheelDynamicRewards.sol)

/**
 * @title Flywheel Accumulated Bribes Reward Stream
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Distributes rewards for allocation to voters at the end of each epoch in accordance to votes.
 */
interface IFlywheelBribeRewards is IFlywheelAcummulatedRewards {
    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice RewardsDepot for each strategy
    function rewardsDepots(ERC20) external view returns (RewardsDepot);

    /**
     * @notice swap out the flywheel rewards contract
     *  @param rewardsDepot the new rewards depot to set
     */
    function setRewardsDepot(RewardsDepot rewardsDepot) external;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice emitted when a new rewards depot is added
     *  @param strategy the strategy to add a rewards depot for
     *  @param rewardsDepot the rewards depot to add
     */
    event AddRewardsDepot(address indexed strategy, RewardsDepot indexed rewardsDepot);
}

// lib/v3-core/contracts/interfaces/IUniswapV3Pool.sol

/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolErrors,
    IUniswapV3PoolEvents
{

}

// src/rewards/depots/MultiRewardsDepot.sol

/// @title Multiple Rewards Depot - Contract for multiple reward token storage
contract MultiRewardsDepot is Ownable, RewardsDepot, IMultiRewardsDepot {
    /*///////////////////////////////////////////////////////////////
                        REWARDS DEPOT STATE
    //////////////////////////////////////////////////////////////*/

    /// @dev _assets[rewardsContracts] => asset (reward Token)
    mapping(address => address) private _assets;

    /// @notice _isRewardsContracts[rewardsContracts] => true/false
    mapping(address => bool) private _isRewardsContract;

    /// @notice _isAsset[asset] => true/false
    mapping(address => bool) private _isAsset;

    /**
     * @notice MultiRewardsDepot constructor
     *  @param _owner owner of the contract
     */
    constructor(address _owner) {
        _initializeOwner(_owner);
    }

    /*///////////////////////////////////////////////////////////////
                        GET REWARDS LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IMultiRewardsDepot
    function getRewards() external override(RewardsDepot, IMultiRewardsDepot) onlyFlywheelRewards returns (uint256) {
        return transferRewards(_assets[msg.sender], msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IMultiRewardsDepot
    function addAsset(address rewardsContract, address asset) external onlyOwner {
        if (_isAsset[asset] || _isRewardsContract[rewardsContract]) revert ErrorAddingAsset();
        _isAsset[asset] = true;
        _isRewardsContract[rewardsContract] = true;
        _assets[rewardsContract] = asset;

        emit AssetAdded(rewardsContract, asset);
    }

    /// @inheritdoc IMultiRewardsDepot
    function removeAsset(address rewardsContract) external onlyOwner {
        if (!_isRewardsContract[rewardsContract]) revert ErrorRemovingAsset();

        emit AssetRemoved(rewardsContract, _assets[rewardsContract]);

        delete _isAsset[_assets[rewardsContract]];
        delete _isRewardsContract[rewardsContract];
        delete _assets[rewardsContract];
    }

    /*///////////////////////////////////////////////////////////////
                                MODIFIERS   
    //////////////////////////////////////////////////////////////*/

    /// @notice modifier to check if msg.sender is a rewards contract
    modifier onlyFlywheelRewards() override {
        if (!_isRewardsContract[msg.sender]) revert FlywheelRewardsError();
        _;
    }
}

// src/rewards/interfaces/IFlywheelRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/BaseFlywheelRewards.sol)

/**
 * @title Rewards Module for Flywheel
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Flywheel is a general framework for managing token incentives.
 *          It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.
 *
 *          The Rewards module is responsible for:
 *             - determining the ongoing reward amounts to entire strategies (core handles the logic for dividing among users)
 *             - actually holding rewards that are yet to be claimed
 *
 *          The reward stream can follow arbitrary logic as long as the reward amount passed to flywheel core has been sent to this contract.
 *
 *          Different module strategies include:
 *             - a static reward rate per second
 *             - a decaying reward rate
 *             - a dynamic just-in-time reward stream
 *             - liquid governance reward delegation (Curve Gauge style)
 *
 *          SECURITY NOTE: The rewards strategy should be smooth and continuous, to prevent gaming the reward distribution by frontrunning.
 */
interface IFlywheelRewards {
    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice returns the reward token associated with flywheel core.
    function rewardToken() external view returns (address);

    /// @notice return the flywheel core address
    function flywheel() external view returns (FlywheelCore_0);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when msg.sender is not the flywheel
    error FlywheelError();
}

// src/rewards/base/BaseFlywheelRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/BaseFlywheelRewards.sol)

/**
 * @title Flywheel Reward Module - Base contract for reward token distribution
 *  @notice Determines how many rewards accrue to each strategy globally over a given time period.
 *  @dev approves the flywheel core for the reward token to allow balances to be managed by the module but claimed from core.
 */
abstract contract BaseFlywheelRewards is IFlywheelRewards {
    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelRewards
    address public immutable override rewardToken;

    /// @inheritdoc IFlywheelRewards
    FlywheelCore_0 public immutable override flywheel;

    constructor(FlywheelCore_0 _flywheel) {
        flywheel = _flywheel;
        address _rewardToken = _flywheel.rewardToken();
        rewardToken = _rewardToken;

        _rewardToken.safeApprove(address(_flywheel), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyFlywheel() {
        if (msg.sender != address(flywheel)) revert FlywheelError();
        _;
    }
}

// lib/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol

/// @title Non-fungible token for positions
/// @notice Wraps Uniswap V3 positions in a non-fungible token interface which allows for them to be transferred
/// and authorized.
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{
    /// @notice Emitted when liquidity is increased for a position NFT
    /// @dev Also emitted when a token is minted
    /// @param tokenId The ID of the token for which liquidity was increased
    /// @param liquidity The amount by which liquidity for the NFT position was increased
    /// @param amount0 The amount of token0 that was paid for the increase in liquidity
    /// @param amount1 The amount of token1 that was paid for the increase in liquidity
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    /// @notice Emitted when liquidity is decreased for a position NFT
    /// @param tokenId The ID of the token for which liquidity was decreased
    /// @param liquidity The amount by which liquidity for the NFT position was decreased
    /// @param amount0 The amount of token0 that was accounted for the decrease in liquidity
    /// @param amount1 The amount of token1 that was accounted for the decrease in liquidity
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    /// @notice Emitted when tokens are collected for a position NFT
    /// @dev The amounts reported may not be exactly equivalent to the amounts transferred, due to rounding behavior
    /// @param tokenId The ID of the token for which underlying tokens were collected
    /// @param recipient The address of the account that received the collected tokens
    /// @param amount0 The amount of token0 owed to the position that was collected
    /// @param amount1 The amount of token1 owed to the position that was collected
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);

    /// @notice Returns the position information associated with a given token ID.
    /// @dev Throws if the token ID is not valid.
    /// @param tokenId The ID of the token that represents the position
    /// @return nonce The nonce for permits
    /// @return operator The address that is approved for spending
    /// @return token0 The address of the token0 for a specific pool
    /// @return token1 The address of the token1 for a specific pool
    /// @return fee The fee associated with the pool
    /// @return tickLower The lower end of the tick range for the position
    /// @return tickUpper The higher end of the tick range for the position
    /// @return liquidity The liquidity of the position
    /// @return feeGrowthInside0LastX128 The fee growth of token0 as of the last action on the individual position
    /// @return feeGrowthInside1LastX128 The fee growth of token1 as of the last action on the individual position
    /// @return tokensOwed0 The uncollected amount of token0 owed to the position as of the last computation
    /// @return tokensOwed1 The uncollected amount of token1 owed to the position as of the last computation
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    /// @notice Creates a new position wrapped in a NFT
    /// @dev Call this when the pool does exist and is initialized. Note that if the pool is created but not initialized
    /// a method does not exist, i.e. the pool is assumed to be initialized.
    /// @param params The params necessary to mint a position, encoded as `MintParams` in calldata
    /// @return tokenId The ID of the token that represents the minted position
    /// @return liquidity The amount of liquidity for this position
    /// @return amount0 The amount of token0
    /// @return amount1 The amount of token1
    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Increases the amount of liquidity in a position, with tokens paid by the `msg.sender`
    /// @param params tokenId The ID of the token for which liquidity is being increased,
    /// amount0Desired The desired amount of token0 to be spent,
    /// amount1Desired The desired amount of token1 to be spent,
    /// amount0Min The minimum amount of token0 to spend, which serves as a slippage check,
    /// amount1Min The minimum amount of token1 to spend, which serves as a slippage check,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return liquidity The new liquidity amount as a result of the increase
    /// @return amount0 The amount of token0 to acheive resulting liquidity
    /// @return amount1 The amount of token1 to acheive resulting liquidity
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    /// @notice Decreases the amount of liquidity in a position and accounts it to the position
    /// @param params tokenId The ID of the token for which liquidity is being decreased,
    /// amount The amount by which liquidity will be decreased,
    /// amount0Min The minimum amount of token0 that should be accounted for the burned liquidity,
    /// amount1Min The minimum amount of token1 that should be accounted for the burned liquidity,
    /// deadline The time by which the transaction must be included to effect the change
    /// @return amount0 The amount of token0 accounted to the position's tokens owed
    /// @return amount1 The amount of token1 accounted to the position's tokens owed
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    /// @notice Collects up to a maximum amount of fees owed to a specific position to the recipient
    /// @param params tokenId The ID of the NFT for which tokens are being collected,
    /// recipient The account that should receive the tokens,
    /// amount0Max The maximum amount of token0 to collect,
    /// amount1Max The maximum amount of token1 to collect
    /// @return amount0 The amount of fees collected in token0
    /// @return amount1 The amount of fees collected in token1
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    /// @notice Burns a token ID, which deletes it from the NFT contract. The token must have 0 liquidity and all tokens
    /// must be collected first.
    /// @param tokenId The ID of the token that is being burned
    function burn(uint256 tokenId) external payable;
}

// src/rewards/FlywheelCoreStrategy.sol

/**
 * @title Flywheel Core Incentives Manager
 *  @notice Flywheel is a general framework for managing token incentives.
 *          It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.
 *
 *          The Core contract maintains three important pieces of state:
 * the rewards index which determines how many rewards are owed per token per strategy. User indexes track how far behind the strategy they are to lazily calculate all catch-up rewards.
 * the accrued (unclaimed) rewards per user.
 * references to the booster and rewards module described below.
 *
 *          Core does not manage any tokens directly. The rewards module maintains token balances, and approves core to pull transfer them to users when they claim.
 *
 *          SECURITY NOTE: For maximum accuracy and to avoid exploits, rewards accrual should be notified atomically through the accrue hook.
 *          Accrue should be called any time tokens are transferred, minted, or burned.
 */
contract FlywheelCore_1 is FlywheelCore_0 {
    constructor(
        address _rewardToken,
        IFlywheelRewards _flywheelRewards,
        IFlywheelBooster _flywheelBooster,
        address _owner
    ) FlywheelCore_0(_rewardToken, address(_flywheelRewards), _flywheelBooster, _owner) {}

    function _getAccruedRewards(ERC20 strategy) internal override returns (uint256) {
        return IFlywheelAcummulatedRewards(flywheelRewards).getAccruedRewards(strategy);
    }
}

// src/rewards/rewards/FlywheelAcummulatedRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/FlywheelDynamicRewards.sol)

///  @title Flywheel Accumulated Rewards.
abstract contract FlywheelAcummulatedRewards is BaseFlywheelRewards, IFlywheelAcummulatedRewards {
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelAcummulatedRewards
    uint256 public immutable override rewardsCycleLength;

    /// @inheritdoc IFlywheelAcummulatedRewards
    uint256 public override endCycle;

    /**
     * @notice Flywheel Instant Rewards constructor.
     *  @param _flywheel flywheel core contract
     *  @param _rewardsCycleLength the length of a rewards cycle in seconds
     */
    constructor(FlywheelCore_0 _flywheel, uint256 _rewardsCycleLength) BaseFlywheelRewards(_flywheel) {
        rewardsCycleLength = _rewardsCycleLength;
    }

    /*//////////////////////////////////////////////////////////////
                        FLYWHEEL CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelAcummulatedRewards
    function getAccruedRewards(ERC20 strategy) external override onlyFlywheel returns (uint256 amount) {
        uint32 timestamp = block.timestamp.toUint32();

        // if cycle has ended, reset cycle and transfer all available
        if (timestamp >= endCycle) {
            amount = getNextCycleRewards(strategy);

            // reset for next cycle
            uint256 newEndCycle = ((timestamp + rewardsCycleLength) / rewardsCycleLength) * rewardsCycleLength;
            endCycle = newEndCycle;

            emit NewRewardsCycle(timestamp, newEndCycle, amount);
        } else {
            amount = 0;
        }
    }

    /// @notice function to get the next cycle's rewards amount
    function getNextCycleRewards(ERC20 strategy) internal virtual returns (uint256);
}

// src/rewards/rewards/FlywheelBribeRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/FlywheelDynamicRewards.sol)

/// @title Flywheel Accumulated Bribes Reward Stream
contract FlywheelBribeRewards is FlywheelAcummulatedRewards, IFlywheelBribeRewards {
    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelBribeRewards
    mapping(ERC20 => RewardsDepot) public override rewardsDepots;

    /**
     * @notice Flywheel Accumulated Bribes Reward Stream constructor.
     *  @param _flywheel flywheel core contract
     *  @param _rewardsCycleLength the length of a rewards cycle in seconds
     */
    constructor(FlywheelCore_0 _flywheel, uint256 _rewardsCycleLength)
        FlywheelAcummulatedRewards(_flywheel, _rewardsCycleLength)
    {}

    /// @notice calculate and transfer accrued rewards to flywheel core
    function getNextCycleRewards(ERC20 strategy) internal override returns (uint256) {
        return rewardsDepots[strategy].getRewards();
    }

    /// @inheritdoc IFlywheelBribeRewards
    function setRewardsDepot(RewardsDepot rewardsDepot) external {
        /// @dev Anyone can call this, whitelisting is handled in FlywheelCore
        rewardsDepots[ERC20(msg.sender)] = rewardsDepot;

        emit AddRewardsDepot(msg.sender, rewardsDepot);
    }
}

// src/uni-v3-staker/libraries/NFTPositionInfo.sol

// Rewards logic inspired by Uniswap V3 Contracts (Uniswap/v3-staker/contracts/libraries/NFTPositionInfo.sol)

// TODO: The INIT_CODE_HASH needs to be updated to the values that are live on the chain of it's deployment.

/// @title Encapsulates the logic for getting info about a NFT token ID
library NFTPositionInfo {
    /// @param factory The address of the Uniswap V3 Factory used in computing the pool address
    /// @param nonfungiblePositionManager The address of the nonfungible position manager to query
    /// @param tokenId The unique identifier of an Uniswap V3 LP token
    /// @return pool The address of the Uniswap V3 pool
    /// @return tickLower The lower tick of the Uniswap V3 position
    /// @return tickUpper The upper tick of the Uniswap V3 position
    /// @return liquidity The amount of liquidity staked
    function getPositionInfo(
        IUniswapV3Factory factory,
        INonfungiblePositionManager nonfungiblePositionManager,
        uint256 tokenId
    ) internal view returns (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) {
        address token0;
        address token1;
        uint24 fee;
        /// @dev This line causes stack too deep when compiling with the optimizer turned off.
        (,, token0, token1, fee, tickLower, tickUpper, liquidity,,,,) = nonfungiblePositionManager.positions(tokenId);

        pool = IUniswapV3Pool(
            PoolAddress.computeAddress(
                address(factory), PoolAddress.PoolKey({token0: token0, token1: token1, fee: fee})
            )
        );
    }
}


// src/erc-20/ERC20MultiVotes.sol

// Voting logic inspired by OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Votes.sol)

/// @title ERC20 Multi-Delegation Voting contract
abstract contract ERC20MultiVotes is ERC20, Ownable, IERC20MultiVotes {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeCastLib for *;

    /*///////////////////////////////////////////////////////////////
                        VOTE CALCULATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice votes checkpoint list per user.
    mapping(address => Checkpoint[]) private _checkpoints;

    /// @inheritdoc IERC20MultiVotes
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoint memory) {
        return _checkpoints[account][pos];
    }

    /// @inheritdoc IERC20MultiVotes
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return _checkpoints[account].length.toUint32();
    }

    /// @inheritdoc IERC20MultiVotes
    function freeVotes(address account) public view virtual returns (uint256) {
        return balanceOf[account] - userDelegatedVotes[account];
    }

    /// @inheritdoc IERC20MultiVotes
    function getVotes(address account) public view virtual returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
    }

    /// @inheritdoc IERC20MultiVotes
    function userUnusedVotes(address user) public view virtual returns (uint256) {
        return getVotes(user);
    }

    /// @inheritdoc IERC20MultiVotes
    function getPriorVotes(address account, uint256 blockNumber) public view virtual returns (uint256) {
        if (blockNumber >= block.number) revert BlockError();
        return _checkpointsLookup(_checkpoints[account], blockNumber);
    }

    /// @dev Lookup a value in a list of (sorted) checkpoints.
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {
        // We run a binary search to look for the earliest checkpoint taken after `blockNumber`.
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        return high == 0 ? 0 : ckpts[high - 1].votes;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /*///////////////////////////////////////////////////////////////
                        ADMIN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20MultiVotes
    uint256 public override maxDelegates;

    /// @inheritdoc IERC20MultiVotes
    mapping(address => bool) public override canContractExceedMaxDelegates;

    /// @inheritdoc IERC20MultiVotes
    function setMaxDelegates(uint256 newMax) external onlyOwner {
        uint256 oldMax = maxDelegates;
        maxDelegates = newMax;

        emit MaxDelegatesUpdate(oldMax, newMax);
    }

    /// @inheritdoc IERC20MultiVotes
    function setContractExceedMaxDelegates(address account, bool canExceedMax) external onlyOwner {
        if (canExceedMax && account.code.length == 0) revert Errors.NonContractError(); // can only approve contracts

        canContractExceedMaxDelegates[account] = canExceedMax;

        emit CanContractExceedMaxDelegatesUpdate(account, canExceedMax);
    }

    /*///////////////////////////////////////////////////////////////
                        DELEGATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice How many votes a user has delegated to a delegatee.
    mapping(address => mapping(address => uint256)) private _delegatesVotesCount;

    /// @notice How many votes a user has delegated to him.
    mapping(address => uint256) public userDelegatedVotes;

    /// @notice The delegatees of a user.
    mapping(address => EnumerableSet.AddressSet) private _delegates;

    /// @inheritdoc IERC20MultiVotes
    function delegatesVotesCount(address delegator, address delegatee) public view virtual returns (uint256) {
        return _delegatesVotesCount[delegator][delegatee];
    }

    /// @inheritdoc IERC20MultiVotes
    function delegates(address delegator) public view returns (address[] memory) {
        return _delegates[delegator].values();
    }

    /// @inheritdoc IERC20MultiVotes
    function delegateCount(address delegator) public view returns (uint256) {
        return _delegates[delegator].length();
    }

    /// @inheritdoc IERC20MultiVotes
    function incrementDelegation(address delegatee, uint256 amount) public virtual {
        _incrementDelegation(msg.sender, delegatee, amount);
    }

    /// @inheritdoc IERC20MultiVotes
    function undelegate(address delegatee, uint256 amount) public virtual {
        _undelegate(msg.sender, delegatee, amount);
    }

    /// @inheritdoc IERC20MultiVotes
    function delegate(address newDelegatee) external virtual {
        _delegate(msg.sender, newDelegatee);
    }

    /**
     * @notice Delegates all votes from `delegator` to `delegatee`
     * @dev Reverts if delegateCount > 1
     * @param delegator The address to delegate votes from
     * @param newDelegatee The address to delegate votes to
     */
    function _delegate(address delegator, address newDelegatee) internal virtual {
        uint256 count = delegateCount(delegator);

        // undefined behavior for delegateCount > 1
        if (count > 1) revert DelegationError();

        address oldDelegatee;
        // if already delegated, undelegate first
        if (count == 1) {
            oldDelegatee = _delegates[delegator].at(0);
            _undelegate(delegator, oldDelegatee, _delegatesVotesCount[delegator][oldDelegatee]);
        }

        // redelegate only if newDelegatee is not empty
        if (newDelegatee != address(0)) {
            _incrementDelegation(delegator, newDelegatee, freeVotes(delegator));
        }
        emit DelegateChanged(delegator, oldDelegatee, newDelegatee);
    }

    /**
     * @notice Delegates votes from `delegator` to `delegatee`
     * @dev Reverts if delegator is not approved and exceeds maxDelegates
     * @param delegator The address to delegate votes from
     * @param delegatee The address to delegate votes to
     * @param amount The amount of votes to delegate
     */
    function _incrementDelegation(address delegator, address delegatee, uint256 amount) internal virtual {
        // Require freeVotes exceed the delegation size
        uint256 free = freeVotes(delegator);
        if (delegatee == address(0) || free < amount || amount == 0) revert DelegationError();

        bool newDelegate = _delegates[delegator].add(delegatee); // idempotent add
        if (newDelegate && delegateCount(delegator) > maxDelegates && !canContractExceedMaxDelegates[delegator]) {
            // if is a new delegate, exceeds max and is not approved to exceed, revert
            revert DelegationError();
        }

        _delegatesVotesCount[delegator][delegatee] += amount;
        userDelegatedVotes[delegator] += amount;

        emit Delegation(delegator, delegatee, amount);
        _writeCheckpoint(delegatee, _add, amount);
    }

    /**
     * @notice Undelegates votes from `delegator` to `delegatee`
     * @dev Reverts if delegatee does not have enough free votes
     * @param delegator The address to undelegate votes from
     * @param delegatee The address to undelegate votes to
     * @param amount The amount of votes to undelegate
     */
    function _undelegate(address delegator, address delegatee, uint256 amount) internal virtual {
        /**
         * @dev delegatee needs to have sufficient free votes for delegator to undelegate.
         *         Delegatee needs to be trusted, can be either a contract or an EOA.
         *         If delegatee does not have any free votes and doesn't change their vote delegator won't be able to undelegate.
         *         If it is a contract, a possible safety measure is to have an emergency clear votes.
         */
        if (userUnusedVotes(delegatee) < amount) revert UndelegationVoteError();

        uint256 newDelegates = _delegatesVotesCount[delegator][delegatee] - amount;

        if (newDelegates == 0) {
            require(_delegates[delegator].remove(delegatee));
        }

        _delegatesVotesCount[delegator][delegatee] = newDelegates;
        userDelegatedVotes[delegator] -= amount;

        emit Undelegation(delegator, delegatee, amount);
        _writeCheckpoint(delegatee, _subtract, amount);
    }

    /**
     * @notice Writes a checkpoint for `delegatee` with `delta` votes
     * @param delegatee The address to write a checkpoint for
     * @param op The operation to perform on the checkpoint
     * @param delta The difference in votes to write
     */
    function _writeCheckpoint(address delegatee, function(uint256, uint256) view returns (uint256) op, uint256 delta)
        private
    {
        Checkpoint[] storage ckpts = _checkpoints[delegatee];

        uint256 pos = ckpts.length;
        uint256 oldWeight = pos == 0 ? 0 : ckpts[pos - 1].votes;
        uint256 newWeight = op(oldWeight, delta);

        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].votes = newWeight.toUint224();
        } else {
            ckpts.push(Checkpoint({fromBlock: block.number.toUint32(), votes: newWeight.toUint224()}));
        }
        emit DelegateVotesChanged(delegatee, oldWeight, newWeight);
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }

    /*///////////////////////////////////////////////////////////////
                             ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /// NOTE: any "removal" of tokens from a user requires freeVotes(user) < amount.
    /// _decrementVotesUntilFree is called as a greedy algorithm to free up votes.
    /// It may be more gas efficient to free weight before burning or transferring tokens.

    /**
     * @notice Burns `amount` of tokens from `from` address.
     * @dev Frees votes with a greedy algorithm if needed to burn tokens
     * @param from The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function _burn(address from, uint256 amount) internal virtual override {
        _decrementVotesUntilFree(from, amount);
        super._burn(from, amount);
    }

    /**
     * @notice Transfers `amount` of tokens from `msg.sender` to `to` address.
     * @dev Frees votes with a greedy algorithm if needed to burn tokens
     * @param to the address to transfer to.
     * @param amount the amount to transfer.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _decrementVotesUntilFree(msg.sender, amount);
        return super.transfer(to, amount);
    }

    /**
     * @notice Transfers `amount` of tokens from `from` address to `to` address.
     * @dev Frees votes with a greedy algorithm if needed to burn tokens
     * @param from the address to transfer from.
     * @param to the address to transfer to.
     * @param amount the amount to transfer.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _decrementVotesUntilFree(from, amount);
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice A greedy algorithm for freeing votes before a token burn/transfer
     * @dev Frees up entire delegates, so likely will free more than `votes`
     * @param user The address to free votes from.
     * @param votes The amount of votes to free.
     */
    function _decrementVotesUntilFree(address user, uint256 votes) internal {
        uint256 userFreeVotes = freeVotes(user);

        // early return if already free
        if (userFreeVotes >= votes) return;

        // cache total for batch updates
        uint256 totalFreed;

        // Loop through all delegates
        address[] memory delegateList = _delegates[user].values();

        // Free gauges through the entire list or until underweight
        uint256 size = delegateList.length;
        for (uint256 i = 0; i < size && (userFreeVotes + totalFreed) < votes; i++) {
            address delegatee = delegateList[i];
            uint256 delegateVotes = _delegatesVotesCount[user][delegatee];
            // Minimum of votes delegated to delegatee and unused votes of delegatee
            uint256 votesToFree = FixedPointMathLib.min(delegateVotes, userUnusedVotes(delegatee));
            // Skip if votesToFree is zero
            if (votesToFree != 0) {
                totalFreed += votesToFree;

                if (delegateVotes == votesToFree) {
                    // If all votes are freed, remove delegatee from list
                    require(_delegates[user].remove(delegatee)); // Remove from set. Should never fail.
                    _delegatesVotesCount[user][delegatee] = 0;
                } else {
                    // If not all votes are freed, update the votes count
                    _delegatesVotesCount[user][delegatee] -= votesToFree;
                }

                _writeCheckpoint(delegatee, _subtract, votesToFree);
                emit Undelegation(user, delegatee, votesToFree);
            }
        }

        if ((userFreeVotes + totalFreed) < votes) revert UndelegationVoteError();

        userDelegatedVotes[user] -= totalFreed;
    }

    /*///////////////////////////////////////////////////////////////
                             EIP-712 LOGIC
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp <= expiry, "ERC20MultiVotes: signature expired");
        address signer = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01", DOMAIN_SEPARATOR(), keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry))
                )
            ),
            v,
            r,
            s
        );
        require(nonce == nonces[signer]++, "ERC20MultiVotes: invalid nonce");
        require(signer != address(0));
        _delegate(signer, delegatee);
    }
}

// src/erc-20/ERC20Gauges.sol

// Gauge weight logic inspired by Tribe DAO Contracts (flywheel-v2/src/token/ERC20Gauges.sol)

/// @title  An ERC20 with an embedded "Gauge" style vote with liquid weights
abstract contract ERC20Gauges is ERC20MultiVotes, ReentrancyGuard, IERC20Gauges {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeCastLib for *;

    /**
     * @notice Construct a new ERC20Gauges
     * @param _gaugeCycleLength the length of a gauge cycle in seconds
     * @param _incrementFreezeWindow the length of the grace period in seconds
     */
    constructor(uint32 _gaugeCycleLength, uint32 _incrementFreezeWindow) {
        if (_incrementFreezeWindow >= _gaugeCycleLength) revert IncrementFreezeError();
        gaugeCycleLength = _gaugeCycleLength;
        incrementFreezeWindow = _incrementFreezeWindow;
    }

    /*///////////////////////////////////////////////////////////////
                            GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Gauges
    uint32 public immutable override gaugeCycleLength;

    /// @inheritdoc IERC20Gauges
    uint32 public immutable override incrementFreezeWindow;

    /// @inheritdoc IERC20Gauges
    mapping(address => mapping(address => uint112)) public override getUserGaugeWeight;

    /// @inheritdoc IERC20Gauges
    /// @dev NOTE this may contain weights for deprecated gauges
    mapping(address => uint112) public override getUserWeight;

    /// @notice a mapping from a gauge to the total weight allocated to it
    /// @dev NOTE this may contain weights for deprecated gauges
    mapping(address => Weight) internal _getGaugeWeight;

    /// @notice the total global allocated weight ONLY of live gauges
    Weight internal _totalWeight;

    mapping(address => EnumerableSet.AddressSet) internal _userGauges;

    EnumerableSet.AddressSet internal _gauges;

    // Store deprecated gauges in case a user needs to free dead weight
    EnumerableSet.AddressSet internal _deprecatedGauges;

    /*///////////////////////////////////////////////////////////////
                              VIEW HELPERS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Gauges
    function getGaugeCycleEnd() external view returns (uint32) {
        return _getGaugeCycleEnd();
    }

    function _getGaugeCycleEnd() internal view returns (uint32) {
        uint32 nowPlusOneCycle = block.timestamp.toUint32() + gaugeCycleLength;
        unchecked {
            return (nowPlusOneCycle / gaugeCycleLength) * gaugeCycleLength; // cannot divide by zero and always <= nowPlusOneCycle so no overflow
        }
    }

    /// @inheritdoc IERC20Gauges
    function getGaugeWeight(address gauge) external view returns (uint112) {
        return _getGaugeWeight[gauge].currentWeight;
    }

    /// @inheritdoc IERC20Gauges
    function getStoredGaugeWeight(address gauge) external view returns (uint112) {
        if (_deprecatedGauges.contains(gauge)) return 0;
        return _getStoredWeight(_getGaugeWeight[gauge], _getGaugeCycleEnd());
    }

    function _getStoredWeight(Weight storage gaugeWeight, uint32 currentCycle) internal view returns (uint112) {
        return gaugeWeight.currentCycle < currentCycle ? gaugeWeight.currentWeight : gaugeWeight.storedWeight;
    }

    /// @inheritdoc IERC20Gauges
    function totalWeight() external view returns (uint112) {
        return _totalWeight.currentWeight;
    }

    /// @inheritdoc IERC20Gauges
    function storedTotalWeight() external view returns (uint112) {
        return _getStoredWeight(_totalWeight, _getGaugeCycleEnd());
    }

    /// @inheritdoc IERC20Gauges
    function gauges() external view returns (address[] memory) {
        return _gauges.values();
    }

    /// @inheritdoc IERC20Gauges
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _gauges.at(offset + i); // will revert if out of bounds
                i++;
            }
        }
    }

    /// @inheritdoc IERC20Gauges
    function isGauge(address gauge) external view returns (bool) {
        return _gauges.contains(gauge) && !_deprecatedGauges.contains(gauge);
    }

    /// @inheritdoc IERC20Gauges
    function numGauges() external view returns (uint256) {
        return _gauges.length();
    }

    /// @inheritdoc IERC20Gauges
    function deprecatedGauges() external view returns (address[] memory) {
        return _deprecatedGauges.values();
    }

    /// @inheritdoc IERC20Gauges
    function numDeprecatedGauges() external view returns (uint256) {
        return _deprecatedGauges.length();
    }

    /// @inheritdoc IERC20Gauges
    function userGauges(address user) external view returns (address[] memory) {
        return _userGauges[user].values();
    }

    /// @inheritdoc IERC20Gauges
    function isUserGauge(address user, address gauge) external view returns (bool) {
        return _userGauges[user].contains(gauge);
    }

    /// @inheritdoc IERC20Gauges
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _userGauges[user].at(offset + i); // will revert if out of bounds
                i++;
            }
        }
    }

    /// @inheritdoc IERC20Gauges
    function numUserGauges(address user) external view returns (uint256) {
        return _userGauges[user].length();
    }

    /// @inheritdoc ERC20MultiVotes
    function userUnusedVotes(address user) public view override returns (uint256) {
        return super.userUnusedVotes(user) - getUserWeight[user];
    }

    /// @inheritdoc IERC20Gauges
    function calculateGaugeAllocation(address gauge, uint256 quantity) external view returns (uint256) {
        if (_deprecatedGauges.contains(gauge)) return 0;
        uint32 currentCycle = _getGaugeCycleEnd();

        uint112 total = _getStoredWeight(_totalWeight, currentCycle);
        uint112 weight = _getStoredWeight(_getGaugeWeight[gauge], currentCycle);
        return (quantity * weight) / total;
    }

    /*///////////////////////////////////////////////////////////////
                        USER GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Gauges
    function incrementGauge(address gauge, uint112 weight) external nonReentrant returns (uint112 newUserWeight) {
        uint32 currentCycle = _getGaugeCycleEnd();
        _incrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
        return _incrementUserAndGlobalWeights(msg.sender, weight, currentCycle);
    }

    /**
     * @notice Increment the weight of a gauge for a user
     * @dev This function calls accrueBribes for the gauge to ensure the gauge handles the balance change.
     * @param user the user to increment the weight of
     * @param gauge the gauge to increment the weight of
     * @param weight the weight to increment by
     * @param cycle the cycle to increment the weight for
     */
    function _incrementGaugeWeight(address user, address gauge, uint112 weight, uint32 cycle) internal {
        if (!_gauges.contains(gauge) || _deprecatedGauges.contains(gauge)) revert InvalidGaugeError();
        unchecked {
            if (cycle - block.timestamp <= incrementFreezeWindow) revert IncrementFreezeError();
        }

        IBaseV2Gauge(gauge).accrueBribes(user);

        bool added = _userGauges[user].add(gauge); // idempotent add
        if (added && _userGauges[user].length() > maxGauges && !canContractExceedMaxGauges[user]) {
            revert MaxGaugeError();
        }

        getUserGaugeWeight[user][gauge] += weight;

        _writeGaugeWeight(_getGaugeWeight[gauge], _add112, weight, cycle);

        emit IncrementGaugeWeight(user, gauge, weight, cycle);
    }

    /**
     * @notice Increment the weight of a gauge for a user and the total weight
     * @param user the user to increment the weight of
     * @param weight the weight to increment by
     * @param cycle the cycle to increment the weight for
     * @return newUserWeight the new user's weight
     */
    function _incrementUserAndGlobalWeights(address user, uint112 weight, uint32 cycle)
        internal
        returns (uint112 newUserWeight)
    {
        newUserWeight = getUserWeight[user] + weight;

        // new user weight must be less than or equal to the total user weight
        if (newUserWeight > getVotes(user)) revert OverWeightError();

        // Update gauge state
        getUserWeight[user] = newUserWeight;

        _writeGaugeWeight(_totalWeight, _add112, weight, cycle);
    }

    /// @inheritdoc IERC20Gauges
    function incrementGauges(address[] calldata gaugeList, uint112[] calldata weights)
        external
        nonReentrant
        returns (uint256 newUserWeight)
    {
        uint256 size = gaugeList.length;
        if (weights.length != size) revert SizeMismatchError();

        // store total in summary for a batch update on user/global state
        uint112 weightsSum;

        uint32 currentCycle = _getGaugeCycleEnd();

        // Update a gauge's specific state
        for (uint256 i = 0; i < size;) {
            address gauge = gaugeList[i];
            uint112 weight = weights[i];
            weightsSum += weight;

            _incrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
            unchecked {
                i++;
            }
        }
        return _incrementUserAndGlobalWeights(msg.sender, weightsSum, currentCycle);
    }

    /// @inheritdoc IERC20Gauges
    function decrementGauge(address gauge, uint112 weight) external nonReentrant returns (uint112 newUserWeight) {
        uint32 currentCycle = _getGaugeCycleEnd();

        // All operations will revert on underflow, protecting against bad inputs
        _decrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
        if (!_deprecatedGauges.contains(gauge)) {
            _writeGaugeWeight(_totalWeight, _subtract112, weight, currentCycle);
        }
        return _decrementUserWeights(msg.sender, weight);
    }

    /**
     * @notice Decrement the weight of a gauge for a user
     * @dev This function calls accrueBribes for the gauge to ensure the gauge handles the balance change.
     * @param user the user to decrement the weight of
     * @param gauge the gauge to decrement the weight of
     * @param weight the weight to decrement by
     * @param cycle the cycle to decrement the weight for
     */
    function _decrementGaugeWeight(address user, address gauge, uint112 weight, uint32 cycle) internal {
        if (!_gauges.contains(gauge)) revert InvalidGaugeError();

        uint112 oldWeight = getUserGaugeWeight[user][gauge];

        IBaseV2Gauge(gauge).accrueBribes(user);

        getUserGaugeWeight[user][gauge] = oldWeight - weight;
        if (oldWeight == weight) {
            // If removing all weight, remove gauge from user list.
            require(_userGauges[user].remove(gauge));
        }

        _writeGaugeWeight(_getGaugeWeight[gauge], _subtract112, weight, cycle);

        emit DecrementGaugeWeight(user, gauge, weight, cycle);
    }

    /**
     * @notice Decrement the weight of a gauge for a user and the total weight
     * @param user the user to decrement the weight of
     * @param weight the weight to decrement by
     * @return newUserWeight the new user's weight
     */
    function _decrementUserWeights(address user, uint112 weight) internal returns (uint112 newUserWeight) {
        newUserWeight = getUserWeight[user] - weight;
        getUserWeight[user] = newUserWeight;
    }

    /// @inheritdoc IERC20Gauges
    function decrementGauges(address[] calldata gaugeList, uint112[] calldata weights)
        external
        nonReentrant
        returns (uint112 newUserWeight)
    {
        uint256 size = gaugeList.length;
        if (weights.length != size) revert SizeMismatchError();

        // store total in summary for the batch update on user and global state
        uint112 weightsSum;
        uint112 globalWeightsSum;

        uint32 currentCycle = _getGaugeCycleEnd();

        // Update the gauge's specific state
        // All operations will revert on underflow, protecting against bad inputs
        for (uint256 i = 0; i < size;) {
            address gauge = gaugeList[i];
            uint112 weight = weights[i];
            weightsSum += weight;
            if (!_deprecatedGauges.contains(gauge)) globalWeightsSum += weight;

            _decrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
            unchecked {
                i++;
            }
        }
        _writeGaugeWeight(_totalWeight, _subtract112, globalWeightsSum, currentCycle);

        return _decrementUserWeights(msg.sender, weightsSum);
    }

    /**
     * @dev this function is the key to the entire contract.
     *  The storage weight it operates on is either a global or gauge-specific weight.
     *  The operation applied is either addition for incrementing gauges or subtraction for decrementing a gauge.
     * @param weight the weight to apply the operation to
     * @param op the operation to apply
     * @param delta the amount to apply the operation by
     * @param cycle the cycle to apply the operation for
     */
    function _writeGaugeWeight(
        Weight storage weight,
        function(uint112, uint112) view returns (uint112) op,
        uint112 delta,
        uint32 cycle
    ) private {
        uint112 currentWeight = weight.currentWeight;
        // If the last cycle of the weight is before the current cycle, use the current weight as the stored.
        uint112 stored = weight.currentCycle < cycle ? currentWeight : weight.storedWeight;
        uint112 newWeight = op(currentWeight, delta);

        weight.storedWeight = stored;
        weight.currentWeight = newWeight;
        weight.currentCycle = cycle;
    }

    function _add112(uint112 a, uint112 b) private pure returns (uint112) {
        return a + b;
    }

    function _subtract112(uint112 a, uint112 b) private pure returns (uint112) {
        return a - b;
    }

    /*///////////////////////////////////////////////////////////////
                        ADMIN GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Gauges
    uint256 public override maxGauges;

    /// @inheritdoc IERC20Gauges
    mapping(address => bool) public override canContractExceedMaxGauges;

    /// @inheritdoc IERC20Gauges
    function addGauge(address gauge) external onlyOwner returns (uint112) {
        return _addGauge(gauge);
    }

    /**
     * @notice Add a gauge to the contract
     * @param gauge the gauge to add
     * @return weight the previous weight of the gauge, if it was already added
     */
    function _addGauge(address gauge) internal returns (uint112 weight) {
        bool newAdd = _gauges.add(gauge);
        bool previouslyDeprecated = _deprecatedGauges.remove(gauge);
        // add and fail loud if zero address or already present and not deprecated
        if (gauge == address(0) || !(newAdd || previouslyDeprecated)) revert InvalidGaugeError();

        uint32 currentCycle = _getGaugeCycleEnd();

        // Check if some previous weight exists and re-add to the total. Gauge and user weights are preserved.
        weight = _getGaugeWeight[gauge].currentWeight;
        if (weight > 0) {
            _writeGaugeWeight(_totalWeight, _add112, weight, currentCycle);
        }

        emit AddGauge(gauge);
    }

    /// @inheritdoc IERC20Gauges
    function removeGauge(address gauge) external onlyOwner {
        _removeGauge(gauge);
    }

    /**
     * @notice Remove a gauge from the contract
     * @param gauge the gauge to remove
     */
    function _removeGauge(address gauge) internal {
        // add to deprecated and fail loud if not present
        if (!_deprecatedGauges.add(gauge)) revert InvalidGaugeError();

        uint32 currentCycle = _getGaugeCycleEnd();

        // Remove weight from total but keep the gauge and user weights in storage in case the gauge is re-added.
        uint112 weight = _getGaugeWeight[gauge].currentWeight;
        if (weight > 0) {
            _writeGaugeWeight(_totalWeight, _subtract112, weight, currentCycle);
        }

        emit RemoveGauge(gauge);
    }

    /// @inheritdoc IERC20Gauges
    function replaceGauge(address oldGauge, address newGauge) external onlyOwner {
        _removeGauge(oldGauge);
        _addGauge(newGauge);
    }

    /// @inheritdoc IERC20Gauges
    function setMaxGauges(uint256 newMax) external onlyOwner {
        uint256 oldMax = maxGauges;
        maxGauges = newMax;

        emit MaxGaugesUpdate(oldMax, newMax);
    }

    /// @inheritdoc IERC20Gauges
    function setContractExceedMaxGauges(address account, bool canExceedMax) external onlyOwner {
        if (canExceedMax && account.code.length == 0) revert Errors.NonContractError(); // can only approve contracts

        canContractExceedMaxGauges[account] = canExceedMax;

        emit CanContractExceedMaxGaugesUpdate(account, canExceedMax);
    }

    /*///////////////////////////////////////////////////////////////
                             ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /// NOTE: any "removal" of tokens from a user requires userUnusedVotes < amount.
    /// _decrementWeightUntilFree is called as a greedy algorithm to free up weight.
    /// It may be more gas efficient to free weight before burning or transferring tokens.

    /**
     * @notice Burns `amount` of tokens from `from` address.
     * @dev Frees weights and votes with a greedy algorithm if needed to burn tokens
     * @param from The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function _burn(address from, uint256 amount) internal virtual override {
        _decrementWeightUntilFree(from, amount);
        super._burn(from, amount);
    }

    /**
     * @notice Transfers `amount` of tokens from `msg.sender` to `to` address.
     * @dev Frees weights and votes with a greedy algorithm if needed to burn tokens
     * @param to the address to transfer to.
     * @param amount the amount to transfer.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _decrementWeightUntilFree(msg.sender, amount);
        return super.transfer(to, amount);
    }

    /**
     * @notice Transfers `amount` of tokens from `from` address to `to` address.
     * @dev Frees weights and votes with a greedy algorithm if needed to burn tokens
     * @param from the address to transfer from.
     * @param to the address to transfer to.
     * @param amount the amount to transfer.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _decrementWeightUntilFree(from, amount);
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice A greedy algorithm for freeing weight before a token burn/transfer
     * @dev Frees up entire gauges, so likely will free more than `weight`
     * @param user the user to free weight for
     * @param weight the weight to free
     */
    function _decrementWeightUntilFree(address user, uint256 weight) internal nonReentrant {
        uint256 userFreeWeight = freeVotes(user) + userUnusedVotes(user);

        // early return if already free
        if (userFreeWeight >= weight) return;

        uint32 currentCycle = _getGaugeCycleEnd();

        // cache totals for batch updates
        uint112 userFreed;
        uint112 totalFreed;

        // Loop through all user gauges, live and deprecated
        address[] memory gaugeList = _userGauges[user].values();

        // Free gauges through the entire list or until underweight
        uint256 size = gaugeList.length;
        for (uint256 i = 0; i < size && (userFreeWeight + totalFreed) < weight;) {
            address gauge = gaugeList[i];
            uint112 userGaugeWeight = getUserGaugeWeight[user][gauge];
            if (userGaugeWeight != 0) {
                // If the gauge is live (not deprecated), include its weight in the total to remove
                if (!_deprecatedGauges.contains(gauge)) {
                    totalFreed += userGaugeWeight;
                }
                userFreed += userGaugeWeight;
                _decrementGaugeWeight(user, gauge, userGaugeWeight, currentCycle);

                unchecked {
                    i++;
                }
            }
        }

        getUserWeight[user] -= userFreed;
        _writeGaugeWeight(_totalWeight, _subtract112, totalFreed, currentCycle);
    }
}


// src/gauges/interfaces/IBaseV2Gauge.sol

/**
 * @title Base V2 Gauge
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Handles rewards for distribution, boost attaching/detaching and
 *          accruing bribes for a given strategy.
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⠒⠈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠑⠦⣄⠀⠀⢀⣠⠖⢶⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⢤⡈⠳⣦⡀⠀⠀⠀⠀⠀⠀⠒⢦⣀⠀⠀⠈⢱⠖⠉⠀⠀⠀⠳⡄⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣌⣻⣦⡀⠀⠀⠀⠀⠀⠀⠈⠳⢄⢠⡏⠀⠀⠐⠀⠀⠀⠘⡀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠙⢿⣿⣄⠈⠓⢄⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢀⡴⠁⠀⠀⠀⡠⠂⠀⠀⠀⡾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢦⠀⠀⠀⠀⠀⠑⢄⠀⠀⠙⢿⣦⠀⠀⠑⢄⠀⠀⢰⠃⠀⠀⠀⠀⢀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⢠⠞⠀⠀⠀⠀⢰⠃⠀⠀⠀⠀⠧⠀⠀⠀⠀⠀⡄⠀⠀⠀⠀⠀⠈⢧⠀⠀⠀⠀⠀⠈⠳⣄⠀⠀⠙⢷⡀⠀⠀⠙⢦⡘⢦⠀⠀⠀⠺⢿⠇⢀⠀⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⢠⠎⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⡆⡀⠀⠀⠀⠈⣦⠀⠀⠀⠀⠀⠀⠈⢦⡀⠀⠀⠙⢦⡀⠀⠀⠑⢾⡇⠀⠀⠀⠈⢠⡟⠁⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠁⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠀⠀⢳⠀⢣⣧⠀⠀⠀⠀⠘⡆⠑⡀⠀⠀⠀⠀⠐⡝⢄⠀⠀⠀⠹⢆⠀⠀⢈⡷⠀⠀⠀⢠⡟⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⢸⣦⠀⠀⠀⠀⠀⢸⡄⢸⢹⣄⣆⠀⠀⠀⠸⡄⠹⡄⠀⠀⠀⠀⠈⢎⢧⡀⠀⠀⠈⠳⣤⡿⠛⠳⡀⠀⡉⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⠇⠀⠀⠀⡇⠀⢸⢸⠀⠀⠀⠀⠀⠘⣿⠀⣿⣿⡙⡄⠀⠀⠀⠹⡄⠘⡄⠀⠀⠀⠀⠈⢧⡱⡄⠀⠀⠀⠛⢷⣦⣤⣽⣶⣶⣶⣦⣤⣸⣀⡀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠀⠀⠀⡇⠀⢸⡸⡆⠀⠀⠀⠀⠀⣿⣇⣿⣿⣷⣽⡖⠒⠒⠊⢻⡉⠹⡏⠒⠂⠀⠀⠀⠳⡜⣦⡀⠀⠀⠀⠹⣿⡟⠋⣿⡻⣯⣍⠉⡉⠛⠶⣄⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⡇⡀⠸⡇⣧⢂⠀⠀⠀⢰⡸⣿⡿⢻⡇⠁⠹⣆⠀⠀⠈⢷⡀⠹⡾⣆⠀⠀⠀⠀⠙⣎⠟⣦⣀⣀⣴⣿⠀⣼⣿⢷⣌⠻⢷⣦⣄⣸⠇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⢹⣇⠀⣧⢹⡟⡄⠀⠀⠀⣿⢿⠀⡀⢻⡀⠘⣎⢇⢀⣀⣨⣿⣦⠹⣾⣧⡀⠀⠀⣀⣨⠶⠾⣿⣿⣿⣿⣶⡿⣼⡞⠙⢷⣵⡈⠉⠉⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢸⢠⣠⠤⠒⢺⣿⠒⢿⡼⣿⣳⡀⠀⣠⠋⢿⠆⠰⡄⢳⣤⠼⣿⣯⣶⠿⠿⠿⠿⢿⣿⣷⣶⣿⠁⠀⠀⠀⣻⣿⣿⣿⣿⣷⣿⢡⢇⣾⢻⣿⣶⣄⡀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢰⣼⢾⡀⠀⠀⠸⣿⡇⠈⣧⢹⡛⢣⡴⠃⠀⠘⣿⡀⣨⠾⣿⣾⠟⢩⣷⣿⣶⣤⠀⠀⠈⢿⡿⣿⠀⠀⠀⠀⢹⢿⣿⣿⣿⣿⠋⢻⠏⢹⣸⠁⠈⠛⠿⣶⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣇⠀⠀⠀⣿⢹⡄⢻⣧⢷⠛⣧⠀⠀⠀⠈⣿⣧⣾⣿⠁⠀⣾⣿⣿⣷⣾⡇⠀⠀⡜⠀⢸⠀⠀⠀⠀⢸⡄⢻⣿⣿⠋⠀⢸⠀⠀⣿⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⢸⣄⠠⣶⣻⣖⣷⡘⣇⠈⢧⠘⣷⠶⠒⠊⠙⣿⠟⠁⠀⠀⢹⡿⣿⣿⢿⠇⠀⠐⠁⠀⢼⠀⠀⠀⠀⡼⢸⠻⣿⣧⣀⠀⠀⢀⣼⢹⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⠟⠛⠛⣿⣿⣿⣦⡈⠠⠘⠆⠀⠀⠈⠁⠀⠀⠀⠀⠈⠛⠶⠞⠋⠀⠀⠀⡀⢠⡏⠀⠀⠀⢠⡇⣼⢸⣿⡟⠉⢣⣠⢾⡇⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢀⣨⢿⡿⣟⢿⡄⠀⠀⣿⣿⣯⣿⡃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⣼⡿⢱⣿⣿⠁⠀⠈⡇⢸⡇⢠⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢋⠁⠈⡇⠘⣆⠑⢄⠀⠘⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠇⠀⠀⢠⢿⣷⣿⣿⣿⡄⠀⠰⠃⣼⡇⢸⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⢻⠀⢹⣆⠀⠁⢤⡌⠓⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠀⠀⢠⡏⢸⣿⣿⣿⡿⠻⡄⣠⣾⣿⡇⢸⠦⠀⠀⠀ ⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⢸⡆⢸⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡸⡏⠀⢀⡟⠀⣾⣿⣿⣿⠀⠀⣽⠁⢸⣿⣷⢸⡇⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⢸⡇⢸⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⠁⢠⡟⠀⢰⣿⣿⣿⣿⠀⢠⠇⢠⣾⡇⢿⡈⡇⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠈⠃⢸⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⡏⢀⠎⠀⠀⡼⣽⠋⠁⠈⢀⣾⣴⣿⣿⡇⠸⡇⢱⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢠⡇⠀⠀⠀⢸⣿⠑⢹⣿⣄⠀⠀⠀⠀⠀⠀⠀⠀⠐⠂⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⠋⢠⠟⠀⠀⣸⣷⠃⠀⢀⡞⠁⢸⣿⣿⣿⣧⠀⢿⣸⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢻⠃⠀⠀⠀⣿⡇⠀⣼⣿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⠇⡴⠃⠀⠀⣰⣟⡏⠀⡠⠋⢀⣠⣿⣿⡏⠈⣿⡇⠘⣏⣆⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢀⡾⠀⠀⠀⢠⣿⠀⠀⣿⣿⡿⢹⣿⡿⠷⣶⣤⣀⡀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣷⢧⡞⠁⠀⠀⣸⣿⠼⠷⢶⣶⣾⣿⡿⣿⡿⠀⠀⠘⣷⠀⠸⣿⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠊⠀⠀⠀⠀⣼⠇⠀⣸⣿⡿⢡⣿⡟⠀⣠⣾⣿⣿⣿⣷⣦⣤⣀⣠⣾⣿⣿⣿⣿⣛⣋⣀⣀⣠⢞⡟⠀⣀⡠⢾⣿⣿⡟⠀⢿⣧⠀⠀⠀⠘⡆⠀⠙⡇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡟⠀⢠⣿⠟⢀⣿⡟⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠉⠁⠀⠉⠉⠉⠑⠻⢭⡉⠉⠀⢸⡆⢿⡗⠀⠈⢿⡀⠀⠀⠀⠹⡄⠀⢱⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠁⠀⢀⡞⠉⢠⡿⣌⣴⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⠋⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣄⢸⡇⠘⡇⠀⠀⠈⢧⠀⠀⠀⠀⢱⡀⠈⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⣠⠏⠀⣰⣿⣿⣿⡿⠟⠿⠛⣩⣾⡿⠛⠁⠀⢀⣼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⡇⠀⠸⡄⠀⠀⠈⢇⠀⠀⠀⠀⢻⡀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⣠⠇⣠⣾⣿⠿⠛⠁⢀⣠⣴⣿⠟⠁⠀⠀⠀⢰⠋⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡀⠀⠹⡄⠀⠀⠘⢆⠀⠀⠀⠀⠳⡀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣫⡾⠟⠋⢁⣀⣤⣶⣿⡟⠋⠀⠀⣀⣠⣤⣾⡿⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⢹⡄⠀⠀⠈⢧⡀⠀⠀⠀⠙⣔⡄⠀
 */
interface IBaseV2Gauge {
    /*///////////////////////////////////////////////////////////////
                            GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice the reward token paid
    function rewardToken() external returns (address);

    /// @notice the flywheel core contract
    function flywheelGaugeRewards() external returns (FlywheelGaugeRewards);

    /// @notice mapping of whitelisted bribe tokens.
    function isActive(FlywheelCore_1 flywheel) external returns (bool);

    /// @notice if bribe flywheel was already added.
    function added(FlywheelCore_1 flywheel) external returns (bool);

    /// @notice the gauge's strategy contract
    function strategy() external returns (address);

    /// @notice the gauge's rewards depot
    function multiRewardsDepot() external returns (MultiRewardsDepot);

    /// @notice the current epoch / cycle number
    function epoch() external returns (uint256);

    /// @notice returns all bribe flywheels
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory);

    /*///////////////////////////////////////////////////////////////
                        GAUGE ACTIONS    
    //////////////////////////////////////////////////////////////*/

    /// @notice function responsible for updating current epoch
    /// @dev should be called once per week, or any outstanding rewards will be kept for next cycle
    function newEpoch() external;

    /// @notice attaches a gauge to a user
    /// @dev only the strategy can call this function
    function attachUser(address user) external;

    /// @notice detaches a gauge to a users
    /// @dev only the strategy can call this function
    function detachUser(address user) external;

    /// @notice accrues bribes for a given user
    /// @dev ERC20Gauges calls this on every vote change
    function accrueBribes(address user) external;

    /*///////////////////////////////////////////////////////////////
                        ADMIN ACTIONS    
    //////////////////////////////////////////////////////////////*/

    /// @notice adds a new bribe flywheel
    /// @dev only owner can call this function
    function addBribeFlywheel(FlywheelCore_1 bribeFlywheel) external;

    /// @notice removes a bribe flywheel
    /// @dev only owner can call this function
    function removeBribeFlywheel(FlywheelCore_1 bribeFlywheel) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when weekly emissions are distributed
     * @param amount amount of tokens distributed
     * @param epoch current epoch
     */
    event Distribute(uint256 indexed amount, uint256 indexed epoch);

    /**
     * @notice Emitted when adding a new bribe flywheel
     * @param bribeFlywheel address of the bribe flywheel
     */
    event AddedBribeFlywheel(FlywheelCore_1 indexed bribeFlywheel);

    /**
     * @notice Emitted when removing a bribe flywheel
     * @param bribeFlywheel address of the bribe flywheel
     */
    event RemoveBribeFlywheel(FlywheelCore_1 indexed bribeFlywheel);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when caller is not the strategy
    error StrategyError();

    /// @notice thrown when trying to add an existing flywheel
    error FlywheelAlreadyAdded();

    /// @notice thrown when trying to add an existing flywheel
    error FlywheelNotActive();
}


// src/rewards/interfaces/IFlywheelGaugeRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/FlywheelGaugeRewards.sol)

/// @notice a contract that streams reward tokens to the FlywheelRewards module
interface IRewardsStream {
    /// @notice read and transfer reward token chunk to FlywheelRewards module
    function getRewards() external returns (uint256);
}

// src/hermes/interfaces/IBaseV2Minter.sol

/**
 * @title Base V2 Minter
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Codifies the minting rules as per b(3,3), abstracted from the token to support
 *          any ERC4626 with any token that allows minting. Responsible for minting new tokens.
 */
interface IBaseV2Minter is IRewardsStream {
    /*//////////////////////////////////////////////////////////////
                         MINTER STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Underlying token that the contract has minting powers over.
    function underlying() external view returns (address);

    /// @notice ERC4626 vault that receives emissions via rebases, which later will be distributed throughout the depositors.
    function vault() external view returns (ERC4626);

    /// @notice Holds the rewards for the current cycle and distributes them to the gauges.
    function flywheelGaugeRewards() external view returns (FlywheelGaugeRewards);

    /// @notice Represents the address of the DAO.
    function dao() external view returns (address);

    /// @notice Represents the percentage of the emissions that will be sent to the DAO.
    function daoShare() external view returns (uint256);

    /// @notice Represents the percentage of the circulating supply
    ///         that will be distributed every epoch as rewards
    function tailEmission() external view returns (uint256);

    /// @notice Represents the weekly emissions.
    function weekly() external view returns (uint256);

    /// @notice Represents the timestamp of the beginning of the new cycle.
    function activePeriod() external view returns (uint256);

    /**
     * @notice Initializes contract state. Called once when the contract is
     *         deployed to initialize the contract state.
     * @param _flywheelGaugeRewards address of the flywheel gauge rewards contract.
     */
    function initialize(FlywheelGaugeRewards _flywheelGaugeRewards) external;

    /*//////////////////////////////////////////////////////////////
                         ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Changes the current tail emissions.
     * @param _tail_emission amount to set as the tail emission
     */
    function setTailEmission(uint256 _tail_emission) external;

    /**
     * @notice Sets the address of the DAO.
     * @param _dao address of the DAO.
     */
    function setDao(address _dao) external;

    /**
     * @notice Sets the share of the DAO rewards.
     * @param _dao_share share of the DAO rewards.
     */
    function setDaoShare(uint256 _dao_share) external;

    /*//////////////////////////////////////////////////////////////
                         EMISSION LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculates circulating supply as total token supply - locked supply
    function circulatingSupply() external view returns (uint256);

    /// @notice Calculates tail end (infinity) emissions, starts set as 2% of total supply.
    function weeklyEmission() external view returns (uint256);

    /**
     * @notice Calculate inflation and adjust burn balances accordingly.
     * @param _minted Amount of minted bhermes
     */
    function calculateGrowth(uint256 _minted) external view returns (uint256);

    /**
     * @notice Updates critical information surrounding emissions, such as
     *         the weekly emissions, and mints the tokens for the previous week rewards.
     *         Update period can only be called once per cycle (1 week)
     */
    function updatePeriod() external returns (uint256);

    /**
     * @notice Distributes the weekly emissions to flywheelGaugeRewards contract.
     * @return totalQueuedForCycle represents the amounts of rewards to be distributed.
     */
    function getRewards() external returns (uint256 totalQueuedForCycle);

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event Mint(address indexed sender, uint256 weekly, uint256 circulatingSupply, uint256 growth, uint256 dao_share);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Throws when the caller of `getRewards()` is not the flywheelGaugeRewards contract.
    error NotFlywheelGaugeRewards();

    /// @dev Throws when the caller of `intialize()` is not the initializer contract.
    error NotInitializer();

    /// @dev Throws when new tail emission is higher than 10%.
    error TailEmissionTooHigh();

    /// @dev Throws when the new dao share is higher than 30%.
    error DaoShareTooHigh();
}



/**
 * @title Flywheel Gauge Reward Stream
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Distributes rewards from a stream based on gauge weights
 *
 *  The contract assumes an arbitrary stream of rewards `S` of the rewardToken. It chunks the rewards into cycles of length `l`.
 *
 *  The allocation function for each cycle A(g, S) proportions the stream to each gauge such that SUM(A(g, S)) over all gauges <= S.
 *  NOTE it should be approximately S, but may be less due to truncation.
 *
 *  Rewards are accumulated every time a new rewards cycle begins, and all prior rewards are cached in the previous cycle.
 *  When the Flywheel Core requests accrued rewards for a specific gauge:
 *  1. All prior rewards before this cycle are distributed
 *  2. Rewards for the current cycle are distributed proportionally to the remaining time in the cycle.
 *     If `e` is the cycle end, `t` is the min of e and current timestamp, and `p` is the prior updated time:
 *     For `A` accrued rewards over the cycle, distribute `min(A * (t-p)/(e-p), A)`.
 */
interface IFlywheelGaugeRewards {
    /// @notice rewards queued from prior and current cycles
    struct QueuedRewards {
        uint112 priorCycleRewards;
        uint112 cycleRewards;
        uint32 storedCycle;
    }

    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice the gauge token for determining gauge allocations of the rewards stream
    function gaugeToken() external view returns (ERC20Gauges);

    /// @notice the rewards token for this flywheel rewards contract
    function rewardToken() external view returns (address);

    /// @notice the start of the current cycle
    function gaugeCycle() external view returns (uint32);

    /// @notice the length of a gauge/rewards cycle
    function gaugeCycleLength() external view returns (uint32);

    /// @notice mapping from gauges to queued rewards
    function gaugeQueuedRewards(ERC20)
        external
        view
        returns (uint112 priorCycleRewards, uint112 cycleRewards, uint32 storedCycle);

    /*//////////////////////////////////////////////////////////////
                        GAUGE REWARDS LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Iterates over all live gauges and queues up the rewards for the cycle
     * @return totalQueuedForCycle the max amount of rewards to be distributed over the cycle
     */
    function queueRewardsForCycle() external returns (uint256 totalQueuedForCycle);

    /// @notice Iterates over all live gauges and queues up the rewards for the cycle
    function queueRewardsForCyclePaginated(uint256 numRewards) external;

    /*//////////////////////////////////////////////////////////////
                        FLYWHEEL CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice calculate and transfer accrued rewards to flywheel core
     *  @dev msg.sender is the gauge to accrue rewards for
     * @return amount amounts of tokens accrued and transferred
     */
    function getAccruedRewards() external returns (uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice emitted when a cycle has completely queued and started
    event CycleStart(uint32 indexed cycleStart, uint256 rewardAmount);

    /// @notice emitted when a single gauge is queued. May be emitted before the cycle starts if the queue is done via pagination.
    event QueueRewards(address indexed gauge, uint32 indexed cycleStart, uint256 rewardAmount);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice thrown when trying to queue a new cycle during an old one.
    error CycleError();

    /// @notice thrown when trying to queue with 0 gauges
    error EmptyGaugesError();
}

// src/rewards/rewards/FlywheelGaugeRewards.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/FlywheelGaugeRewards.sol)

/// @title Flywheel Gauge Reward Stream
contract FlywheelGaugeRewards is Ownable, IFlywheelGaugeRewards {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;

    /*//////////////////////////////////////////////////////////////
                        REWARDS CONTRACT STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelGaugeRewards
    ERC20Gauges public immutable override gaugeToken;

    /// @notice the minter contract, is a rewardsStream to collect rewards from
    IBaseV2Minter public immutable minter;

    /// @inheritdoc IFlywheelGaugeRewards
    address public immutable override rewardToken;

    /// @inheritdoc IFlywheelGaugeRewards
    uint32 public override gaugeCycle;

    /// @inheritdoc IFlywheelGaugeRewards
    uint32 public immutable override gaugeCycleLength;

    /// @inheritdoc IFlywheelGaugeRewards
    mapping(ERC20 => QueuedRewards) public override gaugeQueuedRewards;

    /// @notice the start of the next cycle being partially queued
    uint32 internal nextCycle;

    // rewards that made it into a partial queue but didn't get completed
    uint112 internal nextCycleQueuedRewards;

    // the offset during pagination of the queue
    uint32 internal paginationOffset;

    constructor(address _rewardToken, address _owner, ERC20Gauges _gaugeToken, IBaseV2Minter _minter) {
        _initializeOwner(_owner);
        rewardToken = _rewardToken;

        gaugeCycleLength = _gaugeToken.gaugeCycleLength();

        // seed initial gaugeCycle
        gaugeCycle = (block.timestamp.toUint32() / gaugeCycleLength) * gaugeCycleLength;

        gaugeToken = _gaugeToken;

        minter = _minter;
    }

    /*//////////////////////////////////////////////////////////////
                        GAUGE REWARDS LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IFlywheelGaugeRewards
    function queueRewardsForCycle() external returns (uint256 totalQueuedForCycle) {
        /// @dev Update minter cycle and queue rewars if needed.
        /// This will make this call fail if it is a new epoch, because the minter calls this function, the first call would fail with "CycleError()".
        /// Should be called through Minter to kickoff new epoch.
        minter.updatePeriod();

        // next cycle is always the next even divisor of the cycle length above current block timestamp.
        uint32 currentCycle = (block.timestamp.toUint32() / gaugeCycleLength) * gaugeCycleLength;
        uint32 lastCycle = gaugeCycle;

        // ensure new cycle has begun
        if (currentCycle <= lastCycle) revert CycleError();

        gaugeCycle = currentCycle;

        // queue the rewards stream and sanity check the tokens were received
        uint256 balanceBefore = rewardToken.balanceOf(address(this));
        totalQueuedForCycle = minter.getRewards();
        require(rewardToken.balanceOf(address(this)) - balanceBefore >= totalQueuedForCycle);

        // include uncompleted cycle
        totalQueuedForCycle += nextCycleQueuedRewards;

        // iterate over all gauges and update the rewards allocations
        address[] memory gauges = gaugeToken.gauges();

        _queueRewards(gauges, currentCycle, lastCycle, totalQueuedForCycle);

        nextCycleQueuedRewards = 0;
        paginationOffset = 0;

        emit CycleStart(currentCycle, totalQueuedForCycle);
    }

    /// @inheritdoc IFlywheelGaugeRewards
    function queueRewardsForCyclePaginated(uint256 numRewards) external {
        /// @dev Update minter cycle and queue rewars if needed.
        /// This will make this call fail if it is a new epoch, because the minter calls this function, the first call would fail with "CycleError()".
        /// Should be called through Minter to kickoff new epoch.
        minter.updatePeriod();

        // next cycle is always the next even divisor of the cycle length above current block timestamp.
        uint32 currentCycle = (block.timestamp.toUint32() / gaugeCycleLength) * gaugeCycleLength;
        uint32 lastCycle = gaugeCycle;

        // ensure new cycle has begun
        if (currentCycle <= lastCycle) revert CycleError();

        if (currentCycle > nextCycle) {
            nextCycle = currentCycle;
            paginationOffset = 0;
        }

        uint32 offset = paginationOffset;

        // important to only calculate the reward amount once to prevent each page from having a different reward amount
        if (offset == 0) {
            // queue the rewards stream and sanity check the tokens were received
            uint256 balanceBefore = rewardToken.balanceOf(address(this));
            uint256 newRewards = minter.getRewards();
            require(rewardToken.balanceOf(address(this)) - balanceBefore >= newRewards);
            require(newRewards <= type(uint112).max); // safe cast
            nextCycleQueuedRewards += uint112(newRewards); // in case a previous incomplete cycle had rewards, add on
        }

        uint112 queued = nextCycleQueuedRewards;

        uint256 remaining = gaugeToken.numGauges() - offset;

        // Important to do non-strict inequality to include the case where the numRewards is just enough to complete the cycle
        if (remaining <= numRewards) {
            numRewards = remaining;
            gaugeCycle = currentCycle;
            nextCycleQueuedRewards = 0;
            paginationOffset = 0;
            emit CycleStart(currentCycle, queued);
        } else {
            paginationOffset = offset + numRewards.toUint32();
        }

        // iterate over all gauges and update the rewards allocations
        address[] memory gauges = gaugeToken.gauges(offset, numRewards);

        _queueRewards(gauges, currentCycle, lastCycle, queued);
    }

    /*//////////////////////////////////////////////////////////////
                        FLYWHEEL CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Queues the rewards for the next cycle for each given gauge.
     * @param gauges array of gauges addresses to queue rewards for.
     * @param currentCycle timestamp representing the beginning of the new cycle.
     * @param lastCycle timestamp representing the end of the of the last cycle.
     * @param totalQueuedForCycle total number of rewards queued for the next cycle.
     */
    function _queueRewards(address[] memory gauges, uint32 currentCycle, uint32 lastCycle, uint256 totalQueuedForCycle)
        internal
    {
        uint256 size = gauges.length;

        if (size == 0) revert EmptyGaugesError();

        for (uint256 i = 0; i < size; i++) {
            ERC20 gauge = ERC20(gauges[i]);

            QueuedRewards memory queuedRewards = gaugeQueuedRewards[gauge];

            // Cycle queue already started
            require(queuedRewards.storedCycle < currentCycle);
            assert(queuedRewards.storedCycle == 0 || queuedRewards.storedCycle >= lastCycle);

            uint112 completedRewards = queuedRewards.storedCycle == lastCycle ? queuedRewards.cycleRewards : 0;
            uint256 nextRewards = gaugeToken.calculateGaugeAllocation(address(gauge), totalQueuedForCycle);
            require(nextRewards <= type(uint112).max); // safe cast

            gaugeQueuedRewards[gauge] = QueuedRewards({
                priorCycleRewards: queuedRewards.priorCycleRewards + completedRewards,
                cycleRewards: uint112(nextRewards),
                storedCycle: currentCycle
            });

            emit QueueRewards(address(gauge), currentCycle, nextRewards);
        }
    }

    /// @inheritdoc IFlywheelGaugeRewards
    function getAccruedRewards() external returns (uint256 accruedRewards) {
        /// @dev Update minter cycle and queue rewars if needed.
        minter.updatePeriod();

        QueuedRewards memory queuedRewards = gaugeQueuedRewards[ERC20(msg.sender)];

        uint32 cycle = gaugeCycle;
        bool incompleteCycle = queuedRewards.storedCycle > cycle;

        // no rewards
        if (queuedRewards.priorCycleRewards == 0 && (queuedRewards.cycleRewards == 0 || incompleteCycle)) {
            return 0;
        }

        // if stored cycle != 0 it must be >= the last queued cycle
        assert(queuedRewards.storedCycle >= cycle);

        // always accrue prior rewards
        accruedRewards = queuedRewards.priorCycleRewards;
        uint112 cycleRewardsNext = queuedRewards.cycleRewards;

        if (incompleteCycle) {
            // If current cycle queue incomplete, do nothing to current cycle rewards or accrued
        } else {
            accruedRewards += cycleRewardsNext;
            cycleRewardsNext = 0;
        }

        gaugeQueuedRewards[ERC20(msg.sender)] = QueuedRewards({
            priorCycleRewards: 0,
            cycleRewards: cycleRewardsNext,
            storedCycle: queuedRewards.storedCycle
        });

        if (accruedRewards > 0) rewardToken.safeTransfer(msg.sender, accruedRewards);
    }
}

// src/erc-20/ERC20Boost.sol

/// @title An ERC20 with an embedded attachment mechanism to keep track of boost
///        allocations to gauges.
abstract contract ERC20Boost is ERC20, Ownable, IERC20Boost {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeCastLib for *;

    /*///////////////////////////////////////////////////////////////
                            GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Boost
    mapping(address => mapping(address => GaugeState)) public override getUserGaugeBoost;

    /// @inheritdoc IERC20Boost
    mapping(address => uint256) public override getUserBoost;

    mapping(address => EnumerableSet.AddressSet) internal _userGauges;

    EnumerableSet.AddressSet internal _gauges;

    // Store deprecated gauges in case a user needs to free dead boost
    EnumerableSet.AddressSet internal _deprecatedGauges;

    /*///////////////////////////////////////////////////////////////
                            VIEW HELPERS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Boost
    function gauges() external view returns (address[] memory) {
        return _gauges.values();
    }

    /// @inheritdoc IERC20Boost
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _gauges.at(offset + i); // will revert if out of bounds
                i++;
            }
        }
    }

    /// @inheritdoc IERC20Boost
    function isGauge(address gauge) external view returns (bool) {
        return _gauges.contains(gauge) && !_deprecatedGauges.contains(gauge);
    }

    /// @inheritdoc IERC20Boost
    function numGauges() external view returns (uint256) {
        return _gauges.length();
    }

    /// @inheritdoc IERC20Boost
    function deprecatedGauges() external view returns (address[] memory) {
        return _deprecatedGauges.values();
    }

    /// @inheritdoc IERC20Boost
    function numDeprecatedGauges() external view returns (uint256) {
        return _deprecatedGauges.length();
    }

    /// @inheritdoc IERC20Boost
    function freeGaugeBoost(address user) public view returns (uint256) {
        return balanceOf[user] - getUserBoost[user];
    }

    /// @inheritdoc IERC20Boost
    function userGauges(address user) external view returns (address[] memory) {
        return _userGauges[user].values();
    }

    /// @inheritdoc IERC20Boost
    function isUserGauge(address user, address gauge) external view returns (bool) {
        return _userGauges[user].contains(gauge);
    }

    /// @inheritdoc IERC20Boost
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _userGauges[user].at(offset + i); // will revert if out of bounds
                i++;
            }
        }
    }

    /// @inheritdoc IERC20Boost
    function numUserGauges(address user) external view returns (uint256) {
        return _userGauges[user].length();
    }

    /*///////////////////////////////////////////////////////////////
                        GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Boost
    function attach(address user) external {
        if (!_gauges.contains(msg.sender) || _deprecatedGauges.contains(msg.sender)) {
            revert InvalidGauge();
        }

        // idempotent add
        if (!_userGauges[user].add(msg.sender)) revert GaugeAlreadyAttached();

        uint128 userGaugeBoost = balanceOf[user].toUint128();

        if (getUserBoost[user] < userGaugeBoost) {
            getUserBoost[user] = userGaugeBoost;
            emit UpdateUserBoost(user, userGaugeBoost);
        }

        getUserGaugeBoost[user][msg.sender] =
            GaugeState({userGaugeBoost: userGaugeBoost, totalGaugeBoost: totalSupply.toUint128()});

        emit Attach(user, msg.sender, userGaugeBoost);
    }

    /// @inheritdoc IERC20Boost
    function detach(address user) external {
        require(_userGauges[user].remove(msg.sender));
        delete getUserGaugeBoost[user][msg.sender];

        emit Detach(user, msg.sender);
    }

    /*///////////////////////////////////////////////////////////////
                        USER GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Boost
    function updateUserBoost(address user) external {
        uint256 userBoost = 0;

        address[] memory gaugeList = _userGauges[user].values();

        uint256 length = gaugeList.length;
        for (uint256 i = 0; i < length;) {
            address gauge = gaugeList[i];

            if (!_deprecatedGauges.contains(gauge)) {
                uint256 gaugeBoost = getUserGaugeBoost[user][gauge].userGaugeBoost;

                if (userBoost < gaugeBoost) userBoost = gaugeBoost;
            }

            unchecked {
                i++;
            }
        }
        getUserBoost[user] = userBoost;

        emit UpdateUserBoost(user, userBoost);
    }

    /// @inheritdoc IERC20Boost
    function decrementGaugeBoost(address gauge, uint256 boost) public {
        GaugeState storage gaugeState = getUserGaugeBoost[msg.sender][gauge];
        if (boost >= gaugeState.userGaugeBoost) {
            _userGauges[msg.sender].remove(gauge);
            delete getUserGaugeBoost[msg.sender][gauge];

            emit Detach(msg.sender, gauge);
        } else {
            gaugeState.userGaugeBoost -= boost.toUint128();

            emit DecrementUserGaugeBoost(msg.sender, gauge, gaugeState.userGaugeBoost);
        }
    }

    /// @inheritdoc IERC20Boost
    function decrementGaugeAllBoost(address gauge) external {
        require(_userGauges[msg.sender].remove(gauge));
        delete getUserGaugeBoost[msg.sender][gauge];

        emit Detach(msg.sender, gauge);
    }

    /// @inheritdoc IERC20Boost
    function decrementAllGaugesBoost(uint256 boost) external {
        decrementGaugesBoostIndexed(boost, 0, _userGauges[msg.sender].length());
    }

    /// @inheritdoc IERC20Boost
    function decrementGaugesBoostIndexed(uint256 boost, uint256 offset, uint256 num) public {
        address[] memory gaugeList = _userGauges[msg.sender].values();

        uint256 length = gaugeList.length;
        for (uint256 i = 0; i < num && i < length;) {
            address gauge = gaugeList[offset + i];

            GaugeState storage gaugeState = getUserGaugeBoost[msg.sender][gauge];

            if (_deprecatedGauges.contains(gauge) || boost >= gaugeState.userGaugeBoost) {
                require(_userGauges[msg.sender].remove(gauge)); // Remove from set. Should never fail.
                delete getUserGaugeBoost[msg.sender][gauge];

                emit Detach(msg.sender, gauge);
            } else {
                gaugeState.userGaugeBoost -= boost.toUint128();

                emit DecrementUserGaugeBoost(msg.sender, gauge, gaugeState.userGaugeBoost);
            }

            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IERC20Boost
    function decrementAllGaugesAllBoost() external {
        // Loop through all user gauges, live and deprecated
        address[] memory gaugeList = _userGauges[msg.sender].values();

        // Free gauges until through the entire list
        uint256 size = gaugeList.length;
        for (uint256 i = 0; i < size;) {
            address gauge = gaugeList[i];

            require(_userGauges[msg.sender].remove(gauge)); // Remove from set. Should never fail.
            delete getUserGaugeBoost[msg.sender][gauge];

            emit Detach(msg.sender, gauge);

            unchecked {
                i++;
            }
        }

        getUserBoost[msg.sender] = 0;

        emit UpdateUserBoost(msg.sender, 0);
    }

    /*///////////////////////////////////////////////////////////////
                        ADMIN GAUGE OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC20Boost
    function addGauge(address gauge) external onlyOwner {
        _addGauge(gauge);
    }

    function _addGauge(address gauge) internal {
        bool newAdd = _gauges.add(gauge);
        bool previouslyDeprecated = _deprecatedGauges.remove(gauge);
        // add and fail loud if zero address or already present and not deprecated
        if (gauge == address(0) || !(newAdd || previouslyDeprecated)) revert InvalidGauge();

        emit AddGauge(gauge);
    }

    /// @inheritdoc IERC20Boost
    function removeGauge(address gauge) external onlyOwner {
        _removeGauge(gauge);
    }

    function _removeGauge(address gauge) internal {
        // add to deprecated and fail loud if not present
        if (!_deprecatedGauges.add(gauge)) revert InvalidGauge();

        emit RemoveGauge(gauge);
    }

    /// @inheritdoc IERC20Boost
    function replaceGauge(address oldGauge, address newGauge) external onlyOwner {
        _removeGauge(oldGauge);
        _addGauge(newGauge);
    }

    /*///////////////////////////////////////////////////////////////
                             ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /// NOTE: any "removal" of tokens from a user requires notAttached < amount.

    /**
     * @notice Burns `amount` of tokens from `from` address.
     * @dev User must have enough free boost.
     * @param from The address to burn tokens from.
     * @param amount The amount of tokens to burn.
     */
    function _burn(address from, uint256 amount) internal override notAttached(from, amount) {
        super._burn(from, amount);
    }

    /**
     * @notice Transfers `amount` of tokens from `msg.sender` to `to` address.
     * @dev User must have enough free boost.
     * @param to the address to transfer to.
     * @param amount the amount to transfer.
     */
    function transfer(address to, uint256 amount) public override notAttached(msg.sender, amount) returns (bool) {
        return super.transfer(to, amount);
    }

    /**
     * @notice Transfers `amount` of tokens from `from` address to `to` address.
     * @dev User must have enough free boost.
     * @param from the address to transfer from.
     * @param to the address to transfer to.
     * @param amount the amount to transfer.
     */
    function transferFrom(address from, address to, uint256 amount)
        public
        override
        notAttached(from, amount)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }

    /*///////////////////////////////////////////////////////////////
                             MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Reverts if the user does not have enough free boost.
     * @param user The user address.
     * @param amount The amount of boost.
     */
    modifier notAttached(address user, uint256 amount) {
        if (freeGaugeBoost(user) < amount) revert AttachedBoost();
        _;
    }
}

// src/hermes/tokens/bHermesGauges.sol

/**
 * @title bHermesGauges: Directs Hermes emissions.
 * @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Represents the underlying emission direction power of a bHermes token.
 *          bHermesGauges is an ERC-4626 compliant bHermes token which:
 *          votes on bribes rewards allocation for Hermes gauges in a
 *          manipulation-resistant manner.
 *
 *          The bHermes owner/authority ONLY control the maximum number
 *          and approved overrides of gauges and delegates, as well as the live gauge list.
 */
contract bHermesGauges is ERC20Gauges, IbHermesUnderlying {
    /// @inheritdoc IbHermesUnderlying
    address public immutable bHermes;

    constructor(address _owner, uint32 _rewardsCycleLength, uint32 _incrementFreezeWindow)
        ERC20Gauges(_rewardsCycleLength, _incrementFreezeWindow)
        ERC20("bHermes Gauges", "bHERMES-G", 18)
    {
        _initializeOwner(_owner);
        bHermes = msg.sender;
    }

    /// @inheritdoc IbHermesUnderlying
    function mint(address to, uint256 amount) external onlybHermes {
        _mint(to, amount);
    }

    modifier onlybHermes() {
        if (msg.sender != bHermes) revert NotbHermes();
        _;
    }
}

// src/hermes/tokens/bHermesVotes.sol

/**
 * @title bHermesVotes: Have power over Hermes' governance
 * @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Represents the underlying governance power of a bHermes token.
 */
contract bHermesVotes is ERC20MultiVotes, IbHermesUnderlying {
    /// @inheritdoc IbHermesUnderlying
    address public immutable bHermes;

    constructor(address _owner) ERC20("bHermes Votes", "bHERMES-V", 18) {
        _initializeOwner(_owner);
        bHermes = msg.sender;
    }

    /// @inheritdoc IbHermesUnderlying
    function mint(address to, uint256 amount) external onlybHermes {
        _mint(to, amount);
    }

    /**
     * @notice Burns bHermes gauge tokens
     * @param from account to burn tokens from
     * @param amount amount of tokens to burn
     */
    function burn(address from, uint256 amount) external onlybHermes {
        _burn(from, amount);
    }

    modifier onlybHermes() {
        if (msg.sender != bHermes) revert NotbHermes();
        _;
    }
}

// src/rewards/booster/FlywheelBoosterGaugeWeight.sol

// Rewards logic inspired by Tribe DAO Contracts (flywheel-v2/src/rewards/IFlywheelBooster.sol)

/**
 * @title Balance Booster Module for Flywheel
 *  @notice Flywheel is a general framework for managing token incentives.
 *          It takes reward streams to various *strategies* such as staking LP tokens and divides them among *users* of those strategies.
 *
 *          The Booster module is an optional module for virtually boosting or otherwise transforming user balances.
 *          If a booster is not configured, the strategies ERC-20 balanceOf/totalSupply will be used instead.
 *
 *          Boosting logic can be associated with referrals, vote-escrow, or other strategies.
 *
 *          SECURITY NOTE: similar to how Core needs to be notified any time the strategy user composition changes, the booster would need to be notified of any conditions which change the boosted balances atomically.
 *          This prevents gaming of the reward calculation function by using manipulated balances when accruing.
 *
 *          NOTE: Gets total and user voting power allocated to each strategy.
 *
 * ⣿⡇⣿⣿⣿⠛⠁⣴⣿⡿⠿⠧⠹⠿⠘⣿⣿⣿⡇⢸⡻⣿⣿⣿⣿⣿⣿⣿
 * ⢹⡇⣿⣿⣿⠄⣞⣯⣷⣾⣿⣿⣧⡹⡆⡀⠉⢹⡌⠐⢿⣿⣿⣿⡞⣿⣿⣿
 * ⣾⡇⣿⣿⡇⣾⣿⣿⣿⣿⣿⣿⣿⣿⣄⢻⣦⡀⠁⢸⡌⠻⣿⣿⣿⡽⣿⣿
 * ⡇⣿⠹⣿⡇⡟⠛⣉⠁⠉⠉⠻⡿⣿⣿⣿⣿⣿⣦⣄⡉⠂⠈⠙⢿⣿⣝⣿
 * ⠤⢿⡄⠹⣧⣷⣸⡇⠄⠄⠲⢰⣌⣾⣿⣿⣿⣿⣿⣿⣶⣤⣤⡀⠄⠈⠻⢮
 * ⠄⢸⣧⠄⢘⢻⣿⡇⢀⣀⠄⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠄⢀
 * ⠄⠈⣿⡆⢸⣿⣿⣿⣬⣭⣴⣿⣿⣿⣿⣿⣿⣿⣯⠝⠛⠛⠙⢿⡿⠃⠄⢸
 * ⠄⠄⢿⣿⡀⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⡾⠁⢠⡇⢀
 * ⠄⠄⢸⣿⡇⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⣫⣻⡟⢀⠄⣿⣷⣾
 * ⠄⠄⢸⣿⡇⠄⠈⠙⠿⣿⣿⣿⣮⣿⣿⣿⣿⣿⣿⣿⣿⡿⢠⠊⢀⡇⣿⣿
 * ⠒⠤⠄⣿⡇⢀⡲⠄⠄⠈⠙⠻⢿⣿⣿⠿⠿⠟⠛⠋⠁⣰⠇⠄⢸⣿⣿⣿
 * ⠄⠄⠄⣿⡇⢬⡻⡇⡄⠄⠄⠄⡰⢖⠔⠉⠄⠄⠄⠄⣼⠏⠄⠄⢸⣿⣿⣿
 * ⠄⠄⠄⣿⡇⠄⠙⢌⢷⣆⡀⡾⡣⠃⠄⠄⠄⠄⠄⣼⡟⠄⠄⠄⠄⢿⣿⣿
 */
contract FlywheelBoosterGaugeWeight is IFlywheelBooster {
    /// @notice the bHermes gauge weight contract
    bHermesGauges private immutable bhermes;

    /**
     * @notice constructor
     * @param _bHermesGauges the bHermes gauge weight contract
     */
    constructor(bHermesGauges _bHermesGauges) {
        bhermes = _bHermesGauges;
    }

    /// @inheritdoc IFlywheelBooster
    /// @dev Total gauge weight allocated to the strategy
    function boostedTotalSupply(ERC20 strategy) external view returns (uint256) {
        return bhermes.getGaugeWeight(address(strategy));
    }

    /// @inheritdoc IFlywheelBooster
    /// @dev User's gauge weight allocated to the strategy
    function boostedBalanceOf(ERC20 strategy, address user) external view returns (uint256) {
        return bhermes.getUserGaugeWeight(user, address(strategy));
    }
}

// src/hermes/tokens/bHermesBoost.sol

/**
 * @title bHermesBoost: Earns rights to boosted Hermes yield
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice An ERC20 with an embedded attachment mechanism to
 *          keep track of boost allocations to gauges.
 */
contract bHermesBoost is ERC20Boost, IbHermesUnderlying {
    /// @inheritdoc IbHermesUnderlying
    address public immutable bHermes;

    constructor(address _owner) ERC20("bHermes Boost", "bHERMES-B", 18) {
        _initializeOwner(_owner);
        bHermes = msg.sender;
    }

    /// @inheritdoc IbHermesUnderlying
    function mint(address to, uint256 amount) external onlybHermes {
        _mint(to, amount);
    }

    modifier onlybHermes() {
        if (msg.sender != bHermes) revert NotbHermes();
        _;
    }
}

// src/hermes/interfaces/IUtilityManager.sol

/**
 * @title Utility Tokens Manager Contract.
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice When implemented, this contract allows for the management
 *          of bHermes utility tokens.
 */
interface IUtilityManager {
    /*//////////////////////////////////////////////////////////////
                         UTILITY MANAGER STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice bHermes Underlying Token responsible for allocating gauge weights.
    function gaugeWeight() external view returns (bHermesGauges);

    /// @notice bHermes Underlying Token for user boost accounting.
    function gaugeBoost() external view returns (bHermesBoost);

    /// @notice bHermes Underlying Token which grants governance rights.
    function governance() external view returns (bHermesVotes);

    /// @notice Mapping of different user's bHermes Gauge Weight withdrawn from vault.
    function userClaimedWeight(address) external view returns (uint256);

    /// @notice Mapping of different user's bHermes Boost withdrawn from vault.
    function userClaimedBoost(address) external view returns (uint256);

    /// @notice Mapping of different user's bHermes Governance withdrawn from vault.
    function userClaimedGovernance(address) external view returns (uint256);

    /*///////////////////////////////////////////////////////////////
                        UTILITY TOKENS LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Forfeits the same amounts of multiple utility tokens.
    function forfeitMultiple(uint256 amount) external;

    /// @notice Forfeits multiple amounts of multiple utility tokens.
    function forfeitMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) external;

    /// @notice Forfeits amounts of weight utility token.
    /// @param amount The amount to send to partner manager
    function forfeitWeight(uint256 amount) external;

    /// @notice Forfeits amounts of boost utility token.
    /// @param amount The amount to send to partner manager
    function forfeitBoost(uint256 amount) external;

    /// @notice Forfeits amounts of governance utility token.
    /// @param amount The amount to send to partner manager
    function forfeitGovernance(uint256 amount) external;

    /// @notice Claims the same amounts of multiple utility tokens.
    function claimMultiple(uint256 amount) external;

    /// @notice Claims multiple amounts of multiple utility tokens.
    function claimMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) external;

    /// @notice Claims amounts of weight utility token.
    /// @param amount The amount to send to partner manager
    function claimWeight(uint256 amount) external;

    /// @notice Claims amounts of boost utility token.
    /// @param amount The amount to send to partner manager
    function claimBoost(uint256 amount) external;

    /// @notice Claims amounts of governance utility token.
    /// @param amount The amount to send to partner manager
    function claimGovernance(uint256 amount) external;

    /*///////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a user forfeits weight.
    event ForfeitWeight(address indexed user, uint256 amount);

    /// @notice Emitted when a user forfeits boost.
    event ForfeitBoost(address indexed user, uint256 amount);

    /// @notice Emitted when a user forfeits governance.
    event ForfeitGovernance(address indexed user, uint256 amount);

    /// @notice Emitted when a user claims weight.
    event ClaimWeight(address indexed user, uint256 amount);

    /// @notice Emitted when a user claims boost.
    event ClaimBoost(address indexed user, uint256 amount);

    /// @notice Emitted when a user claims governance.
    event ClaimGovernance(address indexed user, uint256 amount);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Insufficient vault shares for action.
    error InsufficientShares();
}

// src/hermes/UtilityManager.sol

/// @title Utility Tokens Manager Contract
abstract contract UtilityManager is IUtilityManager {
    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                         UTILITY MANAGER STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUtilityManager
    bHermesGauges public immutable gaugeWeight;
    /// @inheritdoc IUtilityManager
    bHermesBoost public immutable gaugeBoost;
    /// @inheritdoc IUtilityManager
    bHermesVotes public immutable governance;

    /// @inheritdoc IUtilityManager
    mapping(address => uint256) public userClaimedWeight;
    /// @inheritdoc IUtilityManager
    mapping(address => uint256) public userClaimedBoost;
    /// @inheritdoc IUtilityManager
    mapping(address => uint256) public userClaimedGovernance;

    /**
     * @notice Constructs the UtilityManager contract.
     * @param _gaugeWeight The address of the bHermesGauges contract.
     * @param _gaugeBoost The address of the bHermesBoost contract.
     * @param _governance The address of the bHermesVotes contract.
     */
    constructor(address _gaugeWeight, address _gaugeBoost, address _governance) {
        gaugeWeight = bHermesGauges(_gaugeWeight);
        gaugeBoost = bHermesBoost(_gaugeBoost);
        governance = bHermesVotes(_governance);
    }

    /*///////////////////////////////////////////////////////////////
                        UTILITY TOKENS LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUtilityManager
    function forfeitMultiple(uint256 amount) public virtual {
        forfeitWeight(amount);
        forfeitBoost(amount);
        forfeitGovernance(amount);
    }

    /// @inheritdoc IUtilityManager
    function forfeitMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) public virtual {
        forfeitWeight(weight);
        forfeitBoost(boost);
        forfeitGovernance(_governance);
    }

    /// @inheritdoc IUtilityManager
    function forfeitWeight(uint256 amount) public virtual {
        if (amount == 0) return;
        userClaimedWeight[msg.sender] -= amount;
        address(gaugeWeight).safeTransferFrom(msg.sender, address(this), amount);

        emit ForfeitWeight(msg.sender, amount);
    }

    /// @inheritdoc IUtilityManager
    function forfeitBoost(uint256 amount) public virtual {
        if (amount == 0) return;
        userClaimedBoost[msg.sender] -= amount;
        address(gaugeBoost).safeTransferFrom(msg.sender, address(this), amount);

        emit ForfeitBoost(msg.sender, amount);
    }

    /// @inheritdoc IUtilityManager
    function forfeitGovernance(uint256 amount) public virtual {
        if (amount == 0) return;
        userClaimedGovernance[msg.sender] -= amount;
        address(governance).safeTransferFrom(msg.sender, address(this), amount);

        emit ForfeitGovernance(msg.sender, amount);
    }

    /// @inheritdoc IUtilityManager
    function claimMultiple(uint256 amount) public virtual {
        claimWeight(amount);
        claimBoost(amount);
        claimGovernance(amount);
    }

    /// @inheritdoc IUtilityManager
    function claimMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) public virtual {
        claimWeight(weight);
        claimBoost(boost);
        claimGovernance(_governance);
    }

    /// @inheritdoc IUtilityManager
    function claimWeight(uint256 amount) public virtual checkWeight(amount) {
        if (amount == 0) return;
        userClaimedWeight[msg.sender] += amount;
        address(gaugeWeight).safeTransfer(msg.sender, amount);

        emit ClaimWeight(msg.sender, amount);
    }

    /// @inheritdoc IUtilityManager
    function claimBoost(uint256 amount) public virtual checkBoost(amount) {
        if (amount == 0) return;
        userClaimedBoost[msg.sender] += amount;
        address(gaugeBoost).safeTransfer(msg.sender, amount);

        emit ClaimBoost(msg.sender, amount);
    }

    /// @inheritdoc IUtilityManager
    function claimGovernance(uint256 amount) public virtual checkGovernance(amount) {
        if (amount == 0) return;
        userClaimedGovernance[msg.sender] += amount;
        address(governance).safeTransfer(msg.sender, amount);

        emit ClaimGovernance(msg.sender, amount);
    }

    /*///////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Checks available weight allows for call.
    modifier checkWeight(uint256 amount) virtual;

    /// @dev Checks available boost allows for call.
    modifier checkBoost(uint256 amount) virtual;

    /// @dev Checks available governance allows for call.
    modifier checkGovernance(uint256 amount) virtual;
}

// src/hermes/bHermes.sol

/**
 * @title bHermes: Yield bearing, boosting, voting, and gauge enabled Hermes
 *  @notice bHermes is a deposit only ERC-4626 for HERMES tokens which:
 *          mints bHermes utility tokens (Weight, Boost, Governance)
 *          in exchange for burning HERMES.
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⠀⣀⣀⠀⢀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣇⠸⣿⣿⠇⣸⣿⣿⣷⣦⣄⡀⠀⠀⠀⠀⠀⠀
 *  ⢀⣠⣴⣶⠿⠋⣩⡿⣿⡿⠻⣿⡇⢠⡄⢸⣿⠟⢿⣿⢿⣍⠙⠿⣶⣦⣄⡀⠀
 *  ⠀⠉⠉⠁⠶⠟⠋⠀⠉⠀⢀⣈⣁⡈⢁⣈⣁⡀⠀⠉⠀⠙⠻⠶⠈⠉⠉⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⣿⡿⠛⢁⡈⠛⢿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⣿⣦⣤⣈⠁⢠⣴⣿⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠻⢿⣿⣦⡉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⣦⣈⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⠦⠈⠙⠿⣦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣤⡈⠁⢤⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠷⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠑⢶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠁⢰⡆⠈⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⠈⣡⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 *
 *      ⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⣿⡿⠛⠛⢿⣿⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⢿⠁⠀⠀⠈⡿⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢀⣤⣄
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣀⣀⣀⣸⣿⣿
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
 *      ⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⢸⣿⣿
 *      ⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠉⠁
 *      ⠀⠀⠀⣠⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀
 *      ⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀
 *      ⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿
 */
contract bHermes is UtilityManager, ERC4626DepositOnly {
    using SafeTransferLib for address;

    constructor(ERC20 _hermes, address _owner, uint32 _gaugeCycleLength, uint32 _incrementFreezeWindow)
        UtilityManager(
            address(new bHermesGauges(_owner, _gaugeCycleLength, _incrementFreezeWindow)),
            address(new bHermesBoost(_owner)),
            address(new bHermesVotes(_owner))
        )
        ERC4626DepositOnly(_hermes, "Burned Hermes: Gov + Yield + Boost", "bHermes")
    {}

    /*///////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @dev Checks available weight allows for the call.
    modifier checkWeight(uint256 amount) override {
        if (balanceOf[msg.sender] < amount + userClaimedWeight[msg.sender]) {
            revert InsufficientShares();
        }
        _;
    }

    /// @dev Checks available boost allows for the call.
    modifier checkBoost(uint256 amount) override {
        if (balanceOf[msg.sender] < amount + userClaimedBoost[msg.sender]) {
            revert InsufficientShares();
        }
        _;
    }

    /// @dev Checks available governance allows for the call.
    modifier checkGovernance(uint256 amount) override {
        if (balanceOf[msg.sender] < amount + userClaimedGovernance[msg.sender]) {
            revert InsufficientShares();
        }
        _;
    }

    /*///////////////////////////////////////////////////////////////
                            UTILITY MANAGER LOGIC
    //////////////////////////////////////////////////////////////*/

    function claimOutstanding() public virtual {
        uint256 balance = balanceOf[msg.sender];
        /// @dev Never overflows since balandeOf >= userClaimed.
        claimWeight(balance - userClaimedWeight[msg.sender]);
        claimBoost(balance - userClaimedBoost[msg.sender]);
        claimGovernance(balance - userClaimedGovernance[msg.sender]);
    }

    /*///////////////////////////////////////////////////////////////
                            ERC4626 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Computes the amounts of tokens available in the contract.
     * @dev Front-running first deposit vulnerability is not an
     *      issue since in the initial state:
     *      total assets (~90,000,000 ether) are larger than the
     *      underlying's remaining circulating supply (~30,000,000 ether).
     */
    function totalAssets() public view virtual override returns (uint256) {
        return address(asset).balanceOf(address(this));
    }

    /*///////////////////////////////////////////////////////////////
                             ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mint new bHermes and its underlying tokens: governance, boost and gauge tokens
     * @param to address to mint new tokens for
     * @param amount amounts of new tokens to mint
     */
    function _mint(address to, uint256 amount) internal virtual override {
        gaugeWeight.mint(address(this), amount);
        gaugeBoost.mint(address(this), amount);
        governance.mint(address(this), amount);
        super._mint(to, amount);
    }

    /**
     * @notice Transfer bHermes and its underlying tokens.
     * @param to address to transfer the tokens to
     * @param amount amounts of tokens to transfer
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        uint256 userBalance = balanceOf[msg.sender];

        if (
            userBalance - userClaimedWeight[msg.sender] < amount || userBalance - userClaimedBoost[msg.sender] < amount
                || userBalance - userClaimedGovernance[msg.sender] < amount
        ) revert InsufficientUnderlying();

        return super.transfer(to, amount);
    }

    /**
     * @notice Transfer bHermes and its underlying tokens from a specific account
     * @param from address to transfer the tokens from
     * @param to address to transfer the tokens to
     * @param amount amounts of tokens to transfer
     */

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        uint256 userBalance = balanceOf[from];

        if (
            userBalance - userClaimedWeight[from] < amount || userBalance - userClaimedBoost[from] < amount
                || userBalance - userClaimedGovernance[from] < amount
        ) revert InsufficientUnderlying();

        return super.transferFrom(from, to, amount);
    }

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Insufficient Underlying assets in the vault for transfer.
    error InsufficientUnderlying();
}

// src/gauges/BaseV2Gauge.sol

/// @title Base V2 Gauge - Base contract for handling liquidity provider incentives and voter's bribes.
abstract contract BaseV2Gauge is Ownable, IBaseV2Gauge {
    /*///////////////////////////////////////////////////////////////
                            GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2Gauge
    address public immutable override rewardToken;

    /// @notice token to boost gauge rewards
    bHermesBoost public immutable hermesGaugeBoost;

    /// @inheritdoc IBaseV2Gauge
    FlywheelGaugeRewards public immutable override flywheelGaugeRewards;

    /// @inheritdoc IBaseV2Gauge
    mapping(FlywheelCore_1 => bool) public override isActive;

    /// @inheritdoc IBaseV2Gauge
    mapping(FlywheelCore_1 => bool) public override added;

    /// @inheritdoc IBaseV2Gauge
    address public override strategy;

    /// @inheritdoc IBaseV2Gauge
    MultiRewardsDepot public override multiRewardsDepot;

    /// @inheritdoc IBaseV2Gauge
    uint256 public override epoch;

    /// @notice Bribes flywheels array to accrue bribes from.
    FlywheelCore_1[] private bribeFlywheels;

    /// @notice 1 week in seconds.
    uint256 internal constant WEEK = 1 weeks;

    /**
     * @notice Constructs the BaseV2Gauge contract.
     * @param _flywheelGaugeRewards The FlywheelGaugeRewards contract.
     * @param _strategy The strategy address.
     * @param _owner The owner address.
     */
    constructor(FlywheelGaugeRewards _flywheelGaugeRewards, address _strategy, address _owner) {
        _initializeOwner(_owner);
        flywheelGaugeRewards = _flywheelGaugeRewards;
        rewardToken = _flywheelGaugeRewards.rewardToken();
        hermesGaugeBoost = BaseV2GaugeFactory(msg.sender).bHermesBoostToken();
        strategy = _strategy;

        epoch = (block.timestamp / WEEK) * WEEK;

        multiRewardsDepot = new MultiRewardsDepot(address(this));
    }

    /// @inheritdoc IBaseV2Gauge
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory) {
        return bribeFlywheels;
    }

    /*///////////////////////////////////////////////////////////////
                        GAUGE ACTIONS    
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2Gauge
    function newEpoch() external {
        uint256 _newEpoch = (block.timestamp / WEEK) * WEEK;

        if (epoch < _newEpoch) {
            epoch = _newEpoch;

            uint256 accruedRewards = flywheelGaugeRewards.getAccruedRewards();

            distribute(accruedRewards);

            emit Distribute(accruedRewards, _newEpoch);
        }
    }

    /// @notice Distributes weekly emissions to the strategy.
    function distribute(uint256 amount) internal virtual;

    /// @inheritdoc IBaseV2Gauge
    function attachUser(address user) external onlyStrategy {
        hermesGaugeBoost.attach(user);
    }

    /// @inheritdoc IBaseV2Gauge
    function detachUser(address user) external onlyStrategy {
        hermesGaugeBoost.detach(user);
    }

    /// @inheritdoc IBaseV2Gauge
    function accrueBribes(address user) external {
        FlywheelCore_1[] storage _bribeFlywheels = bribeFlywheels;
        uint256 length = _bribeFlywheels.length;
        for (uint256 i = 0; i < length;) {
            if (isActive[_bribeFlywheels[i]]) _bribeFlywheels[i].accrue(ERC20(address(this)), user);

            unchecked {
                i++;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                            ADMIN ACTIONS    
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2Gauge
    function addBribeFlywheel(FlywheelCore_1 bribeFlywheel) external onlyOwner {
        /// @dev Can't add existing flywheel (active or not)
        if (added[bribeFlywheel]) revert FlywheelAlreadyAdded();

        address flyWheelRewards = address(bribeFlywheel.flywheelRewards());
        FlywheelBribeRewards(flyWheelRewards).setRewardsDepot(multiRewardsDepot);

        multiRewardsDepot.addAsset(flyWheelRewards, bribeFlywheel.rewardToken());
        bribeFlywheels.push(bribeFlywheel);
        isActive[bribeFlywheel] = true;
        added[bribeFlywheel] = true;

        emit AddedBribeFlywheel(bribeFlywheel);
    }

    /// @inheritdoc IBaseV2Gauge
    function removeBribeFlywheel(FlywheelCore_1 bribeFlywheel) external onlyOwner {
        /// @dev Can only remove active flywheels
        if (!isActive[bribeFlywheel]) revert FlywheelNotActive();

        /// @dev This is permanent; can't be re-added
        delete isActive[bribeFlywheel];

        emit RemoveBribeFlywheel(bribeFlywheel);
    }

    /// @notice Only the strategy can attach and detach users.
    modifier onlyStrategy() virtual {
        if (msg.sender != strategy) revert StrategyError();
        _;
    }
}

// src/gauges/interfaces/IBaseV2GaugeFactory.sol

/**
 * @title Base V2 Gauge Factory
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Handles the creation of new gauges and the management of existing ones.
 *          Adds and removes gauges, and allows the bribe factory
 *          to add and remove bribes to gauges.
 *
 * ⠀⠀⠀⠀⠀⠀⠀⣠⠊⡴⠁⠀⠀⣰⠏⠀⣼⠃⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⡇⠙⡄⠀⠀⠳⠙⡆⠀⠀⠘⣆⠀⠀
 * ⠀⠀⠀⠀⢀⣀⡔⠁⡞⠁⠀⠀⣴⠃⠀⣰⡏⠀⠇⠀⠀⠀⠀⠀⠀⠀⡄⠀⢻⠀⠀⠀⠀⠀⠀⠀⢸⠀⠘⡄⠀⠀⠀⢹⡄⠀⠀⠸⠀⠀
 * ⠀⠀⠀⠀⢀⡏⠀⠜⠀⠀⠀⣼⠇⠀⢠⣿⠁⣾⢸⠀⠀⠀⠀⠀⠀⠀⡇⠀⢸⡇⠀⢢⠀⠀⠀⢆⠀⣇⠀⠘⡄⠀⠀⠘⡇⠀⠀⠀⠀⠀
 * ⠀⠀⠀⢀⡾⠀⠀⠀⠀⠀⣸⠏⠀⠀⡞⢹⠀⡇⡾⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⣿⡀⠈⢇⠀⠀⠈⢧⣿⡀⠀⠀⠀⠀⠀⠇⠀⠀⠀⠀⠀
 * ⠀⠀⠀⣼⡇⠀⠀⠀⠀⢠⡿⠀⠀⢠⠁⢸⠀⡇⢳⡇⠀⠀⠀⠀⠀⠀⢸⡀⠀⢸⣧⠀⠘⡄⠀⠀⠀⠻⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠐⢸⡇⠀⡄⠀⠀⠸⣿⠀⠀⣼⠤⠐⣇⢣⡀⠳⡀⠀⠀⢠⠀⠀⠘⣇⠀⠀⢻⣏⠉⢻⡒⠤⡀⠀⠘⠣⣄⡆⠀⠀⠀⠀⠀⠀⠀⠀
 * ⡄⠀⠸⡌⣧⠀⢧⠀⠀⠀⢿⣧⠀⢹⠀⠀⠘⢦⠙⠒⠳⠦⠤⣈⣳⠄⠀⠽⢷⠤⠈⠨⠧⢄⠳⣄⣠⡦⡀⠀⠀⣉⣑⣲⡇⠀⠀⠀⠀⠀
 * ⣌⢢⡀⠙⢻⠳⣬⣧⣀⠠⡈⣏⠙⣋⣥⣶⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠾⣶⡶⣶⣧⣶⢹⣷⠚⡗⠋⢹⠉⠀⠀⠀⠀⠀⠀⠀
 * ⠈⠳⣹⣦⡀⠀⣿⣼⠋⠉⢉⣽⣿⡋⣷⣦⣿⣿⣷⡀⠀⠀⢀⣤⣶⠭⠭⢿⣧⣀⣴⣻⣥⣾⣏⣿⠀⢸⡀⠁⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠘⢮⣻⡄⢿⢻⢀⣾⡿⠟⠛⢻⡽⣱⡟⣩⢿⡷⣶⣶⣾⡿⠁⢤⡖⠒⠛⣿⠟⣥⣛⢷⣿⣽⠀⠘⡿⠁⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠰⡙⢿⡼⡜⢸⣿⠒⡿⢦⠎⣴⢏⡜⠀⢸⣿⠁⠀⢹⣧⠀⠘⡿⢷⡾⣅⡠⠞⠛⠿⣟⣿⡆⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠐⠒⠲⣄⢳⢈⡇⡇⠈⢿⣷⣷⢁⣾⢃⠞⠀⣠⡿⠃⠤⡀⠚⢿⣆⡠⠊⠢⡀⠀⠙⠦⣀⣴⣷⠋⣧⠀⠈⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⢠⡀⠀⠘⢻⣾⠃⠃⠀⢸⠻⣿⣿⣥⣋⣠⣾⠟⠁⠀⠀⠀⠀⠈⢻⣧⡀⠀⠈⢲⣄⡀⠈⠛⢁⡀⠟⡄⠀⠸⡀⡀⠀⠀⠠⠀⠀⠀⠀⠀
 * ⠀⠱⣄⠀⠈⢻⡏⠀⠀⠈⡄⢿⠈⠙⠛⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠹⢿⠶⢚⡯⠗⠋⠲⢄⠀⠈⠒⢿⡄⠀⠱⣇⠀⢀⡇⠀⠀⠀⠀⠀
 * ⢀⡀⠙⣧⡀⣸⡇⠀⠀⠀⠇⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠙⢦⣀⠀⠈⠲⢄⠙⣆⣸⡇⠀⠀⠀⠀⠀
 * ⡻⣷⣦⡼⣷⣿⠃⠀⠀⠀⢸⠈⡟⢆⣀⠴⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢴⠚⠉⠉⠉⠀⣀⠔⣋⠡⠽⢷⠀⠀⠀⠀⠀
 * ⠁⠈⢻⡇⢻⣿⠀⠀⠀⠀⠀⣆⢿⠿⡓⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⣽⣿⣀⡤⠎⡔⢊⠔⢊⡁⠤⠖⢚⣳⣄⠀⠀⠀
 * ⠀⢀⢸⢀⢸⡇⠀⠀⠀⠀⠀⠸⡘⡆⢧⠀⢿⢢⣀⠀⠀⠀⠀⠀⠀⢀⣀⠤⠒⠊⣡⢤⡏⡼⢏⠀⡜⣰⠁⡰⠋⣠⠒⠈⢁⣀⠬⠧⡀⠀
 * ⠀⠀⢸⠈⡞⣧⠀⠀⠀⠀⠀⠀⢣⢹⣮⣆⢸⠸⡌⠓⡦⠒⠒⠊⠉⠁⠀⠀⢠⠞⠀⢠⣿⠁⣸⠻⣡⠃⡼⠀⡰⠁⣠⠞⠁⣠⠤⠐⠚⠀
 * ⠀⠀⡸⠀⣷⢻⠀⠀⠀⠀⠀⠀⢀⢷⡈⢿⣄⡇⢹⡀⢱⠀⠀⠀⠀⠀⢀⠜⠁⠀⠀⣼⣻⣰⡏⠀⠙⢶⠀⡴⠁⡔⠁⣠⠊⢀⠔⠋⠀⠀
 * ⠀⠀⠇⢀⡿⡼⣇⠀⠀⠸⠀⠀⠀⠻⣷⡈⢟⢿⡀⠳⣾⣀⣄⣀⡠⠞⠁⠀⢀⣀⣴⢿⡿⡹⠀⠀⠀⠀⢹⣅⡞⠀⡴⠁⡰⠃⠀⡀⠀⠀
 * ⠀⠀⢠⡾⠀⠱⡈⢦⡀⠀⢳⡀⠀⠀⠈⢯⠿⣦⡳⣴⡟⠛⠋⣿⣴⣶⣶⣿⣿⠿⣯⡞⠀⠃⠀⠀⠀⠀⠈⣿⣑⣞⣀⡜⠁⡴⠋⠀⠀⠀
 * ⠀⠀⢠⠇⠀⢀⣈⣒⠻⣦⣀⠱⣄⡀⠀⠀⠓⣬⣳⣽⠳⣤⠼⠋⠉⠉⠉⠀⣀⣴⣿⠁⠀⠀⠀⠀⠀⠀⢰⠋⣉⡏⡍⠙⡎⢀⡼⠁⠀⠀
 * ⠀⣰⣓⣢⠝⠋⣠⣴⡜⠺⠛⠛⠿⠿⣓⣶⠋⠀⠤⠃⠀⠀⠀⠀⠀⢀⣤⡾⢻⠟⡏⠀⠀⠀⠀⠀⠀⡇⡝⠉⡠⢤⣳⠀⣷⢋⡴⠁⠀⠀
 * ⠜⠿⣿⣦⣖⢉⠰⣁⣉⣉⣉⣉⣑⠒⠼⣿⣆⠀⠀⠀⠀⠀⣀⣠⣶⠿⠓⠊⠉⠉⠁⠀⠀⠀⠀⠀⠀⢠⠴⢋⡠⠤⢏⣷⣿⣉⠀⠀⠀
 */
interface IBaseV2GaugeFactory {
    /*///////////////////////////////////////////////////////////////
                            FACTORY STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The gauge factory manager
    function gaugeManager() external view returns (BaseV2GaugeManager);

    /// @notice The bHermes token used for boost accounting
    function bHermesBoostToken() external view returns (bHermesBoost);

    /// @notice The factory of bribe flywheels
    function bribesFactory() external view returns (BribesFactory);

    /// @notice Stores all the gauges created by the factory.
    function gauges(uint256) external view returns (BaseV2Gauge);

    /// @notice Mapping that assigns each gauge an incremental Id for internal use.
    function gaugeIds(BaseV2Gauge) external view returns (uint256);

    /// @notice Mapping to keep track of active gauges.
    function activeGauges(BaseV2Gauge) external view returns (bool);

    /// @notice Associates a strategy address with a gauge.
    function strategyGauges(address) external view returns (BaseV2Gauge);

    /// @notice Returns all the gauges created by this factory.
    function getGauges() external view returns (BaseV2Gauge[] memory);

    /*//////////////////////////////////////////////////////////////
                         EPOCH LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Function to be called after a new epoch begins.
    function newEpoch() external;

    /**
     * @notice Function to be called after a new epoch begins for a specific range of gauges ids.
     * @param start id of the gauge to start the new epoch
     * @param end id of the end gauge to start the new epoch
     */
    function newEpoch(uint256 start, uint256 end) external;

    /*//////////////////////////////////////////////////////////////
                         GAUGE LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Creates a new gauge for the given strategy.
     * @param strategy The strategy address to create a gauge for.
     * @param data The information to pass to create a new gauge.
     */
    function createGauge(address strategy, bytes memory data) external;

    /**
     * @notice Removes a gauge and its underlying strategies from existence.
     * @param gauge gauge address to remove.
     */
    function removeGauge(BaseV2Gauge gauge) external;

    /*//////////////////////////////////////////////////////////////
                           BRIBE LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new bribe to the gauge if the bribe address is already pre-approved by governance.
     * @param gauge address of the gauge to add a new bribe.
     * @param bribeToken address of the token to bribe the gauge with.
     */
    function addBribeToGauge(BaseV2Gauge gauge, address bribeToken) external;

    /// @notice Removes a given bribe from a gauge, contingent on the removal being pre-approved by governance.
    function removeBribeFromGauge(BaseV2Gauge gauge, address bribeToken) external;

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Throws when trying to add a gauge that already exists.
    error GaugeAlreadyExists();

    /// @notice Throws when the caller is not the owner or BribesFactory owner.
    error NotOwnerOrBribesFactoryOwner();

    /// @notice Throws when removing an invalid gauge.
    error InvalidGauge();
}


// src/gauges/factories/BaseV2GaugeFactory.sol

/// @title Base V2 Gauge Factory
abstract contract BaseV2GaugeFactory is Ownable, IBaseV2GaugeFactory {
    /*///////////////////////////////////////////////////////////////
                            FACTORY STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeFactory
    BaseV2GaugeManager public immutable override gaugeManager;

    /// @inheritdoc IBaseV2GaugeFactory
    bHermesBoost public immutable override bHermesBoostToken;

    /// @inheritdoc IBaseV2GaugeFactory
    BribesFactory public immutable override bribesFactory;

    /// @inheritdoc IBaseV2GaugeFactory
    BaseV2Gauge[] public override gauges;

    /// @inheritdoc IBaseV2GaugeFactory
    mapping(BaseV2Gauge => uint256) public override gaugeIds;

    /// @inheritdoc IBaseV2GaugeFactory
    mapping(BaseV2Gauge => bool) public override activeGauges;

    /// @inheritdoc IBaseV2GaugeFactory
    mapping(address => BaseV2Gauge) public override strategyGauges;

    /**
     * @notice Creates a new gauge factory
     * @param _gaugeManager The gauge manager to use
     * @param _bHermesBoost The bHermes boost token to use
     * @param _bribesFactory The bribes factory to use
     * @param _owner The owner of the factory
     */
    constructor(
        BaseV2GaugeManager _gaugeManager,
        bHermesBoost _bHermesBoost,
        BribesFactory _bribesFactory,
        address _owner
    ) {
        _initializeOwner(_owner);
        bribesFactory = _bribesFactory;
        bHermesBoostToken = _bHermesBoost;
        gaugeManager = _gaugeManager;
    }

    /// @inheritdoc IBaseV2GaugeFactory
    function getGauges() external view returns (BaseV2Gauge[] memory) {
        return gauges;
    }

    /*//////////////////////////////////////////////////////////////
                         EPOCH LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeFactory
    function newEpoch() external {
        BaseV2Gauge[] storage _gauges = gauges;

        uint256 length = _gauges.length;
        for (uint256 i = 0; i < length;) {
            if (activeGauges[_gauges[i]]) _gauges[i].newEpoch();

            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IBaseV2GaugeFactory
    function newEpoch(uint256 start, uint256 end) external {
        BaseV2Gauge[] storage _gauges = gauges;

        uint256 length = _gauges.length;
        if (end > length) end = length;

        for (uint256 i = start; i < end;) {
            if (activeGauges[_gauges[i]]) _gauges[i].newEpoch();

            unchecked {
                i++;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                         GAUGE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates a new gauge for the given strategy
    /// @param strategy The strategy address to create a gauge for
    /// @param data The information to pass to create a new gauge.
    function createGauge(address strategy, bytes memory data) external onlyOwner {
        if (address(strategyGauges[strategy]) != address(0)) revert GaugeAlreadyExists();

        BaseV2Gauge gauge = newGauge(strategy, data);
        strategyGauges[strategy] = gauge;

        uint256 id = gauges.length;
        gauges.push(gauge);
        gaugeIds[gauge] = id;
        activeGauges[gauge] = true;

        gaugeManager.addGauge(address(gauge));

        afterCreateGauge(strategy, data);
    }

    function afterCreateGauge(address strategy, bytes memory data) internal virtual;

    function newGauge(address strategy, bytes memory data) internal virtual returns (BaseV2Gauge gauge);

    /// @inheritdoc IBaseV2GaugeFactory
    function removeGauge(BaseV2Gauge gauge) external onlyOwner {
        if (!activeGauges[gauge] || gauges[gaugeIds[gauge]] != gauge) revert InvalidGauge();
        delete gauges[gaugeIds[gauge]];
        delete gaugeIds[gauge];
        delete activeGauges[gauge];
        delete strategyGauges[gauge.strategy()];
        gaugeManager.removeGauge(address(gauge));
    }

    /*//////////////////////////////////////////////////////////////
                           BRIBE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeFactory
    function addBribeToGauge(BaseV2Gauge gauge, address bribeToken) external onlyOwnerOrBribesFactoryOwner {
        if (!activeGauges[gauge]) revert InvalidGauge();
        gauge.addBribeFlywheel(bribesFactory.flywheelTokens(bribeToken));
        bribesFactory.addGaugetoFlywheel(address(gauge), bribeToken);
    }

    /// @inheritdoc IBaseV2GaugeFactory
    function removeBribeFromGauge(BaseV2Gauge gauge, address bribeToken) external onlyOwnerOrBribesFactoryOwner {
        if (!activeGauges[gauge]) revert InvalidGauge();
        gauge.removeBribeFlywheel(bribesFactory.flywheelTokens(bribeToken));
    }

    /*//////////////////////////////////////////////////////////////
                           MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwnerOrBribesFactoryOwner() {
        if (msg.sender != bribesFactory.owner() && msg.sender != owner()) {
            revert NotOwnerOrBribesFactoryOwner();
        }
        _;
    }
}


// src/gauges/interfaces/IBaseV2GaugeManager.sol

/**
 * @title Base V2 Gauge Factory Manager
 * @notice Interface for the BaseV2GaugeManager contract that handles the
 *         management of gauges and gauge factories.
 *
 *         @dev Only this contract can add/remove gauges to bHermesWeight and bHermesBoost.
 * @author Maia DAO (https://github.com/Maia-DAO)
 */
interface IBaseV2GaugeManager {
    /*///////////////////////////////////////////////////////////////
                        GAUGE MANAGER STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Address that holds admin power over the contract.
    function admin() external view returns (address);

    /// @notice Represent the underlying gauge voting power of bHermes.
    function bHermesGaugeWeight() external view returns (bHermesGauges);

    /// @notice Represents the boosting power of bHermes.
    function bHermesGaugeBoost() external view returns (bHermesBoost);

    /// @notice Array that holds every gauge factory.
    function gaugeFactories(uint256) external view returns (BaseV2GaugeFactory);

    /// @notice Maps each gauge factory to an incremental id.
    function gaugeFactoryIds(BaseV2GaugeFactory) external view returns (uint256);

    /// @notice Holds all the active gauge factories.
    function activeGaugeFactories(BaseV2GaugeFactory) external view returns (bool);

    /// @notice Returns all the gauge factories (including the inactive ones).
    function getGaugeFactories() external view returns (BaseV2GaugeFactory[] memory);

    /*//////////////////////////////////////////////////////////////
                            EPOCH LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Function to call at the beginning of every epoch.
    function newEpoch() external;

    /**
     * @notice Performs the necessary operations of the beginning of the new epoch for a given gauge ids range.
     * @param start initial gauge id to perform the actions.
     * @param end end gauge id to perform the actions.
     */
    function newEpoch(uint256 start, uint256 end) external;

    /*//////////////////////////////////////////////////////////////
                            GAUGE LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a gauge to a bhermes position.
     * @param gauge gauge address to add.
     */
    function addGauge(address gauge) external;

    /**
     * @notice Removes a gauge to a bhermes position.
     * @param gauge gauge address to remove.
     */
    function removeGauge(address gauge) external;

    /*//////////////////////////////////////////////////////////////
                            OWNER LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a gauge factory to the manager.
     * @param gaugeFactory gauge factory address to add to the manager.
     */
    function addGaugeFactory(BaseV2GaugeFactory gaugeFactory) external;

    /**
     * @notice Removes a gauge factory from the manager.
     * @param gaugeFactory gauge factory address to remove to the manager.
     */
    function removeGaugeFactory(BaseV2GaugeFactory gaugeFactory) external;

    /*//////////////////////////////////////////////////////////////
                            ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Changes the ownership of the bHermes gauge boost and gauge weight properties.
     * @param newOwner address of the new owner.
     */
    function changebHermesGaugeOwner(address newOwner) external;

    /**
     * @notice Changes the admin powers of the manager.
     * @param newAdmin address of the new admin.
     */
    function changeAdmin(address newAdmin) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new gauge factory is added.
    event AddedGaugeFactory(address gaugeFactory);

    /// @notice Emitted when a gauge factory is removed.
    event RemovedGaugeFactory(address gaugeFactory);

    /// @notice Emitted when changing bHermes GaugeWeight and GaugeWeight owner.
    event ChangedbHermesGaugeOwner(address newOwner);

    /// @notice Emitted when changing admin.
    event ChangedAdmin(address newAdmin);

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @dev Throws when trying to add a gauge factory that already exists.
    error GaugeFactoryAlreadyExists();

    /// @dev Throws when the caller is not an active gauge factory.
    error NotActiveGaugeFactory();

    /// @dev Throws when the caller is not the admin.
    error NotAdmin();
}


// src/gauges/factories/BaseV2GaugeManager.sol

/// @title Base V2 Gauge Factory Manager - Manages addition/removal of Gauge Factories to bHermes.
contract BaseV2GaugeManager is Ownable, IBaseV2GaugeManager {
    /*///////////////////////////////////////////////////////////////
                        GAUGE MANAGER STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeManager
    address public admin;

    /// @inheritdoc IBaseV2GaugeManager
    bHermesGauges public immutable bHermesGaugeWeight;

    /// @inheritdoc IBaseV2GaugeManager
    bHermesBoost public immutable bHermesGaugeBoost;

    /// @inheritdoc IBaseV2GaugeManager
    BaseV2GaugeFactory[] public gaugeFactories;

    /// @inheritdoc IBaseV2GaugeManager
    mapping(BaseV2GaugeFactory => uint256) public gaugeFactoryIds;

    /// @inheritdoc IBaseV2GaugeManager
    mapping(BaseV2GaugeFactory => bool) public activeGaugeFactories;

    /**
     * @notice Initializes Base V2 Gauge Factory Manager contract.
     * @param _bHermes bHermes contract
     * @param _owner can add BaseV2GaugeFactories.
     * @param _admin can transfer ownership of bHermesWeight and bHermesBoost.
     */
    constructor(bHermes _bHermes, address _owner, address _admin) {
        admin = _admin;
        _initializeOwner(_owner);
        bHermesGaugeWeight = _bHermes.gaugeWeight();
        bHermesGaugeBoost = _bHermes.gaugeBoost();
    }

    /// @inheritdoc IBaseV2GaugeManager
    function getGaugeFactories() external view returns (BaseV2GaugeFactory[] memory) {
        return gaugeFactories;
    }

    /*//////////////////////////////////////////////////////////////
                            EPOCH LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeManager
    function newEpoch() external {
        BaseV2GaugeFactory[] storage _gaugeFactories = gaugeFactories;

        uint256 length = _gaugeFactories.length;
        for (uint256 i = 0; i < length;) {
            if (activeGaugeFactories[_gaugeFactories[i]]) _gaugeFactories[i].newEpoch();

            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IBaseV2GaugeManager
    function newEpoch(uint256 start, uint256 end) external {
        BaseV2GaugeFactory[] storage _gaugeFactories = gaugeFactories;

        uint256 length = _gaugeFactories.length;
        if (end > length) end = length;

        for (uint256 i = start; i < end;) {
            if (activeGaugeFactories[_gaugeFactories[i]]) _gaugeFactories[i].newEpoch();

            unchecked {
                i++;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            GAUGE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeManager
    function addGauge(address gauge) external onlyActiveGaugeFactory {
        bHermesGaugeWeight.addGauge(gauge);
        bHermesGaugeBoost.addGauge(gauge);
    }

    /// @inheritdoc IBaseV2GaugeManager
    function removeGauge(address gauge) external onlyActiveGaugeFactory {
        bHermesGaugeWeight.removeGauge(gauge);
        bHermesGaugeBoost.removeGauge(gauge);
    }

    /*//////////////////////////////////////////////////////////////
                            OWNER LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeManager
    function addGaugeFactory(BaseV2GaugeFactory gaugeFactory) external onlyOwner {
        if (activeGaugeFactories[gaugeFactory]) revert GaugeFactoryAlreadyExists();

        gaugeFactoryIds[gaugeFactory] = gaugeFactories.length;
        gaugeFactories.push(gaugeFactory);
        activeGaugeFactories[gaugeFactory] = true;

        emit AddedGaugeFactory(address(gaugeFactory));
    }

    /// @inheritdoc IBaseV2GaugeManager
    function removeGaugeFactory(BaseV2GaugeFactory gaugeFactory) external onlyOwner {
        if (!activeGaugeFactories[gaugeFactory] || gaugeFactories[gaugeFactoryIds[gaugeFactory]] != gaugeFactory) {
            revert NotActiveGaugeFactory();
        }
        delete gaugeFactories[gaugeFactoryIds[gaugeFactory]];
        delete gaugeFactoryIds[gaugeFactory];
        delete activeGaugeFactories[gaugeFactory];

        emit RemovedGaugeFactory(address(gaugeFactory));
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBaseV2GaugeManager
    function changebHermesGaugeOwner(address newOwner) external onlyAdmin {
        bHermesGaugeWeight.transferOwnership(newOwner);
        bHermesGaugeBoost.transferOwnership(newOwner);

        emit ChangedbHermesGaugeOwner(newOwner);
    }

    /// @inheritdoc IBaseV2GaugeManager
    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;

        emit ChangedAdmin(newAdmin);
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyActiveGaugeFactory() {
        if (!activeGaugeFactories[BaseV2GaugeFactory(msg.sender)]) revert NotActiveGaugeFactory();
        _;
    }

    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }
}


// src/gauges/interfaces/IBribesFactory.sol

/**
 * @title Bribes Factory.
 * @notice Responsible for creating new bribe flywheel instances.
 *         Owner has admin rights to add bribe flywheels to gauges.
 */
interface IBribesFactory {
    /*///////////////////////////////////////////////////////////////
                        BRIBES FACTORY STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The length of a rewards cycle
    function rewardsCycleLength() external view returns (uint256);

    /// @notice Array that holds every bribe created by the factory.
    function bribeFlywheels(uint256) external view returns (FlywheelCore_1);

    /// @notice Mapping that attributes an id to every bribe created.
    function bribeFlywheelIds(FlywheelCore_1) external view returns (uint256);

    /// @notice Mapping that attributes a boolean value depending on whether the bribe is active or not.
    function activeBribeFlywheels(FlywheelCore_1) external view returns (bool);

    /// @notice Mapping that holds the address of the bribe token of a given flywheel.
    function flywheelTokens(address) external view returns (FlywheelCore_1);

    /// @notice The gauge manager contract.
    function gaugeManager() external view returns (BaseV2GaugeManager);

    /// @notice Returns all the bribes created by the factory.
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory);

    /*//////////////////////////////////////////////////////////////
                        CREATE BRIBE LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new bribe flywheel to the given gauge.
     * @dev Creates a new bribe flywheel if it doesn't exist.
     * @param gauge address of the gauge to add the bribe to.
     * @param bribeToken address of the token to create a bribe for.
     */
    function addGaugetoFlywheel(address gauge, address bribeToken) external;

    /**
     * @notice Creates a new flywheel for the given bribe token address.
     * @param bribeToken address of the token to create a bribe for.
     */
    function createBribeFlywheel(address bribeToken) external;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a new bribe flywheel is created.
    event BribeFlywheelCreated(address indexed bribeToken, FlywheelCore_1 flywheel);

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Throws when trying to add a bribe flywheel for a token that already exists.
    error BribeFlywheelAlreadyExists();
}


// src/gauges/factories/BribesFactory.sol

/// @title Gauge Bribes Factory
contract BribesFactory is Ownable, IBribesFactory {
    /*///////////////////////////////////////////////////////////////
                        BRIBES FACTORY STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBribesFactory
    uint256 public immutable rewardsCycleLength;

    FlywheelBoosterGaugeWeight private immutable flywheelGaugeWeightBooster;

    /// @inheritdoc IBribesFactory
    FlywheelCore_1[] public bribeFlywheels;

    /// @inheritdoc IBribesFactory
    mapping(FlywheelCore_1 => uint256) public bribeFlywheelIds;

    /// @inheritdoc IBribesFactory
    mapping(FlywheelCore_1 => bool) public activeBribeFlywheels;

    /// @inheritdoc IBribesFactory
    mapping(address => FlywheelCore_1) public flywheelTokens;

    /// @inheritdoc IBribesFactory
    BaseV2GaugeManager public immutable gaugeManager;

    /**
     * @notice Creates a new bribes factory
     * @param _gaugeManager Gauge Factory manager
     * @param _flywheelGaugeWeightBooster Flywheel Gauge Weight Booster
     * @param _rewardsCycleLength Rewards Cycle Length
     * @param _owner Owner of this contract
     */
    constructor(
        BaseV2GaugeManager _gaugeManager,
        FlywheelBoosterGaugeWeight _flywheelGaugeWeightBooster,
        uint256 _rewardsCycleLength,
        address _owner
    ) {
        _initializeOwner(_owner);
        gaugeManager = _gaugeManager;
        flywheelGaugeWeightBooster = _flywheelGaugeWeightBooster;
        rewardsCycleLength = _rewardsCycleLength;
    }

    /// @inheritdoc IBribesFactory
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory) {
        return bribeFlywheels;
    }

    /*//////////////////////////////////////////////////////////////
                        CREATE BRIBE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IBribesFactory
    function addGaugetoFlywheel(address gauge, address bribeToken) external onlyGaugeFactory {
        if (address(flywheelTokens[bribeToken]) == address(0)) createBribeFlywheel(bribeToken);

        flywheelTokens[bribeToken].addStrategyForRewards(ERC20(gauge));
    }

    /// @inheritdoc IBribesFactory
    function createBribeFlywheel(address bribeToken) public {
        if (address(flywheelTokens[bribeToken]) != address(0)) revert BribeFlywheelAlreadyExists();

        FlywheelCore_1 flywheel = new FlywheelCore_1(
            bribeToken,
            FlywheelBribeRewards(address(0)),
            flywheelGaugeWeightBooster,
            address(this)
        );

        flywheelTokens[bribeToken] = flywheel;

        uint256 id = bribeFlywheels.length;
        bribeFlywheels.push(flywheel);
        bribeFlywheelIds[flywheel] = id;
        activeBribeFlywheels[flywheel] = true;

        flywheel.setFlywheelRewards(address(new FlywheelBribeRewards(flywheel, rewardsCycleLength)));

        emit BribeFlywheelCreated(bribeToken, flywheel);
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyGaugeFactory() {
        if (!gaugeManager.activeGaugeFactories(BaseV2GaugeFactory(msg.sender))) {
            revert Unauthorized();
        }
        _;
    }
}


// src/gauges/UniswapV3Gauge.sol

/// @title Uniswap V3 Gauge - Handles liquidity provider incentives for Uniswap V3 in the Base V2 Gauge implementation.
contract UniswapV3Gauge is BaseV2Gauge, IUniswapV3Gauge {
    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                         GAUGE STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Gauge
    address public immutable override uniswapV3Staker;

    /// @inheritdoc IUniswapV3Gauge
    uint24 public override minimumWidth;

    /**
     * @notice Constructs the UniswapV3Gauge contract.
     * @param _flywheelGaugeRewards The FlywheelGaugeRewards contract.
     * @param _uniswapV3Staker The UniswapV3Staker contract.
     * @param _uniswapV3Pool The UniswapV3Pool contract.
     * @param _minimumWidth The minimum width.
     * @param _owner The owner of the contract.
     */
    constructor(
        FlywheelGaugeRewards _flywheelGaugeRewards,
        address _uniswapV3Staker,
        address _uniswapV3Pool,
        uint24 _minimumWidth,
        address _owner
    ) BaseV2Gauge(_flywheelGaugeRewards, _uniswapV3Pool, _owner) {
        uniswapV3Staker = _uniswapV3Staker;
        minimumWidth = _minimumWidth;

        emit NewMinimumWidth(_minimumWidth);

        rewardToken.safeApprove(_uniswapV3Staker, type(uint256).max);
    }

    /**
     *  @notice Distributes weekly emissions to the Uniswap V3 Staker for the current epoch.
     *  @dev must be called during the 12-hour offset after an epoch ends
     *       or rewards will be queued for the next epoch.
     */
    function distribute(uint256 amount) internal override {
        IUniswapV3Staker(uniswapV3Staker).createIncentiveFromGauge(amount);
    }

    /*//////////////////////////////////////////////////////////////
                         ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Gauge
    function setMinimumWidth(uint24 _minimumWidth) external onlyOwner {
        minimumWidth = _minimumWidth;

        emit NewMinimumWidth(_minimumWidth);
    }

    /*//////////////////////////////////////////////////////////////
                         MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Only the UniswapV3Staker contract can attach and detach users.
    modifier onlyStrategy() override {
        if (msg.sender != uniswapV3Staker) revert StrategyError();
        _;
    }
}

// src/uni-v3-staker/interfaces/IUniswapV3Staker.sol

// Rewards logic inspired by Uniswap V3 Contracts (Uniswap/v3-staker/contracts/UniswapV3Staker.sol)

/**
 * @title Uniswap V3 Staker Interface with bHermes Boost.
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Allows staking non-fungible liquidity tokens in exchange for reward tokens.
 *
 *
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⣤⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣾⣿⣿⣿⠋⣸⣿⣿⣿⣿⣿⠹⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⡿⠁⣰⣿⣿⣿⣿⣿⣿⡄⠙⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⠇⢠⣿⣿⣿⣿⢿⡟⣿⣃⣀⣹⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣿⡿⣠⠿⣟⠉⠋⠉⠀⠁⠙⣿⣿⣽⢿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⡿⢳⣿⢿⣧⠀⠀⠀⠀⠀⠃⠀⠛⢹⣿⣿⣿⣿⣆⢻⣆⠀⠀⠀⠀⠀⢀⡤⠖⠒⠋⢹⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣧⣿⣿⣿⡗⠀⠈⠋⠂⠀⠀⠀⠀⠀⠀⠀⠉⠑⡾⣿⣿⣿⣿⣿⠈⣿⠀⠀⢀⣤⡴⠋⠀⠀⠀⡇⢸⠀⠀⣀⠔
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⣟⣿⣿⣿⣧⣄⠀⠀⠁⠀⣠⠴⠒⠒⠲⡄⠀⢰⡇⣿⣿⣿⣿⣿⠀⣿⠤⠴⡋⠀⠀⠀⠀⠀⠀⢃⠀⡷⠊⠁⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⠹⣿⣿⣿⣿⣿⣆⠀⠀⠀⠙⠳⠶⠶⠋⠀⠀⣼⣾⣿⣿⣿⣿⡟⣸⠏⠀⠀⡇⠀⠀⠀⠀⠀⠀⢸⣀⡇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠀⠀⢻⣿⣿⣿⣿⣿⣷⣤⣄⣀⡀⠀⠀⣀⣠⠾⣿⣿⣿⣿⣿⣿⣿⢟⠀⠀⢰⠁⠀⠀⠀⠀⠀⠀⢸⡿⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠤⠞⠁⠀⠀⠀⠰⡿⣿⣿⣿⣿⣿⣿⣿⣩⣿⠗⠛⠒⠀⣸⣿⣿⣿⣿⣿⡿⠑⢸⠀⠀⡸⠀⠀⠀⡀⠀⠀⢀⠟⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⢻⣿⣿⣿⣿⣿⡏⢹⠱⢄⣀⠤⠚⣿⣿⣿⣿⣿⠯⡇⠀⠀⡆⠀⡇⠀⠀⢸⠃⠀⢠⠟⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⢄⠸⡇⠀⠀⠀⢺⣿⣿⣏⣿⡏⠚⣧⡀⠀⢻⡀⠇⠀⠀⣼⠀⢠⠏⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⢒⠟⡅⠸⣿⣿⢺⢹⡈⢦⣣⠀⠀⠀⢸⡀⢿⡿⠌⡟⠀⠀⠀⠀⠀⢣⡀⠀⠀⡏⢠⠟⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠔⠁⠐⠃⠀⠻⡄⠀⠘⠜⠛⢧⡈⢻⡄⢀⣶⣿⡿⠀⠀⢺⠃⠀⠀⠀⠀⠀⠘⡇⠀⢸⣠⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣰⠏⣡⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠙⢲⣽⣾⣿⣋⣤⣄⣀⣼⡇⠀⠀⠀⠀⠀⠀⢸⡀⣼⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⡠⠴⠋⠁⠀⡄⡇⠀⠀⠳⣄⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀⣼⣿⣿⣋⢁⣀⠉⠉⠘⡇⠀⠀⠀⠀⠀⠀⠀⢳⡍⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⢷⠀⠀⠀⠈⠳⣄⠀⠀⢿⠀⠀⠀⠀⠀⡛⢛⡇⠘⣟⠉⡗⠀⣤⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⡟⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡠⠤⠘⠦⣳⣤⡤⣄⣀⡬⠷⣄⡘⡄⠀⢠⠀⢸⡇⢸⣇⣴⠟⠛⣽⣲⣿⡯⡄⠀⠀⠀⠀⠀⠀⠀⠀⡇⢸⡀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠙⣇⠀⡎⠀⢸⣷⣾⡟⢁⣦⣤⣭⣿⣸⡁⢻⠀⠀⠀⠀⠀⠀⠀⠀⡇⠈⣧⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣤⠇⠀⢸⡿⣟⠀⠘⢻⠁⠀⠀⠋⠉⠙⣇⠀⠀⠀⠀⠀⠀⠀⡇⠀⠙⢧⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⣾⡇⠈⠃⠀⠈⣧⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⢷⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠇⠀⠀⣿⢱⠀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠸⣷⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠘⡆⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡼⠀⠀⢠⡏⠸⡀⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀⠻⡆⠀⠀⠀⠀⠸⠀⠀⠀⠀⣼⠁⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⣤⡷⢄⠇⠀⠀⠀⠀⠀⠙⢆⠀⠀⠀⠀⢿⡀⠀⠀⠀⠀⠀⠀⠀⢰⠏⡆⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⢰⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣷⡀⠀⠀⠀⠀⠀⣰⠃⣰⠃⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠀⢸⣿⣟⠛⣦⢄⡀⠀⠀⠀⠀⠀⢀⣠⠤⠊⢉⡼⡇⠀⠀⠀⢀⡜⠁⣰⠃⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢦⡘⢿⣿⡄⠈⠙⠛⠿⠶⠶⠶⠯⠉⠀⠒⠈⠀⣀⣿⢀⣠⠴⠋⠠⠞⢹⠀⠀⠀
 */
interface IUniswapV3Staker is IERC721Receiver {
    /// @param pool The Uniswap V3 pool
    /// @param startTime The time when the epoch begins
    struct IncentiveKey {
        IUniswapV3Pool pool;
        uint96 startTime;
    }

    /// @notice Represents a staking incentive
    struct Incentive {
        uint256 totalRewardUnclaimed;
        uint160 totalSecondsClaimedX128;
        uint96 numberOfStakes;
    }

    /// @notice Represents the deposit of a liquidity NFT
    struct Deposit {
        address owner;
        int24 tickLower;
        int24 tickUpper;
        uint40 stakedTimestamp;
    }

    /// @notice Represents a staked liquidity NFT
    struct Stake {
        uint160 secondsPerLiquidityInsideInitialX128;
        uint96 liquidityNoOverflow;
        uint128 liquidityIfOverflow;
    }

    /*//////////////////////////////////////////////////////////////
                        UNISWAP V3 STAKER STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The Uniswap V3 Factory
    function factory() external view returns (IUniswapV3Factory);

    /// @notice The nonfungible position manager with which this staking contract is compatible
    function nonfungiblePositionManager() external view returns (INonfungiblePositionManager);

    /// @notice The max amount of seconds into the future the incentive startTime can be set
    function maxIncentiveStartLeadTime() external view returns (uint256);

    /// @notice Address to send undistributed rewards
    function minter() external view returns (address);

    /// @notice The reward token
    function hermes() external view returns (address);

    /// @notice bHermes boost token
    function hermesGaugeBoost() external view returns (bHermesBoost);

    /// @notice returns the pool address for a given gauge.
    function gaugePool(address) external view returns (IUniswapV3Pool);

    /// @notice gauges[IUniswapV3Pool] => UniswapV3Gauge
    function gauges(IUniswapV3Pool) external view returns (UniswapV3Gauge);

    /// @notice bribeDepots[IUniswapV3Pool] => bribeDepot;
    function bribeDepots(IUniswapV3Pool) external view returns (address);

    /// @notice poolsMinimumWidth[IUniswapV3Pool] => minimumWidth
    function poolsMinimumWidth(IUniswapV3Pool) external view returns (uint24);

    /// @notice Represents a staking incentive
    /// @param incentiveId The ID of the incentive computed from its parameters
    /// @return totalRewardUnclaimed The amount of reward token not yet claimed by users
    /// @return totalSecondsClaimedX128 Total liquidity-seconds claimed, represented as a UQ32.128
    /// @return numberOfStakes The count of deposits that are currently staked for the incentive
    function incentives(bytes32 incentiveId)
        external
        view
        returns (uint256 totalRewardUnclaimed, uint160 totalSecondsClaimedX128, uint96 numberOfStakes);

    /// @notice Returns information about a deposited NFT
    /// @return owner The owner of the deposited NFT
    /// @return tickLower The lower tick of the range
    /// @return tickUpper The upper tick of the range
    /// @return stakedTimestamp The time at which the liquidity was staked
    function deposits(uint256 tokenId)
        external
        view
        returns (address owner, int24 tickLower, int24 tickUpper, uint40 stakedTimestamp);

    /// @notice Returns tokenId of the attached position of user per pool
    /// @dev Returns 0 if no position is attached
    /// @param user The address of the user
    /// @param pool The Uniswap V3 pool
    /// @return tokenId The ID of the attached position
    function userAttachements(address user, IUniswapV3Pool pool) external view returns (uint256);

    /// @notice Returns information about a staked liquidity NFT
    /// @param tokenId The ID of the staked token
    /// @param incentiveId The ID of the incentive for which the token is staked
    /// @return secondsPerLiquidityInsideInitialX128 secondsPerLiquidity represented as a UQ32.128
    /// @return liquidity The amount of liquidity in the NFT as of the last time the rewards were computed
    function stakes(uint256 tokenId, bytes32 incentiveId)
        external
        view
        returns (uint160 secondsPerLiquidityInsideInitialX128, uint128 liquidity);

    /// @notice Returns amounts of reward tokens owed to a given address according to the last time all stakes were updated
    /// @param owner The owner for which the rewards owed are checked
    /// @return rewardsOwed The amount of the reward token claimable by the owner
    function rewards(address owner) external view returns (uint256 rewardsOwed);

    /// @notice For external accounting purposes only.
    /// @dev tokenIdRewards[owner] => tokenIdRewards
    /// @param tokenId The ID of the staked token
    /// @return rewards The total amount of rewards earned by the tokenId.
    function tokenIdRewards(uint256 tokenId) external view returns (uint256 rewards);

    /*//////////////////////////////////////////////////////////////
                        CREATE INCENTIVE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates a new incentive for the gauge's pool.
    /// @dev msg sender must be a registered gauge.
    /// @param reward The amount of reward tokens to be distributed
    function createIncentiveFromGauge(uint256 reward) external;

    /// @notice Creates a new liquidity mining incentive program
    /// @param key Details of the incentive to create
    /// @param reward The amount of reward tokens to be distributed
    function createIncentive(IncentiveKey memory key, uint256 reward) external;

    /*//////////////////////////////////////////////////////////////
                            END INCENTIVE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Ends an incentive after the incentive end time has passed and all stakes have been withdrawn
    /// @param key Details of the incentive to end
    /// @return refund The remaining reward tokens when the incentive is ended
    function endIncentive(IncentiveKey memory key) external returns (uint256 refund);

    /*//////////////////////////////////////////////////////////////
                            WITHDRAW TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraws a Uniswap V3 LP token `tokenId` from this contract to the recipient `to`
    /// @param tokenId The unique identifier of an Uniswap V3 LP token
    /// @param to The address where the LP token will be sent
    /// @param data An optional data array that will be passed along to the `to` address via the NFT safeTransferFrom
    function withdrawToken(uint256 tokenId, address to, bytes memory data) external;

    /*//////////////////////////////////////////////////////////////
                            REWARD LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Transfers `amountRequested` of accrued `rewardToken` rewards from the contract to the recipient `to`
    /// @param to The address where claimed rewards will be sent to
    /// @param amountRequested The amount of reward tokens to claim. Claims entire reward amount if set to 0.
    /// @return reward The amount of reward tokens claimed
    function claimReward(address to, uint256 amountRequested) external returns (uint256 reward);

    /// @notice Transfers `amountRequested` of accrued `rewardToken` rewards from the contract to the recipient `to`
    /// @param to The address where claimed rewards will be sent to
    /// @return reward The amount of reward tokens claimed
    function claimAllRewards(address to) external returns (uint256 reward);

    /// @notice Calculates the reward amount that will be received for the given stake
    /// @param key The key of the incentive
    /// @param tokenId The ID of the token
    /// @return reward The reward accrued to the NFT for the given incentive thus far
    /// @return secondsInsideX128 The seconds inside the tick range
    function getRewardInfo(IncentiveKey memory key, uint256 tokenId)
        external
        returns (uint256 reward, uint160 secondsInsideX128);

    /*//////////////////////////////////////////////////////////////
                            UNSTAKE TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Unstakes a Uniswap V3 LP token from all it's staked incentives
    /// @param tokenId The ID of the token to unstake
    function unstakeToken(uint256 tokenId) external;

    /// @notice Unstakes a Uniswap V3 LP token
    /// @param key The key of the incentive for which to unstake the NFT
    /// @param tokenId The ID of the token to unstake
    function unstakeToken(IncentiveKey memory key, uint256 tokenId) external;

    /*//////////////////////////////////////////////////////////////
                            STAKE TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Stakes a Uniswap V3 LP token
    /// @param tokenId The ID of the token to stake
    function stakeToken(uint256 tokenId) external;

    /*//////////////////////////////////////////////////////////////
                        GAUGE UPDATE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Updates the gauge for the given pool
    /// @dev Adds gauge to a pool and updates bribeDepot and poolMinimumWidth
    function updateGauges(IUniswapV3Pool uniswapV3Pool) external;

    /// @notice Updates the bribeDepot for the given pool
    function updateBribeDepot(IUniswapV3Pool uniswapV3Pool) external;

    /// @notice Updates the poolMinimumWidth for the given pool
    function updatePoolMinimumWidth(IUniswapV3Pool uniswapV3Pool) external;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Event emitted when a liquidity mining incentive has been created
    /// @param pool The Uniswap V3 pool
    /// @param startTime The time when the incentive program begins
    /// @param reward The amount of reward tokens to be distributed
    event IncentiveCreated(IUniswapV3Pool indexed pool, uint256 startTime, uint256 reward);

    /// @notice Event that can be emitted when a liquidity mining incentive has ended
    /// @param incentiveId The incentive which is ending
    /// @param refund The amount of reward tokens refunded
    event IncentiveEnded(bytes32 indexed incentiveId, uint256 refund);

    /// @notice Emitted when ownership of a deposit changes
    /// @param tokenId The ID of the deposit (and token) that is being transferred
    /// @param oldOwner The owner before the deposit was transferred
    /// @param newOwner The owner after the deposit was transferred
    event DepositTransferred(uint256 indexed tokenId, address indexed oldOwner, address indexed newOwner);

    /// @notice Event emitted when a Uniswap V3 LP token has been staked
    /// @param tokenId The unique identifier of an Uniswap V3 LP token
    /// @param liquidity The amount of liquidity staked
    /// @param incentiveId The incentive in which the token is staking
    event TokenStaked(uint256 indexed tokenId, bytes32 indexed incentiveId, uint128 liquidity);

    /// @notice Event emitted when a Uniswap V3 LP token has been unstaked
    /// @param tokenId The unique identifier of an Uniswap V3 LP token
    /// @param incentiveId The incentive in which the token is staking
    event TokenUnstaked(uint256 indexed tokenId, bytes32 indexed incentiveId);

    /// @notice Event emitted when a reward token has been claimed
    /// @param to The address where claimed rewards were sent to
    /// @param reward The amount of reward tokens claimed
    event RewardClaimed(address indexed to, uint256 reward);

    /// @notice Event emitted when updating the bribeDepot for a pool
    /// @param uniswapV3Pool The Uniswap V3 pool
    /// @param bribeDepot The bribeDepot for the pool
    event BribeDepotUpdated(IUniswapV3Pool indexed uniswapV3Pool, address bribeDepot);

    /// @notice Event emitted when updating the poolMinimumWidth for a pool
    /// @param uniswapV3Pool The Uniswap V3 pool
    /// @param poolMinimumWidth The poolMinimumWidth for the pool
    event PoolMinimumWidthUpdated(IUniswapV3Pool indexed uniswapV3Pool, uint24 indexed poolMinimumWidth);

    /// @notice Event emitted when updating the gauge address for a pool
    event GaugeUpdated(IUniswapV3Pool indexed uniswapV3Pool, address indexed uniswapV3Gauge);

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error InvalidGauge();

    error NotCalledByOwner();

    error IncentiveRewardMustBePositive();
    error IncentiveStartTimeMustBeNowOrInTheFuture();
    error IncentiveStartTimeNotAtEndOfAnEpoch();
    error IncentiveStartTimeTooFarIntoFuture();
    error IncentiveCallerMustBeRegisteredGauge();

    error IncentiveCannotBeCreatedForPoolWithNoGauge();

    error EndIncentiveBeforeEndTime();
    error EndIncentiveWhileStakesArePresent();
    error EndIncentiveNoRefundAvailable();

    error TokenNotUniswapV3NFT();

    error TokenNotStaked();
    error TokenNotDeposited();

    error InvalidRecipient();
    error TokenStakedError();

    error NonExistentIncentiveError();
    error RangeTooSmallError();
    error NoLiquidityError();
}

// src/uni-v3-staker/libraries/IncentiveId.sol

// Rewards logic inspired by Uniswap V3 Contracts (Uniswap/v3-staker/contracts/libraries/IncentiveId.sol)

/**
 * @title Incentive ID hash library
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This library is responsible for computing the incentive identifier.
 */
library IncentiveId {
    /// @dev Calculate the key for a staking incentive
    /// @param key The components used to compute the incentive identifier
    /// @return incentiveId The identifier for the incentive
    function compute(IUniswapV3Staker.IncentiveKey memory key) internal pure returns (bytes32 incentiveId) {
        return keccak256(abi.encode(key));
    }
}

// src/gauges/interfaces/IUniswapV3GaugeFactory.sol

/**
 * @title Uniswap V3 Gauge Factory
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice Handles the creation of new Uniswap V3 gauges and the management of existing ones.
 *          Adds and removes gauges, and allows the bribe factory
 *          to add and remove bribes to gauges.
 *
 * ⠀⠀⠀⠀⠀⠀⠀⣠⠊⡴⠁⠀⠀⣰⠏⠀⣼⠃⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⡇⠙⡄⠀⠀⠳⠙⡆⠀⠀⠘⣆⠀⠀
 * ⠀⠀⠀⠀⢀⣀⡔⠁⡞⠁⠀⠀⣴⠃⠀⣰⡏⠀⠇⠀⠀⠀⠀⠀⠀⠀⡄⠀⢻⠀⠀⠀⠀⠀⠀⠀⢸⠀⠘⡄⠀⠀⠀⢹⡄⠀⠀⠸⠀⠀
 * ⠀⠀⠀⠀⢀⡏⠀⠜⠀⠀⠀⣼⠇⠀⢠⣿⠁⣾⢸⠀⠀⠀⠀⠀⠀⠀⡇⠀⢸⡇⠀⢢⠀⠀⠀⢆⠀⣇⠀⠘⡄⠀⠀⠘⡇⠀⠀⠀⠀⠀
 * ⠀⠀⠀⢀⡾⠀⠀⠀⠀⠀⣸⠏⠀⠀⡞⢹⠀⡇⡾⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⣿⡀⠈⢇⠀⠀⠈⢧⣿⡀⠀⠀⠀⠀⠀⠇⠀⠀⠀⠀⠀
 * ⠀⠀⠀⣼⡇⠀⠀⠀⠀⢠⡿⠀⠀⢠⠁⢸⠀⡇⢳⡇⠀⠀⠀⠀⠀⠀⢸⡀⠀⢸⣧⠀⠘⡄⠀⠀⠀⠻⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠐⢸⡇⠀⡄⠀⠀⠸⣿⠀⠀⣼⠤⠐⣇⢣⡀⠳⡀⠀⠀⢠⠀⠀⠘⣇⠀⠀⢻⣏⠉⢻⡒⠤⡀⠀⠘⠣⣄⡆⠀⠀⠀⠀⠀⠀⠀⠀
 * ⡄⠀⠸⡌⣧⠀⢧⠀⠀⠀⢿⣧⠀⢹⠀⠀⠘⢦⠙⠒⠳⠦⠤⣈⣳⠄⠀⠽⢷⠤⠈⠨⠧⢄⠳⣄⣠⡦⡀⠀⠀⣉⣑⣲⡇⠀⠀⠀⠀⠀
 * ⣌⢢⡀⠙⢻⠳⣬⣧⣀⠠⡈⣏⠙⣋⣥⣶⣶⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠾⣶⡶⣶⣧⣶⢹⣷⠚⡗⠋⢹⠉⠀⠀⠀⠀⠀⠀⠀
 * ⠈⠳⣹⣦⡀⠀⣿⣼⠋⠉⢉⣽⣿⡋⣷⣦⣿⣿⣷⡀⠀⠀⢀⣤⣶⠭⠭⢿⣧⣀⣴⣻⣥⣾⣏⣿⠀⢸⡀⠁⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠘⢮⣻⡄⢿⢻⢀⣾⡿⠟⠛⢻⡽⣱⡟⣩⢿⡷⣶⣶⣾⡿⠁⢤⡖⠒⠛⣿⠟⣥⣛⢷⣿⣽⠀⠘⡿⠁⠀⡟⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠰⡙⢿⡼⡜⢸⣿⠒⡿⢦⠎⣴⢏⡜⠀⢸⣿⠁⠀⢹⣧⠀⠘⡿⢷⡾⣅⡠⠞⠛⠿⣟⣿⡆⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠐⠒⠲⣄⢳⢈⡇⡇⠈⢿⣷⣷⢁⣾⢃⠞⠀⣠⡿⠃⠤⡀⠚⢿⣆⡠⠊⠢⡀⠀⠙⠦⣀⣴⣷⠋⣧⠀⠈⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⢠⡀⠀⠘⢻⣾⠃⠃⠀⢸⠻⣿⣿⣥⣋⣠⣾⠟⠁⠀⠀⠀⠀⠈⢻⣧⡀⠀⠈⢲⣄⡀⠈⠛⢁⡀⠟⡄⠀⠸⡀⡀⠀⠀⠠⠀⠀⠀⠀⠀
 * ⠀⠱⣄⠀⠈⢻⡏⠀⠀⠈⡄⢿⠈⠙⠛⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠹⢿⠶⢚⡯⠗⠋⠲⢄⠀⠈⠒⢿⡄⠀⠱⣇⠀⢀⡇⠀⠀⠀⠀⠀
 * ⢀⡀⠙⣧⡀⣸⡇⠀⠀⠀⠇⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠙⢦⣀⠀⠈⠲⢄⠙⣆⣸⡇⠀⠀⠀⠀⠀
 * ⡻⣷⣦⡼⣷⣿⠃⠀⠀⠀⢸⠈⡟⢆⣀⠴⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢴⠚⠉⠉⠉⠀⣀⠔⣋⠡⠽⢷⠀⠀⠀⠀⠀
 * ⠁⠈⢻⡇⢻⣿⠀⠀⠀⠀⠀⣆⢿⠿⡓⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⣽⣿⣀⡤⠎⡔⢊⠔⢊⡁⠤⠖⢚⣳⣄⠀⠀⠀
 * ⠀⢀⢸⢀⢸⡇⠀⠀⠀⠀⠀⠸⡘⡆⢧⠀⢿⢢⣀⠀⠀⠀⠀⠀⠀⢀⣀⠤⠒⠊⣡⢤⡏⡼⢏⠀⡜⣰⠁⡰⠋⣠⠒⠈⢁⣀⠬⠧⡀⠀
 * ⠀⠀⢸⠈⡞⣧⠀⠀⠀⠀⠀⠀⢣⢹⣮⣆⢸⠸⡌⠓⡦⠒⠒⠊⠉⠁⠀⠀⢠⠞⠀⢠⣿⠁⣸⠻⣡⠃⡼⠀⡰⠁⣠⠞⠁⣠⠤⠐⠚⠀
 * ⠀⠀⡸⠀⣷⢻⠀⠀⠀⠀⠀⠀⢀⢷⡈⢿⣄⡇⢹⡀⢱⠀⠀⠀⠀⠀⢀⠜⠁⠀⠀⣼⣻⣰⡏⠀⠙⢶⠀⡴⠁⡔⠁⣠⠊⢀⠔⠋⠀⠀
 * ⠀⠀⠇⢀⡿⡼⣇⠀⠀⠸⠀⠀⠀⠻⣷⡈⢟⢿⡀⠳⣾⣀⣄⣀⡠⠞⠁⠀⢀⣀⣴⢿⡿⡹⠀⠀⠀⠀⢹⣅⡞⠀⡴⠁⡰⠃⠀⡀⠀⠀
 * ⠀⠀⢠⡾⠀⠱⡈⢦⡀⠀⢳⡀⠀⠀⠈⢯⠿⣦⡳⣴⡟⠛⠋⣿⣴⣶⣶⣿⣿⠿⣯⡞⠀⠃⠀⠀⠀⠀⠈⣿⣑⣞⣀⡜⠁⡴⠋⠀⠀⠀
 * ⠀⠀⢠⠇⠀⢀⣈⣒⠻⣦⣀⠱⣄⡀⠀⠀⠓⣬⣳⣽⠳⣤⠼⠋⠉⠉⠉⠀⣀⣴⣿⠁⠀⠀⠀⠀⠀⠀⢰⠋⣉⡏⡍⠙⡎⢀⡼⠁⠀⠀
 * ⠀⣰⣓⣢⠝⠋⣠⣴⡜⠺⠛⠛⠿⠿⣓⣶⠋⠀⠤⠃⠀⠀⠀⠀⠀⢀⣤⡾⢻⠟⡏⠀⠀⠀⠀⠀⠀⡇⡝⠉⡠⢤⣳⠀⣷⢋⡴⠁⠀⠀
 * ⠜⠿⣿⣦⣖⢉⠰⣁⣉⣉⣉⣉⣑⠒⠼⣿⣆⠀⠀⠀⠀⠀⣀⣠⣶⠿⠓⠊⠉⠉⠁⠀⠀⠀⠀⠀⠀⢠⠴⢋⡠⠤⢏⣷⣿⣉⠀⠀⠀
 */
interface IUniswapV3GaugeFactory is IBaseV2GaugeFactory {
    /*//////////////////////////////////////////////////////////////
                         FACTORY STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice The uniswap v3 staker instance.
    function uniswapV3Staker() external view returns (UniswapV3Staker);

    /// @notice Flywheel for the uniswap v3 staker, that is responsible for distributing the rewards.
    function flywheelGaugeRewards() external view returns (FlywheelGaugeRewards);

    /*//////////////////////////////////////////////////////////////
                         ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Sets the minimum width for gauge
    function setMinimumWidth(address gauge, uint24 minimumWidth) external;
}

// src/uni-v3-staker/UniswapV3Staker.sol

// Rewards logic inspired by Uniswap V3 Contracts (Uniswap/v3-staker/contracts/UniswapV3Staker.sol)

/// @title Uniswap V3 Staker Interface with bHermes Boost.
contract UniswapV3Staker is IUniswapV3Staker, Multicallable {
    using SafeTransferLib for address;

    /*//////////////////////////////////////////////////////////////
                        UNISWAP V3 STAKER STATE
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    mapping(address => IUniswapV3Pool) public gaugePool;

    /// @inheritdoc IUniswapV3Staker
    mapping(IUniswapV3Pool => UniswapV3Gauge) public gauges;

    /// @inheritdoc IUniswapV3Staker
    mapping(IUniswapV3Pool => address) public bribeDepots;

    /// @inheritdoc IUniswapV3Staker
    mapping(IUniswapV3Pool => uint24) public poolsMinimumWidth;

    /// @inheritdoc IUniswapV3Staker
    mapping(bytes32 => Incentive) public override incentives;

    /// @inheritdoc IUniswapV3Staker
    mapping(uint256 => Deposit) public override deposits;

    /// @notice stakes[user][pool] => tokenId of attached position of user per pool
    mapping(address => mapping(IUniswapV3Pool => uint256)) private _userAttachements;

    /// @dev stakes[tokenId][incentiveHash] => Stake
    mapping(uint256 => mapping(bytes32 => Stake)) private _stakes;

    /// @dev stakedIncentives[tokenId] => incentiveIds
    mapping(uint256 => IncentiveKey) private stakedIncentiveKey;

    /// @inheritdoc IUniswapV3Staker
    function stakes(uint256 tokenId, bytes32 incentiveId)
        public
        view
        override
        returns (uint160 secondsPerLiquidityInsideInitialX128, uint128 liquidity)
    {
        Stake storage stake = _stakes[tokenId][incentiveId];
        secondsPerLiquidityInsideInitialX128 = stake.secondsPerLiquidityInsideInitialX128;
        liquidity = stake.liquidityNoOverflow;
        if (liquidity == type(uint96).max) {
            liquidity = stake.liquidityIfOverflow;
        }
    }

    /// @inheritdoc IUniswapV3Staker
    function userAttachements(address user, IUniswapV3Pool pool) external view override returns (uint256) {
        return hermesGaugeBoost.isUserGauge(user, address(gauges[pool])) ? _userAttachements[user][pool] : 0;
    }

    /// @inheritdoc IUniswapV3Staker
    mapping(address => uint256) public override rewards;

    /// @inheritdoc IUniswapV3Staker
    mapping(uint256 => uint256) public tokenIdRewards;

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the Uniswap V3 Gauge Factory
    IUniswapV3GaugeFactory public immutable uniswapV3GaugeFactory;

    /// @inheritdoc IUniswapV3Staker
    IUniswapV3Factory public immutable override factory;

    /// @inheritdoc IUniswapV3Staker
    INonfungiblePositionManager public immutable override nonfungiblePositionManager;

    /// @inheritdoc IUniswapV3Staker
    uint256 public immutable override maxIncentiveStartLeadTime;

    /// @inheritdoc IUniswapV3Staker
    address public immutable minter;

    /// @inheritdoc IUniswapV3Staker
    address public immutable hermes;

    /// @inheritdoc IUniswapV3Staker
    bHermesBoost public immutable hermesGaugeBoost;

    /// @param _factory the Uniswap V3 factory
    /// @param _nonfungiblePositionManager the NFT position manager contract address
    /// @param _maxIncentiveStartLeadTime the max duration of an incentive in seconds
    constructor(
        IUniswapV3Factory _factory,
        INonfungiblePositionManager _nonfungiblePositionManager,
        IUniswapV3GaugeFactory _uniswapV3GaugeFactory,
        bHermesBoost _hermesGaugeBoost,
        uint256 _maxIncentiveStartLeadTime,
        address _minter,
        address _hermes
    ) {
        factory = _factory;
        nonfungiblePositionManager = _nonfungiblePositionManager;
        maxIncentiveStartLeadTime = _maxIncentiveStartLeadTime;
        uniswapV3GaugeFactory = _uniswapV3GaugeFactory;
        hermesGaugeBoost = _hermesGaugeBoost;
        minter = _minter;
        hermes = _hermes;
    }

    /*//////////////////////////////////////////////////////////////
                        CREATE INCENTIVE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function createIncentiveFromGauge(uint256 reward) external {
        if (reward <= 0) revert IncentiveRewardMustBePositive();

        uint96 startTime = IncentiveTime.computeEnd(block.timestamp);

        IUniswapV3Pool pool = gaugePool[msg.sender];

        if (address(pool) == address(0)) revert IncentiveCallerMustBeRegisteredGauge();

        IncentiveKey memory key = IncentiveKey({startTime: startTime, pool: pool});
        bytes32 incentiveId = IncentiveId.compute(key);

        incentives[incentiveId].totalRewardUnclaimed += reward;

        hermes.safeTransferFrom(msg.sender, address(this), reward);

        emit IncentiveCreated(pool, startTime, reward);
    }

    /// @inheritdoc IUniswapV3Staker
    function createIncentive(IncentiveKey memory key, uint256 reward) external {
        if (reward <= 0) revert IncentiveRewardMustBePositive();

        uint96 startTime = IncentiveTime.computeStart(key.startTime);

        if (startTime != key.startTime) revert IncentiveStartTimeNotAtEndOfAnEpoch();

        if (startTime <= block.timestamp) revert IncentiveStartTimeMustBeNowOrInTheFuture();
        if (startTime - block.timestamp > maxIncentiveStartLeadTime) {
            revert IncentiveStartTimeTooFarIntoFuture();
        }

        if (address(gauges[key.pool]) == address(0)) {
            revert IncentiveCannotBeCreatedForPoolWithNoGauge();
        }

        bytes32 incentiveId = IncentiveId.compute(key);

        incentives[incentiveId].totalRewardUnclaimed += reward;

        hermes.safeTransferFrom(msg.sender, address(this), reward);

        emit IncentiveCreated(key.pool, startTime, reward);
    }

    /*//////////////////////////////////////////////////////////////
                            END INCENTIVE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function endIncentive(IncentiveKey memory key) external returns (uint256 refund) {
        if (block.timestamp < IncentiveTime.getEnd(key.startTime)) {
            revert EndIncentiveBeforeEndTime();
        }

        bytes32 incentiveId = IncentiveId.compute(key);

        Incentive storage incentive = incentives[incentiveId];

        refund = incentive.totalRewardUnclaimed;

        if (refund == 0) revert EndIncentiveNoRefundAvailable();
        if (incentive.numberOfStakes > 0) revert EndIncentiveWhileStakesArePresent();

        // issue the refund
        incentive.totalRewardUnclaimed = 0;

        hermes.safeTransfer(minter, refund);

        // note we never clear totalSecondsClaimedX128

        emit IncentiveEnded(incentiveId, refund);
    }

    /*//////////////////////////////////////////////////////////////
                            DEPOSIT TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Upon receiving a Uniswap V3 ERC721, create the token deposit and
    ///      _stakes in current incentive setting owner to `from`.
    /// @inheritdoc IERC721Receiver
    function onERC721Received(address, address from, uint256 tokenId, bytes calldata)
        external
        override
        returns (bytes4)
    {
        INonfungiblePositionManager _nonfungiblePositionManager = nonfungiblePositionManager;
        if (msg.sender != address(_nonfungiblePositionManager)) revert TokenNotUniswapV3NFT();

        (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) =
            NFTPositionInfo.getPositionInfo(factory, nonfungiblePositionManager, tokenId);

        deposits[tokenId] = Deposit({owner: from, tickLower: tickLower, tickUpper: tickUpper, stakedTimestamp: 0});
        emit DepositTransferred(tokenId, address(0), from);

        // stake the token in the current incentive
        _stakeToken(tokenId, pool, tickLower, tickUpper, liquidity);

        return this.onERC721Received.selector;
    }

    /*//////////////////////////////////////////////////////////////
                            WITHDRAW TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function withdrawToken(uint256 tokenId, address to, bytes memory data) external {
        if (to == address(0)) revert InvalidRecipient();

        Deposit storage deposit = deposits[tokenId];

        if (deposit.owner != msg.sender) revert NotCalledByOwner();
        if (deposit.stakedTimestamp != 0) revert TokenStakedError();

        delete deposits[tokenId];
        emit DepositTransferred(tokenId, msg.sender, address(0));

        nonfungiblePositionManager.safeTransferFrom(address(this), to, tokenId, data);
    }

    /*//////////////////////////////////////////////////////////////
                            REWARD LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function claimReward(address to, uint256 amountRequested) external returns (uint256 reward) {
        reward = rewards[msg.sender];
        if (amountRequested != 0 && amountRequested < reward) {
            reward = amountRequested;
            rewards[msg.sender] -= reward;
        } else {
            rewards[msg.sender] = 0;
        }

        if (reward > 0) hermes.safeTransfer(to, reward);

        emit RewardClaimed(to, reward);
    }

    /// @inheritdoc IUniswapV3Staker
    function claimAllRewards(address to) external returns (uint256 reward) {
        reward = rewards[msg.sender];
        rewards[msg.sender] = 0;

        if (reward > 0) hermes.safeTransfer(to, reward);

        emit RewardClaimed(to, reward);
    }

    /// @inheritdoc IUniswapV3Staker
    function getRewardInfo(IncentiveKey memory key, uint256 tokenId)
        external
        view
        override
        returns (uint256 reward, uint160 secondsInsideX128)
    {
        Deposit storage deposit = deposits[tokenId];

        (uint96 endTime, uint256 stakedDuration) =
            IncentiveTime.getEndAndDuration(key.startTime, deposit.stakedTimestamp, block.timestamp);

        bytes32 incentiveId = IncentiveId.compute(key);
        {
            uint128 boostAmount;
            uint128 boostTotalSupply;
            address owner = deposit.owner;
            // If tokenId is attached to gauge
            if (_userAttachements[owner][key.pool] == tokenId) {
                // get boost amount and total supply
                (boostAmount, boostTotalSupply) = hermesGaugeBoost.getUserGaugeBoost(owner, address(gauges[key.pool]));
            }

            (uint160 secondsPerLiquidityInsideInitialX128, uint128 liquidity) = stakes(tokenId, incentiveId);
            if (liquidity == 0) revert TokenNotStaked();

            (, uint160 secondsPerLiquidityInsideX128,) =
                key.pool.snapshotCumulativesInside(deposit.tickLower, deposit.tickUpper);

            secondsInsideX128 = RewardMath.computeBoostedSecondsInsideX128(
                stakedDuration,
                liquidity,
                uint128(boostAmount),
                uint128(boostTotalSupply),
                secondsPerLiquidityInsideInitialX128,
                secondsPerLiquidityInsideX128
            );
        }

        Incentive storage incentive = incentives[incentiveId];
        reward = RewardMath.computeBoostedRewardAmount(
            incentive.totalRewardUnclaimed,
            incentive.totalSecondsClaimedX128,
            key.startTime,
            endTime,
            secondsInsideX128,
            block.timestamp
        );
    }

    /*//////////////////////////////////////////////////////////////
                            RE-STAKE TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    function restakeToken(uint256 tokenId) external {
        IncentiveKey storage incentiveId = stakedIncentiveKey[tokenId];
        if (incentiveId.startTime != 0) _unstakeToken(incentiveId, tokenId, true);

        (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) =
            NFTPositionInfo.getPositionInfo(factory, nonfungiblePositionManager, tokenId);

        _stakeToken(tokenId, pool, tickLower, tickUpper, liquidity);
    }

    /*//////////////////////////////////////////////////////////////
                            UNSTAKE TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function unstakeToken(uint256 tokenId) external {
        IncentiveKey storage incentiveId = stakedIncentiveKey[tokenId];
        if (incentiveId.startTime != 0) _unstakeToken(incentiveId, tokenId, true);
    }

    /// @inheritdoc IUniswapV3Staker
    function unstakeToken(IncentiveKey memory key, uint256 tokenId) external {
        _unstakeToken(key, tokenId, true);
    }

    function _unstakeToken(IncentiveKey memory key, uint256 tokenId, bool isNotRestake) private {
        Deposit storage deposit = deposits[tokenId];

        (uint96 endTime, uint256 stakedDuration) =
            IncentiveTime.getEndAndDuration(key.startTime, deposit.stakedTimestamp, block.timestamp);

        address owner = deposit.owner;

        // anyone can call restakeToken if the block time is after the end time of the incentive
        if ((isNotRestake || block.timestamp < endTime) && owner != msg.sender) revert NotCalledByOwner();

        {
            // scope for bribeAddress, avoids stack too deep errors
            address bribeAddress = bribeDepots[key.pool];

            if (bribeAddress != address(0)) {
                nonfungiblePositionManager.collect(
                    INonfungiblePositionManager.CollectParams({
                        tokenId: tokenId,
                        recipient: bribeAddress,
                        amount0Max: type(uint128).max,
                        amount1Max: type(uint128).max
                    })
                );
            }
        }

        bytes32 incentiveId = IncentiveId.compute(key);
        uint160 secondsInsideX128;
        uint128 liquidity;
        {
            uint128 boostAmount;
            uint128 boostTotalSupply;

            UniswapV3Gauge gauge = gauges[key.pool]; // saves another SLOAD if no tokenId is attached

            // If tokenId is attached to gauge
            if (hermesGaugeBoost.isUserGauge(owner, address(gauge)) && _userAttachements[owner][key.pool] == tokenId) {
                // get boost amount and total supply
                (boostAmount, boostTotalSupply) = hermesGaugeBoost.getUserGaugeBoost(owner, address(gauge));
                gauge.detachUser(owner);
                _userAttachements[owner][key.pool] = 0;
            }

            uint160 secondsPerLiquidityInsideInitialX128;
            (secondsPerLiquidityInsideInitialX128, liquidity) = stakes(tokenId, incentiveId);
            if (liquidity == 0) revert TokenNotStaked();

            (, uint160 secondsPerLiquidityInsideX128,) =
                key.pool.snapshotCumulativesInside(deposit.tickLower, deposit.tickUpper);

            secondsInsideX128 = RewardMath.computeBoostedSecondsInsideX128(
                stakedDuration,
                liquidity,
                uint128(boostAmount),
                uint128(boostTotalSupply),
                secondsPerLiquidityInsideInitialX128,
                secondsPerLiquidityInsideX128
            );
        }

        deposit.stakedTimestamp = 0;
        Incentive storage incentive = incentives[incentiveId];
        incentive.numberOfStakes--;
        uint256 reward = RewardMath.computeBoostedRewardAmount(
            incentive.totalRewardUnclaimed,
            incentive.totalSecondsClaimedX128,
            key.startTime,
            endTime,
            secondsInsideX128,
            block.timestamp
        );

        unchecked {
            // if this overflows, e.g. after 2^32-1 full liquidity seconds have been claimed,
            // reward rate will fall drastically so it's safe
            // can't overflow if incentiveDuration < 2^32-1 seconds
            incentive.totalSecondsClaimedX128 += secondsInsideX128;
            // reward is never greater than total reward unclaimed
            incentive.totalRewardUnclaimed -= reward;
            // this only overflows if a token has a total supply greater than type(uint256).max
            rewards[owner] += reward;

            // this only overflows if a token has a total supply greater than type(uint256).max
            // Accounting purposes for external contracts only
            tokenIdRewards[tokenId] += reward;
        }

        Stake storage stake = _stakes[tokenId][incentiveId];
        stake.secondsPerLiquidityInsideInitialX128 = 0;
        stake.liquidityNoOverflow = 0;
        if (liquidity >= type(uint96).max) stake.liquidityIfOverflow = 0;
        delete stakedIncentiveKey[tokenId];
        emit TokenUnstaked(tokenId, incentiveId);
    }

    /*//////////////////////////////////////////////////////////////
                            STAKE TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function stakeToken(uint256 tokenId) external override {
        if (deposits[tokenId].stakedTimestamp != 0) revert TokenStakedError();

        (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) =
            NFTPositionInfo.getPositionInfo(factory, nonfungiblePositionManager, tokenId);

        _stakeToken(tokenId, pool, tickLower, tickUpper, liquidity);
    }

    /// @dev Stakes a deposited token without doing an already staked in another position check
    function _stakeToken(uint256 tokenId, IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity)
        private
    {
        IncentiveKey memory key = IncentiveKey({pool: pool, startTime: IncentiveTime.computeStart(block.timestamp)});

        bytes32 incentiveId = IncentiveId.compute(key);

        if (incentives[incentiveId].totalRewardUnclaimed == 0) revert NonExistentIncentiveError();

        if (uint24(tickUpper - tickLower) < poolsMinimumWidth[pool]) revert RangeTooSmallError();
        if (liquidity == 0) revert NoLiquidityError();

        stakedIncentiveKey[tokenId] = key;

        // If user not attached to gauge, attach
        address tokenOwner = deposits[tokenId].owner;
        if (tokenOwner == address(0)) revert TokenNotDeposited();

        UniswapV3Gauge gauge = gauges[pool]; // saves another SLOAD if no tokenId is attached

        if (!hermesGaugeBoost.isUserGauge(tokenOwner, address(gauge))) {
            _userAttachements[tokenOwner][pool] = tokenId;
            gauge.attachUser(tokenOwner);
        }

        deposits[tokenId].stakedTimestamp = uint40(block.timestamp);
        incentives[incentiveId].numberOfStakes++;

        (, uint160 secondsPerLiquidityInsideX128,) = pool.snapshotCumulativesInside(tickLower, tickUpper);

        if (liquidity >= type(uint96).max) {
            _stakes[tokenId][incentiveId] = Stake({
                secondsPerLiquidityInsideInitialX128: secondsPerLiquidityInsideX128,
                liquidityNoOverflow: type(uint96).max,
                liquidityIfOverflow: liquidity
            });
        } else {
            Stake storage stake = _stakes[tokenId][incentiveId];
            stake.secondsPerLiquidityInsideInitialX128 = secondsPerLiquidityInsideX128;
            stake.liquidityNoOverflow = uint96(liquidity);
        }

        emit TokenStaked(tokenId, incentiveId, liquidity);
    }

    /*//////////////////////////////////////////////////////////////
                        GAUGE UPDATE LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUniswapV3Staker
    function updateGauges(IUniswapV3Pool uniswapV3Pool) external {
        address uniswapV3Gauge = address(uniswapV3GaugeFactory.strategyGauges(address(uniswapV3Pool)));

        if (uniswapV3Gauge == address(0)) revert InvalidGauge();

        if (address(gauges[uniswapV3Pool]) != uniswapV3Gauge) {
            emit GaugeUpdated(uniswapV3Pool, uniswapV3Gauge);

            gauges[uniswapV3Pool] = UniswapV3Gauge(uniswapV3Gauge);
            gaugePool[uniswapV3Gauge] = uniswapV3Pool;
        }

        updateBribeDepot(uniswapV3Pool);
        updatePoolMinimumWidth(uniswapV3Pool);
    }

    /// @inheritdoc IUniswapV3Staker
    function updateBribeDepot(IUniswapV3Pool uniswapV3Pool) public {
        address newDepot = address(gauges[uniswapV3Pool].multiRewardsDepot());
        if (newDepot != bribeDepots[uniswapV3Pool]) {
            bribeDepots[uniswapV3Pool] = newDepot;

            emit BribeDepotUpdated(uniswapV3Pool, newDepot);
        }
    }

    /// @inheritdoc IUniswapV3Staker
    function updatePoolMinimumWidth(IUniswapV3Pool uniswapV3Pool) public {
        uint24 minimumWidth = gauges[uniswapV3Pool].minimumWidth();
        if (minimumWidth != poolsMinimumWidth[uniswapV3Pool]) {
            poolsMinimumWidth[uniswapV3Pool] = minimumWidth;

            emit PoolMinimumWidthUpdated(uniswapV3Pool, minimumWidth);
        }
    }
}

