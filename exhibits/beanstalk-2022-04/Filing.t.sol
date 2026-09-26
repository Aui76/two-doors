// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployCell} from "lib/dan/cell/script/DeployCell.s.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {SpecGapModule} from "dan/SpecGapModule.sol";
import {SpecGapLib} from "dan/SpecGapLib.sol";
import {StandTheFixture} from "./fixture/Fixture.s.sol";
import {FileTheGap, FilingCore} from "./filing/Filing.s.sol";
import {Room1} from "./verdict/Room1.sol";
import {Room2} from "./filing/Room2.sol";

/// The filing's freeze check, reached from a test (VD-273(4)).
contract FrozenWords is FileTheGap {
    function check(string memory stood) external view {
        _requireTheWordsTheStandFroze(stood);
    }
}

/// Door two, proven in memory before any node sees it: the fixture stood as the
/// stand stands it, then the filing run from each seat the fixture key can take.
/// The filing reads itself back on every run (Filing.s.sol, _readBackFiling);
/// these tests add what follows the filing, and what it refuses.
///
/// No fork and no archive key: the fixture is a fresh deploy, not 2022 state.
contract FilingTest is Test {
    /// Made up for these tests, as in FixtureTest. Not anvil's, not the network's.
    uint256 internal constant KEY = 0xF1C5;
    address internal auditor;
    uint256 internal auditorKey;
    address internal second;
    uint256 internal secondKey;
    StandTheFixture internal stand;
    FileTheGap internal filing;

    function setUp() public {
        (auditor, auditorKey) = makeAddrAndKey("door two auditor");
        (second, secondKey) = makeAddrAndKey("door two second key");
        stand = new StandTheFixture();
        filing = new FileTheGap();
    }

    function _stand() internal returns (DeployCell.Deployed memory) {
        return stand.standWith(KEY, auditor, false);
    }

    function _fileAs(bool fixtureIsProtocol)
        internal
        returns (DeployCell.Deployed memory d, FilingCore.Filing memory f)
    {
        d = _stand();
        f = filing.fileWith(d, KEY, auditorKey, secondKey, fixtureIsProtocol);
    }

    /// Every hash-bearing word in gap.json is found again in the file it names.
    function test_theGapsWordsPointAtTheirSources() public view {
        string memory j = Room2.words();
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

    function test_standMakesDoorTwosAdminActsInItsOneBroadcast() public {
        DeployCell.Deployed memory d = _stand();
        (,, bool isEval, bool canonical, bool exists,,) = d.cell.tools(Room2.EVALUATOR_TOOL);
        assertTrue(exists && isEval && canonical, "evaluator flagged canonical by the stand");
        assertTrue(d.specGapModule.vulnerabilityClassRegistered(Room2.gap().classId), "class registered by the stand");
        vm.expectRevert(SpecGapModule.NotAdmin.selector);
        vm.prank(second);
        d.specGapModule.registerClass(keccak256("any other class"));
    }

    function test_filesWithTheFixtureKeyAsProtocol() public {
        (DeployCell.Deployed memory d, FilingCore.Filing memory f) = _fileAs(true);
        assertEq(f.protocol, vm.addr(KEY), "fixture key files the row");
        assertEq(f.discoverer, second, "second key files the gap");
        assertEq(d.token.balanceOf(second), 0, "the discoverer staked all it was handed");
        assertEq(d.token.balanceOf(vm.addr(KEY)), 0, "the fixture key holds nothing");
        emit log_named_uint("filing stake (wei)", f.stake);
        emit log_named_bytes32("result root", f.resultRoot);
    }

    function test_filesWithTheFixtureKeyAsDiscoverer() public {
        (DeployCell.Deployed memory d, FilingCore.Filing memory f) = _fileAs(false);
        assertEq(f.protocol, second, "second key files the row");
        assertEq(f.discoverer, vm.addr(KEY), "fixture key files the gap");
        assertEq(d.token.balanceOf(second), 0, "the protocol spent the bounty it was handed");
        assertEq(d.token.balanceOf(vm.addr(KEY)), 0, "the fixture key holds nothing");
    }

    /// The protocol stays silent. Once its decision window has passed, anyone
    /// confirms the gap: the stake goes back to the discoverer, and the gap is
    /// recorded against Room 1's spec tool.
    function test_silenceConfirmsTheGapAndReturnsTheStake() public {
        (DeployCell.Deployed memory d, FilingCore.Filing memory f) = _fileAs(true);
        uint256 opens = f.filedAt + d.cell.protocolDecisionWindow();

        vm.warp(opens - 1);
        vm.expectRevert(SpecGapModule.ProtocolWindowOpen.selector);
        d.specGapModule.confirmSpecGapSilence(f.auditId, f.gap.classId);

        vm.warp(opens);
        vm.prank(makeAddr("anyone"));
        d.specGapModule.confirmSpecGapSilence(f.auditId, f.gap.classId);

        assertEq(
            uint256(d.specGapModule.specGapStatusOf(f.auditId, f.gap.classId)), uint256(SpecGapLib.Status.Confirmed)
        );
        assertEq(d.token.balanceOf(f.discoverer), f.stake, "stake returned");
        assertEq(d.specGapModule.toolKnownGapCount(Room1.SPEC_TOOL), 1, "one known gap on Room 1's spec tool");
        assertEq(d.specGapModule.toolKnownGapAt(Room1.SPEC_TOOL, 0), f.gap.classId, "and it is this class");
    }

    /// Silence returns the stake and pays nothing more. A reward is the protocol's
    /// adoption, paid from the protocol's own AUDIT. On the fixture the protocol
    /// holds none after the bounty, so adoption fails until something funds it.
    function test_adoptionIsPaidFromTheProtocol() public {
        (DeployCell.Deployed memory d, FilingCore.Filing memory f) = _fileAs(true);
        vm.warp(f.filedAt + d.cell.protocolDecisionWindow());
        d.specGapModule.confirmSpecGapSilence(f.auditId, f.gap.classId);

        uint256 reward = f.stake;
        assertEq(d.token.balanceOf(f.protocol), 0, "the protocol holds nothing after the bounty");
        vm.startPrank(f.protocol);
        d.token.approve(address(d.cell), reward);
        vm.expectRevert();
        d.specGapModule.adoptSpecGap(f.auditId, f.gap.classId, reward);
        vm.stopPrank();

        vm.prank(address(d.issuance));
        d.token.mint(f.protocol, reward);
        vm.prank(f.protocol);
        d.specGapModule.adoptSpecGap(f.auditId, f.gap.classId, reward);
        assertEq(
            uint256(d.specGapModule.specGapStatusOf(f.auditId, f.gap.classId)), uint256(SpecGapLib.Status.Adopted)
        );
        assertEq(d.token.balanceOf(f.discoverer), f.stake + reward, "stake back and the reward");
    }

    /// The row's own window runs beside the gap. When it closes the row settles
    /// and its auditor is paid; the gap stays where it was.
    function test_theRowSettlesBesideTheGap() public {
        (DeployCell.Deployed memory d, FilingCore.Filing memory f) = _fileAs(true);
        vm.warp(block.timestamp + d.cell.minAuditWindow() + 1);
        d.cell.confirmAudit(f.auditId);
        emit log_named_uint("row state after its window", uint256(d.cell.auditStateOf(f.auditId)));
        emit log_named_uint("auditor AUDIT after its window (wei)", d.token.balanceOf(auditor));
        assertGt(d.token.balanceOf(auditor), 0, "the auditor is paid");
        assertEq(uint256(d.specGapModule.specGapStatusOf(f.auditId, f.gap.classId)), uint256(SpecGapLib.Status.Filed));
    }

    function test_refusesThreeSeatsOnTwoKeys() public {
        DeployCell.Deployed memory d = _stand();
        string memory why = "three seats, three keys: the hull refuses a discoverer who is the row's protocol or auditor";
        vm.expectRevert(bytes(why));
        filing.fileWith(d, KEY, auditorKey, auditorKey, true);
        vm.expectRevert(bytes(why));
        filing.fileWith(d, KEY, auditorKey, KEY, false);
    }

    function test_refusesAnAuditorTheStandDidNotName() public {
        DeployCell.Deployed memory d = _stand();
        (, uint256 otherKey) = makeAddrAndKey("not the named auditor");
        vm.expectRevert(bytes("AUDITOR_KEY is not the fixture's genesis auditor"));
        filing.fileWith(d, KEY, otherKey, secondKey, true);
    }

    function test_refusesAKeyThatDidNotStandTheFixture() public {
        DeployCell.Deployed memory d = _stand();
        vm.expectRevert(bytes("FIXTURE_KEY is not the key that stood this fixture"));
        filing.fileWith(d, secondKey, auditorKey, KEY, true);
    }

    /// The stand records the gap's words; the filing refuses any that differ.
    function test_refusesGapWordsTheStandDidNotFreeze() public {
        FrozenWords frozen = new FrozenWords();
        Room2.Gap memory g = Room2.gap();
        vm.serializeBytes32("stood", "gapClassId", g.classId);
        vm.serializeBytes32("stood", "gapInvariantId", g.invariantId);
        vm.serializeBytes32("stood", "gapLocation", g.location);
        vm.serializeBytes32("stood", "gapContext", g.context);
        frozen.check(vm.serializeBytes32("stood", "gapWitness", g.witness));

        string memory moved = vm.serializeBytes32("stood", "gapWitness", keccak256("a witness edited after the stand"));
        vm.expectRevert(
            bytes("gap.json differs from the words the stand froze (VD-273(4)): a changed gap is a second exhibit")
        );
        frozen.check(moved);
    }

    function test_filesOnce() public {
        (DeployCell.Deployed memory d,) = _fileAs(true);
        vm.expectRevert(bytes("the fixture already holds a row; door two files once (VD-270)"));
        filing.fileWith(d, KEY, auditorKey, secondKey, true);
    }
}
