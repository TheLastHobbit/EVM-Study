// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    // bytes32 private constant APPROVE_PERMIT_TYPEHASH =keccak256("Approvepermit(address owner,address spender,uint256 NFTid,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x600c4ec2714a5bf2b07a39ffefb4fa8210836f9fb40ce0b67dae3e4ef0366a3a;

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