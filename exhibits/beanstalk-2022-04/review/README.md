<!-- SPDX-License-Identifier: MIT -->
# The auditor's room

Beanstalk is staked in DAN. Its diamond's code and its governance spec sit on a
row with a bounty of 40 AUDIT, and the draw gives the row to you. You are the
auditor. The contracts land in front of you and you read them while the row is
in review, before you give any verdict.

The spec says a vote counts with the voter's Stalk at the moment of the vote, and
that an emergency commit needs a day and a supermajority, counted from the
proposal. Read `VotingBooth.sol` lines 32 to 35 and `GovernanceFacet.sol` lines
180 to 191 next to it and the code does exactly that. What the spec never says
is that the weight has to be held before the proposal. So a position bought after
the proposal votes with full weight, and that is the attack: flash loan, deposit,
vote, commit, in one transaction. Door one of this exhibit is that sentence run
on a fork of block 14,595,905.

You don't pass the row and you don't fail it. You file what you found as a
witness claim on the row, with a stake. The cell sends the finding to a drawn
stranger to run again with the evaluator. If the stranger gets the same FAIL, the
row is Exploited once the re-run's window closes, and you are paid as anyone who
found it would be. If the re-run reads PASS, you lose the stake. If it reads
neither, nobody judged anything, the stake comes back and the clock you lost is
given back.

A discoverer who is not on the row files the same finding the same way after a
PASS. The finding, the stake and the pay are the same. The only difference is
when you file it.

## The plaque

Nothing has been filed on Base Sepolia yet. The room is proven in memory by
`../Review.t.sol`, and the operator's acts below stand it on chain. When they are
done this section carries the receipts, the way `../filing/README.md` carries the
second fixture's.

> **Exhibit fixture.** This is an instance of the DAN hull at network commit
> `7fd937a`, the first hull with the auditor's witness claim in review, deployed on
> Base Sepolia by the museum for one review. It is not the network's cell. The
> network's cell is `0xb034F198869726c36965B95879eCB65Bdb1076c9` on Base Sepolia;
> it is this entry's provenance and holds no exhibit. The fixture holds no value,
> sits in no deployment record, and is read by no DAN tool. It is a third fixture,
> beside the second one that `../filing/` filed on, and writes its own records.

## What is in this directory

- `finding.json` holds the finding in words: the missing invariant, the location
  in the specimens, the witness and the context. They are the words the
  discoverer filed as a gap on 29 September 2026, so every commitment is the same
  hash, and a test checks that. The cell receives only hashes. The stand freezes
  the words and records their hashes, and the review refuses words that differ
  (VD-273(4)).
- `Review.sol` reads those words, names the review and evaluator labels, and
  builds the FAIL root the cell checks the claim against.
- `Review.s.sol` holds three scripts.
  - `StandTheReview` deploys and wires the hull exactly as the second fixture's
    stand does, then registers the room's three tool labels, flags the evaluator
    canonical, and mints one review's worth of AUDIT to the fixture key: the
    bounty, the claim stake and the re-run's bounty.
  - `FileTheFinding` runs the review: Beanstalk files the row, the draw gives it
    to the auditor, the auditor files the witness claim in review, Beanstalk funds
    the re-run, and the stranger runs it and gets the same FAIL. Then it reads
    everything back and writes the record.
  - `ReadTheReview` reads the recorded review back from any node, prints where
    the row and the re-run stand now and who holds what, and sends nothing.
- `../Review.t.sol` proves the room in memory, through the settlement and the
  payout, and what it refuses.

## Who sits where

Three keys, because the hull decides it. The fixture key is Beanstalk, the
protocol, and it may not audit its own fixture (PC-86). The auditor is the
fixture's named genesis auditor, the seat the draw gives the row to. The stranger
runs the re-run, and the cell refuses that seat to whoever filed the claim.

The auditor registers first, then Beanstalk files the row and accepts the auditor
drawn for it, and only after the claim does the stranger register. The fixture
draws at random from the queue, so a stranger already in it could be drawn for
the row itself. When the re-run is opened the stranger is the only candidate
left.

The fixture key hands the auditor the claim stake and pays the row's bounty and
the re-run's. It ends the review holding nothing.

## The rehearsal on anvil

```bash
anvil
```

Stand the fixture from anvil's account 0, with account 1 named as the auditor:

```bash
FIXTURE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 FIXTURE_GENESIS_AUDITOR=0x70997970C51812dc3A010C7d01b50e0d17dc79C8 forge script exhibits/beanstalk-2022-04/review/Review.s.sol:StandTheReview --sig "stand()" --rpc-url http://127.0.0.1:8545 --broadcast --slow
```

Run the review with account 1 as the auditor and account 2 as the stranger:

```bash
FIXTURE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 AUDITOR_KEY=$(cast wallet private-key "test test test test test test test test test test test junk" 1) STRANGER_KEY=$(cast wallet private-key "test test test test test test test test test test test junk" 2) forge script exhibits/beanstalk-2022-04/review/Review.s.sol:FileTheFinding --sig "file()" --rpc-url http://127.0.0.1:8545 --broadcast --slow
```

```bash
forge script exhibits/beanstalk-2022-04/review/Review.s.sol:ReadTheReview --sig "check()" --rpc-url http://127.0.0.1:8545
```

`ReadTheReview` prints the second after which the re-run can be confirmed. Move
anvil's clock past it and confirm, with the values it printed in place of the
capitals:

```bash
cast rpc evm_setNextBlockTimestamp CONFIRM_OPENS_AFTER_PLUS_ONE --rpc-url http://127.0.0.1:8545 && cast rpc evm_mine --rpc-url http://127.0.0.1:8545
```

```bash
cast send AUDIT_CELL "confirmAudit(uint256)" RERUN_ROW --private-key $(cast wallet private-key "test test test test test test test test test test test junk" 2) --rpc-url http://127.0.0.1:8545
```

## On Base Sepolia: the operator's acts

Each of these is the operator's keystroke (VD-270). The session runs none of them.

1. **Make three fresh keys**: the fixture key, the auditor, the stranger. None is
   ever a network key, and the scripts refuse them all. Fund all three with gas
   from a faucet.
2. **Stand the fixture** from a clean tree, so the record can cite the commit
   that froze `finding.json`:

   ```bash
   git diff --quiet HEAD && STAND_COMMIT=$(git rev-parse HEAD) FIXTURE_GENESIS_AUDITOR=AUDITOR_ADDRESS forge script exhibits/beanstalk-2022-04/review/Review.s.sol:StandTheReview --sig "stand()" --rpc-url https://sepolia.base.org --broadcast --slow
   ```

3. **Commit** `../fixture/record/84532.review-stand.json`.
4. **Run the review** with `FIXTURE_KEY`, `AUDITOR_KEY` and `STRANGER_KEY` set.
   The claim has to land inside the 10 minute review window that opens when the
   auditor accepts the row, and the script sends everything in one go, so it does:

   ```bash
   forge script exhibits/beanstalk-2022-04/review/Review.s.sol:FileTheFinding --sig "file()" --rpc-url https://sepolia.base.org --broadcast --slow
   ```

5. **Commit** `../fixture/record/84532.review.json`, and the transactions from
   forge's broadcast logs:

   ```bash
   node exhibits/beanstalk-2022-04/fixture/transactions.js --review
   ```

6. **Confirm the re-run** once its window has passed. `ReadTheReview` against
   Base Sepolia prints the second. Any key with gas may send it:

   ```bash
   cast send AUDIT_CELL "confirmAudit(uint256)" RERUN_ROW --private-key $STRANGER_KEY --rpc-url https://sepolia.base.org
   ```

7. **Commit the settlement's record**, `../fixture/record/84532.review-settle.json`,
   read from its receipt: the sender, the block and its second, and the transfers
   to the auditor, the protocol and the stranger.

   ```bash
   cast receipt SETTLE_TX --json --rpc-url https://sepolia.base.org
   ```
