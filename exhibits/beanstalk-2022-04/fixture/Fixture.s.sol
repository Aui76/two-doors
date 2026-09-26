// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DeployCell} from "lib/dan/cell/script/DeployCell.s.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {console} from "forge-std/console.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellToken} from "dan/CellToken.sol";
import {CellEscrow} from "dan/CellEscrow.sol";
import {IssuanceModule} from "dan/IssuanceModule.sol";
import {ClaimDisputeModule} from "dan/ClaimDisputeModule.sol";
import {SpecGapModule} from "dan/SpecGapModule.sol";
import {SpecArbiterModule} from "dan/SpecArbiterModule.sol";
import {IntegrityReviewModule} from "dan/IntegrityReviewModule.sol";
import {StructuralUpgradeModule} from "dan/StructuralUpgradeModule.sol";
import {FmeaRegistry} from "dan/FmeaRegistry.sol";
import {AssignmentModule} from "dan/AssignmentModule.sol";
import {BlockhashEntropy} from "dan/BlockhashEntropy.sol";
import {Room1} from "../verdict/Room1.sol";
import {Room2} from "../filing/Room2.sol";

/// Room 2's fixture (VD-270): an instance of the DAN hull at 0f3eaf8, deployed on
/// Base Sepolia by the museum for one filing. It is not the network's cell. It holds
/// no value, sits in no deployment record, and no DAN tool reads it.
///
/// The testnet profile is the cell's own, not a copy: this contract inherits
/// DeployCell from the hull's script tree, so `_applyTestnetTimeProfile`, the
/// PC-88(a) window check and every named constant are the ones the network deploys
/// with. What cannot be inherited is DeployCell.run itself, which reads the
/// network's env and writes the network's deployment record. The deploy and wiring
/// below are therefore run's lines 146-198 at 0f3eaf8, step for step, with the
/// fixture key in the deployer's place. If run changes, this must change with it;
/// diff the two.
///
/// DeployCell.run is still inherited and cannot be overridden. The fixture's entry
/// point is `stand()`, always named with --sig. See the README for what run does
/// if it is called here by mistake.
abstract contract FixtureCore is DeployCell {
    string internal constant HULL = "0f3eaf8";
    uint256 internal constant BASE_SEPOLIA = 84532;
    uint256 internal constant ANVIL = 31337;
    string internal constant RECORD_DIR = "exhibits/beanstalk-2022-04/fixture/record/";

    /// Every key the network's own deployment records name, as deployer, admin,
    /// protocol or genesis auditor, and the live cell's own address. The fixture
    /// takes a fresh key and refuses all of them in every seat (VD-270(ii)).
    /// Pulled from network/cell with the command in this directory's README.
    /// The first is the live cell's admin() and the second holds auditor position 1
    /// on it, both read from Base Sepolia on 2026-09-25.
    function _networkKeys() internal pure returns (address[9] memory k) {
        k[0] = 0xc9da07eC949261bAD9ffE51f11177A7a011D5708;
        k[1] = 0xDC4d0BBBF1Da2B54326B804FcF95A3B2F55c8fB3;
        k[2] = 0xb6494d7a2e7eBF3C2Fd4CA4AD5b17A235b58E8e7;
        k[3] = 0xfE649eD9ffedF3F3cf7C9F4282BA79BeA5bC483F;
        k[4] = 0xb0A35411b350038aCd79b9bEf455b77f03b9EC55;
        k[5] = 0x44ed2FDaf7e313B23f3777aA60Cb6902E7Df58eF;
        k[6] = 0xB909cA5651c1893486a1EAFB1189E4Db9d15f071;
        k[7] = 0x75A2B69a187A0527fe13248fEcfb88c5a7E98bFe;
        k[8] = 0xb034F198869726c36965B95879eCB65Bdb1076c9;
    }

    function _refuseNetworkKey(address a, string memory seat) internal pure {
        address[9] memory k = _networkKeys();
        for (uint256 i; i < k.length; ++i) {
            require(a != k[i], string.concat(seat, " is a network key; the fixture takes a fresh key (VD-270(ii))"));
        }
    }

    /// Base Sepolia for the fixture, anvil's default chain for the rehearsal. The two
    /// write different record files, so a rehearsal can never touch the real one.
    function _requireFixtureChain() internal view {
        require(
            block.chainid == BASE_SEPOLIA || block.chainid == ANVIL,
            "the fixture stands on Base Sepolia (84532) or an anvil rehearsal (31337) only"
        );
    }

    function _isLive() internal view returns (bool) {
        return vm.isContext(VmSafe.ForgeContext.ScriptBroadcast) || vm.isContext(VmSafe.ForgeContext.ScriptResume);
    }

    function _recordPath(bool live) internal view returns (string memory) {
        return string.concat(RECORD_DIR, vm.toString(block.chainid), live ? ".json" : ".dryrun.json");
    }

    /// The claim stake the cell will ask of a filer against a row of `bounty`:
    /// CellLogicLib.computeClaimStake, read from the cell's two getters. The
    /// rehearsal test proves it equal to requiredClaimStake on a real row.
    function _claimStakeFor(AuditCell cell, uint256 bounty) internal view returns (uint256) {
        uint256 scaled = (bounty * cell.claimStakeBps()) / 10_000;
        uint256 floor = cell.claimFilingStake();
        return scaled > floor ? scaled : floor;
    }

    /// The whole fixture read back from the chain: every admin seat is the fixture
    /// key, every wire points where DeployCell points it, and the testnet profile's
    /// named values are the ones on chain. The profile's windows are asserted by the
    /// cell's own PC-88(a) rule and printed, not retyped here.
    function _readBack(Deployed memory d, address key, address auditor) internal view {
        AuditCell c = d.cell;
        require(c.admin() == key, "cell admin");
        require(d.token.admin() == key, "token admin");
        require(d.escrow.admin() == key, "escrow admin");
        require(d.issuance.admin() == key, "issuance admin");
        require(d.claimModule.admin() == key, "claim module admin");
        require(d.specGapModule.admin() == key, "spec gap admin");
        require(d.specArbiterModule.admin() == key, "spec arbiter admin");
        require(d.integrityReviewModule.admin() == key, "integrity admin");
        require(d.structuralUpgradeModule.admin() == key, "structural admin");
        require(d.fmeaRegistry.admin() == key, "fmea admin");
        require(d.assignmentModule.admin() == key, "assignment admin");

        require(address(c.token()) == address(d.token), "cell token");
        require(c.treasuryEscrow() == address(d.escrow), "cell escrow");
        require(c.issuanceModule() == address(d.issuance), "cell issuance");
        require(c.assignmentModule() == address(d.assignmentModule), "cell assignment");
        require(c.entropyProvider() == address(d.blockhashEntropy), "cell entropy (testnet: BlockhashEntropy)");
        require(d.issuance.cell() == address(c), "issuance wire");
        require(d.issuance.structuralModule() == address(d.structuralUpgradeModule), "issuance structural");
        require(d.claimModule.cell() == address(c), "claim wire");
        require(d.claimModule.fmeaRegistry() == address(d.fmeaRegistry), "claim fmea");
        require(d.fmeaRegistry.claimModule() == address(d.claimModule), "fmea claim");
        require(d.specGapModule.cell() == address(c), "spec gap wire");
        require(d.specArbiterModule.cell() == address(c), "spec arbiter wire");
        require(d.integrityReviewModule.cell() == address(c), "integrity wire");
        require(d.integrityReviewModule.specArbiterModule() == address(d.specArbiterModule), "integrity arbiter");
        require(d.structuralUpgradeModule.cell() == address(c), "structural wire");
        require(d.structuralUpgradeModule.issuanceModule() == address(d.issuance), "structural issuance");
        require(d.assignmentModule.cell() == address(c), "assignment wire");
        require(d.escrow.network() == address(c), "escrow network");
        require(d.escrow.issuanceModule() == address(d.issuance), "escrow issuance");
        require(d.escrow.structuralUpgradeModule() == address(d.structuralUpgradeModule), "escrow structural");
        require(d.escrow.integrityReviewModule() == address(d.integrityReviewModule), "escrow integrity");
        require(d.escrow.founderReleaseTarget() == FOUNDER_RELEASE_TARGET_PAIRS, "founder release target");
        require(d.token.minter() == address(d.issuance), "token minter");

        require(c.genesisAuditor() == auditor, "genesis auditor (PC-85)");
        require(c.increment() == 0 && !c.incrementLocked(), "increment: the mainnet profile ran");
        require(c.claimFilingStake() == TESTNET_STAKE_FLOOR, "claim filing stake");
        require(d.specArbiterModule.specChallengeStake() == TESTNET_STAKE_FLOOR, "spec challenge stake");
        require(d.integrityReviewModule.integrityFilingStake() == TESTNET_STAKE_FLOOR, "integrity filing stake");
        require(d.integrityReviewModule.integrityContestStake() == TESTNET_STAKE_FLOOR, "integrity contest stake");
        require(d.structuralUpgradeModule.gapFilingStake() == TESTNET_STAKE_FLOOR, "gap filing stake");
        require(d.specArbiterModule.specChallengeFee() == SPEC_CHALLENGE_FEE_TESTNET, "spec challenge fee");
        require(
            d.specArbiterModule.specChallengeFee() < d.specArbiterModule.specChallengeStake(), "fee < stake (VD-117)"
        );
        _requireClaimWindowCoversAuditorPath(c);

        (, bool specIsSpec,,, bool specExists,,) = c.tools(SPEC_TOOL_ID);
        (, bool verdictIsSpec,,, bool verdictExists,,) = c.tools(VERDICT_TOOL_ID);
        require(specExists && specIsSpec, "spec tool");
        require(verdictExists && !verdictIsSpec, "verdict tool");

        (, bool r1SpecIsSpec,,, bool r1SpecExists,,) = c.tools(Room1.SPEC_TOOL);
        (, bool r1VerdictIsSpec,,, bool r1VerdictExists,,) = c.tools(Room1.VERDICT_TOOL);
        (, bool finderIsSpec,,, bool finderExists,,) = c.tools(Room2.FINDER_TOOL);
        (, bool evalIsSpec, bool evalIsEval, bool evalCanon, bool evalExists,,) = c.tools(Room2.EVALUATOR_TOOL);
        require(r1SpecExists && r1SpecIsSpec, "Room 1 spec tool");
        require(r1VerdictExists && !r1VerdictIsSpec, "Room 1 verdict tool");
        require(finderExists && !finderIsSpec, "door two finder tool");
        require(evalExists && !evalIsSpec && evalIsEval && evalCanon, "door two evaluator: canonical");
        require(d.specGapModule.vulnerabilityClassRegistered(Room2.gap().classId), "door two gap class");
    }

    function _print(Deployed memory d, address key, address auditor) internal view {
        AuditCell c = d.cell;
        console.log("Room 2 fixture: the DAN hull at", HULL, "- not the network's cell");
        console.log("  chain id                ", block.chainid);
        console.log("  fixture key             ", key);
        console.log("  genesis auditor         ", auditor);
        console.log("  AuditCell               ", address(c));
        console.log("  CellToken               ", address(d.token));
        console.log("  SpecGapModule           ", address(d.specGapModule));
        console.log("  StructuralUpgradeModule ", address(d.structuralUpgradeModule));
        console.log("  AuditCell runtime bytes ", address(c).code.length);
        console.log("  decision window (s)     ", c.decisionWindow());
        console.log("  protocol decision (s)   ", c.protocolDecisionWindow());
        console.log("  in-audit window (s)     ", c.inAuditWindow());
        console.log("  min audit window (s)    ", c.minAuditWindow());
        console.log("  claim resolution (s)    ", c.claimResolutionWindow());
        console.log("  claim filing stake (wei)", c.claimFilingStake());
        console.log("  fixture key AUDIT (wei) ", d.token.balanceOf(key));
    }

    function _record(Deployed memory d, address key, address auditor, uint256 mint, string memory path) internal {
        string memory r = "fixture";
        vm.serializeString(
            r,
            "what",
            "Room 2 fixture: an instance of the DAN hull at 0f3eaf8, deployed on Base Sepolia by the museum for one filing. Not the network's cell."
        );
        vm.serializeString(r, "hull", HULL);
        vm.serializeUint(r, "chainId", block.chainid);
        vm.serializeAddress(r, "fixtureKey", key);
        vm.serializeAddress(r, "genesisAuditor", auditor);
        vm.serializeUint(r, "genesisMint", mint);
        // The words the stand froze (VD-273(4)): the commit the stand ran from, and
        // the keccak256 of each gap word, as the class on chain and the filing carry
        // them. The filing refuses words that differ from these.
        string memory commit = vm.envOr("STAND_COMMIT", string(""));
        vm.serializeString(r, "standCommit", bytes(commit).length == 0 ? "none: a rehearsal" : commit);
        Room2.Gap memory g = Room2.gap();
        vm.serializeString(r, "gapWords", Room2.GAP_PATH);
        vm.serializeBytes32(r, "gapClassId", g.classId);
        vm.serializeBytes32(r, "gapInvariantId", g.invariantId);
        vm.serializeBytes32(r, "gapLocation", g.location);
        vm.serializeBytes32(r, "gapWitness", g.witness);
        vm.serializeBytes32(r, "gapContext", g.context);
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

    function _fromRecord(string memory json) internal pure returns (Deployed memory d, address key, address auditor) {
        d.token = CellToken(vm.parseJsonAddress(json, ".CellToken"));
        d.cell = AuditCell(vm.parseJsonAddress(json, ".AuditCell"));
        d.escrow = CellEscrow(vm.parseJsonAddress(json, ".CellEscrow"));
        d.issuance = IssuanceModule(vm.parseJsonAddress(json, ".IssuanceModule"));
        d.claimModule = ClaimDisputeModule(vm.parseJsonAddress(json, ".ClaimDisputeModule"));
        d.specGapModule = SpecGapModule(vm.parseJsonAddress(json, ".SpecGapModule"));
        d.specArbiterModule = SpecArbiterModule(vm.parseJsonAddress(json, ".SpecArbiterModule"));
        d.integrityReviewModule = IntegrityReviewModule(vm.parseJsonAddress(json, ".IntegrityReviewModule"));
        d.structuralUpgradeModule = StructuralUpgradeModule(vm.parseJsonAddress(json, ".StructuralUpgradeModule"));
        d.fmeaRegistry = FmeaRegistry(vm.parseJsonAddress(json, ".FmeaRegistry"));
        d.assignmentModule = AssignmentModule(vm.parseJsonAddress(json, ".AssignmentModule"));
        d.blockhashEntropy = BlockhashEntropy(vm.parseJsonAddress(json, ".BlockhashEntropy"));
        key = vm.parseJsonAddress(json, ".fixtureKey");
        auditor = vm.parseJsonAddress(json, ".genesisAuditor");
    }
}

/// Stand the fixture. One broadcast from the fixture key: deploy, wire, the testnet
/// profile, the tools with door two's evaluator flagged and its class registered,
/// the stake funding, the minter. Nothing after it touches the fixture's governance
/// (VD-270(ii), VD-260).
contract StandTheFixture is FixtureCore {
    /// Env: FIXTURE_KEY, the fresh museum key. The genesis-auditor seat is a choice,
    /// as on the network (PC-85): FIXTURE_GENESIS_AUDITOR names it, or
    /// FIXTURE_GENESIS_AUDITOR_OPEN=1 leaves it open on purpose.
    ///
    /// STAND_COMMIT, the commit the stand runs from, is required on Base Sepolia:
    /// gap.json's words are frozen there and the record cites it (VD-273(4)).
    function stand() external returns (Deployed memory) {
        if (block.chainid == BASE_SEPOLIA) {
            require(
                bytes(vm.envOr("STAND_COMMIT", string(""))).length == 40,
                "STAND_COMMIT required on Base Sepolia: the commit gap.json is frozen at (VD-273(4))"
            );
        }
        address auditor = _optionalAddress("FIXTURE_GENESIS_AUDITOR", address(0));
        bool open = _optionalUint("FIXTURE_GENESIS_AUDITOR_OPEN", 0) == 1;
        return standWith(vm.envUint("FIXTURE_KEY"), auditor, open);
    }

    function standWith(uint256 key, address auditor, bool open) public returns (Deployed memory d) {
        _requireFixtureChain();
        address fixture = vm.addr(key);
        _refuseNetworkKey(fixture, "FIXTURE_KEY");
        require(
            auditor != address(0) || open,
            "FIXTURE_GENESIS_AUDITOR required (PC-85). Set FIXTURE_GENESIS_AUDITOR_OPEN=1 to leave the seat open on purpose."
        );
        require(auditor != fixture, "FIXTURE_GENESIS_AUDITOR must not be the fixture key (PC-86)");
        if (auditor != address(0)) _refuseNetworkKey(auditor, "FIXTURE_GENESIS_AUDITOR");

        // One fixture per Base Sepolia record. A second deploy is the reopen case
        // (VD-270): the old record is marked superseded by hand first, then moved.
        bool live = _isLive();
        string memory path = _recordPath(live);
        if (live && block.chainid == BASE_SEPOLIA) {
            require(
                !vm.exists(path),
                "a fixture is already recorded on Base Sepolia; supersede it by hand first (VD-270 reopen)"
            );
        }

        vm.startBroadcast(key);

        // --- DeployCell.run lines 146-162 at 0f3eaf8, the fixture key as deployer ---
        d.token = new CellToken();
        d.cell = new AuditCell(address(d.token));
        if (auditor != address(0)) d.cell.setGenesisBootstrap(address(0), auditor);
        d.escrow = new CellEscrow(address(d.token));
        d.issuance = new IssuanceModule(fixture);
        d.claimModule = new ClaimDisputeModule(fixture);
        d.specGapModule = new SpecGapModule(fixture);
        d.specArbiterModule = new SpecArbiterModule(fixture);
        d.integrityReviewModule = new IntegrityReviewModule(fixture);
        d.structuralUpgradeModule = new StructuralUpgradeModule(fixture);
        d.fmeaRegistry = new FmeaRegistry(fixture);
        d.assignmentModule = new AssignmentModule(fixture);
        d.blockhashEntropy = new BlockhashEntropy();

        // --- lines 165-198: the wiring, in DeployCell's order, testnet branch ---
        d.issuance.wire(address(d.cell), address(d.token), address(d.escrow));
        d.issuance.setEmaToMintBps(2500);
        d.issuance.setMintLpCapBps(500);
        d.claimModule.wire(address(d.cell));
        d.fmeaRegistry.wireClaimModule(address(d.claimModule));
        d.claimModule.wireFmeaRegistry(address(d.fmeaRegistry));
        d.assignmentModule.wire(address(d.cell));
        d.specGapModule.wire(address(d.cell));
        d.specArbiterModule.wire(address(d.cell));
        d.integrityReviewModule.wire(address(d.cell), address(d.specArbiterModule));
        d.structuralUpgradeModule.wire(address(d.cell), address(d.issuance));
        d.issuance.setStructuralModule(address(d.structuralUpgradeModule));
        d.escrow.setFounderReleaseTarget(FOUNDER_RELEASE_TARGET_PAIRS);
        d.escrow.setNetwork(address(d.cell));
        d.escrow.setIssuanceModule(address(d.issuance));
        d.escrow.setStructuralUpgradeModule(address(d.structuralUpgradeModule));
        d.escrow.setIntegrityReviewModule(address(d.integrityReviewModule));
        d.cell.setTreasuryEscrow(address(d.escrow));
        d.cell.setIssuanceModule(address(d.issuance));
        d.cell.setDisputeModule(0, address(d.claimModule));
        d.cell.setDisputeModule(1, address(d.specGapModule));
        d.cell.setDisputeModule(2, address(d.specArbiterModule));
        d.cell.setDisputeModule(3, address(d.integrityReviewModule));
        d.cell.setDisputeModule(4, address(d.structuralUpgradeModule));
        d.cell.setAssignmentModule(address(d.assignmentModule));
        d.cell.setEntropyProvider(address(d.blockhashEntropy));

        // --- the testnet profile: inherited, not copied (lines 202, 218) ---
        _applyTestnetTimeProfile(d);
        d.specArbiterModule.setSpecChallengeFee(SPEC_CHALLENGE_FEE_TESTNET);

        // --- tools (lines 235-236), then the stake funding before the minter ---
        d.cell.registerTool(SPEC_TOOL_ID, true);
        d.cell.registerTool(VERDICT_TOOL_ID, false);
        // The museum's own: Room 1's two labels, so the row door two files against is
        // Room 1's row, and door two's finder and evaluator. Flagging the evaluator
        // canonical and registering the gap's class are admin acts, and the stand is
        // the fixture's only admin broadcast, so they are made here. The canonical
        // flag can never be cleared (ToolUseLib, monotone).
        d.cell.registerTool(Room1.SPEC_TOOL, true);
        d.cell.registerTool(Room1.VERDICT_TOOL, false);
        d.cell.registerTool(Room2.FINDER_TOOL, false);
        d.cell.registerTool(Room2.EVALUATOR_TOOL, false);
        d.cell.setToolWitnessFlags(Room2.EVALUATOR_TOOL, true, true);
        d.specGapModule.registerClass(Room2.gap().classId);
        // One row of Room 1's bounty and the claim stake a filer is asked against it.
        // setMinter follows at once and closes genesisMint for good, so this is the
        // only AUDIT on the fixture that its own lifecycle did not pay out.
        uint256 mint = Room1.BOUNTY + _claimStakeFor(d.cell, Room1.BOUNTY);
        d.token.genesisMint(fixture, mint);
        d.token.setMinter(address(d.issuance));

        vm.stopBroadcast();

        _readBack(d, fixture, auditor);
        require(d.token.totalSupply() == mint && d.token.balanceOf(fixture) == mint, "stake funding");
        _print(d, fixture, auditor);
        if (vm.isContext(VmSafe.ForgeContext.ScriptGroup)) _record(d, fixture, auditor, mint, path);
    }
}

/// Read the recorded fixture back from whatever node serves it: every seat, wire and
/// profile value asserted against the chain. Sends nothing.
contract ReadTheFixture is FixtureCore {
    function check() external view {
        _requireFixtureChain();
        string memory path = _recordPath(true);
        (Deployed memory d, address key, address auditor) = _fromRecord(vm.readFile(path));
        _readBack(d, key, auditor);
        _print(d, key, auditor);
        console.log("  read back from          ", path);
    }
}
