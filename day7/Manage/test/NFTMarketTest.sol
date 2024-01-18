// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import "src/Market.sol";
import "src/MyNFT.sol";
import "src/MyERC20.sol";
contract NFTMarketTest is Test{

    Market public nftMarket;
    MyNFT public nft;
    MyERC20 public erc20;

    address admin = makeAddr("admin");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    

    function setUp() public {
        
        // deal("alice",1000 ether);
        vm.startPrank(admin);
        {
            nft = new MyNFT();
            erc20 = new MyERC20();
            nftMarket = new Market(address(nft), address(erc20));
            
        }
        vm.stopPrank();
        
    }


    function test_placeOrder()public{
        vm.startPrank(admin);
        nft.safeMint(admin,"1");
        nftMarket.placeOrder(admin,1,10000);
        assertEq(nftMarket.getorderSell(1),admin);
    }



    function test_buyNFT() public {

        vm.startPrank(admin);
        {
            nft.safeMint(admin,"112");
            assertEq(nft.ownerOf(0),admin);
            nftMarket.placeOrder(admin,0,10000);
            erc20.transfer(alice,100000);
            
            nft.approve(address(nftMarket),0);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
            
            erc20.approve(address(nftMarket),10000);
            assertEq(erc20.balanceOf(alice),100000);
            assertEq(nftMarket.getorderSell(0),admin);
            assertEq(nftMarket.getorderPrice(0),10000);
            nftMarket.buy(0,10000);
            assertEq(nft.ownerOf(0),alice);
        }
        vm.stopPrank();
        
    }

    function test_transferWithCallback() public{
         vm.startPrank(admin);
        {
            nft.safeMint(admin,"112");
            assertEq(nft.ownerOf(0),admin);
            nftMarket.placeOrder(admin,0,10000);
            erc20.transfer(alice,100000);
            nft.approve(address(nftMarket),0);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
            
            assertEq(erc20.balanceOf(alice),100000);
            assertEq(nftMarket.getorderSell(0),admin);
            assertEq(nftMarket.getorderPrice(0),10000);
            erc20.transferWithCallback(address(nftMarket),10000,0);
            assertEq(nft.ownerOf(0),alice);
            
        }
        vm.stopPrank();
        
    }

    // function test_placeOrderFuzz(uint256 _id,uint256 _price)public{
    //     vm.assume(_id>0&&_id<1000);
    //     vm.assume(_price>1);
    //     vm.startPrank(alice);
    //     nftMarket.placeOrder(alice,_id,_price);
    //     assertEq(nftMarket.getorderSell(_id),alice);
    // }

    // function test_transferWithCallbackFuzz(uint256 _id)public{
    //     vm.assume(_id>0&&_id<100);
    //       vm.startPrank(admin);
    //     {
    //         assertEq(nft.ownerOf(0),admin);
    //         nftMarket.placeOrder(admin,0,10000);
    //         erc20.transfer(alice,100000);
    //         nft.approve(address(nftMarket),0);
    //     }
    //     vm.stopPrank();
    //     vm.startPrank(alice);
    //     {
            
    //         assertEq(erc20.balanceOf(alice),100000);
    //         assertEq(nftMarket.getorderSell(0),admin);
    //         assertEq(nftMarket.getorderPrice(0),10000);
    //         erc20.transferWithCallback(address(nftMarket),10000,0);
    //         // assertEq(nft.ownerOf(0),alice);
    //     }
    //     vm.stopPrank();
    // }
}



