// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {ItokenRecieved} from"./ItokenRecieved.sol";
contract KKERC20 is ERC20 {
    uint private perMint;
    uint256 internal  _num;
    address private stakeManager;
    address private owner;

    event Mint(address indexed to,uint amount);

    constructor() ERC20("KK", "KK") {
       _mint(msg.sender, 1 * 10 ** 8 * 10 **decimals());
       owner = msg.sender;
    }

    modifier onlystakeManager() {
        require(msg.sender == stakeManager,"only stake manager");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"only owner");
        _;
    }

    function mint(address to,uint amount) public onlyOwner {
        require(_num>0);
        _mint(to,amount);
        _num--;
        emit Mint(msg.sender,amount);
    }

    function setPerMint(uint _perMint) public onlyOwner {
        perMint = _perMint;
    }


    function setStakeManager(address _stakeManager) external onlyOwner{
        stakeManager = _stakeManager;
    }


    function stakeMint(address staker,uint amount) public onlystakeManager {
        _mint(staker,amount);
        emit Mint(msg.sender,amount);
    }

    function init(string memory name, string memory symbol, uint256 num, uint _perMint) public {
        _name = name;
        _symbol = symbol;
        _num = num;
        perMint = _perMint;
    }
    
}