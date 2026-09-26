<!-- SPDX-License-Identifier: MIT -->
# The fixture — Room 2, door two

> **Exhibit fixture.** This is an instance of the DAN hull at `0f3eaf8`, deployed
> on Base Sepolia by the museum for one filing. It is not the network's cell. The
> network's cell is `0xb034F198869726c36965B95879eCB65Bdb1076c9` on Base Sepolia
> since 2026-09-13; it is this entry's provenance and holds no exhibit. The
> fixture holds no value, sits in no deployment record, and is read by no DAN tool.
> Before the filing, its admin, the museum's key, registered the gap's class and
> flagged door two's evaluator canonical.

That paragraph goes wherever the fixture's address is printed: here, on the
plaque, and on the entry's Room 2 line (VD-270(iii)). The hull needs three keys
for the filing. The fixture key takes the protocol's seat and a fresh second key
files as the discoverer (VD-273(2)), unless the operator sets
`FIXTURE_SEAT=discoverer`; the plaque says which seat it took.

Door two is the discoverer's seat. The spec gap is filed on DAN, the window
pays, the fix supersedes. The filing is a real transaction on Base, and this
directory stands the hull it lands on.

## What is in this directory

- `Fixture.s.sol` holds two scripts.
  - `StandTheFixture` deploys and wires the hull in one broadcast from a fresh
    museum key. It applies the network's own testnet profile, registers the
    network's two tools and the museum's four, flags door two's evaluator
    canonical, registers the gap's class, funds the stake, attaches the minter,
    reads everything back and writes the record.
  - `ReadTheFixture` reads the recorded fixture back from any node and sends
    nothing.
- `../Fixture.t.sol` proves the stand in memory. It shows the stake funding is
  exactly what the cell asks against a real row, and that every seat refuses
  what VD-270 refuses.
- `record/` is the museum's record of the fixture, and the only place it lives
  (VD-270(iv)). The script writes `record/84532.json` on the real broadcast.
  Dry runs and anvil rehearsals write files that git ignores.

## How it is built

The testnet profile is inherited, not copied. `StandTheFixture` extends the
hull's own `DeployCell`, so the windows, the stake floors, the spec-challenge fee
and the PC-88(a) window check are the network's, at the commit `lib/dan` points
to. Only the deploy and wiring lines are repeated, because `DeployCell.run`
reads the network's environment and writes the network's deployment record. The
fixture key takes the deployer's place in every seat.

The stake funding is minted to the fixture key once, before the minter is
attached. After that, `genesisMint` is closed for good. The amount is one row of
Room 1's bounty plus the claim stake the cell asks against such a row, read from
the cell's own getters.

The fixture refuses every key the network's deployment records name, in every
seat. The list was pulled from the cell tree with this command:

```bash
grep -hoE '"(admin|deployer|genesisAuditor|auditor[A-Za-z]*|protocol[A-Za-z]*)"\s*:\s*"0x[0-9a-fA-F]{40}"' deployments/*.json | sort -u
```

`DeployCell.run` is inherited too and cannot be overridden. Always name the
entry point with `--sig "stand()"`. Called here by mistake, `run()` sends
nothing. Without `PRIVATE_KEY` it reverts on its first line. With one set, the
simulation reverts when `run()` reaches for the network's `deployments/`, which
this tree's `fs_permissions` refuse, and forge broadcasts only after a clean
simulation. On the anvil rehearsal the stand-in key's nonce was 0 before and 0
after.

## Before any key touches Base

The hull behind `lib/dan` must be the public export at `0561a4b`, whose contracts
are the hull at `0f3eaf8` with an MIT licence line on the 8 interfaces:

```bash
git -C lib/dan diff --quiet 0561a4b -- cell/contracts cell/script/DeployCell.s.sol cell/script/EnvReads.s.sol && echo HULL-AT-0561a4b
```

The tests, in memory:

```bash
forge test --match-contract FixtureTest -vv
```

The rehearsal on anvil. Start a plain node on its default chain, 31337:

```bash
anvil
```

Stand the fixture from anvil's account 0, with account 1 named as the genesis
auditor, then read it back. The stand is sent with `--slow`, one transaction at a
time, as on Base Sepolia. Sent as one batch on 2026-09-25, anvil mined the first
eleven and left the rest queued with nothing to mine them:

```bash
FIXTURE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 FIXTURE_GENESIS_AUDITOR=0x70997970C51812dc3A010C7d01b50e0d17dc79C8 forge script exhibits/beanstalk-2022-04/fixture/Fixture.s.sol:StandTheFixture --sig "stand()" --rpc-url http://127.0.0.1:8545 --broadcast --slow
```

```bash
forge script exhibits/beanstalk-2022-04/fixture/Fixture.s.sol:ReadTheFixture --sig "check()" --rpc-url http://127.0.0.1:8545
```

## On Base Sepolia — the operator's acts

Each of these is the operator's keystroke (VD-270). The session runs none of them.

1. **The export refresh at `0f3eaf8` is public first** (VD-270(i)). It is: it
   went public on 26 September 2026 as `0561a4b`, and `lib/dan` is pinned to it.
2. **A fresh key, funded from a faucet for gas only.** It is never the network's
   deployer and never its genesis auditor. The script refuses both.
3. **The deploy.** This is the same command as the rehearsal, pointed at Base
   Sepolia, with the fresh key and the chosen auditor seat:

   ```bash
   git diff --quiet HEAD && STAND_COMMIT=$(git rev-parse HEAD) forge script exhibits/beanstalk-2022-04/fixture/Fixture.s.sol:StandTheFixture --sig "stand()" --rpc-url https://sepolia.base.org --broadcast --slow
   ```

   It runs only from a clean tree, and the record cites that commit. The stand
   freezes `../filing/gap.json` at that commit: the record holds the keccak256
   of each gap word, and the filing refuses words that differ (VD-273(4)).

4. **Basescan verification**, against the public export.
5. **The record is committed**: `record/84532.json`, with the transaction and the
   block printed by the command below, and `record/84532.admin-acts.json`, which
   the second command below writes from the same log. That file lists every
   call the fixture key made at the stand by function, transaction and block,
   the class registration and the canonical flag among them (VD-273(1)). The
   command refuses to overwrite a file that is already there.

The deploy transaction and its block are read from forge's broadcast log:

```bash
node -e "const b=require('./broadcast/Fixture.s.sol/84532/stand-latest.json');const r=Object.fromEntries(b.receipts.map(x=>[x.transactionHash,x]));for(const t of b.transactions.filter(t=>t.contractName==='AuditCell'&&t.transactionType==='CREATE'))console.log(t.contractAddress,t.hash,parseInt(r[t.hash].blockNumber,16))"
```

```bash
node -e "const b=require('./broadcast/Fixture.s.sol/84532/stand-latest.json');const r=Object.fromEntries(b.receipts.map(x=>[x.transactionHash,x]));const acts=b.transactions.filter(t=>t.transactionType==='CALL').map(t=>({contract:t.contractName,to:t.contractAddress,from:t.transaction.from,function:t.function,arguments:t.arguments,tx:t.hash,block:parseInt(r[t.hash].blockNumber,16)}));require('fs').writeFileSync('exhibits/beanstalk-2022-04/fixture/record/84532.admin-acts.json',JSON.stringify({what:'Every call the fixture key made at the stand, from forge broadcast log (VD-273(1))',acts},null,2)+String.fromCharCode(10),{flag:'wx'});console.log(acts.length,'calls written')"
```

The filing and its transaction are door two's, in `../filing/README.md`.
