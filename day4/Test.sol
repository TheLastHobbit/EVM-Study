// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank4{
    mapping(address => uint256) public balances;
    address private owner;

    event Deposit(address indexed sender, uint256 amount, uint256 balance);
    event Withdraw(address indexed sender, address account, uint256 balance);

    constructor(){
        owner = msg.sender;
    }

    modifier smaValue(){
        require(msg.value >= 0.001 ether,"You need at least 0.001 ether");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"You are not the owner");
        _;
    }

    error NotOwner();


    function deposit() public smaValue payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 _amount) public {
        if (msg.sender!=owner)revert NotOwner();
        require(balances[msg.sender] >= _amount,"You don't have enough ether");
        payable(msg.sender).call{value: _amount}("");
        balances[msg.sender] -= _amount;
        emit Withdraw(address(this),msg.sender,_amount);
    }

        










}