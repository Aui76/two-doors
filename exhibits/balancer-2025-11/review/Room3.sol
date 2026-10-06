// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Room 3: what the Balancer room's review shares.
///
/// The numbers are the ones spec/SOURCES.md pulled from the chain with the commands
/// written beside them, and Fork.t.sol forks the same block. Never typed from a
/// description.
library Room3 {
    uint256 internal constant FORK_BLOCK = 23_717_396;

    /// The first pool the drain touched: Balancer osETH/wETH StablePool, a
    /// composable stable pool, version 5. Its runtime code hash at the fork block is
    /// what the row is filed against, with no deployed address behind it.
    address internal constant POOL_A = 0xDACf5Fa19b1f720111609043ac67A9818262850c;
    bytes32 internal constant POOL_A_CODEHASH = 0x72b6e1b187e715820b74d4243533145e6d2d0e168101fd8b27be6f5be80ca441;
    uint256 internal constant POOL_A_CODE_LENGTH = 24_280;
    address internal constant VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    /// The spec the row names. Its hash is read from the file at run time, never
    /// pasted in.
    string internal constant SPEC_PATH = "exhibits/balancer-2025-11/spec/swap-rounding-v0.json";

    /// As in Room 1, the museum has no spec tool. A person read the pool's source
    /// and wrote the spec, and this label stands in the tool's place and says so.
    bytes32 internal constant SPEC_TOOL = keccak256("museum/balancer-2025-11: spec read by a person");

    /// The spec validator recorded no errors against the spec.
    bytes32 internal constant SPEC_ERRORS = keccak256("");

    /// Bounty in the cell's own token, the same as Room 1's row.
    uint256 internal constant BOUNTY = 40 ether;
}
