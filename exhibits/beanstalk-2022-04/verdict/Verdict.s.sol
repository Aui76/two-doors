// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {Room1} from "./Room1.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellToken} from "dan/CellToken.sol";

/// Room 1 on a node you can point dan-check at.
///
/// The test proves the lifecycle and forgets it. This script does the same work
/// against a running anvil fork of mainnet at the room's block, so the row stays
/// where a reader can ask the door about it. It stops with the window open; the
/// README closes it with two RPC calls and confirms the row, because a script
/// cannot move a node's clock.
///
/// The three parties are anvil's first three default accounts, derived from its
/// mnemonic rather than pasted. 0 deploys and administers, 1 files the row, 2 audits.
contract FileTheVerdict is Script {
    string internal constant MNEMONIC = "test test test test test test test test test test test junk";

    function run() external {
        require(block.chainid == 1, "not a fork of mainnet: start anvil with --fork-url");
        require(block.number >= Room1.FORK_BLOCK, "the node is behind the room's block");
        bytes memory code = Room1.BEANSTALK.code;
        require(code.length == Room1.BEANSTALK_CODE_LENGTH, "Beanstalk's code is not what the room names");
        bytes32 codehash = keccak256(code);
        require(codehash == Room1.BEANSTALK_CODEHASH, "Beanstalk's code hash is not what the room names");
        bytes32 specHash = keccak256(bytes(vm.readFile(Room1.SPEC_PATH)));

        uint256 adminKey = vm.deriveKey(MNEMONIC, 0);
        uint256 protocolKey = vm.deriveKey(MNEMONIC, 1);
        uint256 auditorKey = vm.deriveKey(MNEMONIC, 2);
        address protocol = vm.addr(protocolKey);
        address auditor = vm.addr(auditorKey);

        vm.startBroadcast(adminKey);
        Room1.Hull memory d = Room1.stand(vm.addr(adminKey), protocol);
        vm.stopBroadcast();
        AuditCell cell = d.cell;
        CellToken token = d.token;

        vm.startBroadcast(auditorKey);
        cell.register();
        vm.stopBroadcast();

        vm.startBroadcast(protocolKey);
        uint256 id = Room1.file(cell, token, codehash, specHash);
        cell.protocolAcceptAuditor(id);
        vm.stopBroadcast();

        vm.startBroadcast(auditorKey);
        cell.acceptAudit(id, Room1.SPEC_ERRORS);
        cell.provePass(id, Room1.VERDICT_TOOL, Room1.resultRoot(specHash));
        vm.stopBroadcast();

        console2.log("cell", address(cell));
        console2.log("audit id", id);
        console2.logBytes32(codehash);
        console2.logBytes32(specHash);
        console2.log("state (4 = AwaitingWindow)", uint256(cell.auditStateOf(id)));
        console2.log("min audit window (seconds)", cell.minAuditWindow());
        console2.log("protocol", protocol);
        console2.log("auditor", auditor);
    }
}
