// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IOracle {
    function getPrize(address token) external returns (uint256);
    function getAmount(address tokenIn,address tokenOut,uint256 amountOut) external returns (uint256 amountIn);
}