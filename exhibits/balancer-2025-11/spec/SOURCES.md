<!-- SPDX-License-Identifier: MIT -->
# Where every word in the spec came from

Same rule as Room 1: the spec is written from what Balancer published about this pool *before* it was
drained, and from nothing else. Here what Balancer published is the source itself. Seven of the files
that compile to the pool carry their own rounding rules in their comments, line by line, and those
comments are the words I used. This file names the line behind each invariant, the commands that fetched the
files and the hash each one had when it arrived.

Pulled 3 October 2026.

## The cut-off

Block 23,717,396 was mined at 1762155995, which is 3 November 2025 at 07:46:35 UTC. The room forks at
that block. Anything published after it is out of bounds, and that includes Balancer's post-mortem: no
line of the spec comes from it.

## The pool

The drain touched more than one pool. The room is built on the first, the osETH/wETH composable stable
pool, read at the cut-off block:

| what | value |
|---|---|
| address | `0xDACf5Fa19b1f720111609043ac67A9818262850c` |
| name | Balancer osETH/wETH StablePool |
| version() | `{"name":"ComposableStablePool","version":5,"deployment":"20230711-composable-stable-pool-v5"}` |
| pool id | `0xdacf5fa19b1f720111609043ac67a9818262850c000000000000000000000635` |
| vault | `0xBA12222222228d8Ba445958a75a0704d566BF2C8` |
| runtime | 24,280 bytes, codehash `0x72b6e1b187e715820b74d4243533145e6d2d0e168101fd8b27be6f5be80ca441` |
| scaling factors | `[1e18, 1e18, 1058109553424427048]` |

```
cast codehash 0xDACf5Fa19b1f720111609043ac67A9818262850c --block 23717396 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast call 0xDACf5Fa19b1f720111609043ac67A9818262850c 'getScalingFactors()(uint256[])' --block 23717396 --rpc-url $MAINNET_ARCHIVE_RPC_URL
```

The third scaling factor is not a power of ten. It is the token's decimals factor times the rate its
rate provider `0x8023518b2192FB5384DAdc596765B3dD1cdFe471` reported at that block. Keep that number in
mind for the sentence below.

## The seven files, from two places

Vendored under `specimens/balancer-2025-11/`, so you can hash them without a network.

**From the chain's side.** Sourcify holds the pool as an exact match, creation and runtime, solc 0.7.1.
That answer means these sources compile to the bytes at the address.

```
curl -s 'https://sourcify.dev/server/v2/contract/1/0xDACf5Fa19b1f720111609043ac67A9818262850c?fields=sources,creationMatch,runtimeMatch'
```

**From Balancer's side.** The same seven files at `balancer/balancer-v2-monorepo` commit
`6198fd700204ed143a33b06539954d218845b3dc`, 11 July 2023, "Patch (single flag version): Composable stable
pool v5". Every file hashes the same as Sourcify's copy.

```
curl -sL https://raw.githubusercontent.com/balancer/balancer-v2-monorepo/6198fd700204ed143a33b06539954d218845b3dc/PATH
```

| file | monorepo path | bytes | sha256 |
|---|---|---|---|
| `BaseGeneralPool.sol` | `pkg/pool-utils/contracts/BaseGeneralPool.sol` | 4997 | `a48d3fe6126e1a49b160d389f27268c848b57127bee13ccf49c9245cb823c5b0` |
| `BasePool.sol` | `pkg/pool-utils/contracts/BasePool.sol` | 39880 | `9fec78a410cccd9248ff96a075a8766af2d607ae4d08e5b5708cd30b99f01972` |
| `ComposableStablePool.sol` | `pkg/pool-stable/contracts/ComposableStablePool.sol` | 53185 | `49222c43627d097b9d51efb1b6a32ca6dbc1e6706fe32d33caef25014c16612f` |
| `ComposableStablePoolRates.sol` | `pkg/pool-stable/contracts/ComposableStablePoolRates.sol` | 13758 | `b361d8ff591fcdf6d811c68f1f602db59e0bd26ecb81b6e184a3ce2522e33e61` |
| `ComposableStablePoolStorage.sol` | `pkg/pool-stable/contracts/ComposableStablePoolStorage.sol` | 16788 | `d4b218e01bf10f49606bd00e741f5a8b9d6e7d96e8a726c766db343b68dc409f` |
| `FixedPoint.sol` | `pkg/solidity-utils/contracts/math/FixedPoint.sol` | 5928 | `9f40aa0869e0e725e44d4d95bfebc66b72042b6a3ef6b687f6f300a4dd9248aa` |
| `StableMath.sol` | `pkg/pool-stable/contracts/StableMath.sol` | 23487 | `25154c99a13173016d22bf8efbf0a5aeb55cef3cfd96f043489c7f573034bdf8` |

All seven carry `SPDX-License-Identifier: GPL-3.0-or-later` in their own headers. See
`specimens/balancer-2025-11/NOTICE.md`.

`ComposableStablePoolStorage.sol` came in on 3 October 2026, after the other six, and from the same two
places, Sourcify's `contracts/ComposableStablePoolStorage.sol` and the monorepo path above. Both copies
hash `d4b218e0…409f`. It is here for one invariant. Line 302 of the rates file multiplies a rate by
`_getScalingFactor(i)`, and that getter lives in this file.

## The sentence the room is built on

`BasePool.sol:680-686`, the comment over `_upscale`, quoted once in full:

> "Upscale rounding wouldn't necessarily always go in the same direction: in a swap for example the
> balance of token in should be rounded up, and that of token out rounded down. This is the only place
> where we round in the same direction for all amounts, as the impact of this rounding is expected to be
> minimal (and there's no rounding error unless `_scalingFactor()` is overriden)."
>
> Balancer, `pkg/pool-utils/contracts/BasePool.sol`, deployed in this pool

This pool overrides it. `ComposableStablePoolRates.sol:302` multiplies each decimals factor by a token
rate, which is where the 1058109553424427048 above comes from.

## What backs each invariant

The spec carries a `_source` on every invariant. Open `swap-rounding-v0.json`, take one, open the line
it names, and check that the invariant says what the line says and no more. Most of them are Balancer's
own comments almost word for word: "amountOut tokens are exiting the Pool, so we round down",
"amountIn tokens are entering the Pool, so we round up", "Fees are subtracted before scaling".

One invariant runs through three files. `scaling-factor-is-decimals-times-rate` starts at line 302 of
the rates file. The decimals factor it multiplies is stored once, in the constructor, at
`ComposableStablePoolStorage.sol:108-113`, and read back by the getter at `:274-280`. The value is
computed at `BasePool.sol:638-649`, which asks each token for its `decimals()`. EIP-20 makes that
method optional. The pool's own comment at line 643 says a token without it is not supported, and the
storage comment at lines 54-56 assumes the answer never changes. The pool asked each token for its
scale once, when it was built, and that answer still sets every swap's scaling factor at the cut-off. That makes it a fact about the pool. It
is not part of the drain, and the finding does not use it.

## Two things I did not do, and why

**I did not write an invariant for the amplification bounds.** `StableMath.sol:28-29` declares a
minimum of 1 and a maximum of 5000, but those constants are enforced in `StablePoolAmplification.sol`,
which is not among the seven files. An invariant whose enforcing line is not in the room is one you would
have to take on trust, so it is left out.

**I did not read anything published after the drain.** Not the post-mortem, not the write-ups, not the
patched code. Every invariant points at a line in a file that was on chain from 2023 to the cut-off.

## The scope manifest

The scope tags were run through the network's own deriver, the same one that gave Room 1's root.

```
node cell/indexer/deriveScope.mjs   # via deriveScopeFromSpec(spec.invariants)
```

13 invariants, 8 categories, no warnings, no unknown symbols.

```
scopeRoot 0x2cf090b8817c244e7541de7ddb05866aecb370ef02a09a7a5d16eec5ebb0509e
```

ACCESS-CONTROL, ARITHMETIC-SAFETY, BALANCE-ACCOUNTING, INPUT-VALIDATION, ORACLE-DEPENDENCE,
PRIVILEGED-PARAMETER, SUPPLY-CONSERVATION, SWAP-RATE.
