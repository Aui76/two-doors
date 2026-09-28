// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployCell} from "deps/dan/cell/script/DeployCell.s.sol";
import {StandTheFixture} from "./fixture/Fixture.s.sol";
import {Room1} from "./verdict/Room1.sol";

/// Room 2's fixture, proven in memory before any node sees it. The stand reads
/// itself back on every run (Fixture.s.sol, _readBack); these tests add what the
/// stand cannot see from inside: that the stake funding is exactly what the cell
/// asks against a real row, and that every seat refuses what VD-270 refuses.
///
/// No fork and no archive key: the fixture is a fresh deploy, not 2022 state.
contract FixtureTest is Test {
    /// A key made up for this test. Not one of anvil's, not one of the network's.
    uint256 internal constant KEY = 0xF1C5;
    address internal auditor = makeAddr("fixture genesis auditor");
    StandTheFixture internal s;

    function setUp() public {
        s = new StandTheFixture();
    }

    function test_standsTheHullUnderTheTestnetProfile() public {
        DeployCell.Deployed memory d = s.standWith(KEY, auditor, false);
        address fixture = vm.addr(KEY);
        assertEq(d.cell.admin(), fixture, "the fixture key administers the cell");
        assertEq(d.cell.genesisAuditor(), auditor, "the named seat");
        assertEq(d.token.minter(), address(d.issuance), "genesisMint is closed");
        assertEq(d.cell.claimFilingStake(), s.TESTNET_STAKE_FLOOR(), "testnet stake floor");
        emit log_named_uint("fixture key AUDIT (wei)", d.token.balanceOf(fixture));
        emit log_named_uint("AuditCell runtime bytes", address(d.cell).code.length);
    }

    /// The mint is one row of Room 1's bounty and the claim stake against it. Filed
    /// here from the fixture key only to make the cell name its price; who files
    /// what in Room 2 is not decided by this test.
    function test_mintIsOneRowAndTheClaimStakeAgainstIt() public {
        DeployCell.Deployed memory d = s.standWith(KEY, auditor, false);
        address fixture = vm.addr(KEY);

        vm.prank(auditor);
        d.cell.register();

        bytes32[] memory declared = new bytes32[](1);
        declared[0] = keccak256("genesis.verdict.tool");
        bytes32 specHash = keccak256(bytes(vm.readFile(Room1.SPEC_PATH)));

        vm.startPrank(fixture);
        d.token.approve(address(d.cell), Room1.BOUNTY);
        uint256 id = d.cell.submitArtifactAudit(
            Room1.BEANSTALK_CODEHASH,
            address(0),
            specHash,
            keccak256("genesis.spec.tool"),
            keccak256(""),
            Room1.BOUNTY,
            declared,
            0,
            0
        );
        vm.stopPrank();

        uint256 stake = d.cell.requiredClaimStake(id);
        emit log_named_uint("requiredClaimStake (wei)", stake);
        assertEq(d.token.balanceOf(fixture), stake, "what is left after the bounty is the claim stake, exactly");
    }

    function test_theOpenSeatIsAChoice() public {
        vm.expectRevert(
            bytes(
                "FIXTURE_GENESIS_AUDITOR required (PC-85). Set FIXTURE_GENESIS_AUDITOR_OPEN=1 to leave the seat open on purpose."
            )
        );
        s.standWith(KEY, address(0), false);

        DeployCell.Deployed memory d = s.standWith(KEY, address(0), true);
        assertEq(d.cell.genesisAuditor(), address(0), "left open on purpose");
    }

    function test_refusesTheFixtureKeyAsItsOwnAuditor() public {
        vm.expectRevert(bytes("FIXTURE_GENESIS_AUDITOR must not be the fixture key (PC-86)"));
        s.standWith(KEY, vm.addr(KEY), false);
    }

    function test_refusesEveryNetworkKeyInTheAuditorSeat() public {
        address[13] memory k = [
            0xc9da07eC949261bAD9ffE51f11177A7a011D5708,
            0xDC4d0BBBF1Da2B54326B804FcF95A3B2F55c8fB3,
            0xb6494d7a2e7eBF3C2Fd4CA4AD5b17A235b58E8e7,
            0xfE649eD9ffedF3F3cf7C9F4282BA79BeA5bC483F,
            0xb0A35411b350038aCd79b9bEf455b77f03b9EC55,
            0x44ed2FDaf7e313B23f3777aA60Cb6902E7Df58eF,
            0xB909cA5651c1893486a1EAFB1189E4Db9d15f071,
            0x75A2B69a187A0527fe13248fEcfb88c5a7E98bFe,
            0xb034F198869726c36965B95879eCB65Bdb1076c9,
            0x3EA29eA8b7aB19Ca2C6f7BD409f1d8d1Ef7b4A37,
            0x216D23BBa1Fb785853d3D0f219BAE71C8D60a3AF,
            0x4B9B66A6603e27098a3Ff4b806D973391Fa324Cd,
            0x67890D4cbD646AD78F72241CA591b9a60456C64E
        ];
        for (uint256 i; i < k.length; ++i) {
            vm.expectRevert(
                bytes("FIXTURE_GENESIS_AUDITOR is a network key; the fixture takes a fresh key (VD-270(ii))")
            );
            s.standWith(KEY, k[i], false);
        }
    }

    function test_standsOnlyOnBaseSepoliaOrTheRehearsal() public {
        vm.chainId(1);
        vm.expectRevert(bytes("the fixture stands on Base Sepolia (84532) or an anvil rehearsal (31337) only"));
        s.standWith(KEY, auditor, false);

        vm.chainId(84532);
        DeployCell.Deployed memory d = s.standWith(KEY, auditor, false);
        assertEq(d.cell.admin(), vm.addr(KEY), "stands on 84532");
    }
}
