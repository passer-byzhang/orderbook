// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IVault.sol"
import "../interfaces/IWETH.sol"

contract OrderBookRouter is ReentrancyGuardUpgradeable, OwnableUpgradeable {

    IOracle public oracle;
    IWETH public weth;

    address public USER;

    mapping(address => address) public getVault;
    address[] public allVaults;

    event VaultCreated(address indexed token, address indexed vault, uint);

    modifier inExec() {
        require(USER != address(0), "OrderBookRouter: IN_EXEC");
        USER = msg.sender;
        _;
        USER = address(0);
    }

    function initialize(
        IOracle _oracle,
        IWETH _weth
    ) external initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        oracle = _oracle;
        weth = _weth;
    }

    function createVault(address tokenA,address tokenB) nonReentrant external returns (address pair) {
        require(token != address(0), 'OrderBook: ZERO_ADDRESS');
        require(getVault[token] == address(0), 'OrderBook: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(IVault).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token));
        assembly {
            vault := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IVault(vault).initialize(token, oracle,address(this));
        getVault[token] = vault; // populate mapping in the reverse direction
        allVaults.push(vault);
        emit VaultCreated(token, vault, allVaults.length);
    }

    //交易调用资金库
    function trading(IVault vault, uint256 pid,bytes data) inExec nonReentrant payable external {
        vault.trading(pid,data);
    }

    //付款函数，保证每次操作只需要给一个合约授权
    function requestFund(address token,address amount) external {
        if (msg.value != 0) {
            require(token == weth, "Token is not wNative");
            require(amount == msg.value, "value != msg.value");
            IWETH(config.getWrappedNativeAddr()).deposit{ value: msg.value }();
            SafeToken.safeTransfer(token, msg.sender, amount);
        }else{
            SafeToken.safeTransferFrom(token, USER, msg.sender, amount);
        }
    }

}