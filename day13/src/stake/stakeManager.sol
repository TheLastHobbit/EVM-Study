// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../sToken.sol";

import "../KKERC20.sol";

// 质押挖矿
contract stakeManager {
    uint private totalStaked;
    address private KKAddress;
    mapping(address => mapping(uint => StakeInfo)) private stakedInfo;

    uint private accrualBlockNumber;

    uint private stakeIndex;
    uint private perMintNum;

    address private owner;

    struct StakeInfo {
        uint stakedAmount;
        uint beginStakeIndex;
    }

    uint private stakeId;

    constructor(address _KKAddress) {
        KKAddress = _KKAddress;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setPerMintNum(uint _perMintNum) external onlyOwner {
        perMintNum = _perMintNum;
    }

    function stakeETH() external payable {
        require(msg.value > 0, "You need to stake at least 1 wei");
        // 只有有人质押进ETH和取出时才会影响利率
        accrueInterest_KK();
        stakeId++;
        console.log("current_stakeId:", stakeId);
        totalStaked += msg.value;
        stakedInfo[msg.sender][stakeId] = StakeInfo(msg.value, stakeIndex);
    }

    function accrueInterest_KK() public returns (uint) {
        uint currentBlockNumber = block.number; //获取当前区块高度
        //如果上次计息时也在相同区块，则不重复计息。
        if (accrualBlockNumber == currentBlockNumber) {
            return stakeIndex;
        }
        uint stakeRate;
        // 计算每份能分一个区块中多少KK
        console.log("totalStaked:",totalStaked);
        if (perMintNum == 0 || totalStaked == 0) {
            stakeRate = 0;
            stakeIndex = stakeIndex +0;
        } else {
            stakeRate = 100000000000000000000*perMintNum / totalStaked;          
            // 更新累积利率
            stakeIndex =
                stakeIndex +
                stakeRate *
                (currentBlockNumber - accrualBlockNumber);
        }

        console.log("stakeRate:", stakeRate);

        console.log("stakeIndex:", stakeIndex);

        // 更新计息时间
        accrualBlockNumber = currentBlockNumber;
        return stakeIndex;
    }

    function unstakeETH(uint stakeId, uint amount) external {
        uint balance = stakedInfo[msg.sender][stakeId].stakedAmount;
        require(
            amount <= balance,
            "You can't unstake more than you have staked"
        );
        // 更新从存入到取出这之间的index
        accrueInterest_KK();
        // 获取存进时的index
        uint beginStakeIndex = stakedInfo[msg.sender][stakeId].beginStakeIndex;
        // 计算应该分得的KK数量
        uint KK_amount = amount * (stakeIndex - beginStakeIndex)/100000000000000000000;
        KKERC20(KKAddress).stakeMint(msg.sender, KK_amount);
        totalStaked -= amount;
        stakedInfo[msg.sender][stakeId].stakedAmount -= amount;
        payable(msg.sender).transfer(amount);
    }
}
