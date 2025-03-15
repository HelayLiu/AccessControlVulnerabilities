// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

// lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

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
 * ```solidity
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
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
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
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
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
            set._positions[value] = set._values.length;
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
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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

        /// @solidity memory-safe-assembly
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
     * @dev Returns the number of values in the set. O(1).
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

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
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

// lib/solmate/src/utils/FixedPointMathLib.sol

/// @notice Arithmetic library with operations for fixed-point numbers.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/FixedPointMathLib.sol)
/// @author Inspired by USM (https://github.com/usmfum/USM/blob/master/contracts/WadMath.sol)
library FixedPointMathLib {
    /*//////////////////////////////////////////////////////////////
                    SIMPLIFIED FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    uint256 internal constant MAX_UINT256 = 2**256 - 1;

    uint256 internal constant WAD = 1e18; // The scalar of ETH and most ERC20s.

    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); // Equivalent to (x * y) / WAD rounded down.
    }

    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); // Equivalent to (x * y) / WAD rounded up.
    }

    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); // Equivalent to (x * WAD) / y rounded down.
    }

    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); // Equivalent to (x * WAD) / y rounded up.
    }

    /*//////////////////////////////////////////////////////////////
                    LOW LEVEL FIXED POINT OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // Divide x * y by the denominator.
            z := div(mul(x, y), denominator)
        }
    }

    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(denominator != 0 && (y == 0 || x <= type(uint256).max / y))
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }

            // If x * y modulo the denominator is strictly greater than 0,
            // 1 is added to round up the division of x * y by the denominator.
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }

    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    // 0 ** 0 = 1
                    z := scalar
                }
                default {
                    // 0 ** n = 0
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    // If n is even, store scalar in z for now.
                    z := scalar
                }
                default {
                    // If n is odd, store x in z for now.
                    z := x
                }

                // Shifting right by 1 is like dividing by 2.
                let half := shr(1, scalar)

                for {
                    // Shift n right by 1 before looping to halve it.
                    n := shr(1, n)
                } n {
                    // Shift n right by 1 each iteration to halve it.
                    n := shr(1, n)
                } {
                    // Revert immediately if x ** 2 would overflow.
                    // Equivalent to iszero(eq(div(xx, x), x)) here.
                    if shr(128, x) {
                        revert(0, 0)
                    }

                    // Store x squared.
                    let xx := mul(x, x)

                    // Round to the nearest number.
                    let xxRound := add(xx, half)

                    // Revert if xx + half overflowed.
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }

                    // Set x to scaled xxRound.
                    x := div(xxRound, scalar)

                    // If n is even:
                    if mod(n, 2) {
                        // Compute z * x.
                        let zx := mul(z, x)

                        // If z * x overflowed:
                        if iszero(eq(div(zx, x), z)) {
                            // Revert if x is non-zero.
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }

                        // Round to the nearest number.
                        let zxRound := add(zx, half)

                        // Revert if zx + half overflowed.
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }

                        // Return properly scaled zxRound.
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        GENERAL NUMBER UTILITIES
    //////////////////////////////////////////////////////////////*/

    function sqrt(uint256 x) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            let y := x // We start y at x, which will help us make our initial estimate.

            z := 181 // The "correct" value is 1, but this saves a multiplication later.

            // This segment is to get a reasonable initial estimate for the Babylonian method. With a bad
            // start, the correct # of bits increases ~linearly each iteration instead of ~quadratically.

            // We check y >= 2^(k + 8) but shift right by k bits
            // each branch to ensure that if x >= 256, then y >= 256.
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }

            // Goal was to get z*z*y within a small factor of x. More iterations could
            // get y in a tighter range. Currently, we will have y in [256, 256*2^16).
            // We ensured y >= 256 so that the relative difference between y and y+1 is small.
            // That's not possible if x < 256 but we can just verify those cases exhaustively.

            // Now, z*z*y <= x < z*z*(y+1), and y <= 2^(16+8), and either y >= 256, or x < 256.
            // Correctness can be checked exhaustively for x < 256, so we assume y >= 256.
            // Then z*sqrt(y) is within sqrt(257)/sqrt(256) of sqrt(x), or about 20bps.

            // For s in the range [1/256, 256], the estimate f(s) = (181/1024) * (s+1) is in the range
            // (1/2.84 * sqrt(s), 2.84 * sqrt(s)), with largest error when s = 1 and when s = 256 or 1/256.

            // Since y is in [256, 256*2^16), let a = y/65536, so that a is in [1/256, 256). Then we can estimate
            // sqrt(y) using sqrt(65536) * 181/1024 * (a + 1) = 181/4 * (y + 65536)/65536 = 181 * (y + 65536)/2^18.

            // There is no overflow risk here since y < 2^136 after the first branch above.
            z := shr(18, mul(z, add(y, 65536))) // A mul() is saved from starting z at 181.

            // Given the worst case multiplicative error of 2.84 above, 7 iterations should be enough.
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))

            // If x+1 is a perfect square, the Babylonian method cycles between
            // floor(sqrt(x)) and ceil(sqrt(x)). This statement ensures we return floor.
            // See: https://en.wikipedia.org/wiki/Integer_square_root#Using_only_integer_division
            // Since the ceil is rare, we save gas on the assignment and repeat division in the rare case.
            // If you don't care whether the floor or ceil square root is returned, you can remove this statement.
            z := sub(z, lt(div(x, z), z))
        }
    }

    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Mod x by y. Note this will return
            // 0 instead of reverting if y is zero.
            z := mod(x, y)
        }
    }

    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        /// @solidity memory-safe-assembly
        assembly {
            // Divide x by y. Note this will return
            // 0 instead of reverting if y is zero.
            r := div(x, y)
        }
    }

    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Add 1 to x * y if x % y > 0. Note this will
            // return 0 instead of reverting if y is zero.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
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

// src/interfaces/loans/ILoanManager.sol

/// @title Multi Source Loan Interface
/// @author Florida St
/// @notice A multi source loan is one with multiple tranches.
interface ILoanManager {
    /// @notice Validate an offer. Can only be called by an accepted caller.
    /// @param _offer The offer to validate.
    /// @param _protocolFee The protocol fee.
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external;

    /// @notice Called on loan repayment.
    /// @param _loanId The loan id.
    /// @param _principalAmount The principal amount.
    /// @param _apr The APR.
    /// @param _accruedInterest The accrued interest.
    /// @param _protocolFee The protocol fee.
    /// @param _startTime The start time.
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external;

    /// @notice Called on loan liquidation.
    /// @param _loanId The loan id.
    /// @param _principalAmount The principal amount.
    /// @param _apr The APR.
    /// @param _accruedInterest The accrued interest.
    /// @param _protocolFee The protocol fee.
    /// @param _received The received amount (from liquidation proceeds)
    /// @param _startTime The start time.
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external;
}

// src/interfaces/loans/ILoanManagerRegistry.sol

/// @title Interface Loan Manager Registry
/// @author Florida St
/// @notice Interface for a Loan Manager Registry.
interface ILoanManagerRegistry {
    /// @notice Add a loan manager to the registry
    /// @param _loanManager Address of the loan manager
    function addLoanManager(address _loanManager) external;

    /// @notice Remove a loan manager from the registry
    /// @param _loanManager Address of the loan manager
    function removeLoanManager(address _loanManager) external;

    /// @notice Check if a loan manager is registered
    /// @param _loanManager Address of the loan manager
    /// @return True if the loan manager is registered
    function isLoanManager(address _loanManager) external view returns (bool);
}

// src/lib/InputChecker.sol

/// @title InputChecker
/// @author Florida St
/// @notice Some basic input checks.
abstract contract InputChecker {
    error AddressZeroError();

    function _checkAddressNotZero(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressZeroError();
        }
    }
}

// lib/solmate/src/utils/SafeTransferLib.sol

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "from" argument.
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) // Append and mask the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument. Masking not required as it's a full 32 byte type.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}

// src/lib/loans/WithLoanManagers.sol

abstract contract WithLoanManagers is Owned {
    mapping(address => bool) internal _loanManagers;

    event LoanManagerAdded(address loanManagerAdded);
    event LoanManagerRemoved(address loanManagerRemoved);

    constructor() Owned(tx.origin) {}

    function addLoanManager(address _loanManager) external onlyOwner {
        _loanManagers[_loanManager] = true;

        emit LoanManagerAdded(_loanManager);
    }

    function removeLoanManager(address _loanManager) external onlyOwner {
        _loanManagers[_loanManager] = false;

        emit LoanManagerRemoved(_loanManager);
    }

    function isLoanManager(address _loanManager) external view returns (bool) {
        return _loanManagers[_loanManager];
    }
}

// src/lib/utils/TwoStepOwned.sol

/// @title TwoStepOwned
/// @author Florida St
/// @notice This contract is used to transfer ownership of a contract in two steps.
abstract contract TwoStepOwned is Owned {
    event TransferOwnerRequested(address newOwner);

    error TooSoonError();
    error InvalidInputError();

    uint256 public MIN_WAIT_TIME;

    address public pendingOwner;
    uint256 public pendingOwnerTime;

    constructor(address _owner, uint256 _minWaitTime) Owned(_owner) {
        pendingOwnerTime = type(uint256).max;
        MIN_WAIT_TIME = _minWaitTime;
    }

    /// @notice First step transferring ownership to the new owner.
    /// @param _newOwner The address of the new owner.
    function requestTransferOwner(address _newOwner) external onlyOwner {
        pendingOwner = _newOwner;
        pendingOwnerTime = block.timestamp;

        emit TransferOwnerRequested(_newOwner);
    }

    /// @notice Second step transferring ownership to the new owner.
    /// @param newOwner The address of the new owner.
    function transferOwnership(address newOwner) public override onlyOwner {
        if (pendingOwnerTime + MIN_WAIT_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (pendingOwner != newOwner) {
            revert InvalidInputError();
        }
        owner = newOwner;
        pendingOwner = address(0);
        pendingOwnerTime = type(uint256).max;

        emit OwnershipTransferred(owner, newOwner);
    }
}

// src/interfaces/ILoanLiquidator.sol

/// @title Liquidates Collateral for Defaulted Loans
/// @author Florida St
/// @notice It liquidates collateral corresponding to defaulted loans
///         and sends back the proceeds to the loan contract for distribution.
interface ILoanLiquidator {
    /// @notice Given a loan, it takes posession of the NFT and liquidates it.
    /// @param _loanId The loan id.
    /// @param _contract The loan contract address.
    /// @param _tokenId The NFT id.
    /// @param _asset The asset address.
    /// @param _duration The liquidation duration.
    /// @param _originator The address that trigger the liquidation.
    /// @return encodedAuction Encoded struct.
    function liquidateLoan(
        uint256 _loanId,
        address _contract,
        uint256 _tokenId,
        address _asset,
        uint96 _duration,
        address _originator
    ) external returns (bytes memory);
}

// src/interfaces/loans/IBaseLoan.sol

/// @title Interface for Loans.
/// @author Florida St
/// @notice Basic Loan
interface IBaseLoan {
    /// @notice Minimum improvement (in BPS) required for a strict improvement.
    /// @param principalAmount Minimum delta of principal amount.
    /// @param interest Minimum delta of interest.
    /// @param duration Minimum delta of duration.
    struct ImprovementMinimum {
        uint256 principalAmount;
        uint256 interest;
        uint256 duration;
    }

    /// @notice Arbitrary contract to validate offers implementing `IBaseOfferValidator`.
    /// @param validator Address of the validator contract.
    /// @param arguments Arguments to pass to the validator.
    struct OfferValidator {
        address validator;
        bytes arguments;
    }

    /// @notice Total number of loans issued by this contract.
    function getTotalLoansIssued() external view returns (uint256);

    /// @notice Cancel offer for `msg.sender`. Each lender has unique offerIds.
    /// @param _offerId Offer ID.
    function cancelOffer(uint256 _offerId) external;

    /// @notice Cancell all offers with offerId < _minOfferId
    /// @param _minOfferId Minimum offer ID.
    function cancelAllOffers(uint256 _minOfferId) external;

    /// @notice Cancel renegotiation offer. Similar to offers.
    /// @param _renegotiationId Renegotiation offer ID.
    function cancelRenegotiationOffer(uint256 _renegotiationId) external;
}

// src/interfaces/loans/IMultiSourceLoan.sol

/// @title Multi Source Loan Interface
/// @author Florida St
/// @notice A multi source loan is one with multiple tranches.
interface IMultiSourceLoan {
    /// @notice Borrowers receive offers that are then validated.
    /// @dev Setting the nftCollateralTokenId to 0 triggers validation through `validators`.
    /// @param offerId Offer ID. Used for canceling/setting as executed.
    /// @param lender Lender of the offer.
    /// @param fee Origination fee.
    /// @param capacity Capacity of the offer.
    /// @param nftCollateralAddress Address of the NFT collateral.
    /// @param nftCollateralTokenId NFT collateral token ID.
    /// @param principalAddress Address of the principal.
    /// @param principalAmount Principal amount of the loan.
    /// @param aprBps APR in BPS.
    /// @param expirationTime Expiration time of the offer.
    /// @param duration Duration of the loan in seconds.
    /// @param maxSeniorRepayment Max amount of senior capital ahead (principal + interest).
    /// @param validators Arbitrary contract to validate offers implementing `IBaseOfferValidator`.
    struct LoanOffer {
        uint256 offerId;
        address lender;
        uint256 fee;
        uint256 capacity;
        address nftCollateralAddress;
        uint256 nftCollateralTokenId;
        address principalAddress;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
        uint256 maxSeniorRepayment;
        IBaseLoan.OfferValidator[] validators;
    }

    /// @notice Offer + how much will be filled (always <= principalAmount).
    /// @param offer Offer.
    /// @param amount Amount to be filled.
    struct OfferExecution {
        LoanOffer offer;
        uint256 amount;
        bytes lenderOfferSignature;
    }

    /// @notice Offer + necessary fields to execute a specific loan. This has a separate expirationTime to avoid
    /// someone holding an offer and executing much later, without the borrower's awareness.
    /// @param offerExecution List of offers to be filled and amount for each.
    /// @param tokenId NFT collateral token ID.
    /// @param amount The amount the borrower is willing to take (must be <= _loanOffer principalAmount)
    /// @param expirationTime Expiration time of the signed offer by the borrower.
    /// @param callbackData Data to pass to the callback.
    struct ExecutionData {
        OfferExecution[] offerExecution;
        uint256 tokenId;
        uint256 duration;
        uint256 expirationTime;
        address principalReceiver;
        bytes callbackData;
    }

    /// @param executionData Execution data.
    /// @param borrower Address that owns the NFT and will take over the loan.
    /// @param borrowerOfferSignature Signature of the offer (signed by borrower).
    /// @param callbackData Whether to call the afterPrincipalTransfer callback
    struct LoanExecutionData {
        ExecutionData executionData;
        address borrower;
        bytes borrowerOfferSignature;
    }

    /// @param loanId Loan ID.
    /// @param callbackData Whether to call the afterNFTTransfer callback
    /// @param shouldDelegate Whether to delegate ownership of the NFT (avoid seaport flags).
    struct SignableRepaymentData {
        uint256 loanId;
        bytes callbackData;
        bool shouldDelegate;
    }

    /// @param loan Loan.
    /// @param borrowerLoanSignature Signature of the loan (signed by borrower).
    struct LoanRepaymentData {
        SignableRepaymentData data;
        Loan loan;
        bytes borrowerSignature;
    }

    /// @notice Tranches have different seniority levels.
    /// @param loanId Loan ID.
    /// @param floor Amount of principal more senior to this tranche.
    /// @param principalAmount Total principal in this tranche.
    /// @param lender Lender for this given tranche.
    /// @param accruedInterest Accrued Interest.
    /// @param startTime Start Time. Either the time at which the loan initiated / was refinanced.
    /// @param aprBps APR in basis points.
    struct Tranche {
        uint256 loanId;
        uint256 floor;
        uint256 principalAmount;
        address lender;
        uint256 accruedInterest;
        uint256 startTime;
        uint256 aprBps;
    }

    /// @dev Principal Amount is equal to the sum of all tranches principalAmount.
    /// We keep it for caching purposes. Since we are not saving this on chain but the hash,
    /// it does not have a huge impact on gas.
    /// @param borrower Borrower.
    /// @param nftCollateralTokenId NFT Collateral Token ID.
    /// @param nftCollateralAddress NFT Collateral Address.
    /// @param principalAddress Principal Address.
    /// @param principalAmount Principal Amount.
    /// @param startTime Start Time.
    /// @param duration Duration.
    /// @param tranche Tranches.
    /// @param protocolFee Protocol Fee.
    struct Loan {
        address borrower;
        uint256 nftCollateralTokenId;
        address nftCollateralAddress;
        address principalAddress;
        uint256 principalAmount;
        uint256 startTime;
        uint256 duration;
        Tranche[] tranche;
        uint256 protocolFee;
    }

    /// @notice Renegotiation offer.
    /// @param renegotiationId Renegotiation ID.
    /// @param loanId Loan ID.
    /// @param lender Lender.
    /// @param fee Fee.
    /// @param trancheIndex Tranche Indexes to be refinanced.
    /// @param principalAmount Principal Amount. If more than one tranche, it must be the sum.
    /// @param aprBps APR in basis points.
    /// @param expirationTime Expiration Time.
    /// @param duration Duration.
    struct RenegotiationOffer {
        uint256 renegotiationId;
        uint256 loanId;
        address lender;
        uint256 fee;
        uint256[] trancheIndex;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
    }

    event LoanLiquidated(uint256 loanId);
    event LoanEmitted(uint256 loanId, uint256[] offerId, Loan loan, uint256 fee);
    event LoanRefinanced(uint256 renegotiationId, uint256 oldLoanId, uint256 newLoanId, Loan loan, uint256 fee);
    event LoanRepaid(uint256 loanId, uint256 totalRepayment, uint256 fee);
    event LoanRefinancedFromNewOffers(
        uint256 loanId, uint256 newLoanId, Loan loan, uint256[] offerIds, uint256 totalFee
    );
    event TranchesMerged(Loan loan, uint256 minTranche, uint256 maxTranche);
    event DelegateRegistryUpdated(address newdelegateRegistry);
    event Delegated(uint256 loanId, address delegate, bool value);
    event FlashActionContractUpdated(address newFlashActionContract);
    event FlashActionExecuted(uint256 loanId, address target, bytes data);
    event RevokeDelegate(address delegate, address collection, uint256 tokenId);
    event MinLockPeriodUpdated(uint256 minLockPeriod);

    /// @notice Call by the borrower when emiting a new loan.
    /// @param _loanExecutionData Loan execution data.
    /// @return loanId Loan ID.
    /// @return loan Loan.
    function emitLoan(LoanExecutionData calldata _loanExecutionData) external returns (uint256, Loan memory);

    /// @notice Refinance whole loan (leaving just one tranche).
    /// @param _renegotiationOffer Offer to refinance a loan.
    /// @param _loan Current loan.
    /// @param _renegotiationOfferSignature Signature of the offer.
    /// @return loanId New Loan Id, New Loan.
    function refinanceFull(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);

    /// @notice Add a new tranche to a loan.
    /// @param _renegotiationOffer Offer for new tranche.
    /// @param _loan Current loan.
    /// @param _renegotiationOfferSignature Signature of the offer.
    /// @return loanId New Loan Id
    /// @return loan New Loan.
    function addNewTranche(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);

    /// @notice Merge tranches higher or equal than _minTranche and lower than _maxTranche.
    /// Lender merging must own all tranches in the tranches being merged.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @param _minTranche Min tranche.
    /// @param _maxTranche Max tranche.
    /// @return loanId New Loan Id
    /// @return loan New Loan.
    function mergeTranches(uint256 _loanId, Loan memory _loan, uint256 _minTranche, uint256 _maxTranche)
        external
        returns (uint256, Loan memory);

    /// @notice Refinance a loan partially. It can only be called by the new lender
    /// (they are always a strict improvement on apr).
    /// @param _renegotiationOffer Offer to refinance a loan partially.
    /// @param _loan Current loan.
    /// @return loanId New Loan Id, New Loan.
    /// @return loan New Loan.
    function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)
        external
        returns (uint256, Loan memory);

    /// @notice Refinance a loan from LoanExecutionData. We let borrowers use outstanding offers for new loans
    ///         to refinance their current loan.
    /// @param _loanId Loan ID.
    /// @param _loan Current loan.
    /// @param _loanExecutionData Loan Execution Data.
    /// @return loanId New Loan Id.
    /// @return loan New Loan.
    function refinanceFromLoanExecutionData(
        uint256 _loanId,
        Loan calldata _loan,
        LoanExecutionData calldata _loanExecutionData
    ) external returns (uint256, Loan memory);

    /// @notice Repay loan. Interest is calculated pro-rata based on time. Lender is defined by nft ownership.
    /// @param _repaymentData Repayment data.
    function repayLoan(LoanRepaymentData calldata _repaymentData) external;

    /// @notice Call when a loan is past its due date.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @return Liquidation Struct of the liquidation.
    function liquidateLoan(uint256 _loanId, Loan calldata _loan) external returns (bytes memory);

    /// @return getMaxTranches Maximum number of tranches per loan.
    function getMaxTranches() external view returns (uint256);

    /// @notice Set min lock period (in BPS).
    /// @param _minLockPeriod Min lock period.
    function setMinLockPeriod(uint256 _minLockPeriod) external;

    /// @notice Get min lock period (in BPS).
    /// @return minLockPeriod Min lock period.
    function getMinLockPeriod() external view returns (uint256);

    /// @notice Get delegation registry.
    /// @return delegateRegistry Delegate registry.
    function getDelegateRegistry() external view returns (address);

    /// @notice Update delegation registry.
    /// @param _newDelegationRegistry Delegation registry.
    function setDelegateRegistry(address _newDelegationRegistry) external;

    /// @notice Delegate ownership.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @param _rights Delegation Rights. Empty for all.
    /// @param _delegate Delegate address.
    /// @param _value True if delegate, false if undelegate.
    function delegate(uint256 _loanId, Loan calldata _loan, address _delegate, bytes32 _rights, bool _value) external;

    /// @notice Anyone can reveke a delegation on an NFT that's no longer in escrow.
    /// @param _delegate Delegate address.
    /// @param _collection Collection address.
    /// @param _tokenId Token ID.
    function revokeDelegate(address _delegate, address _collection, uint256 _tokenId) external;

    /// @notice Get Flash Action Contract.
    /// @return flashActionContract Flash Action Contract.
    function getFlashActionContract() external view returns (address);

    /// @notice Update Flash Action Contract.
    /// @param _newFlashActionContract Flash Action Contract.
    function setFlashActionContract(address _newFlashActionContract) external;

    /// @notice Get Loan Hash.
    /// @param _loanId Loan ID.
    /// @return loanHash Loan Hash.
    function getLoanHash(uint256 _loanId) external view returns (bytes32);

    /// @notice Transfer NFT to the flash action contract (expected use cases here are for airdrops and similar scenarios).
    /// The flash action contract would implement specific interactions with given contracts.
    /// Only the the borrower can call this function for a given loan. By the end of the transaction, the NFT must have
    /// been returned to escrow.
    /// @param _loanId Loan ID.
    /// @param _loan Loan.
    /// @param _target Target address for the flash action contract to interact with.
    /// @param _data Data to be passed to be passed to the ultimate contract.
    function executeFlashAction(uint256 _loanId, Loan calldata _loan, address _target, bytes calldata _data) external;

    /// @notice Called by the liquidator for accounting purposes.
    /// @param _loanId The id of the loan.
    /// @param _loan The loan object.
    function loanLiquidated(uint256 _loanId, Loan calldata _loan) external;
}

// src/interfaces/ILiquidationDistributor.sol

/// @title Liquidation Distributor
/// @author Florida St
/// @notice Given a liquidation. It distributes proceeds accordingly.
interface ILiquidationDistributor {
    /// @notice Called by the liquidator for accounting purposes.
    /// @param _repayment The highest bid of the auction.
    /// @param _loan The loan object.
    function distribute(uint256 _repayment, IMultiSourceLoan.Loan calldata _loan) external;
}

// src/lib/utils/Interest.sol

library Interest {
    using FixedPointMathLib for uint256;

    uint256 private constant _PRECISION = 10000;

    uint256 private constant _SECONDS_PER_YEAR = 31536000;

    function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {
        return _getInterest(_loanOffer.principalAmount, _loanOffer.aprBps, _loanOffer.duration);
    }

    function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {
        return _getInterest(_amount, _aprBps, _duration);
    }

    function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {
        uint256 owed = 0;
        for (uint256 i = 0; i < _loan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = _loan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + _getInterest(tranche.principalAmount, tranche.aprBps, _timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }
        return owed;
    }

    function _getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) private pure returns (uint256) {
        return _amount.mulDivUp(_aprBps * _duration, _PRECISION * _SECONDS_PER_YEAR);
    }
}

// src/lib/loans/LoanManager.sol

/// TODO: Documentation
abstract contract LoanManager is ILoanManager, InputChecker, TwoStepOwned {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct PendingCaller {
        address caller;
        bool isLoanContract;
    }

    /// @notice Time to wait before a new underwriter can be set.
    uint256 public immutable UPDATE_WAITING_TIME;

    /// @notice Pending accepted callers
    PendingCaller[] public getPendingAcceptedCallers;
    /// @notice Time when the pending accepted callers were set.
    uint256 public getPendingAcceptedCallersSetTime;
    /// @notice Set of accepted callers.
    EnumerableSet.AddressSet internal _acceptedCallers;
    /// @dev Keep this in a separate variable as well since we need the subset of loan contracts
    /// within acceptedCallers. Alternatively we could save this in a single struct but keep it
    /// this way for simplicity as we can use EnumerableSet.
    mapping(address => bool) internal _isLoanContract;
    /// @notice Underwriter contract
    address public getUnderwriter;
    /// @notice Pending underwriter contract.
    address public getPendingUnderwriter;
    /// @notice Time when the pending underwriter was set.
    uint256 public getPendingUnderwriterSetTime;

    event RequestCallersAdded(PendingCaller[] callers);
    event CallersAdded(PendingCaller[] callers);
    event PendingUnderwriterSet(address underwriter);
    event UnderwriterSet(address underwriter);

    error CallerNotAccepted();

    constructor(address _owner, address __underwriter, uint256 _updateWaitingTime)
        TwoStepOwned(_owner, _updateWaitingTime)
    {
        _checkAddressNotZero(__underwriter);

        getUnderwriter = __underwriter;
        UPDATE_WAITING_TIME = _updateWaitingTime;
        getPendingUnderwriterSetTime = type(uint256).max;
        getPendingAcceptedCallersSetTime = type(uint256).max;
    }

    modifier onlyAcceptedCallers() {
        if (!_acceptedCallers.contains(msg.sender)) {
            revert CallerNotAccepted();
        }
        _;
    }

    /// @notice First step in d a caller to the accepted callers list. Can be a Loan Contract or Liquidator.
    /// @param _callers The callers to add.
    function requestAddCallers(PendingCaller[] calldata _callers) external onlyOwner {
        getPendingAcceptedCallers = _callers;
        getPendingAcceptedCallersSetTime = block.timestamp;

        emit RequestCallersAdded(_callers);
    }

    /// @notice Second step in d a caller to the accepted callers list. Can be a Loan Contract or Liquidator.
    /// @dev Given repayments, we don't allow callers to be removed.
    /// @param _callers The callers to add.
    function addCallers(PendingCaller[] calldata _callers) external onlyOwner {
        if (getPendingAcceptedCallersSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        PendingCaller[] memory pendingCallers = getPendingAcceptedCallers;
        for (uint256 i = 0; i < _callers.length;) {
            PendingCaller calldata caller = _callers[i];
            if (pendingCallers[i].caller != caller.caller || pendingCallers[i].isLoanContract != caller.isLoanContract)
            {
                revert InvalidInputError();
            }
            _acceptedCallers.add(caller.caller);
            _isLoanContract[caller.caller] = caller.isLoanContract;

            afterCallerAdded(caller.caller);
            unchecked {
                ++i;
            }
        }

        emit CallersAdded(_callers);
    }

    /// @notice Check if a caller is accepted.
    /// @param _caller The caller to check.
    /// @return Whether the caller is accepted.
    function isCallerAccepted(address _caller) external view returns (bool) {
        return _acceptedCallers.contains(_caller);
    }

    /// @notice First step in settting the Underwriter contract.
    /// @param __underwriter The new underwriter address.
    function setUnderwriter(address __underwriter) external onlyOwner {
        _checkAddressNotZero(__underwriter);

        getPendingUnderwriter = __underwriter;
        getPendingUnderwriterSetTime = block.timestamp;

        emit PendingUnderwriterSet(__underwriter);
    }

    /// @notice Confirm the Underwriter contract.
    /// @param __underwriter The new Underwriter address.
    function confirmUnderwriter(address __underwriter) external onlyOwner {
        if (getPendingUnderwriterSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (getPendingUnderwriter != __underwriter) {
            revert InvalidInputError();
        }

        getUnderwriter = __underwriter;
        getPendingUnderwriter = address(0);
        getPendingUnderwriterSetTime = type(uint256).max;

        emit UnderwriterSet(__underwriter);
    }

    /// @notice Perform operations after a caller is added. I.e: ERC20s approvals.
    /// @param _caller The caller that was added.
    function afterCallerAdded(address _caller) internal virtual;

    /// @inheritdoc ILoanManager
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external virtual;

    /// @inheritdoc ILoanManager
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external virtual;

    /// @inheritdoc ILoanManager
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external virtual;
}

// src/lib/LiquidationDistributor.sol

/// @title Liquidation Distributor
/// @author Florida St
/// @notice Receives proceeds from a liquidation and distributes them based on tranches.
contract LiquidationDistributor is ILiquidationDistributor, ReentrancyGuard {
    using FixedPointMathLib for uint256;
    using Interest for uint256;
    using SafeTransferLib for ERC20;

    ILoanManagerRegistry public immutable getLoanManagerRegistry;

    /// @param _loanManagerRegistry The address of the LoanManagerRegistry
    constructor(address _loanManagerRegistry) {
        getLoanManagerRegistry = ILoanManagerRegistry(_loanManagerRegistry);
    }

    /// @inheritdoc ILiquidationDistributor
    function distribute(uint256 _proceeds, IMultiSourceLoan.Loan calldata _loan) external {
        uint256[] memory owedPerTranche = new uint256[](_loan.tranche.length);
        uint256 totalPrincipalAndPaidInterestOwed = _loan.principalAmount;
        uint256 totalPendingInterestOwed = 0;
        for (uint256 i = 0; i < _loan.tranche.length;) {
            IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
            uint256 pendingInterest =
                thisTranche.principalAmount.getInterest(thisTranche.aprBps, block.timestamp - thisTranche.startTime);
            totalPrincipalAndPaidInterestOwed += thisTranche.accruedInterest;
            totalPendingInterestOwed += pendingInterest;
            owedPerTranche[i] += thisTranche.principalAmount + thisTranche.accruedInterest + pendingInterest;
            unchecked {
                ++i;
            }
        }

        if (_proceeds > totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed) {
            for (uint256 i = 0; i < _loan.tranche.length;) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                _handleTrancheExcess(
                    _loan.principalAddress,
                    thisTranche,
                    msg.sender,
                    _proceeds,
                    totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed
                );
                unchecked {
                    ++i;
                }
            }
        } else {
            for (uint256 i = 0; i < _loan.tranche.length && _proceeds > 0;) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                _proceeds = _handleTrancheInsufficient(
                    _loan.principalAddress, thisTranche, msg.sender, _proceeds, owedPerTranche[i]
                );
                unchecked {
                    ++i;
                }
            }
        }
    }

    function _handleTrancheExcess(
        address _tokenAddress,
        IMultiSourceLoan.Tranche calldata _tranche,
        address _liquidator,
        uint256 _proceeds,
        uint256 _totalOwed
    ) private {
        uint256 excess = _proceeds - _totalOwed;
        /// Total = principal + accruedInterest +  pendingInterest + pro-rata remainder
        uint256 owed = _tranche.principalAmount + _tranche.accruedInterest
            + _tranche.principalAmount.getInterest(_tranche.aprBps, block.timestamp - _tranche.startTime);
        uint256 total = owed + excess.mulDivDown(owed, _totalOwed);
        _handleLoanManagerCall(_tranche, total);
        ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, total);
    }

    function _handleTrancheInsufficient(
        address _tokenAddress,
        IMultiSourceLoan.Tranche calldata _tranche,
        address _liquidator,
        uint256 _proceedsLeft,
        uint256 _trancheOwed
    ) private returns (uint256) {
        if (_proceedsLeft > _trancheOwed) {
            _handleLoanManagerCall(_tranche, _trancheOwed);
            ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _trancheOwed);
            _proceedsLeft -= _trancheOwed;
        } else {
            _handleLoanManagerCall(_tranche, _proceedsLeft);
            ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _proceedsLeft);
            _proceedsLeft = 0;
        }
        return _proceedsLeft;
    }

    function _handleLoanManagerCall(IMultiSourceLoan.Tranche calldata _tranche, uint256 _sent) private {
        if (getLoanManagerRegistry.isLoanManager(_tranche.lender)) {
            LoanManager(_tranche.lender).loanLiquidation(
                _tranche.loanId,
                _tranche.principalAmount,
                _tranche.aprBps,
                _tranche.accruedInterest,
                0,
                _sent,
                _tranche.startTime
            );
        }
    }
}

