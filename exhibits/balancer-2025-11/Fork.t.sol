// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

/// The harness under the Balancer room.
///
/// Before anything is claimed about what the code did, the fork has to prove it
/// is standing where it says it is. This test does nothing but check that. If it
/// fails, nothing printed downstream of it can be trusted, because the bytes
/// were read somewhere else.
///
/// Every number here was pulled with a command against an archive node and is
/// recorded, with the command, in exhibits/balancer-2025-11/VERIFIED.md.
contract BalancerForkTest is Test {
    /// The last block before the drain: no Vault-heavy transaction sits in
    /// 23,717,390–396, and the first drain transaction is in 23,717,397.
    /// VERIFIED.md, "Held on the chain".
    uint256 internal constant FORK_BLOCK = 23_717_396;

    /// Monday 3 November 2025, 07:46:35 UTC.
    uint256 internal constant FORK_TIMESTAMP = 1_762_155_995;

    /// The Balancer V2 Vault. All 226 Swap events of the first drain transaction
    /// pass through it. Read at FORK_BLOCK: 24,512 bytes.
    address internal constant VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    /// keccak256 of the Vault's runtime code at FORK_BLOCK, from eth_getProof's
    /// codeHash field. A verdict on an address alone cannot be re-checked, because
    /// the code at an address can change; this hash is what the room binds, and it
    /// sits beside the address rather than replacing it. Kept by VD-310(1).
    bytes32 internal constant VAULT_CODEHASH =
        0x9eb70db20a41bfbf4b022fd070fa7f154b7c4aec98177120dde7a958384f4e66;

    /// The contract the first drain transaction creates. At FORK_BLOCK it does not
    /// exist yet: the transaction that deploys it is in the next block. The drain
    /// is a contract creation whose receipt's `to` is empty and whose
    /// `contractAddress` is this. VERIFIED.md, "Held on the chain".
    address internal constant DRAINER = 0x54B53503c0e2173Df29f8da735fBd45Ee8aBa30d;

    /// keccak256 of nothing at all.
    bytes32 internal constant EMPTY_CODEHASH =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
    }

    /// The fork is where it claims to be.
    function test_forkStandsAtTheNamedBlock() public view {
        assertEq(block.number, FORK_BLOCK, "fork is not at 23,717,396");
        assertEq(block.timestamp, FORK_TIMESTAMP, "block 23,717,396 has a different timestamp");
    }

    /// The Vault the exhibit is about is the one that was there.
    function test_vaultCodeIsTheCodeTheRoomNames() public view {
        bytes memory code = VAULT.code;
        assertEq(code.length, 24_512, "the Vault's code is a different length here");
        assertEq(keccak256(code), VAULT_CODEHASH, "the Vault's code hash does not match");
    }

    /// Nothing has been built on the rounding error yet. The flaw is already there,
    /// in deployed pool code, and the contract that will drain it has not been
    /// written. Anyone reading the pools that day could have found it. Nobody did
    /// until the block after this one.
    function test_theDrainerHasNotBeenDeployedYet() public view {
        assertEq(DRAINER.code.length, 0, "the drainer already has code at this block");
        assertEq(keccak256(DRAINER.code), EMPTY_CODEHASH, "the drainer is not empty at this block");
    }
}
