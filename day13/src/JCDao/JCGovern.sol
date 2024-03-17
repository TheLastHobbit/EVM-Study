// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {GovernorEvents} from "./util/GovernTool.sol";
import "./Dao.sol";

// 治理合约
contract JCGovern is GovernorEvents {
    address private dao;
    address private owner;
    address public implementation;

    event FallbackTriggered(address caller, bytes data);

    constructor(
        address _dao,
        address _timelock,
        address _token,
        address _implementation,
        uint _votingPeriod,
        uint _votingDelay
    ) {
        dao = _dao;
        owner = msg.sender;

        //初始化实现合约
        _delegateTo(
            _implementation,
            abi.encodeWithSignature(
                "initialize(address,address,address,uint256,uint256)",
                _dao,
                _timelock,
                _token,
                _votingPeriod,
                _votingDelay
            )
        );
        setImplementation(_implementation);
    }

    modifier onlyAdmin() {
        require(
            JCDao(dao).isDaoAdmin(msg.sender) || msg.sender == owner,
            "Governor:_setImplementation: admin&owner only"
        );
        _;
    }

    function setImplementation(address _implementation) public onlyAdmin{
        require(
            _implementation != address(0),
            "Governor:_setImplementation: invalid implementation address"
        );

        address oldImplementation = implementation;
        implementation = _implementation;

        emit NewImplementation(oldImplementation, implementation);
    }

    
    function _delegateTo(address callee, bytes memory data) public {
        (bool success, bytes memory returnData) = callee.delegatecall(data);
        assembly {
            if eq(success, 0) {
                revert(add(returnData, 0x20), returndatasize())
            }
        }
    }
    
    /**
     * @dev 回调函数，将本合约的调用委托给 `implementation` 合约
     * 通过assembly，让回调函数也能有返回值
     */
     fallback() external payable {
        // delegate all other functions to current implementation
        
        (bool success, ) = implementation.delegatecall(msg.data);

        assembly {
            let free_mem_ptr := mload(0x40)
            returndatacopy(free_mem_ptr, 0, returndatasize())

            switch success
            case 0 {
                revert(free_mem_ptr, returndatasize())
            }
            default {
                return(free_mem_ptr, returndatasize())
            }
        }
         emit FallbackTriggered(msg.sender, msg.data);
    }
}
