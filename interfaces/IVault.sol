// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IOrderbookRouter.sol";

interface IVault {
    function initialize(address token,IOrderbookRouter orderbook) external;

    function trading(uint256 pid,bytes memory data) external;

}