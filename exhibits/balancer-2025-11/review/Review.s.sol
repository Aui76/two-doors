// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {console} from "forge-std/console.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {FixtureCore} from "../../beanstalk-2022-04/fixture/Fixture.s.sol";
import {Room3} from "./Room3.sol";
import {BalancerReview} from "./Review.sol";

/// The Balancer room's review on the same hull as Room 1's auditor's room (network
/// 7fd937a, shape C), stood and filed in memory only. There is no fixture for it on
/// any chain and these scripts refuse to make one: they run under forge test or a
/// dry run against anvil, never with --broadcast, and they write no record.
///
/// Three keys, because the hull decides it. The fixture key is Balancer, the
/// protocol that staked its pool in DAN; it may not audit its own fixture (PC-86).
/// The auditor is the seat the draw gives the row to, the visitor's seat. The
/// stranger is the auditor the draw gives the re-run to; the cell refuses the filer
/// that seat.
abstract contract BalancerReviewCore is FixtureCore {
    struct Filed {
        uint256 auditId;
        uint256 disputeId;
        address protocol;
        address auditor;
        address stranger;
        uint256 stake;
        uint256 rerunBounty;
        bytes32 specHash;
        bytes32 failRoot;
        BalancerReview.Finding finding;
    }

    function _inMemoryOnly() internal view {
        require(
            block.chainid == ANVIL && !_isLive(),
            "the Balancer room runs in memory only: no fixture of it stands on any chain"
        );
    }

    /// The hull read back as every fixture is, then the room's three tools.
    function _readBackStand(Deployed memory d, address key, address auditor) internal view {
        _readBackHull(d, key, auditor);
        (, bool specIsSpec,,, bool specExists,,) = d.cell.tools(Room3.SPEC_TOOL);
        (, bool reviewIsSpec,,, bool reviewExists,,) = d.cell.tools(BalancerReview.REVIEW_TOOL);
        (, bool evalIsSpec, bool evalIsEval, bool evalCanon, bool evalExists,,) =
            d.cell.tools(BalancerReview.EVALUATOR_TOOL);
        require(specExists && specIsSpec, "Room 3 spec tool");
        require(reviewExists && !reviewIsSpec, "review tool");
        require(evalExists && !evalIsSpec && evalIsEval && evalCanon, "evaluator: canonical");
    }

    /// The row, its claim and the re-run's row as the cell holds them, against
    /// everything the filing meant to send.
    function _readBackReview(Deployed memory d, Filed memory r) internal view {
        AuditCell c = d.cell;
        CellTypeDefs.Audit memory a = c.getAudit(r.auditId);
        require(a.protocol == r.protocol, "row protocol");
        require(a.auditor == r.auditor, "row auditor");
        require(a.artifactHash == Room3.POOL_A_CODEHASH, "row artifact: pool A's code hash");
        require(a.specHash == r.specHash, "row spec");
        require(a.specToolId == Room3.SPEC_TOOL, "row spec tool: Room 3's");
        require(c.auditVerdictToolId(r.auditId) == bytes32(0), "the row's auditor gave no verdict");

        (
            address claimant,
            bytes32 toolId,
            bytes32 proofHash,
            ,
            uint256 stake,
            ,
            bool exists,
            bool witnessPath,
            bytes32 evaluatorToolId,
            bytes32 invariantId,
            bytes32 location,
            bytes32 witness,
            bytes32 context
        ) = c.vulnerabilityClaims(r.auditId);
        require(exists && witnessPath, "a witness claim on the row");
        require(claimant == r.auditor, "the claim is the row's own auditor's");
        require(toolId == BalancerReview.REVIEW_TOOL, "claim tool: the row's declared review tool");
        require(proofHash == r.failRoot, "claim result root");
        require(stake == r.stake, "claim stake");
        require(evaluatorToolId == BalancerReview.EVALUATOR_TOOL, "claim evaluator");
        require(invariantId == r.finding.invariantId, "claim invariant");
        require(location == r.finding.location, "claim location");
        require(witness == r.finding.witness, "claim witness");
        require(context == r.finding.context, "claim context");

        require(c.auditAuditorOf(r.disputeId) == r.stranger, "the re-run is the stranger's");
    }

    function _stateName(CellTypeDefs.AuditState s) internal pure returns (string memory) {
        string[10] memory n = [
            "None", "Submitted", "Assigned", "InAudit", "AwaitingWindow", "Audited", "InBlock", "Claimed", "Exploited",
            "Invalidated"
        ];
        return n[uint256(s)];
    }

    function _printReview(Deployed memory d, Filed memory r) internal view {
        AuditCell c = d.cell;
        console.log("The Balancer room: a witness claim filed in review, in memory - not the network's cell");
        console.log("  row                     ", r.auditId);
        console.log("  row state               ", _stateName(c.auditStateOf(r.auditId)));
        console.log("  protocol (Balancer)     ", r.protocol);
        console.log("  auditor (the visitor)   ", r.auditor);
        console.log("  claim stake (wei)       ", r.stake);
        console.log("  re-run row              ", r.disputeId);
        console.log("  re-run state            ", _stateName(c.auditStateOf(r.disputeId)));
        console.log("  re-run auditor          ", r.stranger);
        console.log("  re-run bounty (wei)     ", r.rerunBounty);
        console.log("  result root");
        console.logBytes32(r.failRoot);
    }
}

/// Stand the room's hull in memory, from the fixture key: the hull deployed and
/// wired as every fixture is, the room's three tools with the evaluator flagged
/// canonical, the funding, the minter.
contract StandTheBalancerReview is BalancerReviewCore {
    function standWith(uint256 key, address auditor) public returns (Deployed memory d) {
        _inMemoryOnly();
        address fixture = _beforeStand(key, auditor, false, "", false);

        vm.startBroadcast(key);

        d = _deployAndWire(fixture, auditor);

        // The room's own: the spec label the row is filed against, the review label
        // the row declares and the claim names, and the evaluator that judges the
        // re-run, flagged canonical. The canonical flag can never be cleared
        // (ToolUseLib, monotone).
        d.cell.registerTool(Room3.SPEC_TOOL, true);
        d.cell.registerTool(BalancerReview.REVIEW_TOOL, false);
        d.cell.registerTool(BalancerReview.EVALUATOR_TOOL, false);
        d.cell.setToolWitnessFlags(BalancerReview.EVALUATOR_TOOL, true, true);
        // One row's bounty, the claim stake against it, and the re-run's bounty.
        // setMinter follows at once and closes genesisMint for good.
        uint256 mint = Room3.BOUNTY + _claimStakeFor(d.cell, Room3.BOUNTY) + BalancerReview.rerunBounty();
        d.token.genesisMint(fixture, mint);
        d.token.setMinter(address(d.issuance));

        vm.stopBroadcast();

        _readBackStand(d, fixture, auditor);
        require(d.token.totalSupply() == mint && d.token.balanceOf(fixture) == mint, "funding");
    }
}

/// The review: Balancer files its row, the draw gives it to the auditor, the auditor
/// reads the pool's source and files what the spec never says, and the network sends
/// the finding to a stranger to run again.
contract FileTheBalancerFinding is BalancerReviewCore {
    function fileWith(Deployed memory d, uint256 fixtureKey, uint256 auditorKey, uint256 strangerKey)
        public
        returns (Filed memory r)
    {
        _inMemoryOnly();
        AuditCell c = d.cell;
        r.protocol = vm.addr(fixtureKey);
        r.auditor = vm.addr(auditorKey);
        r.stranger = vm.addr(strangerKey);
        _refuseNetworkKey(r.protocol, "FIXTURE_KEY");
        _refuseNetworkKey(r.auditor, "AUDITOR_KEY");
        _refuseNetworkKey(r.stranger, "STRANGER_KEY");
        require(c.admin() == r.protocol, "FIXTURE_KEY is not the key that stood this fixture");
        require(
            r.auditor != r.protocol && r.stranger != r.protocol && r.stranger != r.auditor,
            "three seats, three keys: the hull refuses the re-run to the filer, and the fixture key audits nothing"
        );
        address named = c.genesisAuditor();
        require(named == r.auditor, "AUDITOR_KEY is not the fixture's genesis auditor");
        require(c.nextAuditId() == 0, "the fixture already holds a row; the room files once");

        r.specHash = keccak256(bytes(vm.readFile(Room3.SPEC_PATH)));
        r.finding = BalancerReview.finding();
        r.failRoot = BalancerReview.failRoot(r.finding, r.specHash);
        r.rerunBounty = BalancerReview.rerunBounty();

        // 1. The auditor registers: position 1, the seat the stand named.
        vm.broadcast(auditorKey);
        c.register();

        // 2. Balancer files its row and accepts the auditor the draw gave it. The
        //    stranger registers only after this, so the draw has one candidate.
        vm.startBroadcast(fixtureKey);
        r.auditId = BalancerReview.file(c, d.token, r.specHash);
        c.protocolAcceptAuditor(r.auditId);
        vm.stopBroadcast();
        require(c.auditAuditorOf(r.auditId) == r.auditor, "the draw did not give the row to AUDITOR_KEY");

        // 3. The auditor takes the row into review.
        vm.broadcast(auditorKey);
        c.acceptAudit(r.auditId, Room3.SPEC_ERRORS);
        require(c.auditStateOf(r.auditId) == CellTypeDefs.AuditState.InAudit, "the row is not in review");

        // 4. The stake the cell asks, read from the cell, handed to the auditor.
        r.stake = c.requiredClaimStake(r.auditId);
        vm.broadcast(fixtureKey);
        d.token.transfer(r.auditor, r.stake);

        // 5. In review, before any verdict, the auditor files the finding: the
        //    row's declared review tool, the FAIL root, and the witness.
        vm.startBroadcast(auditorKey);
        d.token.approve(address(c), r.stake);
        c.claimVulnerability(
            r.auditId,
            BalancerReview.REVIEW_TOOL,
            r.failRoot,
            "",
            BalancerReview.EVALUATOR_TOOL,
            r.finding.invariantId,
            r.finding.location,
            r.finding.witness,
            r.finding.context
        );
        vm.stopBroadcast();
        require(c.auditStateOf(r.auditId) == CellTypeDefs.AuditState.Claimed, "the row is not Claimed");

        // 6. The stranger registers, the only other candidate for the re-run's draw.
        vm.broadcast(strangerKey);
        c.register();

        // 7. Balancer funds the re-run. The draw gives it to the stranger.
        vm.startBroadcast(fixtureKey);
        d.token.approve(address(c), r.rerunBounty);
        r.disputeId = d.claimModule.openDisputeReaudit(r.auditId, r.rerunBounty);
        vm.stopBroadcast();
        require(c.auditAuditorOf(r.disputeId) == r.stranger, "the draw did not give the re-run to STRANGER_KEY");

        // 8. The stranger runs the evaluator on the finding and gets the same root.
        vm.startBroadcast(strangerKey);
        c.acceptAudit(r.disputeId, Room3.SPEC_ERRORS);
        c.proveFail(r.disputeId, BalancerReview.EVALUATOR_TOOL, r.failRoot);
        vm.stopBroadcast();

        _readBackReview(d, r);
        require(
            c.auditStateOf(r.disputeId) == CellTypeDefs.AuditState.AwaitingWindow, "the re-run is not awaiting its window"
        );
        require(d.token.balanceOf(r.protocol) == 0, "the fixture key should end holding nothing");

        _printReview(d, r);
    }
}
