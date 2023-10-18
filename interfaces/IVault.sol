// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IVault {
    function initialize(address token,address oracle,address orderbook,address weth) external;

    function trading(uint256 pid,bytes memory data) external;

}