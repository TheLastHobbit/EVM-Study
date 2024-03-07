// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
// 这只是看涨的期权合约
contract optionsImp is ERC20 {

    address private owner;
    uint256 private optionPrice;
    uint256 private deadline;
    uint256 private strikePrice;
    uint256 private num;

    address private USDT;

    address private buyer;

    bool private lock = true;

    constructor()ERC20("optionsImp", "OPT"){
    }

    function init(address _owner, uint256 _optionPrice,uint _strikePrice,uint _num,uint _deadline,address _USDT) public onlyOwner{
        owner = _owner;
        optionPrice = _optionPrice;
        deadline = _deadline;
        strikePrice = _strikePrice;
        num = _num;
        USDT = _USDT;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function deposit() external payable onlyOwner{
        require(msg.value >= num*1 ether, "You must deposit the full amount");
        lock = false;
    }

    function setOptionPrice(uint256 _price) public onlyOwner{
        optionPrice = _price;
    }

    function buyOption() public payable{
        require(msg.value >= optionPrice, "You must pay the full price");
        payable(owner).transfer(msg.value);
        buyer = msg.sender;
        
    }

    function exerciseOption() external {
        require(lock == false, "The option is not yet available for exercise");
        require(msg.sender == buyer, "You are not the buyer");
        require(block.timestamp <= deadline, "The deadline has passed");
        require(IERC20(USDT).allowance(msg.sender, address(this)) >= strikePrice, "You must approve the contract to spend the tokens");
        IERC20(USDT).transferFrom(msg.sender, owner, strikePrice);
        payable(msg.sender).transfer(num*1 ether);
    }

    function getOptionPrice() public view returns
    (uint256){
        return optionPrice;
    }
    
}