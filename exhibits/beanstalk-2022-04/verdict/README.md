<!-- SPDX-License-Identifier: MIT -->
# The verdict, on file

This was Room 1 until 3 October 2026, when the auditor's room (`../review/`) took its place.
Its tests still run, and the transcript keeps them on its page after the exit.

The last safe moment. Ethereum at block 14,595,905, Saturday 16 April 2022, 10:54
UTC, the night before Beanstalk was drained. The cured hull stands beside the
diamond, a row is filed against the diamond's code — the hash of the bytes, no
address behind it — the auditor's PASS is proven, the window closes, and the door
is asked. It says CLEAN.

Nothing here is a promise. The plaque sentence, ruled before the harness existed:

> produced by the auditor against the Gate A spec written from pre-hack words,
> settled by a local deploy of the cured hull at 0f3eaf8, and read back by dan-check

Never "DAN found it clean". The auditor is one of anvil's default accounts, the
cell is a local deploy, and every number below is printed by the commands beside
it. On the fork the row sits on a block in 2026-shaped time; the only 2022 thing
about it is the code it names.

## What is in this directory

- `Room1.sol` — what the test and the script share: the constants (checked against
  the fork before use), the hull's wiring copied step for step from the cell's own
  test helper, and the one call that files the row.
- `Verdict.s.sol` — the same lifecycle broadcast to a running anvil fork, so the
  row stays where `dan-check` can be pointed at it.
- `../Verdict.t.sol` — the lifecycle proven and forgotten, three tests on the fork.

## Setup, once

The hull is not vendored (it is BUSL-1.1; this tree is MIT). It comes in as a git
submodule at `deps/dan`: DAN's public repository,
[`Aui76/decentralized-audit-network`](https://github.com/Aui76/decentralized-audit-network),
pinned at commit `0fafb27`. Inside the project, not beside it: a remapping that
points outside the root makes foundry compile every hull source twice under two
spellings of one path, and the two `AuditCell` artifacts cannot be linked.

From the repository root, once after cloning:

```
git submodule update --init
```

That fetches `deps/dan` and `deps/forge-std`. A clone made with `--recurse-submodules`
already has both. The hull's contracts sit under `deps/dan/cell/contracts/`.

The contracts there are the cured hull at the network's commit `0f3eaf8`, with one
difference: the 8 interfaces carry an MIT licence line where the network's own tree
has BUSL-1.1. That line ends up in the compiled metadata, so AuditCell's bytes here are
not byte for byte the network's build. Nothing in this room compares against them.

An archive endpoint that serves 2022 state, in the environment:

```
export MAINNET_ARCHIVE_RPC_URL=https://eth.drpc.org
```

## The tests

```
forge test --match-contract BeanstalkVerdictTest -vv
```

Three tests. The first files, proves, settles and reads back; its log prints the
fork block, the cell, the audit id, the artifact hash, the spec hash, the case
root, the window and the state. The second shows that a different hash finds no
row — and that the index alone cannot say so, because the row is id 0 (below).
The third shows the window cannot be skipped.

## The row on a node

Start a fork of mainnet at the room's block. `--hardfork shanghai` is required:
anvil takes the ruleset from the fork block, which is pre-Shanghai, and the hull
is compiled with `PUSH0`; without the flag the deploy fails `NotActivated`.

```
anvil --fork-url $MAINNET_ARCHIVE_RPC_URL --fork-block-number 14595905 --hardfork shanghai
```

File the row and prove the verdict. The keys are anvil's default mnemonic, derived
in the script: account 0 deploys and administers, 1 files, 2 audits.

```
forge script exhibits/beanstalk-2022-04/verdict/Verdict.s.sol:FileTheVerdict --rpc-url http://127.0.0.1:8545 --broadcast
```

The script stops with the window open and prints the cell address; put it in
`CELL`. Asked now, `dan-check` says CANNOT VERIFY, exit 2: a passing audit with an
open window is not a verdict yet. Close the window — a script cannot move a node's
clock, so this is two RPC calls — and confirm the row:

```
cast call $CELL "minAuditWindow()(uint256)" --rpc-url http://127.0.0.1:8545
cast rpc evm_increaseTime 1209601 --rpc-url http://127.0.0.1:8545
cast rpc evm_mine --rpc-url http://127.0.0.1:8545
cast send $CELL "confirmAudit(uint256)" 0 --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url http://127.0.0.1:8545
```

Ask the door. `--block` pins the code read to the room's block, so the claim has a
time in it and an archive node answers it again.

```
node exhibits/exit/dan-check/dan-check.mjs --target 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5 --cell $CELL --home-rpc http://127.0.0.1:8545 --block 14595905
```

```
  CLEAN — audit #0, state InBlock (settled and the adversarial window has closed)
  codehash 0x2ff59388cd5e1842a3d057338010945a779a6c7d57abfb5e9ddc697838700870
```

Exit 0. Asked about code with no row (`--target $CELL`, the cell's own bytes),
the door refuses, exit 1, and with `--deep` it walks the one row and says
"NEVER AUDITED" — a positive claim it makes only after reading every row.

## What the room found in the door (PC-132)

The first run refused. A fresh cell's first audit is id 0, the genesis audit on
the live cell is id 0, and `dan-check` read `artifactToAuditId(hash) == 0` as "no
row" — so a settled row 0 was REFUSE, exit 1, and `--deep`, walking from 1, called
it NEVER AUDITED with "all 0 of 0 rows read". The cell keeps the disambiguator
itself, `artifactRegistered(bytes32)`, set beside the index and cleared with it;
the door now reads that bit first and walks from 0. Two smaller things fell out
of the same run: a decimal `--block` was handed to the node as-is and rejected,
and on Windows the tool's exit aborted with code 127 on every path, CLEAN
included. All three are cured in the tool, none in the hull; the tool's offline
oracle carries the cases.
