// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Room3} from "./Room3.sol";

interface ISafe111 {
    function getThreshold() external view returns (uint256);
    function getOwners() external view returns (address[] memory);
    function nonce() external view returns (uint256);
}

/// Room 3's footing: the wallet as it stood one block before the signed
/// transaction. Every constant in Room3.sol that names state is checked here
/// against the fork; nothing below is taken from a write-up.
contract BybitForkTest is Test {
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), Room3.FORK_BLOCK);
    }

    function test_theForkIsTheBlockBefore() public view {
        assertEq(block.number, Room3.FORK_BLOCK, "wrong block");
        assertEq(block.timestamp, 1_740_147_203, "wrong time: 21 February 2025, 14:13:23 UTC");
    }

    function test_theWalletAsItStood() public {
        bytes memory code = Room3.WALLET.code;
        assertEq(code.length, Room3.WALLET_CODE_LENGTH, "the wallet's code is a different length here");
        assertEq(keccak256(code), Room3.WALLET_CODEHASH, "the wallet's code hash does not match");

        address slot0 = address(uint160(uint256(vm.load(Room3.WALLET, bytes32(0)))));
        assertEq(slot0, Room3.SINGLETON, "slot 0 did not hold the v1.1.1 singleton");
        assertEq(keccak256(Room3.SINGLETON.code), Room3.SINGLETON_CODEHASH, "the singleton's code hash does not match");

        ISafe111 safe = ISafe111(Room3.WALLET);
        address[] memory owners = safe.getOwners();
        assertEq(safe.nonce(), Room3.SIGNED_NONCE, "the next Safe transaction is not nonce 71");

        emit log_named_uint("fork block", block.number);
        emit log_named_uint("fork timestamp", block.timestamp);
        emit log_named_address("wallet", Room3.WALLET);
        emit log_named_bytes32("wallet code hash", keccak256(code));
        emit log_named_uint("wallet code length (bytes)", code.length);
        emit log_named_address("slot 0 (master copy)", slot0);
        emit log_named_bytes32("master copy code hash", keccak256(slot0.code));
        emit log_named_uint("threshold", safe.getThreshold());
        emit log_named_uint("owners", owners.length);
        emit log_named_uint("nonce", safe.nonce());
        emit log_named_decimal_uint("balance (ETH)", Room3.WALLET.balance, 18);
    }
}
