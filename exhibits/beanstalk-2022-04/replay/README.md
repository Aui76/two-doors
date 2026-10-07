<!-- SPDX-License-Identifier: MIT -->
# The replay — Room 1, door one

This directory holds the exploit replay: the April-2022 Beanstalk attack, rebuilt
and run step by step against the fork at block 14,595,905, the pool draining, with
the command that reproduces it. It is a rebuilt attack, not the chain's own
transaction. The test makes the proposal itself, moves the clock forward one day,
and drains through its own flash loan. The chain's drain is
`0xcd314668aaa9bbfebaf1a0bd2b6553d01dd58899c508d4729fa7311dc5d33ad7` in block
14,602,790, which is 6,885 blocks after the fork, and it is not run here. It is
door one of Room 1, the attacker's door, and it stands beside door two, the
finding the drawn auditor files on DAN while the row is in review (`../review/`).

## Footing (confirmed 2026-09-23)

- Archive RPC `https://eth.drpc.org` serves block 14,595,905 live
  (`eth_getBlockByNumber 0xdeb741` returned the block; the first draft of this line
  wrote `0xDEBA41`, which is 14,596,673 — a number typed, not printed). One free endpoint is the
  museum's single point of failure; a paid archive key goes in before 12 October.
- `forge 1.7.1` present.
- The fork harness (`../Fork.t.sol`) already proves the block, the 5547 diamond
  bytes and their hash, and that the attacker's contract
  `0xE5eCF73603D98A0128F05ed30506ac7A663dBb69` (BIP 18) is empty at the fork block
  — the last safe moment, before the attack was written.
- The fork is the state the attack met, not only the block before it. The attack's
  first transaction, the proposal the replay rebuilds (`0x68cdec0a…4c6f`), is
  transaction 94 of 138 in block 14,595,906, and no receipt ahead of it in that block
  touches the diamond, BEAN, BEAN3CRV, BEANLUSD or BEAN/ETH (receipts, not a trace):
  `python exhibits/fork-position.py` (added 2026-09-30).

## The port itself

Per the entry §4 (VD-240) the replay is a **port with credit** of DeFiHackLabs'
`src/test/2022-04/Beanstalk_exp.sol` (Apache-2.0; see `NOTICE.md`). It is public,
on-chain-permanent history.

The attack body is brought into `Replay.t.sol` from the public source rather than
retyped, so the port is a faithful transcription and its provenance is a fetch,
not a paraphrase. The one command that populates the slot, run from the repo root:

```bash
curl -sL https://raw.githubusercontent.com/SunWeb3Sec/DeFiHackLabs/main/src/test/2022-04/Beanstalk_exp.sol -o exhibits/beanstalk-2022-04/replay/Beanstalk_exp.orig.sol
sha256sum exhibits/beanstalk-2022-04/replay/Beanstalk_exp.orig.sol
```

The sha256 must read `07c9396063f71acd5e6b4e688adb7bc1ebdd1022083cb05cfc997b3312b42256`
(the byte-for-byte file recorded in `../../../PROVENANCE.md`). If the file has moved
in the upstream repo, fetch it by that hash from the repository's history rather
than trusting a moved path.

The `*.orig.sol` reference is a **transient**: it is gitignored and `foundry.toml`
skips `*.orig.sol` from compilation (PC-131 — without that skip the fetched file's
own `interface.sol` import breaks `forge build`, since `test = "exhibits"` compiles
every `.sol` under this tree). So the fetch is safe to run from a green tree and the
raw copy is never committed. The **compiled** artifact is `Replay.t.sol`, transcribed
from the reference and living in this compiled directory.

Transcribing `Replay.t.sol` from the reference is the one step that adapts imports —
provide the `interface.sol` the source expects — but **not the RPC alias**: that is
already mapped at config level (`foundry.toml` → `mainnet = "${MAINNET_ARCHIVE_RPC_URL}"`),
so no port edit touches it. Never a line of the attack is adapted; the byte-faithful
copy is `Beanstalk_exp.orig.sol`, pinned by the sha256 above.

The museum adds a few of its own labelled lines at the top and bottom of `testExploit`,
each marked `museum:`, around the untouched attack: the fork block and the attacker's
USDC balance before and after the drain (read off the same account the attack sweeps to,
so the difference is the profit). The transcript's door-one page keys on those museum
labels rather than on DeFiHackLabs' ad-hoc ones, which stay as they wrote them. Every
number the room prints, the museum's lines included, is produced by the run and not typed
by hand (VD-224), and the room credits DeFiHackLabs by name.

**No `etch` on the room's addresses** (operator, 2026-10-06). `vm.etch` puts new runtime
code at an address without running a constructor, and the fork's storage beside it stays
as it was. A room that etched an exhibit's contract would no longer be running the bytecode
the attack met. No test in this tree calls it; the only `etch` under `exhibits/` is the
declaration in the upstream `interface.sol`. Run from the repo root, the check prints nothing:

```bash
grep -rnE '\betch\(' exhibits specimens src --include=*.sol | grep -v 'function etch'
```

## What it proves

The replay is the vertigo made mechanical: the same governance snapshot the spec's
`vote-weight-is-proportional-to-stalk` and
`emergency-commit-requires-day-and-supermajority` invariants describe — vote weight
read at the instant of the vote, the only time gate being 24h since the *proposal* —
is enough to carry an `emergencyCommit` supermajority with a position that was not
yours a block earlier. The rule never said the votes had to be yours.
