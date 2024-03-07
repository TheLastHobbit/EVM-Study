// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./optionsImp.sol";

contract Factory {
    address public ImpAddress;
    address private newContract;
    address private owner;
    

    event cloneNewContract(address newContract);

    constructor(address _ImpAddress) {
        ImpAddress = _ImpAddress;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }


    function deployInscription(
       address _owner, uint256 _optionPrice,uint _strikePrice,uint _num,uint _deadline,address _USDT
    ) public {
        // 创建合约实例
        newContract = Clones.clone(ImpAddress);
        // 调用合约的init函数
        optionsImp(newContract).init(_owner, _optionPrice, _strikePrice, _num,_deadline,_USDT);
        // 触发事件
        emit cloneNewContract(newContract);
    }

    function setImpAddress(address _ImpAddress) external onlyOwner{
        ImpAddress = _ImpAddress;
    }

    function getNewAddress() public returns (address) {
        return newContract;
    }

}
