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

// src/erc-4626/interfaces/IERC4626MultiToken.sol

interface IERC4626MultiToken {
    /**
     * @notice Gets the address of the underlying asset at the given index.
     * @param index The index of the underlying asset.
     * @return asset address of the underlying asset.
     */
    function assets(uint256 index) external view returns (address asset);

    /**
     * @notice Gets the weight of the underlying asset at the given index.
     * @param index The index of the underlying asset.
     * @return weight of the underlying asset.
     */
    function weights(uint256 index) external view returns (uint256);

    /**
     * @notice Gets the ID of the underlying asset.
     * @dev assetId[asset] = index + 1
     * @param asset The address of the underlying asset.
     * @return assetId ID of the underlying asset.
     */
    function assetId(address asset) external view returns (uint256 assetId);

    /**
     * @notice Gets the sum of all weights.
     * @return totalWeights sum of all weights.
     */
    function totalWeights() external view returns (uint256 totalWeights);

    /**
     * @notice Gets all the underlying assets.
     * @return assets array of all the underlying assets.
     */
    function getAssets() external view returns (address[] memory assets);

    /**
     * @notice Calculates the total amount of assets of a given Ulysses token.
     * @return _totalAssets total number of underlying assets of a Ulysses token.
     */
    function totalAssets() external view returns (uint256 _totalAssets);

    /**
     * @notice Deposit assets into the Vault.
     * @param assetsAmounts The amount of assets to deposit.
     * @param receiver The address to receive the shares.
     */
    function deposit(uint256[] calldata assetsAmounts, address receiver) external returns (uint256 shares);

    /**
     * @notice Mint shares from the Vault.
     * @param shares The amount of shares to mint.
     * @param receiver The address to receive the shares.
     */
    function mint(uint256 shares, address receiver) external returns (uint256[] memory assetsAmounts);

    /**
     * @notice Withdraw assets from the Vault.
     * @param assetsAmounts The amount of assets to withdraw.
     * @param receiver The address to receive the assets.
     * @param owner The address of the owner of the shares.
     */
    function withdraw(uint256[] calldata assetsAmounts, address receiver, address owner)
        external
        returns (uint256 shares);

    /**
     * @notice Redeem shares from the Vault.
     * @param shares The amount of shares to redeem.
     * @param receiver The address to receive the assets.
     */
    function redeem(uint256 shares, address receiver, address owner)
        external
        returns (uint256[] memory assetsAmounts);

    /**
     * @notice Calculates the amount of shares that would be received for a given amount of assets.
     *  @param assetsAmounts The amount of assets to deposit.
     */
    function convertToShares(uint256[] calldata assetsAmounts) external view returns (uint256 shares);

    /**
     * @notice Calculates the amount of assets that would be received for a given amount of shares.
     *  @param shares The amount of shares to redeem.
     */
    function convertToAssets(uint256 shares) external view returns (uint256[] memory assetsAmounts);

    /**
     * @notice Previews the amount of shares that would be received for depositinga given amount of assets.
     *  @param assetsAmounts The amount of assets to deposit.
     */
    function previewDeposit(uint256[] calldata assetsAmounts) external view returns (uint256);

    /**
     * @notice Previews the amount of assets that would be received for minting a given amount of shares
     *  @param shares The amount of shares to mint
     */
    function previewMint(uint256 shares) external view returns (uint256[] memory assetsAmounts);

    /**
     * @notice Previews the amount of shares that would be received for a given amount of assets.
     *  @param assetsAmounts The amount of assets to withdraw.
     */
    function previewWithdraw(uint256[] calldata assetsAmounts) external view returns (uint256 shares);

    /**
     * @notice Previews the amount of assets that would be received for redeeming a given amount of shares
     *  @param shares The amount of shares to redeem
     */
    function previewRedeem(uint256 shares) external view returns (uint256[] memory);

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

    /**
     * @notice Returns the maximum amount of assets that can be withdrawn.
     *  @param owner The address of the owner of the assets.
     */
    function maxWithdraw(address owner) external view returns (uint256[] memory);

    /**
     * @notice Returns the maximum amount of shares that can be redeemed.
     *  @param owner The address of the owner of the shares.
     */
    function maxRedeem(address owner) external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error thrown when redeeming returns 0 assets.
    error ZeroAssets();

    /// @notice Error thrown when depositing amounts array length is different than assets array length.
    error InvalidLength();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when assets are deposited into the Vault.
     * @param caller The caller of the deposit function.
     * @param owner The address of the owner of the shares.
     * @param assets The amount of assets deposited.
     * @param shares The amount of shares minted.
     */
    event Deposit(address indexed caller, address indexed owner, uint256[] assets, uint256 shares);

    /**
     * @notice Emitted when shares are withdrawn from the Vault.
     * @param caller The caller of the withdraw function.
     * @param receiver The address that received the assets.
     * @param owner The address of the owner of the shares.
     * @param assets The amount of assets withdrawn.
     * @param shares The amount of shares redeemed.
     */
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256[] assets, uint256 shares
    );

    /**
     * @notice Emitted when a new asset is added to the Vault.
     * @param asset The address of the new asset.
     * @param weight The weight of the new asset.
     */
    event AssetAdded(address asset, uint256 weight);

    /**
     * @notice Emitted when an asset is removed from the Vault.
     * @param asset The address of the removed asset.
     */
    event AssetRemoved(address asset);
}

// src/erc-4626/interfaces/IUlyssesERC4626.sol

interface IUlyssesERC4626 {
    /**
     * @notice Deposit assets into the Vault.
     * @param assets The amount of assets to deposit.
     * @param receiver The address to receive the shares.
     */
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    /**
     * @notice Mint shares from the Vault.
     *  @param shares The amount of shares to mint.
     *  @param receiver The address to receive the shares.
     */
    function mint(uint256 shares, address receiver) external returns (uint256 assets);

    /**
     * @notice Redeem assets from the Vault.
     * @param assets The amount of assets to Redeem.
     * @param receiver The address to receive the assets.
     * @param owner The address of the owner of the shares.
     */
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);

    /**
     * @notice Calculates the amount of shares that would be received for a given amount of assets.
     *  @param assets The amount of assets to deposit.
     */
    function convertToShares(uint256 assets) external view returns (uint256);

    /**
     * @notice Calculates the amount of assets that would be received for a given amount of shares.
     *  @param shares The amount of shares to redeem.
     */
    function convertToAssets(uint256 shares) external view returns (uint256);

    /**
     * @notice Previews the amount of shares that would be received for depositing given amount of assets.
     *  @param assets The amount of assets to deposit.
     */
    function previewDeposit(uint256 assets) external view returns (uint256);

    /**
     * @notice Previews the amount of assets that would be received for minting a given amount of shares
     *  @param shares The amount of shares to mint
     */
    function previewMint(uint256 shares) external view returns (uint256);

    /**
     * @notice Previews the amount of shares that would be received for redeeming a given amount of assets
     *  @param shares The amount of shares to redeem
     */
    function previewRedeem(uint256 shares) external view returns (uint256);

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

    /**
     * @notice Returns the maximum amount of shares that can be redeemed.
     *  @param owner The address of the owner of the shares.
     */
    function maxRedeem(address owner) external view returns (uint256);

    /* //////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Throw when adding an asset with decimals != 18
    error InvalidAssetDecimals();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);

    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
}

// src/ulysses-amm/interfaces/IUlyssesToken.sol

/**
 * @title Ulysses Token - tokenized Vault multi asset implementation for Ulysses pools
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice ERC4626 multiple token implementation intended for Ulysses Pools.
 *          Balances are always 1 : 1 with the underlying assets.
 *  @dev Allows to add/remove new tokens and change exisiting weights
 *       but there needs to be at least 1 token and the caller is
 *       responsible of making sure the Ulysses Token has the correct
 *       number of assets to change weights or add a new token, or
 *       the call will fail.
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣉⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢇⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⠀⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡺⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⠃⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠤⠔⠒⢁⣀⣀⣿⢿⣿⡿⠹⣿⣿⣿⣿⣿⠛⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠹⠿⣿⣿⣿⣿⣿⣿⡏⡟⡹⣃⣴⠖⠛⠉⠉⠉⢻⢸⣿⣷⡀⠹⣿⣿⣿⡏⠀⢧⠹⣿⣿⣿⣿⣿⣿⡟⡄⠀
 * ⣿⣿⣿⣿⣿⣿⠏⡏⠀⠉⠙⠂⠙⢿⣿⣿⣿⣿⠇⠀⠙⢹⠃⠀⠀⠀⠀⠀⠀⠨⡿⠘⢷⠀⠈⢿⣿⡇⠀⢸⢠⣿⣿⣿⣿⣿⣿⣿⠀⠀
 * ⣿⣿⣿⣿⣿⣿⡶⠟⠛⠛⠛⠻⣆⠀⠻⣿⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⢸⠃⠀⠈⣧⠀⠀⢻⡇⠀⠸⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀
 * ⣿⣿⣿⣿⣿⣿⠀⠈⠀⠀⠀⠀⠀⠀⠀⠈⠟⠀⠀⠀⠀⠀⠀⠀⠀⠐⠇⠈⠢⡈⠀⠀⠀⣿⡇⠀⠘⡇⠀⢀⠙⢿⣿⣿⡟⠑⠋⠀⠀⠀
 * ⣿⣿⣿⣿⣇⢿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⡀⠀⠁⠢⢰⢻⣇⠀⠀⡇⠀⢸⣄⠀⠹⣿⠀⠀⠀⠀⠀⠀
 * ⣿⣿⣿⣿⣿⣌⠙⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢎⡷⡄⠀⠐⣼⣿⠀⠀⢈⠀⠈⣿⠆⠀⠈⣧⣀⠀⠀⠀⠀
 * ⣿⣿⣿⣿⣿⣿⡦⡀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⢳⡀⠀⠘⣿⡆⠀⢸⠀⠀⢻⠀⠀⡼⢴⣹⡧⣄⡀⠀
 * ⣿⣿⣿⣿⣿⣿⣷⡈⠁⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⣀⠔⠉⠀⠀⠘⣇⠀⠀⠘⡇⠀⠀⡇⠀⡞⠀⣼⢓⢶⣡⢟⣉⢉⠳
 * ⠻⣿⣿⣿⣿⣿⣿⣿⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⠔⠊⠀⠀⠀⠀⠀⣰⡿⠀⠀⠠⠁⠀⢀⠃⢀⡇⣼⡗⣡⢓⣴⢫⡴⠉⡴
 * ⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⡂⠀⠀⠀⠀⠰⠂⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⢀⡼⠋⠀⠀⠀⠀⠀⠀⠀⠀⠘⣰⠣⡏⣱⢻⣴⢻⣜⠃⢌
 * ⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⢿⠀⠀⠀⠀⠀⠀⠀⠀⢀⠄⢠⢻⢻⢚⣱⠻⡤⢳⢜⡢⠦
 * ⠀⠀⠀⠀⠉⠻⢯⡙⠿⣿⣿⣿⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠈⢢⠀⠀⠀⠀⠀⠀⡠⠃⣠⠃⢸⡼⢏⡼⣩⢾⡹⢞⡰⢮
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢧⠹⣿⡿⡏⠛⣿⣦⣄⡀⠀⠀⠀⣨⠞⠁⠀⠁⠀⠀⠑⢄⡀⠀⠀⠎⢀⠔⠁⠀⢸⡗⢊⣲⡭⠞⣽⠣⡥⢪
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡇⠃⡰⠋⠀⠉⠛⠷⢶⣾⠏⠀⠀⠀⠀⠀⠀⠀⠀⠈⠒⢠⡴⠃⠀⠀⠀⢸⡝⣫⢮⡹⢯⢼⣫⠡⠆
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠂⡼⠁⠀⠀⠀⠀⠀⢠⡏⡈⠂⠄⣀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⠀⣿⣞⣱⣚⢮⣙⢮⡡⠆⡚
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣷⣦⣀⠀⠀⠀⠀⢸⠃⠀⠁⠐⠂⠀⠀⠁⢉⠿⣿⣦⡀⠀⠀⠀⠀⢠⡿⣏⢲⣸⢬⣊⢾⡱⢽⠰
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⢻⣷⣦⣀⠀⣸⠀⠀⠀⠀⠀⠀⠀⣴⢿⠀⠘⣿⣿⣦⠀⠀⠀⡘⡷⡊⠱⣘⠶⢉⢎⠱⠄⠁
 */
interface IUlyssesToken {
    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Calculates the total amount of assets of a given Ulysses token.
     *  @param asset The address of the asset to add.
     *  @param _weight The weight of the asset to add.
     */
    function addAsset(address asset, uint256 _weight) external;

    /**
     * @notice Removes an asset from the Ulysses token.
     *  @param asset The address of the asset to remove.
     */
    function removeAsset(address asset) external;

    /**
     * @notice Sets the weights of the assets in the Ulysses token.
     *  @param _weights The weights of the assets in the Ulysses token.
     */
    function setWeights(uint256[] memory _weights) external;

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Error emitted when trying to add an asset that is already part of the Ulysses token.
    error AssetAlreadyAdded();

    /// @notice Error emitted when trying to remove the last asset of the Ulysses token.
    error CannotRemoveLastAsset();

    /// @notice Error emitted when trying to set weights with an invalid length.
    error InvalidWeightsLength();
}

// src/ulysses-amm/interfaces/IUlyssesFactory.sol

/**
 * @title Factory of new Ulysses instances
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This contract is responsible for creating new Ulysses Tokens
 *          and Ulysses Pools.
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡴⠲⠚⠙⢛⣶⣶⣯⣷⣒⠶⣍⠀⠂⠀⠀⠉⠉⠒⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡾⠁⠀⢠⣶⠟⠛⠿⠟⠛⠣⣍⠙⠒⢷⣦⡀⠀⠀⠀⠀⠀⠈⠲⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠟⠀⢀⡴⠋⠀⣠⣾⠟⠙⢧⠀⠀⢱⠀⠀⠀⠙⢦⡀⠀⠀⠀⠀⠀⠈⠳⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡿⠃⠀⢠⡞⠀⢠⣴⣏⡞⠀⠀⠈⡇⠀⠀⢷⠀⠀⠀⠀⠙⢦⠀⠀⠀⠀⠀⠀⠙⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⣰⠋⣠⠀⠀⡾⠀⢠⠏⡇⣼⠃⠀⠀⠀⢸⠀⠀⠈⡆⢰⡀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⠈⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢰⠟⣄⡇⠀⣸⠁⠀⠁⢸⠀⠋⠀⠀⠀⠀⠀⣇⠀⠀⡇⠀⢣⠀⠀⠀⠀⢧⠀⠀⠀⢀⠀⠀⠘⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣿⣾⢹⡧⢪⡇⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⠀⢀⠘⣇⠀⠀⠀⠘⣆⠀⠀⠈⠀⠀⠀⠹⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢰⣻⣯⠟⠁⢸⠁⠀⠀⢰⡉⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⢸⡀⠀⠀⠀⢹⡀⠀⠀⠀⠀⠀⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⣾⣿⠁⣸⠀⡇⠀⠀⠀⣾⣇⠀⢧⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⡇⠀⣷⠀⠀⡄⠀⡇⠀⠀⠀⢀⠀⠀⣾⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢠⣿⡇⠀⣾⠀⡇⠀⠀⣄⣿⣽⠀⢸⡆⠀⠀⠀⠀⠀⡄⢠⠇⠀⣿⡀⣿⡇⠀⢱⠀⢹⠀⠀⠀⢸⠀⠀⢱⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢸⠁⡇⠀⡟⡆⡇⡄⠀⣹⠟⠸⣳⠈⢷⡄⠀⠀⠀⢠⢧⡟⠀⡆⣿⡇⢸⢻⡀⠘⣇⢸⡇⠀⠀⢸⡆⠀⢸⢻⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢸⣧⠇⢀⠁⢻⣷⡇⠀⡯⠤⠖⢳⡏⠙⣧⣀⠀⢠⣿⣿⡄⠀⣷⠋⡇⠈⠉⢧⠀⡿⣜⡇⠀⠀⢸⡇⠀⠀⡏⡄⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⢸⡿⠀⢻⠀⠸⣷⣧⢰⠁⠀⠀⠀⢳⣀⡟⣷⢴⡿⢻⣿⡇⣸⡟⢀⡁⠀⠀⠈⡀⠁⢻⡇⢰⠀⢸⡇⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⢀⣸⡿⡀⠘⡆⠀⢿⣟⣿⠠⠤⣄⠀⠀⠀⠈⠊⠿⣦⣟⠏⣧⠟⠛⣩⣤⣤⣦⣬⣵⣦⣼⣇⡼⠀⣼⠁⢰⠀⠘⡇⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⢀⣾⢿⡟⡇⠀⢷⠱⢼⣿⠾⢿⣿⣿⣿⣿⡷⣄⠀⠀⠈⠉⠀⠃⠠⠞⢻⣿⣿⣿⣿⠋⠁⡟⢩⡇⠀⡿⠀⣾⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⢀⣾⠏⢸⠁⢳⠀⢘⣇⠀⢽⠀⠈⠻⣿⣗⣿⠃⠈⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣯⣛⡥⠀⠀⢠⡿⠁⢸⠁⠀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⣾⡟⠀⢸⡀⢸⡆⠀⢻⣆⠘⣆⠀⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠟⡵⢀⣿⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⢸⢽⠃⢀⣼⡇⠘⣿⠀⢸⣿⡣⣙⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡜⠁⡼⢃⣾⡏⠀⣸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠸⢼⣧⣴⣿⣿⠀⢿⣟⢆⢳⡫⣿⣝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠐⠁⢠⠞⣠⡾⡟⠀⢰⠿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⢙⣿⣿⣿⠀⢸⠘⣞⣎⢧⠈⢻⠷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⣠⠞⠋⠔⢩⠰⠁⢀⡞⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⣿⣿⡆⠸⡇⢸⣞⢯⣧⢈⠀⢈⠓⠦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡾⠁⠀⠇⢀⡇⠀⢀⣼⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⢀⡀⠀⡇⣿⢧⠀⡇⢸⡌⢳⡙⢦⠍⡞⠀⠀⠀⠹⡗⠦⢄⣀⣀⣀⡴⠚⠁⢈⣇⢀⠀⢀⡾⠀⠀⣾⠈⡇⠀⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⣸⡇⢀⢧⣿⠻⣆⣿⣾⡇⠸⣽⡎⢵⠃⠀⠀⠀⣠⡧⠂⠀⠀⠁⠀⠀⠀⠀⣸⠻⣄⡆⢘⡇⠀⣸⣿⢰⠇⢸⡈⠀⣄⠄⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠈⢹⡇⡸⣿⣿⣷⠥⠐⠈⢹⡄⣿⣀⣚⣀⡤⠖⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠀⠈⠙⣺⠁⣰⣿⣿⣾⣿⠀⠓⣇⣿⠸⡆⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠐⠙⢳⣤⣿⣿⠁⠀⠀⣠⡤⢷⢿⡞⠉⠁⠀⠀⠀⠀⠀⢲⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⢿⠀⣿⣿⣿⡷⡿⡅⠀⠀⠉⠲⢧⣄⠀⠀⠀⠀⠀⠀
 * ⠀⠀⡰⡏⠁⣾⡟⠀⠀⣸⣿⣵⣼⣷⣧⠀⠀⡘⢦⣄⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⠀⣀⣀⡟⠀⠀⣿⣿⠂⢹⡍⠀⠀⠀⠀⠀⣸⣟⠷⡄⠀⠀⠀⠀
 * ⠀⠸⡷⠃⣰⣿⣁⡤⢴⡷⠻⣯⣿⠹⢯⢦⠀⠳⡀⠨⠍⠛⠲⣾⣄⡠⢖⡾⠗⠋⠉⣠⣿⣰⢠⠀⢉⣿⣲⣸⠀⠀⠁⠀⠀⢻⠇⠈⢹⣇⠀⠀⠀⠀
 * ⠀⢰⠇⠈⠉⣠⠞⠀⡞⠀⠲⣿⡇⢢⡈⠻⡳⠤⠽⣦⣀⣀⠀⠀⠉⠛⠉⠀⠀⣀⡴⠋⠃⡏⠘⡆⠸⢿⣿⡿⠀⠀⠀⠘⢀⡟⠀⠀⢘⣿⣦⡀⠀⠀
 * ⣰⣿⣤⠤⠄⡇⠀⣸⠁⠀⠀⢟⠀⠀⠑⠦⣝⠦⣄⠀⠈⠉⠀⠀⠀⠀⠀⠐⠚⠁⠀⣴⢸⡇⠀⣇⠀⠸⣿⠁⠀⠀⠀⢀⣾⠁⠀⣠⢾⣿⡅⠉⡂⠄
 * ⢹⢻⡄⠀⠀⣣⢠⢇⡀⠀⠀⣹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣼⡇⠠⢿⠀⠀⢿⡇⠀⠀⢀⡼⠁⠀⠞⣡⠞⢯⢿⡄⢠⡀
 * ⣸⡧⢳⡀⠀⣿⡾⠉⠀⠐⢻⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡇⣿⠀⢻⡀⠀⢸⣇⡀⢹⣿⠃⣀⡴⣾⠁⠀⠘⢺⣷⡇⡀
 * ⡿⡃⠈⢳⣴⠏⠀⠀⠀⣠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⡘⡷⣄⢳⡀⠈⣿⢳⡀⠻⣿⡉⠉⠁⠀⠀⠀⠈⡏⡇⣷
 * ⣟⠁⠠⢴⣿⣦⣀⣀⣴⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⢮⠳⢽⣦⣾⣇⠱⣄⢈⣻⣄⠀⠀⠀⠀⠀⣧⡇⢹
 */
interface IUlyssesFactory {
    /**
     * @notice Creates a new Ullysses pool based on a given ERC20 passed through params.
     *     @param asset represents the asset we want to create a Ulysses pool around
     *     @return poolId returns the poolId
     */
    function createPool(ERC20 asset, address owner) external returns (uint256);

    /**
     * @notice Takes an array of assets and their respective weights and creates a Ulysses token.
     *         First it creates a Ulysses pool for each asset and then it links them together
     *         according to the specified weight.
     * @param assets ERC20 array that represents all the assets that are part of the Ulysses Token.
     * @param weights Weights array that holds the weights for the corresponding assets.
     */
    function createPools(ERC20[] calldata assets, uint8[][] calldata weights, address owner)
        external
        returns (uint256[] memory poolIds);

    /**
     * @notice Responsible for creating a unified liquidity token (Ulysses token).
     *  @param poolIds Ids of the pools that the unified liquidity token should take into consideration
     *  @param weights wWeights of the pools to link to the Ulysses Token
     *  @return _tokenId Id of the newly created Ulysses token
     */
    function createToken(uint256[] calldata poolIds, uint256[] calldata weights, address owner)
        external
        returns (uint256 _tokenId);
}

// src/erc-4626/ERC4626MultiToken.sol

/// @title Minimal ERC4626 tokenized Vault multi asset implementation
/// @author Maia DAO (https://github.com/Maia-DAO)
abstract contract ERC4626MultiToken is ERC20, ReentrancyGuard, IERC4626MultiToken {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626MultiToken
    address[] public assets;

    /// @inheritdoc IERC4626MultiToken
    uint256[] public weights;

    /// @inheritdoc IERC4626MultiToken
    mapping(address => uint256) public assetId;

    /// @inheritdoc IERC4626MultiToken
    uint256 public totalWeights;

    /// @inheritdoc IERC4626MultiToken
    function getAssets() external view returns (address[] memory) {
        return assets;
    }

    constructor(address[] memory _assets, uint256[] memory _weights, string memory _name, string memory _symbol)
        ERC20(_name, _symbol, 18)
    {
        assets = _assets;
        weights = _weights;

        uint256 length = _weights.length;
        uint256 _totalWeights;

        if (length != _assets.length || length == 0) revert InvalidLength();

        for (uint256 i = 0; i < length;) {
            require(ERC20(_assets[i]).decimals() == 18);
            require(_weights[i] > 0);

            _totalWeights += _weights[i];
            assetId[_assets[i]] = i + 1;

            emit AssetAdded(_assets[i], _weights[i]);

            unchecked {
                i++;
            }
        }
        totalWeights = _totalWeights;
    }

    function receiveAssets(uint256[] memory assetsAmounts) private {
        uint256 length = assetsAmounts.length;
        for (uint256 i = 0; i < length;) {
            assets[i].safeTransferFrom(msg.sender, address(this), assetsAmounts[i]);

            unchecked {
                i++;
            }
        }
    }

    function sendAssets(uint256[] memory assetsAmounts, address receiver) private {
        uint256 length = assetsAmounts.length;
        for (uint256 i = 0; i < length;) {
            assets[i].safeTransfer(receiver, assetsAmounts[i]);

            unchecked {
                i++;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626MultiToken
    function deposit(uint256[] calldata assetsAmounts, address receiver)
        public
        virtual
        nonReentrant
        returns (uint256 shares)
    {
        // Check for rounding error since we round down in previewDeposit.
        require((shares = previewDeposit(assetsAmounts)) != 0, "ZERO_SHARES");

        // Need to transfer before minting or ERC777s could reenter.
        receiveAssets(assetsAmounts);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assetsAmounts, shares);

        afterDeposit(assetsAmounts, shares);
    }

    /// @inheritdoc IERC4626MultiToken
    function mint(uint256 shares, address receiver)
        public
        virtual
        nonReentrant
        returns (uint256[] memory assetsAmounts)
    {
        assetsAmounts = previewMint(shares); // No need to check for rounding error, previewMint rounds up.

        // Need to transfer before minting or ERC777s could reenter.
        receiveAssets(assetsAmounts);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assetsAmounts, shares);

        afterDeposit(assetsAmounts, shares);
    }

    /// @inheritdoc IERC4626MultiToken
    function withdraw(uint256[] calldata assetsAmounts, address receiver, address owner)
        public
        virtual
        nonReentrant
        returns (uint256 shares)
    {
        shares = previewWithdraw(assetsAmounts); // No need to check for rounding error, previewWithdraw rounds up.

        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        beforeWithdraw(assetsAmounts, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assetsAmounts, shares);

        sendAssets(assetsAmounts, receiver);
    }

    /// @inheritdoc IERC4626MultiToken
    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        nonReentrant
        returns (uint256[] memory assetsAmounts)
    {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        assetsAmounts = previewRedeem(shares);
        uint256 length = assetsAmounts.length;
        for (uint256 i = 0; i < length;) {
            // Check for rounding error since we round down in previewRedeem.
            if (assetsAmounts[i] == 0) revert ZeroAssets();
            unchecked {
                i++;
            }
        }

        beforeWithdraw(assetsAmounts, shares);

        _burn(owner, shares);

        emit Withdraw(msg.sender, receiver, owner, assetsAmounts, shares);

        sendAssets(assetsAmounts, receiver);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    /// @inheritdoc IERC4626MultiToken
    function convertToShares(uint256[] calldata assetsAmounts) public view virtual returns (uint256 shares) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assetsAmounts.length;

        if (length != assets.length) revert InvalidLength();

        shares = type(uint256).max;
        for (uint256 i = 0; i < length;) {
            uint256 share = assetsAmounts[i].mulDiv(_totalWeights, weights[i]);
            if (share < shares) shares = share;
            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IERC4626MultiToken
    function convertToAssets(uint256 shares) public view virtual returns (uint256[] memory assetsAmounts) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assets.length;

        assetsAmounts = new uint256[](length);
        for (uint256 i = 0; i < length;) {
            assetsAmounts[i] = shares.mulDiv(weights[i], _totalWeights);
            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IERC4626MultiToken
    function previewDeposit(uint256[] calldata assetsAmounts) public view virtual returns (uint256) {
        return convertToShares(assetsAmounts);
    }

    /// @inheritdoc IERC4626MultiToken
    function previewMint(uint256 shares) public view virtual returns (uint256[] memory assetsAmounts) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assets.length;

        assetsAmounts = new uint256[](length);
        for (uint256 i = 0; i < length;) {
            assetsAmounts[i] = shares.mulDivUp(weights[i], _totalWeights);
            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IERC4626MultiToken
    function previewWithdraw(uint256[] calldata assetsAmounts) public view virtual returns (uint256 shares) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assetsAmounts.length;

        if (length != assets.length) revert InvalidLength();

        for (uint256 i = 0; i < length;) {
            uint256 share = assetsAmounts[i].mulDivUp(_totalWeights, weights[i]);
            if (share > shares) shares = share;
            unchecked {
                i++;
            }
        }
    }

    /// @inheritdoc IERC4626MultiToken
    function previewRedeem(uint256 shares) public view virtual returns (uint256[] memory) {
        return convertToAssets(shares);
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626MultiToken
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626MultiToken
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    /// @inheritdoc IERC4626MultiToken
    function maxWithdraw(address owner) public view virtual returns (uint256[] memory) {
        return convertToAssets(balanceOf[owner]);
    }

    /// @inheritdoc IERC4626MultiToken
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    function beforeWithdraw(uint256[] memory assetsAmounts, uint256 shares) internal virtual {}

    function afterDeposit(uint256[] memory assetsAmounts, uint256 shares) internal virtual {}
}

// src/erc-4626/UlyssesERC4626.sol

/// @title Minimal ERC4626 tokenized 1:1 Vault implementation
/// @author Maia DAO (https://github.com/Maia-DAO)
abstract contract UlyssesERC4626 is ERC20, ReentrancyGuard, IUlyssesERC4626 {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    address public immutable asset;

    constructor(address _asset, string memory _name, string memory _symbol) ERC20(_name, _symbol, 18) {
        asset = _asset;

        if (ERC20(_asset).decimals() != 18) revert InvalidAssetDecimals();
    }

    /*//////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    //////////////////////////////////////////////////////////////*/

    function deposit(uint256 assets, address receiver) public virtual nonReentrant returns (uint256 shares) {
        // Need to transfer before minting or ERC777s could reenter.
        asset.safeTransferFrom(msg.sender, address(this), assets);

        shares = beforeDeposit(assets);

        require(shares != 0, "ZERO_SHARES");

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function mint(uint256 shares, address receiver) public virtual nonReentrant returns (uint256 assets) {
        assets = beforeMint(shares); // No need to check for rounding error, previewMint rounds up.

        require(assets != 0, "ZERO_ASSETS");

        asset.safeTransferFrom(msg.sender, address(this), assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        nonReentrant
        returns (uint256 assets)
    {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }

        _burn(owner, shares);

        assets = afterRedeem(shares);

        require(assets != 0, "ZERO_ASSETS");

        emit Withdraw(msg.sender, receiver, owner, assets, shares);

        asset.safeTransfer(receiver, assets);
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    function totalAssets() public view virtual returns (uint256);

    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return assets;
    }

    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }

    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return assets;
    }

    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }

    /*//////////////////////////////////////////////////////////////
                     DEPOSIT/WITHDRAWAL LIMIT LOGIC
    //////////////////////////////////////////////////////////////*/

    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }

    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Should not do any external calls to prevent reentrancy.
    function beforeDeposit(uint256 assets) internal virtual returns (uint256 shares);

    /// @dev Should not do any external calls to prevent reentrancy.
    function beforeMint(uint256 shares) internal virtual returns (uint256 assets);

    /// @dev Should not do any external calls to prevent reentrancy.
    function afterRedeem(uint256 shares) internal virtual returns (uint256 assets);
}

// src/ulysses-amm/UlyssesToken.sol

/// @title Ulysses Token - tokenized Vault multi asset implementation for Ulysses pools
contract UlyssesToken is ERC4626MultiToken, Ownable, IUlyssesToken {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;

    uint256 public immutable id;

    constructor(
        uint256 _id,
        address[] memory _assets,
        uint256[] memory _weights,
        string memory _name,
        string memory _symbol,
        address _owner
    ) ERC4626MultiToken(_assets, _weights, _name, _symbol) {
        _initializeOwner(_owner);
        require(_id != 0);
        id = _id;
    }

    /*//////////////////////////////////////////////////////////////
                            ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IERC4626MultiToken
    function totalAssets() public view override returns (uint256 _totalAssets) {
        return totalSupply;
    }

    ///@inheritdoc IUlyssesToken
    function addAsset(address asset, uint256 _weight) external nonReentrant onlyOwner {
        if (assetId[asset] != 0) revert AssetAlreadyAdded();
        require(ERC20(asset).decimals() == 18);
        require(_weight > 0);

        assetId[asset] = assets.length + 1;
        assets.push(asset);
        weights.push(_weight);
        totalWeights += _weight;

        emit AssetAdded(asset, _weight);

        updateAssetBalances();
    }

    ///@inheritdoc IUlyssesToken
    function removeAsset(address asset) external nonReentrant onlyOwner {
        // No need to check if index is 0, it will underflow and revert if it is 0
        uint256 assetIndex = assetId[asset] - 1;

        uint256 newAssetsLength = assets.length - 1;

        if (newAssetsLength == 0) revert CannotRemoveLastAsset();

        totalWeights -= weights[assetIndex];

        address lastAsset = assets[newAssetsLength];

        assetId[lastAsset] = assetIndex;
        assets[assetIndex] = lastAsset;
        weights[assetIndex] = weights[newAssetsLength];

        assets.pop();
        weights.pop();
        assetId[asset] = 0;

        emit AssetRemoved(asset);

        updateAssetBalances();

        asset.safeTransfer(msg.sender, asset.balanceOf(address(this)));
    }

    ///@inheritdoc IUlyssesToken
    function setWeights(uint256[] memory _weights) external nonReentrant onlyOwner {
        if (_weights.length != assets.length) revert InvalidWeightsLength();

        weights = _weights;

        uint256 newTotalWeights;

        for (uint256 i = 0; i < assets.length; i++) {
            newTotalWeights += _weights[i];

            emit AssetRemoved(assets[i]);
            emit AssetAdded(assets[i], _weights[i]);
        }

        totalWeights = newTotalWeights;

        updateAssetBalances();
    }

    /**
     * @notice Update the balances of the underlying assets.
     */
    function updateAssetBalances() internal {
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 assetBalance = assets[i].balanceOf(address(this));
            uint256 newAssetBalance = totalSupply.mulDivUp(weights[i], totalWeights);

            if (assetBalance > newAssetBalance) {
                assets[i].safeTransfer(msg.sender, assetBalance - newAssetBalance);
            } else {
                assets[i].safeTransferFrom(msg.sender, address(this), newAssetBalance - assetBalance);
            }
        }
    }
}



// src/ulysses-amm/interfaces/IUlyssesPool.sol

/**
 * @title Ulysses Pool - Single Sided Stableswap LP
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This contract is stableswap AMM that uses it's implemention of
 *          the Delta Algorithm to manage the LP's balances and transfers
 *          between LPs.
 *  @dev NOTE: Can't remove a destination, only add new ones.
 *
 *       Input: Transaction amount t, destination LP ID d
 *
 *       # On the source LP:
 *       1: aₛ ← aₛ + t
 *       2: bₛ,𝒹 ← bₛ,𝒹 − t
 *       3: for x != s do
 *       4:     diffₛ,ₓ ← max(0, lpₛ * wₛ,ₓ − lkbₓ,ₛ)
 *       5: end for
 *       6: Total ← ∑ₓ diffₛ,ₓ
 *       7: for x != s do
 *       8:     diffₛ,ₓ ← min(Total, t) * diffₛ,ₓ / Total
 *       9: end for
 *       10: t′ ← t - min(Total, t)
 *       11: for ∀x do
 *       12:     bₛ,ₓ ← bₛ,ₓ + diffₛ,ₓ + t′ * wₛ,ₓ
 *       13: end for
 *       14: msg = (t)
 *       15: Send msg to LP d
 *
 *       # On the destination LP:
 *       16: Receive (t) from a source LP
 *       17: if bₛ,𝒹 < t then
 *       18:     Reject the transfer
 *       19: end if
 *       20: a𝒹 ← a𝒹 − t
 *       21: bₛ,𝒹 ← bₛ,𝒹 − t
 *       Adapted from: Figure 4 from:
 *        - https://www.dropbox.com/s/gf3606jedromp61/Ulysses-Solving.The.Bridging-Trilemma.pdf?dl=0
 * ⠀⠀⠀⠀⠀⡂⠀⠀⠀⠁⠀⠀⠀⠀⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣀⡀⠀⠀⠀⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠾⢋⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⢰⣿⠄
 * ⠀⠀⢰⠀⠀⠂⠔⠀⡂⠐⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠤⢂⣉⠉⠉⠉⠁⠀⠉⠁⡀⠀⠉⠳⢶⠶⣦⣄⡀⠀⠀⠀⠀⠀⠀⠌⠙⠓⠒⠻⡦⠔⡌⣄⠤⢲⡽⠖⠪⢱⠦⣤
 * ⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠘⠋⣠⣾⣛⣞⡛⢶⣾⣿⣶⣴⣤⣤⣤⣀⣀⢠⠂⠀⠊⡛⢷⣄⡀⠀⠀⠀⠀⠀⠂⣾⣁⢸⠀⠁⠐⢊⣱⣺⡰⠶⣚⡭⠂
 * ⢀⠀⠄⠀⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠄⠀⢠⣤⣴⡟⠇⣶⣠⢭⣿⣿⣿⣿⡌⠙⠻⠿⣿⣿⣿⣶⣄⡀⠀⠈⣯⢻⡷⣄⠀⠄⢀⡆⠠⢀⣤⠀⠀⠀⠀⠛⠐⢓⡁⠤⠐⢁
 * ⡼⠀⠀⢀⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠆⠀⠀⣼⣿⣿⣿⣦⣠⠤⢖⣿⣿⣿⣟⣛⣿⡴⣿⣿⣿⣟⢿⣿⣿⣦⣰⠉⠻⢷⡈⢳⡄⢸⠇⢹⡦⢥⢸⠀⡄⠀⠀⠀⠈⠀⠀⢠⠂
 * ⢡⢐⠀⠂⠀⠀⠆⠀⠀⠀⠀⠀⠀⣠⠖⠋⢰⣴⣾⣿⣿⣿⣿⠙⠛⠚⠛⠁⠙⢦⡉⠉⠉⠀⠙⣷⣭⣿⣦⣹⣿⣿⣿⣤⠐⢀⠹⣷⡹⣾⣧⢻⠐⡀⢸⠀⠀⠀⡁⠀⠀⠀⠴⠃⠀
 * ⠂⠀⠀⠀⠈⡘⠀⠀⠀⠀⠀⠀⣰⠏⠀⢰⣾⡿⢋⣽⡿⠟⠉⠀⠀⢴⠀⠙⣆⠀⠳⡄⠀⠀⠀⠈⢿⣆⢹⣿⢿⣿⣿⣿⣆⣂⠀⢿⡇⠘⢿⣿⣷⡅⣼⢸⡇⢸⡇⠀⡀⣰⠁⠀⠀
 * ⠸⠐⠁⢠⠣⠁⠁⠀⠀⢀⣠⣾⡏⡄⣰⣿⣿⣷⣾⠁⠀⠀⠀⠀⠀⢸⡀⠀⠘⣇⠀⠙⣆⠀⠀⠀⠀⢻⣎⠻⣾⣿⣾⣿⣿⣿⠁⣸⣷⣀⠈⢿⣿⠇⡿⢸⡇⢸⠀⠀⣷⠁⠀⠀⠀
 * ⠂⠀⠀⡎⠄⠀⣠⣤⣾⣻⣿⡟⠀⢘⣿⣿⣿⡿⠃⠀⠀⠀⡄⠀⠀⢈⡇⠀⠀⠸⡀⠀⠀⠀⠀⠀⠀⠀⠻⡄⠀⢈⣿⠿⣿⣿⡿⠯⣿⡽⡆⠸⣿⣀⡇⢸⡇⢸⡀⠀⡟⠀⠀⠀⠀
 * ⡈⠀⡸⠼⠐⠌⢡⠹⡍⣷⣿⣁⠰⣾⣿⢿⣿⠁⠀⠀⠀⠀⡇⠀⠀⢸⠁⠀⠀⠀⢷⠀⠀⠀⠀⠀⠀⠀⠀⢷⠀⠈⣿⣿⣿⣿⣿⣛⣿⣿⡇⠀⢻⣻⡇⣼⡇⣹⠊⠀⣧⠀⠀⠀⠀
 * ⠀⢐⡣⢑⣨⠶⠞⠀⠃⣋⣽⣟⡘⣿⣿⣺⡿⠀⠀⠀⠀⠀⠁⠀⠀⠈⠀⠀⠀⠀⠈⡇⠐⡄⠀⠀⠀⠀⠀⠘⡆⡄⠈⠻⢿⣿⣿⣿⣿⣯⣜⠀⠀⡇⢧⣿⡇⣿⡄⢀⣿⠀⠀⠀⠀
 * ⠨⣥⡶⠌⣡⠡⡖⠀⠈⣹⣿⣿⣿⣿⣿⠏⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀⣇⢷⠀⠀⠀⢼⣿⣿⣍⡟⠻⣷⣄⢻⡈⣿⠁⣿⡇⢸⣿⠀⠀⠀⠀
 * ⠋⠁⠀⠀⠁⠀⢩⡏⢼⣽⣿⣿⣿⣿⢷⡄⡇⠀⠀⠀⠀⠀⠀⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣧⠀⠀⠀⠀⠀⢸⠸⡄⠀⠀⢸⣿⣿⣿⣿⣄⠙⣿⣾⡇⠸⡆⣿⠁⢸⣿⣇⠀⠀⠀
 * ⠀⠀⠠⢀⣪⣤⡌⠉⣼⣿⣿⣿⣿⣿⣨⡟⢣⠀⠀⠀⠀⠀⢠⣳⠃⠀⠀⠀⠀⠀⠀⠀⣄⠀⣿⡆⠀⠀⠀⠀⢸⡆⡇⠀⠀⢸⣾⣿⣿⣿⣿⣷⣼⣿⡇⠀⢹⣿⡅⣿⣿⣿⠀⠀⠀
 * ⣤⣵⣾⣿⣿⣿⣿⠂⠝⣿⣿⣿⣿⣿⣿⠀⠈⠀⠀⠀⠀⠀⣼⠋⠀⠀⠀⠀⠀⠀⠀⠀⢿⠀⡿⢣⠀⠀⠀⢀⡼⢻⢿⠀⠀⢸⣿⣿⣿⢿⢹⢿⣿⡅⢹⠀⠀⢿⡆⣿⣿⣿⡆⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣆⠀⡆⠀⠀⠀⣰⠋⠀⣆⠀⠀⠀⠀⠀⠀⠀⢸⣄⣧⣼⣦⡴⠚⢩⠇⠘⢺⣦⡆⢉⣿⣿⣿⣼⣾⡈⢻⣿⣸⡆⠀⠘⡇⣿⣿⣿⡇⠀⠀
 * ⡿⢿⣟⣽⣿⡿⠿⠛⣉⣥⠶⠾⣿⣿⣿⢿⠀⢳⡀⠀⢰⢋⡀⠀⢸⡄⠀⠀⠀⠀⠀⠀⣿⣇⠇⠀⣧⣧⡐⣍⣴⣾⣿⡇⠀⢸⣿⣿⠹⢿⣯⠻⢿⣿⣄⣧⠀⠀⠸⣿⣿⣿⣿⣆⠀
 * ⣿⠿⠟⣋⡡⠔⠚⠋⠁⠀⠀⠀⣧⣿⣿⡇⡆⠘⣧⡄⠀⠀⠉⠛⡓⣿⡎⠀⠀⠀⠀⠀⡿⢿⣄⡀⢹⣶⣿⠟⣻⠿⠚⣿⢀⣾⢾⣿⡀⣿⣿⠂⣺⡇⢻⣿⡆⠀⠀⢻⣿⣿⣿⣿⣆
 * ⢰⠚⠉⠀⡀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣷⡇⠀⢻⣿⣦⣀⢀⡀⢹⣌⣙⣶⠤⢄⣀⠤⠇⠀⠀⠀⠀⠋⠁⠀⠀⠀⠀⢸⣺⡏⡆⢻⣿⣿⣿⠀⣿⣧⢸⣯⢧⠀⠀⠀⢿⣿⣿⣿⣿
 * ⠂⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠿⣿⣿⣿⣿⣧⠀⢸⣷⡀⠹⣿⡿⣟⠛⠻⣿⣿⣷⣦⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣷⡇⠃⠘⣿⣿⣿⠀⣿⣿⢸⡟⠻⡄⠀⠀⠘⣿⣟⣟⣿
 * ⠀⠀⠀⠀⠀⠀⠀⢠⣾⠟⠁⢰⣿⣿⣿⣿⡟⡇⠀⡿⢻⠶⣄⠻⣄⠑⠶⠦⠶⠚⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠈⣼⡇⠀⠀⢹⣿⡿⢢⣿⣿⣿⣧⢠⢧⠀⠀⠀⠹⣯⣏⠀
 * ⠀⠀⠀⢦⠀⠀⠰⣿⣷⣀⣴⣿⡿⣻⣿⣿⡇⢧⠀⡇⠈⣧⠈⣿⢶⡿⡂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠀⠀⢠⣾⣿⡇⠀⠠⣿⢿⠀⣼⣿⣿⣿⣿⡎⣿⠀⠀⠀⠀⠹⡥⠀
 * ⠀⠀⠀⣼⣇⠀⠀⠈⠛⢫⣿⣿⢀⣏⣿⣿⡅⢸⣸⡇⠀⣿⡄⢹⠀⠙⣿⣦⠀⠀⠀⠀⠀⠀⠠⣤⡾⢅⡈⠓⠢⡶⠋⢀⡾⠁⢠⣇⣿⣧⣾⣿⣿⣿⣿⣿⣿⣮⣳⡀⠀⠀⠀⠰⠈
 * ⠀⠀⠀⣿⣿⡄⠀⠀⠀⠘⠻⣿⣾⠟⣿⣟⠀⠸⢃⠇⢰⣿⣇⠘⠀⠀⢻⣿⣷⣶⣤⣤⣀⣠⠞⠭⠤⠄⠙⠿⢻⣥⣴⣿⠃⠀⣾⣾⣿⣯⣿⣿⣿⣾⣟⣿⣿⣿⣿⡿⡄⠀⠀⠀⢣
 * ⠀⠀⠀⠻⣿⣿⣆⠀⠀⠀⢀⣼⣟⢠⣿⣿⠀⠀⢸⠀⣼⣿⣿⠆⠀⠀⢸⡟⣿⣿⣿⣿⠟⠁⠀⣀⣤⡖⠂⣴⣿⣯⣿⠋⠀⠐⡿⣹⣾⠋⠗⣯⢿⣿⣿⣿⣿⣿⣿⡇⢳⡀⠀⠀⠀
 * ⠀⠀⡂⢸⣿⣿⣿⣷⡀⢀⣿⣿⣿⣾⡿⣿⠀⠀⡜⢸⣿⣓⣾⣷⠀⠀⢸⣿⣜⣿⣯⡟⠀⠀⠀⣀⣈⠙⢶⣿⣿⣿⠇⠀⢀⣼⣇⣿⡀⢀⣤⣷⣿⣿⣿⣿⣿⣿⣿⡇⠀⠷⡀⠀⠀
 * ⣤⣀⡞⣢⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⠁⣿⡆⢠⣧⣿⡇⠐⣿⡿⠀⠀⢸⢷⣻⣿⡟⠀⠀⠀⠀⡇⣸⠑⢦⣻⣿⠏⠀⢀⣾⣿⣸⣿⣩⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠙⡣⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠟⠃⣜⣿⣿⣧⣸⣿⠁⠀⠀⣿⣿⣿⡟⠀⠀⠀⠀⢰⣴⡟⠀⢀⡿⠃⠀⣠⠋⣹⡏⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠐⠤⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⣿⣿⣿⡦⣿⡟⠀⠀⣼⣿⣿⣿⠓⢤⣄⣤⣴⣿⣏⣀⣠⢾⠁⠀⡴⢇⣾⣿⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⢣
 * ⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡻⠋⠻⠆⠀⠀⣰⣿⣿⣿⣿⣿⠇⠀⣾⣿⣿⡿⡇⠈⠒⠦⠖⢻⡟⠁⣰⠃⠈⠀⡼⢁⣼⣿⡇⣾⢈⣹⣹⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣧⠀⠀⠀⠀⠀
 * ⣿⣿⣿⣿⣿⣿⣿⣿⢟⡵⠁⠀⠀⠀⢠⣲⠟⣿⣿⣿⣿⠏⣠⣾⣿⣿⣧⣰⠁⠀⠀⠀⠀⣾⠹⢾⠁⠀⣧⡾⣡⣾⡟⢻⡇⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⡆⠀⠀⠀⠀
 * ⣿⣿⣿⣿⣿⠿⠋⠀⠞⠀⠀⠀⠀⠀⣿⢏⡾⢃⣼⠟⣡⣾⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⢠⢏⠀⢇⠀⠀⢸⣰⣿⣇⣗⣾⣇⢿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀
 * ⢿⣿⠿⠋⣀⣤⠖⠀⠀⠀⠀⠀⠀⣼⣿⢏⣠⣞⣵⣿⣿⣿⣿⣿⣿⣟⣿⠁⠀⠀⠀⠀⣾⠀⠱⣼⡆⠀⢸⠹⣿⡄⣾⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠈⢻⣿⡄⠀⠀
 */
interface IUlyssesPool {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice The bandwidth state of a Ulysses LP
     * @param bandwidth The available bandwidth for the given pool's ID
     * @param weight The weight to calculate the target bandwidth for the given pool's ID
     * @param destination The destination Ulysses LP
     */
    struct BandwidthState {
        uint248 bandwidth;
        uint8 weight;
        UlyssesPool destination;
    }

    /**
     * @notice The fees charged to incentivize rebalancing
     *  @param lambda1 The fee charged for rebalancing in upper bound (in basis points divided 2)
     *  @param lambda2 The fee charged for rebalancing in lower bound (in basis points divided 2)
     *  @param sigma1 The bandiwth upper bound to start charging the first rebalancing fees
     *  @param sigma2 The bandiwth lower bound to start charging the second rebalancing fees
     */
    struct Fees {
        uint64 lambda1;
        uint64 lambda2;
        uint64 sigma1;
        uint64 sigma2;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the available bandwidth for the given pool's ID, if it doesn't have a connection it will return 0
     * @param destinationId The ID of a Ulysses LP
     * @return bandwidth The available bandwidth for the given pool's ID
     */

    function getBandwidth(uint256 destinationId) external view returns (uint256);

    /**
     * @notice Gets the bandwidth state list
     *  @return bandwidthStateList The bandwidth state list
     */
    function getBandwidthStateList() external view returns (BandwidthState[] memory);

    /**
     * @notice Calculates the amount of tokens that can be redeemed by the protocol.
     */
    function getProtocolFees() external view returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sends all outstanding protocol fees to factory owner
     * @dev Anyone can call this function
     */
    function claimProtocolFees() external returns (uint256 claimed);

    /**
     * @notice Adds a new Ulysses LP with the requested weight
     * @dev Can't remove a destination, only add new ones
     * @param poolId The ID of the destination Ulysses LP to be added
     * @param weight The weight to calculate the bandwidth for the given pool's ID
     * @return index The index of bandwidthStateList of the newly added Ulysses LP
     */
    function addNewBandwidth(uint256 poolId, uint8 weight) external returns (uint256 index);

    /**
     * @notice Changes the weight of a exisiting Ulysses LP with the given ID
     * @param poolId The ID of the destination Ulysses LP to be removed
     * @param weight The new weight to calculate the bandwidth for the given pool's ID
     */
    function setWeight(uint256 poolId, uint8 weight) external;

    /**
     * @notice Sets the protocol and rebalancing fees
     * @param _fees The new fees to be set
     */
    function setFees(Fees calldata _fees) external;

    /**
     * @notice Sets the protocol fee
     * @param _protocolFee The new protocol fee to be set
     * @dev Only factory owner can call this function
     */
    function setProtocolFee(uint256 _protocolFee) external;

    /**
     * @notice Swaps from this Ulysses LP's underlying to the destination Ulysses LP's underlying.
     *       Distributes amount between bandwidths in the source, having a positive rebalancing fee
     *       Calls swapDestination of the destination Ulysses LP
     * @param amount The amount to be dsitributed to bandwidth
     * @param poolId The ID of the destination Ulysses LP
     * @return output The output amount transfered to user from the destination Ulysses LP
     */
    function swapIn(uint256 amount, uint256 poolId) external returns (uint256 output);

    /**
     * @notice Swaps from the caller (source Ulysses LP's) underlying to this Ulysses LP's underlying.
     *       Called from swapIn of the source Ulysses LP
     *       Removes amount from the source's bandwidth, having a negative rebalancing fee
     * @dev Only Ulysses LPs added as destinations can call this function
     * @param amount The amount to be removed from source's bandwidth
     * @param user The user to be transfered the output
     * @return output The output amount transfered to user
     */
    function swapFromPool(uint256 amount, address user) external returns (uint256 output);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Throw when trying to re-add pool or adding itself
    error InvalidPool();

    /// @notice Throw when trying to add a destination that is not a Ulysses LP
    error NotUlyssesLP();

    /// @notice Throw when fee would overflow
    error FeeError();

    /// @notice Throw when input amount is too small
    error AmountTooSmall();

    /// @notice Throw when weight is 0 or exceeds MAX_TOTAL_WEIGHT
    error InvalidWeight();

    /// @notice Throw when settng an invalid fee
    error InvalidFee();

    /// @notice Throw when weight is 0 or exceeds MAX_TOTAL_WEIGHT
    error TooManyDestinations();

    /// @notice Throw when adding/removing LPs before adding any destinations
    error NotInitialized();

    /// @notice Thrown when muldiv fails due to multiplication overflow
    error MulDivFailed();

    /// @notice Thrown when addition overflows
    error Overflow();

    /// @notice Thrown when subtraction underflows
    error Underflow();

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a user swaps from this Ulysses LP's underlying to the destination Ulysses LP's underlying
     * @param caller The caller of the swap
     * @param poolId The ID of the destination Ulysses LP
     * @param assets The amount of underlying deposited in this Ulysses LP
     */
    event Swap(address indexed caller, uint256 indexed poolId, uint256 assets);
}


// src/ulysses-amm/UlyssesPool.sol

/// @title Ulysses Pool - Single Sided Stableswap LP
/// @author Maia DAO (https://github.com/Maia-DAO)
contract UlyssesPool is UlyssesERC4626, Ownable, IUlyssesPool {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    using SafeCastLib for uint256;

    /// @notice ulysses factory associated with the Ulysses LP
    UlyssesFactory public immutable factory;

    /// @notice ID of this Ulysses LP
    uint256 public immutable id;

    /// @notice List of all added LPs
    BandwidthState[] public bandwidthStateList;

    /// @notice destinations[destinationId] => bandwidthStateList index
    mapping(uint256 => uint256) public destinations;

    /// @notice destinationIds[address] => destinationId
    mapping(address => uint256) public destinationIds;

    /// @notice Sum of all weights
    uint256 public totalWeights;

    /// @notice The minimum amount that can be swapped
    uint256 private constant MIN_SWAP_AMOUNT = 1e4;

    /// @notice The maximum sum of all weights
    uint256 private constant MAX_TOTAL_WEIGHT = 256;

    /// @notice The maximum destinations that can be added
    uint256 private constant MAX_DESTINATIONS = 15;

    /// @notice The maximum protocol fee that can be set (1%)
    uint256 private constant MAX_PROTOCOL_FEE = 1e16;

    /// @notice The maximum lambda1 that can be set (10%)
    uint256 private constant MAX_LAMBDA1 = 1e17;

    /// @notice The minimum sigma2 that can be set (1%)
    uint256 private constant MIN_SIGMA2 = 1e16;

    /*//////////////////////////////////////////////////////////////
                            FEE PARAMETERS
    //////////////////////////////////////////////////////////////*/

    /// @notice The divisioner for fee calculations
    uint256 private constant DIVISIONER = 1 ether;

    uint256 public protocolFee = 1e14;

    /// @notice The current rebalancing fees
    Fees public fees = Fees({lambda1: 20e14, lambda2: 4980e14, sigma1: 6000e14, sigma2: 500e14});

    /**
     * @param _id the Ulysses LP ID
     * @param _asset the underlying asset
     * @param _name the name of the LP
     * @param _symbol the symbol of the LP
     * @param _owner the owner of this contract
     * @param _factory the Ulysses factory
     */
    constructor(
        uint256 _id,
        address _asset,
        string memory _name,
        string memory _symbol,
        address _owner,
        address _factory
    ) UlyssesERC4626(_asset, _name, _symbol) {
        require(_owner != address(0));
        factory = UlyssesFactory(_factory);
        _initializeOwner(_owner);
        require(_id != 0);
        id = _id;

        bandwidthStateList.push(BandwidthState({bandwidth: 0, destination: UlyssesPool(address(0)), weight: 0}));
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    // @inheritdoc UlyssesERC4626
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this)) - getProtocolFees();
    }

    // @inheritdoc UlyssesERC4626
    function maxRedeem(address owner) public view override returns (uint256) {
        return balanceOf[owner].min(asset.balanceOf(address(this)));
    }

    /// @inheritdoc IUlyssesPool
    function getBandwidth(uint256 destinationId) external view returns (uint256) {
        /**
         * @dev bandwidthStateList first element has always 0 bandwidth
         *      so this line will never fail and return 0 instead
         */
        return bandwidthStateList[destinations[destinationId]].bandwidth;
    }

    /// @inheritdoc IUlyssesPool
    function getBandwidthStateList() external view returns (BandwidthState[] memory) {
        return bandwidthStateList;
    }

    /// @inheritdoc IUlyssesPool
    function getProtocolFees() public view returns (uint256) {
        uint256 balance = asset.balanceOf(address(this));
        uint256 assets;

        for (uint256 i = 1; i < bandwidthStateList.length; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);

            assets += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);

            assets += bandwidthStateList[i].bandwidth;
        }

        if (balance > assets) {
            return balance - assets;
        } else {
            return 0;
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUlyssesPool
    function claimProtocolFees() external nonReentrant returns (uint256 claimed) {
        claimed = getProtocolFees();

        if (claimed > 0) {
            asset.safeTransfer(factory.owner(), claimed);
        }
    }

    /// @inheritdoc IUlyssesPool
    function addNewBandwidth(uint256 poolId, uint8 weight) external nonReentrant onlyOwner returns (uint256 index) {
        if (weight == 0) revert InvalidWeight();

        UlyssesPool destination = factory.pools(poolId);
        uint256 destinationId = destination.id();

        if (destinationIds[address(destination)] != 0 || destinationId == id) revert InvalidPool();

        if (destinationId == 0) revert NotUlyssesLP();

        index = bandwidthStateList.length;

        if (index > MAX_DESTINATIONS) revert TooManyDestinations();

        uint256 oldRebalancingFee;

        for (uint256 i = 1; i < index; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);

            oldRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }

        uint256 oldTotalWeights = totalWeights;
        uint256 newTotalWeights = oldTotalWeights + weight;
        totalWeights = newTotalWeights;

        if (newTotalWeights > MAX_TOTAL_WEIGHT) revert InvalidWeight();

        uint256 newBandwidth;

        for (uint256 i = 1; i < index;) {
            uint256 oldBandwidth = bandwidthStateList[i].bandwidth;
            if (oldBandwidth > 0) {
                bandwidthStateList[i].bandwidth = oldBandwidth.mulDivUp(oldTotalWeights, newTotalWeights).toUint248();

                newBandwidth += oldBandwidth - bandwidthStateList[i].bandwidth;
            }

            unchecked {
                ++i;
            }
        }

        bandwidthStateList.push(
            BandwidthState({bandwidth: newBandwidth.toUint248(), destination: destination, weight: weight})
        );

        destinations[destinationId] = index;
        destinationIds[address(destination)] = index;

        uint256 newRebalancingFee;

        for (uint256 i = 1; i <= index; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);

            newRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }

        if (oldRebalancingFee < newRebalancingFee) {
            asset.safeTransferFrom(msg.sender, address(this), newRebalancingFee - oldRebalancingFee);
        }
    }

    /// @inheritdoc IUlyssesPool
    function setWeight(uint256 poolId, uint8 weight) external nonReentrant onlyOwner {
        if (weight == 0) revert InvalidWeight();

        uint256 poolIndex = destinations[poolId];

        if (poolIndex == 0) revert NotUlyssesLP();

        uint256 oldRebalancingFee;

        for (uint256 i = 1; i < bandwidthStateList.length; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);

            oldRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }

        uint256 oldTotalWeights = totalWeights;
        uint256 weightsWithoutPool = oldTotalWeights - bandwidthStateList[poolIndex].weight;
        uint256 newTotalWeights = weightsWithoutPool + weight;
        totalWeights = newTotalWeights;

        if (totalWeights > MAX_TOTAL_WEIGHT || oldTotalWeights == newTotalWeights) {
            revert InvalidWeight();
        }

        uint256 leftOverBandwidth;

        BandwidthState storage poolState = bandwidthStateList[poolIndex];
        poolState.weight = weight;

        if (oldTotalWeights > newTotalWeights) {
            for (uint256 i = 1; i < bandwidthStateList.length;) {
                if (i != poolIndex) {
                    uint256 oldBandwidth = bandwidthStateList[i].bandwidth;
                    if (oldBandwidth > 0) {
                        bandwidthStateList[i].bandwidth =
                            oldBandwidth.mulDivUp(oldTotalWeights, newTotalWeights).toUint248();

                        leftOverBandwidth += oldBandwidth - bandwidthStateList[i].bandwidth;
                    }
                }

                unchecked {
                    ++i;
                }
            }

            poolState.bandwidth += leftOverBandwidth.toUint248();
        } else {
            uint256 oldBandwidth = poolState.bandwidth;
            if (oldBandwidth > 0) {
                poolState.bandwidth = oldBandwidth.mulDivUp(oldTotalWeights, newTotalWeights).toUint248();

                leftOverBandwidth += oldBandwidth - poolState.bandwidth;
            }

            for (uint256 i = 1; i < bandwidthStateList.length;) {
                if (i != poolIndex) {
                    if (i == bandwidthStateList.length - 1) {
                        bandwidthStateList[i].bandwidth += leftOverBandwidth.toUint248();
                    } else if (leftOverBandwidth > 0) {
                        bandwidthStateList[i].bandwidth +=
                            leftOverBandwidth.mulDiv(bandwidthStateList[i].weight, weightsWithoutPool).toUint248();
                    }
                }

                unchecked {
                    ++i;
                }
            }
        }

        uint256 newRebalancingFee;

        for (uint256 i = 1; i < bandwidthStateList.length; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);

            newRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }

        if (oldRebalancingFee < newRebalancingFee) {
            asset.safeTransferFrom(msg.sender, address(this), newRebalancingFee - oldRebalancingFee);
        }
    }

    /// @inheritdoc IUlyssesPool
    function setFees(Fees calldata _fees) external nonReentrant onlyOwner {
        // Lower fee must be lower than 1%
        if (_fees.lambda1 > MAX_LAMBDA1) revert InvalidFee();
        // Sum of both fees must be 50%
        if (_fees.lambda1 + _fees.lambda2 != DIVISIONER / 2) revert InvalidFee();

        // Upper bound must be lower than 100%
        if (_fees.sigma1 > DIVISIONER) revert InvalidFee();
        // Lower bound must be lower than Upper bound and higher than 1%
        if (_fees.sigma1 <= _fees.sigma2 || _fees.sigma2 < MIN_SIGMA2) revert InvalidFee();

        fees = _fees;
    }

    /// @inheritdoc IUlyssesPool
    function setProtocolFee(uint256 _protocolFee) external nonReentrant {
        if (msg.sender != factory.owner()) revert Unauthorized();

        // Revert if the protocol fee is larger than 1%
        if (_protocolFee > MAX_PROTOCOL_FEE) revert InvalidFee();

        protocolFee = _protocolFee;
    }

    /*//////////////////////////////////////////////////////////////
                            ULYSSES LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Calculates the bandwidth increase/decrease amount.
     * Is called when a user is doing a swap or adding/removing liquidity.
     * @param roundUp Whether to round up or down
     * @param positiveTransfer Whether the transfer is positive or negative
     * @param amount The amount to transfer
     * @param _totalWeights The total weights
     * @param _totalSupply The total supply
     */
    function getBandwidthUpdateAmounts(
        bool roundUp,
        bool positiveTransfer,
        uint256 amount,
        uint256 _totalWeights,
        uint256 _totalSupply
    ) private view returns (uint256[] memory bandwidthUpdateAmounts, uint256 length) {
        // Get the bandwidth state list length
        length = bandwidthStateList.length;

        /// @solidity memory-safe-assembly
        assembly {
            // Revert if the list is empty
            if eq(length, 1) {
                // Store the function selector of `NotInitialized()`.
                mstore(0x00, 0x87138d5c)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Revert if the amount is too small
            if lt(amount, MIN_SWAP_AMOUNT) {
                // Store the function selector of `AmountTooSmall()`.
                mstore(0x00, 0xc2f5625a)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }

        // Initialize bandwidth update amounts
        bandwidthUpdateAmounts = new uint256[](length);
        // Initialize bandwidth differences from target bandwidth
        uint256[] memory diffs = new uint256[](length);

        /// @solidity memory-safe-assembly
        assembly {
            // Store bandwidth state slot in memory
            mstore(0x00, bandwidthStateList.slot)
            // Hash the bandwidth state slot to get the bandwidth state list start
            let bandwidthStateListStart := keccak256(0x00, 0x20)

            // Total difference from target bandwidth of all bandwidth states
            let totalDiff
            // Total difference from target bandwidth of all bandwidth states
            let transfered
            // Total amount to be distributed according to each bandwidth weights
            let transferedChange

            for { let i := 1 } lt(i, length) { i := add(i, 1) } {
                // Load bandwidth and weight from storage
                // Each bandwidth state occupies two storage slots
                let slot := sload(add(bandwidthStateListStart, mul(i, 2)))
                // Bandwidth is the first 248 bits of the slot
                let bandwidth := and(slot, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                // Weight is the last 8 bits of the slot
                let weight := shr(248, slot)

                // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
                if mul(weight, gt(_totalSupply, div(not(0), weight))) {
                    // Store the function selector of `MulDivFailed()`.
                    mstore(0x00, 0xad251c27)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }

                // Calculate the target bandwidth
                let targetBandwidth := div(mul(_totalSupply, weight), _totalWeights)

                // Calculate the difference from the target bandwidth
                switch positiveTransfer
                // If the transfer is positive, calculate deficit from target bandwidth
                case true {
                    // If there is a deficit, store the difference
                    if gt(targetBandwidth, bandwidth) {
                        // Calculate the difference
                        let diff := sub(targetBandwidth, bandwidth)
                        // Add the difference to the total difference
                        totalDiff := add(totalDiff, diff)
                        // Store the difference in the diffs array
                        mstore(add(diffs, add(mul(i, 0x20), 0x20)), diff)
                    }
                }
                // If the transfer is negative, calculate surplus from target bandwidth
                default {
                    // If there is a surplus, store the difference
                    if gt(bandwidth, targetBandwidth) {
                        // Calculate the difference
                        let diff := sub(bandwidth, targetBandwidth)
                        // Add the difference to the total difference
                        totalDiff := add(totalDiff, diff)
                        // Store the difference in the diffs array
                        mstore(add(diffs, add(mul(i, 0x20), 0x20)), diff)
                    }
                }
            }

            // Calculate the amount to be distributed according deficit/surplus
            // and/or the amount to be distributed according to each bandwidth weights
            switch gt(amount, totalDiff)
            // If the amount is greater than the total deficit/surplus
            case true {
                // Total deficit/surplus is distributed
                transfered := totalDiff
                // Set rest to be distributed according to each bandwidth weights
                transferedChange := sub(amount, totalDiff)
            }
            // If the amount is less than the total deficit/surplus
            default {
                // Amount will be distributed according to deficit/surplus
                transfered := amount
            }

            for { let i := 1 } lt(i, length) { i := add(i, 1) } {
                // Increase/decrease amount of bandwidth for each bandwidth state
                let bandwidthUpdate

                // If there is a deficit/surplus, calculate the amount to be distributed
                if gt(transfered, 0) {
                    // Load the difference from the diffs array
                    let diff := mload(add(diffs, add(mul(i, 0x20), 0x20)))

                    // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
                    if mul(diff, gt(transfered, div(not(0), diff))) {
                        // Store the function selector of `MulDivFailed()`.
                        mstore(0x00, 0xad251c27)
                        // Revert with (offset, size).
                        revert(0x1c, 0x04)
                    }

                    // Calculate the amount to be distributed according to deficit/surplus
                    switch roundUp
                    // If round up then do mulDivUp(transfered, diff, totalDiff)
                    case true {
                        bandwidthUpdate :=
                            add(
                                iszero(iszero(mod(mul(transfered, diff), totalDiff))), div(mul(transfered, diff), totalDiff)
                            )
                    }
                    // If round down then do mulDiv(transfered, diff, totalDiff)
                    default { bandwidthUpdate := div(mul(transfered, diff), totalDiff) }
                }

                // If there is a rest, calculate the amount to be distributed according to each bandwidth weights
                if gt(transferedChange, 0) {
                    // Load weight from storage
                    let weight := shr(248, sload(add(bandwidthStateListStart, mul(i, 2))))

                    // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
                    if mul(weight, gt(transferedChange, div(not(0), weight))) {
                        // Store the function selector of `MulDivFailed()`.
                        mstore(0x00, 0xad251c27)
                        // Revert with (offset, size).
                        revert(0x1c, 0x04)
                    }

                    // Calculate the amount to be distributed according to each bandwidth weights
                    switch roundUp
                    // If round up then do mulDivUp(transferedChange, weight, _totalWeights)
                    case true {
                        bandwidthUpdate :=
                            add(
                                bandwidthUpdate,
                                add(
                                    iszero(iszero(mod(mul(transferedChange, weight), _totalWeights))),
                                    div(mul(transferedChange, weight), _totalWeights)
                                )
                            )
                    }
                    // If round down then do mulDiv(transferedChange, weight, _totalWeights)
                    default {
                        bandwidthUpdate := add(bandwidthUpdate, div(mul(transferedChange, weight), _totalWeights))
                    }
                }

                // If there is an update in bandwidth
                if gt(bandwidthUpdate, 0) {
                    // Store the amount to be updated in the bandwidthUpdateAmounts array
                    mstore(add(bandwidthUpdateAmounts, add(mul(i, 0x20), 0x20)), bandwidthUpdate)
                }
            }
        }
    }

    /**
     * @notice Updates the bandwidth of the destination Ulysses LP
     * @param depositFees Whether to deposit fees or not
     * @param positiveTransfer Whether the transfer is positive or negative
     * @param destinationState The state of the destination Ulysses LP
     * @param difference The difference between the old and new total supply
     * @param _totalWeights The total weights of all Ulysses LPs
     * @param _totalSupply The total supply of the Ulysses LP
     * @param _newTotalSupply  The new total supply of the Ulysses LP
     * @return positivefee The positive fee
     */
    function updateBandwidth(
        bool depositFees,
        bool positiveTransfer,
        BandwidthState storage destinationState,
        uint256 difference,
        uint256 _totalWeights,
        uint256 _totalSupply,
        uint256 _newTotalSupply
    ) private returns (uint256 positivefee, uint256 negativeFee) {
        uint256 bandwidth;
        uint256 targetBandwidth;
        uint256 weight;

        /// @solidity memory-safe-assembly
        assembly {
            // Load bandwidth and weight from storage
            let slot := sload(destinationState.slot)
            // Bandwidth is the first 248 bits of the slot
            bandwidth := and(slot, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            // Weight is the last 8 bits of the slot
            weight := shr(248, slot)

            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(weight, gt(_totalSupply, div(not(0), weight))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Get the target bandwidth
            targetBandwidth := div(mul(_totalSupply, weight), _totalWeights)
        }

        // get the rebalancing fee prior to updating the bandwidth
        uint256 oldRebalancingFee = _calculateRebalancingFee(
            bandwidth,
            targetBandwidth,
            positiveTransfer // Rounds down if positive, up if negative
        );

        /// @solidity memory-safe-assembly
        assembly {
            switch positiveTransfer
            // If the transfer is positive
            case true {
                // Add the difference to the bandwidth
                bandwidth := add(bandwidth, difference)

                // Revert if bandwidth overflows
                if lt(bandwidth, difference) {
                    // Store the function selector of `Overflow()`.
                    mstore(0x00, 0x35278d12)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }
            }
            // If the transfer is negative
            default {
                // Revert if bandwidth underflows
                if gt(difference, bandwidth) {
                    // Store the function selector of `Underflow()`.
                    mstore(0x00, 0xcaccb6d9)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }

                // Subtract the difference from the bandwidth
                bandwidth := sub(bandwidth, difference)
            }

            // True on deposit, mint and redeem
            if gt(_newTotalSupply, 0) {
                // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
                if mul(weight, gt(_newTotalSupply, div(not(0), weight))) {
                    // Store the function selector of `MulDivFailed()`.
                    mstore(0x00, 0xad251c27)
                    // Revert with (offset, size).
                    revert(0x1c, 0x04)
                }

                // Get the new target bandwidth after total supply change
                targetBandwidth := div(mul(_newTotalSupply, weight), _totalWeights)
            }
        }

        // get the rebalancing fee after updating the bandwidth
        uint256 newRebalancingFee = _calculateRebalancingFee(
            bandwidth,
            targetBandwidth,
            positiveTransfer // Rounds down if positive, up if negative
        );

        /// @solidity memory-safe-assembly
        assembly {
            switch lt(newRebalancingFee, oldRebalancingFee)
            // If new fee is lower than old fee
            case true {
                // Calculate the positive fee
                positivefee := sub(oldRebalancingFee, newRebalancingFee)

                // If depositFees is true, add the positive fee to the bandwidth
                if depositFees {
                    bandwidth := add(bandwidth, positivefee)

                    // Revert if bandwidth overflows
                    if lt(bandwidth, positivefee) {
                        // Store the function selector of `Overflow()`.
                        mstore(0x00, 0x35278d12)
                        // Revert with (offset, size).
                        revert(0x1c, 0x04)
                    }
                }
            }
            default {
                // If new fee is higher than old fee
                if gt(newRebalancingFee, oldRebalancingFee) {
                    // Calculate the negative fee
                    negativeFee := sub(newRebalancingFee, oldRebalancingFee)
                }
            }

            if gt(bandwidth, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
                // Store the function selector of `Overflow()`.
                mstore(0x00, 0x35278d12)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Update storage with the new bandwidth
            sstore(destinationState.slot, or(bandwidth, shl(248, weight)))
        }
    }

    /**
     * @notice Calculates the positive or negative rebalancing fee for a bandwidth change
     * @param bandwidth The new bandwidth, after decreasing or increasing the current bandwidth
     * @param targetBandwidth The ideal bandwidth according to weight and totalSupply
     * @param roundDown Whether to round down or up
     * @return fee The rebalancing fee for this action
     */
    function _calculateRebalancingFee(uint256 bandwidth, uint256 targetBandwidth, bool roundDown)
        internal
        view
        returns (uint256 fee)
    {
        // If the bandwidth is larger or equal to the target bandwidth, return 0
        if (bandwidth >= targetBandwidth) return 0;

        // Upper bound of the first fee interval
        uint256 upperBound1;
        // Upper bound of the second fee interval
        uint256 upperBound2;
        // Fee tier 1 (fee % divided by 2)
        uint256 lambda1;
        // Fee tier 2 (fee % divided by 2)
        uint256 lambda2;

        // @solidity memory-safe-assembly
        assembly {
            // Load the rebalancing fee slot to get the fee parameters
            let feeSlot := sload(fees.slot)
            // Get sigma2 from the first 8 bytes of the fee slot
            let sigma2 := shr(192, feeSlot)
            // Get sigma1 from the next 8 bytes of the fee slot
            let sigma1 := and(shr(128, feeSlot), 0xffffffffffffffff)
            // Get lambda2 from the next 8 bytes of the fee slot
            lambda2 := and(shr(64, feeSlot), 0xffffffffffffffff)
            // Get lambda1 from the last 8 bytes of the fee slot
            lambda1 := and(feeSlot, 0xffffffffffffffff)

            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if mul(sigma1, gt(targetBandwidth, div(not(0), sigma1))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Calculate the upper bound for the first fee
            upperBound1 := div(mul(targetBandwidth, sigma1), DIVISIONER)

            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if mul(sigma2, gt(targetBandwidth, div(not(0), sigma2))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Calculate the upper bound for the second fee
            upperBound2 := div(mul(targetBandwidth, sigma2), DIVISIONER)
        }

        if (bandwidth >= upperBound1) return 0;

        uint256 maxWidth;
        /// @solidity memory-safe-assembly
        assembly {
            // Calculate the maximum width of the trapezium
            maxWidth := sub(upperBound1, upperBound2)
        }

        // If the bandwidth is smaller than upperBound2
        if (bandwidth >= upperBound2) {
            // Calculate the fee for the first interval
            fee = calcFee(lambda1, maxWidth, upperBound1, bandwidth, 0, roundDown);
        } else {
            // Calculate the fee for the first interval
            fee = calcFee(lambda1, maxWidth, upperBound1, upperBound2, 0, roundDown);

            /// @solidity memory-safe-assembly
            assembly {
                // offset = lambda1 * 2
                lambda1 := shl(1, lambda1)
            }

            // Calculate the fee for the second interval
            uint256 fee2 = calcFee(lambda2, upperBound2, upperBound2, bandwidth, lambda1, roundDown);

            /// @solidity memory-safe-assembly
            assembly {
                // Add the two fees together
                fee := add(fee, fee2)
            }
        }
    }

    /**
     *  @notice Calculates outstanding rebalancing fees for a specific bandwidth
     *  @dev The fee is calculated as a trapezium with a base of width and a height of height
     *       The formula for the area of a trapezium is (a + b) * h / 2
     *                          ___________
     *          fee1 + fee2 -->|          /|
     *                         |         / |
     *                         |________/  |
     *  fee1 + fee2 * amount-->|       /|  |
     *         -------------   |      / |  |
     *           max width     |     /  |  |
     *                         |____/   |  |
     *                 fee1 -->|   |    |  |
     *                         |   |    |  |
     *                         |___|____|__|_____
     *                             |    |  |
     *                    upper bound 2 |  0
     *                                  |
     *                              bandwidth
     *
     *         max width = upper bound 2
     *         amount = upper bound 2 - bandwidth
     *
     *           h = amount
     *           a = fee1 + (fee2 * amount / max width)
     *           b = fee1
     *
     *           fee = (a + b) * h / 2
     *               = (fee1 + fee1 + (fee2 * amount / max width)) * amount / 2
     *               = ((fee1 * 2) + (fee2 * amount / max width)) * amount / 2
     *
     *         Because lambda1 = fee1 / 2 and lambda2 = fee2 / 2
     *
     *         fee = ((fee1 * 2) + (fee2 * amount / max width)) * amount / 2
     *             = (lambda1 * 2 * amount) + (lambda2 * amount * amount) / max width
     *             = amount * ((lambda1 * 2) + (lambda2 * amount / max width))
     *
     *
     *       When offset (b) is 0, the trapezium is equivalent to a triangle:
     *                          ___________
     *                 fee1 -->|          /|
     *                         |         / |
     *                         |________/  |
     *        fee1 * amount -->|       /|  |
     *        -------------    |      / |  |
     *          max width      |     /  |  |
     *                         |    /   |  |
     *                         |___/____|__|_____
     *                             |    |  |
     *                    upper bound 1 | upper bound 2
     *                                  |
     *                              bandwidth
     *
     *         max width = upper bound 1 - upper bound 2
     *         amount = upper bound 1 - bandwidth
     *
     *           h = amount
     *           a = fee1 * amount / max width
     *           b = 0
     *
     *           fee = (a + b) * h / 2
     *               = fee1 * amount * amount / (2 * max width)
     *
     *         Because lambda1 = fee1 / 2
     *
     *         fee = fee1 * amount * amount / (2 * max width)
     *             = lambda2 * amount * amount / max width
     *
     *  @param feeTier The fee tier of the bandwidth
     *  @param maxWidth The maximum width of the bandwidth
     *  @param upperBound The upper bound of the bandwidth
     *  @param bandwidth The bandwidth of the bandwidth
     *  @param offset The offset of the bandwidth
     *  @param roundDown Whether to round down or up
     */
    function calcFee(
        uint256 feeTier,
        uint256 maxWidth,
        uint256 upperBound,
        uint256 bandwidth,
        uint256 offset,
        bool roundDown
    ) private pure returns (uint256 fee) {
        /// @solidity memory-safe-assembly
        assembly {
            // Calculate the height of the trapezium
            // The height is calculated as `upperBound - bandwidth`
            let height := sub(upperBound, bandwidth)

            // Equivalent to `require(y == 0 || x <= type(uint256).max / y)`.
            if mul(feeTier, gt(height, div(not(0), feeTier))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Calculate the width of the trapezium, rounded up
            // The width is calculated as `feeTier * height / maxWidth + offset`
            let width :=
                add(add(iszero(iszero(mod(mul(height, feeTier), maxWidth))), div(mul(height, feeTier), maxWidth)), offset)

            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if mul(height, gt(width, div(not(0), height))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Calculate the fee for this tier
            switch roundDown
            // If round down then do mulDiv(transfered, diff, totalDiff)
            case true { fee := div(mul(width, height), DIVISIONER) }
            // If round up then do mulDivUp(transfered, diff, totalDiff)
            default {
                fee := add(iszero(iszero(mod(mul(width, height), DIVISIONER))), div(mul(width, height), DIVISIONER))
            }
        }
    }

    /**
     * @notice Adds assets to bandwidths and returns the assets to be swapped to a destination pool
     * @param assets The assets to be distributed between all bandwidths
     * @return output The assets of assets to be swapped to a destination pool
     */
    function ulyssesSwap(uint256 assets) private returns (uint256 output) {
        uint256 _totalWeights = totalWeights;
        uint256 _totalSupply = totalSupply;

        // Get the bandwidth update amounts and chainStateList length
        (uint256[] memory bandwidthUpdateAmounts, uint256 length) = getBandwidthUpdateAmounts(
            false, // round down bandwidths
            true, // is positive transfer
            assets,
            _totalWeights,
            _totalSupply
        );

        for (uint256 i = 1; i < length;) {
            // Get the update amount for this bandwidth
            uint256 updateAmount = bandwidthUpdateAmounts[i];

            // if updateAmount > 0
            if (updateAmount > 0) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Add updateAmount to output
                    output := add(output, updateAmount)
                }

                // Update bandwidth with the update amount and get the positive fee
                // Negative fee is always 0 because totalSupply does not increase
                (uint256 positiveFee,) =
                    updateBandwidth(true, true, bandwidthStateList[i], updateAmount, _totalWeights, _totalSupply, 0);

                /// @solidity memory-safe-assembly
                assembly {
                    // if positiveFee > 0 then add positiveFee to output
                    if gt(positiveFee, 0) { output := add(output, positiveFee) }
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Adds amount to bandwidths and returns assets to deposit or shares to mint
     * @param amount The amount to be distributed between all bandwidths
     * @param depositFees True when called from deposit, false when called from mint
     * @return output The output amount to be minted or deposited
     */
    function ulyssesAddLP(uint256 amount, bool depositFees) private returns (uint256 output) {
        uint256 _totalWeights = totalWeights;
        uint256 _totalSupply = totalSupply;
        uint256 _newTotalSupply;

        /// @solidity memory-safe-assembly
        assembly {
            // Get the new total supply by adding amount to totalSupply
            _newTotalSupply := add(_totalSupply, amount)
        }

        // Get the bandwidth update amounts and chainStateList length
        // newTotalSupply is used to avoid negative rebalancing fees
        // Rounds up when depositFees is false
        (uint256[] memory bandwidthUpdateAmounts, uint256 length) =
            getBandwidthUpdateAmounts(!depositFees, true, amount, _totalWeights, _newTotalSupply);

        // Discount in assets in `mint` or negative fee in `deposit`
        uint256 negativeFee;
        for (uint256 i = 1; i < length;) {
            // Get the update amount for this bandwidth
            uint256 updateAmount = bandwidthUpdateAmounts[i];

            /// @solidity memory-safe-assembly
            assembly {
                // if updateAmount > 0 then add updateAmount to output
                if gt(updateAmount, 0) { output := add(output, updateAmount) }
            }

            // Update bandwidth with the update amount and get the positive fee and negative fee
            (uint256 _positiveFee, uint256 _negativeFee) = updateBandwidth(
                depositFees, true, bandwidthStateList[i], updateAmount, _totalWeights, _totalSupply, _newTotalSupply
            );

            /// @solidity memory-safe-assembly
            assembly {
                switch depositFees
                // if depositFees is true, `deposit` was called
                case true {
                    switch gt(_positiveFee, 0)
                    // if _positiveFee > 0 then add _positiveFee to output
                    // Adding shares to mint
                    case true { output := add(output, _positiveFee) }
                    // if _positiveFee <= 0 then add _negativeFee to negativeFee
                    // Subtracting shares to mint
                    default { negativeFee := add(negativeFee, _negativeFee) }
                }
                // if depositFees is false, `mint` was called
                default {
                    switch gt(_positiveFee, 0)
                    // if _positiveFee > 0 then add _positiveFee to output
                    // Subtracting assets to deposit
                    case true { negativeFee := add(negativeFee, _positiveFee) }
                    // if _positiveFee <= 0 then add _negativeFee to output
                    // Adding assets to deposit
                    default { output := add(output, _negativeFee) }
                }
            }

            unchecked {
                ++i;
            }
        }

        /// @solidity memory-safe-assembly
        assembly {
            // Revert if output underflows
            if gt(negativeFee, output) {
                // Store the function selector of `Underflow()`.
                mstore(0x00, 0xcaccb6d9)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Subtracting assets to deposit or shares to mint
            output := sub(output, negativeFee)
        }
    }

    /**
     * @notice Removes shares from bandwidths and returns assets to withdraw
     * @param shares The shares to be removed between all bandwidths
     * @return assets The shares of assets to withdraw
     */
    function ulyssesRemoveLP(uint256 shares) private returns (uint256 assets) {
        uint256 _totalWeights = totalWeights;
        uint256 _totalSupply;
        uint256 _newTotalSupply = totalSupply;

        /// @solidity memory-safe-assembly
        assembly {
            // Get the old total supply by adding burned shares to totalSupply
            _totalSupply := add(_newTotalSupply, shares)
        }

        // Get the bandwidth update amounts and chainStateList length
        (uint256[] memory bandwidthUpdateAmounts, uint256 length) =
            getBandwidthUpdateAmounts(false, false, shares, _totalWeights, _totalSupply);

        // Assets paid as negative rebalancing fees
        uint256 negativeFee;
        for (uint256 i = 1; i < length;) {
            // Get the update amount for this bandwidth
            uint256 updateAmount = bandwidthUpdateAmounts[i];

            // If updateAmount > 0, update bandwidth and add assets to withdraw
            if (updateAmount > 0) {
                /// @solidity memory-safe-assembly
                assembly {
                    // Add updateAmount to assets
                    assets := add(assets, updateAmount)
                }

                // Update bandwidth with the update amount and get the negative fee
                // If any, positive fees are accumulated by the protocol
                (, uint256 _negativeFee) = updateBandwidth(
                    false, false, bandwidthStateList[i], updateAmount, _totalWeights, _totalSupply, _newTotalSupply
                );

                /// @solidity memory-safe-assembly
                assembly {
                    // Update negativeFee
                    negativeFee := add(negativeFee, _negativeFee)
                }
            }

            unchecked {
                ++i;
            }
        }

        /// @solidity memory-safe-assembly
        assembly {
            // Revert if assets underflows
            if gt(negativeFee, assets) {
                // Store the function selector of `Underflow()`.
                mstore(0x00, 0xcaccb6d9)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Subtracting assets to withdraw
            assets := sub(assets, negativeFee)
        }
    }

    /*//////////////////////////////////////////////////////////////
                            SWAP LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUlyssesPool
    function swapIn(uint256 assets, uint256 poolId) external nonReentrant returns (uint256 output) {
        // Get bandwidth state index from poolId
        uint256 index = destinations[poolId]; // Saves an extra SLOAD if poolId is valid

        /// @solidity memory-safe-assembly
        assembly {
            // Revert if poolId is invalid
            if iszero(index) {
                // Store the function selector of `NotUlyssesLP()`.
                mstore(0x00, 0x3c930918)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }

        // Transfer assets from msg.sender to this contract
        asset.safeTransferFrom(msg.sender, address(this), assets);

        /// @solidity memory-safe-assembly
        assembly {
            // Get the protocol fee from storage
            let _protocolFee := sload(protocolFee.slot)

            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if mul(_protocolFee, gt(assets, div(not(0), _protocolFee))) {
                // Store the function selector of `MulDivFailed()`.
                mstore(0x00, 0xad251c27)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Calculate the base fee, rounding up
            let baseFee :=
                add(iszero(iszero(mod(mul(assets, _protocolFee), DIVISIONER))), div(mul(assets, _protocolFee), DIVISIONER))

            // Revert if assets underflows
            if gt(baseFee, assets) {
                // Store the function selector of `Underflow()`.
                mstore(0x00, 0xcaccb6d9)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Subtract the base fee from assets
            output := sub(assets, baseFee)
        }

        emit Swap(msg.sender, poolId, assets);

        // Update bandwidths, swap assets to destination, and return output
        output = bandwidthStateList[index].destination.swapFromPool(ulyssesSwap(output), msg.sender);
    }

    /// @inheritdoc IUlyssesPool
    function swapFromPool(uint256 assets, address user) external nonReentrant returns (uint256 output) {
        // Get bandwidth state index from msg.sender
        uint256 index = destinationIds[msg.sender]; // Saves an extra SLOAD if msg.sender is valid

        /// @solidity memory-safe-assembly
        assembly {
            // Revert if msg.sender is invalid
            if iszero(index) {
                // Store the function selector of `NotUlyssesLP()`.
                mstore(0x00, 0x3c930918)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
            // Revert if the amount is zero
            if iszero(assets) {
                // Store the function selector of `AmountTooSmall()`.
                mstore(0x00, 0xc2f5625a)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }
        }

        // Update bandwidths and get the negative fee
        // Positive fee is always 0 because totalSupply does not decrease
        (, uint256 negativeFee) =
            updateBandwidth(false, false, bandwidthStateList[index], assets, totalWeights, totalSupply, 0);

        /// @solidity memory-safe-assembly
        assembly {
            // Revert if output underflows
            if gt(negativeFee, assets) {
                // Store the function selector of `Underflow()`.
                mstore(0x00, 0xcaccb6d9)
                // Revert with (offset, size).
                revert(0x1c, 0x04)
            }

            // Subtract the negative fee from assets
            output := sub(assets, negativeFee)
        }

        // Transfer output to user
        asset.safeTransfer(user, output);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL HOOKS LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Performs the necessary steps to make after depositing.
     * @param assets to be deposited
     */
    function beforeDeposit(uint256 assets) internal override returns (uint256 shares) {
        // Update deposit/mint
        shares = ulyssesAddLP(assets, true);
    }

    /**
     * @notice Performs the necessary steps to make after depositing.
     * @param assets to be deposited
     */
    function beforeMint(uint256 shares) internal override returns (uint256 assets) {
        // Update deposit/mint
        assets = ulyssesAddLP(shares, false);
    }

    /**
     * @notice Performs the necessary steps to take before withdrawing assets
     * @param shares to be burned
     */
    function afterRedeem(uint256 shares) internal override returns (uint256 assets) {
        // Update withdraw/redeem
        assets = ulyssesRemoveLP(shares);
    }
}

// src/ulysses-amm/factories/UlyssesFactory.sol

/// @title Ulysses Pool Deployer
library UlyssesPoolDeployer {
    /**
     * @notice Deploys a new Ulysses pool.
     * @param id The id of the Ulysses pool.
     * @param asset The asset of the Ulysses pool.
     * @param name The name of the Ulysses pool.
     * @param symbol The symbol of the Ulysses pool.
     * @param owner The owner of the Ulysses pool.
     * @param factory The factory of the Ulysses pool.
     */
    function deployPool(
        uint256 id,
        address asset,
        string calldata name,
        string calldata symbol,
        address owner,
        address factory
    ) public returns (UlyssesPool) {
        return new UlyssesPool(id, asset, name, symbol, owner, factory);
    }
}

/// @title Factory of new Ulysses instances
contract UlyssesFactory is Ownable, IUlyssesFactory {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;

    error ParameterLengthError();

    error InvalidPoolId();

    error InvalidAsset();

    ///@notice next poolId
    uint256 public poolId = 1;

    ///@notice next tokenId
    uint256 public tokenId = 1;

    ///@notice Mapping that holds all the Ulysses pools
    mapping(uint256 => UlyssesPool) public pools;

    ///@notice Mapping that holds all the Ulysses tokens
    mapping(uint256 => UlyssesToken) public tokens;

    constructor(address _owner) {
        require(_owner != address(0), "Owner cannot be 0");
        _initializeOwner(_owner);
    }

    function renounceOwnership() public payable override onlyOwner {
        revert("Cannot renounce ownership");
    }

    /*//////////////////////////////////////////////////////////////
                           NEW LP LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUlyssesFactory
    function createPool(ERC20 asset, address owner) external returns (uint256) {
        return _createPool(asset, owner);
    }

    /**
     * @notice Private function that holds the logic for creating a new Ulysses pool.
     * @param asset represents the asset that we want to create a Ulysses pool for.
     * @return _poolId id of the pool that was created.
     */
    function _createPool(ERC20 asset, address owner) private returns (uint256 _poolId) {
        if (address(asset) == address(0)) revert InvalidAsset();
        _poolId = ++poolId;
        pools[_poolId] =
            UlyssesPoolDeployer.deployPool(_poolId, address(asset), "Ulysses Pool", "ULP", owner, address(this));
    }

    /// @inheritdoc IUlyssesFactory
    function createPools(ERC20[] calldata assets, uint8[][] calldata weights, address owner)
        external
        returns (uint256[] memory poolIds)
    {
        uint256 length = assets.length;

        if (length != weights.length) revert ParameterLengthError();

        for (uint256 i = 0; i < length;) {
            poolIds[i] = _createPool(assets[i], address(this));

            unchecked {
                ++i;
            }
        }

        for (uint256 i = 0; i < length;) {
            if (length != weights[i].length) revert ParameterLengthError();

            for (uint256 j = 0; j < length;) {
                if (j != i && weights[i][j] > 0) pools[poolIds[i]].addNewBandwidth(poolIds[j], weights[i][j]);

                unchecked {
                    ++j;
                }
            }

            unchecked {
                ++i;
            }
        }

        for (uint256 i = 0; i < length;) {
            pools[poolIds[i]].transferOwnership(owner);

            unchecked {
                ++i;
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                           NEW TOKEN LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUlyssesFactory
    function createToken(uint256[] calldata poolIds, uint256[] calldata weights, address owner)
        external
        returns (uint256 _tokenId)
    {
        _tokenId = ++tokenId;

        uint256 length = poolIds.length;
        address[] memory destinations = new address[](length);
        for (uint256 i = 0; i < length;) {
            address destination = address(pools[poolIds[i]]);

            if (destination == address(0)) revert InvalidPoolId();

            destinations[i] = destination;

            unchecked {
                ++i;
            }
        }

        tokens[_tokenId] = new UlyssesToken(
            _tokenId,
            destinations,
            weights,
            "Ulysses Token",
            "ULT",
            owner
        );
    }
}


// src/ulysses-amm/interfaces/IUlyssesRouter.sol

/**
 * @title Ulysses Router - Handles routing of transactions in the Ulysses AMM
 *  @author Maia DAO (https://github.com/Maia-DAO)
 *  @notice This contract routes and adds/removes liquidity from Ulysses Pools
 *          deployed by the Ulysses Factory, it allows users to set maximum slippage.
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠉⢀⣶⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⠢⣝⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⢠⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⡀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠞⠁⠀⠀⢠⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢷⡄⠀⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⢀⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⡄⠀⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⠀⣸⠁⢀⡴⠃⠀⠀⣼⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢧⡀⠀⠀⢻⡄⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⢰⡏⢠⠞⠀⠀⠀⢠⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀⠀⠀⢹⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣄⠀⠀⢳⠀⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣼⣱⠋⠀⠀⠀⠀⠸⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⢰⠀⠀⠀⣿⡄⠀⠀⠀⠀⠀⠐⠦⡀⠀⠀⠀⠀⠀⠀⠀⠸⣧⠀⠸⡇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⠀⣿⠇⠀⠀⠀⠀⠀⠀⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⡇⢸⠀⠀⠀⣿⣷⣄⠀⠀⠀⠀⠀⠀⠈⢦⡀⠀⠀⠀⠀⠀⠀⠸⣧⢀⣇⠀⠀⠀
 * ⠀⠀⠀⠀⠀⠀⢸⠯⠀⠀⠀⠀⠀⠀⠀⠀⣼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣇⠈⡇⠀⠀⢻⡀⠙⠷⣄⠀⠀⠀⠀⠀⠀⠹⣦⠀⠀⠀⠀⠀⠀⣿⣿⣿⡆⠀⠀
 * ⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⢀⡄⠀⠀⠀⢠⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣽⠇⢻⡄⡇⠀⠀⢸⣷⡀⠀⠈⠳⢄⠀⠀⠀⠀⠀⠘⣆⠀⠀⠀⠀⠀⢨⣿⣿⣇⠀⠀
 * ⠀⠀⠀⠀⠀⡞⠀⠀⠀⢀⡞⠀⠀⠀⠀⣾⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⣿⠀⠘⣇⡇⠀⠀⢸⡌⠻⣷⣤⡀⠀⠉⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀⣿⣿⣿⣿⡀⠀
 * ⠀⠀⠀⠀⣼⠁⠀⠀⠀⣼⠃⠀⠀⠀⢠⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡇⣰⡟⠀⠀⢹⡇⠀⠀⣼⠇⠀⠸⣍⠉⠙⠶⢤⣀⡀⠀⠀⠀⠘⡆⠀⠀⢠⣿⣿⣿⣿⡇⠀
 * ⠀⠀⠀⢰⣣⠃⢰⠁⢀⡇⠀⠀⠀⠀⢸⣽⠀⢠⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⢠⠏⡇⠀⠀⠸⡇⠀⠀⢻⠀⠀⠀⠈⢿⡲⢄⠀⠀⠈⣄⠀⠀⠀⠸⡆⠀⢸⣿⣿⣿⣿⡇⠀
 * ⠀⠀⢠⣧⡟⠀⡼⠀⢸⠀⠀⠀⠀⠀⣿⡿⡄⢸⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⢀⣏⡟⢰⠇⠀⠀⢰⠇⠀⢰⣾⠀⠀⠀⠀⠀⢸⣟⣦⣄⠀⠈⠻⣧⣄⠀⠹⠀⢸⣿⣿⣿⣿⣿⠀
 * ⠀⠰⡫⢻⠁⢰⡇⠀⡞⠀⢠⠂⢀⠀⡿⠀⡇⠘⡆⠀⠀⠀⠀⠘⣆⠀⠀⠀⢸⡿⠀⣾⠀⠀⠀⢸⢀⠀⣼⣾⠀⠀⠀⠀⠀⠀⠻⣌⠙⠿⣦⡀⠘⢿⣦⠀⠀⢸⣿⣿⣿⣿⣿⠀
 * ⠀⠀⠀⣼⠀⣾⠃⢰⡇⠀⡞⠀⢸⠀⡇⠀⢻⡄⡇⠀⠀⠀⠀⠀⢻⠀⠀⠀⣿⠁⠀⡏⠀⠀⠀⣸⡎⢠⡏⢏⡆⠀⠀⠀⠀⠀⠀⠙⢯⡶⣄⡈⠒⠀⠹⣧⠀⢻⣿⣿⣿⣿⣿⠀
 * ⠀⠀⠀⡇⢰⣿⠀⣼⡇⢠⡇⠀⢸⡄⡇⠀⠀⢻⣻⡀⠰⡀⠀⠀⠈⣇⠀⢸⡟⠓⢺⠓⠶⠦⢤⣿⢁⣾⣀⣈⣻⡀⠀⠀⠀⠀⠀⠀⠈⢿⡑⠛⠷⣤⠀⠘⠄⠀⢻⣿⣿⣿⣿⠀
 * ⠀⠀⠀⡇⡾⢯⠀⣿⡇⢸⡇⠀⢸⣇⡧⠤⠤⠒⠻⣇⠀⢳⡀⠀⠀⠸⡆⢸⠁⠀⡞⠀⠀⠀⣸⢇⠞⠁⠀⠀⠈⠳⠄⠀⠀⠀⠀⠀⠀⢀⣽⣍⢓⣮⣷⣄⡀⠀⠀⠻⣿⣿⡇⠀
 * ⠀⠀⠀⣇⡇⢸⠀⡿⣇⢸⣧⠀⢸⢿⣳⠀⣀⣀⡀⠙⣦⠈⣷⡄⠀⠀⠹⣼⠀⣰⠃⠀⠔⢺⣏⣉⣩⣽⣂⣀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠊⣤⣾⠛⢁⣴⣮⣷⠀⠀⠀⠯⠿⡇⠀
 * ⠀⠀⠀⢹⡇⠘⣧⣧⣹⣜⢿⠀⣾⣀⢻⣷⣭⣭⣍⣑⠊⢧⡘⡟⢦⡀⠀⠹⡤⠃⠀⢀⣀⣬⡿⢿⣿⣿⣿⣿⣿⣶⣶⣤⣤⠀⠀⢰⢇⡾⠉⣠⠞⠛⡏⠹⣽⡇⠀⠀⠀⠀⣿⠀
 * ⠀⠀⠀⠀⢳⡼⠋⣻⣿⠉⠻⣇⣿⡿⣿⡟⢻⠿⣿⣿⣿⣭⡳⣿⣄⠙⢾⣦⡹⣄⠀⠀⠀⠀⠀⠀⣥⣼⠛⣿⣿⣿⣿⣹⠏⠀⢀⣿⡞⠀⣼⢛⢷⠀⡇⠀⢸⡇⠀⢰⠀⢧⢸⠀
 * ⠀⠀⠀⠀⣼⠁⣰⢃⡇⡰⠀⢹⣾⡿⡌⠳⠀⢰⣿⣟⣿⡿⡅⠀⠉⠁⠀⠈⠉⠺⠧⠀⠀⠀⠀⠀⠘⢯⣋⣉⡉⣹⠓⠃⠀⠀⢸⠞⠀⠀⣝⢁⡾⠀⠁⢀⡾⠁⠀⠘⠀⠸⣾⠀
 * ⠀⠀⠀⡸⠁⣰⠃⢸⣧⠇⠀⢸⠀⠙⢿⣆⠀⠀⠉⠳⠤⠤⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠋⠀⠀⠀⠀⢼⠀⠀⣀⣼⡿⠀⠀⣠⡞⠀⠀⠀⠀⡇⠀⢹⠀
 * ⠀⠀⣰⠇⣴⠃⠀⣼⡞⠀⠀⢸⠀⠀⠀⢻⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠀⠰⠿⠝⠋⣡⣾⠋⠀⠀⠀⠀⠀⡇⠀⢸⠀
 * ⠀⢀⡿⣴⠋⠀⠀⣿⠃⠀⠀⣿⡀⠀⠀⠀⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣴⣾⡿⠃⠀⠀⠀⠀⠀⠀⡇⠀⠀⡇
 * ⠀⢸⣴⠇⠀⠀⢰⠇⠀⠀⢰⠿⡇⠀⡀⠀⢸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⡿⠋⡇⣿⠀⠀⢀⠀⠀⠀⠀⠀⡇⠀⠀⢱
 * ⢠⣏⠏⠀⠀⢀⡞⠀⠀⢠⡞⠀⡇⢸⠀⠀⠀⢿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡿⣿⡇⣸⡹⢻⠀⠀⡸⠀⠀⠀⠀⠀⡇⠀⠀⠘
 * ⢸⢻⠀⠀⠀⡾⠀⠀⠀⣾⠃⢠⡇⣼⠀⠀⠀⠘⣷⡀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡤⠴⠶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⠋⠀⣸⣧⣏⡇⢸⠀⢀⡇⠀⠀⠀⠀⠀⡇⠀⠀⠀
 * ⡾⡸⠀⠀⣼⠁⠀⠀⣸⡟⠀⣾⣇⡟⠀⠀⠀⠀⢻⡷⣄⠀⣴⠒⠒⠒⠚⠛⠥⠤⠤⢤⣜⣯⢧⠀⠀⠀⠀⠀⠀⠀⣰⠋⠀⠀⠀⣿⠉⣽⢧⢸⠇⢸⠁⠀⠀⠀⠀⠀⡇⢀⠁⠀
 * ⠀⡇⠀⣰⠁⠀⠀⣼⠃⡇⢀⣇⣿⠁⠀⠀⠀⠀⢀⠇⢺⣿⠃⠀⠈⠑⠒⠲⠦⠤⣤⣀⠸⡈⢻⡀⠀⠀⠀⢀⣠⠞⠁⠀⠀⠀⠀⢻⡷⠃⠘⣿⣆⡏⠀⠀⠀⠀⠀⠀⡇⠘⠀⢀
 * ⠀⡇⣠⠇⠀⠀⣴⠁⢀⣇⡼⣿⠃⠀⠀⠀⠀⢀⡞⠀⣼⡏⠀⠀⠀⣀⠀⠀⠀⠀⠀⠈⢧⢷⡼⠁⠀⣀⣶⡟⠁⠀⠀⠀⠀⠀⢠⠞⠁⠀⠀⠘⣿⠃⠀⠀⠀⠀⠀⠀⡇⠀⠀⠜
 * ⠀⣧⠋⠀⠀⣼⣷⣾⣍⣁⠀⠁⠀⠀⠀⢀⡤⠏⢀⣴⣿⠁⠀⠀⠀⠀⠙⠓⠲⠤⣄⠀⢸⣼⣣⣴⣾⠿⠋⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⠀⢁⣀⣼⡤
 * ⠀⠃⠀⢀⡾⡉⠀⠀⢹⣏⠛⠶⢤⣴⣾⣯⣤⡶⢿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣇⢀⣿⣿⠟⠁⠀⠀⠀⠀⠀⣀⡴⠟⠁⠀⠀⠀⠀⢀⣾⠀⠀⠀⠀⠀⠀⠀⠀⡿⠀⠀⠀
 */
interface IUlyssesRouter {
    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice A route for a swap
     * @param from The index of the pool to swap from
     * @param to The index of the pool to swap to
     */
    struct Route {
        uint128 from;
        uint128 to;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the Ulysses Factory address
     * @return ulyssesFactory The Ulysses Factory address
     */
    function ulyssesFactory() external view returns (UlyssesFactory);

    /**
     * @notice Adds liquidity to a pool
     * @param amount The amount of tokens to add
     * @param minOutput The minimum amount of LP tokens to receive
     * @param poolId The pool to add liquidity to
     * @return lpReceived amount of LP tokens received
     */
    function addLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256);

    /**
     * @notice Removes liquidity from a pool
     * @param amount The amount of LP tokens to remove
     * @param minOutput The minimum amount of tokens to receive
     * @param poolId The pool to remove liquidity from
     * @return tokensReceived amount of tokens received
     */
    function removeLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256);

    /**
     * @notice Swaps tokens from one pool to another
     * @param amount The amount of tokens to swap
     * @param minOutput The minimum amount of tokens to receive
     * @param routes The routes to take for the swap to occur
     * @return tokensReceived amount of tokens received
     */
    function swap(uint256 amount, uint256 minOutput, Route[] calldata routes) external returns (uint256);

    /*//////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the output amount is less than the minimum output amount
    error OutputTooLow();

    /// @notice Thrown when the Ulysses pool is not recognized
    error UnrecognizedUlyssesLP();
}

// src/ulysses-amm/UlyssesRouter.sol

/// @title Ulysses Router - Handles routing of transactions in the Ulysses AMM
contract UlyssesRouter is IUlyssesRouter {
    using SafeTransferLib for address;

    /// @notice Mapping from pool id to Ulysses pool.
    mapping(uint256 => UlyssesPool) private pools;

    /// @inheritdoc IUlyssesRouter
    UlyssesFactory public ulyssesFactory;

    constructor(UlyssesFactory _ulyssesFactory) {
        ulyssesFactory = _ulyssesFactory;
    }

    /*//////////////////////////////////////////////////////////////
                        Internal LOGIC
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns the Ulysses pool for the given id.
     * @param id The id of the Ulysses pool.
     */
    function getUlyssesLP(uint256 id) private returns (UlyssesPool ulysses) {
        ulysses = pools[id];
        if (address(ulysses) == address(0)) {
            ulysses = ulyssesFactory.pools(id);

            if (address(ulysses) == address(0)) revert UnrecognizedUlyssesLP();

            pools[id] = ulysses;

            address(ulysses.asset()).safeApprove(address(ulysses), type(uint256).max);
        }
    }

    /*//////////////////////////////////////////////////////////////
                         LIQUIDITY LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUlyssesRouter
    function addLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256) {
        UlyssesPool ulysses = getUlyssesLP(poolId);

        amount = ulysses.deposit(amount, msg.sender);

        if (amount < minOutput) revert OutputTooLow();
        return amount;
    }

    /// @inheritdoc IUlyssesRouter
    function removeLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256) {
        UlyssesPool ulysses = getUlyssesLP(poolId);

        amount = ulysses.redeem(amount, msg.sender, msg.sender);

        if (amount < minOutput) revert OutputTooLow();
        return amount;
    }

    /*//////////////////////////////////////////////////////////////
                            SWAP LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IUlyssesRouter
    function swap(uint256 amount, uint256 minOutput, Route[] calldata routes) external returns (uint256) {
        address(getUlyssesLP(routes[0].from).asset()).safeTransferFrom(msg.sender, address(this), amount);

        uint256 length = routes.length;

        for (uint256 i = 0; i < length;) {
            amount = getUlyssesLP(routes[i].from).swapIn(amount, routes[i].to);

            unchecked {
                ++i;
            }
        }

        if (amount < minOutput) revert OutputTooLow();

        unchecked {
            --length;
        }

        address(getUlyssesLP(routes[length].to).asset()).safeTransfer(msg.sender, amount);

        return amount;
    }
}

