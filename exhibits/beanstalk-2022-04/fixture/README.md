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

Door two is the discoverer's seat. The discoverer files the spec gap on DAN with
a stake, and if the protocol stays silent the stake comes back. The filing is a
real transaction on Base Sepolia, and this directory stands the hull it lands on.
What the filing moved is on the plaque, in `../filing/README.md`.

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
- `verify.py` verifies the sixteen contracts on Basescan. It compiles each one
  here first and submits only what equals the bytes the stand sent.
- `transactions.js` writes `record/84532.transactions.json`, every transaction
  the stand and the filing sent, from forge's broadcast logs, which git ignores.

## How it is built

The testnet profile is inherited, not copied. `StandTheFixture` extends the
hull's own `DeployCell`, so the windows, the stake floors, the spec-challenge fee
and the PC-88(a) window check are the network's, at the commit `deps/dan` points
to. Only the deploy and wiring lines are repeated, because `DeployCell.run`
reads the network's environment and writes the network's deployment record. The
fixture key takes the deployer's place in every seat.

The stake funding is minted to the fixture key once, before the minter is
attached. After that, `genesisMint` is closed for good. The amount is one row of
Room 1's bounty plus the claim stake the cell asks against such a row, read from
the cell's own getters.

The fixture refuses every key the network has used, in every seat. The list is
every address in the network repo's tracked `cell/` and `body/` records that
holds no contract code and has sent a transaction on Base Sepolia. Run from the
network repo:

```bash
git ls-files 'cell/*.json' 'body/*.json' | xargs grep -ohiE '0x[0-9a-fA-F]{40}' | tr A-F a-f | sort -u | while read a; do c=$(cast code $a --rpc-url https://sepolia.base.org); case $c in 0x|0xef0100*) n=$(cast nonce $a --rpc-url https://sepolia.base.org); [ "$n" -gt 0 ] && echo $a $n;; esac; done
```

A delegated key (EIP-7702, code starting `0xef0100`) is still a key. On
27 September 2026 the command printed 13 lines. Eleven are the network's keys, and
the fixture refuses them. The other two are not the network's: the zero address, and anvil's first dev key
`0xf39F…2266`, whose private key is public and which the rehearsal below uses.
The list also refuses two addresses the command cannot see: the live cell itself,
and `0x75A2…8bFe`, the deployer of the network's local rehearsal, which has
never sent a transaction on Base Sepolia.

The first list, of 25 September, matched five field names in `cell/deployments`
alone. It missed four keys. Three sit in the same folder under other roles
(`originalAuditor`, `gapFiler`, `disputeAuditor`, `canonAuditor`,
`assignedAuditor`). The fourth is the predecessor's admin after its rotation,
named in `body/`. Asking the chain which addresses have sent transactions does
not depend on how a record names its fields.

`DeployCell.run` is inherited too and cannot be overridden. Always name the
entry point with `--sig "stand()"`. Called here by mistake, `run()` sends
nothing. Without `PRIVATE_KEY` it reverts on its first line. With one set, the
simulation reverts when `run()` reaches for the network's `deployments/`, which
this tree's `fs_permissions` refuse, and forge broadcasts only after a clean
simulation. On the anvil rehearsal the stand-in key's nonce was 0 before and 0
after.

## Before any key touches Base

The hull behind `deps/dan` must hold the public export's contracts at `0561a4b`,
which are the hull at `0f3eaf8` with an MIT licence line on the 8 interfaces. The
submodule is pinned at `5f2012b`, three commits later, and none of the three
touches these files:

```bash
git -C deps/dan diff --quiet 0561a4b -- cell/contracts cell/script/DeployCell.s.sol cell/script/EnvReads.s.sol && echo HULL-AT-0561a4b
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
   went public on 26 September 2026 as `0561a4b`, and the fixture on Base Sepolia
   was stood with `lib/dan` pinned to it.
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

4. **Basescan verification**, against the public export. The hull is built with
   via_ir, and under via_ir a contract's code depends on every source compiled
   beside it. DAN found this on its own cell on 13 September 2026:
   `forge verify-contract` submits only the target's imports, and Basescan
   refused CellLogicLib. `verify.py` rebuilds each input from the build that
   deployed the fixture, compiles it with the same solc, and submits a contract
   only when that compile equals the creation code in forge's broadcast log. The
   key is an Etherscan API key, read from `BASESCAN_API_KEY`:

   ```bash
   python exhibits/beanstalk-2022-04/fixture/verify.py --check
   python exhibits/beanstalk-2022-04/fixture/verify.py
   ```

   The first command is the local proof and sends nothing.

   I ran it on 27 September 2026 and Basescan verified 15 of the 16. AuditCell
   is the one it did not verify. The only input I found that reproduces its
   deployed code is the 59 sources the stand's build numbered at or before it,
   with their imports.
   The museum's own files sort before the hull, and the stand script, the filing
   script and the two tests among them pull in forge-std, so that input is
   1.4 MB. I tried smaller sets here and none compiled to the deployed body.
   Basescan answered "Other Exception" to the 59 sources twice. Here, solc
   compiles AuditCell from them in 14 seconds. Asked for every contract in the
   same input, it was still running after 25 minutes, and I stopped it. DAN got
   the same answer on 13 September 2026 when it sent CellLogicLib as 2.1 MB, and
   Basescan passed CellLogicLib from 17 sources. So AuditCell stays unverified on Basescan.

   I ran that proof on my own machine at `86781e1`, and a clone cannot rerun it.
   `verify.py` reads the creation code from forge's broadcast log, which git
   ignores. The tree has moved since as well. `062ba6c` changed the filing
   script, which sorted ahead of the hull, and AuditCell's body moved with it.
   Then the hull moved from `lib/` to `deps/`, which changes every contract's
   metadata.

   The move to `deps/` is for the next stand. With the hull ahead of the
   museum's own files, AuditCell compiles from its 14 sources, 188 KB and no
   forge-std, to the same body as the hull built alone. I measured that on
   28 September 2026 with the stand's settings, against the files the stand
   was built from.
5. **The record is committed**: `record/84532.json`, which the stand wrote, and
   `record/84532.admin-acts.json`, which the second command below writes from
   forge's broadcast log. That file lists every call the fixture key made at the
   stand by function, transaction and block, the class registration and the
   canonical flag among them (VD-273(1)). The command refuses to overwrite a
   file that is already there. The deploy transactions and their blocks went in
   later, with the filing's, in `record/84532.transactions.json`, which
   `transactions.js` writes from both broadcast logs (`../filing/README.md`,
   step 5).

The deploy transaction and its block are read from forge's broadcast log:

```bash
node -e "const b=require('./broadcast/Fixture.s.sol/84532/stand-latest.json');const r=Object.fromEntries(b.receipts.map(x=>[x.transactionHash,x]));for(const t of b.transactions.filter(t=>t.contractName==='AuditCell'&&t.transactionType==='CREATE'))console.log(t.contractAddress,t.hash,parseInt(r[t.hash].blockNumber,16))"
```

```bash
node -e "const b=require('./broadcast/Fixture.s.sol/84532/stand-latest.json');const r=Object.fromEntries(b.receipts.map(x=>[x.transactionHash,x]));const acts=b.transactions.filter(t=>t.transactionType==='CALL').map(t=>({contract:t.contractName,to:t.contractAddress,from:t.transaction.from,function:t.function,arguments:t.arguments,tx:t.hash,block:parseInt(r[t.hash].blockNumber,16)}));require('fs').writeFileSync('exhibits/beanstalk-2022-04/fixture/record/84532.admin-acts.json',JSON.stringify({what:'Every call the fixture key made at the stand, from forge broadcast log (VD-273(1))',acts},null,2)+String.fromCharCode(10),{flag:'wx'});console.log(acts.length,'calls written')"
```

The filing and its transaction are door two's, in `../filing/README.md`.
