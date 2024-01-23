// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "./BaseScript.s.sol";
import "../src/ERC2612.sol";

import "../src/TokenBank.sol";

contract ERC2612Script is BaseScript {
    function run() public broadcaster {
        ERC2612 token = new ERC2612();

        console.log("ERC2612 deployed on %s", address(token));


        TokenBank bank = new TokenBank(address(token));
        console.log("TokenBank deployed on %s", address(bank));
    }
}
