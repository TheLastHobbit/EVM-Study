//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console} from "forge-std/Test.sol";

import "../src/JCDao/Dao.sol";
import "../src/JCDao/JCGovern.sol";
import "../src/JCDao/JCGovernImp.sol";
import "../src/JCDao/JCToken.sol";
import "../src/JCDao/TimeLock.sol";

contract JCDaoTest is Test {
    address public owner;
    address public alice;
    address public bob;
    address public david;
    address public lucy;

    address public delegatee1;
    address public delegatee2;
    address public delegatee3;

    JCDao public dao;
    JCGovern public govern;
    JCGovernImp public governImp;
    JCToken public token;
    TimeLock public timelock;

    function setUp() public {
        owner = makeAddr("owner");
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        david = makeAddr("david");
        lucy = makeAddr("lucy");

        delegatee1 = makeAddr("delegatee1");
        delegatee2 = makeAddr("delegatee2");
        delegatee3 = makeAddr("delegator3");

        deal(owner, 10000 ether);
        deal(alice, 10000 ether);
        deal(bob, 10000 ether);
        deal(david, 10000 ether);
        deal(lucy, 10000 ether);

        vm.startPrank(owner);
        {
            token = new JCToken();
            dao = new JCDao(owner, address(token));
            governImp = new JCGovernImp();
            timelock = new TimeLock(owner, 20);
            govern = new JCGovern(
                address(dao),
                address(timelock),
                address(token),
                address(governImp),
                20,
                10
            );

            token.setDao(address(dao));
            timelock.setAdmin(address(govern));
            dao.setTimeLock(address(timelock));
            dao.setAdmin(alice);
            dao.addMember(alice);
            dao.addMember(bob);
            dao.addMember(david);
            dao.addMember(lucy);
            dao.addMember(owner);

            dao.contribute{value: 200 ether}();
        }
        vm.stopPrank();

        vm.startPrank(alice);
        {
            dao.contribute{value: 100 ether}();
        }
        vm.stopPrank();
        vm.startPrank(bob);
        {
            dao.contribute{value: 100 ether}();
        }
        vm.stopPrank();
        vm.startPrank(lucy);
        {
            dao.contribute{value: 100 ether}();
        }
        vm.stopPrank();
        vm.startPrank(david);
        {
            dao.contribute{value: 100 ether}();
        }
        vm.stopPrank();
    }

    address[] targets;
    uint[] values;
    string[] signatures;
    bytes[] calldatas;
    string description;

    function test() public {
        vm.startPrank(alice);
        {
            bytes memory dataP = abi.encodeWithSignature(
                "withdraw(address,uint256)",
                bob,
                100 ether
            );

            targets.push(address(dao));
            values.push(0);
            signatures.push("");
            calldatas.push(dataP);
            description = "Test proposal";

            bytes memory dataG = abi.encodeWithSignature(
                "propose(address[],uint256[],string[],bytes[],string)",
                targets,
                values,
                signatures,
                calldatas,
                description
            );
            address(govern).call{value: 100}(dataG);

            // 委托
            token.delegate(delegatee1);
        }
        vm.stopPrank();

        vm.roll(11);
        //委托代理
        vm.startPrank(bob);
        {
            token.delegate(delegatee1);
        }
        vm.stopPrank();

        vm.startPrank(owner);
        {
            token.delegate(delegatee2);
        }
        vm.stopPrank();
        vm.startPrank(david);
        {
            token.delegate(delegatee2);
        }
        vm.stopPrank();
        vm.startPrank(lucy);
        {
            token.delegate(delegatee3);
        }
        vm.stopPrank();

        vm.roll(21);

        //代理投票
        vm.startPrank(delegatee1);
        {
            bytes memory data = abi.encodeWithSignature(
                "castVote(uint256,uint8)",
                1,
                0
            );
            address(govern).call(data);
        }
        vm.stopPrank();
        vm.startPrank(delegatee2);
        {
            bytes memory data = abi.encodeWithSignature(
                "castVote(uint256,uint8)",
                1,
                1
            );
            address(govern).call(data);
        }
        vm.stopPrank();
        vm.startPrank(delegatee3);
        {
            bytes memory data = abi.encodeWithSignature(
                "castVote(uint256,uint8)",
                1,
                2
            );
            address(govern).call(data);
        }
        vm.stopPrank();

        vm.roll(32);

        // 将提案加入执行队列（谁来执行都无所谓）
        vm.startPrank(owner);
        {
            bytes memory data = abi.encodeWithSignature("queue(uint256)", 1);
            address(govern).call(data);
        }
        vm.stopPrank();

        // 执行提案
        //必须等20个区块的delay时间过了
        vm.roll(53);
        //先记录bob之前的余额：
        uint beginBalance = bob.balance;
        vm.startPrank(owner);
        {
            bytes memory data = abi.encodeWithSignature("execute(uint256)", 1);
            address(govern).call{value:100}(data);
        }
        vm.stopPrank();

        // 检查提案是否成功执行
        vm.roll(54);
        assertEq(bob.balance,beginBalance+100 ether);
        console.log("proposal success!");
    }
}
