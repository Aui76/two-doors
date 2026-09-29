# The replay — the Balancer room, the attacker's door

This directory holds the exploit replay: the real 3-November-2025 Balancer V2
drain, run against the fork at block 23,717,396, the two Composable Stable Pools
falling, with the command that reproduces it. It is the attacker's door, and it
stands beside the discoverer's door (the Trail of Bits look at the carrying half,
on the wall under VD-314).

## Footing

- Archive RPC serves block 23,717,396 live: `../Fork.t.sol` builds the fork and
  passes (`test_forkStandsAtTheNamedBlock`, the 24,512 Vault bytes and their hash,
  and the drainer `0x54B5…30d` empty at the fork block — the last safe moment,
  before the attack was written).
- `foundry.toml` maps `mainnet = "${MAINNET_ARCHIVE_RPC_URL}"`, so no port edit
  touches the RPC alias.
- **To confirm from the fetched file:** its constructor's `createSelectFork` block
  must be **23,717,396**. If it forks somewhere else, do not adjust the attack —
  surface the mismatch; that is the VD-307 reopen condition, not a port edit.

## The port itself

The replay is a **port with credit** of DeFiHackLabs'
`src/test/2025-11/BalancerV2_exp.sol` (Apache-2.0; see `NOTICE.md`). It is public,
on-chain-permanent history.

The attack body is brought into `Replay.t.sol` from the public source rather than
retyped, so the port is a faithful transcription and its provenance is a fetch,
not a paraphrase. The one command that populates the slot, run from the repo root:

```bash
cd C:\Users\cloni\Documents\Claude\museum-wip
curl.exe -sL https://raw.githubusercontent.com/SunWeb3Sec/DeFiHackLabs/main/src/test/2025-11/BalancerV2_exp.sol -o exhibits/balancer-2025-11/replay/BalancerV2_exp.orig.sol
Get-FileHash exhibits/balancer-2025-11/replay/BalancerV2_exp.orig.sol -Algorithm SHA256
```

Record the sha256 here and in `NOTICE.md` once it has run:

- Fetched: 2026-09-29 — **19,080 bytes**, sha256
  `9cf837fa17a20573fd6df4bdaa28b2e38c0e478e699bf0701efec8be5d8d17dc`.
- If the file has moved in the upstream repo, fetch it by that hash from the
  repository's history rather than trusting a moved path.

The `*.orig.sol` reference is a **transient**: it is gitignored and `foundry.toml`
skips `*.orig.sol` from compilation, so the fetch is safe to run from a green tree
and the raw copy is never committed. The **compiled** artifact is `Replay.t.sol`,
transcribed from the reference and living in this compiled directory.

Transcribing `Replay.t.sol` from the reference adapts imports — provide the
interface file the source expects — but **never a line of the attack**: the
byte-faithful copy is `BalancerV2_exp.orig.sol`, pinned by the sha256 above.

### The support files the imports need

The original imports four things: `forge-std/Test.sol` (mapped at config level),
`../interface.sol` (the shared ABI stub), `../StableMath.sol` (Balancer's own
StableMath, the carrying-half math), and — pulled in transitively by StableMath —
`@balancer-labs/v2-solidity-utils`. These are fetched public dependencies, not the
attack; they are committed so the room compiles.

- `interface.sol` and `StableMath.sol` are fetched from DeFiHackLabs' `src/test/`
  (see the curl step above) and sit beside `Replay.t.sol`, so the transcription
  imports them as `./interface.sol` and `./StableMath.sol`.
- `StableMath.sol` (pragma `^0.8.0`, GPL-3.0) imports Balancer's `FixedPoint.sol`
  and `Math.sol`. DeFiHackLabs never vendored that package — its `foundry.lock`
  pins only forge-std — and `StableMath.sol`'s own header says to install it and
  bump the pragma. So the museum vendors the minimal closure of four files
  (`math/FixedPoint.sol`, `math/Math.sol`, `math/LogExpMath.sol`,
  `helpers/BalancerErrors.sol`) from `@balancer-labs/v2-solidity-utils@2.0.0`
  (unpkg), under `balancer-v2-solidity-utils/` here, with each file's
  `pragma solidity ^0.7.0;` changed to `>=0.7.0 <0.9.0;` — the one documented edit,
  no line of the math touched. The remapping
  `@balancer-labs/v2-solidity-utils/=exhibits/balancer-2025-11/replay/balancer-v2-solidity-utils/`
  in `foundry.toml` resolves the import. The 2.0.0 layout is used on purpose:
  later versions split `BalancerErrors` into a separate package, which would drag a
  second tree in.
- These files carry their own SPDX headers (GPL-3.0 and MIT); the licence rule for
  going public is the publishing gate's, not this working tree's.

The museum adds a few of its own labelled lines at the top and bottom of the test,
each marked `museum:`, around the untouched attack: the fork block, and the two
drained pools' Vault balances before and after the run — pool A
`0xdacf…850c` (osETH/wETH) and pool B `0x93d1…f0bd` (wstETH/WETH) — so the fall is
printed by the run, not typed. **No dollar figure** (VD-307(2), VD-310(5)); the
labels print token balances only. Every number the room prints, the museum's lines
included, is produced by the run (VD-224), and the room credits DeFiHackLabs by name.

### The run, recorded

Run on 2026-09-29 the replay passes (`[PASS] testPoC()`), and the `museum:` lines
print, per pool, the two paired assets at the Vault (the pool's own BPT skipped):

| | pool A osETH/wETH | pool B wstETH/WETH |
|---|---|---|
| before | WETH 4,922.357 · osETH 6,851.581 | wstETH 4,270.841 · WETH 1,977.058 |
| after  | WETH 298.755 · osETH 0.458 | wstETH 43.583 · WETH 12.406 |

The **before** row reproduces, to the decimal, the fork-block Vault balances the
archive node gave (`VERIFIED.md`, "Pool A/B balances"): the run is reading the two
pools the room names — WETH `0xC02a…6Cc2`, osETH `0xf1C9…0E38`, wstETH
`0x7f39…2Ca0`. The **after** row is this port's own residual: the DeFiHackLabs PoC
drains by its own swap path, so it leaves more than the attacker's first
transaction did (`VERIFIED.md` records the on-chain 23,717,397 state as WETH 256.226
/ osETH 1.722 and wstETH 10.998 / WETH 13.219). Either way both pools fall from
thousands to almost nothing, and every figure is produced by the run, not typed.

## What it proves

The rounding error was already in the deployed V5 pool code at the fork block, and
in the V6 pools two bytes of creation code apart (the version fingerprint,
VD-310(2)). The replay shows the exact-out swap path draining the two low-liquidity
V5 pools that could no longer be paused, while a weighted pool of the same Vault
sat untouched (the control, VD-310(4)). The flaw was reachable by anyone reading
the pools that day.
