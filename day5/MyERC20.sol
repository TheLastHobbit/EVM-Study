// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MyToken.sol";

contract MTK is MyToken {
    constructor() MyToken("MyToken", "MTK") {
       _mint(msg.sender, 1 * 10 ** 8 * 10 **decimals());
    }
}