# The replay — Room 2, door one

This directory holds the exploit replay: the real April-2022 Beanstalk attack
transaction, run step by step against the fork at block 14,595,905, the pool
draining, with the command that reproduces it. It is the left door of Room 2 —
the attacker's door — and it stands beside door two, the discoverer's filing on
DAN.

## Footing (confirmed 2026-09-23)

- Archive RPC `https://eth.drpc.org` serves block 14,595,905 live
  (`eth_getBlockByNumber 0xDEBA41` returned the block). One free endpoint is the
  museum's single point of failure; a paid archive key goes in before 12 October.
- `forge 1.7.1` present.
- The fork harness (`../Fork.t.sol`) already proves the block, the 5547 diamond
  bytes and their hash, and that the attacker's contract
  `0xE5eCF73603D98A0128F05ed30506ac7A663dBb69` (BIP 18) is empty at the fork block
  — the last safe moment, before the attack was written.

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
than trusting a moved path. Once fetched, the port adapts only the imports and the
RPC alias (`mainnet` → `${MAINNET_ARCHIVE_RPC_URL}`) — never a line of the attack —
and the room prints every number the run produces (VD-224: no number typed by hand).

## What it proves

The replay is the vertigo made mechanical: the same governance snapshot the spec's
`vote-weight-is-proportional-to-stalk` and
`emergency-commit-requires-day-and-supermajority` invariants describe — vote weight
read at the instant of the vote, the only time gate being 24h since the *proposal* —
is enough to carry an `emergencyCommit` supermajority with a position that was not
yours a block earlier. The rule never said the votes had to be yours.
