// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Vm} from "forge-std/Vm.sol";
import {WitnessClaimLib} from "dan/WitnessClaimLib.sol";
import {AuditResultV1} from "genesis-tools/AuditResultV1.sol";
import {Room1} from "../verdict/Room1.sol";

/// Room 2, door two: the discoverer's filing.
///
/// What the stand, the filing script and the tests share. The gap is written in
/// words in gap.json beside this file. The cell receives only hashes, and each one
/// is the keccak256 of one of those strings, read here at run time.
///
/// The row the gap is filed against is Room 1's row, filed on the fixture the way
/// Room 1 files it: the Beanstalk code hash with no deployed address behind it, the
/// governance spec, Room 1's tool labels.
library Room2 {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    string internal constant GAP_PATH = "exhibits/beanstalk-2022-04/filing/gap.json";

    /// As in Room 1, the museum has no finder tool and no evaluator tool. A person
    /// found the gap and a person checked it against the specimens. These labels
    /// stand in the tools' place and say so.
    bytes32 internal constant FINDER_TOOL = keccak256("museum/beanstalk-2022-04: gap found by a person");
    bytes32 internal constant EVALUATOR_TOOL = keccak256("museum/beanstalk-2022-04: gap checked by a person");

    struct Gap {
        bytes32 classId;
        bytes32 invariantId;
        bytes32 location;
        bytes32 witness;
        bytes32 context;
    }

    function words() internal view returns (string memory) {
        return vm.readFile(GAP_PATH);
    }

    function gap() internal view returns (Gap memory g) {
        string memory j = words();
        g.classId = keccak256(bytes(vm.parseJsonString(j, ".class")));
        g.invariantId = keccak256(bytes(vm.parseJsonString(j, ".invariant.id")));
        g.location = keccak256(bytes(vm.parseJsonString(j, ".location")));
        g.witness = keccak256(bytes(vm.parseJsonString(j, ".witness")));
        g.context = keccak256(bytes(vm.parseJsonString(j, ".context")));
    }

    function binding(Gap memory g) internal pure returns (WitnessClaimLib.Binding memory) {
        return WitnessClaimLib.Binding({
            evaluatorToolId: EVALUATOR_TOOL,
            invariantId: g.invariantId,
            locationCommitment: g.location,
            witnessCommitment: g.witness,
            contextRoot: g.context
        });
    }

    /// The FAIL result the evaluator gives against Room 1's row: the row's own code
    /// hash and spec, with the gap's invariant failing at its location on its
    /// witness. The cell rebuilds this root from the filing and refuses any other.
    function resultRoot(Gap memory g, bytes32 specHash) internal pure returns (bytes32) {
        return WitnessClaimLib.resultRoot(binding(g), Room1.BEANSTALK_CODEHASH, specHash, AuditResultV1.VERDICT_FAIL);
    }
}
