<!-- SPDX-License-Identifier: MIT -->
# Door two: the discoverer's filing

In door two the discoverer files a spec gap against Room 1's row, on the fixture
that `../fixture/` stands. The fixture is not the network's cell; its README carries the paragraph
that goes wherever its address is printed.

The gap is one sentence the governance spec never said: a vote may count only
the Roots the voter held when the BIP was proposed. The spec reads the weight at
the instant of the vote and counts its one time gate from the proposal, so a
position acquired after the proposal votes with full weight. The replay behind door
one is that sentence run on the fork.

## The plaque

Every number here is in a receipt on Base Sepolia or a read of the chain. The
records in `../fixture/record/` hold them, and the commands under the plaque read
them back.

> **Exhibit fixture.** This is an instance of the DAN hull at `0f3eaf8`, deployed
> on Base Sepolia by the museum for one filing. It is not the network's cell. The
> network's cell is `0xb034F198869726c36965B95879eCB65Bdb1076c9` on Base Sepolia
> since 2026-09-13; it is this entry's provenance and holds no exhibit. The
> fixture holds no value, sits in no deployment record, and is read by no DAN tool.
> Before the filing, its admin, the museum's key, registered the gap's class and
> flagged door two's evaluator canonical.

The stand. On 27 September 2026 at 19:42:40 UTC, block 47,384,936, the museum's
key `0x85F9549e4fdCa52fF56742B27b6C037ae5B06966` deployed the fixture's AuditCell
at `0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2`, in transaction
`0x171d5aed…b8d6`. It flagged door two's evaluator canonical at block 47,384,993
and registered the gap's class at 47,384,994. Basescan verified 15 of the
fixture's 16 contracts. AuditCell is the one it did not, and
`../fixture/README.md` says why.

The row. The museum's key took the protocol's seat and filed Room 1's row as row
0, with a bounty of 40 AUDIT. `0xEdB37f4C862fC94A63Fe826baCefF2fF17016839`
audited it and passed it, and the row's window opened at 19:53:16 UTC for 600
seconds.

The gap. At 19:53:22 UTC, block 47,385,257, the discoverer
`0xfEE57981D498a5b3882ac464344687A12c8d4cC9`, a second fresh key, filed the gap
against row 0 in transaction `0x7ac4a1f5…b5ac` and staked 10 AUDIT. The protocol
had until 19:58:22 to answer and said nothing.

The confirm. I sent it from the discoverer's key at 20:00:14 UTC, block
47,385,463, 112 seconds after the protocol's window closed, in transaction
`0x36d26fe400734e1c4b1ce2efdf6c1297f5f348519510ea1e7019cf1ea43712b4`. The module
sent the 10 AUDIT stake back to the discoverer, and the gap reads Confirmed.

So the discoverer got back what they staked and nothing more. A reward is the
protocol's to give by adopting the gap, and the protocol never adopted it. The
row's own window closed at 20:03:16 UTC. Nobody had sent `confirmAudit` for it
when I read the chain at 21:23 UTC, so row 0 still read AwaitingWindow, the cell
still held the 40 AUDIT bounty, and the auditor held none. No row carries a
corrected spec, so nothing on the fixture supersedes row 0. The museum's key
holds 0 AUDIT, and its nonce was 71 at the filing's block and 71 after it.

```bash
forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:ReadTheFiling --sig "check()" --rpc-url https://sepolia.base.org
```

```bash
cast call 0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2 "auditStateOf(uint256)(uint8)" 0 --rpc-url https://sepolia.base.org
```

State 4 is AwaitingWindow and 6 is InBlock. The balances, cell first, then the
auditor, the discoverer and the museum's key:

```bash
for a in 0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2 0xEdB37f4C862fC94A63Fe826baCefF2fF17016839 0xfEE57981D498a5b3882ac464344687A12c8d4cC9 0x85F9549e4fdCa52fF56742B27b6C037ae5B06966; do cast call 0x9C667B21C072D2Cf816fF458D6698be8D21f6A33 "balanceOf(address)(uint256)" $a --rpc-url https://sepolia.base.org; done
```

## What is in this directory

- `gap.json` holds the gap in words: its class, the missing invariant, the
  location in the specimens, the witness and the context. The cell receives only
  hashes, and each is the keccak256 of one of these strings, read at run time.
  Change a word and every hash follows. The stand freezes the words and records
  their hashes, and the filing refuses words that differ. A changed gap after
  the stand is a second exhibit (VD-273(4)).
- `Room2.sol` reads those words, names the finder and evaluator labels, and
  builds the result root the cell checks the filing against.
- `Filing.s.sol` holds two scripts.
  - `FileTheGap` files Room 1's row on the fixture, has the auditor pass it, and
    files the gap against it, then reads everything back and writes the record.
  - `ReadTheFiling` reads the recorded filing back from any node, prints where
    the gap stands now and sends nothing.
- `../Filing.t.sol` proves the filing in memory from both seats, what follows it,
  and what it refuses.

## Who sits where

On this hull the filing takes three keys. The discoverer may be neither
the row's protocol nor its auditor, and the fixture key may not audit its own
fixture. So the fixture's named genesis auditor audits, the fixture key takes one
of the other two seats, and a second key takes the last one.

The fixture key takes the protocol's seat and a fresh second key files as the
discoverer (VD-273(2)). The operator may override that with
`FIXTURE_SEAT=discoverer`. Whichever seat the second key takes, the fixture key
hands it what that seat spends: the bounty to a protocol, the claim stake to a discoverer. The
fixture key ends the filing holding nothing and sends nothing after it
(VD-270(ii)).

The auditor registers first, then the protocol files and accepts the auditor
drawn for the row, and only then does the discoverer register. The fixture draws
auditors at random from the queue, so a discoverer already in the queue could be
drawn for the row they are about to file against.

## What the stand does for it

Two things door two needs are admin acts: flagging the evaluator canonical and
registering the gap's class. The stand is the fixture's only admin broadcast, so
it makes both there, and it registers the museum's four tool labels in the same
broadcast. The filing then runs with no admin key. On this hull nobody can clear
the canonical flag once it is set.

## After the filing

The protocol has a decision window. If it stays silent, anyone may confirm the
gap once the window has passed. The module hands the stake back to the discoverer
and records the gap against Room 1's spec tool. The script prints the second from which
that is possible.

Silence pays back the stake and nothing more. A reward is the protocol's to give,
by adopting the gap, and it is paid from the protocol's own AUDIT. On the fixture
the protocol holds none after the bounty, so adoption fails until something funds
it. The test shows both halves.

The row's own window runs beside the gap. When it closes the row settles, the
cell pays its auditor, and the gap stays where it was.

## The rehearsal on anvil

Stand the fixture first, as `../fixture/README.md` says. Then file from anvil's
account 0 as the fixture key, account 1 as the auditor the stand named, and
account 2 as the second key:

```bash
FIXTURE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 AUDITOR_KEY=$(cast wallet private-key "test test test test test test test test test test test junk" 1) SECOND_KEY=$(cast wallet private-key "test test test test test test test test test test test junk" 2) forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:FileTheGap --sig "file()" --rpc-url http://127.0.0.1:8545 --broadcast --slow
```

```bash
forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:ReadTheFiling --sig "check()" --rpc-url http://127.0.0.1:8545
```

`ReadTheFiling` prints the second from which silence can confirm the gap, and it
reads that second from the chain. The filing script writes its record while forge
simulates the filing, before any transaction is mined, so the record leaves the
second out.

To see silence confirm on the rehearsal, move anvil's clock to that second, then
confirm from the second key and read the filing again:

```bash
cast rpc evm_setNextBlockTimestamp SILENCE_CONFIRMS_FROM --rpc-url http://127.0.0.1:8545 && cast rpc evm_mine --rpc-url http://127.0.0.1:8545
```

```bash
cast send SPEC_GAP_MODULE "confirmSpecGapSilence(uint256,bytes32)" ROW GAP_CLASS --private-key $(cast wallet private-key "test test test test test test test test test test test junk" 2) --rpc-url http://127.0.0.1:8545
```

with the values `ReadTheFiling` printed under those names in place of the
capitals.

## On Base Sepolia: the operator's acts

Each of these is the operator's keystroke (VD-270). The session runs none of them.

1. **Stand the fixture and commit its record**, as `../fixture/README.md` says.
2. **Make a second fresh key.** It files the gap as the discoverer, or files the
   row as the protocol under `FIXTURE_SEAT=discoverer`. Neither the second key
   nor the auditor key is ever a network key; the script refuses them all.
3. **Fund the auditor key and the second key with gas** from a faucet. The script
   refuses to start while either holds none.
4. **File.** This is the same command as the rehearsal, pointed at Base
   Sepolia, with the three keys:

   ```bash
   forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:FileTheGap --sig "file()" --rpc-url https://sepolia.base.org --broadcast --slow
   ```

5. **Commit the record**, `../fixture/record/84532.filing.json`, with the filing
   transaction and its block as the command below prints them.

```bash
node -e "const b=require('./broadcast/Filing.s.sol/84532/file-latest.json');const r=Object.fromEntries(b.receipts.map(x=>[x.transactionHash,x]));for(const t of b.transactions.filter(t=>(t.function||'').startsWith('openSpecGap(')))console.log(t.hash,parseInt(r[t.hash].blockNumber,16))"
```

6. **Confirm by silence** once the window has passed. `ReadTheFiling` against
   Base Sepolia prints the second. Any key with gas may send the confirm, and the
   operator sent it from the second key. Sent before that second, the module
   reverts with `ProtocolWindowOpen` (`0x44e2ade4`) and nothing lands on chain.

   ```bash
   cast send SPEC_GAP_MODULE "confirmSpecGapSilence(uint256,bytes32)" ROW GAP_CLASS --private-key $SECOND_KEY --rpc-url https://sepolia.base.org
   ```

7. **Commit the confirm's record**, `../fixture/record/84532.confirm.json`, read
   from the confirm's receipt: the sender, the block and its second, and the
   stake's transfer back to the discoverer.

```bash
cast receipt CONFIRM_TX --json --rpc-url https://sepolia.base.org
```
