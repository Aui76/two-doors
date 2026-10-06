// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Room3} from "./review/Room3.sol";

/// Room 3's spec is only honest if the words under it are the source deployed in the pool
/// before it was drained. `spec/SOURCES.md` says which bytes those were and where they came
/// from twice over. This test re-hashes them and fails if a single one has moved.
///
/// It runs offline, like Room 1's. A reader with the repository and nothing else can still
/// check that the vendored sources are the ones the provenance claims.
contract BalancerProvenanceTest is Test {
    string internal constant DIR = "specimens/balancer-2025-11/";

    function _sha256Of(string memory name) internal view returns (bytes32) {
        return sha256(bytes(vm.readFile(string.concat(DIR, name))));
    }

    /// Every hash below is copied from spec/SOURCES.md, which records what arrived from
    /// Sourcify's exact match for 0xDACf5Fa19b1f720111609043ac67A9818262850c and, the same
    /// bytes, from balancer-v2-monorepo at 6198fd7 on 3 October 2026.
    function test_vendoredSourcesAreUnmodified() public view {
        assertEq(
            _sha256Of("BaseGeneralPool.sol"),
            0xa48d3fe6126e1a49b160d389f27268c848b57127bee13ccf49c9245cb823c5b0,
            "BaseGeneralPool.sol has changed"
        );
        assertEq(
            _sha256Of("BasePool.sol"),
            0x9fec78a410cccd9248ff96a075a8766af2d607ae4d08e5b5708cd30b99f01972,
            "BasePool.sol has changed"
        );
        assertEq(
            _sha256Of("ComposableStablePool.sol"),
            0x49222c43627d097b9d51efb1b6a32ca6dbc1e6706fe32d33caef25014c16612f,
            "ComposableStablePool.sol has changed"
        );
        assertEq(
            _sha256Of("ComposableStablePoolRates.sol"),
            0xb361d8ff591fcdf6d811c68f1f602db59e0bd26ecb81b6e184a3ce2522e33e61,
            "ComposableStablePoolRates.sol has changed"
        );
        assertEq(
            _sha256Of("ComposableStablePoolStorage.sol"),
            0xd4b218e01bf10f49606bd00e741f5a8b9d6e7d96e8a726c766db343b68dc409f,
            "ComposableStablePoolStorage.sol has changed"
        );
        assertEq(
            _sha256Of("FixedPoint.sol"),
            0x9f40aa0869e0e725e44d4d95bfebc66b72042b6a3ef6b687f6f300a4dd9248aa,
            "FixedPoint.sol has changed"
        );
        assertEq(
            _sha256Of("StableMath.sol"),
            0x25154c99a13173016d22bf8efbf0a5aeb55cef3cfd96f043489c7f573034bdf8,
            "StableMath.sol has changed"
        );
    }

    /// The spec's rounding invariants are Balancer's own comments. Reading them out of the
    /// vendored files rather than restating them keeps one copy of each fact, and if a line
    /// moves, this fails rather than the spec drifting quietly away from it.
    function test_roundingWordsAreTheOnesTheSpecCites() public view {
        string memory general = vm.readFile(string.concat(DIR, "BaseGeneralPool.sol"));
        assertTrue(vm.contains(general, "amountOut tokens are exiting the Pool, so we round down."), "exact-in direction moved");
        assertTrue(vm.contains(general, "amountIn tokens are entering the Pool, so we round up."), "exact-out direction moved");

        string memory base = vm.readFile(string.concat(DIR, "BasePool.sol"));
        assertTrue(vm.contains(base, "_MIN_TOKENS = 2;"), "minimum token count is not 2");
        assertTrue(vm.contains(base, "_MIN_SWAP_FEE_PERCENTAGE = 1e12;"), "minimum swap fee is not 0.0001%");
        assertTrue(vm.contains(base, "_MAX_SWAP_FEE_PERCENTAGE = 1e17;"), "maximum swap fee is not 10%");
        assertTrue(vm.contains(base, "amountsIn are amounts entering the Pool, so we round up."), "join direction moved");
        assertTrue(vm.contains(base, "amountsOut are amounts exiting the Pool, so we round down."), "exit direction moved");
        assertTrue(vm.contains(base, "rounding error unless `_scalingFactor()` is overriden)."), "the upscale comment moved");
        assertTrue(vm.contains(base, "return FixedPoint.mulDown(amount, scalingFactor);"), "upscale no longer rounds down");

        string memory rates = vm.readFile(string.concat(DIR, "ComposableStablePoolRates.sol"));
        assertTrue(
            vm.contains(rates, "scalingFactors[i] = _getScalingFactor(i).mulDown(_getTokenRate(i));"),
            "the scaling factor is no longer decimals times rate"
        );

        // Where the decimals factor on that line comes from: stored once at construction, read
        // back by index, computed from the token's own decimals(), which EIP-20 makes optional.
        string memory store = vm.readFile(string.concat(DIR, "ComposableStablePoolStorage.sol"));
        assertTrue(
            vm.contains(store, "_scalingFactor0 = _computeScalingFactor(params.registeredTokens[0]);"),
            "the decimals factor is no longer fixed at construction"
        );
        assertTrue(vm.contains(store, "if (index == 0) return _scalingFactor0;"), "the getter no longer reads the stored factor");
        assertTrue(
            vm.contains(base, "uint256 tokenDecimals = ERC20(address(token)).decimals();"),
            "the decimals factor no longer comes from the token"
        );
        assertTrue(
            vm.contains(base, "Tokens that don't implement the `decimals` method are not supported."),
            "the decimals comment moved"
        );

        string memory math = vm.readFile(string.concat(DIR, "StableMath.sol"));
        assertTrue(vm.contains(math, "Always round down, to match Vyper's arithmetic"), "invariant direction moved");
        assertTrue(vm.contains(math, "Amount out, so we round down overall."), "amount out direction moved");
        assertTrue(vm.contains(math, "Amount in, so we round up overall."), "amount in direction moved");
    }

    /// Every invariant in the spec has to name where it came from.
    function test_everyInvariantNamesItsSource() public view {
        string memory spec = vm.readFile("exhibits/balancer-2025-11/spec/swap-rounding-v0.json");
        string[13] memory ids = [
            "swaps-come-only-from-the-vault",
            "swap-fee-is-bounded",
            "pool-holds-two-tokens-or-more",
            "exact-in-fee-comes-off-before-scaling",
            "exact-in-amount-out-rounds-down",
            "exact-out-amount-in-rounds-up",
            "exact-out-fee-is-added-after-scaling",
            "upscaling-rounds-down-for-every-amount",
            "scaling-factor-is-decimals-times-rate",
            "invariant-rounds-down",
            "join-amounts-in-round-up",
            "exit-amounts-out-round-down",
            "bpt-swaps-are-joins-and-exits"
        ];
        for (uint256 i = 0; i < ids.length; i++) {
            assertTrue(vm.contains(spec, ids[i]), string.concat("spec is missing invariant ", ids[i]));
        }
        // 13 invariants, 13 _source lines. Counted rather than assumed.
        assertEq(_countOf(spec, "\"_source\""), 13, "an invariant has no _source");
    }

    /// The pool the spec names is the pool the fork reads. The address and code hash are
    /// written once in the spec; this ties them to the room's constants so the two cannot part.
    function test_specNamesThePoolTheRoomForks() public view {
        string memory spec = vm.readFile(Room3.SPEC_PATH);
        assertEq(vm.parseJsonAddress(spec, ".target.address"), Room3.POOL_A, "spec names another pool");
        assertEq(vm.parseJsonBytes32(spec, ".target.codehash"), Room3.POOL_A_CODEHASH, "spec names another code hash");
        assertEq(vm.parseJsonUint(spec, ".target.block"), Room3.FORK_BLOCK, "spec names another block");
        assertTrue(
            vm.contains(vm.readFile("exhibits/balancer-2025-11/Fork.t.sol"), "FORK_BLOCK = 23_717_396"),
            "Fork.t.sol forks another block"
        );
    }

    function _countOf(string memory haystack, string memory needle) internal pure returns (uint256 n) {
        bytes memory h = bytes(haystack);
        bytes memory k = bytes(needle);
        if (k.length == 0 || h.length < k.length) return 0;
        for (uint256 i = 0; i + k.length <= h.length; i++) {
            bool hit = true;
            for (uint256 j = 0; j < k.length; j++) {
                if (h[i + j] != k[j]) {
                    hit = false;
                    break;
                }
            }
            if (hit) n++;
        }
    }
}
