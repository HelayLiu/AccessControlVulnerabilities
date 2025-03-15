// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

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

// src/ulysses-omnichain/interfaces/IAnycallConfig.sol

/// IAnycallConfig interface of the anycall config
interface IAnycallConfig {
    function calcSrcFees(address _app, uint256 _toChainID, uint256 _dataLength) external view returns (uint256);

    function executionBudget(address _app) external view returns (uint256);

    function deposit(address _account) external payable;

    function withdraw(uint256 _amount) external;
}

// src/ulysses-omnichain/interfaces/IAnycallExecutor.sol

/// IAnycallExecutor interface of the anycall executor
interface IAnycallExecutor {
    function context() external view returns (address from, uint256 fromChainID, uint256 nonce);

    function execute(
        address _to,
        bytes calldata _data,
        address _from,
        uint256 _fromChainID,
        uint256 _nonce,
        uint256 _flags,
        bytes calldata _extdata
    ) external returns (bool success, bytes memory result);
}

// src/ulysses-omnichain/interfaces/IAnycallProxy.sol

/// IAnycallProxy interface of the anycall proxy
interface IAnycallProxy {
    function executor() external view returns (address);

    function config() external view returns (address);

    function anyCall(address _to, bytes calldata _data, uint256 _toChainID, uint256 _flags, bytes calldata _extdata)
        external
        payable;

    function anyCall(
        string calldata _to,
        bytes calldata _data,
        uint256 _toChainID,
        uint256 _flags,
        bytes calldata _extdata
    ) external payable;
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

// src/ulysses-omnichain/interfaces/IERC20hTokenRoot.sol

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
    function localChainId() external view returns (uint256);

    /// @notice View Function returns Root Port Address.
    function rootPortAddress() external view returns (address);

    /// @notice View Function returns Local Branch Port Address.
    function localBranchPortAddress() external view returns (address);

    /// @notice View Function returns the address of the Factory that deployed this token.
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
     * @param value Amount of hTokens to be burned.
     * @param chainId Identifier of the Branch Chain.
     */
    function burn(address from, uint256 value, uint256 chainId) external;

    /*///////////////////////////////////////////////////////////////
                                ERRORS 
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedPort();
}

// src/ulysses-omnichain/interfaces/IWETH9.sol

interface WETH9 {
    function withdraw(uint256 wad) external;

    function deposit() external payable;

    function balanceOf(address guy) external view returns (uint256 wad);

    function transfer(address dst, uint256 wad) external;
}

// src/ulysses-omnichain/lib/AnycallFlags.sol

/// @title Anycall flags library
library AnycallFlags {
    // call flags which can be specified by user
    uint256 public constant FLAG_NONE = 0x0;
    uint256 public constant FLAG_MERGE_CONFIG_FLAGS = 0x1;
    uint256 public constant FLAG_PAY_FEE_ON_DEST = 0x1 << 1;
    uint256 public constant FLAG_ALLOW_FALLBACK = 0x1 << 2;
    uint256 public constant FLAG_ALLOW_FALLBACK_DST = 6;

    // exec flags used internally
    uint256 public constant FLAG_EXEC_START_VALUE = 0x1 << 16;
    uint256 public constant FLAG_EXEC_FALLBACK = 0x1 << 16;
}

// src/ulysses-omnichain/interfaces/IBranchBridgeAgent.sol

struct UserFeeInfo_0 {
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

struct DepositParams_0 {
    //Deposit Info
    uint32 depositNonce; //Deposit nonce.
    address hToken; //Input Local hTokens Address.
    address token; //Input Native / underlying Token Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
    uint128 depositedGas; //BRanch chain gas token amount sent with request.
}

struct DepositMultipleParams_0 {
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

struct SettlementParams_0 {
    uint32 settlementNonce;
    address recipient;
    address hToken;
    address token;
    uint256 amount;
    uint256 deposit;
}

struct SettlementMultipleParams_0 {
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
        returns (SettlementMultipleParams_0 memory);

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

// src/ulysses-omnichain/interfaces/IRootBridgeAgent.sol

/*///////////////////////////////////////////////////////////////
                            STRUCTS
//////////////////////////////////////////////////////////////*/

struct SwapCallbackData {
    address tokenIn; //Token being sold
}

struct UserFeeInfo_1 {
    uint128 depositedGas; //Gas deposited by user
    uint128 gasToBridgeOut; //Gas to be sent to bridge
}

struct GasPoolInfo_0 {
    //zeroForOne when swapping gas from branch chain into root chain gas
    bool zeroForOneOnInflow;
    uint24 priceImpactPercentage; //Price impact percentage
    address poolAddress; //Uniswap V3 Pool Address
}

enum SettlementStatus {
    Success, //Settlement was successful
    Failed //Settlement failed
}

struct Settlement {
    uint24 toChain; //Destination chain for interaction.
    uint128 gasToBridgeOut; //Gas owed to user
    address owner; //Owner of the settlement
    address recipient; //Recipient of the settlement.
    SettlementStatus status; //Status of the settlement
    address[] hTokens; //Input Local hTokens Addresses.
    address[] tokens; //Input Native / underlying Token Addresses.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
    bytes callData; //Call data for settlement
}

struct SettlementParams_1 {
    uint32 settlementNonce; //Settlement nonce.
    address recipient; //Recipient of the settlement.
    address hToken; //Input Local hTokens Address.
    address token; //Input Native / underlying Token Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
}

struct SettlementMultipleParams_1 {
    uint8 numberOfAssets; //Number of assets to deposit.
    uint32 settlementNonce; //Settlement nonce.
    address recipient; //Recipient of the settlement.
    address[] hTokens; //Input Local hTokens Addresses.
    address[] tokens; //Input Native / underlying Token Addresses.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
}

struct DepositParams_1 {
    //Deposit Info
    uint32 depositNonce; //Deposit nonce.
    address hToken; //Input Local hTokens Address.
    address token; //Input Native / underlying Token Address.
    uint256 amount; //Amount of Local hTokens deposited for interaction.
    uint256 deposit; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
}

struct DepositMultipleParams_1 {
    //Deposit Info
    uint8 numberOfAssets; //Number of assets to deposit.
    uint32 depositNonce; //Deposit nonce.
    address[] hTokens; //Input Local hTokens Address.
    address[] tokens; //Input Native / underlying Token Address.
    uint256[] amounts; //Amount of Local hTokens deposited for interaction.
    uint256[] deposits; //Amount of native tokens deposited for interaction.
    uint24 toChain; //Destination chain for interaction.
}

/**
 * @title  Root Bridge Agent Contract
 * @author MaiaDAO
 * @notice Contract responsible for interfacing with Users and Routers acting as a middleman to
 *         access Anycall cross-chain messaging and Port communication for asset management.
 * @dev    Bridge Agents allow for the encapsulation of business logic as well as the standardize
 *         cross-chain communication, allowing for the creation of custom Routers to perform
 *         actions as a response to remote user requests. This contract is for deployment in the Root
 *         Chain Omnichain Environment based on Arbitrum.
 *         This contract manages gas spenditure calling `_replenishingGas` after each remote initiated
 *         execution, as well as requests tokens clearances and tx execution from the `RootBridgeAgentExecutor`.
 *         Remote execution is "sandboxed" in 3 different nestings:
 *         - 1: Anycall Messaging Layer will revert execution if by the end of the call the
 *              balance in the executionBudget AnycallConfig contract to the Root Bridge Agent
 *              being called is inferior to the  executionGasSpent, throwing the error `no enough budget`.
 *         - 2: The `RootBridgeAgent` will trigger a revert all state changes if by the end of the remote initiated call
 *              Router interaction the userDepositedGas < executionGasSpent. This is done by calling the `_forceRevert()`
 *              internal function clearing all executionBudget from the AnycallConfig contract forcing the error `no enough budget`.
 *         - 3: The `RootBridgeAgentExecutor` is in charge of requesting token deposits for each remote interaction as well
 *              as performing the Router calls, if any of the calls initiated by the Router lead to an invlaid state change
 *              both the token deposit clearances as well as the external interactions will be reverted. Yet executionGas
 *              will still be credited by the `RootBridgeAgent`.
 *
 *          Func IDs for calling these  functions through messaging layer:
 *
 *          ROOT BRIDGE AGENT DEPOSIT FLAGS
 *          --------------------------------------
 *          ID           | DESCRIPTION
 *          -------------+------------------------
 *          0x00         | Branch Router Response.
 *          0x01         | Call to Root Router without Deposit.
 *          0x02         | Call to Root Router with Deposit.
 *          0x03         | Call to Root Router with Deposit of Multiple Tokens.
 *          0x04         | Call to Root Router without Deposit + singned message.
 *          0x05         | Call to Root Router with Deposit + singned message.
 *          0x06         | Call to Root Router with Deposit of Multiple Tokens + singned message.
 *          0x07         | Call to `retrySettlement()´. (retries sending a settlement + calldata for branch execution with new gas)
 *          0x08         | Call to `clearDeposit()´. (clears a deposit that has not been executed yet triggering `anyFallback`)
 *
 *
 *          Encoding Scheme for different Root Bridge Agent Deposit Flags:
 *
 *           - ht = hToken
 *           - t = Token
 *           - A = Amount
 *           - D = Destination
 *           - C = ChainId
 *           - b = bytes
 *           - n = number of assets
 *           ___________________________________________________________________________________________________________________________
 *          |            Flag               |        Deposit Info        |             Token Info             |   DATA   |  Gas Info   |
 *          |           1 byte              |         4-25 bytes         |     3 + (105 or 128) * n bytes     |   ---	 |  32 bytes   |
 *          |                               |                            |          hT - t - A - D - C        |          |             |
 *          |_______________________________|____________________________|____________________________________|__________|_____________|
 *          | callOutSystem = 0x0   	    |                 4b(nonce)  |            -------------           |   ---	 |  dep + bOut |
 *          | callOut = 0x1                 |                 4b(nonce)  |            -------------           |   ---	 |  dep + bOut |
 *          | callOutSingle = 0x2           |                 4b(nonce)  |      20b + 20b + 32b + 32b + 3b    |   ---	 |  16b + 16b  |
 *          | callOutMulti = 0x3            |         1b(n) + 4b(nonce)  |   	32b + 32b + 32b + 32b + 3b    |   ---	 |  16b + 16b  |
 *          | callOutSigned = 0x4           |    20b(recip) + 4b(nonce)  |   	      -------------           |   ---    |  16b + 16b  |
 *          | callOutSignedSingle = 0x5     |           20b + 4b(nonce)  |      20b + 20b + 32b + 32b + 3b 	  |   ---	 |  16b + 16b  |
 *          | callOutSignedMultiple = 0x6   |   20b + 1b(n) + 4b(nonce)  |      32b + 32b + 32b + 32b + 3b 	  |   ---	 |  16b + 16b  |
 *          |_______________________________|____________________________|____________________________________|__________|_____________|
 *
 *          Contract Interaction Flows:
 *
 *          - 1) Remote to Remote:
 *                  RootBridgeAgent.anyExecute**() -> BridgeAgentExecutor.execute**() -> Router.anyExecute**() -> BridgeAgentExecutor (txExecuted) -> RootBridgeAgent (replenishedGas)
 *
 *          - 2) Remote to Arbitrum:
 *                  RootBridgeAgent.anyExecute**() -> BridgeAgentExecutor.execute**() -> Router.anyExecute**() -> BridgeAgentExecutor (txExecuted) -> RootBridgeAgent (replenishedGas)
 *
 *          - 3) Arbitrum to Arbitrum:
 *                  RootBridgeAgent.anyExecute**() -> BridgeAgentExecutor.execute**() -> Router.anyExecute**() -> BridgeAgentExecutor (txExecuted)
 *
 */
interface IRootBridgeAgent is IApp {
    /*///////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice External function to get the intial gas available for remote request execution.
     *   @return uint256 Initial gas available for remote request execution.
     */
    function initialGas() external view returns (uint256);

    /**
     * @notice External get gas fee details for current remote request being executed.
     *   @return uint256 Gas fee for remote request execution.
     *   @return uint256 Gas fee for remote request execution.
     */
    function userFeeInfo() external view returns (uint128, uint128);

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
     * @notice External function to verify a given chain has been allowed by the Root Bridge Agent's Manager for new Branch Bridge Agent creation.
     *   @param _chainId Chain ID of the Branch Bridge Agent.
     *   @return bool True if the chain has been allowed for new Branch Bridge Agent creation.
     */
    function isBranchBridgeAgentAllowed(uint256 _chainId) external view returns (bool);

    /*///////////////////////////////////////////////////////////////
                            REMOTE CALL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice External function performs call to AnycallProxy Contract for cross-chain messaging.
     *   @param _recipient address to receive any outstanding gas on the destination chain.
     *   @param _calldata Calldata for function call.
     *   @param _toChain Chain to bridge to.
     *   @dev Internal function performs call to AnycallProxy Contract for cross-chain messaging.
     */
    function callOut(address _recipient, bytes memory _calldata, uint24 _toChain) external payable;

    /**
     * @notice External function to move assets from root chain to branch omnichain envirsonment.
     *   @param _owner address allowed for redeeming assets after a failed settlement fallback. This address' Virtual Account is also allowed.
     *   @param _recipient recipient of bridged tokens and any outstanding gas on the destination chain.
     *   @param _data parameters for function call on branch chain.
     *   @param _globalAddress global token to be moved.
     *   @param _amount amount of ´token´.
     *   @param _deposit amount of native / underlying token.
     *   @param _toChain chain to bridge to.
     *
     */
    function callOutAndBridge(
        address _owner,
        address _recipient,
        bytes memory _data,
        address _globalAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) external payable;

    /**
     * @notice External function to move assets from branch chain to root omnichain environment.
     *   @param _owner address allowed for redeeming assets after a failed settlement fallback. This address' Virtual Account is also allowed.
     *   @param _recipient recipient of bridged tokens.
     *   @param _data parameters for function call on branch chain.
     *   @param _globalAddresses global tokens to be moved.
     *   @param _amounts amounts of token.
     *   @param _deposits amounts of underlying / token.
     *   @param _toChain chain to bridge to.
     *
     *
     */
    function callOutAndBridgeMultiple(
        address _owner,
        address _recipient,
        bytes memory _data,
        address[] memory _globalAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        uint24 _toChain
    ) external payable;

    /*///////////////////////////////////////////////////////////////
                        TOKEN MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to move assets from branch chain to root omnichain environment. Called in response to Bridge Agent Executor.
     *   @param _dParams Cross-Chain Deposit of Multiple Tokens Params.
     *   @param _fromChain chain to bridge from.
     *
     */
    function bridgeIn(address _recipient, DepositParams_1 memory _dParams, uint24 _fromChain) external;

    /**
     * @notice Function to move assets from branch chain to root omnichain environment. Called in response to Bridge Agent Executor.
     *   @param _dParams Cross-Chain Deposit of Multiple Tokens Params.
     *   @param _fromChain chain to bridge from.
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
    function bridgeInMultiple(address _recipient, DepositMultipleParams_1 memory _dParams, uint24 _fromChain) external;

    /*///////////////////////////////////////////////////////////////
                        SETTLEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function that returns the current settlement nonce.
     *   @return nonce bridge agent's current settlement nonce
     *
     */
    function settlementNonce() external view returns (uint32 nonce);

    /**
     * @notice Function that allows redemption of failed Settlement's global tokens.
     *   @param _depositNonce Identifier for token deposit.
     *
     */
    function redeemSettlement(uint32 _depositNonce) external;

    /**
     * @notice Function to retry a user's Settlement balance.
     *   @param _settlementNonce Identifier for token settlement.
     *   @param _remoteExecutionGas Identifier for token settlement.
     *
     */
    function retrySettlement(uint32 _settlementNonce, uint128 _remoteExecutionGas) external payable;

    /**
     * @notice External function that returns a given settlement entry.
     *   @param _settlementNonce Identifier for token settlement.
     *
     */
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory);

    /**
     * @notice Updates the address of the branch bridge agent
     *   @param _newBranchBridgeAgent address of the new branch bridge agent
     *   @param _branchChainId chainId of the branch chain
     */
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint24 _branchChainId) external;

    /*///////////////////////////////////////////////////////////////
                            GAS SWAP FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks if a pool is eligible to call uniswapV3SwapCallback
     *   @param amount0 amount of token0 to swap
     *   @param amount1 amount of token1 to swap
     *   @param _data abi encoded data
     */
    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata _data) external;

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

    /**
     * @notice Function to collect excess gas fees.
     *   @dev only callable by the DAO.
     */
    function sweep() external;

    /*///////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new branch bridge agent to a given branch chainId
     *   @param _branchChainId chainId of the branch chain
     */
    function approveBranchBridgeAgent(uint256 _branchChainId) external;

    /*///////////////////////////////////////////////////////////////
                             EVENTS
    //////////////////////////////////////////////////////////////*/

    event LogCallin(bytes1 selector, bytes data, uint24 fromChainId);
    event LogCallout(bytes1 selector, bytes data, uint256, uint24 toChainId);
    event LogCalloutFail(bytes1 selector, bytes data, uint24 toChainId);

    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error GasErrorOrRepeatedTx();

    error NotDao();
    error AnycallUnauthorizedCaller();

    error AlreadyAddedBridgeAgent();
    error UnrecognizedExecutor();
    error UnrecognizedPort();
    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentManager();
    error UnrecognizedCallerNotRouter();

    error UnrecognizedUnderlyingAddress();
    error UnrecognizedLocalAddress();
    error UnrecognizedGlobalAddress();
    error UnrecognizedAddressInDestination();

    error SettlementRedeemUnavailable();
    error NotSettlementOwner();

    error InsufficientBalanceForSettlement();
    error InsufficientGasForFees();
    error InvalidInputParams();
    error InvalidGasPool();

    error CallerIsNotPool();
    error AmountsAreZero();
}

// src/ulysses-omnichain/interfaces/IVirtualAccount.sol

/// @notice Interface for the `Multicall2` contract.
struct Call {
    address target;
    bytes callData;
}

/**
 * @title  Virtual Account Contract
 * @notice A Virtual Account allows users to manage assets and perform interactions remotely while allowing dApps to keep encapsulated user balance for accounting purposes.
 * @dev    This contract is based off Maker's `Multicall2` contract, executes a set of `Call` objects if any of the perfomed call is invalid the whole batch should revert.
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
     * @notice
     * @param callInput The call to make.
     */
    function call(Call[] calldata callInput) external returns (uint256 blockNumber, bytes[] memory);

    /*///////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error CallFailed();

    error UnauthorizedCaller();
}

// src/ulysses-omnichain/interfaces/IRootRouter.sol

/**
 * @title  Root Router Contract
 * @author MaiaDAO
 * @notice Base Branch Contract for interfacing with Root Bridge Agents.
 *         This contract for deployment in the Root Chain of the Ulysses Omnichain System,
 *         additional logic can be implemented to perform actions before sending cross-chain
 *         requests to Branch Chains, as well as in response to remote requests.
 */
interface IRootRouter {
    /*///////////////////////////////////////////////////////////////
                        ANYCALL FUNCTIONS
    ///////////////////////////////////////////////////////////////*/

    /**
     *     @notice Function to execute Branch Bridge Agent system initiated requests with no asset deposit.
     *     @param funcId 1 byte called Router function identifier.
     *     @param encodedData data received from messaging layer.
     *     @param fromChainId chain where the request originated from.
     *
     */
    function anyExecuteResponse(bytes1 funcId, bytes memory encodedData, uint24 fromChainId)
        external
        payable
        returns (bool success, bytes memory result);

    /**
     *     @notice Function responsible of executing a crosschain request without any deposit.
     *     @param funcId 1 byte Router function identifier.
     *     @param encodedData data received from messaging layer.
     *     @param fromChainId chain where the request originated from.
     *
     */
    function anyExecute(bytes1 funcId, bytes memory encodedData, uint24 fromChainId)
        external
        payable
        returns (bool success, bytes memory result);

    /**
     *   @notice Function responsible of executing a crosschain request which contains cross-chain deposit information attached.
     *   @param funcId 1 byte Router function identifier.
     *   @param encodedData execution data received from messaging layer.
     *   @param dParams cross-chain deposit information.
     *   @param fromChainId chain where the request originated from.
     *
     */
    function anyExecuteDepositSingle(
        bytes1 funcId,
        bytes memory encodedData,
        DepositParams_1 memory dParams,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);

    /**
     *   @notice Function responsible of executing a crosschain request which contains cross-chain deposit information for multiple assets attached.
     *   @param funcId 1 byte Router function identifier.
     *   @param encodedData execution data received from messaging layer.
     *   @param dParams cross-chain multiple deposit information.
     *   @param fromChainId chain where the request originated from.
     *
     */
    function anyExecuteDepositMultiple(
        bytes1 funcId,
        bytes memory encodedData,
        DepositMultipleParams_1 memory dParams,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);

    /**
     * @notice Function responsible of executing a crosschain request with msg.sender without any deposit.
     * @param funcId 1 byte Router function identifier.
     * @param encodedData execution data received from messaging layer.
     * @param userAccount user account address.
     * @param fromChainId chain where the request originated from.
     */
    function anyExecuteSigned(bytes1 funcId, bytes memory encodedData, address userAccount, uint24 fromChainId)
        external
        payable
        returns (bool success, bytes memory result);

    /**
     * @notice Function responsible of executing a crosschain request which contains cross-chain deposit information and msg.sender attached.
     * @param funcId 1 byte Router function identifier.
     * @param encodedData execution data received from messaging layer.
     * @param dParams cross-chain deposit information.
     * @param userAccount user account address.
     * @param fromChainId chain where the request originated from.
     */
    function anyExecuteSignedDepositSingle(
        bytes1 funcId,
        bytes memory encodedData,
        DepositParams_1 memory dParams,
        address userAccount,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);

    /**
     * @notice Function responsible of executing a crosschain request which contains cross-chain deposit information for multiple assets and msg.sender attached.
     * @param funcId 1 byte Router function identifier.
     * @param encodedData execution data received from messaging layer.
     * @param dParams cross-chain multiple deposit information.
     * @param userAccount user account address.
     * @param fromChainId chain where the request originated from.
     */
    function anyExecuteSignedDepositMultiple(
        bytes1 funcId,
        bytes memory encodedData,
        DepositMultipleParams_1 memory dParams,
        address userAccount,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);

    /*///////////////////////////////////////////////////////////////
                             ERRORS
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedBridgeAgentExecutor();
}

// src/ulysses-omnichain/VirtualAccount.sol

/// @title VirtualAccount - Contract for managing a virtual user account on the Root Chain
contract VirtualAccount is IVirtualAccount {
    using SafeTransferLib for address;

    /// @inheritdoc IVirtualAccount
    address public immutable userAddress;

    /// @inheritdoc IVirtualAccount
    address public localPortAddress;

    constructor(address _userAddress, address _localPortAddress) {
        userAddress = _userAddress;
        localPortAddress = _localPortAddress;
    }

    /// @inheritdoc IVirtualAccount
    function withdrawERC20(address _token, uint256 _amount) external requiresApprovedCaller {
        _token.safeTransfer(msg.sender, _amount);
    }

    /// @inheritdoc IVirtualAccount
    function withdrawERC721(address _token, uint256 _tokenId) external requiresApprovedCaller {
        ERC721(_token).transferFrom(address(this), msg.sender, _tokenId);
    }

    /// @inheritdoc IVirtualAccount
    function call(Call[] calldata calls)
        external
        requiresApprovedCaller
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory data) = calls[i].target.call(calls[i].callData);
            if (!success) revert CallFailed();
            returnData[i] = data;
        }
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL HOOKS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC721Receiver
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /*///////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Modifier that verifies msg sender is the approved to use the virtual account. Either the owner or an approved router.
    modifier requiresApprovedCaller() {
        if ((!IRootPort(localPortAddress).isRouterApproved(this, msg.sender)) && (msg.sender != userAddress)) {
            revert UnauthorizedCaller();
        }
        _;
    }
}

// src/ulysses-omnichain/interfaces/IRootPort.sol

/// @title Core Root Router Interface
interface ICoreRootRouter {
    function bridgeAgentAddress() external view returns (address);
    function hTokenFactoryAddress() external view returns (address);
}

/// @title Struct that contains the information of the Gas Pool - used for swapping in and out of a given Branch Chain's Gas Token.
struct GasPoolInfo_1 {
    bool zeroForOneOnInflow;
    uint24 priceImpactPercentage;
    address gasTokenGlobalAddress;
    address poolAddress;
}

/**
 * @title  Root Port - Omnichain Token Management Contract
 * @author MaiaDAO
 * @notice Ulyses `RootPort` implementation for Root Omnichain Environment deployment.
 *         This contract is used to manage the deposit and withdrawal of assets
 *         between the Root Omnichain Environment an every Branch Chain in response to
 *         Root Bridge Agents requests. Manages Bridge Agents and their factories as well as
 *         key governance enabled actions such as adding new chains and bridge agent factories.
 */
interface IRootPort {
    /*///////////////////////////////////////////////////////////////
                        BRIDGE AGENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getBridgeAgentManager(address _rootBridgeAgent) external view returns (address);

    /*///////////////////////////////////////////////////////////////
                        VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function isChainId(uint256 _chainId) external view returns (bool);

    function isBridgeAgentFactory(address _bridgeAgentFactory) external view returns (bool);

    function isGlobalAddress(address _globalAddress) external view returns (bool);

    /// @notice Mapping from Underlying Address to isUnderlying (bool).
    function isRouterApproved(VirtualAccount _userAccount, address _router) external returns (bool);

    /**
     * @notice View Function returns Token's Global Address from it's local address.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _fromChain The chainId of the chain where the token is deployed.
     */
    function getGlobalTokenFromLocal(address _localAddress, uint256 _fromChain) external view returns (address);

    /**
     * @notice View Function returns Token's Local Address from it's global address.
     * @param _globalAddress The address of the token in the global chain.
     * @param _fromChain The chainId of the chain where the token is deployed.
     */
    function getLocalTokenFromGlobal(address _globalAddress, uint256 _fromChain) external view returns (address);

    /**
     * @notice View Function that returns the local token address from the underlying token address.
     *  @param _underlyingAddress The address of the underlying token.
     *  @param _fromChain The chainId of the chain where the token is deployed.
     */
    function getLocalTokenFromUnder(address _underlyingAddress, uint256 _fromChain) external view returns (address);

    /**
     * @notice Function that returns Local Token's Local Address on another chain.
     * @param _localAddress The address of the token in the local chain.
     * @param _fromChain The chainId of the chain where the token is deployed.
     * @param _toChain The chainId of the chain where the token is deployed.
     */
    function getLocalToken(address _localAddress, uint24 _fromChain, uint24 _toChain) external view returns (address);

    /**
     * @notice View Function returns a underlying token address from it's local address.
     * @param _localAddress The address of the token in the local chain.
     * @param _fromChain The chainId of the chain where the token is deployed.
     */
    function getUnderlyingTokenFromLocal(address _localAddress, uint256 _fromChain) external view returns (address);

    /**
     * @notice Returns the underlying token address given it's global address.
     * @param _globalAddress The address of the token in the global chain.
     * @param _fromChain The chainId of the chain where the token is deployed.
     */
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint24 _fromChain) external view returns (address);

    /**
     * @notice View Function returns True if Global Token is already added in current chain, false otherwise.
     * @param _globalAddress The address of the token in the global chain.
     * @param _fromChain The chainId of the chain where the token is deployed.
     */
    function isGlobalToken(address _globalAddress, uint24 _fromChain) external view returns (bool);

    /**
     * @notice View Function returns True if Local Token is already added in current chain, false otherwise.
     *  @param _localAddress The address of the token in the local chain.
     *  @param _fromChain The chainId of the chain where the token is deployed.
     */
    function isLocalToken(address _localAddress, uint24 _fromChain) external view returns (bool);

    /// @notice View Function returns True if Local Token and is also already added in another branch chain, false otherwise.
    function isLocalToken(address _localAddress, uint24 _fromChain, uint24 _toChain) external view returns (bool);

    /**
     * @notice View Function returns True if the underlying Token is already added in current chain, false otherwise.
     * @param _underlyingToken The address of the underlying token.
     * @param _fromChain The chainId of the chain where the token is deployed.
     */
    function isUnderlyingToken(address _underlyingToken, uint24 _fromChain) external view returns (bool);

    /// @notice View Function returns wrapped native token address for a given chain.
    function getWrappedNativeToken(uint256 _chainId) external view returns (address);

    /// @notice View Function returns the gasPoolAddress for a given chain.
    function getGasPoolInfo(uint256 _chainId)
        external
        view
        returns (
            bool zeroForOneOnInflow,
            uint24 priceImpactPercentage,
            address gasTokenGlobalAddress,
            address poolAddress
        );

    function getUserAccount(address _user) external view returns (VirtualAccount);

    /*///////////////////////////////////////////////////////////////
                        hTOKEN ACCOUTING FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Burns hTokens from the sender address.
     * @param _from sender of the hTokens to burn.
     * @param _hToken address of the hToken to burn.
     * @param _amount amount of hTokens to burn.
     * @param _fromChain The chainId of the chain where the token is deployed.
     */
    function burn(address _from, address _hToken, uint256 _amount, uint24 _fromChain) external;

    /**
     * @notice Updates root port state to match a new deposit.
     * @param _recipient recipient of bridged tokens.
     * @param _hToken address of the hToken to bridge.
     * @param _amount amount of hTokens to bridge.
     * @param _deposit amount of underlying tokens to deposit.
     * @param _fromChainId The chainId of the chain where the token is deployed.
     */
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint24 _fromChainId)
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
    function setAddresses(address _globalAddress, address _localAddress, address _underlyingAddress, uint24 _fromChain)
        external;

    /**
     * @notice Setter function to update a Global hToken's Local hToken Address.
     *   @param _globalAddress new hToken address to update.
     *   @param _localAddress new underlying/native token address to set.
     *
     */
    function setLocalAddress(address _globalAddress, address _localAddress, uint24 _fromChain) external;

    /*///////////////////////////////////////////////////////////////
                    VIRTUAL ACCOUNT MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the virtual account given a user address.
     * @param _user address of the user to get the virtual account for.
     */
    function fetchVirtualAccount(address _user) external returns (VirtualAccount account);

    /**
     * @notice Toggles the approval of a router for a virtual account. Allows for a router to spend a user's virtual account.
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
     * @param _fromChain chainId of the chain to set the bridge agent for.
     */
    function syncBranchBridgeAgentWithRoot(address _newBranchBridgeAgent, address _rootBridgeAgent, uint24 _fromChain)
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
     * @param _pledger address of the addNewChain proposal initial liquidity pledger.
     * @param _pledgedInitialAmount address of the core branch bridge agent
     * @param _coreBranchBridgeAgentAddress address of the core branch bridge agent
     * @param _chainId chainId of the new chain
     * @param _wrappedGasTokenName gas token name of the chain to add
     * @param _wrappedGasTokenSymbol gas token symbol of the chain to add
     * @param _fee fee of the chain to add
     * @param _priceImpactPercentage price impact percentage of the chain to add
     * @param _sqrtPriceX96 sqrt price of the chain to add
     * @param _nonFungiblePositionManagerAddress address of the NFT position manager
     * @param _newLocalBranchWrappedNativeTokenAddress address of the wrapped native token of the new branch
     * @param _newUnderlyingBranchWrappedNativeTokenAddress address of the underlying wrapped native token of the new branch
     */
    function addNewChain(
        address _pledger,
        uint256 _pledgedInitialAmount,
        address _coreBranchBridgeAgentAddress,
        uint24 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint24 _fee,
        uint24 _priceImpactPercentage,
        uint160 _sqrtPriceX96,
        address _nonFungiblePositionManagerAddress,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external;

    /**
     * @notice Sets the gas pool info for a chain
     * @param _chainId chainId of the chain to set the gas pool info for
     * @param _gasPoolInfo gas pool info to set
     */
    function setGasPoolInfo(uint24 _chainId, GasPoolInfo_1 calldata _gasPoolInfo) external;

    /**
     * @notice Adds an ecosystem hToken to a branch chain
     * @param ecoTokenGlobalAddress ecosystem token global address
     */
    function addEcosystemToken(address ecoTokenGlobalAddress) external;

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    event BridgeAgentFactoryAdded(address indexed bridgeAgentFactory);
    event BridgeAgentFactoryToggled(address indexed bridgeAgentFactory);

    event BridgeAgentAdded(address indexed bridgeAgent, address manager);
    event BridgeAgentToggled(address indexed bridgeAgent);
    event BridgeAgentSynced(address indexed bridgeAgent, address indexed rootBridgeAgent, uint24 indexed fromChain);

    event NewChainAdded(uint24 indexed chainId);
    event GasPoolInfoSet(uint24 indexed chainId, GasPoolInfo_1 gasPoolInfo);

    event VirtualAccountCreated(address indexed user, address account);

    event LocalTokenAdded(
        address indexed underlyingAddress, address localAddress, address globalAddress, uint24 chainId
    );
    event GlobalTokenAdded(address indexed localAddress, address indexed globalAddress, uint24 chainId);
    event EcosystemTokenAdded(address indexed ecoTokenGlobalAddress);

    /*///////////////////////////////////////////////////////////////
                            ERRORS  
    //////////////////////////////////////////////////////////////*/

    error UnrecognizedBridgeAgentFactory();
    error UnrecognizedBridgeAgent();

    error UnrecognizedToken();

    error AlreadyAddedEcosystemToken();

    error AlreadyAddedBridgeAgent();
    error BridgeAgentNotAllowed();
    error UnrecognizedCoreRootRouter();
    error UnrecognizedLocalBranchPort();
    error UnknowHTokenFactory();
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

// src/ulysses-omnichain/RootBridgeAgentExecutor.sol

/// @title Library for Root Bridge Agent Executor Deployment
library DeployRootBridgeAgentExecutor {
    function deploy(address _owner) external returns (address) {
        return address(new RootBridgeAgentExecutor(_owner));
    }
}

/**
 * @title  Root Bridge Agent Executor Contract
 * @notice This contract is used for requesting token settlement clearance and
 *         executing transaction requests from the branch chains.
 * @dev    Execution is "sandboxed" meaning upon tx failure both token settlements
 *         and interactions with external contracts should be reverted and caught.
 */
contract RootBridgeAgentExecutor is Ownable {
    /*///////////////////////////////////////////////////////////////
                            ENCODING CONSTS
    //////////////////////////////////////////////////////////////*/

    /// Remote Execution Consts

    uint8 internal constant PARAMS_START = 1;

    uint8 internal constant PARAMS_START_SIGNED = 21;

    uint8 internal constant PARAMS_END_OFFSET = 9;

    uint8 internal constant PARAMS_END_SIGNED_OFFSET = 29;

    uint8 internal constant PARAMS_ENTRY_SIZE = 32;

    uint8 internal constant PARAMS_ADDRESS_SIZE = 20;

    uint8 internal constant PARAMS_TKN_SET_SIZE = 104;

    uint8 internal constant PARAMS_TKN_SET_SIZE_MULTIPLE = 128;

    uint8 internal constant PARAMS_GAS_IN = 32;

    uint8 internal constant PARAMS_GAS_OUT = 16;

    /// BridgeIn Consts

    uint8 internal constant PARAMS_TKN_START = 5;

    uint8 internal constant PARAMS_AMT_OFFSET = 64;

    uint8 internal constant PARAMS_DEPOSIT_OFFSET = 96;

    constructor(address owner) {
        _initializeOwner(owner);
    }

    /*///////////////////////////////////////////////////////////////
                        EXECUTOR EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Execute a system request from a remote chain
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 0 (System request / response)
     */
    function executeSystemRequest(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Try to execute remote request
        (success, result) = IRootRouter(_router).anyExecuteResponse(
            bytes1(_data[PARAMS_TKN_START]), _data[6:_data.length - PARAMS_GAS_IN], _fromChainId
        );
    }

    /**
     * @notice Execute a remote request from a remote chain
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 1 (Call without Deposit)
     */
    function executeNoDeposit(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Execute remote request
        (success, result) =
            IRootRouter(_router).anyExecute(bytes1(_data[5]), _data[6:_data.length - PARAMS_GAS_IN], _fromChainId);
    }

    /**
     * @notice Execute a remote request from a remote chain
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 2 (Call with Deposit)
     */
    function executeWithDeposit(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Read Deposit Params
        DepositParams_1 memory dParams = DepositParams_1({
            depositNonce: uint32(bytes4(_data[PARAMS_START:PARAMS_TKN_START])),
            hToken: address(uint160(bytes20(_data[PARAMS_TKN_START:25]))),
            token: address(uint160(bytes20(_data[25:45]))),
            amount: uint256(bytes32(_data[45:77])),
            deposit: uint256(bytes32(_data[77:109])),
            toChain: uint24(bytes3(_data[109:112]))
        });

        //Bridge In Assets
        _bridgeIn(_router, dParams, _fromChainId);

        if (_data.length - PARAMS_GAS_IN > 112) {
            //Execute remote request
            (success, result) = IRootRouter(_router).anyExecuteDepositSingle(
                _data[112], _data[113:_data.length - PARAMS_GAS_IN], dParams, _fromChainId
            );
        } else {
            success = true;
        }
    }

    /**
     * @notice Execute a remote request from a remote chain
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 3 (Call with multiple asset Deposit)
     */
    function executeWithDepositMultiple(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Bridge In Assets and Save Deposit Params
        DepositMultipleParams_1 memory dParams = _bridgeInMultiple(
            _router,
            _data[
                PARAMS_START:
                    PARAMS_END_OFFSET + uint16(uint8(bytes1(_data[PARAMS_START]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
            ],
            _fromChainId
        );

        uint8 numOfAssets = uint8(bytes1(_data[PARAMS_START]));
        uint256 length = _data.length;

        if (
            length - PARAMS_GAS_IN
                > PARAMS_END_OFFSET + uint16(uint8(bytes1(_data[PARAMS_START]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
        ) {
            //Try to execute remote request
            (success, result) = IRootRouter(_router).anyExecuteDepositMultiple(
                bytes1(_data[PARAMS_END_OFFSET + uint16(numOfAssets) * PARAMS_TKN_SET_SIZE_MULTIPLE]),
                _data[
                    PARAMS_START + PARAMS_END_OFFSET + uint16(numOfAssets) * PARAMS_TKN_SET_SIZE_MULTIPLE:
                        length - PARAMS_GAS_IN
                ],
                dParams,
                _fromChainId
            );
        } else {
            success = true;
        }
    }

    /**
     * @notice Execute a remote request from a remote chain
     * @param _account The account that will execute the request
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 4 (Call without Deposit + msg.sender)
     */
    function executeSignedNoDeposit(address _account, address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Execute remote request
        (success, result) =
            IRootRouter(_router).anyExecuteSigned(_data[25], _data[26:_data.length - PARAMS_GAS_IN], _account, _fromChainId);
    }

    /**
     * @notice Execute a remote request from a remote chain with single asset deposit
     * @param _account The account that will execute the request
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 5 (Call with Deposit + msg.sender)
     */
    function executeSignedWithDeposit(address _account, address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Read Deposit Params
        DepositParams_1 memory dParams = DepositParams_1({
            depositNonce: uint32(bytes4(_data[PARAMS_START_SIGNED:25])),
            hToken: address(uint160(bytes20(_data[25:45]))),
            token: address(uint160(bytes20(_data[45:65]))),
            amount: uint256(bytes32(_data[65:97])),
            deposit: uint256(bytes32(_data[97:129])),
            toChain: uint24(bytes3(_data[129:132]))
        });

        //Bridge In Asset
        _bridgeIn(_account, dParams, _fromChainId);

        if (_data.length - PARAMS_GAS_IN > 132) {
            //Execute remote request
            (success, result) = IRootRouter(_router).anyExecuteSignedDepositSingle(
                _data[132], _data[133:_data.length - PARAMS_GAS_IN], dParams, _account, _fromChainId
            );
        } else {
            success = true;
        }
    }

    /**
     * @notice Execute a remote request from a remote chain with multiple asset deposit
     * @param _account The account that will execute the request
     * @param _router The router contract address
     * @param _data The encoded request data
     * @param _fromChainId The chain id of the chain that sent the request
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 6 (Call with multiple asset Deposit + msg.sender)
     */
    function executeSignedWithDepositMultiple(
        address _account,
        address _router,
        bytes calldata _data,
        uint24 _fromChainId
    ) external onlyOwner returns (bool success, bytes memory result) {
        //Bridge In Assets
        DepositMultipleParams_1 memory dParams = _bridgeInMultiple(
            _account,
            _data[
                PARAMS_START_SIGNED:
                    PARAMS_END_SIGNED_OFFSET
                        + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
            ],
            _fromChainId
        );

        {
            if (
                _data.length - PARAMS_GAS_IN
                    > PARAMS_END_SIGNED_OFFSET
                        + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
            ) {
                //Execute remote request
                (success, result) = IRootRouter(_router).anyExecuteSignedDepositMultiple(
                    _data[PARAMS_END_SIGNED_OFFSET
                        + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE],
                    _data[
                        PARAMS_START + PARAMS_END_SIGNED_OFFSET
                            + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE:
                            _data.length - PARAMS_GAS_IN
                    ],
                    dParams,
                    _account,
                    _fromChainId
                );
            } else {
                success = true;
            }
        }
    }

    /**
     * @notice Retry a settlement request that has not yet been executed in destination chain.
     * @param _settlementNonce The settlement nonce of the request to retry.
     * @return success Whether the request was successful
     * @return result The result of the request
     * @dev DEPOSIT FLAG: 7 (Retry Settlement)
     */
    function executeRetrySettlement(uint32 _settlementNonce)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        //Execute remote request
        RootBridgeAgent(payable(msg.sender)).retrySettlement(_settlementNonce, 0);
        //Trigger retry success (no guarantees about settlement success at this point)
        (success, result) = (true, "");
    }

    /**
     * @notice Internal function to move assets from branch chain to root omnichain environment.
     *   @param _dParams Cross-Chain Deposit of Multiple Tokens Params.
     *   @param _fromChain chain to bridge from.
     *
     */
    function _bridgeIn(address _recipient, DepositParams_1 memory _dParams, uint24 _fromChain) internal {
        //Request assets for decoded request.
        RootBridgeAgent(payable(msg.sender)).bridgeIn(_recipient, _dParams, _fromChain);
    }

    /**
     * @notice Internal function to move assets from branch chain to root omnichain environment.
     *   @param _dParams Cross-Chain Deposit of Multiple Tokens Params.
     *   @param _fromChain chain to bridge from.
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
    function _bridgeInMultiple(address _recipient, bytes calldata _dParams, uint24 _fromChain)
        internal
        returns (DepositMultipleParams_1 memory dParams)
    {
        // Parse Parameters
        uint8 numOfAssets = uint8(bytes1(_dParams[0]));
        uint32 nonce = uint32(bytes4(_dParams[PARAMS_START:5]));
        uint24 toChain = uint24(bytes3(_dParams[_dParams.length - 3:_dParams.length]));

        address[] memory hTokens = new address[](numOfAssets);
        address[] memory tokens = new address[](numOfAssets);
        uint256[] memory amounts = new uint256[](numOfAssets);
        uint256[] memory deposits = new uint256[](numOfAssets);

        for (uint256 i = 0; i < uint256(uint8(numOfAssets));) {
            //Parse Params
            hTokens[i] = address(
                uint160(
                    bytes20(
                        bytes32(
                            _dParams[
                                PARAMS_TKN_START + (PARAMS_ENTRY_SIZE * i) + 12:
                                    PARAMS_TKN_START + (PARAMS_ENTRY_SIZE * (PARAMS_START + i))
                            ]
                        )
                    )
                )
            );

            tokens[i] = address(
                uint160(
                    bytes20(
                        _dParams[
                            PARAMS_TKN_START + PARAMS_ENTRY_SIZE * uint16(i + numOfAssets) + 12:
                                PARAMS_TKN_START + PARAMS_ENTRY_SIZE * uint16(PARAMS_START + i + numOfAssets)
                        ]
                    )
                )
            );

            amounts[i] = uint256(
                bytes32(
                    _dParams[
                        PARAMS_TKN_START + PARAMS_AMT_OFFSET * uint16(numOfAssets) + (PARAMS_ENTRY_SIZE * uint16(i)):
                            PARAMS_TKN_START + PARAMS_AMT_OFFSET * uint16(numOfAssets)
                                + PARAMS_ENTRY_SIZE * uint16(PARAMS_START + i)
                    ]
                )
            );

            deposits[i] = uint256(
                bytes32(
                    _dParams[
                        PARAMS_TKN_START + PARAMS_DEPOSIT_OFFSET * uint16(numOfAssets) + (PARAMS_ENTRY_SIZE * uint16(i)):
                            PARAMS_TKN_START + PARAMS_DEPOSIT_OFFSET * uint16(numOfAssets)
                                + PARAMS_ENTRY_SIZE * uint16(PARAMS_START + i)
                    ]
                )
            );

            unchecked {
                ++i;
            }
        }

        //Save Deposit Multiple Params
        dParams = DepositMultipleParams_1({
            numberOfAssets: numOfAssets,
            depositNonce: nonce,
            hTokens: hTokens,
            tokens: tokens,
            amounts: amounts,
            deposits: deposits,
            toChain: toChain
        });

        RootBridgeAgent(payable(msg.sender)).bridgeInMultiple(_recipient, dParams, _fromChain);
    }
}

// src/ulysses-omnichain/RootBridgeAgent.sol

/// @title Library for Cross Chain Deposit Parameters Validation.
library CheckParamsLib {
    /**
     * @notice Function to check cross-chain deposit parameters and verify deposits made on branch chain are valid.
     * @param _localPortAddress Address of local Port.
     * @param _dParams Cross Chain swap parameters.
     * @param _fromChain Chain ID of the chain where the deposit was made.
     * @dev Local hToken must be recognized and address must match underlying if exists otherwise only local hToken is checked.
     *
     */
    function checkParams(address _localPortAddress, DepositParams_1 memory _dParams, uint24 _fromChain)
        internal
        view
        returns (bool)
    {
        if (
            (_dParams.amount < _dParams.deposit) //Deposit can't be greater than amount.
                || (_dParams.amount > 0 && !IRootPort(_localPortAddress).isLocalToken(_dParams.hToken, _fromChain)) //Check local exists.
                || (_dParams.deposit > 0 && !IRootPort(_localPortAddress).isUnderlyingToken(_dParams.token, _fromChain)) //Check underlying exists.
        ) {
            return false;
        }
        return true;
    }
}

/// @title Library for Root Bridge Agent Deployment.
library DeployRootBridgeAgent {
    function deploy(
        WETH9 _wrappedNativeToken,
        uint24 _localChainId,
        address _daoAddress,
        address _localAnyCallAddress,
        address _localAnyCallExecutorAddress,
        address _localPortAddress,
        address _localRouterAddress
    ) external returns (RootBridgeAgent) {
        return new RootBridgeAgent(
            _wrappedNativeToken,
            _localChainId,
            _daoAddress,
            _localAnyCallAddress,
            _localAnyCallExecutorAddress,
            _localPortAddress,
            _localRouterAddress
        );
    }
}

/// @title  Root Bridge Agent Contract
contract RootBridgeAgent is IRootBridgeAgent {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;

    /*///////////////////////////////////////////////////////////////
                            ENCODING CONSTS
    //////////////////////////////////////////////////////////////*/

    /// AnyExec Consts

    uint8 internal constant PARAMS_START = 1;

    uint8 internal constant PARAMS_START_SIGNED = 21;

    uint8 internal constant PARAMS_ADDRESS_SIZE = 20;

    uint8 internal constant PARAMS_GAS_IN = 32;

    uint8 internal constant PARAMS_GAS_OUT = 16;

    /// BridgeIn Consts

    uint8 internal constant PARAMS_TKN_START = 5;

    uint8 internal constant PARAMS_AMT_OFFSET = 64;

    uint8 internal constant PARAMS_DEPOSIT_OFFSET = 96;

    /*///////////////////////////////////////////////////////////////
                        ROOT BRIDGE AGENT STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Local Chain Id
    uint24 public immutable localChainId;

    /// @notice Local Wrapped Native Token
    WETH9 public immutable wrappedNativeToken;

    /// @notice Bridge Agent Factory Address.
    address public immutable factoryAddress;

    /// @notice Address of DAO.
    address public immutable daoAddress;

    /// @notice Local Core Root Router Address
    address public immutable localRouterAddress;

    /// @notice Address for Local Port Address where funds deposited from this chain are stored.
    address public immutable localPortAddress;

    /// @notice Local Anycall Address
    address public immutable localAnyCallAddress;

    /// @notice Local Anyexec Address
    address public immutable localAnyCallExecutorAddress;

    /// @notice Address of Root Bridge Agent Executor.
    address public immutable bridgeAgentExecutorAddress;

    /*///////////////////////////////////////////////////////////////
                    BRANCH BRIDGE AGENTS STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Chain -> Branch Bridge Agent Address. For N chains, each Root Bridge Agent Address has M =< N Branch Bridge Agent Address.
    mapping(uint256 => address) public getBranchBridgeAgent;

    /// @notice If true, bridge agent manager has allowed for a new given branch bridge agent to be synced/added.
    mapping(uint256 => bool) public isBranchBridgeAgentAllowed;

    /*///////////////////////////////////////////////////////////////
                        SETTLEMENTS STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit nonce used for identifying transaction.
    uint32 public settlementNonce;

    /// @notice Mapping from Settlement nonce to Deposit Struct.
    mapping(uint32 => Settlement) public getSettlement;

    /*///////////////////////////////////////////////////////////////
                            EXECUTOR STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice If true, bridge agent has already served a request with this nonce from  a given chain. Chain -> Nonce -> Bool
    mapping(uint256 => mapping(uint32 => bool)) public executionHistory;

    /*///////////////////////////////////////////////////////////////
                        GAS MANAGEMENT STATE
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MIN_FALLBACK_RESERVE = 155_000; // 100_000 for anycall + 55_000 for fallback
    uint256 internal constant MIN_EXECUTION_OVERHEAD = 155_000; // 100_000 for anycall + 30_000 Pre 1st Gas Checkpoint Execution + 25_000 Post last Gas Checkpoint Execution

    uint256 public initialGas;
    UserFeeInfo_1 public userFeeInfo;

    /*///////////////////////////////////////////////////////////////
                        DAO STATE
    //////////////////////////////////////////////////////////////*/

    uint256 public accumulatedFees;

    /**
     * @notice Constructor for Bridge Agent.
     *     @param _wrappedNativeToken Local Wrapped Native Token.
     *     @param _daoAddress Address of DAO.
     *     @param _localChainId Local Chain Id.
     *     @param _localAnyCallAddress Local Anycall Address.
     *     @param _localPortAddress Local Port Address.
     *     @param _localRouterAddress Local Port Address.
     */
    constructor(
        WETH9 _wrappedNativeToken,
        uint24 _localChainId,
        address _daoAddress,
        address _localAnyCallAddress,
        address _localAnyCallExecutorAddress,
        address _localPortAddress,
        address _localRouterAddress
    ) {
        require(address(_wrappedNativeToken) != address(0), "Wrapped native token cannot be zero address");
        require(_daoAddress != address(0), "DAO cannot be zero address");
        require(_localAnyCallAddress != address(0), "Anycall Address cannot be zero address");
        require(_localAnyCallExecutorAddress != address(0), "Anycall Executor Address cannot be zero address");
        require(_localPortAddress != address(0), "Port Address cannot be zero address");
        require(_localRouterAddress != address(0), "Router Address cannot be zero address");

        wrappedNativeToken = _wrappedNativeToken;
        factoryAddress = msg.sender;
        daoAddress = _daoAddress;
        localChainId = _localChainId;
        localAnyCallAddress = _localAnyCallAddress;
        localPortAddress = _localPortAddress;
        localRouterAddress = _localRouterAddress;
        bridgeAgentExecutorAddress = DeployRootBridgeAgentExecutor.deploy(address(this));
        localAnyCallExecutorAddress = _localAnyCallExecutorAddress;
        settlementNonce = 1;
        accumulatedFees = 1; //Avoid paying 20k gas in first `payExecutionGas` making MIN_EXECUTION_OVERHEAD constant.
    }

    /*///////////////////////////////////////////////////////////////
                        VIEW EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootBridgeAgent
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory) {
        return getSettlement[_settlementNonce];
    }

    /*///////////////////////////////////////////////////////////////
                        USER EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootBridgeAgent
    function retrySettlement(uint32 _settlementNonce, uint128 _remoteExecutionGas) external payable {
        //Update User Gas available.
        if (initialGas == 0) {
            userFeeInfo.depositedGas = uint128(msg.value);
            userFeeInfo.gasToBridgeOut = _remoteExecutionGas;
        }
        //Clear Settlement with updated gas.
        _retrySettlement(_settlementNonce);
    }

    /// @inheritdoc IRootBridgeAgent
    function redeemSettlement(uint32 _depositNonce) external lock {
        //Get deposit owner.
        address depositOwner = getSettlement[_depositNonce].owner;

        //Update Deposit
        if (getSettlement[_depositNonce].status != SettlementStatus.Failed || depositOwner == address(0)) {
            revert SettlementRedeemUnavailable();
        } else if (
            msg.sender != depositOwner && msg.sender != address(IRootPort(localPortAddress).getUserAccount(depositOwner))
        ) {
            revert NotSettlementOwner();
        }
        _redeemSettlement(_depositNonce);
    }

    /*///////////////////////////////////////////////////////////////
                    ROOT ROUTER EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootBridgeAgent
    function callOut(address _recipient, bytes memory _data, uint24 _toChain) external payable lock requiresRouter {
        //Encode Data for call.
        bytes memory data =
            abi.encodePacked(bytes1(0x00), _recipient, settlementNonce++, _data, _manageGasOut(_toChain));

        //Perform Call to clear hToken balance on destination branch chain.
        _performCall(data, _toChain);
    }

    /// @inheritdoc IRootBridgeAgent
    function callOutAndBridge(
        address _owner,
        address _recipient,
        bytes memory _data,
        address _globalAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) external payable lock requiresRouter {
        //Get destination Local Address from Global Address.
        address localAddress = IRootPort(localPortAddress).getLocalTokenFromGlobal(_globalAddress, _toChain);

        //Get destination Underlying Address from Local Address.
        address underlyingAddress = IRootPort(localPortAddress).getUnderlyingTokenFromLocal(localAddress, _toChain);

        //Check if valid assets
        if (localAddress == address(0) || (underlyingAddress == address(0) && _deposit > 0)) {
            revert InvalidInputParams();
        }

        //Prepare data for call
        bytes memory data = abi.encodePacked(
            bytes1(0x01),
            _recipient,
            settlementNonce,
            localAddress,
            underlyingAddress,
            _amount,
            _deposit,
            _data,
            _manageGasOut(_toChain)
        );

        //Update State to reflect bridgeOut
        _updateStateOnBridgeOut(
            msg.sender, _globalAddress, localAddress, underlyingAddress, _amount, _deposit, _toChain
        );

        //Create Settlement
        _createSettlement(_owner, _recipient, localAddress, underlyingAddress, _amount, _deposit, data, _toChain);

        //Perform Call to clear hToken balance on destination branch chain and perform call.
        _performCall(data, _toChain);
    }

    /// @inheritdoc IRootBridgeAgent
    function callOutAndBridgeMultiple(
        address _owner,
        address _recipient,
        bytes memory _data,
        address[] memory _globalAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        uint24 _toChain
    ) external payable lock requiresRouter {
        address[] memory hTokens = new address[](_globalAddresses.length);
        address[] memory tokens = new address[](_globalAddresses.length);
        for (uint256 i = 0; i < _globalAddresses.length;) {
            //Populate Addresses for Settlement
            hTokens[i] = IRootPort(localPortAddress).getLocalTokenFromGlobal(_globalAddresses[i], _toChain);
            tokens[i] = IRootPort(localPortAddress).getUnderlyingTokenFromLocal(hTokens[i], _toChain);

            if (hTokens[i] == address(0) || (tokens[i] == address(0) && _deposits[i] > 0)) revert InvalidInputParams();

            _updateStateOnBridgeOut(
                msg.sender, _globalAddresses[i], hTokens[i], tokens[i], _amounts[i], _deposits[i], _toChain
            );

            unchecked {
                ++i;
            }
        }

        //Prepare data for call with settlement of multiple assets
        bytes memory data = abi.encodePacked(
            bytes1(0x02),
            _recipient,
            uint8(hTokens.length),
            settlementNonce,
            hTokens,
            tokens,
            _amounts,
            _deposits,
            _data,
            _manageGasOut(_toChain)
        );

        //Create Settlement Balance
        _createMultipleSettlement(_owner, _recipient, hTokens, tokens, _amounts, _deposits, data, _toChain);

        //Perform Call to destination Branch Chain.
        _performCall(data, _toChain);
    }

    /*///////////////////////////////////////////////////////////////
                    TOKEN MANAGEMENT EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootBridgeAgent
    function bridgeIn(address _recipient, DepositParams_1 memory _dParams, uint24 _fromChain)
        public
        requiresAgentExecutor
    {
        //Check Deposit info from Cross Chain Parameters.
        if (!CheckParamsLib.checkParams(localPortAddress, _dParams, _fromChain)) {
            revert InvalidInputParams();
        }

        //Get global address
        address globalAddress = IRootPort(localPortAddress).getGlobalTokenFromLocal(_dParams.hToken, _fromChain);

        //Check if valid asset
        if (globalAddress == address(0)) revert InvalidInputParams();

        //Move hTokens from Branch to Root + Mint Sufficient hTokens to match new port deposit
        IRootPort(localPortAddress).bridgeToRoot(_recipient, globalAddress, _dParams.amount, _dParams.deposit, _fromChain);
    }

    /// @inheritdoc IRootBridgeAgent
    function bridgeInMultiple(address _recipient, DepositMultipleParams_1 memory _dParams, uint24 _fromChain)
        external
        requiresAgentExecutor
    {
        for (uint256 i = 0; i < _dParams.hTokens.length;) {
            bridgeIn(
                _recipient,
                DepositParams_1({
                    hToken: _dParams.hTokens[i],
                    token: _dParams.tokens[i],
                    amount: _dParams.amounts[i],
                    deposit: _dParams.deposits[i],
                    toChain: _dParams.toChain,
                    depositNonce: 0
                }),
                _fromChain
            );

            unchecked {
                ++i;
            }
        }
    }

    /*///////////////////////////////////////////////////////////////
                    TOKEN MANAGEMENT INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Updates the token balance state by moving assets from root omnichain environment to branch chain, when a user wants to bridge out tokens from the root bridge agent chain.
     *     @param _sender address of the sender.
     *     @param _globalAddress address of the global token.
     *     @param _localAddress address of the local token.
     *     @param _underlyingAddress address of the underlying token.
     *     @param _amount amount of hTokens to be bridged out.
     *     @param _deposit amount of underlying tokens to be bridged out.
     *     @param _toChain chain to bridge to.
     */
    function _updateStateOnBridgeOut(
        address _sender,
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) internal {
        if (_amount - _deposit > 0) {
            //Move output hTokens from Root to Branch
            if (_localAddress == address(0)) revert UnrecognizedLocalAddress();
            _globalAddress.safeTransferFrom(_sender, localPortAddress, _amount - _deposit);
        }

        if (_deposit > 0) {
            //Verify there is enough balance to clear native tokens if needed
            if (_underlyingAddress == address(0)) revert UnrecognizedUnderlyingAddress();
            if (IERC20hTokenRoot(_globalAddress).getTokenBalance(_toChain) < _deposit) {
                revert InsufficientBalanceForSettlement();
            }
            IRootPort(localPortAddress).burn(_sender, _globalAddress, _deposit, _toChain);
        }
    }

    /*///////////////////////////////////////////////////////////////
                SETTLEMENT INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Function to store a Settlement instance. Settlement should be reopened if fallback occurs.
     *    @param _owner settlement owner address.
     *    @param _recipient destination chain reciever address.
     *    @param _hToken deposited global token address.
     *    @param _token deposited global token address.
     *    @param _amount amounts of total hTokens + Tokens output.
     *    @param _deposit amount of underlying / native token to output.
     *    @param _callData calldata to execute on destination Router.
     *    @param _toChain Destination chain identificator.
     *
     */
    function _createSettlement(
        address _owner,
        address _recipient,
        address _hToken,
        address _token,
        uint256 _amount,
        uint256 _deposit,
        bytes memory _callData,
        uint24 _toChain
    ) internal {
        //Cast to Dynamic
        address[] memory hTokens = new address[](1);
        hTokens[0] = _hToken;
        address[] memory tokens = new address[](1);
        tokens[0] = _token;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;
        uint256[] memory deposits = new uint256[](1);
        deposits[0] = _deposit;

        //Call createSettlement
        _createMultipleSettlement(_owner, _recipient, hTokens, tokens, amounts, deposits, _callData, _toChain);
    }

    /**
     * @notice Function to create a settlemment. Settlement should be reopened if fallback occurs.
     *    @param _owner settlement owner address.
     *    @param _recipient destination chain reciever address.
     *    @param _hTokens deposited global token addresses.
     *    @param _tokens deposited global token addresses.
     *    @param _amounts amounts of total hTokens + Tokens output.
     *    @param _deposits amount of underlying / native tokens to output.
     *    @param _callData calldata to execute on destination Router.
     *    @param _toChain Destination chain identificator.
     *
     *
     */
    function _createMultipleSettlement(
        address _owner,
        address _recipient,
        address[] memory _hTokens,
        address[] memory _tokens,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        bytes memory _callData,
        uint24 _toChain
    ) internal {
        // Update State
        getSettlement[_getAndIncrementSettlementNonce()] = Settlement({
            owner: _owner,
            recipient: _recipient,
            hTokens: _hTokens,
            tokens: _tokens,
            amounts: _amounts,
            deposits: _deposits,
            callData: _callData,
            toChain: _toChain,
            status: SettlementStatus.Success,
            gasToBridgeOut: userFeeInfo.gasToBridgeOut
        });
    }

    /**
     * @notice Function to retry a user's Settlement balance with a new amount of gas to bridge out of Root Bridge Agent's Omnichain Environment.
     *    @param _settlementNonce Identifier for token settlement.
     *
     */
    function _retrySettlement(uint32 _settlementNonce) internal returns (bool) {
        //Get Settlement
        Settlement memory settlement = getSettlement[_settlementNonce];

        //Check if Settlement hasn't been redeemed.
        if (settlement.owner == address(0)) return false;

        //abi encodePacked
        bytes memory newGas = abi.encodePacked(_manageGasOut(settlement.toChain));

        //overwrite last 16bytes of callData
        for (uint256 i = 0; i < newGas.length;) {
            settlement.callData[settlement.callData.length - 16 + i] = newGas[i];
            unchecked {
                ++i;
            }
        }

        Settlement storage settlementReference = getSettlement[_settlementNonce];

        //Update Gas To Bridge Out
        settlementReference.gasToBridgeOut = userFeeInfo.gasToBridgeOut;

        //Set Settlement Calldata to send to Branch Chain
        settlementReference.callData = settlement.callData;

        //Update Settlement Staus
        settlementReference.status = SettlementStatus.Success;

        //Retry call with additional gas
        _performCall(settlement.callData, settlement.toChain);

        //Retry Success
        return true;
    }

    /**
     * @notice Function to retry a user's Settlement balance.
     *     @param _settlementNonce Identifier for token settlement.
     *
     */
    function _redeemSettlement(uint32 _settlementNonce) internal {
        // Get storage reference
        Settlement storage settlement = getSettlement[_settlementNonce];

        //Clear Global hTokens To Recipient on Root Chain cancelling Settlement to Branch
        for (uint256 i = 0; i < settlement.hTokens.length;) {
            //Check if asset
            if (settlement.hTokens[i] != address(0)) {
                //Move hTokens from Branch to Root + Mint Sufficient hTokens to match new port deposit
                IRootPort(localPortAddress).bridgeToRoot(
                    msg.sender,
                    IRootPort(localPortAddress).getGlobalTokenFromLocal(settlement.hTokens[i], settlement.toChain),
                    settlement.amounts[i],
                    settlement.deposits[i],
                    settlement.toChain
                );
            }

            unchecked {
                ++i;
            }
        }

        // Delete Settlement
        delete getSettlement[_settlementNonce];
    }

    /**
     * @notice Function to reopen a user's Settlement balance as pending and thus retryable by users. Called upon anyFallback of triggered by Branch Bridge Agent.
     *     @param _settlementNonce Identifier for token settlement.
     *
     */
    function _reopenSettlemment(uint32 _settlementNonce) internal {
        //Update Deposit
        getSettlement[_settlementNonce].status = SettlementStatus.Failed;
    }

    /**
     * @notice Function that returns Deposit nonce and increments nonce counter.
     *
     */
    function _getAndIncrementSettlementNonce() internal returns (uint32) {
        return settlementNonce++;
    }

    /*///////////////////////////////////////////////////////////////
                    GAS SWAP INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    uint24 private constant GLOBAL_DIVISIONER = 1e6; // for basis point (0.0001%)

    //Local mapping of valid gas pools
    mapping(address => bool) private approvedGasPool;

    /// @inheritdoc IRootBridgeAgent
    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata _data) external {
        if (!approvedGasPool[msg.sender]) revert CallerIsNotPool();
        if (amount0 == 0 && amount1 == 0) revert AmountsAreZero();
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));

        address(data.tokenIn).safeTransfer(msg.sender, uint256(amount0 > 0 ? amount0 : amount1));
    }

    /**
     * @notice Swaps gas tokens from the given branch chain to the root chain
     * @param _amount amount of gas token to swap
     * @param _fromChain chain to swap from
     */
    function _gasSwapIn(uint256 _amount, uint24 _fromChain) internal returns (uint256) {
        //Get fromChain's Gas Pool Info
        (bool zeroForOneOnInflow, uint24 priceImpactPercentage, address gasTokenGlobalAddress, address poolAddress) =
            IRootPort(localPortAddress).getGasPoolInfo(_fromChain);

        //Check if valid addresses
        if (gasTokenGlobalAddress == address(0) || poolAddress == address(0)) revert InvalidGasPool();

        //Move Gas hTokens from Branch to Root / Mint Sufficient hTokens to match new port deposit
        IRootPort(localPortAddress).bridgeToRoot(address(this), gasTokenGlobalAddress, _amount, _amount, _fromChain);

        //Save Gas Pool for future use
        if (!approvedGasPool[poolAddress]) approvedGasPool[poolAddress] = true;

        //Get sqrtPriceX96
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();

        // Calculate Price limit depending on pre-set price impact
        uint160 exactSqrtPriceImpact = (sqrtPriceX96 * (priceImpactPercentage / 2)) / GLOBAL_DIVISIONER;

        //Get limit
        uint160 sqrtPriceLimitX96 =
            zeroForOneOnInflow ? sqrtPriceX96 - exactSqrtPriceImpact : sqrtPriceX96 + exactSqrtPriceImpact;

        //Swap imbalanced token as long as we haven't used the entire amountSpecified and haven't reached the price limit
        try IUniswapV3Pool(poolAddress).swap(
            address(this),
            zeroForOneOnInflow,
            int256(_amount),
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({tokenIn: gasTokenGlobalAddress}))
        ) returns (int256 amount0, int256 amount1) {
            return uint256(zeroForOneOnInflow ? amount1 : amount0);
        } catch (bytes memory) {
            _forceRevert();
            return 0;
        }
    }

    /**
     * @notice Swaps gas tokens from the given root chain to the branch chain
     * @param _amount amount of gas token to swap
     * @param _toChain chain to swap to
     */
    function _gasSwapOut(uint256 _amount, uint24 _toChain) internal returns (uint256, address) {
        //Get fromChain's Gas Pool Info
        (bool zeroForOneOnInflow, uint24 priceImpactPercentage, address gasTokenGlobalAddress, address poolAddress) =
            IRootPort(localPortAddress).getGasPoolInfo(_toChain);

        //Check if valid addresses
        if (gasTokenGlobalAddress == address(0) || poolAddress == address(0)) revert InvalidGasPool();

        //Save Gas Pool for future use
        if (!approvedGasPool[poolAddress]) approvedGasPool[poolAddress] = true;

        uint160 sqrtPriceLimitX96;
        {
            //Get sqrtPriceX96
            (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();

            // Calculate Price limit depending on pre-set price impact
            uint160 exactSqrtPriceImpact = (sqrtPriceX96 * (priceImpactPercentage / 2)) / GLOBAL_DIVISIONER;

            //Get limit
            sqrtPriceLimitX96 =
                zeroForOneOnInflow ? sqrtPriceX96 + exactSqrtPriceImpact : sqrtPriceX96 - exactSqrtPriceImpact;
        }

        //Swap imbalanced token as long as we haven't used the entire amountSpecified and haven't reached the price limit
        (int256 amount0, int256 amount1) = IUniswapV3Pool(poolAddress).swap(
            address(this),
            !zeroForOneOnInflow,
            int256(_amount),
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({tokenIn: address(wrappedNativeToken)}))
        );

        return (uint256(!zeroForOneOnInflow ? amount1 : amount0), gasTokenGlobalAddress);
    }

    /**
     * @notice Manages gas costs of bridging from Root to a given Branch.
     * @param _toChain destination chain.
     */
    function _manageGasOut(uint24 _toChain) internal returns (uint128) {
        uint256 amountOut;
        address gasToken;
        uint256 _initialGas = initialGas;

        if (_toChain == localChainId) {
            //Transfer gasToBridgeOut Local Branch Bridge Agent if remote initiated call.
            if (_initialGas > 0) {
                address(wrappedNativeToken).safeTransfer(getBranchBridgeAgent[localChainId], userFeeInfo.gasToBridgeOut);
            }

            return uint128(userFeeInfo.gasToBridgeOut);
        }

        if (_initialGas > 0) {
            if (userFeeInfo.gasToBridgeOut <= MIN_FALLBACK_RESERVE * tx.gasprice) revert InsufficientGasForFees();
            (amountOut, gasToken) = _gasSwapOut(userFeeInfo.gasToBridgeOut, _toChain);
        } else {
            if (msg.value <= MIN_FALLBACK_RESERVE * tx.gasprice) revert InsufficientGasForFees();
            wrappedNativeToken.deposit{value: msg.value}();
            (amountOut, gasToken) = _gasSwapOut(msg.value, _toChain);
        }

        IRootPort(localPortAddress).burn(address(this), gasToken, amountOut, _toChain);
        return amountOut.toUint128();
    }

    /*///////////////////////////////////////////////////////////////
                    ANYCALL INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Internal function performs call to AnycallProxy Contract for cross-chain messaging.
    function _performCall(bytes memory _calldata, uint256 _toChain) internal {
        address callee = getBranchBridgeAgent[_toChain];

        if (callee == address(0)) revert UnrecognizedBridgeAgent();

        if (_toChain != localChainId) {
            //Sends message to AnycallProxy
            IAnycallProxy(localAnyCallAddress).anyCall(
                callee, _calldata, _toChain, AnycallFlags.FLAG_ALLOW_FALLBACK_DST, ""
            );
        } else {
            //Execute locally
            IBranchBridgeAgent(callee).anyExecute(_calldata);
        }
    }

    /**
     * @notice Pays for the remote call execution gas. Demands that the user has enough gas to replenish gas for the anycall config contract or forces reversion.
     * @param _depositedGas available user gas to pay for execution.
     * @param _gasToBridgeOut amount of gas needed to bridge out.
     * @param _initialGas initial gas used by the transaction.
     * @param _fromChain chain remote action initiated from.
     */
    function _payExecutionGas(uint128 _depositedGas, uint128 _gasToBridgeOut, uint256 _initialGas, uint24 _fromChain)
        internal
    {
        //reset initial remote execution gas and remote execution fee information
        delete(initialGas);
        delete(userFeeInfo);

        if (_fromChain == localChainId) return;

        //Get Available Gas
        uint256 availableGas = _depositedGas - _gasToBridgeOut;

        //Get Root Environment Execution Cost
        uint256 minExecCost = tx.gasprice * (MIN_EXECUTION_OVERHEAD + _initialGas - gasleft());

        //Check if sufficient balance
        if (minExecCost > availableGas) {
            _forceRevert();
            return;
        }

        //Replenish Gas
        _replenishGas(minExecCost);

        //Account for excess gas
        accumulatedFees += availableGas - minExecCost;
    }

    /**
     * @notice Updates the user deposit with the amount of gas needed to pay for the fallback function execution.
     * @param _settlementNonce nonce of the failed settlement
     * @param _initialGas initial gas available for this transaction
     */
    function _payFallbackGas(uint32 _settlementNonce, uint256 _initialGas) internal virtual {
        //Save gasleft
        uint256 gasLeft = gasleft();

        //Get Branch Environment Execution Cost
        uint256 minExecCost = tx.gasprice * (MIN_FALLBACK_RESERVE + _initialGas - gasLeft);

        //Check if sufficient balance
        if (minExecCost > getSettlement[_settlementNonce].gasToBridgeOut) {
            _forceRevert();
            return;
        }

        //Update user deposit reverts if not enough gas
        getSettlement[_settlementNonce].gasToBridgeOut -= minExecCost.toUint128();
    }

    function _replenishGas(uint256 _executionGasSpent) internal {
        //Unwrap Gas
        wrappedNativeToken.withdraw(_executionGasSpent);
        IAnycallConfig(IAnycallProxy(localAnyCallAddress).config()).deposit{value: _executionGasSpent}(address(this));
    }

    /// @notice Internal function that return 'from' address and 'fromChain' Id by performing an external call to AnycallExecutor Context.
    function _getContext() internal view returns (address from, uint256 fromChainId) {
        (from, fromChainId,) = IAnycallExecutor(localAnyCallExecutorAddress).context();
    }

    /// @inheritdoc IApp
    function anyExecute(bytes calldata data)
        external
        virtual
        requiresExecutor
        returns (bool success, bytes memory result)
    {
        //Get Initial Gas Checkpoint
        uint256 _initialGas = gasleft();

        uint24 fromChainId;

        UserFeeInfo_1 memory _userFeeInfo;

        if (localAnyCallExecutorAddress == msg.sender) {
            //Save initial gas
            initialGas = _initialGas;

            //Get fromChainId from AnyExecutor Context
            (, uint256 _fromChainId) = _getContext();

            //Save fromChainId
            fromChainId = _fromChainId.toUint24();

            //Swap in all deposited Gas
            _userFeeInfo.depositedGas = _gasSwapIn(
                uint256(uint128(bytes16(data[data.length - PARAMS_GAS_IN:data.length - PARAMS_GAS_OUT]))), fromChainId
            ).toUint128();

            //Save Gas to Swap out to destination chain
            _userFeeInfo.gasToBridgeOut = uint128(bytes16(data[data.length - PARAMS_GAS_OUT:data.length]));
        } else {
            //Local Chain initiated call
            fromChainId = localChainId;

            //Save depositedGas
            _userFeeInfo.depositedGas = uint128(bytes16(data[data.length - 32:data.length - 16]));

            //Save Gas to Swap out to destination chain
            _userFeeInfo.gasToBridgeOut = _userFeeInfo.depositedGas;
        }

        if (_userFeeInfo.depositedGas < _userFeeInfo.gasToBridgeOut) {
            _forceRevert();
            //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
            return (true, "Not enough gas to bridge out");
        }

        //Store User Fee Info
        userFeeInfo = _userFeeInfo;

        //Read Bridge Agent Action Flag attached from cross-chain message header.
        bytes1 flag = data[0];

        //DEPOSIT FLAG: 0 (System request / response)
        if (flag == 0x00) {
            //Get nonce
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSystemRequest(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                //Interaction failure trigger fallback
                (success, result) = (false, reason);
            }

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            //DEPOSIT FLAG: 1 (Call without Deposit)
        } else if (flag == 0x01) {
            //Get Deposit Nonce
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeNoDeposit(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                //No new asset deposit no need to trigger fallback
                (success, result) = (true, reason);
            }

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            //DEPOSIT FLAG: 2 (Call with Deposit)
        } else if (flag == 0x02) {
            //Get Deposit Nonce
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeWithDeposit(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            //DEPOSIT FLAG: 3 (Call with multiple asset Deposit)
        } else if (flag == 0x03) {
            //Get deposit nonce
            uint32 nonce = uint32(bytes4(data[2:6]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeWithDepositMultiple(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            //DEPOSIT FLAG: 4 (Call without Deposit + msg.sender)
        } else if (flag == 0x04) {
            //Get deposit nonce associated with request being processed
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Get User Virtual Account
            VirtualAccount userAccount = IRootPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );

            //Toggle Router Virtual Account use for tx execution
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedNoDeposit(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                //No new asset deposit no need to trigger fallback
                (success, result) = (true, reason);
            }

            //Toggle Router Virtual Account use for tx execution
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            //DEPOSIT FLAG: 5 (Call with Deposit + msg.sender)
        } else if (flag == 0x05) {
            //Get deposit nonce associated with request being processed
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Get User Virtual Account
            VirtualAccount userAccount = IRootPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );

            //Toggle Router Virtual Account use for tx execution
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedWithDeposit(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }

            //Toggle Router Virtual Account use for tx execution
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            //DEPOSIT FLAG: 6 (Call with multiple asset Deposit + msg.sender)
        } else if (flag == 0x06) {
            //Get nonce
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Get User Virtual Account
            VirtualAccount userAccount = IRootPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );

            //Toggle Router Virtual Account use for tx execution
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedWithDepositMultiple(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }

            //Toggle Router Virtual Account use for tx execution
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            /// DEPOSIT FLAG: 7 (retrySettlement)
        } else if (flag == 0x07) {
            //Get nonce
            uint32 nonce = uint32(bytes4(data[1:5]));

            //Check if tx has already been executed
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Try to execute remote request
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeRetrySettlement(uint32(bytes4(data[5:9])))
            returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }

            //Update tx state as executed
            executionHistory[fromChainId][nonce] = true;

            /// DEPOSIT FLAG: 8 (retrieveDeposit)
        } else if (flag == 0x08) {
            //Get nonce
            uint32 nonce = uint32(bytes4(data[1:5]));

            //Check if tx has already been executed
            if (!executionHistory[fromChainId][uint32(bytes4(data[1:5]))]) {
                //Toggle Nonce as executed
                executionHistory[fromChainId][nonce] = true;

                //Retry failed fallback
                (success, result) = (false, "");
            } else {
                _forceRevert();
                //Return true to avoid triggering anyFallback in case of `_forceRevert()` failure
                return (true, "already executed tx");
            }

            //Unrecognized Function Selector
        } else {
            //Zero out gas after use if remote call
            if (initialGas > 0) {
                _payExecutionGas(userFeeInfo.depositedGas, userFeeInfo.gasToBridgeOut, _initialGas, fromChainId);
            }

            return (false, "unknown selector");
        }

        emit LogCallin(flag, data, fromChainId);

        //Zero out gas after use if remote call
        if (initialGas > 0) {
            _payExecutionGas(userFeeInfo.depositedGas, userFeeInfo.gasToBridgeOut, _initialGas, fromChainId);
        }
    }

    /// @inheritdoc IApp
    function anyFallback(bytes calldata data)
        external
        virtual
        requiresExecutor
        returns (bool success, bytes memory result)
    {
        //Get Initial Gas Checkpoint
        uint256 _initialGas = gasleft();

        //Get fromChain
        (, uint256 _fromChainId) = _getContext();
        uint24 fromChainId = _fromChainId.toUint24();

        //Save Flag
        bytes1 flag = data[0];

        //Deposit nonce
        uint32 _settlementNonce;

        /// SETTLEMENT FLAG: 1 (single asset settlement)
        if (flag == 0x00) {
            _settlementNonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            _reopenSettlemment(_settlementNonce);

            /// SETTLEMENT FLAG: 1 (single asset settlement)
        } else if (flag == 0x01) {
            _settlementNonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            _reopenSettlemment(_settlementNonce);

            /// SETTLEMENT FLAG: 2 (multiple asset settlement)
        } else if (flag == 0x02) {
            _settlementNonce = uint32(bytes4(data[22:26]));
            _reopenSettlemment(_settlementNonce);
        }
        emit LogCalloutFail(flag, data, fromChainId);

        _payFallbackGas(_settlementNonce, _initialGas);

        return (true, "");
    }

    /// @inheritdoc IRootBridgeAgent
    function depositGasAnycallConfig() external payable {
        //Deposit Gas
        _replenishGas(msg.value);
    }

    /// @inheritdoc IRootBridgeAgent
    function forceRevert() external requiresLocalBranchBridgeAgent {
        _forceRevert();
    }

    /**
     * @notice Reverts the current transaction with a "no enough budget" message.
     * @dev This function is used to revert the current transaction with a "no enough budget" message.
     */
    function _forceRevert() internal {
        if (initialGas == 0) revert GasErrorOrRepeatedTx();

        IAnycallConfig anycallConfig = IAnycallConfig(IAnycallProxy(localAnyCallAddress).config());
        uint256 executionBudget = anycallConfig.executionBudget(address(this));

        // Withdraw all execution gas budget from anycall for tx to revert with "no enough budget"
        if (executionBudget > 0) try anycallConfig.withdraw(executionBudget) {} catch {}
    }

    /*///////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IRootBridgeAgent
    function approveBranchBridgeAgent(uint256 _branchChainId) external requiresManager {
        if (getBranchBridgeAgent[_branchChainId] != address(0)) revert AlreadyAddedBridgeAgent();
        isBranchBridgeAgentAllowed[_branchChainId] = true;
    }

    /// @inheritdoc IRootBridgeAgent
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint24 _branchChainId) external requiresPort {
        getBranchBridgeAgent[_branchChainId] = _newBranchBridgeAgent;
    }

    /// @inheritdoc IRootBridgeAgent
    function sweep() external {
        if (msg.sender != daoAddress) revert NotDao();
        uint256 _accumulatedFees = accumulatedFees - 1;
        accumulatedFees = 1;
        SafeTransferLib.safeTransferETH(daoAddress, _accumulatedFees);
    }

    /*///////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/

    uint256 internal _unlocked = 1;

    /// @notice Modifier for a simple re-entrancy check.
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    /// @notice Modifier verifies the caller is the Anycall Executor or Local Branch Bridge Agent.
    modifier requiresExecutor() {
        _requiresExecutor();
        _;
    }

    /// @notice Verifies the caller is the Anycall Executor or Local Branch Bridge Agent. Internal function used in modifier to reduce contract bytesize.
    function _requiresExecutor() internal view {
        if (msg.sender == getBranchBridgeAgent[localChainId]) return;

        if (msg.sender != localAnyCallExecutorAddress) revert AnycallUnauthorizedCaller();
        (address from, uint256 fromChainId,) = IAnycallExecutor(localAnyCallExecutorAddress).context();
        if (getBranchBridgeAgent[fromChainId] != from) revert AnycallUnauthorizedCaller();
    }

    /// @notice Modifier that verifies msg sender is the Bridge Agent's Router
    modifier requiresRouter() {
        _requiresRouter();
        _;
    }

    /// @notice Internal function to verify msg sender is Bridge Agent's Router. Reuse to reduce contract bytesize.
    function _requiresRouter() internal view {
        if (msg.sender != localRouterAddress) revert UnrecognizedCallerNotRouter();
    }

    /// @notice Modifier that verifies msg sender is Bridge Agent Executor.
    modifier requiresAgentExecutor() {
        if (msg.sender != bridgeAgentExecutorAddress) revert UnrecognizedExecutor();
        _;
    }

    /// @notice Modifier that verifies msg sender is Local Branch Bridge Agent.
    modifier requiresLocalBranchBridgeAgent() {
        if (msg.sender != getBranchBridgeAgent[localChainId]) {
            revert UnrecognizedExecutor();
        }
        _;
    }

    /// @notice Modifier that verifies msg sender is the Local Port.
    modifier requiresPort() {
        if (msg.sender != localPortAddress) revert UnrecognizedPort();
        _;
    }

    /// @notice Modifier that verifies msg sender is the Bridge Agent's Manager.
    modifier requiresManager() {
        if (msg.sender != IRootPort(localPortAddress).getBridgeAgentManager(address(this))) {
            revert UnrecognizedBridgeAgentManager();
        }
        _;
    }

    fallback() external payable {}
}

