<!-- SPDX-License-Identifier: MIT -->
# The gap filed on the second fixture, on file

This was Room 2's door two until 3 October 2026, when the auditor's room (`../review/`) took
its place. The filing and its records stand as they were filed.

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
transactions, their blocks and their times are in `../fixture/record/`, and the
commands under the plaque print them and read the rest back from the chain.

> **Exhibit fixture.** This is an instance of the DAN hull at `0f3eaf8`, deployed
> on Base Sepolia by the museum for one filing. It is not the network's cell. The
> network's cell is `0xb034F198869726c36965B95879eCB65Bdb1076c9` on Base Sepolia
> since 2026-09-13; it is this entry's provenance and holds no exhibit. The
> fixture holds no value, sits in no deployment record, and is read by no DAN tool.
> Before the filing, its admin, the museum's key, registered the gap's class and
> flagged door two's evaluator canonical.

The stand. On 29 September 2026 at 06:42:20 UTC, block 47,447,926, the museum's
key `0x85F9549e4fdCa52fF56742B27b6C037ae5B06966` deployed the fixture's AuditCell
at `0x5D76C2127Ea49F1f6cc4b7228608d4ccD9c62016`, in transaction
`0x6a869677…9609`. It flagged door two's evaluator canonical at block 47,447,982
and registered the gap's class at 47,447,983. Basescan verified all 16 of the
fixture's contracts. This is the second fixture I stood. Basescan could not
verify the first one's AuditCell, and `../fixture/README.md` says why and what I
changed.

The row. The museum's key took the protocol's seat and filed Room 1's row as row
0, with a bounty of 40 AUDIT. `0xEdB37f4C862fC94A63Fe826baCefF2fF17016839`
audited it and passed it, and the row's window opened at 07:07:40 UTC for 600
seconds.

The gap. At 07:07:46 UTC, block 47,448,689, the discoverer
`0xfEE57981D498a5b3882ac464344687A12c8d4cC9`, a second fresh key, filed the gap
against row 0 in transaction `0xd5cc45f3…98bf` and staked 10 AUDIT. The protocol
had until 07:12:46 to answer and said nothing.

The confirm. I sent it from the discoverer's key at 07:13:28 UTC, block
47,448,860, 42 seconds after the protocol's window closed, in transaction
`0xc57c1c1f8de7a7e7ecf945bf469d64266807e8eaf7c9acfe7eff89ff19840b46`. The module
sent the 10 AUDIT stake back to the discoverer, and the gap reads Confirmed.

So the discoverer got back what they staked and nothing more. A reward is the
protocol's to give by adopting the gap, and the protocol never adopted it.

The row. Its own window closed at 07:17:40 UTC. At 07:18:14, block 47,449,003, I
sent `confirmAudit` for row 0 from the discoverer's key, in transaction
`0x333b31b26818a8d51a5221050ba8938b4d1a53b8bb9fddfa6234f0d0708d11eb`. Row 0 now
reads InBlock. The cell paid the auditor the 40 AUDIT bounty, and in the same
transaction the issuance module minted 0.625 AUDIT to the auditor and 0.6440625
to the escrow. The cell holds 0 AUDIT, the auditor 40.625 and the discoverer 10.
The fixture holds one row, so nothing on it supersedes row 0. The museum's key
holds 0 AUDIT, and its nonce was 140 at the filing's block and 140 after it.

This prints the gap's status, the row's state, bounty and window, what the cell,
the auditor, the discoverer and the museum's key hold, the key's nonce, and the
block and second it read at. State 4 is AwaitingWindow and 6 is InBlock. Times
are unix seconds and amounts are wei, 18 decimals to the AUDIT. Row 0 is settled,
so the row reads as above for good. The balances are keys' balances, and a key
can still send its AUDIT on.

```bash
forge script exhibits/beanstalk-2022-04/filing/Filing.s.sol:ReadTheFiling --sig "check()" --rpc-url https://sepolia.base.org
```

The number of rows on the fixture, and the key's nonce at the filing's block:

```bash
cast call 0x5D76C2127Ea49F1f6cc4b7228608d4ccD9c62016 "nextAuditId()(uint256)" --rpc-url https://sepolia.base.org
```

```bash
cast nonce 0x85F9549e4fdCa52fF56742B27b6C037ae5B06966 --block 47448689 --rpc-url https://sepolia.base.org
```

The stand's and the filing's transactions, with their blocks and times, from the
record:

```bash
node -e "const j=require('./exhibits/beanstalk-2022-04/fixture/record/84532.transactions.json');for(const t of j.transactions)if((t.contract==='AuditCell'&&t.type==='CREATE')||/^(setToolWitnessFlags|registerClass|submitArtifactAudit|provePass|openSpecGap)\(/.test(t.function||''))console.log(t.function||'deploy '+t.contract,t.tx,t.block,new Date(t.timestamp*1000).toISOString())"
```

The confirm is in `../fixture/record/84532.confirm.json`, and the row's
settlement in `../fixture/record/84532.settle.json`. The first fixture's records
are in `../fixture/record/superseded/`.

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

The row's own window runs beside the gap. Once it closes, anyone may send
`confirmAudit`. Then the row settles, the cell pays its auditor, and the gap
stays where it was.

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

5. **Commit the records**: `../fixture/record/84532.filing.json`, which the
   filing wrote, and `../fixture/record/84532.transactions.json`, which the
   command below writes from forge's broadcast logs of the stand and the filing,
   with each block's time read from the node. The logs are gitignored and live on
   the machine that sent the transactions, so this file is the only copy the
   repository has of the stand's and the filing's transactions. The command
   refuses to overwrite it, and with `--check` it compares the file with the logs.

```bash
node exhibits/beanstalk-2022-04/fixture/transactions.js
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

8. **Settle the row** once its own window has closed. `ReadTheFiling` prints
   that second too. Any key with gas may send it, and the operator sent it from
   the second key. Then commit `../fixture/record/84532.settle.json`, read from
   its receipt the same way: the sender, the block and its second, the bounty's
   transfer to the auditor and the issuance module's mints.

   ```bash
   cast send AUDIT_CELL "confirmAudit(uint256)" ROW --private-key $SECOND_KEY --rpc-url https://sepolia.base.org
   ```
