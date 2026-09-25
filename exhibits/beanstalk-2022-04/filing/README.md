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

## What is in this directory

- `gap.json` holds the gap in words: its class, the missing invariant, the
  location in the specimens, the witness and the context. The cell receives only
  hashes, and each is the keccak256 of one of these strings, read at run time.
  Change a word and every hash follows.
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

Which seat the fixture key takes is the operator's choice (VD-270), and the
script asks for it with `FIXTURE_SEAT=protocol` or `FIXTURE_SEAT=discoverer`. It
has no default. Whichever seat the second key takes, the fixture key hands it what
that seat spends: the bounty to a protocol, the claim stake to a discoverer. The
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
FIXTURE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 AUDITOR_KEY=$(cast wallet private-key "test test test test test test test test test test test junk" 1) SECOND_KEY=$(cast wallet private-key "test test test test test test test test test test test junk" 2) FIXTURE_SEAT=protocol forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:FileTheGap --sig "file()" --rpc-url http://127.0.0.1:8545 --broadcast --slow
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
2. **Choose the seat and make a second fresh key.** Neither the second key
   nor the auditor key is ever a network key; the script refuses them all.
3. **Fund the auditor key and the second key with gas** from a faucet. The script
   refuses to start while either holds none.
4. **File.** This is the same command as the rehearsal, pointed at Base
   Sepolia, with the three keys and the chosen seat:

   ```bash
   forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:FileTheGap --sig "file()" --rpc-url https://sepolia.base.org --broadcast --slow
   ```

5. **Commit the record**, `../fixture/record/84532.filing.json`, with the filing
   transaction and its block as the command below prints them.

```bash
node -e "const b=require('./broadcast/Filing.s.sol/84532/file-latest.json');const r=Object.fromEntries(b.receipts.map(x=>[x.transactionHash,x]));for(const t of b.transactions.filter(t=>(t.function||'').startsWith('openSpecGap(')))console.log(t.hash,parseInt(r[t.hash].blockNumber,16))"
```
