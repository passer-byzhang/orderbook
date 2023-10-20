// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IVault.sol";
import "../interfaces/IWETH.sol";
import "../interfaces/IOrderbookRouter.sol";
import "./Vault.sol";

contract OrderBookRouter is IOrderbookRouter, ReentrancyGuardUpgradeable, OwnableUpgradeable {

    mapping(address => address) public getVault;
    
    address[] public allVaults;

    event VaultCreated(address indexed token, address indexed vault, uint);

    IOracle public oracle;

    function initialize(
        IOracle _oracle
    ) external initializer {
        OwnableUpgradeable.__Ownable_init(msg.sender);
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        oracle = _oracle;
    }

    function createVault(address token) nonReentrant external returns (address vault) {
        require(token != address(0), 'OrderBook: ZERO_ADDRESS');
        require(getVault[token] == address(0), 'OrderBook: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(Vault).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token));
        assembly {
            vault := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IVault(vault).initialize(token, IOrderbookRouter(address(this)));
        getVault[token] = vault; // populate mapping in the reverse direction
        allVaults.push(vault);
        emit VaultCreated(token, vault, allVaults.length);
    }

}