pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";

import {console} from "lib/forge-std/src/console.sol";

import "../src/MarketV2.sol";

import {Upgrades,Options} from "lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";

contract upgradeImp is Script{

  function run() public {

   vm.startBroadcast();
    Options memory opts;
    opts.unsafeSkipAllChecks = true;
  //   Upgrades.upgradeProxy(address(0xe6570e5A8499326Ce15E3F5641fD2B1FadE90A77),"MarketV2.sol",
  //  abi.encodeCall(MarketV2.initialize, 
  //  (address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),address(0x4FCe758EceE5aA7Fda5b1A04356Dbfa265061BE3),address(0x25bDeB03a8f9f02928Bf035730363eBdef9bdA31))
  //  ),opts);

   vm.stopBroadcast();

   console.log("update ImpContract success!");

  }

}