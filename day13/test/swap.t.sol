//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {Test, console2} from "forge-std/Test.sol";
import {Script, console2} from "forge-std/Script.sol";
import {OutswapV1Router} from "src/dex/router/OutswapV1Router.sol";
import {OutswapV1Factory} from "../src/dex/core/OutswapV1Factory.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/MyERC20.sol";
import {WETH} from "./util/WETH.sol";
import "./util/TestERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../src/MarketV2.t.sol";
import "../src/NFT.sol";
import "../src/KKERC20.sol";
import "../src/transFeeStake.sol";
import "../src/sToken.sol";

contract TestAddLiq is Test {
    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");

    OutswapV1Factory internal Factory;
    OutswapV1Router internal Router;
    MarketV2 internal Market;
    MyNFT internal NFT;
    KKERC20 internal KK;
    tranFeeStakePool internal StakePool;
    sToken internal stoken;

    WETH internal WETH9;
    address internal erc20;
    address internal MTK;

    function setUp() public {
        deal(admin, 1000000000000 ether);
        vm.startPrank(admin);
        {
            NFT = new MyNFT();
            KK = new KKERC20();

            WETH9 = new WETH();
            WETH9.deposit{value: 1000 ether}();
            MTK = address(new MyERC20());
            Factory = new OutswapV1Factory(admin);
            Router = new OutswapV1Router(address(Factory), address(WETH9));

            ERC20(KK).transfer(address(alice), 100000000);
            WETH9.transfer(address(alice), 100 ether);
            // approve
            ERC20(KK).approve(address(Router), 100 ether);
            WETH9.approve(address(Router), 200 ether);
            ERC20(MTK).approve(address(Router), 100 ether);

            StakePool = new tranFeeStakePool(address(stoken), address(KK));

            Market = new MarketV2(
                address(admin),
                address(NFT),
                address(KK),
                address(Router),
                address(StakePool),
                address(WETH9)
            );
            ERC20(KK).approve(address(Market), 100 ether);
            WETH9.approve(address(Market), 200 ether);
            ERC20(MTK).approve(address(Market), 100 ether);
        }
        vm.stopPrank();
    }

    function testAddLiquidity() public {
        assertEq(WETH9.balanceOf(address(admin)), 900 ether);
        vm.startPrank(admin);
        {
            Router.addLiquidity(
                address(KK),
                address(WETH9),
                100 ether,
                100 ether,
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
        }
        vm.stopPrank();
    }

    function testSwap() public {
        // add KK&WETH,MTK&&WETH Liquidity
        vm.startPrank(admin);
        {
            Router.addLiquidity(
                address(KK),
                address(WETH9),
                100 ether,
                100 ether,
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
            console2.log("addliquidity success!");
        }
        vm.stopPrank();

        vm.startPrank(alice);
        {
            WETH9.approve(address(Market), 200 ether);
            ERC20(MTK).approve(address(Market), 100 ether);
            // WETH Swap KK
            uint256[] memory amounts = Market._swap(
                address(WETH9),
                10 ether,
                12 ether,//amountsIn:", 11144544745347152569
                block.timestamp + 1000
            );

            // MTK Swap KK
        }
        vm.stopPrank();

        assertEq(ERC20(KK).balanceOf(address(Market)), 10 ether);
    }
}
