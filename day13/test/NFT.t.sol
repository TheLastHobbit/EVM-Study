pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFT.sol";
import "../src/SigUtils.sol";

contract ERC20Test is Test {
    MyNFT internal nft;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    function setUp() public {
        nft = new MyNFT();
        sigUtils = new SigUtils(nft.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        nft.mint(owner, 1);
        nft.mint(owner, 1);
        nft.mint(owner, 1);
    }

    function test_ApprovePermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            NFTid: 1,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        nft.Approvepermit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(nft.allowance(owner, spender), 1);
        assertEq(nft.nonces(owner), 1);
    }

}