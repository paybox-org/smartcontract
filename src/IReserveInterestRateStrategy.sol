// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;



interface IReserveInterestRateStrategy {
        struct CalculateInterestRatesParams {
        address reserve;
        address aToken;
        uint256 totalStableDebt;
        uint256 totalVariableDebt;
        uint256 liquidityAdded;
        uint256 liquidityTaken;
        uint256 unbacked;
        uint256 averageStableBorrowRate;
        uint256 reserveFactor;
    }
    
    function calculateInterestRates(CalculateInterestRatesParams memory params)
        external
        view
        returns (uint256, uint256, uint256);
}