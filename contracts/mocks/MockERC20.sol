// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MockERC20 is ERC20Upgradeable, OwnableUpgradeable {
  
  function initialize(
    string calldata _name,
    string calldata _symbol
  ) external initializer {
    OwnableUpgradeable.__Ownable_init(msg.sender);
    ERC20Upgradeable.__ERC20_init(_name, _symbol);
  }

  function mint(address account,uint256 amountToken) external {
    _mint(account,amountToken );
  }

}