// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IBalance {
    function scaledBalanceOf(address user) external view returns (uint256);

    function scaledTotalSupply() external view returns (uint256);

    function getRewardsData(
        address asset,
        address user
    ) external view returns (uint104, uint88, uint32, uint32);

    function getRewardsByAsset(
        address asset
    ) external view returns (address[] memory);

    function getUserRewards(
        address[] calldata assets,
        address user,
        address reward
    ) external view returns (uint256);

    function getUserAccountData(
        address user
    )
        external
        view
        returns (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        );
}
