// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test, console2} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";
import {OutswapV1Router} from "src/dex/router/OutswapV1Router.sol";
import {OutswapV1Router2} from "src/dex2/router/OutswapV1Router.sol";
import {OutswapV1Factory} from "../src/dex/core/OutswapV1Factory.sol";
import {OutswapV1Factory2} from "../src/dex2/core/OutswapV1Factory.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/MyERC20.sol";
import {WETH} from "./util/WETH.sol";
import "./util/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/Flashloan/Flashloan.sol";

import "../src/KKERC20.sol";
import "../src/transFeeStake.sol";
import "../src/sToken.sol";

contract FlashloanTest is Test {
    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public david = makeAddr("david");

    OutswapV1Factory internal Factory;
    OutswapV1Router internal Router;
    OutswapV1Factory2 internal Factory2;
    OutswapV1Router2 internal Router2;
    Flashloan private flashloan;

    KKERC20 internal KK;
    tranFeeStakePool internal StakePool;
    sToken internal stoken;

    WETH internal WETH9;
    address internal erc20;
    address internal MTK;

    function setUp() public {
        deal(admin, 1000000000000 ether);
        deal(alice, 1000000000000 ether);
        deal(david, 1000000000000 ether);
        vm.startPrank(admin);
        {
            KK = new KKERC20(); //token0
            MTK = address(new MyERC20()); //token1

            WETH9 = new WETH();
            WETH9.deposit{value: 20000 ether}();

            Factory = new OutswapV1Factory(admin);
            Router = new OutswapV1Router(address(Factory), address(WETH9));
            Factory2 = new OutswapV1Factory2(admin);
            Router2 = new OutswapV1Router2(address(Factory2), address(WETH9));

            ERC20(KK).transfer(address(alice), 800 ether);
            WETH9.transfer(address(alice), 200 ether);
            // approve
            ERC20(KK).approve(address(Router), 8000 ether);
            WETH9.approve(address(Router), 2000 ether);
            ERC20(MTK).approve(address(Router), 10000 ether);

            ERC20(KK).approve(address(Router2), 8000 ether);
            WETH9.approve(address(Router2), 2000 ether);
            ERC20(MTK).approve(address(Router2), 10000 ether);

            ERC20(KK).approve(address(Factory), 800 ether);
            WETH9.approve(address(Factory), 2000 ether);
            ERC20(MTK).approve(address(Factory), 100 ether);

            //dex add KK&WETH,MTK&&WETH Liquidity

            Router.addLiquidity(
                address(KK),
                address(WETH9),
                1000 ether,
                1000 ether,
                1,
                1,
                alice,
                block.timestamp + 1000
            );
            Router.addLiquidity(
                MTK,
                address(WETH9),
                100 ether,
                100 ether,
                1,
                1,
                alice,
                block.timestamp + 1000
            );
            console2.log("addliquidity in dex1 success!");

            //dex2: add KK&WETH,MTK&&WETH Liquidity

            Router2.addLiquidity(
                address(KK),
                address(WETH9),
                800 ether,
                200 ether,
                1,
                1,
                alice,
                block.timestamp + 1000
            );
            Router2.addLiquidity(
                MTK,
                address(WETH9),
                100 ether,
                400 ether,
                1,
                1,
                alice,
                block.timestamp + 1000
            );
            console2.log("addliquidity in dex2 success!");

            flashloan = new Flashloan(
                address(KK),
                address(WETH9),
                address(Factory),
                address(Router),
                address(Router2),
                address(WETH9)
            );   
            console.log("flashloan:", address(flashloan));

            ERC20(KK).approve(address(flashloan), 8000 ether);
            WETH9.approve(address(flashloan), 2000 ether);
            ERC20(MTK).approve(address(flashloan), 1000 ether);   
        }
        vm.stopPrank();
    }

    function testFlashloan() public {
        vm.startPrank(alice);
        {
            flashloan.flashloan(10 ether);
        }
        vm.stopPrank();
    }
}
