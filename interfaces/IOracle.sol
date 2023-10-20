// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOracle {
    function getAmount(address tokenIn,address tokenOut,uint256 amountOut) external returns (uint256 amountIn);
}