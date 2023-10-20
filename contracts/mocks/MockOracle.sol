// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import '../../interfaces/IOracle.sol';

contract MockOracle is IOracle {

    function getAmount(address tokenIn,address tokenOut,uint256 amountOut) external returns (uint256 amountIn){
        return amountOut + block.timestamp%2;
    }

}