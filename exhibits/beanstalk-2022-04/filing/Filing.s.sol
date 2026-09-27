// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {VmSafe} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {SpecGapLib} from "dan/SpecGapLib.sol";
import {FixtureCore} from "../fixture/Fixture.s.sol";
import {Room1} from "../verdict/Room1.sol";
import {Room2} from "./Room2.sol";

/// Door two's filing (VD-270): one row and one spec gap against it, on the recorded
/// fixture, from three keys.
///
/// The hull decides how many keys. The discoverer may be neither the row's protocol
/// (FilerCannotBeProtocol) nor its auditor (FilerCannotBeOriginalAuditor), and the
/// fixture key may not audit its own fixture (PC-86). So the fixture key takes one
/// seat, the protocol or the discoverer, and a second key takes the other. The
/// fixture key takes the protocol's seat unless FIXTURE_SEAT says discoverer: the
/// fixture is the museum's own spec under audit, so the owner funds the bounty and a
/// fresh key files as the discoverer (VD-273(2)). The operator may override it.
///
/// The fixture key was minted exactly one of Room 1's bounties and the claim stake
/// against it. It spends the one and hands the other to the second key, so it ends
/// the filing holding nothing, and it sends nothing after the filing (VD-270(ii)).
abstract contract FilingCore is FixtureCore {
    struct Filing {
        uint256 auditId;
        address protocol;
        address auditor;
        address discoverer;
        bool fixtureIsProtocol;
        uint256 stake;
        uint256 filedAt;
        bytes32 specHash;
        bytes32 resultRoot;
        Room2.Gap gap;
    }

    function _filingPath(bool live) internal view returns (string memory) {
        return string.concat(RECORD_DIR, vm.toString(block.chainid), live ? ".filing.json" : ".filing.dryrun.json");
    }

    /// The row as the cell holds it, and the gap as the spec-gap module holds it,
    /// against everything the filing meant to send. The second the gap was filed
    /// is taken from the module into f, since only the chain knows it: a script
    /// records during its simulation, before anything is mined.
    function _readBackFiling(Deployed memory d, Filing memory f) internal view returns (SpecGapLib.Status status) {
        AuditCell c = d.cell;
        CellTypeDefs.Audit memory a = c.getAudit(f.auditId);
        require(a.protocol == f.protocol, "row protocol");
        require(a.auditor == f.auditor, "row auditor");
        require(a.artifactHash == Room1.BEANSTALK_CODEHASH, "row artifact: the Beanstalk code hash");
        require(a.specHash == f.specHash, "row spec");
        require(a.specToolId == Room1.SPEC_TOOL, "row spec tool: Room 1's");

        (
            address filer,
            bytes32 classId,
            bytes32 finderToolId,
            bytes32 proofHash,
            bytes32 evaluatorToolId,
            bytes32 invariantId,
            bytes32 location,
            bytes32 witness,
            bytes32 context,
            uint256 filedAt,
            ,
            ,
            SpecGapLib.Status s,
            bool exists
        ) = d.specGapModule.specGaps(f.auditId, f.gap.classId);
        require(exists, "gap exists");
        require(filer == f.discoverer, "gap filer");
        require(classId == f.gap.classId, "gap class");
        require(finderToolId == Room2.FINDER_TOOL, "gap finder");
        require(evaluatorToolId == Room2.EVALUATOR_TOOL, "gap evaluator");
        require(proofHash == f.resultRoot, "gap result root");
        require(invariantId == f.gap.invariantId, "gap invariant");
        require(location == f.gap.location, "gap location");
        require(witness == f.gap.witness, "gap witness");
        require(context == f.gap.context, "gap context");
        f.filedAt = filedAt;
        return s;
    }

    function _printFiling(Deployed memory d, Filing memory f, SpecGapLib.Status s, bool mined) internal view {
        console.log("Room 2, door two: a spec gap on the fixture - not the network's cell");
        console.log("  chain id                ", block.chainid);
        console.log("  AuditCell               ", address(d.cell));
        console.log("  SpecGapModule           ", address(d.specGapModule));
        console.log("  row                     ", f.auditId);
        console.log("  protocol                ", f.protocol);
        console.log("  auditor                 ", f.auditor);
        console.log("  discoverer              ", f.discoverer);
        console.log("  fixture key's seat      ", f.fixtureIsProtocol ? "protocol" : "discoverer");
        console.log("  row state               ", uint256(d.cell.auditStateOf(f.auditId)));
        console.log("  gap status              ", _statusName(s));
        console.log("  filing stake (wei)      ", f.stake);
        if (mined) {
            console.log("  filed at                ", f.filedAt);
            console.log("  silence confirms from   ", f.filedAt + d.cell.protocolDecisionWindow());
        } else {
            console.log("  filed at                 ReadTheFiling prints it once the filing is mined");
        }
        console.log("  gap class");
        console.logBytes32(f.gap.classId);
        console.log("  result root");
        console.logBytes32(f.resultRoot);
    }

    function _recordFiling(Deployed memory d, Filing memory f, string memory path) internal {
        string memory r = "filing";
        vm.serializeString(
            r,
            "what",
            "Room 2, door two: a spec gap filed on the fixture, an instance of the DAN hull at 0f3eaf8 on Base Sepolia. Not the network's cell."
        );
        vm.serializeString(r, "hull", HULL);
        vm.serializeUint(r, "chainId", block.chainid);
        vm.serializeAddress(r, "AuditCell", address(d.cell));
        vm.serializeAddress(r, "SpecGapModule", address(d.specGapModule));
        vm.serializeUint(r, "auditId", f.auditId);
        vm.serializeAddress(r, "protocol", f.protocol);
        vm.serializeAddress(r, "auditor", f.auditor);
        vm.serializeAddress(r, "discoverer", f.discoverer);
        vm.serializeString(r, "fixtureKeySeat", f.fixtureIsProtocol ? "protocol" : "discoverer");
        vm.serializeBytes32(r, "artifactHash", Room1.BEANSTALK_CODEHASH);
        vm.serializeBytes32(r, "specHash", f.specHash);
        vm.serializeString(r, "gapWords", Room2.GAP_PATH);
        vm.serializeBytes32(r, "classId", f.gap.classId);
        vm.serializeBytes32(r, "finderToolId", Room2.FINDER_TOOL);
        vm.serializeBytes32(r, "evaluatorToolId", Room2.EVALUATOR_TOOL);
        vm.serializeBytes32(r, "invariantId", f.gap.invariantId);
        vm.serializeBytes32(r, "locationCommitment", f.gap.location);
        vm.serializeBytes32(r, "witnessCommitment", f.gap.witness);
        vm.serializeBytes32(r, "contextRoot", f.gap.context);
        vm.serializeBytes32(r, "resultRoot", f.resultRoot);
        string memory json = vm.serializeUint(r, "filingStake", f.stake);
        vm.writeJson(json, path);
        console.log("  record                  ", path);
    }

    /// gap.json is frozen at the stand (VD-273(4)). Words that differ from the ones
    /// the stand recorded are a second exhibit, never an edit of this one.
    function _requireTheWordsTheStandFroze(string memory stood) internal view {
        Room2.Gap memory g = Room2.gap();
        string memory why = "gap.json differs from the words the stand froze (VD-273(4)): a changed gap is a second exhibit";
        require(g.classId == vm.parseJsonBytes32(stood, ".gapClassId"), why);
        require(g.invariantId == vm.parseJsonBytes32(stood, ".gapInvariantId"), why);
        require(g.location == vm.parseJsonBytes32(stood, ".gapLocation"), why);
        require(g.witness == vm.parseJsonBytes32(stood, ".gapWitness"), why);
        require(g.context == vm.parseJsonBytes32(stood, ".gapContext"), why);
    }

    function _statusName(SpecGapLib.Status s) internal pure returns (string memory) {
        if (s == SpecGapLib.Status.Filed) return "Filed";
        if (s == SpecGapLib.Status.Confirmed) return "Confirmed";
        if (s == SpecGapLib.Status.False) return "False";
        if (s == SpecGapLib.Status.Adopted) return "Adopted";
        if (s == SpecGapLib.Status.Declined) return "Declined";
        if (s == SpecGapLib.Status.Expired) return "Expired";
        return "None";
    }

    function _filingFromRecord(string memory json) internal view returns (Filing memory f) {
        f.auditId = vm.parseJsonUint(json, ".auditId");
        f.protocol = vm.parseJsonAddress(json, ".protocol");
        f.auditor = vm.parseJsonAddress(json, ".auditor");
        f.discoverer = vm.parseJsonAddress(json, ".discoverer");
        f.fixtureIsProtocol = keccak256(bytes(vm.parseJsonString(json, ".fixtureKeySeat"))) == keccak256("protocol");
        f.stake = vm.parseJsonUint(json, ".filingStake");
        f.specHash = vm.parseJsonBytes32(json, ".specHash");
        f.resultRoot = vm.parseJsonBytes32(json, ".resultRoot");
        f.gap = Room2.gap();
        require(f.gap.classId == vm.parseJsonBytes32(json, ".classId"), "gap.json has changed since the filing");
        require(f.gap.witness == vm.parseJsonBytes32(json, ".witnessCommitment"), "gap.json has changed since the filing");
        require(f.specHash == keccak256(bytes(vm.readFile(Room1.SPEC_PATH))), "the spec has changed since the filing");
    }
}

/// File door two on the recorded fixture.
contract FileTheGap is FilingCore {
    /// Env: FIXTURE_KEY, the key that stood the fixture. AUDITOR_KEY, the fixture's
    /// genesis auditor. SECOND_KEY, the seat the fixture key does not take.
    /// FIXTURE_SEAT, "protocol" (the default, VD-273(2)) or "discoverer": which seat
    /// the fixture key takes.
    function file() external returns (Filing memory) {
        _requireFixtureChain();
        string memory stood = vm.readFile(_recordPath(true));
        _requireTheWordsTheStandFroze(stood);
        (Deployed memory d, address key, address named) = _fromRecord(stood);
        _readBack(d, key, named);
        bytes32 seat = keccak256(bytes(vm.envOr("FIXTURE_SEAT", string("protocol"))));
        require(
            seat == keccak256("protocol") || seat == keccak256("discoverer"),
            "FIXTURE_SEAT is protocol (the default) or discoverer: the seat the fixture key takes (VD-273(2))"
        );
        return fileWith(
            d, vm.envUint("FIXTURE_KEY"), vm.envUint("AUDITOR_KEY"), vm.envUint("SECOND_KEY"), seat == keccak256("protocol")
        );
    }

    function fileWith(Deployed memory d, uint256 fixtureKey, uint256 auditorKey, uint256 secondKey, bool fixtureIsProtocol)
        public
        returns (Filing memory f)
    {
        _requireFixtureChain();
        AuditCell c = d.cell;
        address fixture = vm.addr(fixtureKey);
        address second = vm.addr(secondKey);
        f.auditor = vm.addr(auditorKey);
        f.fixtureIsProtocol = fixtureIsProtocol;
        _refuseNetworkKey(fixture, "FIXTURE_KEY");
        _refuseNetworkKey(f.auditor, "AUDITOR_KEY");
        _refuseNetworkKey(second, "SECOND_KEY");
        require(c.admin() == fixture, "FIXTURE_KEY is not the key that stood this fixture");
        require(
            f.auditor != fixture && second != fixture && second != f.auditor,
            "three seats, three keys: the hull refuses a discoverer who is the row's protocol or auditor"
        );
        address named = c.genesisAuditor();
        require(named == address(0) || named == f.auditor, "AUDITOR_KEY is not the fixture's genesis auditor");
        require(c.nextAuditId() == 0, "the fixture already holds a row; door two files once (VD-270)");
        (f.protocol, f.discoverer) = fixtureIsProtocol ? (fixture, second) : (second, fixture);
        uint256 protocolKey = fixtureIsProtocol ? fixtureKey : secondKey;
        uint256 discovererKey = fixtureIsProtocol ? secondKey : fixtureKey;

        f.specHash = keccak256(bytes(vm.readFile(Room1.SPEC_PATH)));
        f.gap = Room2.gap();
        f.resultRoot = Room2.resultRoot(f.gap, f.specHash);

        bool live = _isLive();
        string memory path = _filingPath(live);
        // A filing already on chain is refused above: the fixture holds a row. The
        // record file is no guard. Forge can run this script twice when it
        // broadcasts, and the first run writes the record before anything is sent
        // (Fixture.s.sol, standWith).
        if (live) {
            require(f.auditor.balance > 0 && second.balance > 0, "AUDITOR_KEY and SECOND_KEY need gas first");
        }

        // 1. A second key in the protocol's seat is handed the bounty first.
        if (!fixtureIsProtocol) {
            vm.broadcast(fixtureKey);
            d.token.transfer(second, Room1.BOUNTY);
        }

        // 2. The auditor takes position 1, the seat the stand named.
        vm.broadcast(auditorKey);
        c.register();

        // 3. The protocol files Room 1's row and accepts the auditor the draw gave it.
        //    The discoverer registers only after this, so the draw has one candidate.
        vm.startBroadcast(protocolKey);
        f.auditId = Room1.file(c, d.token, Room1.BEANSTALK_CODEHASH, f.specHash);
        c.protocolAcceptAuditor(f.auditId);
        vm.stopBroadcast();
        require(c.auditAuditorOf(f.auditId) == f.auditor, "the draw did not give the row to AUDITOR_KEY");

        // 4. The auditor passes the row as Room 1 does. It waits out its window.
        vm.startBroadcast(auditorKey);
        c.acceptAudit(f.auditId, Room1.SPEC_ERRORS);
        c.provePass(f.auditId, Room1.VERDICT_TOOL, Room1.resultRoot(f.specHash));
        vm.stopBroadcast();
        require(c.auditStateOf(f.auditId) == CellTypeDefs.AuditState.AwaitingWindow, "the row is not awaiting its window");

        // 5. The stake the cell asks, read from the cell. A second key in the
        //    discoverer's seat is handed it.
        f.stake = c.requiredClaimStake(f.auditId);
        if (fixtureIsProtocol) {
            vm.broadcast(fixtureKey);
            d.token.transfer(second, f.stake);
        }

        // 6. The discoverer registers and files the gap.
        vm.startBroadcast(discovererKey);
        c.register();
        d.token.approve(address(c), f.stake);
        d.specGapModule.openSpecGap(
            f.auditId,
            f.gap.classId,
            Room2.FINDER_TOOL,
            f.resultRoot,
            Room2.EVALUATOR_TOOL,
            f.gap.invariantId,
            f.gap.location,
            f.gap.witness,
            f.gap.context
        );
        vm.stopBroadcast();

        SpecGapLib.Status s = _readBackFiling(d, f);
        require(s == SpecGapLib.Status.Filed, "the gap is not Filed");
        (,,,,,,,,,, uint256 held,,,) = d.specGapModule.specGaps(f.auditId, f.gap.classId);
        require(held == f.stake, "the gap does not hold the stake");
        require(d.token.balanceOf(fixture) == 0, "the fixture key should end holding nothing");

        _printFiling(d, f, s, false);
        if (vm.isContext(VmSafe.ForgeContext.ScriptGroup)) _recordFiling(d, f, path);
    }
}

/// Read the recorded filing back from whatever node serves it, and print where the
/// gap stands now. Sends nothing.
contract ReadTheFiling is FilingCore {
    function check() external view {
        _requireFixtureChain();
        (Deployed memory d, address key,) = _fromRecord(vm.readFile(_recordPath(true)));
        string memory path = _filingPath(true);
        Filing memory f = _filingFromRecord(vm.readFile(path));
        SpecGapLib.Status s = _readBackFiling(d, f);
        _printFiling(d, f, s, true);
        // The row's own window, and who holds what now: the plaque's last paragraph.
        CellTypeDefs.Audit memory a = d.cell.getAudit(f.auditId);
        console.log("  row bounty (wei)        ", a.bounty);
        console.log("  row window opened       ", a.windowStart);
        console.log("  row window (s)          ", a.auditWindow);
        console.log("  row window closed       ", a.windowStart + a.auditWindow);
        console.log("  cell holds (wei)        ", d.token.balanceOf(address(d.cell)));
        console.log("  auditor holds (wei)     ", d.token.balanceOf(f.auditor));
        console.log("  discoverer holds (wei)  ", d.token.balanceOf(f.discoverer));
        console.log("  fixture key holds (wei) ", d.token.balanceOf(key));
        console.log("  fixture key's nonce     ", uint256(vm.getNonce(key)));
        console.log("  read at block           ", block.number);
        console.log("  read at (unix s)        ", block.timestamp);
        console.log("  read back from          ", path);
    }
}
