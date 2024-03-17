// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import "./JCToken.sol";
import "./TimeLock.sol";

contract JCDao{
    address public owner;
    address public jcToken;
    address public timeLock;

    mapping(address => bool) public whitelisted;
    mapping(address => bool) public blacklisted;
    mapping(address => bool) public Admin;

    mapping(address => uint256) public contributions;

    event Contribute(address indexed contributor, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    constructor(address _owner,address _jcToken){
        owner = _owner;
        jcToken = _jcToken;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function contribute() external payable{
        require(msg.value > 0,"You must contribute more than 0 ether");
        require(isDaoMember(msg.sender),"You must be a DAO member to contribute");
        contributions[msg.sender] += msg.value;
        JCToken(jcToken).mintDao(msg.sender,msg.value);
        
        emit Contribute(msg.sender,msg.value);
    }
    
    function isDaoMember(address _address) public view returns(bool){
        return whitelisted[_address];
    }

    function setAdmin(address _addr) external onlyOwner{
        Admin[_addr] = true;
    }

    function isDaoAdmin(address _address) public view returns(bool){
        return Admin[_address];
    }

    function addMember(address _member) external{
        require(Admin[msg.sender]|| msg.sender == owner ,"You must be an admin&Owner to add a member");
        whitelisted[_member] = true;
    }

    function setTimeLock(address _timeLock) external onlyOwner{
        timeLock = _timeLock;
    }

    function withdraw(address to,uint256 amount) external{
        require(msg.sender == timeLock,"You must be the timeLock to call this function");
        payable(to).transfer(amount);
        emit Withdraw(to,amount);
    }

}
