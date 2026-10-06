// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployCell} from "deps/dan/cell/script/DeployCell.s.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {StandTheReview, FileTheFinding, ReviewCore} from "./review/Review.s.sol";
import {Review} from "./review/Review.sol";
import {Room1} from "./verdict/Room1.sol";
import {Room2} from "./filing/Room2.sol";

/// The review's freeze check, reached from a test (VD-273(4)).
contract FrozenFinding is FileTheFinding {
    function check(string memory stood) external view {
        _requireTheWordsTheStandFroze(stood);
    }
}

/// The auditor's room, proven in memory before any node sees it: the fixture stood
/// as the stand stands it, the review filed, the re-run confirmed. The filing reads
/// itself back on every run (Review.s.sol, _readBackReview); these tests add what
/// follows it, and what it refuses.
///
/// No fork and no archive key: the fixture is a fresh deploy, not 2022 state.
contract ReviewTest is Test {
    /// Made up for these tests, as in FixtureTest. Not anvil's, not the network's.
    uint256 internal constant KEY = 0xF1C5;
    address internal auditor;
    uint256 internal auditorKey;
    address internal stranger;
    uint256 internal strangerKey;
    StandTheReview internal stand;
    FileTheFinding internal review;

    function setUp() public {
        (auditor, auditorKey) = makeAddrAndKey("the drawn auditor");
        (stranger, strangerKey) = makeAddrAndKey("the re-run's auditor");
        stand = new StandTheReview();
        review = new FileTheFinding();
    }

    function _stand() internal returns (DeployCell.Deployed memory) {
        return stand.standWith(KEY, auditor, false);
    }

    function _file() internal returns (DeployCell.Deployed memory d, ReviewCore.Filed memory r) {
        d = _stand();
        r = review.fileWith(d, KEY, auditorKey, strangerKey);
    }

    /// Every hash-bearing word in finding.json is found again in the file it names.
    function test_theFindingsWordsPointAtTheirSources() public view {
        string memory j = Review.words();
        string memory location = vm.parseJsonString(j, ".location");
        string memory witness = vm.parseJsonString(j, ".witness");
        string memory context = vm.parseJsonString(j, ".context");

        string memory booth = vm.readFile("specimens/beanstalk-2022-04/VotingBooth.sol");
        string memory facet = vm.readFile("specimens/beanstalk-2022-04/GovernanceFacet.sol");
        assertTrue(vm.contains(location, vm.toString(sha256(bytes(booth)))), "VotingBooth.sol hash");
        assertTrue(vm.contains(location, vm.toString(sha256(bytes(facet)))), "GovernanceFacet.sol hash");
        assertTrue(vm.contains(booth, "roots.add(balanceOfRoots(account))"), "the line the location names");
        assertTrue(vm.contains(facet, "function emergencyCommit(uint32 bip)"), "the function the location names");

        string memory replay = vm.parseJsonString(j, "._pins.replayReference");
        assertTrue(vm.contains(witness, replay), "witness names the replay reference");
        assertTrue(
            vm.contains(vm.readFile("exhibits/beanstalk-2022-04/replay/README.md"), replay),
            "the replay README pins the same reference"
        );
        string memory bip18 = vm.parseJsonString(j, "._pins.bip18");
        assertTrue(vm.contains(witness, bip18), "witness names BIP 18");
        assertTrue(
            vm.contains(vm.readFile("exhibits/beanstalk-2022-04/Fork.t.sol"), bip18), "Fork.t.sol proves the same address"
        );

        assertTrue(vm.contains(context, vm.toString(Room1.BEANSTALK)), "context: the diamond");
        assertTrue(vm.contains(context, vm.toString(Room1.BEANSTALK_CODEHASH)), "context: its code hash");
        assertTrue(vm.contains(context, vm.toString(Room1.FORK_BLOCK)), "context: the block");
        assertTrue(vm.contains(witness, vm.toString(Room1.FORK_BLOCK)), "witness: the block");
    }

    /// finding.json says its words are the ones the discoverer filed on the second
    /// fixture. The hashes prove it.
    function test_theFindingIsTheGapsWords() public view {
        Review.Finding memory f = Review.finding();
        Room2.Gap memory g = Room2.gap();
        assertEq(f.invariantId, g.invariantId, "invariant");
        assertEq(f.location, g.location, "location");
        assertEq(f.witness, g.witness, "witness");
        assertEq(f.context, g.context, "context");
    }

    function test_standRegistersTheRoomsToolsAndFundsOneReview() public {
        DeployCell.Deployed memory d = _stand();
        (,, bool isEval, bool canonical, bool exists,,) = d.cell.tools(Review.EVALUATOR_TOOL);
        assertTrue(exists && isEval && canonical, "evaluator flagged canonical by the stand");
        uint256 stake = (Room1.BOUNTY * d.cell.claimStakeBps()) / 10_000;
        if (stake < d.cell.claimFilingStake()) stake = d.cell.claimFilingStake();
        assertEq(d.token.balanceOf(vm.addr(KEY)), Room1.BOUNTY + stake + Review.rerunBounty(), "one review's worth");
    }

    /// The whole room: in review, before any verdict, the drawn auditor files the
    /// finding; a stranger runs it again and gets the same FAIL; once the re-run's
    /// window has passed anyone confirms it, and the row is Exploited.
    function test_theAuditorFilesInReviewAndIsPaid() public {
        (DeployCell.Deployed memory d, ReviewCore.Filed memory r) = _file();
        AuditCell c = d.cell;
        assertEq(uint256(c.auditStateOf(r.auditId)), uint256(CellTypeDefs.AuditState.Claimed));
        assertEq(
            uint256(c.getAudit(r.auditId).stateBeforeClaim),
            uint256(CellTypeDefs.AuditState.InAudit),
            "claimed from review, not after a PASS"
        );
        assertEq(c.auditVerdictToolId(r.auditId), bytes32(0), "there is no PASS and no FAIL on the row");
        assertEq(r.stake, c.requiredClaimStake(r.auditId), "the stake the cell asks");

        uint256 pot = c.getAudit(r.auditId).bounty;
        uint256 poolBefore = d.escrow.escrowBalance();
        uint256 auditorBefore = d.token.balanceOf(auditor);
        uint256 protocolBefore = d.token.balanceOf(r.protocol);
        uint256 strangerBefore = d.token.balanceOf(stranger);

        vm.warp(vm.getBlockTimestamp() + c.minAuditWindow() + 1);
        vm.prank(makeAddr("anyone"));
        c.confirmAudit(r.disputeId);

        assertEq(uint256(c.auditStateOf(r.auditId)), uint256(CellTypeDefs.AuditState.Exploited));

        // DiscovererPayoutLib.pay: the target is the larger of the pool's share and
        // the pot's floor, capped at the pot; the pool pays first, the pot tops up
        // the shortfall, the rest of the pot goes back to the protocol. The stake
        // comes back whole.
        uint256 poolShare = (poolBefore * c.discoveryCapBps()) / 10_000;
        uint256 floorShare = (pot * c.discoveryFloorBps()) / 10_000;
        uint256 target = poolShare > floorShare ? poolShare : floorShare;
        if (target > pot) target = pot;
        uint256 auditorAfter = d.token.balanceOf(auditor);
        uint256 refund = d.token.balanceOf(r.protocol) - protocolBefore;
        emit log_named_decimal_uint("the pot", pot, 18);
        emit log_named_decimal_uint("the pool before the confirmation", poolBefore, 18);
        emit log_named_decimal_uint("the auditor holds after", auditorAfter, 18);
        emit log_named_decimal_uint("returned to the protocol", refund, 18);
        emit log_named_decimal_uint("the re-run's auditor holds after", d.token.balanceOf(stranger) - strangerBefore, 18);
        assertEq(auditorBefore, 0, "the auditor staked all it was handed");
        assertEq(auditorAfter, r.stake + target, "the stake back and the target the rule sets");
        assertLe(refund, pot, "the protocol cannot get back more than the pot");

        (, uint256 failed, uint256 found,,,) = c.auditors(auditor);
        assertEq(failed, 0, "the auditor gave no verdict to be wrong about");
        assertEq(found, 1, "and is counted as having found one");
    }

    /// The re-run settles only once its own window has passed.
    function test_theReRunWaitsForItsWindow() public {
        (DeployCell.Deployed memory d, ReviewCore.Filed memory r) = _file();
        CellTypeDefs.Audit memory a = d.cell.getAudit(r.disputeId);
        vm.warp(a.windowStart + a.auditWindow - 1);
        vm.expectRevert();
        d.cell.confirmAudit(r.disputeId);
        assertEq(uint256(d.cell.auditStateOf(r.auditId)), uint256(CellTypeDefs.AuditState.Claimed));
    }

    function test_refusesThreeSeatsOnTwoKeys() public {
        DeployCell.Deployed memory d = _stand();
        string memory why =
            "three seats, three keys: the hull refuses the re-run to the filer, and the fixture key audits nothing";
        vm.expectRevert(bytes(why));
        review.fileWith(d, KEY, auditorKey, auditorKey);
        vm.expectRevert(bytes(why));
        review.fileWith(d, KEY, auditorKey, KEY);
    }

    function test_refusesAnAuditorTheStandDidNotName() public {
        DeployCell.Deployed memory d = _stand();
        (, uint256 otherKey) = makeAddrAndKey("not the named auditor");
        vm.expectRevert(bytes("AUDITOR_KEY is not the fixture's genesis auditor"));
        review.fileWith(d, KEY, otherKey, strangerKey);
    }

    function test_refusesAKeyThatDidNotStandTheFixture() public {
        DeployCell.Deployed memory d = _stand();
        vm.expectRevert(bytes("FIXTURE_KEY is not the key that stood this fixture"));
        review.fileWith(d, strangerKey, auditorKey, KEY);
    }

    /// The stand records the finding's words; the review refuses any that differ.
    function test_refusesFindingWordsTheStandDidNotFreeze() public {
        FrozenFinding frozen = new FrozenFinding();
        Review.Finding memory f = Review.finding();
        vm.serializeBytes32("stood", "findingInvariantId", f.invariantId);
        vm.serializeBytes32("stood", "findingLocation", f.location);
        vm.serializeBytes32("stood", "findingContext", f.context);
        frozen.check(vm.serializeBytes32("stood", "findingWitness", f.witness));

        string memory moved = vm.serializeBytes32("stood", "findingWitness", keccak256("a witness edited after the stand"));
        vm.expectRevert(
            bytes("finding.json differs from the words the stand froze (VD-273(4)): a changed finding is a second exhibit")
        );
        frozen.check(moved);
    }

    function test_filesOnce() public {
        (DeployCell.Deployed memory d,) = _file();
        vm.expectRevert(bytes("the fixture already holds a row; the room files once"));
        review.fileWith(d, KEY, auditorKey, strangerKey);
    }
}
