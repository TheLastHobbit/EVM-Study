// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// import {NFTMarket} from "./Market.sol";
import {ItokenRecieved} from"./ItokenRecieved.sol";
contract MyERC20 is ERC20 {
    constructor() ERC20("MyToken", "MTK") {
       _mint(msg.sender, 1 * 10 ** 8 * 10 **decimals());
    }

    function _isContract(address _address) internal view returns (bool) {
    uint32 size;
    assembly {
        size := extcodesize(_address)
    }
    return (size > 0);
    }
    

     function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }


    function transferWithCallback(address to,uint256 amount,uint256 id) external{
        _transfer(msg.sender,to,amount);
        ItokenRecieved(to).tokenRecieve(msg.sender,amount,id);
       
    }
}