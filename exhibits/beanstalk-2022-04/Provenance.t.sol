// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";

/// The spec is only honest if the words under it are the words Beanstalk published
/// before it was drained. `spec/SOURCES.md` says which bytes those were. This test
/// re-hashes them and fails if a single one has moved.
///
/// It runs offline. Nothing here needs an RPC, which is the point: a reader with the
/// repository and nothing else can still check that the vendored sources are the ones
/// the provenance claims.
contract ProvenanceTest is Test {
    string internal constant DIR = "specimens/beanstalk-2022-04/";

    function _sha256Of(string memory name) internal view returns (bytes32) {
        return sha256(bytes(vm.readFile(string.concat(DIR, name))));
    }

    /// Every hash below is copied from spec/SOURCES.md, which in turn records what
    /// arrived from raw.githubusercontent.com at commit e9f4991 on 23 September 2026.
    function test_vendoredSourcesAreUnmodified() public view {
        assertEq(
            _sha256Of("GovernanceFacet.sol"),
            0x27938091a8fd181e62246d9f365e3d5523d8b825b1c562243ffa9d6db908efad,
            "GovernanceFacet.sol has changed"
        );
        assertEq(
            _sha256Of("Bip.sol"),
            0xef726c967c38bfab4474b64942efb534694d06473f2fd91ddc5a807d382b73f7,
            "Bip.sol has changed"
        );
        assertEq(
            _sha256Of("VotingBooth.sol"),
            0x8f4bc3b86403814495490089e4300da66f42b34bdd4210d82bbf9abf7e2fe484,
            "VotingBooth.sol has changed"
        );
        assertEq(
            _sha256Of("C.sol"),
            0xd32adf7a7344fa132703f5c54b0f56419499c77ec5d876cc93ace279f5a4b40d,
            "C.sol has changed"
        );
    }

    /// The numbers the spec's time and threshold invariants rest on are constants in
    /// Beanstalk's own C.sol. Reading them out of the vendored file rather than
    /// restating them keeps one copy of each fact. If Beanstalk's line changes, this
    /// fails rather than drifting quietly away from the spec.
    function test_governanceConstantsAreTheOnesTheSpecCites() public view {
        string memory c = vm.readFile(string.concat(DIR, "C.sol"));
        assertTrue(vm.contains(c, "GOVERNANCE_PERIOD = 168"), "voting period is not 168 seasons");
        assertTrue(vm.contains(c, "GOVERNANCE_EMERGENCY_PERIOD = 86400"), "emergency wait is not one day");
        assertTrue(vm.contains(c, "GOVERNANCE_PASS_THRESHOLD = 5e17"), "pass threshold is not one half");
        assertTrue(vm.contains(c, "GOVERNANCE_EMERGENCY_THRESHOLD_NUMERATOR = 2"), "supermajority numerator is not 2");
        assertTrue(vm.contains(c, "GOVERNANCE_EMERGENCY_THRESHOLD_DEMONINATOR = 3"), "supermajority denominator is not 3");
        assertTrue(vm.contains(c, "GOVERNANCE_PROPOSAL_THRESHOLD = 0.001e18"), "proposal threshold is not 0.1%");
        assertTrue(vm.contains(c, "MAX_PROPOSITIONS = 5"), "proposition cap is not 5");
    }

    /// Every invariant in the spec has to name where it came from. A spec line with no
    /// source is exactly the thing this exhibit exists to argue against.
    function test_everyInvariantNamesItsSource() public view {
        string memory spec = vm.readFile("exhibits/beanstalk-2022-04/spec/governance-v0.json");
        string[14] memory ids = [
            "propose-requires-threshold-stake",
            "propose-caps-active-propositions",
            "propose-rejects-empty-proposition",
            "proposer-votes-and-is-bound",
            "vote-requires-silo-membership",
            "vote-only-while-nominated-and-active",
            "vote-weight-is-proportional-to-stalk",
            "voting-locks-the-voter-until-the-period-ends",
            "commit-requires-ended-period-and-majority",
            "emergency-commit-requires-day-and-supermajority",
            "pause-bip-carries-no-code",
            "owner-pause-is-the-only-unilateral-power",
            "a-bip-executes-at-most-once",
            "the-only-mint-is-the-commit-incentive"
        ];
        for (uint256 i = 0; i < ids.length; i++) {
            assertTrue(vm.contains(spec, ids[i]), string.concat("spec is missing invariant ", ids[i]));
        }
        // 14 invariants, 14 _source lines. Counted rather than assumed.
        assertEq(_countOf(spec, "\"_source\""), 14, "an invariant has no _source");
    }

    function _countOf(string memory haystack, string memory needle) internal pure returns (uint256 n) {
        bytes memory h = bytes(haystack);
        bytes memory k = bytes(needle);
        if (k.length == 0 || h.length < k.length) return 0;
        for (uint256 i = 0; i + k.length <= h.length; i++) {
            bool hit = true;
            for (uint256 j = 0; j < k.length; j++) {
                if (h[i + j] != k[j]) {
                    hit = false;
                    break;
                }
            }
            if (hit) n++;
        }
    }
}
