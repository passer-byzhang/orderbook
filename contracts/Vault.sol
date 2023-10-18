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
import "./utils/SafeToken.sol";

contract Vault is ReentrancyGuardUpgradeable {

    IOracle public oracle;
    address public token;
    IWETH public weth;
    IOrderbookRouter public orderbook;
    uint256 lastPid;

    event PositionCreated(uint256 indexed pid, address indexed creator, address receiver, uint256 amount, address requestToken, uint256 timestamp);
    event PositionRemoved(uint256 indexed pid, address indexed creator, address receiver, uint256 amount, address requestToken, uint256 timestamp);
    event PositionDealed(uint256 indexed pid, address indexed creator, address receiver, uint256 amount, address requestToken, , address user , uint256 paymentAmount , uint256 timestamp);

    struct Position {
        address creator;
        address receiver;
        uint256 amount;
        address requestToken;
    }

    mapping(uint256 => Position) public positions;

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
            emit PositionCreated(lastPid, msg.sender, requestToken, amount, requestToken, block.timestamp);
        }else{
            Position memory position = positions[pid];
            position.amount = 0;
            positions[pid] = position;
            emit PositionRemoved(pid, msg.sender, position.receiver, position.amount, position.requestToken, block.timestamp);
            
        }
    }

    //购买，只有全单购买
    function trading(uint256 pid,bytes memory data) nonReentrant external {
        Position memory position = positions[pid];
        require(position.amount > 0, "Vault: POSITION_NOT_EXISTS");
        uint256 requestAmount = IOracle(oracle).getAmount(position.requestToken,token,position.amount);
        swap(position.requestToken, requestAmount, position.amount, position.receiver);
        position.amount = 0;
        positions[pid] = position;
        emit PositionDealed(pid, position.creator, position.receiver, position.amount, position.requestToken, msg.sender, requestAmount, block.timestamp);
    }

    function swap(address tokenTo /*付款token*/, uint256 amountTo /*付款数目*/, uint256 amountFrom /*订单数目*/, address to /*收款人*/) internal {
        SafeToken.safeTransferFrom(tokenTo, msg.sender, to, amountTo);
        SafeToken.safeTransfer(token, msg.sender,amountFrom);
    }
}