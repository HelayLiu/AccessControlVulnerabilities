// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IERC20.sol";

// Base V1 Fees contract is used as a 1:1 pair relationship to split out fees, this ensures that the curve does not need to be modified for LP shares
contract LeetSwapV2Fees {
    address internal immutable pair; // The pair it is bonded to
    address internal immutable token0; // token0 of pair, saved localy and statically for gas optimization
    address internal immutable token1; // Token1 of pair, saved localy and statically for gas optimization

    error InvalidToken();
    error TransferFailed();
    error Unauthorized();

    constructor(address _token0, address _token1) {
        pair = msg.sender;
        token0 = _token0;
        token1 = _token1;
    }

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        if (token.code.length == 0) revert InvalidToken();
        bool success = IERC20(token).transfer(to, value);
        if (!success) revert TransferFailed();
    }

    // Allow the pair to transfer fees to users
    function claimFeesFor(
        address recipient,
        uint256 amount0,
        uint256 amount1
    ) external {
        if (msg.sender != pair) revert Unauthorized();
        if (amount0 > 0) _safeTransfer(token0, recipient, amount0);
        if (amount1 > 0) _safeTransfer(token1, recipient, amount1);
    }
}