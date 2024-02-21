// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";
import {multiSignWallet} from "../src/multiSignWallet.sol";

contract multiSignWalletTest is Test {
    multiSignWallet public multiSign;
    Counter public counter;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address tom = makeAddr("tom");
    address david = makeAddr("david");

    function setUp() public {
        deal(david, 10000000 ether);
        vm.startPrank(admin);
        {
            multiSign = new multiSignWallet();
            counter = new Counter();

        }
        vm.stopPrank();
    }

    function testMultiSignWallet() public {
        bool result;
        vm.startPrank(admin);
        {
            multiSign.setOwner(alice);
            multiSign.setOwner(bob);
            multiSign.setOwner(tom);
            bytes memory data = abi.encodeWithSignature("setNumber(uint256)",666);
            multiSign.submitTransaction(address(counter),data,0,2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
            multiSign.confirmTransaction(0);
        }
        vm.stopPrank();
        vm.startPrank(bob);
        {
            multiSign.confirmTransaction(0);
        }
        vm.stopPrank();
        vm.startPrank(david);
        {
            result = multiSign.executeTransaction(0);
        }
        assertEq(counter.getNumber(),666);
        assertEq(result,false);
    }

}