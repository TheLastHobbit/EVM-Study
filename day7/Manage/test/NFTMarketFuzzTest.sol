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
            for(uint256 i=0;i<100;i++){
                nft.safeMint(admin,"1");
               
            }
                           
            erc20.transfer(alice,100000000000000000000);
        }
        vm.stopPrank();
        
    }

    function test_transferWithCallbackFuzz(uint256 _id,uint256 _price)public{
        vm.assume(_id>0&&_id<100);
        vm.assume(_price>1&&_price<1000000000);

        vm.startPrank(admin);
        {
        nftMarket.placeOrder(admin,_id,_price);
        assertEq(nftMarket.getorderSell(_id),admin);
        nft.approve(address(nftMarket),_id);
        }
         
        vm.stopPrank();
        vm.startPrank(alice);
        {

            assertEq(erc20.balanceOf(alice),100000000000000000000);
            assertEq(nftMarket.getorderSell(_id),admin);
            assertEq(nftMarket.getorderPrice(_id),_price);
            erc20.transferWithCallback(address(nftMarket),_price,_id);
            assertEq(nft.ownerOf(_id),alice);
        }
        vm.stopPrank();
       
    }
}