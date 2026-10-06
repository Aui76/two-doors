// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

interface IVaultRead {
    function getPoolTokens(bytes32 poolId)
        external
        view
        returns (address[] memory tokens, uint256[] memory balances, uint256 lastChangeBlock);
}

/// The chain's own drain, run on the room's fork.
///
/// The replay beside this file (replay/Replay.t.sol) is a port. It deploys
/// DeFiHackLabs' rebuilt attack contract and calls it, so the swap path is theirs.
/// This file runs the attacker's own transaction. vm.transact fetches it from
/// the node by its hash and executes that record on the fork: the calldata, the
/// sender and the nonce are the chain's, and nothing here is rebuilt.
///
/// It also checks one row of VERIFIED.md. A read at block 23,717,397 is the end
/// of that block, and the drain is transaction 1 of 214 in it. Transaction 2,
/// from another sender, swaps in pool A. So pool A after the drain alone is not
/// pool A at the end of the block, and the second test measures the difference
/// instead of taking it from a receipt.
contract BalancerTransactTest is Test {
    /// The last block before the drain. Fork.t.sol proves the fork stands here.
    uint256 internal constant FORK_BLOCK = 23_717_396;

    IVaultRead internal constant VAULT = IVaultRead(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    /// The first drain transaction: block 23,717,397, index 1, a contract creation.
    bytes32 internal constant TX_DRAIN = 0x6ed07db1a9fe5c0794d44cd36081d6a6df103fab868cdd75d581e3bd23bc9742;

    /// The transaction behind it in the same block, index 2. It is not part of the
    /// drain: a different sender, one Swap at the Vault, in pool A. It is here only
    /// because the end-of-block read includes it.
    bytes32 internal constant TX_NEXT = 0x4b6b5fb9aa779c7662793a2613dca48f6e4afd15037b1acf2be4355cb032ed63;

    /// The contract the drain transaction creates. Empty at the fork block.
    address internal constant DRAINER = 0x54B53503c0e2173Df29f8da735fBd45Ee8aBa30d;

    bytes32 internal constant POOL_A_ID = 0xdacf5fa19b1f720111609043ac67a9818262850c000000000000000000000635;
    address internal constant POOL_A = 0xDACf5Fa19b1f720111609043ac67A9818262850c;
    bytes32 internal constant POOL_B_ID = 0x93d199263632a4ef4bb438f1feb99e57b4b5f0bd0000000000000000000005c2;
    address internal constant POOL_B = 0x93d199263632a4EF4Bb438F1feB99e57b4b5f0BD;

    /// A pool's two paired assets at the Vault, the pool's own BPT skipped.
    struct Pair {
        address token0;
        uint256 balance0;
        address token1;
        uint256 balance1;
    }

    /// The rule set mainnet ran at block 23,717,397, set by hand because the harness
    /// does not pick it. Measured on 2026-10-01 with forge 1.7.1: without the line
    /// in setUp, and with it set to "shanghai", the transaction behind the drain ends
    /// its first call `NotActivated`, vm.transact returns without a word, and pool A
    /// does not move. With "cancun", "prague" or "osaka" it runs and the second test
    /// passes. The drain itself runs under all four.
    string internal constant CHAIN_RULES = "prague";

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        vm.setEvmVersion(CHAIN_RULES);
        emit log_named_string("museum: rule set these transactions run under", vm.getEvmVersion());
    }

    function _read(bytes32 id, address pool) internal view returns (Pair memory p) {
        (address[] memory tokens, uint256[] memory balances,) = VAULT.getPoolTokens(id);
        bool first = true;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == pool) continue; // skip the pool's own BPT
            if (first) {
                (p.token0, p.balance0) = (tokens[i], balances[i]);
                first = false;
            } else {
                (p.token1, p.balance1) = (tokens[i], balances[i]);
            }
        }
    }

    /// Same labels as the port's museum lines, so the two runs read side by side.
    /// The scale is each token's own, read on the fork, not a number typed here:
    /// a printer that always passes 18 is a scale the token was not asked for.
    function _print(string memory when, string memory name, Pair memory p) internal {
        emit log_named_decimal_uint(
            string.concat("museum: ", when, " pool ", name, " ", vm.toString(p.token0)),
            p.balance0,
            IERC20(p.token0).decimals()
        );
        emit log_named_decimal_uint(
            string.concat("museum: ", when, " pool ", name, " ", vm.toString(p.token1)),
            p.balance1,
            IERC20(p.token1).decimals()
        );
    }

    function _printBoth(string memory when) internal {
        _print(when, "A osETH/wETH", _read(POOL_A_ID, POOL_A));
        _print(when, "B wstETH/WETH", _read(POOL_B_ID, POOL_B));
    }

    function _same(Pair memory x, Pair memory y) internal pure returns (bool) {
        return x.token0 == y.token0 && x.token1 == y.token1 && x.balance0 == y.balance0 && x.balance1 == y.balance1;
    }

    /// The attacker's transaction runs on the fork and both pools fall.
    function test_theChainsOwnDrainRunsOnTheFork() public {
        emit log_named_uint("museum: fork block", block.number);
        assertEq(DRAINER.code.length, 0, "the drainer already has code at the fork block");
        Pair memory aBefore = _read(POOL_A_ID, POOL_A);
        Pair memory bBefore = _read(POOL_B_ID, POOL_B);
        _printBoth("before");

        vm.transact(TX_DRAIN);

        emit log_named_uint("museum: drainer code bytes after the chain's own transaction", DRAINER.code.length);
        assertGt(DRAINER.code.length, 0, "the transaction did not create the drainer");
        _printBoth("after");

        Pair memory aAfter = _read(POOL_A_ID, POOL_A);
        Pair memory bAfter = _read(POOL_B_ID, POOL_B);
        // Each paired asset is left with less than a tenth of what the fork block held.
        assertLt(aAfter.balance0 * 10, aBefore.balance0, "pool A, first asset, did not fall");
        assertLt(aAfter.balance1 * 10, aBefore.balance1, "pool A, second asset, did not fall");
        assertLt(bAfter.balance0 * 10, bBefore.balance0, "pool B, first asset, did not fall");
        assertLt(bAfter.balance1 * 10, bBefore.balance1, "pool B, second asset, did not fall");
    }

    /// The end of block 23,717,397 is the drain and one more swap in pool A.
    ///
    /// Pool B after the drain alone is already pool B at the end of the block, to
    /// the wei. Pool A is not, and running the next transaction closes the gap, to
    /// the wei. So the "23,717,397" row of a balance table is "after the first
    /// transaction" for pool B only.
    function test_theEndOfTheBlockIsTheDrainAndOneMoreSwapInPoolA() public {
        vm.transact(TX_DRAIN);
        Pair memory aDrain = _read(POOL_A_ID, POOL_A);
        Pair memory bDrain = _read(POOL_B_ID, POOL_B);

        vm.transact(TX_NEXT);
        Pair memory aNext = _read(POOL_A_ID, POOL_A);
        Pair memory bNext = _read(POOL_B_ID, POOL_B);

        // A second fork, at the end of the drain's block, read as the chain left it.
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK + 1);
        emit log_named_uint("museum: end-of-block fork", block.number);
        Pair memory aEnd = _read(POOL_A_ID, POOL_A);
        Pair memory bEnd = _read(POOL_B_ID, POOL_B);

        _print("after the drain alone,", "A osETH/wETH", aDrain);
        _print("after the drain and the next transaction,", "A osETH/wETH", aNext);
        _print("end of block 23,717,397,", "A osETH/wETH", aEnd);
        _print("after the drain alone,", "B wstETH/WETH", bDrain);
        _print("end of block 23,717,397,", "B wstETH/WETH", bEnd);

        assertTrue(_same(bDrain, bEnd), "pool B after the drain alone is not pool B at the end of the block");
        assertTrue(_same(bNext, bEnd), "the next transaction moved pool B");
        assertFalse(_same(aDrain, aEnd), "pool A after the drain alone already equals the end of the block");
        assertTrue(_same(aNext, aEnd), "the drain and the next transaction do not add up to the end of the block");

        // What the next transaction did to pool A, measured as a difference: it took
        // the first asset out and put the second in.
        emit log_named_address("museum: pool A asset the next transaction took out", aDrain.token0);
        emit log_named_decimal_uint(
            "museum: amount out", aDrain.balance0 - aEnd.balance0, IERC20(aDrain.token0).decimals()
        );
        emit log_named_address("museum: pool A asset the next transaction put in", aDrain.token1);
        emit log_named_decimal_uint(
            "museum: amount in", aEnd.balance1 - aDrain.balance1, IERC20(aDrain.token1).decimals()
        );
    }
}
