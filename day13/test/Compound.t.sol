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
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

import "../src/MarketV2.t.sol";
import "../src/NFT.sol";
import "../src/KKERC20.sol";
import "../src/transFeeStake.sol";
import "../src/sToken.sol";

contract TestCompound is Test {
    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");
    address public david = makeAddr("david");

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
        deal(alice, 1000000000000 ether);
        deal(david, 1000000000000 ether);
        vm.startPrank(admin);
        {
            NFT = new MyNFT();
            NFT.safeMint(admin, "1");
            NFT.safeMint(admin, "2");
            NFT.safeMint(admin, "3");
            NFT.safeMint(admin, "4");
            KK = new KKERC20();

            WETH9 = new WETH();
            WETH9.deposit{value: 1000 ether}();
            MTK = address(new MyERC20());
            Factory = new OutswapV1Factory(admin);
            Router = new OutswapV1Router(address(Factory), address(WETH9));
            stoken = new sToken(admin);
            StakePool = new tranFeeStakePool(address(stoken), address(KK));
           

            Market = new MarketV2(
                address(admin),
                address(NFT),
                address(KK),
                address(Router),
                address(StakePool),
                address(WETH9)
            );

            stoken.setTransFeeStake(address(StakePool));
            
            ERC721(NFT).approve(address(Market), 1);
            ERC721(NFT).approve(address(Market), 2);
            ERC721(NFT).approve(address(Market), 3);

            ERC20(KK).transfer(address(alice), 100000000);
            WETH9.transfer(address(alice), 100 ether);
            // approve
            ERC20(KK).approve(address(Router), 100 ether);
            WETH9.approve(address(Router), 200 ether);
            ERC20(MTK).approve(address(Router), 100 ether);

            ERC20(KK).approve(address(Market), 100 ether);
            WETH9.approve(address(Market), 200 ether);
            ERC20(MTK).approve(address(Market), 100 ether);
        }
        vm.stopPrank();
    }

    function testCompound() public {
        vm.startPrank(admin);
        {
            Market.setTransfee(100); //设定10%手续费率
        }
        vm.stopPrank();

        vm.startPrank(david);
        {
            StakePool.stake{value: 100 ether}();
        }
        vm.stopPrank();
        assertEq(stoken.balanceOf(address(david)), 100 ether);

        vm.startPrank(alice);
        {
            ERC20(KK).approve(address(Market), 100 ether);
            Market.buy(address(KK), 100, admin, 1, 1000);
        }
        vm.stopPrank();
        assertEq(KK.balanceOf(address(StakePool)), 100);

        vm.startPrank(alice);
        {
            StakePool.stake{value: 100 ether}();
        }
        vm.stopPrank();

        vm.startPrank(alice);
        {
            ERC20(KK).approve(address(Market), 100 ether);
            Market.buy(address(KK), 100, admin, 2, 1000);
        }
        vm.stopPrank();
        assertEq(KK.balanceOf(address(StakePool)), 200);

        vm.startPrank(david);
        {
            StakePool.withDraw(100 ether);
        }
        vm.stopPrank();
        assertEq(KK.balanceOf(address(david)), 150);
    }
}
