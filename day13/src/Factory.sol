// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "lib/openzeppelin-contracts/contracts/proxy/Clones.sol";
import "./MyERC20.sol";

contract Factory{
    address public  libraryAddress;
    address private newContract;

    event cloneNewContract(address newContract);

    function deployInscription(string memory name, string memory symbol, uint totalSupply, uint perMint)public {
        // 创建合约实例
        newContract = Clones.clone(libraryAddress);
        // 调用合约的init函数
        MyERC20(newContract).init(name, symbol, totalSupply, perMint);
        // 触发事件
        emit cloneNewContract(newContract);
    }

     function setLibraryAddress(address _libraryAddress) public {
    libraryAddress = _libraryAddress;
  }

  function getNewAddress()public returns (address){
    return newContract;
    
  }

    function mintInscription(address tokenAddr)public {
        MyERC20(tokenAddr).mint();
    }

}