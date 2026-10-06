// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployCell} from "deps/dan/cell/script/DeployCell.s.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {StandTheBalancerReview, FileTheBalancerFinding, BalancerReviewCore} from "./review/Review.s.sol";
import {BalancerReview} from "./review/Review.sol";
import {Room3} from "./review/Room3.sol";

/// The Balancer room's review, proven in memory: the hull stood as every fixture is,
/// the review filed, the re-run confirmed. The filing reads itself back on every run
/// (Review.s.sol, _readBackReview); these tests add what follows it, and what it
/// refuses.
///
/// No fork and no archive key: the hull is a fresh deploy, not 2025 state. The
/// finding's witness is the replay, which does need the fork, and runs on its own.
contract BalancerReviewTest is Test {
    /// Made up for these tests, as in Room 1's. Not anvil's, not the network's.
    uint256 internal constant KEY = 0xBA1A;
    address internal auditor;
    uint256 internal auditorKey;
    address internal stranger;
    uint256 internal strangerKey;
    StandTheBalancerReview internal stand;
    FileTheBalancerFinding internal review;

    function setUp() public {
        (auditor, auditorKey) = makeAddrAndKey("the drawn auditor");
        (stranger, strangerKey) = makeAddrAndKey("the re-run's auditor");
        stand = new StandTheBalancerReview();
        review = new FileTheBalancerFinding();
    }

    function _stand() internal returns (DeployCell.Deployed memory) {
        return stand.standWith(KEY, auditor);
    }

    function _file() internal returns (DeployCell.Deployed memory d, BalancerReviewCore.Filed memory r) {
        d = _stand();
        r = review.fileWith(d, KEY, auditorKey, strangerKey);
    }

    /// Every hash-bearing word in finding.json is found again in the file it names.
    function test_theFindingsWordsPointAtTheirSources() public view {
        string memory j = BalancerReview.words();
        string memory location = vm.parseJsonString(j, ".location");
        string memory witness = vm.parseJsonString(j, ".witness");
        string memory context = vm.parseJsonString(j, ".context");

        string memory base = vm.readFile("specimens/balancer-2025-11/BasePool.sol");
        string memory general = vm.readFile("specimens/balancer-2025-11/BaseGeneralPool.sol");
        string memory rates = vm.readFile("specimens/balancer-2025-11/ComposableStablePoolRates.sol");
        string memory math = vm.readFile("specimens/balancer-2025-11/StableMath.sol");
        assertTrue(vm.contains(location, vm.toString(sha256(bytes(base)))), "BasePool.sol hash");
        assertTrue(vm.contains(location, vm.toString(sha256(bytes(general)))), "BaseGeneralPool.sol hash");
        assertTrue(vm.contains(location, vm.toString(sha256(bytes(rates)))), "ComposableStablePoolRates.sol hash");
        assertTrue(vm.contains(location, vm.toString(sha256(bytes(math)))), "StableMath.sol hash");
        assertTrue(vm.contains(base, "return FixedPoint.mulDown(amount, scalingFactor);"), "the line the location names");
        assertTrue(
            vm.contains(general, "swapRequest.amount = _upscale(swapRequest.amount, scalingFactors[indexOut]);"),
            "the exact-out call the location names"
        );
        assertTrue(
            vm.contains(rates, "scalingFactors[i] = _getScalingFactor(i).mulDown(_getTokenRate(i));"),
            "the scaling factor the location names"
        );
        assertTrue(vm.contains(math, "function _calcInGivenOut("), "the function the location names");

        string memory replay = vm.parseJsonString(j, "._pins.replayReference");
        assertTrue(vm.contains(witness, replay), "witness names the replay reference");
        assertTrue(
            vm.contains(vm.readFile("exhibits/balancer-2025-11/replay/NOTICE.md"), replay),
            "the replay NOTICE pins the same reference"
        );
        string memory drainer = vm.parseJsonString(j, "._pins.drainer");
        assertTrue(vm.contains(witness, drainer), "witness names the drainer");
        assertTrue(
            vm.contains(vm.readFile("exhibits/balancer-2025-11/Fork.t.sol"), drainer), "Fork.t.sol proves the same address"
        );

        assertTrue(vm.contains(context, vm.toString(Room3.POOL_A)), "context: pool A");
        assertTrue(vm.contains(context, vm.toString(Room3.POOL_A_CODEHASH)), "context: its code hash");
        assertTrue(vm.contains(context, vm.toString(Room3.VAULT)), "context: the Vault");
        assertTrue(vm.contains(context, vm.toString(Room3.FORK_BLOCK)), "context: the block");
        assertTrue(vm.contains(witness, vm.toString(Room3.FORK_BLOCK)), "witness: the block");
        assertTrue(
            vm.contains(vm.readFile("exhibits/balancer-2025-11/Fork.t.sol"), "FORK_BLOCK = 23_717_396"),
            "Fork.t.sol forks the same block"
        );
    }

    /// The missing invariant is missing: no invariant of that id in the spec.
    function test_theSpecNeverSaysIt() public view {
        string memory id = vm.parseJsonString(BalancerReview.words(), ".invariant.id");
        assertFalse(vm.contains(vm.readFile(Room3.SPEC_PATH), id), "the spec already states the finding");
    }

    function test_standRegistersTheRoomsToolsAndFundsOneReview() public {
        DeployCell.Deployed memory d = _stand();
        (,, bool isEval, bool canonical, bool exists,,) = d.cell.tools(BalancerReview.EVALUATOR_TOOL);
        assertTrue(exists && isEval && canonical, "evaluator flagged canonical by the stand");
        uint256 stake = (Room3.BOUNTY * d.cell.claimStakeBps()) / 10_000;
        if (stake < d.cell.claimFilingStake()) stake = d.cell.claimFilingStake();
        assertEq(d.token.balanceOf(vm.addr(KEY)), Room3.BOUNTY + stake + BalancerReview.rerunBounty(), "one review's worth");
    }

    /// The whole room: in review, before any verdict, the drawn auditor files the
    /// finding; a stranger runs it again and gets the same FAIL; once the re-run's
    /// window has passed anyone confirms it, and the row is Exploited.
    function test_theAuditorFilesInReviewAndIsPaid() public {
        (DeployCell.Deployed memory d, BalancerReviewCore.Filed memory r) = _file();
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
        (DeployCell.Deployed memory d, BalancerReviewCore.Filed memory r) = _file();
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

    /// No chain but the in-memory one. The room has no fixture anywhere.
    function test_refusesAnyChainButMemory() public {
        vm.chainId(84532);
        vm.expectRevert(bytes("the Balancer room runs in memory only: no fixture of it stands on any chain"));
        stand.standWith(KEY, auditor);
    }

    function test_filesOnce() public {
        (DeployCell.Deployed memory d,) = _file();
        vm.expectRevert(bytes("the fixture already holds a row; the room files once"));
        review.fileWith(d, KEY, auditorKey, strangerKey);
    }
}
