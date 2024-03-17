// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;
interface IJCToken {
    function getPriorVotes(address account, uint blockNumber) external view returns (uint256);
}