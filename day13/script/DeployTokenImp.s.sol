// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/MyERC20.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {console} from "lib/forge-std/src/console.sol";

contract DeployTokenImplementation is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();
        // Deploy the ERC-20 token
        MyERC20 implementation = new MyERC20();
        // Stop broadcasting calls from our address
        vm.stopBroadcast();
        // Log the token address
        console.log("ERC20 Implementation Address:", address(implementation));
    }
}