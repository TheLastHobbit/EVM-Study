// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    // bytes32 private constant APPROVE_PERMIT_TYPEHASH =keccak256("Permit(address owner,address spender,uint256 NFTid,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0xfb3e9d431a0aefe96a11d2a0c850f5eaafaf15dabad6b0027953cc6d25bfad74;

    struct Permit {
        address owner;
        address spender;
        uint256 NFTid;
        uint256 nonce;
        uint256 deadline;
    }

    // computes the hash of a permit
    function getStructHash(Permit memory _permit)
        internal
        pure
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.NFTid,
                    _permit.nonce,
                    _permit.deadline
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(Permit memory _permit)
        public
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }
}