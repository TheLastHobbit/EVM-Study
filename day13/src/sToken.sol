// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract sToken is ERC20, Ownable {

    address private transFeeStake;

    modifier onlytransFeeStake() {
        require(
            msg.sender == transFeeStake,
            "Access only by StakeManager"
        );
        _;
    }

    constructor(address owner) ERC20("Principal Staked ETH", "sToken") Ownable(owner) {}

    function setTransFeeStake(address _transFeeStake) external onlyOwner {
        transFeeStake = _transFeeStake;
    }

    function mint(address account, uint256 amount) external onlytransFeeStake {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external onlytransFeeStake {
        _burn(account, amount);
    }
    
}