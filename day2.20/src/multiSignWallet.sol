// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";
contract multiSignWallet{

    address[] private owners;
    Transaction[] private transactions;

    mapping(uint256 txIndex => Transaction) private indexTotransaction;

    mapping(address => bool) private isOwner;

    event SubmitTransaction(address indexed transactionSender, address indexed to, uint256 amount, bytes data, uint256 threshold);

    struct Transaction{
        address to;
        bytes data;
        uint256 amount;
        bool executed;
        uint threshold;
        uint256 confirmNum;
    }
    address private admin;

    event Deposit(address indexed sender, uint256 amount, uint256 balance);

    modifier txExists(uint256 _txIndex){
        require(indexTotransaction[_txIndex].to != address(0), "Transaction does not exist");
        _;
    }
    constructor(){
        admin = msg.sender;
    }

    modifier onlyOwner(){
        require(isOwner[msg.sender] || msg.sender==admin, "You are not the owner");
        _;
    }

// 存钱
    receive() external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function setOwner(address _owner) public onlyOwner{
        require(_owner != address(0), "Invalid address");
        owners.push(_owner);
        isOwner[_owner] = true;
    }

    function getOwner() public view returns(address[] memory){
        return owners;
    }

    // 发起一个交易
    function submitTransaction(address _to, bytes memory _data, uint256 _amount, uint _threshold) public{
        require(_to != address(0), "Invalid address");
        require(_threshold > 0 && _threshold <= owners.length, "Invalid threshold");
        uint256 txIndex = transactions.length;
        console.log("txIndex",txIndex);
        transactions.push(Transaction({
            to: _to,
            data: _data,
            amount: _amount,
            executed: false,
            threshold: _threshold,
            confirmNum: 0
        }));
        indexTotransaction[txIndex] = transactions[txIndex];
        // event SubmitTransaction(address indexed transactionSender, address indexed to, uint256 amount, bytes data, uint256 threshold);
        emit SubmitTransaction(msg.sender,_to,_amount,_data, _threshold);
    }
        
    // 执行一个交易
    function executeTransaction(uint _txIndex) public returns(bool success){
        require(_checkTransaction(_txIndex),"not meet Threshold!");
        address to = indexTotransaction[_txIndex].to;
        uint amount = indexTotransaction[_txIndex].amount;
        bytes memory data = indexTotransaction[_txIndex].data;
        (bool sent,) = to.call{value: amount}(data);
        require(sent, "Failed to call:");
        console.log("excute success:",to);
        return true;
    }

    function confirmTransaction(uint _txIndex) public onlyOwner{
        // 确认交易
        indexTotransaction[_txIndex].confirmNum++;
    }

    // 设置门槛
    function setThreshold(uint _txIndex, uint _threshold) public onlyOwner{
        indexTotransaction[_txIndex].threshold = _threshold;
    }

    // 判断是否达到门槛
    function _checkTransaction(uint _txIndex) internal view returns(bool success){
        return indexTotransaction[_txIndex].confirmNum >= indexTotransaction[_txIndex].threshold;
    }
    // 获取交易信息
    function getTransactionInfo(uint _txIndex) public view returns(address to, uint amount, bytes memory data, uint confirmNum, uint threshold){
        console.log("getTransactionInfo:");
        return (indexTotransaction[_txIndex].to, indexTotransaction[_txIndex].amount, indexTotransaction[_txIndex].data, indexTotransaction[_txIndex].confirmNum, indexTotransaction[_txIndex].threshold);
    }

}