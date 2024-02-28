// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract MyBank{
    mapping(address account=> uint256) private _balance;
    address[3] private topThree;

    event Deposit(address account,uint256 value);

    event Withdraw(uint256 value);

    address private admin;
    constructor(){
        admin = msg.sender; 
    }


    // receive() external payable { 
    //     require(msg.value>0,"Your value must more than zero!");
    //     _balance[msg.sender] += msg.value;
    //     updatetopthree(msg.sender);
    //     emit Deposit(msg.sender, msg.value);
    // }

    function deposit() external payable{
        require(msg.value>0,"Your value must more than zero!");
        _balance[msg.sender] += msg.value;
        updatetopthree(msg.sender);
        emit Deposit(msg.sender, msg.value);
    }

   
    function withdraw() external{
        require(msg.sender == admin,"only admin");
        uint256 amount =address(this).balance;
        payable(msg.sender).transfer(amount);
        _balance[msg.sender] = amount;
        emit Withdraw(amount);
    }

    function getBalance(address account) public view returns(uint256){
        return _balance[account];
    }

    function getTopthree()external view returns(address[3] memory){
        return topThree;

    }


    function updatetopthree(address user) private {
        if (_balance[user] > _balance[topThree[0]]) {
            topThree[2] = topThree[1];
            topThree[1] = topThree[0];
            topThree[0] = user;
        } else if (_balance[user] > _balance[topThree[1]]) {
            topThree[2] = topThree[1];
            topThree[1] = user;
        } else if (_balance[user] > _balance[topThree[2]]) {
            topThree[2] = user;
        }
        
    }

}