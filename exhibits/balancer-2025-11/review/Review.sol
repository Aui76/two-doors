// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellToken} from "dan/CellToken.sol";
import {WitnessClaimLib} from "dan/WitnessClaimLib.sol";
import {AuditResultV1} from "genesis-tools/AuditResultV1.sol";
import {Room3} from "./Room3.sol";

/// The Balancer room's review: what the stand, the filing and the tests share.
///
/// Balancer is staked in DAN. The row is pool A's runtime code hash with no deployed
/// address behind it, the swap rounding spec, and a bounty of 40 AUDIT. The visitor
/// is the auditor the draw gives the row to. While the row is in review, that
/// auditor files what the spec never says as a witness claim, and gives no verdict.
///
/// The finding is written in words in finding.json beside this file. The cell
/// receives only hashes, and each one is the keccak256 of one of those strings,
/// read here at run time.
library BalancerReview {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    string internal constant FINDING_PATH = "exhibits/balancer-2025-11/review/finding.json";

    /// The museum has no tools. A person read the pool's source in review and a
    /// person checked the finding against the specimens. These labels stand in the
    /// tools' place and say so. The row declares the first, the claim names it, and
    /// the re-run is judged by the second.
    bytes32 internal constant REVIEW_TOOL = keccak256("museum/balancer-2025-11: contracts reviewed by a person");
    bytes32 internal constant EVALUATOR_TOOL = keccak256("museum/balancer-2025-11: finding checked by a person");

    struct Finding {
        bytes32 invariantId;
        bytes32 location;
        bytes32 witness;
        bytes32 context;
    }

    function words() internal view returns (string memory) {
        return vm.readFile(FINDING_PATH);
    }

    function finding() internal view returns (Finding memory f) {
        string memory j = words();
        f.invariantId = keccak256(bytes(vm.parseJsonString(j, ".invariant.id")));
        f.location = keccak256(bytes(vm.parseJsonString(j, ".location")));
        f.witness = keccak256(bytes(vm.parseJsonString(j, ".witness")));
        f.context = keccak256(bytes(vm.parseJsonString(j, ".context")));
    }

    function binding(Finding memory f) internal pure returns (WitnessClaimLib.Binding memory) {
        return WitnessClaimLib.Binding({
            evaluatorToolId: EVALUATOR_TOOL,
            invariantId: f.invariantId,
            locationCommitment: f.location,
            witnessCommitment: f.witness,
            contextRoot: f.context
        });
    }

    /// The FAIL result the evaluator gives against the row: the pool's code hash
    /// and the spec, with the invariant failing at its location on its witness. The
    /// cell rebuilds this root from the claim and refuses any other, and the re-run
    /// must give the same root for the claim to be upheld.
    function failRoot(Finding memory f, bytes32 specHash) internal pure returns (bytes32) {
        return WitnessClaimLib.resultRoot(binding(f), Room3.POOL_A_CODEHASH, specHash, AuditResultV1.VERDICT_FAIL);
    }

    function declared() internal pure returns (bytes32[] memory tools) {
        tools = new bytes32[](1);
        tools[0] = REVIEW_TOOL;
    }

    /// File the row. Called as the protocol. A bare hash, no deployed address: the
    /// cell is asked about code, not about a place.
    function file(AuditCell cell, CellToken token, bytes32 specHash) internal returns (uint256 id) {
        token.approve(address(cell), Room3.BOUNTY);
        id = cell.submitArtifactAudit(
            Room3.POOL_A_CODEHASH, address(0), specHash, Room3.SPEC_TOOL, Room3.SPEC_ERRORS, Room3.BOUNTY, declared(), 0, 0
        );
    }

    /// The re-run's bounty: the least the claim module takes, half the row's.
    function rerunBounty() internal pure returns (uint256) {
        return (Room3.BOUNTY * 5_000) / 10_000;
    }
}
