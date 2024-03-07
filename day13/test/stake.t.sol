//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console2} from "forge-std/Test.sol";
import "../src/KKERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/stake/stakeManager.sol";

// 测试质押EGTH挖KK
contract stakeETHtest is Test {
    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public david = makeAddr("david");

    KKERC20 internal KK;
    stakeManager internal StakeManager;

        function setUp() public {
        deal(admin, 1000000000000 ether);
        deal(alice, 1000000000000 ether);
        deal(david, 1000000000000 ether);
        vm.startPrank(admin);
        {
            KK = new KKERC20();
            StakeManager = new stakeManager(address(KK));
            StakeManager.setPerMintNum(10);
            KK.setStakeManager(address(StakeManager));
        }
        vm.stopPrank();
    }

    function testStakeETH() public {
        vm.startPrank(alice);
        {
            StakeManager.stakeETH{value: 100 ether}();
        }
        vm.stopPrank();

        //设定期间出了10区块
        vm.roll(11);

         vm.startPrank(david);
        {
            StakeManager.stakeETH{value: 400 ether}();
        }
        vm.stopPrank();

        vm.roll(21);

        vm.startPrank(alice);
        {
            StakeManager.unstakeETH(1,50 ether);
        }
        vm.stopPrank();
        //(100+20)/2
        assertEq(KK.balanceOf(alice), 60);

    }
}
