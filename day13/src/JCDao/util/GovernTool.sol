// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;
import "../interface/ItimeLock.sol";
contract GovernorEvents {
    /// @notice Emitted when implementation is changed
    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint id);

    /// @notice An event emitted when a proposal has been queued in the Timelock
    event ProposalQueued(uint id, uint eta);

    /// @notice An event emitted when a proposal has been executed in the Timelock
    event ProposalExecuted(uint id);

    event ProposalCreated(
        uint id,
        address proposer,
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        uint startBlock,
        uint endBlock,
        string description
    );

    event VoteCast(
        address indexed voter,
        uint proposalId,
        uint8 support,
        uint votes,
        string reason
    );
}

contract GovernImpV1 {
    address public admin;

    address public pendingAdmin;

    address public implementation;
}

contract GovernImpV2 is GovernImpV1 {
    /// @notice The delay before voting on a proposal may take place, once proposed, in blocks
    uint public votingDelay;

    /// @notice The duration of voting on a proposal, in blocks
    uint public votingPeriod;

    /// @notice The official record of all proposals ever proposed
    mapping(uint => Proposal) public proposals;

    /// @notice The latest proposal for each proposer
    mapping(address => uint) public latestProposalIds;

    /// @notice The total number of proposals
    uint public proposalCount;

    /// @notice The address of the Compound Protocol Timelock
    TimelockInterface public timelock;

    struct Proposal {
        uint id;
        address proposer;
        uint eta; //提案可用于执行的时间戳，在投票成功后设置
        address[] targets;
        uint[] values;
        string[] signatures;
        bytes[] calldatas;
        uint startBlock;
        uint endBlock;
        uint forVotes;
        uint againstVotes;
        uint abstainVotes;
        bool canceled;
        bool executed;
        mapping(address => Receipt) receipts;
    }

    /// @notice Ballot receipt record for a voter
    struct Receipt {
        bool hasVoted;
        uint8 support;
        uint96 votes;
    }

    enum ProposalState {
        Pending,
        Active, //在投票中
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired, //过期了
        Executed
    }
}
