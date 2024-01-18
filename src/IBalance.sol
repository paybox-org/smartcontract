// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IBalance{
         function scaledBalanceOf(address user) external view returns (uint256);
            
  function scaledTotalSupply() external view returns (uint256);
    function getRewardsByAsset(address asset) external view  returns (address[] memory);
      function getUserRewards(
    address[] calldata assets,
    address user,
    address reward
  ) external view  returns (uint256) ;

}

