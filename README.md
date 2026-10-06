<!-- SPDX-License-Identifier: MIT -->
# Two doors

A museum where you stand inside a real hack at the block before it happened and find the loophole yourself.
Then you have two doors. One is the attack. The other is filing what you found on DAN, and DAN pays you for it.

Every room is a Foundry test on a fork of a public chain at a named block. I typed none of the numbers on the
walls. The tests read them off the chain and print them, and each README puts the command next to the number.

## The rooms

**Room 1, the auditor's room.** Beanstalk, on Ethereum at block 14,595,905, the night before it was drained in
April 2022. Here Beanstalk is staked in DAN. Its diamond's code and its governance spec sit on a row with a
bounty of 40 AUDIT, and the draw gives the row to you, so you're the auditor and you read the contracts while the
row is in review. The code does exactly what the spec says. What the spec never says is that a vote's weight has
to be held before the proposal, and that gap is the whole attack: flash loan, deposit, vote, commit, in one
transaction.

Door one is the attack. The port runs it against the fork at block 14,595,905, step by step, rebuilt, and the
pool drains. Door two is yours. You give no verdict on the row. You file the finding on it as a witness claim
with a stake, a stranger the cell draws runs it again and gets the same FAIL, and when the re-run's window
closes you're paid what anyone who found it would be paid. If you weren't on the row you'd file the same
finding, with the same stake, for the same pay, so it's one room whichever seat you came in by.

Right now the room runs in memory, and `forge test` proves it through the payout. The review on Base Sepolia,
on a fixture the museum deploys for it, isn't filed yet, and the plaque will carry the receipts when it is.
[`review/`](exhibits/beanstalk-2022-04/review/README.md), [`replay/`](exhibits/beanstalk-2022-04/replay/README.md)

**Room 2, the room with no seat.** Bybit, February 2025. Three of six owners signed, the wallet did what it was
told, and 401,346 ETH left. The check passes and it's right to pass, so there is no gap to file and no button.
DAN could not have caught this one, and the room says so. [`exhibits/bybit-2025-02/`](exhibits/bybit-2025-02/README.md)

**Room 3, the Balancer room.** Balancer's osETH/wETH pool on Ethereum at block 23,717,396, on 3 November 2025,
the block before it was drained. It's Room 1 again on a different hack. The pool is staked in DAN with a bounty
of 40 AUDIT, the draw gives the row to you, and you read the pool's deployed source in review. The spec has 13
invariants about rounding, each one taken from a line of that source, and the code does all 13. What the spec
never says is that on an exact-out swap every rounding has to favour the pool. The error enters at `_upscale`,
which rounds the amount out down, and StableMath carries it into the amount in.

Door one is the drain, DeFiHackLabs' port and the chain's own first transaction, both on the fork. Pool A goes
from 4,922.357 WETH and 6,851.581 osETH to 298.755 and 0.458. Door two is the same witness claim as Room 1's,
filed in review, re-run by a stranger and paid. Trail of Bits wrote the property down twice in 2021, asking for
the "appropriate rounding direction" in April and for "directions that benefit the pool" in October. Door two
files it where it can be checked and priced. This room
runs in memory only, and no fixture of it stands on any chain.
[`review/`](exhibits/balancer-2025-11/review/README.md), [`spec/`](exhibits/balancer-2025-11/spec/SOURCES.md),
[`replay/`](exhibits/balancer-2025-11/replay/README.md)

**The exit, the empty pedestal.** One command that runs DAN's check on any contract you like, against the live
cell on Base Sepolia. [`exhibits/exit/`](exhibits/exit/README.md)

Before the auditor's room, I showed the same Beanstalk row settled on the fork, and on 29 September 2026 I filed
the same words as a gap on Base Sepolia, on a second fixture. Those were real acts, so their tests still run and
their records stay in [`verdict/`](exhibits/beanstalk-2022-04/verdict/README.md),
[`fixture/`](exhibits/beanstalk-2022-04/fixture/README.md) and [`filing/`](exhibits/beanstalk-2022-04/filing/README.md).
The transcript keeps them on a page of their own, after the exit.

## Run it

You need Foundry and an archive endpoint that serves 2022 state. `eth.drpc.org` answered without a key when I
checked ([`PROVENANCE.md`](PROVENANCE.md)), and `.env.example` names it.

```
git clone --recurse-submodules https://github.com/Aui76/two-doors
cd two-doors
cp .env.example .env
forge test
```

On a fresh clone `forge test` reads 63 passed, 0 failed. The first compile is slow, minutes not seconds,
because DAN's AuditCell only fits under the contract size limit with `via_ir` and one optimizer run. After
that a run takes seconds. The transcript records the build and test times of its own run.

## Where DAN is

DAN's contracts are not copied in here. They come in as a submodule at `deps/dan`, pinned to
[`Aui76/decentralized-audit-network`](https://github.com/Aui76/decentralized-audit-network) at commit `0fafb27`.
The settlement core there is BUSL-1.1, and the interfaces and tools are MIT. This repository is MIT.

The network's live cell is `0xb034F198869726c36965B95879eCB65Bdb1076c9` on Base Sepolia. It has filed one row,
its genesis audit. Room 2's row lives on a local fork, Room 3's lives in memory, and Room 1's rows live in memory
and on the museum's own fixtures, so the live cell doesn't know about any of them.
