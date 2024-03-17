// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

// 铭文实现
contract Ming is ERC20 {
    uint private perMint;
    uint256 internal  _num;

    address private stakeManager;
    address private owner;
    address private factory;


    event Mint(address indexed to,uint amount);

    constructor()ERC20("Ming", "MNG") {
       
    }

  
    modifier onlyOwner() {
        require(msg.sender == owner,"only owner");
        _;
    }

    function setPerMint(uint _perMint) public onlyOwner {
        perMint = _perMint;
    }

    function mint() public onlyOwner returns (uint256){
        require(_num>0);
        _mint(msg.sender,perMint);
        _num--;
        emit Mint(msg.sender,perMint);
        return perMint;
    }

    function init(string memory name, string memory symbol, uint256 num, uint _perMint) public {
        owner = msg.sender;
        _name = name;
        _symbol = symbol;
        _num = num;
        perMint = _perMint;
    }
    
}