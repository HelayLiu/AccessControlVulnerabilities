// SPDX-License-Identifier: MIT
pragma solidity 0.8.20 ;

// lib/solady/src/utils/LibBit.sol

/// @notice Library for bit twiddling and boolean operations.
/// @author Solady (https://github.com/vectorized/solady/blob/main/src/utils/LibBit.sol)
/// @author Inspired by (https://graphics.stanford.edu/~seander/bithacks.html)
library LibBit {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  BIT TWIDDLING OPERATIONS                  */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Find last set.
    /// Returns the index of the most significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    function fls(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, byte(shr(r, x), hex"00000101020202020303030303030303"))
        }
    }

    /// @dev Count leading zeros.
    /// Returns the number of zeros preceding the most significant one bit.
    /// If `x` is zero, returns 256.
    function clz(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            // forgefmt: disable-next-item
            r := add(iszero(x), xor(255,
                or(r, byte(shr(r, x), hex"00000101020202020303030303030303"))))
        }
    }

    /// @dev Find first set.
    /// Returns the index of the least significant bit of `x`,
    /// counting from the least significant bit position.
    /// If `x` is zero, returns 256.
    /// Equivalent to `ctz` (count trailing zeros), which gives
    /// the number of zeros following the least significant one bit.
    function ffs(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Isolate the least significant bit.
            let b := and(x, add(not(x), 1))

            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, b)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, b))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, b))))

            // For the remaining 32 bits, use a De Bruijn lookup.
            // forgefmt: disable-next-item
            r := or(r, byte(and(div(0xd76453e0, shr(r, b)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }

    /// @dev Returns the number of set bits in `x`.
    function popCount(uint256 x) internal pure returns (uint256 c) {
        /// @solidity memory-safe-assembly
        assembly {
            let max := not(0)
            let isMax := eq(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := or(shl(8, isMax), shr(248, mul(x, div(max, 255))))
        }
    }

    /// @dev Returns whether `x` is a power of 2.
    function isPo2(uint256 x) internal pure returns (bool result) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to `x && !(x & (x - 1))`.
            result := iszero(add(and(x, sub(x, 1)), iszero(x)))
        }
    }

    /// @dev Returns `x` reversed at the bit level.
    function reverseBits(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Computing masks on-the-fly reduces bytecode size by about 500 bytes.
            let m := not(0)
            r := x
            for { let s := 128 } 1 {} {
                m := xor(m, shl(s, m))
                r := or(and(shr(s, r), m), and(shl(s, r), not(m)))
                s := shr(1, s)
                if iszero(s) { break }
            }
        }
    }

    /// @dev Returns `x` reversed at the byte level.
    function reverseBytes(uint256 x) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Computing masks on-the-fly reduces bytecode size by about 200 bytes.
            let m := not(0)
            r := x
            for { let s := 128 } 1 {} {
                m := xor(m, shl(s, m))
                r := or(and(shr(s, r), m), and(shl(s, r), not(m)))
                s := shr(1, s)
                if eq(s, 4) { break }
            }
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     BOOLEAN OPERATIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    // A Solidity bool on the stack or memory is represented as a 256-bit word.
    // Non-zero values are true, zero is false.
    // A clean bool is either 0 (false) or 1 (true) under the hood.
    // Usually, if not always, the bool result of a regular Solidity expression,
    // or the argument of a public/external function will be a clean bool.
    // You can usually use the raw variants for more performance.
    // If uncertain, test (best with exact compiler settings).
    // Or use the non-raw variants (compiler can sometimes optimize out the double `iszero`s).

    /// @dev Returns `x & y`. Inputs must be clean.
    function rawAnd(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(x, y)
        }
    }

    /// @dev Returns `x & y`.
    function and(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := and(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns `x | y`. Inputs must be clean.
    function rawOr(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(x, y)
        }
    }

    /// @dev Returns `x | y`.
    function or(bool x, bool y) internal pure returns (bool z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := or(iszero(iszero(x)), iszero(iszero(y)))
        }
    }

    /// @dev Returns 1 if `b` is true, else 0. Input must be clean.
    function rawToUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := b
        }
    }

    /// @dev Returns 1 if `b` is true, else 0.
    function toUint(bool b) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            z := iszero(iszero(b))
        }
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
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
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
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
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
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        /// @solidity memory-safe-assembly
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
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
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
            }
        }
    }

    /// @dev Force sends all the ETH in the current contract to `to`, with `GAS_STIPEND_NO_GRIEF`.
    function forceSafeTransferAllETH(address to) internal {
        /// @solidity memory-safe-assembly
        assembly {
            // forgefmt: disable-next-item
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) // Store the address in scratch space.
                mstore8(0x0b, 0x73) // Opcode `PUSH20`.
                mstore8(0x20, 0xff) // Opcode `SELFDESTRUCT`.
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } // For gas estimation.
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
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }

    /// @dev Sends all the ETH in the current contract to `to`, with a `gasStipend`.
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        /// @solidity memory-safe-assembly
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
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

// src/ReentrancyGuard.sol

/**
 * @title ReentrancyGuard
 * @author 0age
 *         https://github.com/ProjectOpenSea/seaport/blob/main/contracts/lib/ReentrancyGuard.sol
 * Changes: add modifier, bring constants & error definition into contract
 * @notice ReentrancyGuard contains a storage variable and related functionality
 *         for protecting against reentrancy.
 */
contract ReentrancyGuard {
  /**
   * @dev Revert with an error when a caller attempts to reenter a protected
   *      function.
   */
  error NoReentrantCalls();

  // Prevent reentrant calls on protected functions.
  uint256 private _reentrancyGuard;

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  /**
   * @dev Reentrancy guard for state-changing functions.
   *      Reverts if the reentrancy guard is currently set; otherwise, sets
   *      the reentrancy guard, executes the function body, then clears the
   *      reentrancy guard.
   */
  modifier nonReentrant() {
    _setReentrancyGuard();
    _;
    _clearReentrancyGuard();
  }

  /**
   * @dev Reentrancy guard for view functions.
   *      Reverts if the reentrancy guard is currently set.
   */
  modifier nonReentrantView() {
    _assertNonReentrant();
    _;
  }

  /**
   * @dev Initialize the reentrancy guard during deployment.
   */
  constructor() {
    // Initialize the reentrancy guard in a cleared state.
    _reentrancyGuard = _NOT_ENTERED;
  }

  /**
   * @dev Internal function to ensure that a sentinel value for the reentrancy
   *      guard is not currently set and, if not, to set a sentinel value for
   *      the reentrancy guard.
   */
  function _setReentrancyGuard() internal {
    // Ensure that the reentrancy guard is not already set.
    _assertNonReentrant();

    // Set the reentrancy guard.
    unchecked {
      _reentrancyGuard = _ENTERED;
    }
  }

  /**
   * @dev Internal function to unset the reentrancy guard sentinel value.
   */
  function _clearReentrancyGuard() internal {
    // Clear the reentrancy guard.
    _reentrancyGuard = _NOT_ENTERED;
  }

  /**
   * @dev Internal view function to ensure that a sentinel value for the
   *         reentrancy guard is not currently set.
   */
  function _assertNonReentrant() internal view {
    // Ensure that the reentrancy guard is not currently set.
    if (_reentrancyGuard != _NOT_ENTERED) {
      revert NoReentrantCalls();
    }
  }
}

// src/interfaces/IERC20.sol

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

// src/interfaces/IWildcatMarketControllerEventsAndErrors.sol

interface IWildcatMarketControllerEventsAndErrors {
  /* -------------------------------------------------------------------------- */
  /*                                   Errors                                   */
  /* -------------------------------------------------------------------------- */

  error DelinquencyGracePeriodOutOfBounds();
  error ReserveRatioBipsOutOfBounds();
  error DelinquencyFeeBipsOutOfBounds();
  error WithdrawalBatchDurationOutOfBounds();
  error AnnualInterestBipsOutOfBounds();

  // Error thrown when a borrower-only method is called by another account.
  error CallerNotBorrower();

  // Error thrown when `deployMarket` called by an account other than `borrower` or
  // `controllerFactory`.
  error CallerNotBorrowerOrControllerFactory();

  // Error thrown if borrower calls `deployMarket` and is no longer
  // registered with the arch-controller.
  error NotRegisteredBorrower();

  error EmptyString();

  error NotControlledMarket();

  error MarketAlreadyDeployed();

  error ExcessReserveRatioStillActive();
  error AprChangeNotPending();

  /* -------------------------------------------------------------------------- */
  /*                                   Events                                   */
  /* -------------------------------------------------------------------------- */

  event LenderAuthorized(address);

  event LenderDeauthorized(address);

  event MarketDeployed(address indexed market);
}

// src/interfaces/IWildcatSanctionsSentinel.sol

interface IWildcatSanctionsSentinel {
  event NewSanctionsEscrow(
    address indexed borrower,
    address indexed account,
    address indexed asset
  );

  event SanctionOverride(address indexed borrower, address indexed account);

  event SanctionOverrideRemoved(address indexed borrower, address indexed account);

  error NotRegisteredMarket();

  struct TmpEscrowParams {
    address borrower;
    address account;
    address asset;
  }

  function WildcatSanctionsEscrowInitcodeHash() external pure returns (bytes32);

  // Returns immutable sanctions list contract
  function chainalysisSanctionsList() external view returns (address);

  // Returns immutable arch-controller
  function archController() external view returns (address);

  // Returns temporary escrow params
  function tmpEscrowParams()
    external
    view
    returns (address borrower, address account, address asset);

  // Returns result of `chainalysisSanctionsList().isSanctioned(account)`
  // if borrower has not overridden the status of `account`
  function isSanctioned(address borrower, address account) external view returns (bool);

  // Returns boolean indicating whether `borrower` has overridden the
  // sanction status of `account`
  function sanctionOverrides(address borrower, address account) external view returns (bool);

  function overrideSanction(address account) external;

  function removeSanctionOverride(address account) external;

  // Returns create2 address of sanctions escrow contract for
  // combination of `account,borrower,asset`
  function getEscrowAddress(
    address account,
    address borrower,
    address asset
  ) external view returns (address escrowContract);

  /**
   * @dev Returns a create2 deployment of WildcatSanctionsEscrow unique to each
   *      combination of `account,borrower,asset`. If the contract is already
   *      deployed, returns the existing address.
   *
   *      Emits `NewSanctionsEscrow(borrower, account, asset)` if a new contract
   *      is deployed.
   *
   *      If `archController.isRegisteredMarket(msg.sender)` returns false,
   *      reverts with `NotRegisteredMarket`.
   *
   *      The sanctions escrow contract is used to hold assets until either the
   *      sanctioned status is lifted or the assets are released by the borrower.
   */
  function createEscrow(
    address account,
    address borrower,
    address asset
  ) external returns (address escrowContract);
}

// src/libraries/BoolUtils.sol

library BoolUtils {
  function and(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := and(a, b)
    }
  }

  function or(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := or(a, b)
    }
  }

  function xor(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := xor(a, b)
    }
  }
}

// src/libraries/Errors.sol

uint256 constant Panic_CompilerPanic = 0x00;
uint256 constant Panic_AssertFalse = 0x01;
uint256 constant Panic_Arithmetic = 0x11;
uint256 constant Panic_DivideByZero = 0x12;
uint256 constant Panic_InvalidEnumValue = 0x21;
uint256 constant Panic_InvalidStorageByteArray = 0x22;
uint256 constant Panic_EmptyArrayPop = 0x31;
uint256 constant Panic_ArrayOutOfBounds = 0x32;
uint256 constant Panic_MemoryTooLarge = 0x41;
uint256 constant Panic_UninitializedFunctionPointer = 0x51;

uint256 constant Panic_ErrorSelector = 0x4e487b71;
uint256 constant Panic_ErrorCodePointer = 0x20;
uint256 constant Panic_ErrorLength = 0x24;
uint256 constant Error_SelectorPointer = 0x1c;

/**
 * @dev Reverts with the given error selector.
 * @param errorSelector The left-aligned error selector.
 */
function revertWithSelector_0(bytes4 errorSelector) pure {
  assembly {
    mstore(0, errorSelector)
    revert(0, 4)
  }
}

/**
 * @dev Reverts with the given error selector.
 * @param errorSelector The left-padded error selector.
 */
function revertWithSelector_1(uint256 errorSelector) pure {
  assembly {
    mstore(0, errorSelector)
    revert(Error_SelectorPointer, 4)
  }
}

/**
 * @dev Reverts with the given error selector and argument.
 * @param errorSelector The left-aligned error selector.
 * @param argument The argument to the error.
 */
function revertWithSelectorAndArgument_0(bytes4 errorSelector, uint256 argument) pure {
  assembly {
    mstore(0, errorSelector)
    mstore(4, argument)
    revert(0, 0x24)
  }
}

/**
 * @dev Reverts with the given error selector and argument.
 * @param errorSelector The left-padded error selector.
 * @param argument The argument to the error.
 */
function revertWithSelectorAndArgument_1(uint256 errorSelector, uint256 argument) pure {
  assembly {
    mstore(0, errorSelector)
    mstore(0x20, argument)
    revert(Error_SelectorPointer, 0x24)
  }
}

// src/libraries/FIFOQueue.sol

struct FIFOQueue {
  uint128 startIndex;
  uint128 nextIndex;
  mapping(uint256 => uint32) data;
}

// @todo - make array tightly packed for gas efficiency with multiple reads/writes
//         also make a memory version of the array with (nextIndex, startIndex, storageSlot)
//         so that multiple storage reads aren't required for tx's using multiple functions

using FIFOQueueLib for FIFOQueue global;

library FIFOQueueLib {
  error FIFOQueueOutOfBounds();

  function empty(FIFOQueue storage arr) internal view returns (bool) {
    return arr.nextIndex == arr.startIndex;
  }

  function first(FIFOQueue storage arr) internal view returns (uint32) {
    if (arr.startIndex == arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    return arr.data[arr.startIndex];
  }

  function at(FIFOQueue storage arr, uint256 index) internal view returns (uint32) {
    index += arr.startIndex;
    if (index >= arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    return arr.data[index];
  }

  function length(FIFOQueue storage arr) internal view returns (uint128) {
    return arr.nextIndex - arr.startIndex;
  }

  function values(FIFOQueue storage arr) internal view returns (uint32[] memory _values) {
    uint256 startIndex = arr.startIndex;
    uint256 nextIndex = arr.nextIndex;
    uint256 len = nextIndex - startIndex;
    _values = new uint32[](len);

    for (uint256 i = 0; i < len; i++) {
      _values[i] = arr.data[startIndex + i];
    }

    return _values;
  }

  function push(FIFOQueue storage arr, uint32 value) internal {
    uint128 nextIndex = arr.nextIndex;
    arr.data[nextIndex] = value;
    arr.nextIndex = nextIndex + 1;
  }

  function shift(FIFOQueue storage arr) internal {
    uint128 startIndex = arr.startIndex;
    if (startIndex == arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    delete arr.data[startIndex];
    arr.startIndex = startIndex + 1;
  }

  function shiftN(FIFOQueue storage arr, uint128 n) internal {
    uint128 startIndex = arr.startIndex;
    if (startIndex + n > arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    for (uint256 i = 0; i < n; i++) {
      delete arr.data[startIndex + i];
    }
    arr.startIndex = startIndex + n;
  }
}

// src/interfaces/IERC20Metadata.sol

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);
}

// src/libraries/MathUtils.sol

uint256 constant BIP = 1e4;
uint256 constant HALF_BIP = 0.5e4;

uint256 constant RAY = 1e27;
uint256 constant HALF_RAY = 0.5e27;

uint256 constant BIP_RAY_RATIO = 1e23;

uint256 constant SECONDS_IN_365_DAYS = 365 days;

library MathUtils {
  /// @dev The multiply-divide operation failed, either due to a
  /// multiplication overflow, or a division by a zero.
  error MulDivFailed();

  using MathUtils for uint256;

  /**
   * @dev Function to calculate the interest accumulated using a linear interest rate formula
   *
   * @param rateBip The interest rate, in bips
   * @param timeDelta The time elapsed since the last interest accrual
   * @return result The interest rate linearly accumulated during the timeDelta, in ray
   */
  function calculateLinearInterestFromBips(
    uint256 rateBip,
    uint256 timeDelta
  ) internal pure returns (uint256 result) {
    uint256 rate = rateBip.bipToRay();
    uint256 accumulatedInterestRay = rate * timeDelta;
    unchecked {
      return accumulatedInterestRay / SECONDS_IN_365_DAYS;
    }
  }

  /**
   * @dev Return the smaller of `a` and `b`
   */
  function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = ternary(a < b, a, b);
  }

  /**
   * @dev Return the larger of `a` and `b`.
   */
  function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = ternary(a < b, b, a);
  }

  /**
   * @dev Saturation subtraction. Subtract `b` from `a` and return the result
   *      if it is positive or zero if it underflows.
   */
  function satSub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // (a > b) * (a - b)
      // If a-b underflows, the product will be zero
      c := mul(gt(a, b), sub(a, b))
    }
  }

  /**
   * @dev Return `valueIfTrue` if `condition` is true and `valueIfFalse` if it is false.
   *      Equivalent to `condition ? valueIfTrue : valueIfFalse`
   */
  function ternary(
    bool condition,
    uint256 valueIfTrue,
    uint256 valueIfFalse
  ) internal pure returns (uint256 c) {
    assembly {
      c := add(valueIfFalse, mul(condition, sub(valueIfTrue, valueIfFalse)))
    }
  }

  /**
   * @dev Multiplies two bip, rounding half up to the nearest bip
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function bipMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b == 0 || a <= (type(uint256).max - HALF_BIP) / b)`
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_BIP), b))))) {
        // Store the Panic error signature.
        mstore(0, Panic_ErrorSelector)
        // Store the arithmetic (0x11) panic code.
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        // revert(abi.encodeWithSignature("Panic(uint256)", 0x11))
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, b), HALF_BIP), BIP)
    }
  }

  /**
   * @dev Divides two bip, rounding half up to the nearest bip
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function bipDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b != 0 && a <= (type(uint256).max - b/2) / BIP)`
      if or(iszero(b), gt(a, div(sub(not(0), div(b, 2)), BIP))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, BIP), div(b, 2)), b)
    }
  }

  /**
   * @dev Converts bip up to ray
   */
  function bipToRay(uint256 a) internal pure returns (uint256 b) {
    // to avoid overflow, b/BIP_RAY_RATIO == a
    assembly {
      b := mul(a, BIP_RAY_RATIO)
      // equivalent to `require((b = a * BIP_RAY_RATIO) / BIP_RAY_RATIO == a )
      if iszero(eq(div(b, BIP_RAY_RATIO), a)) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
    }
  }

  /**
   * @dev Multiplies two ray, rounding half up to the nearest ray
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b == 0 || a <= (type(uint256).max - HALF_RAY) / b)`
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, b), HALF_RAY), RAY)
    }
  }

  /**
   * @dev Divide two ray, rounding half up to the nearest ray
   *      see https://twitter.com/transmissions11/status/1451131036377571328
   */
  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      // equivalent to `require(b != 0 && a <= (type(uint256).max - halfB) / RAY)`
      if or(iszero(b), gt(a, div(sub(not(0), div(b, 2)), RAY))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }

      c := div(add(mul(a, RAY), div(b, 2)), b)
    }
  }

  /**
   * @dev Returns `floor(x * y / d)`.
   *      Reverts if `x * y` overflows, or `d` is zero.
   * @custom:author solady/src/utils/FixedPointMathLib.sol
   */
  function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
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

  /**
   * @dev Returns `ceil(x * y / d)`.
   *      Reverts if `x * y` overflows, or `d` is zero.
   * @custom:author solady/src/utils/FixedPointMathLib.sol
   */
  function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
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
}

// src/libraries/SafeCastLib.sol

library SafeCastLib {
  function _assertNonOverflow(bool didNotOverflow) private pure {
    assembly {
      if iszero(didNotOverflow) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
    }
  }

  function toUint8(uint256 x) internal pure returns (uint8 y) {
    _assertNonOverflow(x == (y = uint8(x)));
  }

  function toUint16(uint256 x) internal pure returns (uint16 y) {
    _assertNonOverflow(x == (y = uint16(x)));
  }

  function toUint24(uint256 x) internal pure returns (uint24 y) {
    _assertNonOverflow(x == (y = uint24(x)));
  }

  function toUint32(uint256 x) internal pure returns (uint32 y) {
    _assertNonOverflow(x == (y = uint32(x)));
  }

  function toUint40(uint256 x) internal pure returns (uint40 y) {
    _assertNonOverflow(x == (y = uint40(x)));
  }

  function toUint48(uint256 x) internal pure returns (uint48 y) {
    _assertNonOverflow(x == (y = uint48(x)));
  }

  function toUint56(uint256 x) internal pure returns (uint56 y) {
    _assertNonOverflow(x == (y = uint56(x)));
  }

  function toUint64(uint256 x) internal pure returns (uint64 y) {
    _assertNonOverflow(x == (y = uint64(x)));
  }

  function toUint72(uint256 x) internal pure returns (uint72 y) {
    _assertNonOverflow(x == (y = uint72(x)));
  }

  function toUint80(uint256 x) internal pure returns (uint80 y) {
    _assertNonOverflow(x == (y = uint80(x)));
  }

  function toUint88(uint256 x) internal pure returns (uint88 y) {
    _assertNonOverflow(x == (y = uint88(x)));
  }

  function toUint96(uint256 x) internal pure returns (uint96 y) {
    _assertNonOverflow(x == (y = uint96(x)));
  }

  function toUint104(uint256 x) internal pure returns (uint104 y) {
    _assertNonOverflow(x == (y = uint104(x)));
  }

  function toUint112(uint256 x) internal pure returns (uint112 y) {
    _assertNonOverflow(x == (y = uint112(x)));
  }

  function toUint120(uint256 x) internal pure returns (uint120 y) {
    _assertNonOverflow(x == (y = uint120(x)));
  }

  function toUint128(uint256 x) internal pure returns (uint128 y) {
    _assertNonOverflow(x == (y = uint128(x)));
  }

  function toUint136(uint256 x) internal pure returns (uint136 y) {
    _assertNonOverflow(x == (y = uint136(x)));
  }

  function toUint144(uint256 x) internal pure returns (uint144 y) {
    _assertNonOverflow(x == (y = uint144(x)));
  }

  function toUint152(uint256 x) internal pure returns (uint152 y) {
    _assertNonOverflow(x == (y = uint152(x)));
  }

  function toUint160(uint256 x) internal pure returns (uint160 y) {
    _assertNonOverflow(x == (y = uint160(x)));
  }

  function toUint168(uint256 x) internal pure returns (uint168 y) {
    _assertNonOverflow(x == (y = uint168(x)));
  }

  function toUint176(uint256 x) internal pure returns (uint176 y) {
    _assertNonOverflow(x == (y = uint176(x)));
  }

  function toUint184(uint256 x) internal pure returns (uint184 y) {
    _assertNonOverflow(x == (y = uint184(x)));
  }

  function toUint192(uint256 x) internal pure returns (uint192 y) {
    _assertNonOverflow(x == (y = uint192(x)));
  }

  function toUint200(uint256 x) internal pure returns (uint200 y) {
    _assertNonOverflow(x == (y = uint200(x)));
  }

  function toUint208(uint256 x) internal pure returns (uint208 y) {
    _assertNonOverflow(x == (y = uint208(x)));
  }

  function toUint216(uint256 x) internal pure returns (uint216 y) {
    _assertNonOverflow(x == (y = uint216(x)));
  }

  function toUint224(uint256 x) internal pure returns (uint224 y) {
    _assertNonOverflow(x == (y = uint224(x)));
  }

  function toUint232(uint256 x) internal pure returns (uint232 y) {
    _assertNonOverflow(x == (y = uint232(x)));
  }

  function toUint240(uint256 x) internal pure returns (uint240 y) {
    _assertNonOverflow(x == (y = uint240(x)));
  }

  function toUint248(uint256 x) internal pure returns (uint248 y) {
    _assertNonOverflow(x == (y = uint248(x)));
  }
}

// src/libraries/StringQuery.sol

using LibBit for uint256;

uint256 constant InvalidReturnDataString_selector = (
  0x4cb9c00000000000000000000000000000000000000000000000000000000000
);

uint256 constant SixtyThreeBytes = 0x3f;
uint256 constant ThirtyOneBytes = 0x1f;
uint256 constant OnlyFullWordMask = 0xffffffe0;

error InvalidReturnDataString();
error InvalidCompactString();

function bytes32ToString(bytes32 value) pure returns (string memory str) {
  uint256 size;
  unchecked {
    uint256 sizeInBits = 255 - uint256(value).ffs();
    size = (sizeInBits + 7) / 8;
  }
  assembly {
    str := mload(0x40)
    mstore(0x40, add(str, 0x40))
    mstore(str, size)
    mstore(add(str, 0x20), value)
  }
}

function queryStringOrBytes32AsString(
  address target,
  uint256 rightPaddedFunctionSelector,
  uint256 rightPaddedGenericErrorSelector
) view returns (string memory str) {
  bool isBytes32;
  assembly {
    mstore(0, rightPaddedFunctionSelector)
    let status := staticcall(gas(), target, 0, 0x04, 0, 0)
    isBytes32 := eq(returndatasize(), 0x20)
    // If call fails or function returns invalid data, revert.
    // Strings are always right padded to full words - if the returndata
    // is not 32 bytes (string encoded as bytes32) or 96 bytes (abi encoded
    // string) it is either an invalid string or too large.
    if or(iszero(status), iszero(or(isBytes32, eq(returndatasize(), 0x60)))) {
      // Check if call failed
      if iszero(status) {
        // Check if any revert data was given
        if returndatasize() {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
        // If not, throw a generic error
        mstore(0, rightPaddedGenericErrorSelector)
        revert(0, 0x04)
      }
      // If the returndata is the wrong size, throw InvalidReturnDataString
      mstore(0, InvalidReturnDataString_selector)
      revert(0, 0x04)
    }
  }
  if (isBytes32) {
    uint256 value;
    assembly {
      returndatacopy(0x00, 0x00, 0x20)
      value := mload(0)
    }
    uint256 size;
    unchecked {
      uint256 sizeInBits = 255 - value.ffs();
      size = (sizeInBits + 7) / 8;
    }
    assembly {
      str := mload(0x40)
      mstore(0x40, add(str, 0x40))
      mstore(str, size)
      mstore(add(str, 0x20), value)
    }
  } else {
    // If returndata is a string, copy the length and value
    assembly {
      str := mload(0x40)
      // Get allocation size for the string including the length and data.
      // Rounding down returndatasize to nearest word because the returndata
      // has an extra offset word.
      let allocSize := and(sub(returndatasize(), 1), OnlyFullWordMask)
      mstore(0x40, add(str, allocSize))
      // Copy returndata after the offset
      returndatacopy(str, 0x20, sub(returndatasize(), 0x20))
    }
  }
}

function queryName(address target) view returns (string memory) {
  return
    queryStringOrBytes32AsString(target, NameFunction_selector, UnknownNameQueryError_selector);
}

function querySymbol(address target) view returns (string memory) {
  return
    queryStringOrBytes32AsString(target, SymbolFunction_selector, UnknownSymbolQueryError_selector);
}

uint256 constant UnknownNameQueryError_selector = (
  0xed3df7ad00000000000000000000000000000000000000000000000000000000
);
uint256 constant UnknownSymbolQueryError_selector = (
  0x89ff815700000000000000000000000000000000000000000000000000000000
);
uint256 constant NameFunction_selector = (
  0x06fdde0300000000000000000000000000000000000000000000000000000000
);
uint256 constant SymbolFunction_selector = (
  0x95d89b4100000000000000000000000000000000000000000000000000000000
);

// src/interfaces/WildcatStructsAndEnums.sol

enum AuthRole {
  Null,
  Blocked,
  WithdrawOnly,
  DepositAndWithdraw
}

struct MarketParameters {
  address asset;
  string namePrefix;
  string symbolPrefix;
  address borrower;
  address controller;
  address feeRecipient;
  address sentinel;
  uint128 maxTotalSupply;
  uint16 protocolFeeBips;
  uint16 annualInterestBips;
  uint16 delinquencyFeeBips;
  uint32 withdrawalBatchDuration;
  uint16 reserveRatioBips;
  uint32 delinquencyGracePeriod;
}

struct MarketControllerParameters {
  address archController;
  address borrower;
  address sentinel;
  address marketInitCodeStorage;
  uint256 marketInitCodeHash;
  uint32 minimumDelinquencyGracePeriod;
  uint32 maximumDelinquencyGracePeriod;
  uint16 minimumReserveRatioBips;
  uint16 maximumReserveRatioBips;
  uint16 minimumDelinquencyFeeBips;
  uint16 maximumDelinquencyFeeBips;
  uint32 minimumWithdrawalBatchDuration;
  uint32 maximumWithdrawalBatchDuration;
  uint16 minimumAnnualInterestBips;
  uint16 maximumAnnualInterestBips;
}

struct ProtocolFeeConfiguration {
  address feeRecipient;
  address originationFeeAsset;
  uint80 originationFeeAmount;
  uint16 protocolFeeBips;
}

struct MarketParameterConstraints {
  uint32 minimumDelinquencyGracePeriod;
  uint32 maximumDelinquencyGracePeriod;
  uint16 minimumReserveRatioBips;
  uint16 maximumReserveRatioBips;
  uint16 minimumDelinquencyFeeBips;
  uint16 maximumDelinquencyFeeBips;
  uint32 minimumWithdrawalBatchDuration;
  uint32 maximumWithdrawalBatchDuration;
  uint16 minimumAnnualInterestBips;
  uint16 maximumAnnualInterestBips;
}

// src/libraries/FeeMath.sol

using SafeCastLib for uint256;
using MathUtils for uint256;

library FeeMath {
  /**
   * @dev Function to calculate the interest accumulated using a linear interest rate formula
   *
   * @param rateBip The interest rate, in bips
   * @param timeDelta The time elapsed since the last interest accrual
   * @return result The interest rate linearly accumulated during the timeDelta, in ray
   */
  function calculateLinearInterestFromBips(
    uint256 rateBip,
    uint256 timeDelta
  ) internal pure returns (uint256 result) {
    uint256 rate = rateBip.bipToRay();
    uint256 accumulatedInterestRay = rate * timeDelta;
    unchecked {
      return accumulatedInterestRay / SECONDS_IN_365_DAYS;
    }
  }

  function calculateBaseInterest(
    MarketState memory state,
    uint256 timestamp
  ) internal pure returns (uint256 baseInterestRay) {
    baseInterestRay = MathUtils.calculateLinearInterestFromBips(
      state.annualInterestBips,
      timestamp - state.lastInterestAccruedTimestamp
    );
  }

  function applyProtocolFee(
    MarketState memory state,
    uint256 baseInterestRay,
    uint256 protocolFeeBips
  ) internal pure returns (uint256 protocolFee) {
    // Protocol fee is charged in addition to the interest paid to lenders.
    uint256 protocolFeeRay = protocolFeeBips.bipMul(baseInterestRay);
    protocolFee = uint256(state.scaledTotalSupply).rayMul(
      uint256(state.scaleFactor).rayMul(protocolFeeRay)
    );
    state.accruedProtocolFees = (state.accruedProtocolFees + protocolFee).toUint128();
  }

  function updateDelinquency(
    MarketState memory state,
    uint256 timestamp,
    uint256 delinquencyFeeBips,
    uint256 delinquencyGracePeriod
  ) internal pure returns (uint256 delinquencyFeeRay) {
    // Calculate the number of seconds the borrower spent in penalized
    // delinquency since the last update.
    uint256 timeWithPenalty = updateTimeDelinquentAndGetPenaltyTime(
      state,
      delinquencyGracePeriod,
      timestamp - state.lastInterestAccruedTimestamp
    );

    if (timeWithPenalty > 0) {
      // Calculate penalty fees on the interest accrued.
      delinquencyFeeRay = calculateLinearInterestFromBips(delinquencyFeeBips, timeWithPenalty);
    }
  }

  /**
   * @notice  Calculate the number of seconds that the market has been in
   *          penalized delinquency since the last update, and update
   *          `timeDelinquent` in state.
   *
   * @dev When `isDelinquent`, equivalent to:
   *        max(0, timeDelta - max(0, delinquencyGracePeriod - previousTimeDelinquent))
   *      When `!isDelinquent`, equivalent to:
   *        min(timeDelta, max(0, previousTimeDelinquent - delinquencyGracePeriod))
   *
   * @param state Encoded state parameters
   * @param delinquencyGracePeriod Seconds in delinquency before penalties apply
   * @param timeDelta Seconds since the last update
   * @param `timeWithPenalty` Number of seconds since the last update where
   *        the market was in delinquency outside of the grace period.
   */
  function updateTimeDelinquentAndGetPenaltyTime(
    MarketState memory state,
    uint256 delinquencyGracePeriod,
    uint256 timeDelta
  ) internal pure returns (uint256 /* timeWithPenalty */) {
    // Seconds in delinquency at last update
    uint256 previousTimeDelinquent = state.timeDelinquent;

    if (state.isDelinquent) {
      // Since the borrower is still delinquent, increase the total
      // time in delinquency by the time elapsed.
      state.timeDelinquent = (previousTimeDelinquent + timeDelta).toUint32();

      // Calculate the number of seconds the borrower had remaining
      // in the grace period.
      uint256 secondsRemainingWithoutPenalty = delinquencyGracePeriod.satSub(
        previousTimeDelinquent
      );

      // Penalties apply for the number of seconds the market spent in
      // delinquency outside of the grace period since the last update.
      return timeDelta.satSub(secondsRemainingWithoutPenalty);
    }

    // Reduce the total time in delinquency by the time elapsed, stopping
    // when it reaches zero.
    state.timeDelinquent = previousTimeDelinquent.satSub(timeDelta).toUint32();

    // Calculate the number of seconds the old timeDelinquent had remaining
    // outside the grace period, or zero if it was already in the grace period.
    uint256 secondsRemainingWithPenalty = previousTimeDelinquent.satSub(delinquencyGracePeriod);

    // Only apply penalties for the remaining time outside of the grace period.
    return MathUtils.min(secondsRemainingWithPenalty, timeDelta);
  }

  /**
   * @dev Calculates interest and delinquency/protocol fees accrued since last state update
   *      and applies it to cached state, returning the rates for base interest and delinquency
   *      fees and the normalized amount of protocol fees accrued.
   *
   *      Takes `timestamp` as input to allow separate calculation of interest
   *      before and after withdrawal batch expiry.
   *
   * @param state Market scale parameters
   * @param protocolFeeBips Protocol fee rate (in bips)
   * @param delinquencyFeeBips Delinquency fee rate (in bips)
   * @param delinquencyGracePeriod Grace period (in seconds) before delinquency fees apply
   * @param timestamp Time to calculate interest and fees accrued until
   * @return baseInterestRay Interest accrued to lenders (ray)
   * @return delinquencyFeeRay Penalty fee incurred by borrower for delinquency (ray).
   * @return protocolFee Protocol fee charged on interest (normalized token amount).
   */
  function updateScaleFactorAndFees(
    MarketState memory state,
    uint256 protocolFeeBips,
    uint256 delinquencyFeeBips,
    uint256 delinquencyGracePeriod,
    uint256 timestamp
  )
    internal
    pure
    returns (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee)
  {
    baseInterestRay = state.calculateBaseInterest(timestamp);

    if (protocolFeeBips > 0) {
      protocolFee = state.applyProtocolFee(baseInterestRay, protocolFeeBips);
    }

    if (delinquencyFeeBips > 0) {
      delinquencyFeeRay = state.updateDelinquency(
        timestamp,
        delinquencyFeeBips,
        delinquencyGracePeriod
      );
    }

    // Calculate new scaleFactor
    uint256 prevScaleFactor = state.scaleFactor;
    uint256 scaleFactorDelta = prevScaleFactor.rayMul(baseInterestRay + delinquencyFeeRay);

    state.scaleFactor = (prevScaleFactor + scaleFactorDelta).toUint112();
    state.lastInterestAccruedTimestamp = uint32(timestamp);
  }
}

// src/libraries/MarketState.sol

using MarketStateLib for MarketState global;
using MarketStateLib for Account global;
using FeeMath for MarketState global;

struct MarketState {
  bool isClosed;
  uint128 maxTotalSupply;
  uint128 accruedProtocolFees;
  // Underlying assets reserved for withdrawals which have been paid
  // by the borrower but not yet executed.
  uint128 normalizedUnclaimedWithdrawals;
  // Scaled token supply (divided by scaleFactor)
  uint104 scaledTotalSupply;
  // Scaled token amount in withdrawal batches that have not been
  // paid by borrower yet.
  uint104 scaledPendingWithdrawals;
  uint32 pendingWithdrawalExpiry;
  // Whether market is currently delinquent (liquidity under requirement)
  bool isDelinquent;
  // Seconds borrower has been delinquent
  uint32 timeDelinquent;
  // Annual interest rate accrued to lenders, in basis points
  uint16 annualInterestBips;
  // Percentage of outstanding balance that must be held in liquid reserves
  uint16 reserveRatioBips;
  // Ratio between internal balances and underlying token amounts
  uint112 scaleFactor;
  uint32 lastInterestAccruedTimestamp;
}

struct Account {
  AuthRole approval;
  uint104 scaledBalance;
}

library MarketStateLib {
  using MathUtils for uint256;
  using SafeCastLib for uint256;

  /**
   * @dev Returns the normalized total supply of the market.
   */
  function totalSupply(MarketState memory state) internal pure returns (uint256) {
    return state.normalizeAmount(state.scaledTotalSupply);
  }

  /**
   * @dev Returns the maximum amount of tokens that can be deposited without
   *      reaching the maximum total supply.
   */
  function maximumDeposit(MarketState memory state) internal pure returns (uint256) {
    return uint256(state.maxTotalSupply).satSub(state.totalSupply());
  }

  /**
   * @dev Normalize an amount of scaled tokens using the current scale factor.
   */
  function normalizeAmount(
    MarketState memory state,
    uint256 amount
  ) internal pure returns (uint256) {
    return amount.rayMul(state.scaleFactor);
  }

  /**
   * @dev Scale an amount of normalized tokens using the current scale factor.
   */
  function scaleAmount(MarketState memory state, uint256 amount) internal pure returns (uint256) {
    return amount.rayDiv(state.scaleFactor);
  }

  /**
   * @dev Collateralization requirement is:
   *      - 100% of all pending (unpaid) withdrawals
   *      - 100% of all unclaimed (paid) withdrawals
   *      - reserve ratio times the outstanding debt (supply - pending withdrawals)
   *      - accrued protocol fees
   */
  function liquidityRequired(
    MarketState memory state
  ) internal pure returns (uint256 _liquidityRequired) {
    uint256 scaledWithdrawals = state.scaledPendingWithdrawals;
    uint256 scaledRequiredReserves = (state.scaledTotalSupply - scaledWithdrawals).bipMul(
      state.reserveRatioBips
    ) + scaledWithdrawals;
    return
      state.normalizeAmount(scaledRequiredReserves) +
      state.accruedProtocolFees +
      state.normalizedUnclaimedWithdrawals;
  }

  /**
   * @dev Returns the amount of underlying assets that can be withdrawn
   *      for protocol fees. The only debts with higher priority are
   *      processed withdrawals that have not been executed.
   */
  function withdrawableProtocolFees(
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint128) {
    uint256 totalAvailableAssets = totalAssets - state.normalizedUnclaimedWithdrawals;
    return uint128(MathUtils.min(totalAvailableAssets, state.accruedProtocolFees));
  }

  /**
   * @dev Returns the amount of underlying assets that can be borrowed.
   *
   *      The borrower must maintain sufficient assets in the market to
   *      cover 100% of pending withdrawals, 100% of previously processed
   *      withdrawals (before they are executed), and the reserve ratio
   *      times the outstanding debt (deposits not pending withdrawal).
   *
   *      Any underlying assets in the market above this amount can be borrowed.
   */
  function borrowableAssets(
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint256) {
    return totalAssets.satSub(state.liquidityRequired());
  }

  function hasPendingExpiredBatch(MarketState memory state) internal view returns (bool result) {
    uint256 expiry = state.pendingWithdrawalExpiry;
    assembly {
      // Equivalent to expiry > 0 && expiry <= block.timestamp
      result := gt(timestamp(), sub(expiry, 1))
    }
  }

  function totalDebts(MarketState memory state) internal pure returns (uint256) {
    return
      state.normalizeAmount(state.scaledTotalSupply) +
      state.normalizedUnclaimedWithdrawals +
      state.accruedProtocolFees;
  }
}

// src/interfaces/IMarketEventsAndErrors.sol

interface IMarketEventsAndErrors {
  /// @notice Error thrown when deposit exceeds maxTotalSupply
  error MaxSupplyExceeded();

  /// @notice Error thrown when non-borrower tries accessing borrower-only actions
  error NotApprovedBorrower();

  /// @notice Error thrown when non-approved lender tries lending to the market
  error NotApprovedLender();

  /// @notice Error thrown when non-controller tries accessing controller-only actions
  error NotController();

  /// @notice Error thrown when non-sentinel tries to use nukeFromOrbit
  error BadLaunchCode();

  /// @notice Error thrown when new maxTotalSupply lower than totalSupply
  error NewMaxSupplyTooLow();

  /// @notice Error thrown when reserve ratio set higher than 100%
  error ReserveRatioBipsTooHigh();

  /// @notice Error thrown when interest rate set higher than 100%
  error InterestRateTooHigh();

  /// @notice Error thrown when interest fee set higher than 100%
  error InterestFeeTooHigh();

  /// @notice Error thrown when penalty fee set higher than 100%
  error PenaltyFeeTooHigh();

  /// @notice Error thrown when transfer target is blacklisted
  error AccountBlacklisted();

  error AccountNotBlocked();

  error NotReversedOrStunning();

  error UnknownNameQueryError();

  error UnknownSymbolQueryError();

  error BorrowAmountTooHigh();

  error FeeSetWithoutRecipient();

  error InsufficientReservesForFeeWithdrawal();

  error WithdrawalBatchNotExpired();

  error NullMintAmount();

  error NullBurnAmount();

  error NullFeeAmount();

  error NullTransferAmount();

  error NullWithdrawalAmount();

  error DepositToClosedMarket();

  error BorrowFromClosedMarket();

  error CloseMarketWithUnpaidWithdrawals();

  /// @notice Error thrown when reserve ratio set to value
  ///         the market currently would not meet.
  error InsufficientReservesForNewLiquidityRatio();

  error InsufficientReservesForOldLiquidityRatio();

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);

  event MaxTotalSupplyUpdated(uint256 assets);

  event AnnualInterestBipsUpdated(uint256 annualInterestBipsUpdated);

  event ReserveRatioBipsUpdated(uint256 reserveRatioBipsUpdated);

  event SanctionedAccountAssetsSentToEscrow(address account, address escrow, uint256 amount);

  event Deposit(address indexed account, uint256 assetAmount, uint256 scaledAmount);

  event Borrow(uint256 assetAmount);

  event MarketClosed(uint256 timestamp);

  event FeesCollected(uint256 assets);

  event StateUpdated(uint256 scaleFactor, bool isDelinquent);

  event ScaleFactorUpdated(
    uint256 scaleFactor,
    uint256 baseInterestRay,
    uint256 delinquencyFeeRay,
    uint256 protocolFee
  );

  event AuthorizationStatusUpdated(address indexed account, AuthRole role);

  // =====================================================================//
  //                          Withdrawl Events                            //
  // =====================================================================//

  event WithdrawalBatchExpired(
    uint256 expiry,
    uint256 scaledTotalAmount,
    uint256 scaledAmountBurned,
    uint256 normalizedAmountPaid
  );

  /**
   * @dev Emitted when a new withdrawal batch is created.
   */
  event WithdrawalBatchCreated(uint256 expiry);

  /**
   * @dev Emitted when a withdrawal batch is paid off.
   */
  event WithdrawalBatchClosed(uint256 expiry);

  event WithdrawalBatchPayment(
    uint256 expiry,
    uint256 scaledAmountBurned,
    uint256 normalizedAmountPaid
  );

  event WithdrawalQueued(uint256 expiry, address account, uint256 scaledAmount);

  event WithdrawalExecuted(uint256 expiry, address account, uint256 normalizedAmount);

  event Withdrawal(address indexed account, uint256 assetAmount, uint256 scaledAmount);

  event SanctionedAccountWithdrawalSentToEscrow(
    address account,
    address escrow,
    uint32 expiry,
    uint256 amount
  );
}

// src/interfaces/IWildcatMarketController.sol

interface IWildcatMarketController is IWildcatMarketControllerEventsAndErrors {
  // Returns immutable controller factory
  function controllerFactory() external view returns (address);

  // Returns immutable market factory
  function marketFactory() external view returns (address);

  // Returns immutable arch-controller
  function archController() external view returns (address);

  // Returns immutable borrower address
  function borrower() external view returns (address);

  /**
   * @dev Returns immutable protocol fee configuration for new markets.
   *      Queried from the controller factory.
   *
   * @return feeRecipient         feeRecipient to use in new markets
   * @return protocolFeeBips      protocolFeeBips to use in new markets
   * @return originationFeeAsset  Asset used to pay fees for new market
   *                              deployments
   * @return originationFeeAmount Amount of originationFeeAsset paid
   *                              for new market deployments
   */
  function getProtocolFeeConfiguration()
    external
    view
    returns (
      address feeRecipient,
      uint16 protocolFeeBips,
      address originationFeeAsset,
      uint256 originationFeeAmount
    );

  /**
   * @dev Returns immutable constraints on market parameters that
   *      the controller will enforce.
   */
  function getParameterConstraints()
    external
    view
    returns (MarketParameterConstraints memory constraints);

  /* -------------------------------------------------------------------------- */
  /*                               Lender Registry                              */
  /* -------------------------------------------------------------------------- */

  function getAuthorizedLenders() external view returns (address[] memory);

  function getAuthorizedLenders(
    uint256 start,
    uint256 end
  ) external view returns (address[] memory);

  function getAuthorizedLendersCount() external view returns (uint256);

  function isAuthorizedLender(address lender) external view returns (bool);

  /**
   * @dev Grant authorization for a set of lenders.
   *
   *      Note: Only updates the internal set of approved lenders.
   *      Must call `updateLenderAuthorization` to apply changes
   *      to existing market accounts
   */
  function authorizeLenders(address[] memory lenders) external;

  /**
   * @dev Revoke authorization for a set of lenders.
   *
   *      Note: Only updates the internal set of approved lenders.
   *      Must call `updateLenderAuthorization` to apply changes
   *      to existing market accounts
   */
  function deauthorizeLenders(address[] memory lenders) external;

  /**
   * @dev Update lender authorization for a set of markets to the current
   *      status.
   */
  function updateLenderAuthorization(address lender, address[] memory markets) external;

  /* -------------------------------------------------------------------------- */
  /*                               Market Controls                               */
  /* -------------------------------------------------------------------------- */

  /**
   * @dev Modify the interest rate for a market.
   * If the new interest rate is lower than the current interest rate,
   * the reserve ratio is set to 90% for the next two weeks.
   */
  function setAnnualInterestBips(address market, uint16 annualInterestBips) external;

  /**
   * @dev Reset the reserve ratio to the value it had prior to
   *      a call to `setAnnualInterestBips`.
   */
  function resetReserveRatio(address market) external;

  function temporaryExcessReserveRatio(
    address
  ) external view returns (uint128 reserveRatioBips, uint128 expiry);

  /**
   * @dev Deploys a new instance of the market through the market factory
   *      and registers it with the arch-controller.
   *
   *      If `msg.sender` is not `borrower` or `controllerFactory`,
   *      reverts with `CallerNotBorrowerOrControllerFactory`.
   *
   *	    If `msg.sender == borrower && !archController.isRegisteredBorrower(msg.sender)`,
   *		  reverts with `NotRegisteredBorrower`.
   *
   *      If called by `controllerFactory`, skips borrower check.
   *
   *      If `originationFeeAmount` returned by controller factory is not zero,
   *      transfers `originationFeeAmount` of `originationFeeAsset` from
   *      `msg.sender` to `feeRecipient`.
   */
  function deployMarket(
    address asset,
    string memory namePrefix,
    string memory symbolPrefix,
    uint128 maxTotalSupply,
    uint16 annualInterestBips,
    uint16 delinquencyFeeBips,
    uint32 withdrawalBatchDuration,
    uint16 reserveRatioBips,
    uint32 delinquencyGracePeriod
  ) external returns (address);

  function getMarketParameters() external view returns (MarketParameters memory);
}

// src/libraries/Withdrawal.sol

using MathUtils for uint256;
using SafeCastLib for uint256;
using WithdrawalLib for WithdrawalBatch global;
using WithdrawalLib for WithdrawalData global;

/**
 * Withdrawals are grouped together in batches with a fixed expiry.
 * Until a withdrawal is paid out, the tokens are not burned from the market
 * and continue to accumulate interest.
 */
struct WithdrawalBatch {
  // Total scaled amount of tokens to be withdrawn
  uint104 scaledTotalAmount;
  // Amount of scaled tokens that have been paid by borrower
  uint104 scaledAmountBurned;
  // Amount of normalized tokens that have been paid by borrower
  uint128 normalizedAmountPaid;
}

struct AccountWithdrawalStatus {
  uint104 scaledAmount;
  uint128 normalizedAmountWithdrawn;
}

struct WithdrawalData {
  FIFOQueue unpaidBatches;
  mapping(uint32 => WithdrawalBatch) batches;
  mapping(uint256 => mapping(address => AccountWithdrawalStatus)) accountStatuses;
}

library WithdrawalLib {
  function scaledOwedAmount(WithdrawalBatch memory batch) internal pure returns (uint104) {
    return batch.scaledTotalAmount - batch.scaledAmountBurned;
  }

  /**
   * @dev Get the amount of assets which are not already reserved
   *      for prior withdrawal batches. This must only be used on
   *      the latest withdrawal batch to expire.
   */
  function availableLiquidityForPendingBatch(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint256) {
    // Subtract normalized value of pending scaled withdrawals, processed
    // withdrawals and protocol fees.
    uint256 priorScaledAmountPending = (state.scaledPendingWithdrawals - batch.scaledOwedAmount());
    uint256 unavailableAssets = state.normalizedUnclaimedWithdrawals +
      state.normalizeAmount(priorScaledAmountPending) +
      state.accruedProtocolFees;
    return totalAssets.satSub(unavailableAssets);
  }
}

// src/market/WildcatMarketBase.sol

contract WildcatMarketBase is ReentrancyGuard, IMarketEventsAndErrors {
  using WithdrawalLib for MarketState;
  using SafeCastLib for uint256;
  using MathUtils for uint256;
  using BoolUtils for bool;

  // ==================================================================== //
  //                       Market Config (immutable)                       //
  // ==================================================================== //

  string public constant version = '1.0';

  /// @dev Account with blacklist control, used for blocking sanctioned addresses.
  address public immutable sentinel;

  /// @dev Account with authority to borrow assets from the market.
  address public immutable borrower;

  /// @dev Account that receives protocol fees.
  address public immutable feeRecipient;

  /// @dev Protocol fee added to interest paid by borrower.
  uint256 public immutable protocolFeeBips;

  /// @dev Penalty fee added to interest earned by lenders, does not affect protocol fee.
  uint256 public immutable delinquencyFeeBips;

  /// @dev Time after which delinquency incurs penalty fee.
  uint256 public immutable delinquencyGracePeriod;

  /// @dev Address of the Market Controller.
  address public immutable controller;

  /// @dev Address of the underlying asset.
  address public immutable asset;

  /// @dev Time before withdrawal batches are processed.
  uint256 public immutable withdrawalBatchDuration;

  /// @dev Token decimals (same as underlying asset).
  uint8 public immutable decimals;

  /// @dev Token name (prefixed name of underlying asset).
  string public name;

  /// @dev Token symbol (prefixed symbol of underlying asset).
  string public symbol;

  // ===================================================================== //
  //                             Market State                               //
  // ===================================================================== //

  MarketState internal _state;

  mapping(address => Account) internal _accounts;

  WithdrawalData internal _withdrawalData;

  // ===================================================================== //
  //                             Constructor                               //
  // ===================================================================== //

  constructor() {
    MarketParameters memory parameters = IWildcatMarketController(msg.sender).getMarketParameters();

    if ((parameters.protocolFeeBips > 0).and(parameters.feeRecipient == address(0))) {
      revert FeeSetWithoutRecipient();
    }
    if (parameters.annualInterestBips > BIP) {
      revert InterestRateTooHigh();
    }
    if (parameters.reserveRatioBips > BIP) {
      revert ReserveRatioBipsTooHigh();
    }
    if (parameters.protocolFeeBips > BIP) {
      revert InterestFeeTooHigh();
    }
    if (parameters.delinquencyFeeBips > BIP) {
      revert PenaltyFeeTooHigh();
    }

    // Set asset metadata
    asset = parameters.asset;
    name = string.concat(parameters.namePrefix, queryName(parameters.asset));
    symbol = string.concat(parameters.symbolPrefix, querySymbol(parameters.asset));
    decimals = IERC20Metadata(parameters.asset).decimals();

    _state = MarketState({
      isClosed: false,
      maxTotalSupply: parameters.maxTotalSupply,
      accruedProtocolFees: 0,
      normalizedUnclaimedWithdrawals: 0,
      scaledTotalSupply: 0,
      scaledPendingWithdrawals: 0,
      pendingWithdrawalExpiry: 0,
      isDelinquent: false,
      timeDelinquent: 0,
      annualInterestBips: parameters.annualInterestBips,
      reserveRatioBips: parameters.reserveRatioBips,
      scaleFactor: uint112(RAY),
      lastInterestAccruedTimestamp: uint32(block.timestamp)
    });

    sentinel = parameters.sentinel;
    borrower = parameters.borrower;
    controller = parameters.controller;
    feeRecipient = parameters.feeRecipient;
    protocolFeeBips = parameters.protocolFeeBips;
    delinquencyFeeBips = parameters.delinquencyFeeBips;
    delinquencyGracePeriod = parameters.delinquencyGracePeriod;
    withdrawalBatchDuration = parameters.withdrawalBatchDuration;
  }

  // ===================================================================== //
  //                              Modifiers                                //
  // ===================================================================== //

  modifier onlyBorrower() {
    if (msg.sender != borrower) revert NotApprovedBorrower();
    _;
  }

  modifier onlyController() {
    if (msg.sender != controller) revert NotController();
    _;
  }

  // ===================================================================== //
  //                       Internal State Getters                          //
  // ===================================================================== //

  /**
   * @dev Retrieve an account from storage.
   *
   *      Reverts if account is blocked.
   */
  function _getAccount(address accountAddress) internal view returns (Account memory account) {
    account = _accounts[accountAddress];
    if (account.approval == AuthRole.Blocked) {
      revert AccountBlacklisted();
    }
  }

  /**
   * @dev Block an account and transfer its balance of market tokens
   *      to an escrow contract.
   *
   *      If the account is already blocked, this function does nothing.
   */
  function _blockAccount(MarketState memory state, address accountAddress) internal {
    Account memory account = _accounts[accountAddress];
    if (account.approval != AuthRole.Blocked) {
      uint104 scaledBalance = account.scaledBalance;
      account.approval = AuthRole.Blocked;
      emit AuthorizationStatusUpdated(accountAddress, AuthRole.Blocked);

      if (scaledBalance > 0) {
        account.scaledBalance = 0;
        address escrow = IWildcatSanctionsSentinel(sentinel).createEscrow(
          accountAddress,
          borrower,
          address(this)
        );
        emit Transfer(accountAddress, escrow, state.normalizeAmount(scaledBalance));
        _accounts[escrow].scaledBalance += scaledBalance;
        emit SanctionedAccountAssetsSentToEscrow(
          accountAddress,
          escrow,
          state.normalizeAmount(scaledBalance)
        );
      }
      _accounts[accountAddress] = account;
    }
  }

  /**
   * @dev Retrieve an account from storage and assert that it has at
   *      least the required role.
   *
   *      If the account's role is not set, queries the controller to
   *      determine if it is an approved lender; if it is, its role
   *      is initialized to DepositAndWithdraw.
   */
  function _getAccountWithRole(
    address accountAddress,
    AuthRole requiredRole
  ) internal returns (Account memory account) {
    account = _getAccount(accountAddress);
    // If account role is null, see if it is authorized on controller.
    if (account.approval == AuthRole.Null) {
      if (IWildcatMarketController(controller).isAuthorizedLender(accountAddress)) {
        account.approval = AuthRole.DepositAndWithdraw;
        emit AuthorizationStatusUpdated(accountAddress, AuthRole.DepositAndWithdraw);
      }
    }
    // If account role is insufficient, revert.
    if (uint256(account.approval) < uint256(requiredRole)) {
      revert NotApprovedLender();
    }
  }

  // ===================================================================== //
  //                       External State Getters                          //
  // ===================================================================== //

  /**
   * @dev Returns the amount of underlying assets the borrower is obligated
   *      to maintain in the market to avoid delinquency.
   */
  function coverageLiquidity() external view nonReentrantView returns (uint256) {
    return currentState().liquidityRequired();
  }

  /**
   * @dev Returns the scale factor (in ray) used to convert scaled balances
   *      to normalized balances.
   */
  function scaleFactor() external view nonReentrantView returns (uint256) {
    return currentState().scaleFactor;
  }

  /**
   * @dev Total balance in underlying asset.
   */
  function totalAssets() public view returns (uint256) {
    return IERC20(asset).balanceOf(address(this));
  }

  /**
   * @dev Returns the amount of underlying assets the borrower is allowed
   *      to borrow.
   *
   *      This is the balance of underlying assets minus:
   *      - pending (unpaid) withdrawals
   *      - paid withdrawals
   *      - reserve ratio times the portion of the supply not pending withdrawal
   *      - protocol fees
   */
  function borrowableAssets() external view nonReentrantView returns (uint256) {
    return currentState().borrowableAssets(totalAssets());
  }

  /**
   * @dev Returns the amount of protocol fees (in underlying asset amount)
   *      that have accrued and are pending withdrawal.
   */
  function accruedProtocolFees() external view nonReentrantView returns (uint256) {
    return currentState().accruedProtocolFees;
  }

  /**
   * @dev Returns the state of the market as of the last update.
   */
  function previousState() external view returns (MarketState memory) {
    return _state;
  }

  /**
   * @dev Return the state the market would have at the current block after applying
   *      interest and fees accrued since the last update and processing the pending
   *      withdrawal batch if it is expired.
   */
  function currentState() public view nonReentrantView returns (MarketState memory state) {
    (state, , ) = _calculateCurrentState();
  }

  /**
   * @dev Returns the scaled total supply the vaut would have at the current block
   *      after applying interest and fees accrued since the last update and burning
   *      market tokens for the pending withdrawal batch if it is expired.
   */
  function scaledTotalSupply() external view nonReentrantView returns (uint256) {
    return currentState().scaledTotalSupply;
  }

  /**
   * @dev Returns the scaled balance of `account`
   */
  function scaledBalanceOf(address account) external view nonReentrantView returns (uint256) {
    return _accounts[account].scaledBalance;
  }

  /**
   * @dev Returns current role of `account`.
   */
  function getAccountRole(address account) external view nonReentrantView returns (AuthRole) {
    return _accounts[account].approval;
  }

  /**
   * @dev Returns the amount of protocol fees that are currently
   *      withdrawable by the fee recipient.
   */
  function withdrawableProtocolFees() external view returns (uint128) {
    return currentState().withdrawableProtocolFees(totalAssets());
  }

  /**
   * @dev Calculate effective interest rate currently paid by borrower.
   *      Borrower pays base APR, protocol fee (on base APR) and delinquency
   *      fee (if delinquent beyond grace period).
   *
   * @return apr paid by borrower in ray
   */
  function effectiveBorrowerAPR() external view returns (uint256) {
    MarketState memory state = currentState();
    // apr + (apr * protocolFee)
    uint256 apr = MathUtils.bipToRay(state.annualInterestBips).bipMul(BIP + protocolFeeBips);
    if (state.timeDelinquent > delinquencyGracePeriod) {
      apr += MathUtils.bipToRay(delinquencyFeeBips);
    }
    return apr;
  }

  /**
   * @dev Calculate effective interest rate currently earned by lenders.
   *     Lenders earn base APR and delinquency fee (if delinquent beyond grace period)
   *
   * @return apr earned by lender in ray
   */
  function effectiveLenderAPR() external view returns (uint256) {
    MarketState memory state = currentState();
    uint256 apr = state.annualInterestBips;
    if (state.timeDelinquent > delinquencyGracePeriod) {
      apr += delinquencyFeeBips;
    }
    return MathUtils.bipToRay(apr);
  }

  // /*//////////////////////////////////////////////////////////////
  //                     Internal State Handlers
  // //////////////////////////////////////////////////////////////*/

  /**
   * @dev Returns cached MarketState after accruing interest and delinquency / protocol fees
   *      and processing expired withdrawal batch, if any.
   *
   *      Used by functions that make additional changes to `state`.
   *
   *      NOTE: Returned `state` does not match `_state` if interest is accrued
   *            Calling function must update `_state` or revert.
   *
   * @return state Market state after interest is accrued.
   */
  function _getUpdatedState() internal returns (MarketState memory state) {
    state = _state;
    // Handle expired withdrawal batch
    if (state.hasPendingExpiredBatch()) {
      uint256 expiry = state.pendingWithdrawalExpiry;
      // Only accrue interest if time has passed since last update.
      // This will only be false if withdrawalBatchDuration is 0.
      if (expiry != state.lastInterestAccruedTimestamp) {
        (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee) = state
          .updateScaleFactorAndFees(
            protocolFeeBips,
            delinquencyFeeBips,
            delinquencyGracePeriod,
            expiry
          );
        emit ScaleFactorUpdated(state.scaleFactor, baseInterestRay, delinquencyFeeRay, protocolFee);
      }
      _processExpiredWithdrawalBatch(state);
    }
    // Apply interest and fees accrued since last update (expiry or previous tx)
    if (block.timestamp != state.lastInterestAccruedTimestamp) {
      (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee) = state
        .updateScaleFactorAndFees(
          protocolFeeBips,
          delinquencyFeeBips,
          delinquencyGracePeriod,
          block.timestamp
        );
      emit ScaleFactorUpdated(state.scaleFactor, baseInterestRay, delinquencyFeeRay, protocolFee);
    }
  }

  /**
   * @dev Calculate the current state, applying fees and interest accrued since
   *      the last state update as well as the effects of withdrawal batch expiry
   *      on the market state.
   *      Identical to _getUpdatedState() except it does not modify storage or
   *      or emit events.
   *      Returns expired batch data, if any, so queries against batches have
   *      access to the most recent data.
   */
  function _calculateCurrentState()
    internal
    view
    returns (
      MarketState memory state,
      uint32 expiredBatchExpiry,
      WithdrawalBatch memory expiredBatch
    )
  {
    state = _state;
    // Handle expired withdrawal batch
    if (state.hasPendingExpiredBatch()) {
      expiredBatchExpiry = state.pendingWithdrawalExpiry;
      // Only accrue interest if time has passed since last update.
      // This will only be false if withdrawalBatchDuration is 0.
      if (expiredBatchExpiry != state.lastInterestAccruedTimestamp) {
        state.updateScaleFactorAndFees(
          protocolFeeBips,
          delinquencyFeeBips,
          delinquencyGracePeriod,
          expiredBatchExpiry
        );
      }

      expiredBatch = _withdrawalData.batches[expiredBatchExpiry];
      uint256 availableLiquidity = expiredBatch.availableLiquidityForPendingBatch(
        state,
        totalAssets()
      );
      if (availableLiquidity > 0) {
        _applyWithdrawalBatchPaymentView(expiredBatch, state, availableLiquidity);
      }
      state.pendingWithdrawalExpiry = 0;
    }

    if (state.lastInterestAccruedTimestamp != block.timestamp) {
      state.updateScaleFactorAndFees(
        protocolFeeBips,
        delinquencyFeeBips,
        delinquencyGracePeriod,
        block.timestamp
      );
    }
  }

  /**
   * @dev Writes the cached MarketState to storage and emits an event.
   *      Used at the end of all functions which modify `state`.
   */
  function _writeState(MarketState memory state) internal {
    bool isDelinquent = state.liquidityRequired() > totalAssets();
    state.isDelinquent = isDelinquent;
    _state = state;
    emit StateUpdated(state.scaleFactor, isDelinquent);
  }

  /**
   * @dev Handles an expired withdrawal batch:
   *      - Retrieves the amount of underlying assets that can be used to pay for the batch.
   *      - If the amount is sufficient to pay the full amount owed to the batch, the batch
   *        is closed and the total withdrawal amount is reserved.
   *      - If the amount is insufficient to pay the full amount owed to the batch, the batch
   *        is recorded as an unpaid batch and the available assets are reserved.
   *      - The assets reserved for the batch are scaled by the current scale factor and that
   *        amount of scaled tokens is burned, ensuring borrowers do not continue paying interest
   *        on withdrawn assets.
   */
  function _processExpiredWithdrawalBatch(MarketState memory state) internal {
    uint32 expiry = state.pendingWithdrawalExpiry;
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];

    // Burn as much of the withdrawal batch as possible with available liquidity.
    uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
    if (availableLiquidity > 0) {
      _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
    }

    emit WithdrawalBatchExpired(
      expiry,
      batch.scaledTotalAmount,
      batch.scaledAmountBurned,
      batch.normalizedAmountPaid
    );

    if (batch.scaledAmountBurned < batch.scaledTotalAmount) {
      _withdrawalData.unpaidBatches.push(expiry);
    } else {
      emit WithdrawalBatchClosed(expiry);
    }

    state.pendingWithdrawalExpiry = 0;

    _withdrawalData.batches[expiry] = batch;
  }

  /**
   * @dev Process withdrawal payment, burning market tokens and reserving
   *      underlying assets so they are only available for withdrawals.
   */
  function _applyWithdrawalBatchPayment(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint32 expiry,
    uint256 availableLiquidity
  ) internal {
    uint104 scaledAvailableLiquidity = state.scaleAmount(availableLiquidity).toUint104();
    uint104 scaledAmountOwed = batch.scaledTotalAmount - batch.scaledAmountBurned;
    // Do nothing if batch is already paid
    if (scaledAmountOwed == 0) {
      return;
    }
    uint104 scaledAmountBurned = uint104(MathUtils.min(scaledAvailableLiquidity, scaledAmountOwed));
    uint128 normalizedAmountPaid = state.normalizeAmount(scaledAmountBurned).toUint128();

    batch.scaledAmountBurned += scaledAmountBurned;
    batch.normalizedAmountPaid += normalizedAmountPaid;
    state.scaledPendingWithdrawals -= scaledAmountBurned;

    // Update normalizedUnclaimedWithdrawals so the tokens are only accessible for withdrawals.
    state.normalizedUnclaimedWithdrawals += normalizedAmountPaid;

    // Burn market tokens to stop interest accrual upon withdrawal payment.
    state.scaledTotalSupply -= scaledAmountBurned;

    // Emit transfer for external trackers to indicate burn.
    emit Transfer(address(this), address(0), normalizedAmountPaid);
    emit WithdrawalBatchPayment(expiry, scaledAmountBurned, normalizedAmountPaid);
  }

  function _applyWithdrawalBatchPaymentView(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint256 availableLiquidity
  ) internal pure {
    uint104 scaledAvailableLiquidity = state.scaleAmount(availableLiquidity).toUint104();
    uint104 scaledAmountOwed = batch.scaledTotalAmount - batch.scaledAmountBurned;
    // Do nothing if batch is already paid
    if (scaledAmountOwed == 0) {
      return;
    }
    uint104 scaledAmountBurned = uint104(MathUtils.min(scaledAvailableLiquidity, scaledAmountOwed));
    uint128 normalizedAmountPaid = state.normalizeAmount(scaledAmountBurned).toUint128();

    batch.scaledAmountBurned += scaledAmountBurned;
    batch.normalizedAmountPaid += normalizedAmountPaid;
    state.scaledPendingWithdrawals -= scaledAmountBurned;

    // Update normalizedUnclaimedWithdrawals so the tokens are only accessible for withdrawals.
    state.normalizedUnclaimedWithdrawals += normalizedAmountPaid;

    // Burn market tokens to stop interest accrual upon withdrawal payment.
    state.scaledTotalSupply -= scaledAmountBurned;
  }
}

// src/market/WildcatMarketConfig.sol

contract WildcatMarketConfig is WildcatMarketBase {
  using SafeCastLib for uint256;
  using BoolUtils for bool;

  // ===================================================================== //
  //                      External Config Getters                          //
  // ===================================================================== //

  /**
   * @dev Returns the maximum amount of underlying asset that can
   *      currently be deposited to the market.
   */
  function maximumDeposit() external view returns (uint256) {
    MarketState memory state = currentState();
    return state.maximumDeposit();
  }

  /**
   * @dev Returns the maximum supply the market can reach via
   *      deposits (does not apply to interest accrual).
   */
  function maxTotalSupply() external view returns (uint256) {
    return _state.maxTotalSupply;
  }

  /**
   * @dev Returns the annual interest rate earned by lenders
   *      in bips.
   */
  function annualInterestBips() external view returns (uint256) {
    return _state.annualInterestBips;
  }

  function reserveRatioBips() external view returns (uint256) {
    return _state.reserveRatioBips;
  }

  /* -------------------------------------------------------------------------- */
  /*                                  Sanctions                                 */
  /* -------------------------------------------------------------------------- */

  /// @dev Block a sanctioned account from interacting with the market
  ///      and transfer its balance to an escrow contract.
  // ******************************************************************
  //          *  |\**/|  *          *                                *
  //          *  \ == /  *          *                                *
  //          *   | b|   *          *                                *
  //          *   | y|   *          *                                *
  //          *   \ e/   *          *                                *
  //          *    \/    *          *                                *
  //          *          *          *                                *
  //          *          *          *                                *
  //          *          *  |\**/|  *                                *
  //          *          *  \ == /  *         _.-^^---....,,--       *
  //          *          *   | b|   *    _--                  --_    *
  //          *          *   | y|   *   <                        >)  *
  //          *          *   \ e/   *   |         O-FAC!          |  *
  //          *          *    \/    *    \._                   _./   *
  //          *          *          *       ```--. . , ; .--'''      *
  //          *          *          *   💸        | |   |            *
  //          *          *          *          .-=||  | |=-.    💸   *
  //  💰🤑💰 *   😅    *    😐    *    💸    `-=#$%&%$#=-'         *
  //   \|/    *   /|\    *   /|\    *  🌪         | ;  :|    🌪       *
  //   /\     * 💰/\ 💰 * 💰/\ 💰 *    _____.,-#%&$@%#&#~,._____    *
  // ******************************************************************
  function nukeFromOrbit(address accountAddress) external nonReentrant {
    if (!IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      revert BadLaunchCode();
    }
    MarketState memory state = _getUpdatedState();
    _blockAccount(state, accountAddress);
    _writeState(state);
  }

  /**
   * @dev Unblock an account that was previously sanctioned and blocked
   *      and has since been removed from the sanctions list or had
   *      their sanctioned status overridden by the borrower.
   */
  function stunningReversal(address accountAddress) external nonReentrant {
    Account memory account = _accounts[accountAddress];
    if (account.approval != AuthRole.Blocked) {
      revert AccountNotBlocked();
    }

    if (IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      revert NotReversedOrStunning();
    }

    account.approval = AuthRole.Null;
    emit AuthorizationStatusUpdated(accountAddress, account.approval);

    _accounts[accountAddress] = account;
  }

  /* -------------------------------------------------------------------------- */
  /*                           External Config Setters                          */
  /* -------------------------------------------------------------------------- */

  /**
   * @dev Updates an account's authorization status based on whether the controller
   *      has it marked as approved.
   */
  function updateAccountAuthorization(
    address _account,
    bool _isAuthorized
  ) external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    Account memory account = _getAccount(_account);
    if (_isAuthorized) {
      account.approval = AuthRole.DepositAndWithdraw;
    } else {
      account.approval = AuthRole.WithdrawOnly;
    }
    _accounts[_account] = account;
    _writeState(state);
    emit AuthorizationStatusUpdated(_account, account.approval);
  }

  /**
   * @dev Sets the maximum total supply - this only limits deposits and
   *      does not affect interest accrual.
   *
   *      Can not be set lower than current total supply.
   */
  function setMaxTotalSupply(uint256 _maxTotalSupply) external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();

    if (_maxTotalSupply < state.totalSupply()) {
      revert NewMaxSupplyTooLow();
    }

    state.maxTotalSupply = _maxTotalSupply.toUint128();
    _writeState(state);
    emit MaxTotalSupplyUpdated(_maxTotalSupply);
  }

  /**
   * @dev Sets the annual interest rate earned by lenders in bips.
   */
  function setAnnualInterestBips(uint16 _annualInterestBips) public onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();

    if (_annualInterestBips > BIP) {
      revert InterestRateTooHigh();
    }

    state.annualInterestBips = _annualInterestBips;
    _writeState(state);
    emit AnnualInterestBipsUpdated(_annualInterestBips);
  }

  /**
   * @dev Adjust the market's reserve ratio.
   *
   *      If the new ratio is lower than the old ratio,
   *      asserts that the market is not currently delinquent.
   *
   *      If the new ratio is higher than the old ratio,
   *      asserts that the market will not become delinquent
   *      because of the change.
   */
  function setReserveRatioBips(uint16 _reserveRatioBips) public onlyController nonReentrant {
    if (_reserveRatioBips > BIP) {
      revert ReserveRatioBipsTooHigh();
    }

    MarketState memory state = _getUpdatedState();

    uint256 initialReserveRatioBips = state.reserveRatioBips;

    if (_reserveRatioBips < initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert InsufficientReservesForOldLiquidityRatio();
      }
    }
    state.reserveRatioBips = _reserveRatioBips;
    if (_reserveRatioBips > initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert InsufficientReservesForNewLiquidityRatio();
      }
    }
    _writeState(state);
    emit ReserveRatioBipsUpdated(_reserveRatioBips);
  }
}

// src/market/WildcatMarketToken.sol

contract WildcatMarketToken is WildcatMarketBase {
  using SafeCastLib for uint256;

  /* -------------------------------------------------------------------------- */
  /*                                ERC20 Queries                               */
  /* -------------------------------------------------------------------------- */

  mapping(address => mapping(address => uint256)) public allowance;

  /// @notice Returns the normalized balance of `account` with interest.
  function balanceOf(address account) public view virtual nonReentrantView returns (uint256) {
    (MarketState memory state, , ) = _calculateCurrentState();
    return state.normalizeAmount(_accounts[account].scaledBalance);
  }

  /// @notice Returns the normalized total supply with interest.
  function totalSupply() external view virtual nonReentrantView returns (uint256) {
    (MarketState memory state, , ) = _calculateCurrentState();
    return state.totalSupply();
  }

  /* -------------------------------------------------------------------------- */
  /*                                ERC20 Actions                               */
  /* -------------------------------------------------------------------------- */

  function approve(address spender, uint256 amount) external virtual nonReentrant returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transfer(address to, uint256 amount) external virtual nonReentrant returns (bool) {
    _transfer(msg.sender, to, amount);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external virtual nonReentrant returns (bool) {
    uint256 allowed = allowance[from][msg.sender];

    // Saves gas for unlimited approvals.
    if (allowed != type(uint256).max) {
      uint256 newAllowance = allowed - amount;
      _approve(from, msg.sender, newAllowance);
    }

    _transfer(from, to, amount);

    return true;
  }

  function _approve(address approver, address spender, uint256 amount) internal virtual {
    allowance[approver][spender] = amount;
    emit Approval(approver, spender, amount);
  }

  function _transfer(address from, address to, uint256 amount) internal virtual {
    MarketState memory state = _getUpdatedState();
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();

    if (scaledAmount == 0) {
      revert NullTransferAmount();
    }

    Account memory fromAccount = _getAccount(from);
    fromAccount.scaledBalance -= scaledAmount;
    _accounts[from] = fromAccount;

    Account memory toAccount = _getAccount(to);
    toAccount.scaledBalance += scaledAmount;
    _accounts[to] = toAccount;

    _writeState(state);
    emit Transfer(from, to, amount);
  }
}

// src/market/WildcatMarketWithdrawals.sol

contract WildcatMarketWithdrawals is WildcatMarketBase {
  using SafeTransferLib for address;
  using MathUtils for uint256;
  using SafeCastLib for uint256;
  using BoolUtils for bool;

  /* -------------------------------------------------------------------------- */
  /*                             Withdrawal Queries                             */
  /* -------------------------------------------------------------------------- */

  /**
   * @dev Returns the expiry timestamp of every unpaid withdrawal batch.
   */
  function getUnpaidBatchExpiries() external view nonReentrantView returns (uint32[] memory) {
    return _withdrawalData.unpaidBatches.values();
  }

  function getWithdrawalBatch(
    uint32 expiry
  ) external view nonReentrantView returns (WithdrawalBatch memory) {
    (, uint32 expiredBatchExpiry, WithdrawalBatch memory expiredBatch) = _calculateCurrentState();
    if ((expiry == expiredBatchExpiry).and(expiry > 0)) {
      return expiredBatch;
    }
    return _withdrawalData.batches[expiry];
  }

  function getAccountWithdrawalStatus(
    address accountAddress,
    uint32 expiry
  ) external view nonReentrantView returns (AccountWithdrawalStatus memory) {
    return _withdrawalData.accountStatuses[expiry][accountAddress];
  }

  function getAvailableWithdrawalAmount(
    address accountAddress,
    uint32 expiry
  ) external view nonReentrantView returns (uint256) {
    if (expiry > block.timestamp) {
      revert WithdrawalBatchNotExpired();
    }
    (, uint32 expiredBatchExpiry, WithdrawalBatch memory expiredBatch) = _calculateCurrentState();
    WithdrawalBatch memory batch;
    if (expiry == expiredBatchExpiry) {
      batch = expiredBatch;
    } else {
      batch = _withdrawalData.batches[expiry];
    }
    AccountWithdrawalStatus memory status = _withdrawalData.accountStatuses[expiry][accountAddress];
    // Rounding errors will lead to some dust accumulating in the batch, but the cost of
    // executing a withdrawal will be lower for users.
    uint256 previousTotalWithdrawn = status.normalizedAmountWithdrawn;
    uint256 newTotalWithdrawn = uint256(batch.normalizedAmountPaid).mulDiv(
      status.scaledAmount,
      batch.scaledTotalAmount
    );
    return newTotalWithdrawn - previousTotalWithdrawn;
  }

  /* -------------------------------------------------------------------------- */
  /*                             Withdrawal Actions                             */
  /* -------------------------------------------------------------------------- */

  /**
   * @dev Create a withdrawal request for a lender.
   */
  function queueWithdrawal(uint256 amount) external nonReentrant {
    MarketState memory state = _getUpdatedState();

    // Cache account data and revert if not authorized to withdraw.
    Account memory account = _getAccountWithRole(msg.sender, AuthRole.WithdrawOnly);

    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) {
      revert NullBurnAmount();
    }

    // Reduce caller's balance and emit transfer event.
    account.scaledBalance -= scaledAmount;
    _accounts[msg.sender] = account;
    emit Transfer(msg.sender, address(this), amount);

    // If there is no pending withdrawal batch, create a new one.
    if (state.pendingWithdrawalExpiry == 0) {
      state.pendingWithdrawalExpiry = uint32(block.timestamp + withdrawalBatchDuration);
      emit WithdrawalBatchCreated(state.pendingWithdrawalExpiry);
    }
    // Cache batch expiry on the stack for gas savings.
    uint32 expiry = state.pendingWithdrawalExpiry;

    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];

    // Add scaled withdrawal amount to account withdrawal status, withdrawal batch and market state.
    _withdrawalData.accountStatuses[expiry][msg.sender].scaledAmount += scaledAmount;
    batch.scaledTotalAmount += scaledAmount;
    state.scaledPendingWithdrawals += scaledAmount;

    emit WithdrawalQueued(expiry, msg.sender, scaledAmount);

    // Burn as much of the withdrawal batch as possible with available liquidity.
    uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
    if (availableLiquidity > 0) {
      _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
    }

    // Update stored batch data
    _withdrawalData.batches[expiry] = batch;

    // Update stored state
    _writeState(state);
  }

  /**
   * @dev Execute a pending withdrawal request for a batch that has expired.
   *
   *      Withdraws the proportional amount of the paid batch owed to
   *      `accountAddress` which has not already been withdrawn.
   *
   *      If `accountAddress` is sanctioned, transfers the owed amount to
   *      an escrow contract specific to the account and blocks the account.
   *
   *      Reverts if:
   *      - `expiry > block.timestamp`
   *      -  `expiry` does not correspond to an existing withdrawal batch
   *      - `accountAddress` has already withdrawn the full amount owed
   */
  function executeWithdrawal(
    address accountAddress,
    uint32 expiry
  ) external nonReentrant returns (uint256) {
    if (expiry > block.timestamp) {
      revert WithdrawalBatchNotExpired();
    }
    MarketState memory state = _getUpdatedState();

    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
    AccountWithdrawalStatus storage status = _withdrawalData.accountStatuses[expiry][
      accountAddress
    ];

    uint128 newTotalWithdrawn = uint128(
      MathUtils.mulDiv(batch.normalizedAmountPaid, status.scaledAmount, batch.scaledTotalAmount)
    );

    uint128 normalizedAmountWithdrawn = newTotalWithdrawn - status.normalizedAmountWithdrawn;

    status.normalizedAmountWithdrawn = newTotalWithdrawn;
    state.normalizedUnclaimedWithdrawals -= normalizedAmountWithdrawn;

    if (normalizedAmountWithdrawn == 0) {
      revert NullWithdrawalAmount();
    }

    if (IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      _blockAccount(state, accountAddress);
      address escrow = IWildcatSanctionsSentinel(sentinel).createEscrow(
        accountAddress,
        borrower,
        address(asset)
      );
      asset.safeTransfer(escrow, normalizedAmountWithdrawn);
      emit SanctionedAccountWithdrawalSentToEscrow(
        accountAddress,
        escrow,
        expiry,
        normalizedAmountWithdrawn
      );
    } else {
      asset.safeTransfer(accountAddress, normalizedAmountWithdrawn);
    }

    emit WithdrawalExecuted(expiry, accountAddress, normalizedAmountWithdrawn);

    // Update stored state
    _writeState(state);

    return normalizedAmountWithdrawn;
  }

  function processUnpaidWithdrawalBatch() external nonReentrant {
    MarketState memory state = _getUpdatedState();

    // Get the next unpaid batch timestamp from storage (reverts if none)
    uint32 expiry = _withdrawalData.unpaidBatches.first();

    // Cache batch data in memory
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];

    // Calculate assets available to process the batch
    uint256 availableLiquidity = totalAssets() -
      (state.normalizedUnclaimedWithdrawals + state.accruedProtocolFees);

    _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);

    // Remove batch from unpaid set if fully paid
    if (batch.scaledTotalAmount == batch.scaledAmountBurned) {
      _withdrawalData.unpaidBatches.shift();
      emit WithdrawalBatchClosed(expiry);
    }

    // Update stored batch
    _withdrawalData.batches[expiry] = batch;
    _writeState(state);
  }
}

// src/market/WildcatMarket.sol

contract WildcatMarket is
  WildcatMarketBase,
  WildcatMarketConfig,
  WildcatMarketToken,
  WildcatMarketWithdrawals
{
  using MathUtils for uint256;
  using SafeCastLib for uint256;
  using SafeTransferLib for address;

  /**
   * @dev Apply pending interest, delinquency fees and protocol fees
   *      to the state and process the pending withdrawal batch if
   *      one exists and has expired, then update the market's
   *      delinquency status.
   */
  function updateState() external nonReentrant {
    MarketState memory state = _getUpdatedState();
    _writeState(state);
  }

  /**
   * @dev Deposit up to `amount` underlying assets and mint market tokens
   *      for `msg.sender`.
   *
   *      The actual deposit amount is limited by the market's maximum deposit
   *      amount, which is the configured `maxTotalSupply` minus the current
   *      total supply.
   *
   *      Reverts if the market is closed or if the scaled token amount
   *      that would be minted for the deposit is zero.
   */
  function depositUpTo(
    uint256 amount
  ) public virtual nonReentrant returns (uint256 /* actualAmount */) {
    // Get current state
    MarketState memory state = _getUpdatedState();

    if (state.isClosed) {
      revert DepositToClosedMarket();
    }

    // Reduce amount if it would exceed totalSupply
    amount = MathUtils.min(amount, state.maximumDeposit());

    // Scale the mint amount
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) revert NullMintAmount();

    // Transfer deposit from caller
    asset.safeTransferFrom(msg.sender, address(this), amount);

    // Cache account data and revert if not authorized to deposit.
    Account memory account = _getAccountWithRole(msg.sender, AuthRole.DepositAndWithdraw);
    account.scaledBalance += scaledAmount;
    _accounts[msg.sender] = account;

    emit Transfer(address(0), msg.sender, amount);
    emit Deposit(msg.sender, amount, scaledAmount);

    // Increase supply
    state.scaledTotalSupply += scaledAmount;

    // Update stored state
    _writeState(state);

    return amount;
  }

  /**
   * @dev Deposit exactly `amount` underlying assets and mint market tokens
   *      for `msg.sender`.
   *
   *     Reverts if the deposit amount would cause the market to exceed the
   *     configured `maxTotalSupply`.
   */
  function deposit(uint256 amount) external virtual {
    uint256 actualAmount = depositUpTo(amount);
    if (amount != actualAmount) {
      revert MaxSupplyExceeded();
    }
  }

  /**
   * @dev Withdraw available protocol fees to the fee recipient.
   */
  function collectFees() external nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (state.accruedProtocolFees == 0) {
      revert NullFeeAmount();
    }
    uint128 withdrawableFees = state.withdrawableProtocolFees(totalAssets());
    if (withdrawableFees == 0) {
      revert InsufficientReservesForFeeWithdrawal();
    }
    state.accruedProtocolFees -= withdrawableFees;
    _writeState(state);
    asset.safeTransfer(feeRecipient, withdrawableFees);
    emit FeesCollected(withdrawableFees);
  }

  /**
   * @dev Withdraw funds from the market to the borrower.
   *
   *      Can only withdraw up to the assets that are not required
   *      to meet the borrower's collateral obligations.
   *
   *      Reverts if the market is closed.
   */
  function borrow(uint256 amount) external onlyBorrower nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (state.isClosed) {
      revert BorrowFromClosedMarket();
    }
    uint256 borrowable = state.borrowableAssets(totalAssets());
    if (amount > borrowable) {
      revert BorrowAmountTooHigh();
    }
    _writeState(state);
    asset.safeTransfer(msg.sender, amount);
    emit Borrow(amount);
  }

  /**
   * @dev Sets the market APR to 0% and marks market as closed.
   *
   *      Can not be called if there are any unpaid withdrawal batches.
   *
   *      Transfers remaining debts from borrower if market is not fully
   *      collateralized; otherwise, transfers any assets in excess of
   *      debts to the borrower.
   */
  function closeMarket() external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    state.annualInterestBips = 0;
    state.isClosed = true;
    state.reserveRatioBips = 0;
    if (_withdrawalData.unpaidBatches.length() > 0) {
      revert CloseMarketWithUnpaidWithdrawals();
    }
    uint256 currentlyHeld = totalAssets();
    uint256 totalDebts = state.totalDebts();
    if (currentlyHeld < totalDebts) {
      // Transfer remaining debts from borrower
      asset.safeTransferFrom(borrower, address(this), totalDebts - currentlyHeld);
    } else if (currentlyHeld > totalDebts) {
      // Transfer excess assets to borrower
      asset.safeTransfer(borrower, currentlyHeld - totalDebts);
    }
    _writeState(state);
    emit MarketClosed(block.timestamp);
  }
}

