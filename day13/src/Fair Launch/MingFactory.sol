// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./Ming.sol";

contract Factory {
    address public ImpAddress;
    address private newContract;
    address private owner;
    uint256 public perMintFee;

    event cloneNewContract(address newContract);

    constructor(address _ImpAddress) {
        ImpAddress = _ImpAddress;
        owner = msg.sender;
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
        uint totalSupply,
        uint perMint
    ) public {
        // 创建合约实例
        newContract = Clones.clone(ImpAddress);
        // 调用合约的init函数
        Ming(newContract).init(name, symbol, totalSupply, perMint);
        // 触发事件
        emit cloneNewContract(newContract);
    }

    function setImpAddress(address _ImpAddress) external onlyOwner{
        ImpAddress = _ImpAddress;
    }

    function getNewAddress() public returns (address) {
        return newContract;
    }

    //实现在支付一定费用参与铸币的功能
    function mintInscription(address tokenAddr) public payable {
        require(msg.value >= perMintFee, "Insufficient payment");
        
        Ming(tokenAddr).mint();
    }
}
