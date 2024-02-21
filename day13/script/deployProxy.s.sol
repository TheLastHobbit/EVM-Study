pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";

import {console} from "lib/forge-std/src/console.sol";
import "../src/Market.sol";

import {Upgrades, Options} from "lib/openzeppelin-foundry-upgrades/src/Upgrades.sol";

contract DeployUUPSProxy is Script {

   function run() public {
     vm.startBroadcast();

     Options memory opts;
     opts.unsafeSkipAllChecks = true;
  //  function initialize(address initialOwner,address _erc721, address _erc20) initializer public
     address proxy = Upgrades.deployUUPSProxy( "Market.sol",abi.encodeCall(Market.initialize, 
     (address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),address(0x4FCe758EceE5aA7Fda5b1A04356Dbfa265061BE3),address(0x25bDeB03a8f9f02928Bf035730363eBdef9bdA31))
     ), opts
     );
     vm.stopBroadcast();
     console.log("UUPS Proxy Address:", address(proxy));
   } 

}