// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interfaces/IOracle.sol";
import "../interfaces/IVault.sol"
import "../interfaces/IWETH.sol"
import "../interfaces/IOracle.sol";
import "../interfaces/IOrderbookRouter.sol";

contract Vault is ReentrancyGuardUpgradeable {

    IOracle public oracle;
    address public token;
    IWETH public weth;
    IOrderbookRouter public orderbook;
    uint256 lastPid;

    struct Position {
        address creator;
        address receiver;
        uint256 amount;
        address requestToken;
    }

    mapping(address => Position) public positions;

    function initialize(
        address _token,
        IOrderbookRouter _orderbook
    ) external initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        orderbook = _orderbook;
        token = _token;
        oracle = orderbook.oracle();
        weth = orderbook.weth();
    }

    //开关调仓
    function dealPosition(uint256 pid,uint256 amount,address requestToken,address user) nonReentrant external {
        if(pid==0){
            orderbook.requestFund(token,requestAmount);
            lastPid++;
            positions[lastPid] = Position(amount,requestToken);
        }else{
            Position memory position = positions[pid];
            require(position.creater==user,"Vault: Can't access");
            orderbook.requestFund(token,requestAmount);
            if(amount>position.amount){
                orderbook.requestFund(token,amount);
                position.amount = position.amount + amount;
            }else{
                position.amount = position.amount - amount;
                returnFund(token,position.amount - amount,position.creator);
            }

    }

    //购买，只有全单购买
    function trading(uint256 pid,bytes memory data) nonReentrant external {
        Position memory position = positions[pid];
        require(position.amount > 0, "Vault: POSITION_NOT_EXISTS");
        uint256 requestAmount = IOracle(oracle).getAmount(position.requestToken,token,position.amount);
        orderbook.requestFund(position.requestToken,requestAmount);
        returnFund(position.requestToken,requestAmount,position.receiver);
        ERC20Upgradeable(position.requestToken).transfer(position.receiver, _amount);
        ERC20Upgradeable(token).transfer(_receiver, position.amount);
        position.amount = 0;
        positions[pid] = position;
    }

    //给挂单者发款项
    function returnFund(address _token,address _amount,address _receiver) internal {
        if (msg.value != 0) {
            require(_token == weth, "Token is not wNative");
            weth.withdraw(_amount);
            (bool success,) = receiver.call{value: _amount}("");
            require(success, "ETH transfer failed.");
        } else {
            ERC20Upgradeable(_token).transfer(_receiver, _amount);
        }
    }
}