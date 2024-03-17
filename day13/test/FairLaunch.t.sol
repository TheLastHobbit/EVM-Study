// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test, console} from "forge-std/Test.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {WETH} from "./util/WETH.sol";

import "../src/Fair Launch/MingFactory.sol";
import "../src/Fair Launch/Ming.sol";

import "../src/Fair Launch/FLdex/core/OutswapV1Factory.sol";
import {OutswapV1Router} from  "../src/Fair Launch/FLdex/router/OutswapV1Router.sol";

contract FairLaunchTest is Test {
    address public admin = makeAddr("admin");
    address public alice = makeAddr("alice");

    OutswapV1Factory internal Factory;
    OutswapV1Router internal Router;

    MingFactory internal mingFactory;
    Ming internal ming;

    WETH internal WETH9;

    function setUp() public {
        deal(admin, 1000000000000 ether);
        deal(alice, 1000000000000 ether);

        vm.startPrank(admin);
        {
        WETH9 = new WETH();
        WETH9.deposit{value: 1000 ether}();

        Factory = new OutswapV1Factory(admin);
        Router = new OutswapV1Router(address(Factory), address(WETH9));

        ming = new Ming();
      
        mingFactory = new MingFactory(address(ming),address(Router));

        mingFactory.setPerMintFee(100 ether);
        }
        vm.stopPrank();
    }

    function testMint() public{
        vm.startPrank(alice);
        {
            address newContract = mingFactory.deployInscription("alice","ALC",10000,100 ether);
            mingFactory.mintInscription{value: 100 ether}(newContract);
        }
        vm.stopPrank();
    }

    function testGetLiqEarn() public{
        vm.startPrank(alice);
        {
            address newContract = mingFactory.deployInscription("alice","ALC",10000,100 ether);
            mingFactory.mintInscription{value: 100 ether}(newContract);
        }
        vm.stopPrank();

         vm.startPrank(alice);
        {
            address[] memory path;
            path[0] = address(WETH9);
            path[1] = address(ming);
            Router.swapExactETHForTokens(10 ether, path, alice, block.timestamp+20);
        }

        
    }

    
}