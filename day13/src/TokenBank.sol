// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";

contract TokenBank{
    mapping(address => uint) public deposited;
    address public token;
    constructor(address _token) {
        token = _token;        
    }

    function deposit(address account,uint256 amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        deposited[account] += amount;
    }

    function permitDeposit(address user, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
        deposit(user, amount);
    }

    function tokensReceived(address sender, uint amount) external returns (bool) {
        require(msg.sender == token, "invalid");
        deposited[sender] += amount;
        return true;
    }



}