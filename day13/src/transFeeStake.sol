// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./sToken.sol";

import "./KKERC20.sol";

// 这个池子的手续费是平台币，所得也是平台币KK，所以缺点是无法像所得为ETH一样可以实现自动复投（复利）
// 但质押的是ETH。
contract tranFeeStakePool {
    uint private totalStaked;

    uint private stakeIndex;

    mapping(address => stakeInfo) private addressTostakedInfo;

    uint private accrualBlockNumber;

    uint public constant RATIO = 10 ** 10;

    uint LastKKBalance;

    struct stakeInfo{
        uint stakedAmount;
        uint startIndex;
    }

    address private sTokenAddress;
    address private KK;
    
    constructor(address _sTokenAddress,address _KK) {
        accrualBlockNumber = block.number;
        sTokenAddress = _sTokenAddress;
        KK = _KK;
    }

    function withDraw(uint256 amount) external {
        // accrueInterest_KK();
        stakeInfo memory info = addressTostakedInfo[msg.sender];
        uint currentStakeAmount = info.stakedAmount*(stakeIndex-info.startIndex);
        sToken(sTokenAddress).burn(msg.sender,amount);
        totalStaked -= amount;
        console.log("currentStakeAmount:",currentStakeAmount);
        ERC20(KK).transfer(msg.sender,currentStakeAmount/100000000000000000000);
        delete addressTostakedInfo[msg.sender];
    }

    function accrueInterest_KK() public returns (uint){
        // uint currentBlockNumber =block.number; //获取当前区块高度
        // //如果上次计息时也在相同区块，则不重复计息。
        // if (accrualBlockNumber == currentBlockNumber) {
        //     return stakeIndex;
        // }
         uint  stakeRate;
         uint currentKKBalance = ERC20(KK).balanceOf(address(this));
         uint addKKBalance = currentKKBalance - LastKKBalance;
         

         console.log("KK Balance:",ERC20(KK).balanceOf(address(this)));

        //根据当stake的ETH和fee池中的KK得出当前的利率，也就是一份ETH可以分多少KK。
        if (totalStaked == 0 || currentKKBalance == 0){
            stakeRate = 0;
        }else{
            console.log("update stakeRate!");
        stakeRate= (100000000000000000000*addKKBalance)/totalStaked;
        }
        console.log("stakeRate:",stakeRate);

        // 更新累积利率
        stakeIndex = stakeIndex +stakeRate;
        console.log("stakeIndex:",stakeIndex);
        LastKKBalance = currentKKBalance;
        // 更新计息时间
        // accrualBlockNumber = currentBlockNumber;
        return stakeIndex;
    }

    function stake() external payable {
        // stake前先更新利率，并记录当前的利率 错误：不用更新，因为stake根本不会增加池子里面的fee，也就是说没有新收益可以结算。
        // accrueInterest_KK();
        console.log("accrue success");
        require(msg.value > 0, "Stake amount must be greater than zero");
        totalStaked += msg.value;
        console.log("totalStake:",totalStaked);
        addressTostakedInfo[msg.sender] = stakeInfo(msg.value,stakeIndex);
        console.log("accrue success3");
        sToken(sTokenAddress).mint(msg.sender, msg.value);
        console.log("accrue success4");
    }

    function getTotalStaked() external view returns (uint256) {
        return totalStaked;
    }


}
