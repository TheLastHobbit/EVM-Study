// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract MyERC20 is ERC20 {
    uint private perMint;
    uint256 internal  _num;

    event Mint(address indexed to,uint amount);

    constructor() ERC20("MyToken", "MTK") {
       _mint(msg.sender, 1 * 10 ** 8 * 10 **decimals());
    }

    function mint() public{
        require(_num>0);
        _mint(msg.sender,perMint);
        _num--;
        emit Mint(msg.sender,perMint);
    }

    function init(string memory name, string memory symbol, uint256 num, uint _perMint) public {
        _name = name;
        _symbol = symbol;
        _num = num;
        perMint = _perMint;
    }
    
}