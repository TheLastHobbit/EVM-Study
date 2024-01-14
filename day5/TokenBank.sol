// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IMyToken.sol";

contract TokenBank {
    mapping (address account=>uint256) private _balance;
    address private admin;
    IMyToken public  imytoken; 

    event Deposit(address account,uint256 value);

    event WithDraw(uint256 value);

    constructor(IMyToken _imytoken){
        imytoken = _imytoken;
        admin = msg.sender;
    }

// 注意要先approve给Bank
    function deposit(uint256 value) external {
        address account = msg.sender;
        require(imytoken.transferfrom(account, address(this), value),"transfer failed");
        _balance[account] += value;
        emit Deposit(account, value);
    }

    function withDraw() external {
        require(msg.sender==admin);
        uint256 account= address(this).balance;
        require(imytoken.transfer(msg.sender, account));
        _balance[msg.sender] = 0;
        emit WithDraw(account);
    }

    function getbalance(address account) external view returns(uint256){
        return _balance[account];
    }
    
}