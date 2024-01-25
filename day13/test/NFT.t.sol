pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/NFT.sol";
import "../src/SigUtils.sol";

contract NFTTest is Test {
    MyNFT internal nft;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    function setUp() public {
        

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        vm.startPrank(owner);{
        console.log("owner address: ", owner);
        nft = new MyNFT();
        sigUtils = new SigUtils(nft.DOMAIN_SEPARATOR());
        console.log("nft address: ", address(nft));
        nft.safeMint(owner, "1");
        nft.safeMint(owner, "1");
        nft.safeMint(owner,"1");
        }
        vm.stopPrank();
    }

    function test_ApprovePermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            NFTid: 1,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });
        console.log("owner address: ", owner);

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        console.log("owner: ", owner);

        nft.Approvepermit(
            owner,
            spender,
            permit.NFTid,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(nft._getApproved(1),spender);
        assertEq(nft.nonces(owner), 1);
    }

}