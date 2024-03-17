// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.20;
import {Test, console} from "forge-std/Test.sol";

import "./interface/ItimeLock.sol";
import "./util/SafeMath.sol";
import "./Dao.sol";
contract TimeLock is TimelockInterface {
    using SafeMath for uint;

    address public admin;
    address public pendingAdmin;

    uint public delay;//在提案生效前的一段宽限期，可以选择不接受此提案而退出。
    uint public constant GRACE_PERIOD = 10; 

    mapping(bytes32 => bool) public queuedTransactions;

    event NewDelay(uint indexed newDelay);
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint eta
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint eta
    );
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint value,
        string signature,
        bytes data,
        uint eta
    );

    constructor(address _admin, uint _delay) public {
        admin = _admin;
        delay = _delay;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == pendingAdmin,
            "Timelock::onlyAdmin: Call must come from pendingAdmin."
        );
        _;
    }

    //pendingAdmin一般为治理合约
    function setAdmin(address _admin) public {
        require(msg.sender == admin, "call must by admin");
        require(
            _admin != address(0),
            "Timelock::setAdmin: New admin cannot be the zero address."
        );
        pendingAdmin = _admin;
    }

    function setDelay(uint _delay) public onlyAdmin {
        require(
            msg.sender == address(this),
            "Timelock::setDelay: Call must come from Timelock."
        );
        delay = _delay;

        emit NewDelay(delay);
    }

    //将在执行队列中的提案信息hash，并设此提案hash为true，代表此提案已入队列
    function queueTransaction(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint eta
    ) public onlyAdmin returns (bytes32) {
        require(
            eta >= getBlockTimestamp().add(delay),
            "Timelock::queueTransaction: Estimated execution block must satisfy delay."
        );

        bytes32 txHash = keccak256(
            abi.encode(target, value, signature, data, eta)
        );
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, eta);
        return txHash;
    }

    //取消提案
    function cancelTransaction(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint eta
    ) public onlyAdmin {
        bytes32 txHash = keccak256(
            abi.encode(target, value, signature, data, eta)
        );
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }

    //执行队列中的提案，这里一般是
    function executeTransaction(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint eta
    ) public payable onlyAdmin returns (bytes memory) {
        bytes32 txHash = keccak256(
            abi.encode(target, value, signature, data, eta)
        );
        require(
            queuedTransactions[txHash],
            "Timelock::executeTransaction: Transaction hasn't been queued."
        );
        require(
            getBlockTimestamp() >= eta,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );

        queuedTransactions[txHash] = false;

        bytes memory callData;
        // 如果没有签名，直接调用data
        if (bytes(signature).length == 0) {
            console.log("2222");
            callData = data;
        } else {
            // 如果有签名,将签名和data打包
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
        }
        console.log("msg.sender:",msg.sender);
        // 执行提案中要执行的target合约交易
        (bool success, bytes memory returnData) = target.call{value: value}(
            callData
        );
        require(
            success,
            "Timelock::executeTransaction: Transaction execution reverted."
        );

        emit ExecuteTransaction(txHash, target, value, signature, data, eta);

        return returnData;
    }

    function getBlockTimestamp() internal view returns (uint) {
        return block.number;
    }
}
