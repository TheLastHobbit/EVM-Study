// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract MyBank{
    mapping(address account=> uint256) private balances;
    mapping(address => address) _nextAccounts;
    uint256 public listSize;
    address constant GUARD = address(1);

    event Deposit(address account,uint256 value);

    event Withdraw(uint256 value);

    address private admin;
    constructor(){
        admin = msg.sender; 
        _nextAccounts[GUARD] = GUARD;  
    }

    function deposit() external payable{
        require(msg.value>0,"Your value must more than zero!");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external{
        require(msg.sender == admin,"only admin");
        uint256 amount =address(this).balance;
        payable(msg.sender).transfer(amount);
        balances[msg.sender] = amount;
        emit Withdraw(amount);
    }

    function getBalance(address account) public view returns(uint256){
        return balances[account];
    }

    function addAccount(address Account, uint256 balance, address candidateAccount) public {
    require(_nextAccounts[Account] == address(0));
    require(_nextAccounts[candidateAccount] != address(0));
    require(_verifyIndex(candidateAccount, balance, _nextAccounts[candidateAccount]));
    balances[Account] = balance;
    _nextAccounts[Account] = _nextAccounts[candidateAccount];
    _nextAccounts[candidateAccount] = Account;
    listSize++;
  }
  
  function increasebalance(
    address Account, 
    uint256 balance, 
    address oldCandidateAccount, 
    address newCandidateAccount
  ) public {
    updatebalance(Account, balances[Account] + balance, oldCandidateAccount, newCandidateAccount);
  }
  
  function reducebalance(
    address Account, 
    uint256 balance, 
    address oldCandidateAccount, 
    address newCandidateAccount
  ) public {
    updatebalance(Account, balances[Account] - balance, oldCandidateAccount, newCandidateAccount);
  }
  
  function updatebalance(
    address Account, 
    uint256 newbalance, 
    address oldCandidateAccount, 
    address newCandidateAccount
  ) public {
    require(_nextAccounts[Account] != address(0));
    require(_nextAccounts[oldCandidateAccount] != address(0));
    require(_nextAccounts[newCandidateAccount] != address(0));
    if(oldCandidateAccount == newCandidateAccount)
    {
      require(_isPrevAccount(Account, oldCandidateAccount));
      require(_verifyIndex(newCandidateAccount, newbalance, _nextAccounts[Account]));
      balances[Account] = newbalance;
    } else {
      removeAccount(Account, oldCandidateAccount);
      addAccount(Account, newbalance, newCandidateAccount);
    }
  }
  
  function removeAccount(address Account, address candidateAccount) public {
    require(_nextAccounts[Account] != address(0));
    require(_isPrevAccount(Account, candidateAccount));
    _nextAccounts[candidateAccount] = _nextAccounts[Account];
    _nextAccounts[Account] = address(0);
    balances[Account] = 0;
    listSize--;
  }
  
  function getTop(uint256 k) public view returns(address[] memory) {
    require(k <= listSize);
    address[] memory AccountLists = new address[](k);
    address currentAddress = _nextAccounts[GUARD];
    for(uint256 i = 0; i < k; ++i) {
      AccountLists[i] = currentAddress;
      currentAddress = _nextAccounts[currentAddress];
    }
    return AccountLists;
  }
  
  
  function _verifyIndex(address prevAccount, uint256 newValue, address nextAccount)
    internal
    view
    returns(bool)
  {
    return (prevAccount == GUARD || balances[prevAccount] >= newValue) && 
          (nextAccount == GUARD || newValue > balances[nextAccount]);
  }
  
  function _isPrevAccount(address Account, address prevAccount) internal view returns(bool) {
    return _nextAccounts[prevAccount] == Account;
  }

}