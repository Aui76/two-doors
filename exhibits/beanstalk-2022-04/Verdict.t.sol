// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Room1} from "./verdict/Room1.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {CellToken} from "dan/CellToken.sol";

/// Room 1: the hull stands beside Beanstalk on the morning of 16 April 2022, a
/// row is filed against the diamond's code, and the door is asked.
///
/// The fork is the one Fork.t.sol proves. The hull is the cured one at 0f3eaf8,
/// compiled from the public export in deps/dan with its own settings. Nothing about
/// the row is a promise: `InBlock` means settled, window closed, nothing claimed as
/// of this block, and the door's own table says exactly that
/// (exhibits/exit/dan-check/dan-check.mjs).
///
/// Every number is read at run time and printed. The one constant, the code hash,
/// is checked against the bytes on the fork before it is used.
contract BeanstalkVerdictTest is Test {
    address internal constant PROTOCOL = address(0xA11CE);
    address internal constant AUDITOR = address(0xB0B);

    AuditCell internal cell;
    CellToken internal token;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), Room1.FORK_BLOCK);
        Room1.Hull memory d = Room1.stand(address(this), PROTOCOL);
        cell = d.cell;
        token = d.token;
    }

    /// The hash the row will name is the hash of the bytes that are there.
    function _codehashOnTheFork() internal view returns (bytes32 h) {
        bytes memory code = Room1.BEANSTALK.code;
        assertEq(code.length, Room1.BEANSTALK_CODE_LENGTH, "the diamond's code is a different length here");
        h = keccak256(code);
        assertEq(h, Room1.BEANSTALK_CODEHASH, "the diamond's code hash does not match");
    }

    function _specHash() internal view returns (bytes32) {
        return keccak256(bytes(vm.readFile(Room1.SPEC_PATH)));
    }

    /// File, prove, and stop at the open window. Returns the row id.
    function _fileAndProve(bytes32 codehash, bytes32 specHash) internal returns (uint256 id) {
        vm.prank(AUDITOR);
        cell.register();

        vm.startPrank(PROTOCOL);
        id = Room1.file(cell, token, codehash, specHash);
        vm.stopPrank();

        assertEq(uint256(cell.auditStateOf(id)), uint256(CellTypeDefs.AuditState.Assigned), "not assigned");
        assertEq(cell.auditAuditorOf(id), AUDITOR, "assigned to someone else");

        vm.prank(PROTOCOL);
        cell.protocolAcceptAuditor(id);
        vm.prank(AUDITOR);
        cell.acceptAudit(id, Room1.SPEC_ERRORS);
        vm.prank(AUDITOR);
        cell.provePass(id, Room1.VERDICT_TOOL, Room1.resultRoot(specHash));
    }

    /// The whole lifecycle, and the read-back the door performs.
    function test_theRowIsFiledSettledAndFoundByTheCodeHash() public {
        bytes32 codehash = _codehashOnTheFork();
        bytes32 specHash = _specHash();

        uint256 id = _fileAndProve(codehash, specHash);

        // The verdict is in, and the window is open. dan-check refuses here
        // (exit 2): a passing audit with an open window is not a verdict yet.
        assertEq(
            uint256(cell.auditStateOf(id)), uint256(CellTypeDefs.AuditState.AwaitingWindow), "window should be open"
        );

        uint256 window = cell.minAuditWindow();
        vm.warp(block.timestamp + window + 1);
        cell.confirmAudit(id);

        assertEq(uint256(cell.auditStateOf(id)), uint256(CellTypeDefs.AuditState.InBlock), "did not settle");
        assertEq(cell.artifactToAuditId(codehash), id, "the door would not find this row by the code hash");

        emit log_named_uint("fork block", block.number);
        emit log_named_address("cell", address(cell));
        emit log_named_uint("audit id", id);
        emit log_named_bytes32("artifact hash (Beanstalk diamond code)", codehash);
        emit log_named_bytes32("spec hash (governance-v0.json)", specHash);
        emit log_named_bytes32("case root", cell.caseRootOf(id));
        emit log_named_uint("min audit window (seconds)", window);
        emit log_named_uint("state (6 = InBlock)", uint256(cell.auditStateOf(id)));
    }

    /// The door finds nothing for bytes that were not audited. One byte more and
    /// the hash is a different artifact.
    ///
    /// The index alone cannot say this: the row filed here is id 0, the first a
    /// fresh cell files, so `artifactToAuditId` answers 0 for the real row AND for
    /// the stranger. The presence bit `artifactRegistered` is what tells them
    /// apart, and it is what dan-check reads first (PC-132).
    function test_aDifferentHashFindsNoRow() public {
        bytes32 codehash = _codehashOnTheFork();
        bytes32 specHash = _specHash();
        uint256 id = _fileAndProve(codehash, specHash);
        vm.warp(block.timestamp + cell.minAuditWindow() + 1);
        cell.confirmAudit(id);

        bytes32 other = keccak256(abi.encodePacked(Room1.BEANSTALK.code, hex"00"));
        assertEq(id, 0, "the first row a fresh cell files is id 0");
        assertEq(cell.artifactToAuditId(other), cell.artifactToAuditId(codehash), "the index cannot tell them apart");
        assertTrue(cell.artifactRegistered(codehash), "the real row is registered");
        assertFalse(cell.artifactRegistered(other), "a different artifact must find no row");
    }

    /// The window cannot be skipped. Confirming early is refused, and the row
    /// stays where the door refuses to answer.
    function test_theWindowCannotBeSkipped() public {
        uint256 id = _fileAndProve(_codehashOnTheFork(), _specHash());
        vm.expectRevert();
        cell.confirmAudit(id);
        assertEq(uint256(cell.auditStateOf(id)), uint256(CellTypeDefs.AuditState.AwaitingWindow), "moved early");
    }
}
