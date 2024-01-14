// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IMyToken} from "./IMyToken.sol";

// 抽象合约可以选择性地实现接口中的函数，而普通合约在继承接口时需要实现接口中的所有函数。
abstract contract MyToken is IMyToken{

    mapping(address account => uint256)private _balances;
    mapping (address owner =>mapping (address spender=>uint256))private _allowances;


    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name,string memory symbol){
        _name=name;
        _symbol=symbol;
    }

// 在Solidity中，对于固定大小的返回值类型（如uint256），编译器会自动将其数据位置设置为默认的"memory"，因此不需要显式指定数据位置。

// 而对于动态大小的返回值类型（如string），编译器无法确定其大小，因此需要显式指定数据位置为"memory"或"calldata"。
    function name()public view returns (string memory){
        return _name;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to,uint256 value) external override returns(bool){
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    function _transfer(address from,address to,uint256 value)internal {
       if(from==address(0)){
        revert();
       }
       if(to==address(0)){
        revert();
       }
       _updata(from, to, value);
    }

    function approve(address spender,uint256 value) external override returns (bool){
        address owner =  msg.sender;
        _approve(owner, spender, value,true);
        return true;
    }

    function allowance(address owner,address spender)external override returns (uint256){
        uint256 value = _allowances[owner][spender];
        return value;
    }

    function transferfrom(address from,address to,uint256 value)external override returns(bool){
        address spender  = msg.sender;
        _spendAllowance(from,spender,value);
        _updata(from, to, value);
        return true;
    }

    function _approve(address owner,address spender,uint256 value,bool emitEvent)internal {
        if(owner==address(0)){
            revert();
        }
        if (spender==address(0)){
            revert();
        }
        _allowances[owner][spender]=value;
        if(emitEvent){
            emit Approve(owner,spender,value);
        }

    }

    function _spendAllowance(address owner,address spender,uint256 value) internal virtual {
        uint256 currentAllowance = _allowances[owner][spender];
        if(value>currentAllowance){
            revert();
        }
        // 不需要触发事件
        _approve(owner, spender,currentAllowance-value, false);
    }


    function _mint(address account,uint256 value) internal {
        _updata(address(0), account, value);
    }

    function _updata(address from ,address to,uint256 value) internal virtual {
        if(from==address(0)){
            _totalSupply+=value;
        }else{
            uint256 frombalance = _balances[from];
            if(frombalance<value){
                revert();//yichang
            }else {
                _balances[from]=frombalance-value;
            }

        }
        
        if(to==address(0)){
            _totalSupply-=value;
        }else {
            _balances[to]+=value;
        }

        emit Transfer(from,to,value);
    }
    

}