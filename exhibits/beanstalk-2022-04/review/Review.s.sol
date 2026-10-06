// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VmSafe} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {FixtureCore} from "../fixture/Fixture.s.sol";
import {Room1} from "../verdict/Room1.sol";
import {Review} from "./Review.sol";

/// The auditor's room on its own fixture: the DAN hull with the auditor's witness
/// claim in review (network 7fd937a, shape C), deployed on Base Sepolia by the
/// museum. It is not the network's cell and not the second fixture: it writes its
/// own records, so the second fixture's records and plaque stay as they were.
///
/// Three keys, because the hull decides it. The fixture key is Beanstalk, the
/// protocol that staked its contracts in DAN; it may not audit its own fixture
/// (PC-86). The auditor is the seat the draw gives the row to, the visitor's seat.
/// The stranger is the auditor the draw gives the re-run to; the cell refuses the
/// filer that seat.
abstract contract ReviewCore is FixtureCore {
    string internal constant REVIEW_HULL = "7fd937a";

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
        Review.Finding finding;
    }

    function _standPath(bool live) internal view returns (string memory) {
        return string.concat(RECORD_DIR, vm.toString(block.chainid), live ? ".review-stand.json" : ".review-stand.dryrun.json");
    }

    function _reviewPath(bool live) internal view returns (string memory) {
        return string.concat(RECORD_DIR, vm.toString(block.chainid), live ? ".review.json" : ".review.dryrun.json");
    }

    /// The hull read back as every fixture is, then the room's three tools.
    function _readBackStand(Deployed memory d, address key, address auditor) internal view {
        _readBackHull(d, key, auditor);
        (, bool specIsSpec,,, bool specExists,,) = d.cell.tools(Room1.SPEC_TOOL);
        (, bool reviewIsSpec,,, bool reviewExists,,) = d.cell.tools(Review.REVIEW_TOOL);
        (, bool evalIsSpec, bool evalIsEval, bool evalCanon, bool evalExists,,) = d.cell.tools(Review.EVALUATOR_TOOL);
        require(specExists && specIsSpec, "Room 1 spec tool");
        require(reviewExists && !reviewIsSpec, "review tool");
        require(evalExists && !evalIsSpec && evalIsEval && evalCanon, "evaluator: canonical");
    }

    function _printStand(Deployed memory d, address key, address auditor) internal view {
        AuditCell c = d.cell;
        console.log("The auditor's room fixture: the DAN hull at", REVIEW_HULL, "- not the network's cell");
        console.log("  chain id                ", block.chainid);
        console.log("  fixture key (protocol)  ", key);
        console.log("  genesis auditor         ", auditor);
        console.log("  AuditCell               ", address(c));
        console.log("  CellToken               ", address(d.token));
        console.log("  ClaimDisputeModule      ", address(d.claimModule));
        console.log("  AuditCell runtime bytes ", address(c).code.length);
        console.log("  decision window (s)     ", c.decisionWindow());
        console.log("  in-audit window (s)     ", c.inAuditWindow());
        console.log("  min audit window (s)    ", c.minAuditWindow());
        console.log("  claim filing stake (wei)", c.claimFilingStake());
        console.log("  fixture key AUDIT (wei) ", d.token.balanceOf(key));
    }

    /// The same address keys as the second fixture's record, so _fromRecord reads
    /// both; then the finding's words, frozen at the stand as door two's were
    /// (VD-273(4)).
    function _recordStand(Deployed memory d, address key, address auditor, uint256 mint, string memory path) internal {
        string memory r = "review-stand";
        vm.serializeString(
            r,
            "what",
            "The auditor's room fixture: an instance of the DAN hull at network 7fd937a (the auditor's witness claim in review), deployed on Base Sepolia by the museum. Not the network's cell."
        );
        vm.serializeString(r, "hull", REVIEW_HULL);
        vm.serializeUint(r, "chainId", block.chainid);
        vm.serializeAddress(r, "fixtureKey", key);
        vm.serializeAddress(r, "genesisAuditor", auditor);
        vm.serializeUint(r, "genesisMint", mint);
        string memory commit = vm.envOr("STAND_COMMIT", string(""));
        vm.serializeString(r, "standCommit", bytes(commit).length == 0 ? "none: a rehearsal" : commit);
        Review.Finding memory f = Review.finding();
        vm.serializeString(r, "findingWords", Review.FINDING_PATH);
        vm.serializeBytes32(r, "findingInvariantId", f.invariantId);
        vm.serializeBytes32(r, "findingLocation", f.location);
        vm.serializeBytes32(r, "findingWitness", f.witness);
        vm.serializeBytes32(r, "findingContext", f.context);
        vm.serializeBytes32(r, "auditCellRuntimeCodehash", address(d.cell).codehash);
        vm.serializeUint(r, "auditCellRuntimeBytes", address(d.cell).code.length);
        vm.serializeAddress(r, "CellToken", address(d.token));
        vm.serializeAddress(r, "AuditCell", address(d.cell));
        vm.serializeAddress(r, "CellEscrow", address(d.escrow));
        vm.serializeAddress(r, "IssuanceModule", address(d.issuance));
        vm.serializeAddress(r, "ClaimDisputeModule", address(d.claimModule));
        vm.serializeAddress(r, "SpecGapModule", address(d.specGapModule));
        vm.serializeAddress(r, "SpecArbiterModule", address(d.specArbiterModule));
        vm.serializeAddress(r, "IntegrityReviewModule", address(d.integrityReviewModule));
        vm.serializeAddress(r, "StructuralUpgradeModule", address(d.structuralUpgradeModule));
        vm.serializeAddress(r, "FmeaRegistry", address(d.fmeaRegistry));
        vm.serializeAddress(r, "AssignmentModule", address(d.assignmentModule));
        string memory json = vm.serializeAddress(r, "BlockhashEntropy", address(d.blockhashEntropy));
        vm.writeJson(json, path);
        console.log("  record                  ", path);
    }

    /// finding.json is frozen at the stand. Words that differ from the ones the
    /// stand recorded are a second exhibit, never an edit of this one.
    function _requireTheWordsTheStandFroze(string memory stood) internal view {
        Review.Finding memory f = Review.finding();
        string memory why = "finding.json differs from the words the stand froze (VD-273(4)): a changed finding is a second exhibit";
        require(f.invariantId == vm.parseJsonBytes32(stood, ".findingInvariantId"), why);
        require(f.location == vm.parseJsonBytes32(stood, ".findingLocation"), why);
        require(f.witness == vm.parseJsonBytes32(stood, ".findingWitness"), why);
        require(f.context == vm.parseJsonBytes32(stood, ".findingContext"), why);
    }

    /// The row, its claim and the re-run's row as the cell holds them, against
    /// everything the filing meant to send.
    function _readBackReview(Deployed memory d, Filed memory r) internal view {
        AuditCell c = d.cell;
        CellTypeDefs.Audit memory a = c.getAudit(r.auditId);
        require(a.protocol == r.protocol, "row protocol");
        require(a.auditor == r.auditor, "row auditor");
        require(a.artifactHash == Room1.BEANSTALK_CODEHASH, "row artifact: the Beanstalk code hash");
        require(a.specHash == r.specHash, "row spec");
        require(a.specToolId == Room1.SPEC_TOOL, "row spec tool: Room 1's");
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
        require(toolId == Review.REVIEW_TOOL, "claim tool: the row's declared review tool");
        require(proofHash == r.failRoot, "claim result root");
        require(stake == r.stake, "claim stake");
        require(evaluatorToolId == Review.EVALUATOR_TOOL, "claim evaluator");
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
        console.log("The auditor's room: a witness claim filed in review - not the network's cell");
        console.log("  chain id                ", block.chainid);
        console.log("  AuditCell               ", address(c));
        console.log("  row                     ", r.auditId);
        console.log("  row state               ", _stateName(c.auditStateOf(r.auditId)));
        console.log("  protocol (Beanstalk)    ", r.protocol);
        console.log("  auditor (the visitor)   ", r.auditor);
        console.log("  claim stake (wei)       ", r.stake);
        console.log("  re-run row              ", r.disputeId);
        console.log("  re-run state            ", _stateName(c.auditStateOf(r.disputeId)));
        console.log("  re-run auditor          ", r.stranger);
        console.log("  re-run bounty (wei)     ", r.rerunBounty);
        console.log("  result root");
        console.logBytes32(r.failRoot);
    }

    function _recordReview(Deployed memory d, Filed memory r, string memory path) internal {
        string memory k = "review";
        vm.serializeString(
            k,
            "what",
            "The auditor's room: the drawn auditor's witness claim filed in review on the museum's fixture, an instance of the DAN hull at network 7fd937a on Base Sepolia. Not the network's cell."
        );
        vm.serializeString(k, "hull", REVIEW_HULL);
        vm.serializeUint(k, "chainId", block.chainid);
        vm.serializeAddress(k, "AuditCell", address(d.cell));
        vm.serializeAddress(k, "ClaimDisputeModule", address(d.claimModule));
        vm.serializeUint(k, "auditId", r.auditId);
        vm.serializeUint(k, "disputeId", r.disputeId);
        vm.serializeAddress(k, "protocol", r.protocol);
        vm.serializeAddress(k, "auditor", r.auditor);
        vm.serializeAddress(k, "stranger", r.stranger);
        vm.serializeBytes32(k, "artifactHash", Room1.BEANSTALK_CODEHASH);
        vm.serializeBytes32(k, "specHash", r.specHash);
        vm.serializeString(k, "findingWords", Review.FINDING_PATH);
        vm.serializeBytes32(k, "toolId", Review.REVIEW_TOOL);
        vm.serializeBytes32(k, "evaluatorToolId", Review.EVALUATOR_TOOL);
        vm.serializeBytes32(k, "invariantId", r.finding.invariantId);
        vm.serializeBytes32(k, "locationCommitment", r.finding.location);
        vm.serializeBytes32(k, "witnessCommitment", r.finding.witness);
        vm.serializeBytes32(k, "contextRoot", r.finding.context);
        vm.serializeBytes32(k, "resultRoot", r.failRoot);
        vm.serializeUint(k, "rerunBounty", r.rerunBounty);
        string memory json = vm.serializeUint(k, "claimStake", r.stake);
        vm.writeJson(json, path);
        console.log("  record                  ", path);
    }

    function _reviewFromRecord(string memory json) internal view returns (Filed memory r) {
        r.auditId = vm.parseJsonUint(json, ".auditId");
        r.disputeId = vm.parseJsonUint(json, ".disputeId");
        r.protocol = vm.parseJsonAddress(json, ".protocol");
        r.auditor = vm.parseJsonAddress(json, ".auditor");
        r.stranger = vm.parseJsonAddress(json, ".stranger");
        r.stake = vm.parseJsonUint(json, ".claimStake");
        r.rerunBounty = vm.parseJsonUint(json, ".rerunBounty");
        r.specHash = vm.parseJsonBytes32(json, ".specHash");
        r.failRoot = vm.parseJsonBytes32(json, ".resultRoot");
        r.finding = Review.finding();
        require(r.finding.witness == vm.parseJsonBytes32(json, ".witnessCommitment"), "finding.json has changed since the filing");
        require(r.specHash == keccak256(bytes(vm.readFile(Room1.SPEC_PATH))), "the spec has changed since the filing");
    }
}

/// Stand the room's fixture. One broadcast from the fixture key: the hull deployed
/// and wired as every fixture is, the room's three tools with the evaluator flagged
/// canonical, the funding, the minter. Nothing after it touches the fixture's
/// governance (VD-270(ii), VD-260).
contract StandTheReview is ReviewCore {
    /// Env: FIXTURE_KEY, a fresh museum key. FIXTURE_GENESIS_AUDITOR names the
    /// auditor's seat (PC-85), or FIXTURE_GENESIS_AUDITOR_OPEN=1 leaves it open.
    /// STAND_COMMIT, the museum commit the stand runs from, is required on Base
    /// Sepolia: finding.json's words are frozen there and the record cites it.
    function stand() external returns (Deployed memory) {
        if (block.chainid == BASE_SEPOLIA) {
            require(
                bytes(vm.envOr("STAND_COMMIT", string(""))).length == 40,
                "STAND_COMMIT required on Base Sepolia: the commit finding.json is frozen at (VD-273(4))"
            );
        }
        address auditor = _optionalAddress("FIXTURE_GENESIS_AUDITOR", address(0));
        bool open = _optionalUint("FIXTURE_GENESIS_AUDITOR_OPEN", 0) == 1;
        return standWith(vm.envUint("FIXTURE_KEY"), auditor, open);
    }

    function standWith(uint256 key, address auditor, bool open) public returns (Deployed memory d) {
        bool live = _isLive();
        string memory path = _standPath(live);
        address fixture = _beforeStand(key, auditor, open, path, live);

        vm.startBroadcast(key);

        d = _deployAndWire(fixture, auditor);

        // The room's own: Room 1's spec label, so the row is filed against the same
        // governance spec Room 1 reads; the review label the row declares and the
        // claim names; the evaluator that judges the re-run, flagged canonical here
        // because the stand is the fixture's only admin broadcast. The canonical
        // flag can never be cleared (ToolUseLib, monotone).
        d.cell.registerTool(Room1.SPEC_TOOL, true);
        d.cell.registerTool(Review.REVIEW_TOOL, false);
        d.cell.registerTool(Review.EVALUATOR_TOOL, false);
        d.cell.setToolWitnessFlags(Review.EVALUATOR_TOOL, true, true);
        // One row of Room 1's bounty, the claim stake against it, and the re-run's
        // bounty. setMinter follows at once and closes genesisMint for good, so this
        // is the only AUDIT on the fixture that its own lifecycle did not pay out.
        uint256 mint = Room1.BOUNTY + _claimStakeFor(d.cell, Room1.BOUNTY) + Review.rerunBounty();
        d.token.genesisMint(fixture, mint);
        d.token.setMinter(address(d.issuance));

        vm.stopBroadcast();

        _readBackStand(d, fixture, auditor);
        require(d.token.totalSupply() == mint && d.token.balanceOf(fixture) == mint, "funding");
        _printStand(d, fixture, auditor);
        if (vm.isContext(VmSafe.ForgeContext.ScriptGroup)) _recordStand(d, fixture, auditor, mint, path);
    }
}

/// The review, on the recorded fixture: Beanstalk files its row, the draw gives it
/// to the auditor, the auditor reads the contracts and files what the spec never
/// says, and the network sends the finding to a stranger to run again.
contract FileTheFinding is ReviewCore {
    /// Env: FIXTURE_KEY, the key that stood the fixture. AUDITOR_KEY, its genesis
    /// auditor, the visitor's seat. STRANGER_KEY, the re-run's auditor.
    function file() external returns (Filed memory) {
        _requireFixtureChain();
        string memory stood = vm.readFile(_standPath(true));
        _requireTheWordsTheStandFroze(stood);
        (Deployed memory d, address key, address named) = _fromRecord(stood);
        _readBackStand(d, key, named);
        return fileWith(d, vm.envUint("FIXTURE_KEY"), vm.envUint("AUDITOR_KEY"), vm.envUint("STRANGER_KEY"));
    }

    function fileWith(Deployed memory d, uint256 fixtureKey, uint256 auditorKey, uint256 strangerKey)
        public
        returns (Filed memory r)
    {
        _requireFixtureChain();
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
        require(named == address(0) || named == r.auditor, "AUDITOR_KEY is not the fixture's genesis auditor");
        require(c.nextAuditId() == 0, "the fixture already holds a row; the room files once");

        r.specHash = keccak256(bytes(vm.readFile(Room1.SPEC_PATH)));
        r.finding = Review.finding();
        r.failRoot = Review.failRoot(r.finding, r.specHash);
        r.rerunBounty = Review.rerunBounty();

        bool live = _isLive();
        string memory path = _reviewPath(live);
        if (live) {
            require(r.auditor.balance > 0 && r.stranger.balance > 0, "AUDITOR_KEY and STRANGER_KEY need gas first");
        }

        // 1. The auditor registers: position 1, the seat the stand named.
        vm.broadcast(auditorKey);
        c.register();

        // 2. Beanstalk files its row and accepts the auditor the draw gave it. The
        //    stranger registers only after this, so the draw has one candidate.
        vm.startBroadcast(fixtureKey);
        r.auditId = Review.file(c, d.token, r.specHash);
        c.protocolAcceptAuditor(r.auditId);
        vm.stopBroadcast();
        require(c.auditAuditorOf(r.auditId) == r.auditor, "the draw did not give the row to AUDITOR_KEY");

        // 3. The auditor takes the row into review.
        vm.broadcast(auditorKey);
        c.acceptAudit(r.auditId, Room1.SPEC_ERRORS);
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
            Review.REVIEW_TOOL,
            r.failRoot,
            "",
            Review.EVALUATOR_TOOL,
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

        // 7. Beanstalk funds the re-run. The draw gives it to the stranger.
        vm.startBroadcast(fixtureKey);
        d.token.approve(address(c), r.rerunBounty);
        r.disputeId = d.claimModule.openDisputeReaudit(r.auditId, r.rerunBounty);
        vm.stopBroadcast();
        require(c.auditAuditorOf(r.disputeId) == r.stranger, "the draw did not give the re-run to STRANGER_KEY");

        // 8. The stranger runs the evaluator on the finding and gets the same root.
        vm.startBroadcast(strangerKey);
        c.acceptAudit(r.disputeId, Room1.SPEC_ERRORS);
        c.proveFail(r.disputeId, Review.EVALUATOR_TOOL, r.failRoot);
        vm.stopBroadcast();

        _readBackReview(d, r);
        require(
            c.auditStateOf(r.disputeId) == CellTypeDefs.AuditState.AwaitingWindow, "the re-run is not awaiting its window"
        );
        require(d.token.balanceOf(r.protocol) == 0, "the fixture key should end holding nothing");

        _printReview(d, r);
        if (vm.isContext(VmSafe.ForgeContext.ScriptGroup)) _recordReview(d, r, path);
    }
}

/// Read the recorded review back from whatever node serves it, and print where the
/// row stands now and who holds what. Sends nothing.
contract ReadTheReview is ReviewCore {
    function check() external view {
        _requireFixtureChain();
        (Deployed memory d, address key,) = _fromRecord(vm.readFile(_standPath(true)));
        string memory path = _reviewPath(true);
        Filed memory r = _reviewFromRecord(vm.readFile(path));
        _readBackReview(d, r);
        _printReview(d, r);
        CellTypeDefs.Audit memory a = d.cell.getAudit(r.disputeId);
        console.log("  re-run window opened    ", a.windowStart);
        console.log("  re-run window (s)       ", a.auditWindow);
        console.log("  confirm opens after     ", a.windowStart + a.auditWindow);
        console.log("  cell holds (wei)        ", d.token.balanceOf(address(d.cell)));
        console.log("  escrow holds (wei)      ", d.token.balanceOf(address(d.escrow)));
        console.log("  auditor holds (wei)     ", d.token.balanceOf(r.auditor));
        console.log("  stranger holds (wei)    ", d.token.balanceOf(r.stranger));
        console.log("  fixture key holds (wei) ", d.token.balanceOf(key));
        console.log("  read at block           ", block.number);
        console.log("  read at (unix s)        ", block.timestamp);
        console.log("  read back from          ", path);
    }
}
