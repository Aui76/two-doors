// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AuditCell} from "dan/AuditCell.sol";
import {CellToken} from "dan/CellToken.sol";

/// Room 3: the room with no seat.
///
/// What the tests and the script share. The hull is Room 1's, stood the same way
/// (Room1.stand); this room adds its own two tool labels and files its own row,
/// against the Bybit cold wallet's code hash, with no deployed address behind it.
///
/// Every constant below was printed by a command in README.md and is checked
/// against the fork before it is used. The two transactions are named by hash
/// only: their bytes are fetched from the node at run time, never pasted in.
library Room3 {
    /// The block before the signed transaction. 21 February 2025, 14:13:23 UTC.
    uint256 internal constant FORK_BLOCK = 21_895_237;

    /// The wallet: a Safe v1.1.1 proxy, 170 bytes, that forwards every call to
    /// the address in its storage slot 0.
    address internal constant WALLET = 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4;
    bytes32 internal constant WALLET_CODEHASH = 0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5;
    uint256 internal constant WALLET_CODE_LENGTH = 170;

    /// What slot 0 held before: the Safe v1.1.1 singleton, 24,040 bytes.
    address internal constant SINGLETON = 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F;
    bytes32 internal constant SINGLETON_CODEHASH = 0x56b8be58b5ad629a621593a2e5e5e8e9a28408dc06e95597497b303902772e45;

    /// What slot 0 held after. Neither address is trusted from a write-up: the
    /// tests read slot 0 before and after the replayed transaction and compare.
    address internal constant BACKDOOR = 0xbDd077f651EBe7f7b3cE16fe5F2b025BE2969516;

    /// The two real transactions, in the order they were mined.
    /// Block 21,895,238: execTransaction, operation 1, three signatures.
    bytes32 internal constant TX_SIGNED = 0x46deef0f52e3a983b67abf4714448a41dd7ffd6d32d32da69d62081c68ad7882;
    /// Block 21,895,251: the ETH leaves.
    bytes32 internal constant TX_SWEEP = 0xb61413c495fdad6114a7aa863a00b2e3c28945979a10885b12b30316ea9f072c;

    /// The signed transaction's words, as the Safe hashes them. Read off the
    /// node's record of TX_SIGNED (`cast tx`), and not trusted from here: the
    /// tests rebuild the calldata from these and require it to appear byte for
    /// byte in what the node returns for that hash.
    address internal constant SIGNED_TO = 0x96221423681A6d52E184D440a8eFCEbB105C7242;
    uint8 internal constant SIGNED_OPERATION = 1;
    uint256 internal constant SIGNED_SAFE_TX_GAS = 45_746;
    uint256 internal constant SIGNED_NONCE = 71;
    bytes internal constant SIGNATURES =
        hex"d0afef78a52fd504479dc2af3dc401334762cbd05609c7ac18db9ec5abf4a07a5cc09fc86efd3489707b89b0c729faed616459189cb50084f208d03b201b001f1f0f62ad358d6b319d3c1221d44456080068fe02ae5b1a39b4afb1e6721ca7f9903ac523a801533f265231cd35fc2dfddc3bd9a9563b51315cf9d5ff23dc6d2c221fdf9e4b878877a8dbeee951a4a31ddbf1d3b71e127d5eda44b4730030114baba52e06dd23da37cd2a07a6e84f9950db867374a0f77558f42adf4409bfd569673c1f";

    /// Where the sweep sent the ETH, read the same way off TX_SWEEP.
    address internal constant SWEEP_TO = 0x47666Fab8bd0Ac7003bce3f5C3585383F09486E2;

    function signedData() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("transfer(address,uint256)", BACKDOOR, uint256(0));
    }

    function signedCalldata() internal pure returns (bytes memory) {
        return abi.encodeWithSignature(
            "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)",
            SIGNED_TO, uint256(0), signedData(), SIGNED_OPERATION, SIGNED_SAFE_TX_GAS,
            uint256(0), uint256(0), address(0), address(0), SIGNATURES
        );
    }

    function sweepCalldata() internal pure returns (bytes memory) {
        return abi.encodeWithSignature("sweepETH(address)", SWEEP_TO);
    }

    /// The spec the row names. Its hash is read from the file at run time.
    string internal constant SPEC_PATH = "exhibits/bybit-2025-02/spec/safe-v1.1.1.json";

    /// Labels in place of tool code hashes, as in Room 1: the spec was read by a
    /// person and the verdict is the finding written in the room.
    bytes32 internal constant SPEC_TOOL = keccak256("museum/bybit-2025-02: spec read by a person");
    bytes32 internal constant VERDICT_TOOL = keccak256("museum/bybit-2025-02: verdict written by a person");
    bytes32 internal constant SPEC_ERRORS = keccak256("");

    /// Room 1's genesis funds the protocol with 2,000; this row takes 40 of it.
    uint256 internal constant BOUNTY = 40 ether;

    function resultRoot(bytes32 specHash) internal pure returns (bytes32) {
        return keccak256(abi.encode("PASS", WALLET_CODEHASH, specHash));
    }

    function declared() internal pure returns (bytes32[] memory tools) {
        tools = new bytes32[](1);
        tools[0] = VERDICT_TOOL;
    }

    /// Called as the cell's admin, after Room1.stand.
    function registerTools(AuditCell cell) internal {
        cell.registerTool(SPEC_TOOL, true);
        cell.registerTool(VERDICT_TOOL, false);
    }

    /// File the row. Called as `protocol`. A bare hash: the cell is asked about
    /// code, not about a place.
    function file(AuditCell cell, CellToken token, bytes32 specHash) internal returns (uint256 id) {
        token.approve(address(cell), BOUNTY);
        id = cell.submitArtifactAudit(
            WALLET_CODEHASH, address(0), specHash, SPEC_TOOL, SPEC_ERRORS, BOUNTY, declared(), 0, 0
        );
    }
}
