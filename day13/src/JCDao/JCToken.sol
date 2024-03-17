// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./interface/IJCToken.sol";
import "./util/SafeMath.sol";
contract JCToken is ERC20, IJCToken {
    using SafeMath for uint256;

    address public owner;
    address public dao;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint256 fromBlock;
        uint256 votes;
    }

    mapping(address => address) public delegates;

    /// @notice A record of votes checkpoints for each account, by index
    mapping(address => mapping(uint256 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping(address => uint256) public numCheckpoints;

    event DelegateChanged(
        address indexed delegator,
        address indexed fromDelegate,
        address indexed toDelegate
    );

    event DelegateVotesChanged(
        address indexed delegate,
        uint previousBalance,
        uint newBalance
    );

    constructor() ERC20("JCDao_Token", "JCT") {
        owner = msg.sender;
    }

        modifier onlyDao() {
        require(msg.sender == dao, "Only the DAO can call this function");
        _;
    }

    function setDao(address _dao) external {
        require(msg.sender == owner, "Only the owner can call this function");
        dao = _dao;
    }

    function mintDao(address account, uint256 amount) external onlyDao {
        _mint(account, amount);
    }

    function delegate(address delegatee) public {
        return _delegate(msg.sender, delegatee);
    }

    function _delegate(address delegator, address delegatee) internal {
        address currentDelegate = delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator);
        delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(
        address fromRep,
        address toRep,
        uint256 amount
    ) internal {
        if (fromRep != toRep && amount > 0) {
            if (fromRep != address(0)) {
                uint256 fromRepNum = numCheckpoints[fromRep];
                uint256 fromRepOld = fromRepNum > 0
                    ? checkpoints[fromRep][fromRepNum - 1].votes
                    : 0;
                uint256 fromRepNew = fromRepOld.sub(amount);
                _writeCheckpoint(fromRep, fromRepNum, fromRepOld, fromRepNew);
            }

            if (toRep != address(0)) {
                uint256 toRepNum = numCheckpoints[toRep];
                uint256 toRepOld = toRepNum > 0
                    ? checkpoints[toRep][toRepNum - 1].votes
                    : 0;
                uint256 toRepNew = amount.add(toRepOld);
                _writeCheckpoint(toRep, toRepNum, toRepOld, toRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint256 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    ) internal {
        uint256 blockNumber =block.number;
        if (
            nCheckpoints > 0 &&
            checkpoints[delegatee][nCheckpoints - 1].fromBlock ==  blockNumber
        ) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(
                blockNumber,
                newVotes
            );
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    //计票函数：
    function getPriorVotes(
        address account,
        uint blockNumber
    ) external view returns (uint256) {
        require(
            blockNumber < block.number,
            "Comp::getPriorVotes: not yet determined"
        );
        uint256 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }
        
        uint256 lower = 0;
        uint256 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint256 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function getCurrentVotes(address account) external view returns (uint256) {
        uint256 nCheckpoints = numCheckpoints[account];
        return
            nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }
}
