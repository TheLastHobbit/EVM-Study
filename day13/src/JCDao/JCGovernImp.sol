pragma solidity ^0.8.20;

import {GovernorEvents, GovernImpV2} from "./util/GovernTool.sol";
import "./interface/IJCToken.sol";
import "./JCToken.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./interface/ItimeLock.sol";

import "./Dao.sol";
contract JCGovernImp is GovernorEvents, GovernImpV2 {
    address public jcToken;
    address public dao;

    uint public quorumVotes = 300 ether; //每个提案通过所需的最少票数

    function initialize(
        address _dao,
        address _timelock,
        address _token,
        uint _votingPeriod,
        uint _votingDelay
    ) public {
        require(
            address(timelock) == address(0),
            "GovernorBravo::initialize: can only initialize once"
        );
        require(
            _timelock != address(0),
            "GovernorBravo::initialize: invalid timelock address"
        );
        require(
            _token != address(0),
            "GovernorBravo::initialize: invalid comp address"
        );

        timelock = TimelockInterface(_timelock);
        jcToken = _token;
        votingPeriod = _votingPeriod;
        votingDelay = _votingDelay;
        dao = _dao;
    }

 
    /**
     * @dev 提议
     * @param targets 目标合约地址
     * @param values 转账金额
     * @param calldatas 调用数据
     * @param description 提议描述
     * @return proposalId 提议ID
     */
    function propose(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) external payable returns (uint proposalId) {
        return
            _proposeInternal(
                msg.sender,
                targets,
                values,
                signatures,
                calldatas,
                description
            );
    }

    function _proposeInternal(
        address proposer,
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) internal returns (uint) {
        // 在提交本次提案之前先判断上一个提案是否被处理：
        uint latestProposalId = latestProposalIds[proposer];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = state(
                latestProposalId
            );
            //
            require(
                proposersLatestProposalState != ProposalState.Active,
                "GovernorBravo::proposeInternal: one live proposal per proposer, found an already active proposal"
            );
            require(
                proposersLatestProposalState != ProposalState.Pending,
                "GovernorBravo::proposeInternal: one live proposal per proposer, found an already pending proposal"
            );
        }

        uint startBlock = block.number + votingDelay;
        uint endBlock = startBlock + votingPeriod;
        proposalCount++;

        uint newProposalID = proposalCount;
        Proposal storage newProposal = proposals[newProposalID];
    
        newProposal.id = newProposalID;
        newProposal.proposer = proposer;
        newProposal.targets = targets;
        newProposal.values = values;
        newProposal.signatures = signatures;
        newProposal.calldatas = calldatas;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        newProposal.forVotes = 0;
        newProposal.againstVotes = 0;
        newProposal.abstainVotes = 0;
        newProposal.canceled = false;
        newProposal.executed = false;

        latestProposalIds[newProposal.proposer] = newProposal.id;

        emit ProposalCreated(
            newProposal.id,
            proposer,
            targets,
            values,
            signatures,
            calldatas,
            startBlock,
            endBlock,
            description
        );

        return newProposal.id;
    }

    /**
     * @dev 投票
     * @param proposalId 提议ID
     * @param support 支持或反对或中立：0，1，2
     */
    function castVote(uint proposalId, uint8 support) external {
        emit VoteCast(
            msg.sender,
            proposalId,
            support,
            _castVoteInternal(msg.sender, proposalId, support),
            ""
        );  
    }
    /**
     * @dev 投票internal
     * @param voter 投票人
     * @param proposalId 提议ID
     * @param support 反对或支持或中立：0，1，2
     */
    function _castVoteInternal(
        address voter,
        uint proposalId,
        uint8 support
    ) internal returns (uint256) {
        require(
            state(proposalId) == ProposalState.Active,
            "GovernorBravo::castVoteInternal: voting is closed"
        );
        require(
            support <= 2,
            "GovernorBravo::castVoteInternal: invalid vote type"
        );
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        uint256 votes = IJCToken(jcToken).getPriorVotes(
            voter,
            proposal.startBlock
        );

        if (support == 0) {
            proposal.againstVotes = proposal.againstVotes + votes;
        } else if (support == 1) {
            proposal.forVotes = proposal.forVotes + votes;
        } else if (support == 2) {
            proposal.abstainVotes = proposal.abstainVotes + votes;
        }

        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = uint96(votes);

        return votes;
    }

    //提议被投票通过标准后可进入执行队列
    function queue(uint proposalId) external {
        require(
            state(proposalId) == ProposalState.Succeeded,
            "GovernorBravo::queue: proposal can only be queued if it is succeeded"
        );
        Proposal storage proposal = proposals[proposalId];
        uint eta = block.number + timelock.delay();
        for (uint i = 0; i < proposal.targets.length; i++) {
            _queueOrRevertInternal(
                proposal.targets[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                eta
            );
        }
        proposal.eta = eta; //成功进入执行队列后，设置执行时间戳
        emit ProposalQueued(proposalId, eta);
    }

    function _queueOrRevertInternal(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint eta
    ) internal {
        require(
            !timelock.queuedTransactions(
                keccak256(abi.encode(target, value, signature, data, eta))
            ),
            "GovernorBravo::queueOrRevertInternal: identical proposal action already queued at eta"
        );
        timelock.queueTransaction(target, value, signature, data, eta);
    }

    //执行提议
    function execute(uint proposalId) external payable {
        require(
            state(proposalId) == ProposalState.Queued,
            "GovernorBravo::execute: proposal can only be executed if it is queued"
        );

        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        // 执行提案中每一个动作。
        for (uint i = 0; i < proposal.targets.length; i++) {
            timelock.executeTransaction(
                proposal.targets[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                proposal.eta
            );
           
        }
        emit ProposalExecuted(proposalId);
    }

    //获取提案的状态&根据投票结果得出提案是否通过
    function state(uint proposalId) public view returns (ProposalState) {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) {
            return ProposalState.Canceled;
        } else if (block.number <= proposal.startBlock) {
            return ProposalState.Pending;
        } else if (block.number <= proposal.endBlock) {
            return ProposalState.Active;
        } else if (
            proposal.forVotes <= proposal.againstVotes ||
            proposal.forVotes < quorumVotes
        ) {
            return ProposalState.Defeated;
        } else if (proposal.eta == 0) {
            return ProposalState.Succeeded;
        } else if (proposal.executed) {
            return ProposalState.Executed;
        } else if (block.number >= proposal.eta + timelock.GRACE_PERIOD()) {
            return ProposalState.Expired;
        } else {
            return ProposalState.Queued;
        }
    }
}
