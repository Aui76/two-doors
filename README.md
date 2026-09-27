<!-- SPDX-License-Identifier: MIT -->
# Two doors

A museum where you stand inside a real hack at the block before it happened, find the loophole yourself, and
then choose between the attacker's door and the discoverer's door. DAN pays for the second one.

Every room is a Foundry test on a fork of a public chain at a named block. I typed none of the numbers on the
walls. The tests read them off the chain and print them, and each README puts the command next to the number.

## The rooms

**Room 1, the last safe moment.** Beanstalk, on Ethereum at block 14,595,905, the night before it was drained in
April 2022. A row is filed against the diamond's code on a local deploy of DAN, the auditor passes it, and the
check reads CLEAN. That's the right answer, because the contract does exactly what its governance rule says. Your
job is to find what the rule forgot to say. [`exhibits/beanstalk-2022-04/verdict/`](exhibits/beanstalk-2022-04/verdict/README.md)

**Room 2, the two doors.** You found it, now pick a door. Door two is the discoverer's: you file the gap on DAN
with a stake, and if the protocol stays silent the stake comes back. I filed it on 27 September 2026 on Base
Sepolia, on a fixture the museum deployed for this one filing, an instance of DAN's hull that isn't the network's
cell. The protocol said nothing, silence confirmed the gap, and the 10 AUDIT stake came back. Nobody paid a
reward, and the plaque says so. Door one replays the real attack and drains the pool. It's built: the ported transaction runs against the fork at block
14,595,905, step by step, and reproduces the drain. [`filing/`](exhibits/beanstalk-2022-04/filing/README.md), [`fixture/`](exhibits/beanstalk-2022-04/fixture/README.md),
[`replay/`](exhibits/beanstalk-2022-04/replay/README.md)

**Room 3, the room with no seat.** Bybit, February 2025. Three of six owners signed, the wallet did what it was
told, and 401,346 ETH left. The check passes and it's right to pass, so there is no gap to file and no button.
DAN could not have caught this one, and the room says so. [`exhibits/bybit-2025-02/`](exhibits/bybit-2025-02/README.md)

**The exit, the empty pedestal.** One command that runs DAN's check on any contract you like, against the live
cell on Base Sepolia. [`exhibits/exit/`](exhibits/exit/README.md)

## Run it

You need Foundry and an archive endpoint that serves 2022 state. `eth.drpc.org` answered without a key when I
checked ([`PROVENANCE.md`](PROVENANCE.md)), and `.env.example` names it.

```
git clone --recurse-submodules https://github.com/Aui76/two-doors
cd two-doors
cp .env.example .env
forge test
```

On a fresh clone on 26 September 2026 that read 32 passed, 0 failed. The first compile took 37 minutes on my
machine. DAN's AuditCell only fits under the contract size limit with `via_ir` and one optimizer run, and that
is slow to build. After that a run takes seconds.

## Where DAN is

DAN's contracts are not copied in here. They come in as a submodule at `lib/dan`, pinned to
[`Aui76/decentralized-audit-network`](https://github.com/Aui76/decentralized-audit-network) at commit `0561a4b`.
The settlement core there is BUSL-1.1, and the interfaces and tools are MIT. This repository is MIT.

The network's live cell is `0xb034F198869726c36965B95879eCB65Bdb1076c9` on Base Sepolia. It has filed one row,
its genesis audit. The rows in Rooms 1 and 3 live on local forks, and Room 2's row lives on the fixture, so the
live cell doesn't know about any of them.
