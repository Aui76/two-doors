// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {Room1} from "../beanstalk-2022-04/verdict/Room1.sol";
import {Room3} from "./Room3.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellToken} from "dan/CellToken.sol";

/// Room 3 on a node you can point dan-check at.
///
/// The same row the test files, broadcast to a running anvil fork of mainnet at
/// the room's block, so it stays where the door can be asked before and after
/// the two real transactions run. It stops with the window open; the README
/// closes it, confirms the row, and replays the transactions with anvil's
/// impersonation, because a script can neither move a node's clock nor send as
/// an account it has no key for.
///
/// The parties are anvil's first three default accounts, derived from its
/// mnemonic. 0 deploys and administers, 1 files the row, 2 audits. The hull is
/// Room 1's, stood the same way; this room adds its own two tool labels.
contract FileTheNoSeatRow is Script {
    string internal constant MNEMONIC = "test test test test test test test test test test test junk";

    function run() external {
        require(block.chainid == 1, "not a fork of mainnet: start anvil with --fork-url");
        require(block.number >= Room3.FORK_BLOCK, "the node is behind the room's block");
        bytes memory code = Room3.WALLET.code;
        require(code.length == Room3.WALLET_CODE_LENGTH, "the wallet's code is not what the room names");
        require(keccak256(code) == Room3.WALLET_CODEHASH, "the wallet's code hash is not what the room names");
        address slot0 = address(uint160(uint256(vm.load(Room3.WALLET, bytes32(0)))));
        require(slot0 == Room3.SINGLETON, "slot 0 has moved: fork at the block before the signed transaction");
        bytes32 specHash = keccak256(bytes(vm.readFile(Room3.SPEC_PATH)));

        uint256 adminKey = vm.deriveKey(MNEMONIC, 0);
        uint256 protocolKey = vm.deriveKey(MNEMONIC, 1);
        uint256 auditorKey = vm.deriveKey(MNEMONIC, 2);

        vm.startBroadcast(adminKey);
        Room1.Hull memory d = Room1.stand(vm.addr(adminKey), vm.addr(protocolKey));
        Room3.registerTools(d.cell);
        vm.stopBroadcast();
        AuditCell cell = d.cell;
        CellToken token = d.token;

        vm.startBroadcast(auditorKey);
        cell.register();
        vm.stopBroadcast();

        vm.startBroadcast(protocolKey);
        uint256 id = Room3.file(cell, token, specHash);
        cell.protocolAcceptAuditor(id);
        vm.stopBroadcast();

        vm.startBroadcast(auditorKey);
        cell.acceptAudit(id, Room3.SPEC_ERRORS);
        cell.provePass(id, Room3.VERDICT_TOOL, Room3.resultRoot(specHash));
        vm.stopBroadcast();

        console2.log("cell", address(cell));
        console2.log("audit id", id);
        console2.logBytes32(Room3.WALLET_CODEHASH);
        console2.logBytes32(specHash);
        console2.log("state (4 = AwaitingWindow)", uint256(cell.auditStateOf(id)));
        console2.log("min audit window (seconds)", cell.minAuditWindow());
    }
}
