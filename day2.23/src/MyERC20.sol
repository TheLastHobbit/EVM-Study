// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TokenBank.sol";
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
    function transferWithCallback(address recipient,uint256 amount) external returns(bool){
        
        if(_isContract(recipient)){
            bool rv = TokenBank(recipient).tokenReceive(msg.sender,amount);
            require(rv, "No tokensReceived");
        }
        _transfer(msg.sender, recipient, amount);
        return true;
    }
}