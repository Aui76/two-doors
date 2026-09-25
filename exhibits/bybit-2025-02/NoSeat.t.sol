// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Room1} from "../beanstalk-2022-04/verdict/Room1.sol";
import {Room3} from "./Room3.sol";
import {AuditCell} from "dan/AuditCell.sol";
import {CellTypeDefs} from "dan/CellStorage.sol";
import {CellToken} from "dan/CellToken.sol";

interface ISafe111Hash {
    function getThreshold() external view returns (uint256);
    function isOwner(address owner) external view returns (bool);
    function nonce() external view returns (uint256);
    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        uint8 operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes32);
}

/// Room 3: the room with no seat.
///
/// The hull stands beside the Bybit cold wallet one block before the signed
/// transaction. A row is filed against the wallet's code, the auditor's PASS
/// against the spec from Safe's own 2019 words is proven, the window closes,
/// and the row is where the door finds it. Then the two real transactions run,
/// fetched from the node by hash (vm.transact), and the row is asked again.
///
/// Nothing is asserted about what the signers were shown. That is not on the
/// chain, and the check does not read it.
contract BybitNoSeatTest is Test {
    address internal constant PROTOCOL = address(0xA11CE);
    address internal constant AUDITOR = address(0xB0B);

    AuditCell internal cell;
    CellToken internal token;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), Room3.FORK_BLOCK);
    }

    /// True when `needle` appears byte for byte inside `hay`.
    function _contains(bytes memory hay, bytes memory needle) internal pure returns (bool) {
        if (needle.length > hay.length) return false;
        bytes32 want = keccak256(needle);
        uint256 n = needle.length;
        for (uint256 i = 0; i + n <= hay.length; i++) {
            bytes32 got;
            assembly {
                got := keccak256(add(add(hay, 0x20), i), n)
            }
            if (got == want) return true;
        }
        return false;
    }

    /// The node's own record of a transaction, as returned for its hash.
    function _record(bytes32 txHash) internal returns (bytes memory r) {
        r = vm.rpc("eth_getTransactionByHash", string.concat('["', vm.toString(txHash), '"]'));
        assertTrue(_contains(r, abi.encodePacked(txHash)), "the node returned a record for another hash");
    }

    function _recover(bytes32 h, bytes memory sigs, uint256 i) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly {
            let p := add(add(sigs, 0x20), mul(i, 65))
            r := mload(p)
            s := mload(add(p, 0x20))
            v := byte(0, mload(add(p, 0x40)))
        }
        // v above 30 is an eth_sign signature, recovered over the prefixed hash
        // (GnosisSafe.sol:244-248). Otherwise plain ecrecover (:249-251).
        if (v > 30) {
            return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", h)), v - 4, r, s);
        }
        return ecrecover(h, v, r, s);
    }

    function _specHash() internal view returns (bytes32) {
        return keccak256(bytes(vm.readFile(Room3.SPEC_PATH)));
    }

    /// The row, filed, proven and settled. The same lifecycle as Room 1.
    function _settledRow() internal returns (uint256 id) {
        Room1.Hull memory d = Room1.stand(address(this), PROTOCOL);
        cell = d.cell;
        token = d.token;
        Room3.registerTools(cell);
        // vm.transact rolls the fork to each transaction's own block, and a roll
        // drops every account the fork did not bring. The hull is local, so it is
        // carried across the rolls; the wallet's state comes from the chain.
        address[] memory hull = new address[](11);
        (hull[0], hull[1], hull[2], hull[3]) = (address(d.token), address(d.escrow), address(d.cell), address(d.issuance));
        (hull[4], hull[5], hull[6]) = (address(d.claimModule), address(d.specGapModule), address(d.specArbiterModule));
        (hull[7], hull[8]) = (address(d.integrityReviewModule), address(d.structuralUpgradeModule));
        (hull[9], hull[10]) = (address(d.fmeaRegistry), address(d.assignmentModule));
        vm.makePersistent(hull);

        bytes32 specHash = _specHash();
        vm.prank(AUDITOR);
        cell.register();
        vm.startPrank(PROTOCOL);
        id = Room3.file(cell, token, specHash);
        vm.stopPrank();
        assertEq(cell.auditAuditorOf(id), AUDITOR, "assigned to someone else");
        vm.prank(PROTOCOL);
        cell.protocolAcceptAuditor(id);
        vm.prank(AUDITOR);
        cell.acceptAudit(id, Room3.SPEC_ERRORS);
        vm.prank(AUDITOR);
        cell.provePass(id, Room3.VERDICT_TOOL, Room3.resultRoot(specHash));
        vm.warp(block.timestamp + cell.minAuditWindow() + 1);
        cell.confirmAudit(id);
    }

    /// What the door reads: the bytes at the address, hashed, and whether that
    /// hash has a settled row. The same two reads dan-check makes.
    function _theDoorSaysClean(uint256 id) internal view returns (bool) {
        bytes32 h = keccak256(Room3.WALLET.code);
        return cell.artifactRegistered(h) && cell.artifactToAuditId(h) == id
            && cell.auditStateOf(id) == CellTypeDefs.AuditState.InBlock;
    }

    /// Three of the wallet's owners signed this exact transaction, and it is a
    /// delegatecall. The multisig was told, correctly, by the required number.
    function test_threeOwnersSignedThisTransaction() public {
        assertTrue(_contains(_record(Room3.TX_SIGNED), Room3.signedCalldata()), "the rebuilt calldata is not the chain's");

        ISafe111Hash safe = ISafe111Hash(Room3.WALLET);
        assertEq(safe.nonce(), Room3.SIGNED_NONCE, "not the nonce the signers signed");
        bytes32 safeTxHash = safe.getTransactionHash(
            Room3.SIGNED_TO, 0, Room3.signedData(), Room3.SIGNED_OPERATION, Room3.SIGNED_SAFE_TX_GAS,
            0, 0, address(0), address(0), Room3.SIGNED_NONCE
        );

        uint256 threshold = safe.getThreshold();
        assertEq(Room3.SIGNATURES.length, threshold * 65, "not one signature per required owner");
        address last;
        emit log_named_bytes32("Safe transaction hash (nonce 71)", safeTxHash);
        emit log_named_uint("operation (1 = delegatecall)", Room3.SIGNED_OPERATION);
        emit log_named_address("destination", Room3.SIGNED_TO);
        for (uint256 i = 0; i < threshold; i++) {
            address signer = _recover(safeTxHash, Room3.SIGNATURES, i);
            assertTrue(safe.isOwner(signer), "a signature does not recover to an owner");
            assertGt(uint160(signer), uint160(last), "owners not strictly ascending");
            last = signer;
            emit log_named_address("signed by owner", signer);
        }
        emit log_named_uint("signatures required (threshold)", threshold);
    }

    /// The room. The check passes before, the money leaves, and the check
    /// passes after, because the bytes it reads are the same bytes.
    function test_theCheckPassesAndTheMoneyLeaves() public {
        assertTrue(_contains(_record(Room3.TX_SWEEP), Room3.sweepCalldata()), "the sweep is not the chain's");

        uint256 id = _settledRow();
        assertTrue(_theDoorSaysClean(id), "the row did not settle");

        uint256 held = Room3.WALLET.balance;
        uint256 destBefore = Room3.SWEEP_TO.balance;
        bytes32 codeBefore = keccak256(Room3.WALLET.code);

        emit log_named_uint("fork block", Room3.FORK_BLOCK);
        emit log_named_address("cell", address(cell));
        emit log_named_uint("audit id", id);
        emit log_named_bytes32("artifact hash (wallet code)", codeBefore);
        emit log_named_bytes32("spec hash (safe-v1.1.1.json)", _specHash());
        emit log_named_uint("state (6 = InBlock)", uint256(cell.auditStateOf(id)));
        emit log_named_decimal_uint("wallet holds (ETH)", held, 18);

        vm.transact(Room3.TX_SIGNED);
        address slot0 = address(uint160(uint256(vm.load(Room3.WALLET, bytes32(0)))));
        assertEq(slot0, Room3.BACKDOOR, "slot 0 did not move");
        emit log_named_address("slot 0 after the signed transaction", slot0);

        vm.transact(Room3.TX_SWEEP);
        assertEq(Room3.WALLET.balance, 0, "the wallet was not emptied");
        assertEq(Room3.SWEEP_TO.balance - destBefore, held, "the ETH did not all go to one place");
        emit log_named_decimal_uint("wallet holds after the sweep (ETH)", Room3.WALLET.balance, 18);
        emit log_named_decimal_uint("moved to the sweep's destination (ETH)", Room3.SWEEP_TO.balance - destBefore, 18);

        bytes32 codeAfter = keccak256(Room3.WALLET.code);
        assertEq(codeAfter, codeBefore, "the wallet's bytes changed");
        assertTrue(_theDoorSaysClean(id), "the door no longer says CLEAN");
        emit log_named_bytes32("artifact hash after (wallet code)", codeAfter);
        emit log_named_uint("state after (6 = InBlock)", uint256(cell.auditStateOf(id)));
    }
}
