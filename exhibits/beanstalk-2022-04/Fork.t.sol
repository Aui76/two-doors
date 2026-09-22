// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

/// The harness under the first room.
///
/// Before anything is claimed about what the code did, the fork has to prove it
/// is standing where it says it is. This test does nothing but check that. If it
/// fails, nothing printed downstream of it can be trusted, because the bytes
/// were read somewhere else.
///
/// The numbers here are not typed from a write up. Each one was pulled with a
/// command, and the command is written beside it in PROVENANCE.md.
contract BeanstalkForkTest is Test {
    /// The block DeFiHackLabs forks at, taken from their own test file rather
    /// than from a description of it: src/test/2022-04/Beanstalk_exp.sol reads
    /// cheat.createSelectFork("mainnet", 14_595_905).
    uint256 internal constant FORK_BLOCK = 14_595_905;

    /// Saturday 16 April 2022, 10:54:42 UTC.
    uint256 internal constant FORK_TIMESTAMP = 1_650_106_482;

    /// Beanstalk. Silo, governance and the rest sit behind one diamond.
    address internal constant BEANSTALK = 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5;

    /// The proposal contract the attacker submitted as BIP 18. At this block it
    /// does not exist yet.
    address internal constant BIP18 = 0xE5eCF73603D98A0128F05ed30506ac7A663dBb69;

    /// keccak256 of the diamond's runtime code at FORK_BLOCK, 5547 bytes.
    /// A verdict on an address alone cannot be re-checked, because the code at an
    /// address can change. This hash is what the verdict binds, and it sits beside
    /// the address rather than replacing it.
    bytes32 internal constant BEANSTALK_CODEHASH =
        0x2ff59388cd5e1842a3d057338010945a779a6c7d57abfb5e9ddc697838700870;

    /// keccak256 of nothing at all.
    bytes32 internal constant EMPTY_CODEHASH =
        0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
    }

    /// The fork is where it claims to be.
    function test_forkStandsAtTheNamedBlock() public view {
        assertEq(block.number, FORK_BLOCK, "fork is not at 14,595,905");
        assertEq(block.timestamp, FORK_TIMESTAMP, "block 14,595,905 has a different timestamp");
    }

    /// The contract the exhibit is about is the one that was there.
    function test_beanstalkCodeIsTheCodeTheVerdictNames() public view {
        bytes memory code = BEANSTALK.code;
        assertEq(code.length, 5547, "the diamond's code is a different length here");
        assertEq(keccak256(code), BEANSTALK_CODEHASH, "the diamond's code hash does not match");
    }

    /// Nothing has been built on the loophole yet. This is the whole point of the
    /// room: the flaw is already there, in deployed code, and the thing that will
    /// use it has not been written. Anyone reading the contract that day could
    /// have found it. Nobody did.
    function test_theAttackHasNotBeenWrittenYet() public view {
        assertEq(BIP18.code.length, 0, "BIP 18 already has code at this block");
        assertEq(keccak256(BIP18.code), EMPTY_CODEHASH, "BIP 18 is not empty at this block");
    }
}
