// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./Ming.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../dex/router/interfaces/IOutswapV1Router.sol";

import {Test, console} from "forge-std/Test.sol";
contract MingFactory {
    address public ImpAddress;
    address private newContract;
    address private owner;
    uint256 public perMintFee;
    address private router;

    event cloneNewContract(address newContract);
    event mintinscription(address indexed to,address tokenAddr,uint256 tokenAmount,uint256 ETHamount);

    constructor(address _ImpAddress,address _router) {
        ImpAddress = _ImpAddress;
        owner = msg.sender;
        router = _router;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setPerMintFee(uint256 _perMintFee) public onlyOwner {
        perMintFee = _perMintFee;
    }

    function deployInscription(
        string memory name,
        string memory symbol,
        uint num,
        uint perMint
    ) public returns(address){
        // 创建合约实例
        newContract = Clones.clone(ImpAddress);
        // 调用合约的init函数
        Ming(newContract).init(name, symbol, num, perMint);
        // 触发事件
        emit cloneNewContract(newContract);

        return newContract;
    }

    function setImpAddress(address _ImpAddress) external onlyOwner{
        ImpAddress = _ImpAddress;
    }

    function getNewAddress() public returns (address) {
        return newContract;
    }

    function withDraww() external onlyOwner{
        require(address(this).balance > 0, "No balance to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }

    //实现在支付一定费用参与铸币的功能
    function mintInscription(address tokenAddr) public payable {
        require(msg.value >= perMintFee, "Insufficient payment");
        uint ethValue = msg.value/2;
        uint256 mintNum = Ming(tokenAddr).mint();//先将打的铭文存在factory
        IERC20(tokenAddr).approve(router,mintNum);
        IOutswapV1Router(router).addLiquidityETH{value:ethValue}(tokenAddr,mintNum/2,0,0,msg.sender,block.timestamp+60);//将一半的打铭文的费用和一半的铭文数量添加到流动性池中
        console.log("factorybalance:",IERC20(tokenAddr).balanceOf(address(this)));
        IERC20(tokenAddr).transfer(msg.sender,mintNum/2);//将另一半的铭文发送给用户

        emit mintinscription(msg.sender,tokenAddr,mintNum/2,msg.value);
    }
}
