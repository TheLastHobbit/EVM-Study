//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./NFT.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "./ERC2612.sol";

// 使用mlticall同时调用下面两个方法
import "openzeppelin-contracts/contracts/utils/Multicall.sol";
contract AirdropNFT is Multicall {
    bytes32 public immutable merkleRoot;
    MyNFT public erc721;
    address public token;
    address private owner;
    uint256 private amount;


    event Claimed(address account, uint256 amount);

    constructor(bytes32 merkleRoot_, MyNFT erc721_,address _token) {
        merkleRoot = merkleRoot_;
        erc721 = erc721_;
        token = _token;
        owner = msg.sender;
    }
    
    // erc20 permit
    function permitPrePay(address user, uint _amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(token).permit(user, address(this), amount, deadline, v, r, s);
        amount = _amount;
    
    }

    function claimNFT(
        address account,
        uint256 NFTid,
        bytes32[] calldata merkleProof
    ) public {
        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(account, NFTid));

        require(
            MerkleProof.verify(merkleProof, merkleRoot, node),
            "MerkleDistributor: Invalid proof."
        );
        IERC20(token).transferFrom(account,owner,amount);
        erc721.safeTransferFrom(owner, account, NFTid);
        emit Claimed(account, amount);
    }

    function getEncode() public view returns(bytes memory){
        return abi.encodeWithSignature("claimNFT(address,uint256,bytes32[])");
    }

}