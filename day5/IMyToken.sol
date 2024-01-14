// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMyToken {
        // 在Solidity中，indexed是一个关键字，用于声明事件参数。
    // 当在事件声明中使用indexed修饰符时，表示该参数将被索引，以便在日志中进行快速搜索和过滤。
    event Transfer(address indexed from,address indexed to, uint256 value);

    event Approve(address indexed owner,address indexed spender,uint256 value);

// 在Solidity中，external和view是函数修饰符，用于声明函数的可见性和状态。

// external修饰符表示该函数只能通过外部调用进行访问，即只能通过合约外部的消息调用来触发该函数。
// 这意味着该函数不能在合约内部直接调用，只能由其他合约或外部账户通过交易调用。

// view修饰符表示该函数不会修改合约的状态。它只用于读取数据，而不会对合约的状态进行修改。
// 这意味着在调用该函数期间，不会产生任何状态变化，也不会消耗任何燃气（gas）。

    function totalSupply() external view returns (uint256);

    function balanceOf (address account) external view returns(uint256);
    function transfer(address to,uint256 value) external returns(bool);

    function allowance(address owner,address spender) external returns(uint256);

    function approve(address spender,uint256 value)external returns(bool);

    function transferfrom(address from,address to,uint256 value) external returns(bool);
    
    
}