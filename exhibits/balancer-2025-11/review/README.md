<!-- SPDX-License-Identifier: MIT -->
# The Balancer room, the auditor's seat

Balancer is staked in DAN. The code of its osETH/wETH pool, `0xDACf…850c` on
Ethereum, and a spec of its swap rounding sit on a row with a bounty of 40
AUDIT, and the draw gives the row to you. You're the auditor, and you read the
pool's source while the row is in review, before you give any verdict. The
source is the one deployed at block 23,717,396 on 3 November 2025, the block
before the drain, and `../spec/SOURCES.md` says where each byte came from.

The spec has 13 invariants and every one names the line it came from. Most of
them are Balancer's own comments: exact in rounds the amount out down, exact out
rounds the amount in up, the invariant rounds down, a join rounds up and an exit
rounds down. One of them is `_upscale` in `BasePool.sol`, which multiplies every
amount by its scaling factor and rounds down. Balancer's comment on it expects
the impact to be minimal, because there is no rounding error unless the scaling
factor is overridden. This pool overrides it, with a token rate, at
`ComposableStablePoolRates.sol` line 302.

The code does what each of the 13 says. What the spec never says is that on an
exact-out swap every rounding on the path has to favour the pool. The error
enters at `_upscale`, which makes the amount out smaller before the math prices
it, and `_calcInGivenOut` in `StableMath.sol` carries it into the amount in.
Door one of this room is the drain that gets through that gap, run against the
fork: DeFiHackLabs' port, and the chain's own first transaction beside it.

You file what you found as a witness claim on the row, with a stake. The cell
sends the finding to a drawn stranger to run again with the evaluator, and when
the stranger gets the same FAIL and the re-run's window closes, the row is
Exploited and you're paid as anyone who found it would be. It's Room 1's door,
on Balancer's row.

## In memory only

This room has no fixture on any chain, and the scripts refuse to make one. They
run under `forge test`, on chain 31337 and without `--broadcast`, and they write
no record. `../Review.t.sol` proves the room through the settlement and the
payout, and what it refuses:

```bash
forge test --match-path exhibits/balancer-2025-11/Review.t.sol -vv
```

## What is in this directory

- `finding.json` holds the finding in words: the missing invariant, the location
  in the specimens with each file's sha256, the witness and the context. The cell
  receives only hashes, and `../Review.t.sol` finds every hash and line the words
  name again in the file they came from.
- `Room3.sol` holds the room's constants: the fork block, pool A and its code
  hash, the Vault, the spec's path, the spec label and the bounty.
  `../Provenance.t.sol` ties the spec's target to them.
- `Review.sol` reads the words, names the review and evaluator labels, and builds
  the FAIL root the cell checks the claim against.
- `Review.s.sol` holds two scripts. `StandTheBalancerReview` deploys and wires
  the hull exactly as Room 1's stand does, registers the room's three labels,
  flags the evaluator canonical, and mints one review's worth of AUDIT to the
  fixture key: the bounty, the claim stake and the re-run's bounty.
  `FileTheBalancerFinding` runs the review: Balancer files the row, the draw gives
  it to the auditor, the auditor files the witness claim in review, Balancer funds
  the re-run, and the stranger runs it and gets the same FAIL. Then it reads
  everything back.

## Who sits where

Three keys, as in Room 1. The fixture key is Balancer, and it may not audit its
own fixture (PC-86). The auditor is the fixture's named genesis auditor. The
stranger runs the re-run, and the cell refuses that seat to whoever filed the
claim. The auditor registers first and the stranger only after the claim, so
when the re-run is opened the stranger is the only candidate left.
