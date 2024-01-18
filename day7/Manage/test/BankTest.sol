// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "src/Bank.sol";

contract BankTest is Test {
    MyBank public bank;
    address public owner;
    address public user1;
    address public user2;



    function setUp() public {
        vm.startPrank(owner);
        {
        bank = new MyBank();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        }
        vm.stopPrank();
    }

    function testDepositFuzz(uint256 count) public {
        vm.assume(count > 0 ether);
        deposit(user1, count);

    }

    function deposit (address user, uint256 amount) public{
        deal(user, amount);
        vm.prank(user);
        
        uint256 beforebalance = address(bank).balance;
        console.log("Before balance:", beforebalance);
        bank.deposit{value: amount}();
        assertEq(bank.getBalance(user), amount);
        assertEq(address(bank).balance, beforebalance+amount);
        console.log("Deposit successful");
    }

    function test_withdrawFuzz(uint256 amount) public {
        vm.assume(amount > 0 ether);
        deposit(user1, amount);
        uint256 balanceBefore = owner.balance;
        console.log("bank before banlance:",address(bank).balance);
        vm.startPrank(owner);
        {
        bank.withdraw();
        }
        vm.stopPrank();
        console.log("bank later banlance:",address(bank).balance);
        assertEq(owner.balance, balanceBefore+amount);
        console.log("Deposit successful");
    }   
        
}
        

