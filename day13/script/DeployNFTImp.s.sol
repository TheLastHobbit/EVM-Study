// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/NFT.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {console} from "lib/forge-std/src/console.sol";
contract DeployTokenImplementation is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();
        // Deploy the ERC-20 token
        MyNFT implementation = new MyNFT();
        // Stop broadcasting calls from our address
        vm.stopBroadcast();
        // Log the token address
        console.log("NFT Implementation Address:", address(implementation));
    }
}