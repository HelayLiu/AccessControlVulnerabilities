// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

interface IMigrationPool {
    function migrateFromStaking(
        address account,
        address pool,
        uint256 amount,
        uint256 depositLockStart,
        uint256 lockPeriod,
        uint256 unclaimedReward
    ) external;
}
