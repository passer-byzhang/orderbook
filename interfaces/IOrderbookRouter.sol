// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IOracle.sol";

interface IOrderbookRouter {

    function oracle() external view returns (IOracle);
    

}