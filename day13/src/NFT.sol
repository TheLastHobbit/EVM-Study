// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "lib/openzeppelin-contracts/contracts/utils/Nonces.sol";

import {console} from "forge-std/console.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable,EIP712, Nonces {
    uint256 private _nextTokenId;

    constructor() ERC721("MyNFT", "NFT") Ownable(msg.sender)EIP712("NFT","1") {}
    event print(bytes32 msg);

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    bytes32 private constant NFT_PERMIT_TYPEHASH =keccak256("Permit(address owner,uint256 deadline)");
    bytes32 private constant APPROVE_PERMIT_TYPEHASH =keccak256("Approvepermit(address owner,address spender,uint256 NFTid,uint256 deadline)");
    
    error NFTExpiredSignature(uint ddl);
    error NFTInvalidSigner(address s,address o);
    function NFTpermit(
        address owner,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        if (block.timestamp > deadline) {
            revert NFTExpiredSignature(deadline);
        }

        bytes32 structHash = keccak256(abi.encode(NFT_PERMIT_TYPEHASH, owner, _useNonce(owner), deadline));

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert NFTInvalidSigner(signer, owner);
        }
    }

    

     function Approvepermit(
        address owner,
        address spender,
        uint256 NFTid,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        if (block.timestamp > deadline) {
            revert NFTExpiredSignature(deadline);
        }
        // 获取
        emit print(APPROVE_PERMIT_TYPEHASH);

        bytes32 structHash = keccak256(abi.encode(APPROVE_PERMIT_TYPEHASH, owner, spender, NFTid, _useNonce(owner), deadline));
        
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != owner) {
            revert NFTInvalidSigner(signer, owner);
        }
        _approve(spender,NFTid,owner);
    }



    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

     function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }

    
}
