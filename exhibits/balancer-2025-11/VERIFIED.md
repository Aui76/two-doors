<!-- SPDX-License-Identifier: MIT -->
# Balancer V2, 3 November 2025: the facts, read at their sources

This file records the fetch-and-verify that VD-307(5) requires before any room code is written. Each fact below was
read either on the chain (Ethereum mainnet, archive reads through `eth.drpc.org`, 2026-09-29) or in the source it
cites. A fact that failed at its source, or was ruled off the wall, is listed under **Ruled: VD-310**, with the reason.

## Held on the chain

| Fact | Value | How it was read |
|---|---|---|
| The Vault | `0xBA12222222228d8Ba445958a75a0704d566BF2C8` | code present at block 23,717,396 (24,512 bytes) |
| The Vault's code hash | `0x9eb70db20a41bfbf4b022fd070fa7f154b7c4aec98177120dde7a958384f4e66` | `eth_getProof` codeHash at 23,717,396; bound by `Fork.t.sol` (VD-310(1)) |
| Fork block timestamp | 1762155995 = 2025-11-03 07:46:35 UTC | `eth_getBlockByNumber(23717396)`; bound by `Fork.t.sol` |
| First drain transaction | `0x6ed07db1a9fe5c0794d44cd36081d6a6df103fab868cdd75d581e3bd23bc9742` | block 23,717,397, 07:46:47 UTC, status 1 |
| Its sender | `0x506d1f9efe24f0d47853adca907eb8d89ae03207` | receipt `from` |
| What it is | a contract creation; the created contract is `0x54b53503c0e2173df29f8da735fbd45ee8aba30d` | receipt `to` is empty, `contractAddress` set |
| What it did at the Vault | 226 `Swap` and 6 `InternalBalanceChanged` events, on two pools only | Vault logs in its receipt |
| Withdrawal | `0xd155207261712c35fa3d472ed1e51bfcd816e616dd4f517fa5959836f5b48569`, same sender, to the created contract | block 23,717,404, status true |
| Fork block (the last block before the drain) | 23,717,396 | no Vault-heavy transaction in blocks 23,717,390–396; the drain is transaction 1 of 214 in block 23,717,397, and the receipt of transaction 0 touches neither the Vault nor pool A nor pool B (receipts, not a trace), so the fork is the state the drain met; `python exhibits/fork-position.py` |
| Drained pool A | osETH/wETH `0xdacf5fa19b1f720111609043ac67a9818262850c`, poolId `…0635` | `version()` = ComposableStablePool **v5**, deployment `20230711-composable-stable-pool-v5` |
| Drained pool B | wstETH/WETH `0x93d199263632a4ef4bb438f1feb99e57b4b5f0bd`, poolId `…05c2` | same, **v5** |
| Their factory | `0xDB8d758BCb971e482B2C45f7F8a7740283A1bd3A`, ComposableStablePoolFactory **v5** | `isPoolFromFactory` true for both |
| Why V5 could not be paused | pool A's pause window ended 2023-11-28 (1701212579), pool B's 2023-10-09 (1696880027) | `getPausedState()` at 23,717,396 |
| The pause | one transaction paused 28 pools at 08:06:59 UTC: `0xd7f213ba51af09549bcb6a074d28ca0d766572e7b33c80924b14d887769f99e6`, block 23,717,497, from `0x3f2e8a2bf3237c3cb36d75e3ab8590c55e2d6f33` | `PausedStateChanged(true)` events in the block's receipts |
| The paused pools are V6 | all 14 sampled read ComposableStablePool **v6**, deployment `20240223-composable-stable-pool-v6`; pause window open until 2028-02-25 | `version()`, `getPausedState()` |

### Pool A balances (osETH/wETH), read at the Vault

| Block | WETH | osETH |
|---|---|---|
| 23,717,396 (before) | 4,922.356 | 6,851.581 |
| after the first transaction alone (run by `Transact.t.sol`) | 298.755 | 0.458 |
| 23,717,397 (end of the block) | 256.226 | 1.722 |
| 23,717,399 | 0.136 | 0.000216 |
| 23,717,404 | 0.0019 | 0.00061 |

Corrected 2026-10-01. The 256.226 / 1.722 row used to be labelled "after the first transaction". A read at a block
number is the state at the end of that block, and the drain is transaction 1 of 214 in block 23,717,397. Transaction
2 (`0x4b6b5fb9aa779c7662793a2613dca48f6e4afd15037b1acf2be4355cb032ed63`, from another sender, not a drain sender) emits
one Vault `Swap` in pool A: 1.264 osETH in, 42.529 WETH out. `Transact.t.sol` runs the drain by `vm.transact` on the
fork at 23,717,396 and prints the row above. It then runs transaction 2 and matches a second fork at 23,717,397 to
the wei. No other receipt in the block names pool A or pool B at the Vault (receipts, not a trace).

### Pool B balances (wstETH/WETH)

| Block | wstETH | WETH |
|---|---|---|
| 23,717,396 (before) | 4,270.841 | 1,977.058 |
| 23,717,397 | 10.998 | 13.219 |
| 23,717,399 | 0.000113 | 0.000229 |
| 23,717,404 | 0.00000053 | 0.00000072 |

For pool B the 23,717,397 row is both readings. The first transaction alone leaves the same balances as the end of
the block, to the wei (`Transact.t.sol`).

### The version fingerprint (VD-310(2)(A)), read at 23,717,396

| Factory | `version()` | `getCreationCode()` | keccak |
|---|---|---|---|
| `0xDB8d758BCb971e482B2C45f7F8a7740283A1bd3A` | ComposableStablePoolFactory **v5** | 32,202 bytes | `0xc970b1d539df9eb95acfd9703ef4b1c2c0faa338983d81db5958a0103ff16ed1` |
| `0x5B42eC6D40f7B7965BE5308c70e2603c0281C1E9` | ComposableStablePoolFactory **v6** | 32,204 bytes | `0x29e3a405ec588a9ec22bd4d737680c6c4be2caa019a4c53ebf783578cb365345` |

`isPoolFromFactory` is true for pools A and B against the V5 factory only, and true for the V6 pools `0xda17…c12c` and
`0x1d13…ad14` against the V6 factory only. The vault re-read this independently at the latest block before ruling and
found the same figures, to the byte.

### The paused V6 exhibit (VD-310(3)): wstETH/tETH `0x1d13531bf6344c102280ce4c458781fbf14dad14`, poolId `…06df`

ComposableStablePool **v6**, from the V6 factory, pause window open until 2028-02-25.

- None of the three drain transactions touched it. Their Vault logs name only pools A and B.
- Every Vault event on it from the fork block to the pause (23,717,396–23,717,497, read from each block's receipts)
  was one of these two:
  - a swap of 0.021076 tETH in for 0.021156 wstETH out, block 23,717,464, tx
    `0x95ee59b291a203c364ef52dd6cc9abea87d82693ccc8e976e6ec6ebeb9c14e0e`. Sent by the EOA `0x7244…b059` through the
    180-byte contract `0xb300…028d`.
  - an LP exit (`exitPool`, `0x8bdb3913`) of 2.428740 wstETH and 3.344186 tETH, block 23,717,484, tx
    `0xd39617775aefecce78050fa36aca8eb3a0f8bcb2787e273d49feb7fe1da2ee47`. The EOA `0x69d6…ce14` called the Vault
    directly for its own position.
- Together they account for the whole fall: 671.9235 → 669.4736 wstETH and 925.1362 → 921.8131 tETH. Neither sender
  is a drain sender or a contract the drain created.
- Paused at 23,717,497; balances unchanged at 23,717,600.
- **It is not the control** (VD-310(4)). It is the exhibit for "one could still be stopped". It must not be captioned
  "no one moved a token", because an LP left before the pause.

### The control (VD-310(4)): Balancer 80 BAL 20 WETH `0x5c6Ee304399DBdB9C8Ef030aB642B10820DB8F56`

- **Class:** a weighted pool, the class the post-mortem calls unaffected. `getNormalizedWeights()` = 80% / 20%;
  `isPoolFromFactory` is true on the WeightedPool2TokensFactory `0xA5bf2ddF098bb0Ef6d120C98217dD6B141c74EE0`. The pool
  has no `version()`.
- **poolId:** `0x5c6ee304399dbdb9c8ef030ab642b10820db8f56000200000000000000000014`.
- **Balances at the Vault:** 24,575,449.788602 BAL and 1,564.259547 WETH, identical at 23,717,396 and 23,717,404.
- **`lastChangeBlock`:** 23,716,619 at both blocks, so no balance-changing event touched it anywhere in the range.
- **Size:** VD-310(4) ranks the tests: not moving first, size second. Of the three weighted pools checked, this is the
  largest. With no price needed, its 1,564 WETH is its 20% side, so it is worth about 7,800 WETH. The comparison
  figures are about 64 WETH for 50 USDC 50 WETH and about 734 for 50 WBTC 50 WETH, each twice its WETH balance.
- **Not taken:**
  - 50 USDC 50 WETH `0x9664…B6f8` also sat still, but it is smaller.
  - 50 WBTC 50 WETH `0xA6F5…6dB5` moved inside the range (`lastChangeBlock` 23,717,404), so it does not qualify.

## Fork-build notes

Standing note (Cursor brief, promoted on the operator's word 2026-09-29; not a ruling, not a register row, VD-299).
On a fork, an `InvalidFEOpcode` is the local EVM refusing a precompile it does not carry — not a revert inside the
contract — and the door never mocks it. Source: foundry-rs/foundry issue 6035, "InvalidFEOpcode when simulating
Arbitrum transactions" (closed 2023-11-07), where a transaction that succeeded on-chain died in cast/anvil at
Arbitrum's `0x6c` precompile; mattsse, 2023-10-13: "this precompile is not supported by the evm foundry uses".

1. It does not touch the replay as built. The attacker's door forks Ethereum mainnet at 23,717,396; `0x6c` is an
   ArbOS precompile that does not exist on mainnet, whose precompiles are the standard set `revm` carries. This is
   reasoning from the chain — the fork build is the measurement.
2. It would touch an L2 leg. The drain also hit Arbitrum and Base. If a replay of one of those ever dies with
   `InvalidFEOpcode`, that is the EVM refusing a precompile, not the pool reverting. The L2 legs stay off the door
   until a replay is measured there.
3. Mocking is barred by the room's own rule. A mocked precompile substitutes a stand-in for the object the door reads.
   If a replay dies that way, the plaque says the replay died there and why; it never says the drain failed, and it
   never runs on a mock.

## Held in the sources

- **Root cause, Balancer's post-mortem** (18 Nov 2025,
  <https://medium.com/balancer-protocol/nov-3-exploit-post-mortem-51dcbeb6b020>): "incorrect rounding in the 'exact
  out' swap path for Stable Pools." Its timeline gives 07:46 UTC for the first transactions and 08:07 UTC for the V6
  pause; the chain agrees (07:46:47, 08:06:59).
- **"Vulnerable too", in the post-mortem's own words:** "Vulnerable V6 Composable Stable Pools (CSPv6) were still
  within their pause windows."
- **The control's class, in the post-mortem's own words:** "On V2, all variants of Weighted Pools, Gyro Pools, and
  other types of Stable Pools were unaffected by this exploit."
- **The three preconditions, in the post-mortem's own words** (read 2026-09-29 from Balancer's Medium RSS feed, since
  the article page returns 403): "This exploit required three preconditions: 1) the underlying rounding error in exact
  out swaps; 2) rate providers, to introduce imprecision in the math; and 3) a low liquidity state, required to
  magnify the imprecision enough to be exploitable." This is Balancer's own sentence joining the rate provider to the
  exploit (VD-312(2)).
- **Where the rounding enters, in the same text:** "In `_swapGivenOut`, the amountOut is adjusted for the token decimals
  and rate, then rounded down by `_upscale` before being passed into the calculation. … StableMath's mechanics cause
  the amountIn to be rounded down as well." The error enters at `_upscale`, and StableMath carries it into amountIn.
  For VD-312(1)'s sentence test: StableMath is in the mechanism, but it is not where the error enters.
- **Why other pools were safe, in the same text:** "Weighted Pools do not have rate providers, and also use completely
  different math." This supports the control.
- **Why a V5 window closes:** the post-mortem does not say. Under VD-310(3) the room stays with the timestamps.
- **Audited, then widened, OpenZeppelin** (7 Nov 2025,
  <https://www.openzeppelin.com/news/understanding-the-balancer-v2-exploit>): the pools it audited, StablePool and
  WeightedPool, "did not contain the `_scalingFactors` override". MetaStablePool added that override on 16 Jul 2021
  (commit 059284e). PhantomStablePool, later renamed ComposableStablePool, was added on 20 Sep 2021, outside the
  engagement. The lesson holds. The widening came as new contracts beside the audited ones, not as edits to them.

## Ruled: VD-310 (vault commit 619e434, 2026-09-29). Room code may be written

1. **Off:** the comparison of a V5 pool's code hash with a V6 pool's. A pool's own runtime hash can stay on its plaque
   only as identity ("this is that pool"), captioned as such, never as a version. The Vault's code hash stays.
   (Every pool's hash is its own, because its constructor writes its tokens, rate providers and scaling factors into
   its code. The two drained V5 pools hash to `0x72b6e1b1…` and `0x070e5629…`. Both are 24,280 bytes; the vault's
   re-read at the latest block counted 164 bytes that differ.)
2. **On, both together, neither alone:** (A) the factory creation-code fingerprint above, and (B) `version()` and
   `getPausedState()`, with the window ends (2023-11-28 and 2023-10-09 against 2028-02-25) and the 08:06:59 pause
   transaction.
3. **The second fact goes beside "audited, then widened":** same bug, two bytes of creation code apart, one could still
   be stopped. The sentence test: no plaque says or implies "V6 was fixed" or "the fix". "Vulnerable too" is cited
   in the post-mortem's words above.
4. **The control is a weighted pool** that did not move between 23,717,396 and 23,717,404. Settled above.
5. **Off the wall:**
   - The second and third transactions, `0x1dc60f91…d4b87` (block 23,717,398, from `0x5af00b07…c972`) and
     `0xe1d5f36f…a1eb1` (block 23,717,399, from `0x7bb28442…87fa4fb`). The room names only the first sender.
   - **No dollar figure on any plaque** (VD-307(2)). For the record, the published figures disagree, and the
     post-mortem disagrees with itself: $94.8M (its intro) against $121.1M (its Financial Impact section). Others:
     $128.64M (PeckShield, repeated by Check Point and Rekt), $125M+ (BlockSec, QuillAudits), $120M+ (OpenZeppelin)
     and $116.6M (Lookonchain).
   - **Start time:** OpenZeppelin writes "around 7:40 AM UTC". The room uses the chain's 07:46:47.
   - ~~**TOB-BALANCER-004** is not in the room for the wire.~~ **Reversed by VD-311** (below).

## Ruled: VD-311 (vault commit 2265d7e, 2026-09-29). The room tells both halves

The vault read the 2021 report in full (36 pages) before ruling, and each quote below held there word for word.

1. **The order the room tells it in:**
   1. audited (OpenZeppelin);
   2. widened (the override was added in new contracts outside that engagement);
   3. audited again (Trail of Bits, with the phantom pool in scope within weeks);
   4. flagged (a rounding direction, on a function the report says every pool shares, at a severity the auditor
      could not determine);
   5. left open (missing from the follow-up's fix list, with more rounding issues marked for investigation);
   6. four years later, the same direction on the exact-out path (post-mortem: "rounded down by `_upscale`").

   The lesson: paid checkers looked twice. The second wrote the gap down and could not price it, and a finding without
   a price has no owner.
2. **On the plaque, as objects:** the finding ID, its title, the severity and difficulty line, the target, and the
   link into Balancer's monorepo. Quotes stay short and attributed. The three quotes below are the most the plaque
   may carry.
3. **The discoverer's door gains its ancestor.** It may say "this spec existed in a PDF in 2021; this door files it
   where it can be checked and priced." VD-307's sentence test still applies: no "DAN would have caught this".
4. **Sentence tests at acceptance.** Every plaque is checked against each of these:
   - The scope line is the report's own: the phantom pool was reviewed "focusing on its fee structure and integration
     with the stable pool mechanism". Never a flat "ComposableStablePool was audited".
   - Finding 4's target is `LinearMath.sol`. Its reach to every pool is the report's single sentence about
     `_upscaleArray`. No plaque says "Trail of Bits flagged the ComposableStablePool bug".
   - "Left open" means "not among the fixes the report's own follow-up lists", never "never fixed" as a claim about
     the whole codebase.
   - No plaque says "the auditors missed it". The room's point is that they did not.
   - Trail of Bits' 2025 "same vulnerability that we reported" is printed as their claim, attributed, beside the
     post-mortem's `_upscale` sentence, which is what actually closes the chain.
5. **The 2022 scope line** reaches a plaque only once the 2022 report has been read. It has now been read (below);
   VD-312 rules its use.

## Ruled: VD-312 (vault commit 9a15d4e, 2026-09-29). The 2022 review goes on the wall as its own list

The vault read the 2022 report in full before ruling, and every quote below held there word for word.

1. **The coverage-limitations list is printed whole**, or at least its two lines that meet the post-mortem:
   "only partially covered the base components (e.g., BasePool)" and "did not look for issues … third-party
   integrations (e.g., the rate provider)". The StableMath line goes **beside** them, never in front. Sentence test:
   no plaque says or implies "the bug was in the out-of-scope library".
2. **The rate-provider link.** OpenZeppelin's widening line and Trail of Bits' exclusion line may sit side by side.
   Any sentence that joins them reaches the wall only in OpenZeppelin's or Balancer's own quoted words. The
   post-mortem's three-preconditions sentence (under "Held in the sources") is Balancer's own words, so it qualifies.
3. **Both 2021 precisions are accepted.** "we did not identify any significant risks or issues caused by their rounding
   operations" joins the quotes the plaque may carry. Appendix G's issues are "more rounding issues in the same
   family", never "the same function".
4. **The lesson stops counting audits.** No plaque gives a number of audits until every review the index maps to V5 has
   been read. A plaque names the looks that were read and says "at least", or names none. The lesson line: *paid
   checkers looked, and looked again; the second wrote the gap down and could not price it; the third wrote its
   boundary down and the gap sat on the other side of it; a finding without a price has no owner, and neither does
   the far side of a boundary.*
5. **Reopens if:** the Certora review is read and covers base-component rounding (the lesson line would move again);
   the post-mortem contradicts the `_upscale` placement; or the operator says so. The Certora review has now been
   read (below). VD-313 rules it.

## Ruled: VD-313 (vault commit c8907d5, 2026-09-29). Certora is the fourth look

1. **The post-mortem's three-preconditions sentence joins** the first look's widening (the scaling-factor override) to
   the third look's exclusion (the rate provider not examined). It is quoted, with nothing added. The sentence test
   becomes: the error **enters** at `_upscale` and StableMath **carries** it. No plaque says "the bug was in the
   out-of-scope library", and none says "StableMath had nothing to do with it". The plaque prints the post-mortem's
   own two-clause sentence and stops. The control's caption may quote "Weighted Pools do not have rate providers, and
   also use completely different math".
2. **Certora is the fourth look, and the lesson absorbs it.** The lesson line: *paid checkers looked, and looked again;
   the second wrote the gap down and could not price it; the third and fourth wrote their boundaries down and the gap
   sat on the other side of both; a finding without a price has no owner, and neither does the far side of a
   boundary.*
   Sentence tests for Certora's lines:
   - "unable to prove" is not "false".
   - `noFreeMinting` reaches a plaque only with its own stated reason attached, never as a wink at the drain.
   - No plaque says the prover missed the bug, or found it. The plaque is the report's own account: it never looked
     at a rounding direction, a scale or a rate.
3. **Index line 19 is irrelevant. Line 14** was ruled unable to change the lesson because of its date, but able to
   change the count. "At least" stands until line 14 is read. It reopens only if line 14 covers the composable pool's
   scaling. Line 14 has now been read (below): it does not cover scaling, but it has a finding on the in-given-out
   rounding. **Reversed by VD-314.**

## Ruled: VD-314 (vault commit 3adaa1d, 2026-09-29). TOB-BALANCER-007 goes on the wall

The vault read the April 2021 report in full (64 pages) before ruling.

1. **How a look is classed.** A look is classed by which half of the post-mortem's sentence it wrote down: where the
   error enters (`_upscale`) or what carries it (StableMath). Its date sorts it and never excludes it. Line 14 is a
   written look at the **carrying** half, and the index maps it to Stable V5.
2. **What 007 is.**
   - It looks at the post-mortem's first precondition (rounding in exact-out swaps). Its exploit scenario stands at
     the third (one-wei balances, that is, low liquidity).
   - It is priced Medium for what it could reach and names the remainder it could not.
   - It is not finding 004. 004 wrote the entering half at Undetermined; 007 wrote the carrying half at Medium, with a
     named remainder. Same firm, six months apart, different functions, and no source read here puts the two on one
     page.
   - Rate providers (the second precondition) appear in no pre-drain source that has been read. Sentence test: no
     plaque says or implies "all three preconditions were known".
3. **On the plaque:** the ID, title, severity and difficulty line, target and link.
   - Quote ceiling: the description sentence and the large-balances sentence. The large-balances sentence also
     appears word for word in 006 and 008, so it is never presented as unique to 007.
   - The three exploit-scenario balances (20,369; 17,465,037,809; 1) may be printed as numbers.
   - Sentence tests:
     - no "Trail of Bits found this bug in 2021";
     - 007 appears in its own words only, beside the post-mortem's sentence, and the join is the visitor's to make;
     - no "left open" for 007, because this report has no fix list to be absent from;
     - no "the same finding" between 007 and 004 (same family, different half);
     - the 2025 blog's "same vulnerability that we reported" stays attributed and is not made to say which report.
4. **The lesson line drops its ordinals.** OpenZeppelin's March 2021 review (index row 13) predates 007, so nothing is
   "first" or "second". "Could not price it" stays with 004. The line: *paid checkers looked, and looked again, and
   again; one wrote the carrying half down, reached it only at dust and named the edge case it could not reach; one
   wrote the entering half down and could not price it; two wrote their boundaries down and the gap sat on the other
   side of both; a finding without a price has no owner, and neither does the far side of a boundary, nor the
   remainder a priced finding names and cannot reach.*
5. **"At least" stands, on a new ground.** The April report's summary names a January 2021 Trail of Bits audit
   (verbatim: "six person-weeks in January 2021. During that audit, 17 issues were found, including 7 related to
   rounding. Appendix H contains our rounding recommendations resulting from this initial audit"). No row in
   `audits/README.md` lists it. It is unindexed, unread and uncounted. Reopens if that January report is found.
6. **The discoverer's door's ancestor** is two lines: April 2021's "appropriate rounding direction" and October 2021's
   "directions that benefit the pool". The same property, covering both halves.

## Held in the sources: Trail of Bits 2021, read at the report (2026-09-29; on the wall under VD-311)

- **The report:** "Linear and Phantom Pools Security Assessment",
  <https://github.com/balancer/balancer-v2-monorepo/blob/master/audits/trail-of-bits/2021-10-08.pdf>. Engagement
  27 Sep – 8 Oct 2021. Initial report 28 Oct 2021; Appendix G added 22 Dec 2021.
- **Scope:** in its second week the engagement "reviewed the StablePhantomPool contract, focusing on its fee structure
  and integration with the stable pool mechanism". StablePhantomPool is the pool later renamed ComposableStablePool.
- **TOB-BALANCER-004, "Risks associated with rounding operations":** severity Undetermined, difficulty Low, target
  `LinearMath.sol`.
  - It shows `BasePool._upscaleArray` rounding down (`mulDown`) and says the function "is used similarly in all
    Balancer pools".
  - It says an attacker "could use them to turn a profit". The same paragraph also says the auditors "did not
    identify any significant risks or issues caused by their rounding operations". Flagged, but not priced.
  - The recommendation: rounding "directions that benefit the pool".
- **Appendix G:** it lists the fixes that were made, and none names finding 004. It also reports "additional
  arithmetics issues that require further investigation". The examples it lists are the linear pool's nominal/real
  conversions (`fromNominal`, `toNominal`), not `_upscaleArray`.
- **The fuzzer:** "Trail of Bits strongly recommends using Balancer's internal differential fuzzer to check the pools'
  arithmetics before deploying the contracts."
- **The post-mortem's step:** the amount is "rounded down by `_upscale`" on the exact-out path. This is the sentence
  that closes the chain (VD-311(4)).
- **The blog** (7 Nov 2025, Miller, Samuels, Naik): the drained pools "were exploited using the same vulnerability that
  we reported in our audit". Printed as their claim, attributed.

## Held in the sources: Trail of Bits 2022, Composable Stable Pool (read 2026-09-29; on the wall under VD-312)

- **The report:** "Balancer Composable Stable Pool Security Assessment", 22 Sep 2022, by Feist, Grieco and Khan.
  <https://github.com/balancer/balancer-v2-monorepo/blob/master/audits/trail-of-bits/2022-09-02.pdf>, 45 pages.
  Engagement 22 Aug – 2 Sep 2022. Target `pkg/pool-stable/contracts/ComposableStablePool.sol` at commit `3774c9c3`.
  The monorepo's `audits/README.md` maps this report to deployment **V5**, the version that was drained.
- **The blog's claim holds at the report:** "We did not cover the StableMath and WordCodec libraries, which were
  explicitly marked as out of scope."
- **More from the same section:**
  - "We only partially covered the base components (e.g., BasePool)."
  - It took as an assumption that "the arithmetic operations and invariants implemented in the StableMath library are
    correct".
  - It "did not look for issues that could arise from the use of … third-party integrations (e.g., the rate
    provider)".
  - It "did not look for complex arbitraging opportunities".
- **Rounding:** the report never uses the word "round" outside its boilerplate and never names `_upscale`.
- **Caution for the sentence test:** the post-mortem puts the rounding in `_upscale`, not in the StableMath library.
  Read alone, the out-of-scope line could suggest the buggy code was the excluded part, and the record does not
  show that. The report's own words that come nearest to the site are the partial coverage of BasePool and the
  unexamined rate provider. Adopted as VD-312(1).

## Read at the report: Certora 2022, Composable Stable Pool (2026-09-29; its plaque use is the vault's to rule)

- **The report:** "StablePool Verification (June – September 2022)",
  <https://github.com/balancer/balancer-v2-monorepo/blob/master/audits/certora/2022-09-23.pdf>, 12 pages, Certora Prover
  plus a manual review by two researchers. The work ran 21 June – 23 September 2022; the latest commit reviewed was
  `af9e9eb`. Scope: `ComposableStablePool.sol`, `StablePool.sol`, `WordCodec.sol`. `audits/README.md` line 20 maps it
  to **V5**.
- **Rounding:** the word "round" does not appear anywhere in the report.
- **How the arithmetic was modelled.** For ComposableStablePool:
  - "we replaced the StableMath Library with the contract StableMathHarness.sol", with `_calcOutGivenIn()` and
    `_calcInGivenOut()` among the functions replaced "to return arbitrary, but consistent values".
  - `_upscaleArray()`, `_downscaleUp()`, `_downscaleUpArray()`, `_downscaleDownArray()` and `getRate()` "have been set
    to return nondeterministic values for the sake of simplification".
  - So the prover never saw a rounding direction, a scaling factor or a rate. The single-token `_upscale` that the
    post-mortem names is not mentioned anywhere.
- **What it proved.** The ComposableStablePool rules are about pausing, recovery mode, amplification-factor updates,
  BPT initialisation and zero-address BPT. One rule, `noFreeMinting` ("The total supply of BPT must not increase if the
  total tokens held by the pool don't increase"), is marked: "We were unable to prove this rule on ComposableStablePool
  due to the increased number of minimum tokens in the pool."
- **Its own boundary:** "the guarantees of the Certora Prover are scoped to the provided specification, and the Certora
  Prover does not check any cases not covered by the specification."
- **Found:** three issues, all Low or Informational (recovery mode twice, and an amplification-update DoS). None
  concerns rounding.
- **Answer to VD-312's reopen condition:** the review does not cover base-component rounding. It set the scaling
  helpers to nondeterministic values. For the lesson line this is a fourth look whose boundary is written down, with
  the gap again on the far side of it. The ruling on it is the vault's.
- **The index's other V5 rows:** line 14 (read below) and line 19, Trail of Bits `2022-05-27` for the Batch Relayer,
  marked "V5, V6". Line 19 is the relayer's own version line, and VD-313(3) ruled it irrelevant.

## Held in the sources: Trail of Bits, April 2021, index line 14 (read 2026-09-29; on the wall under VD-314)

- **The report:** "Balancer V2 Security Assessment", 5 April 2021, by Feist and Remie.
  <https://github.com/balancer/balancer-v2-monorepo/blob/master/audits/trail-of-bits/2021-04-02.pdf>, 64 pages.
  - Engagement 22 March – 2 April 2021, commits `2c84113` and `bce652f` of `balancer-core-v2`.
  - Index line 14: "Vault, Weighted Pool, Stable Pool", marked "Vault; Stable V5".
  - It records an earlier Trail of Bits audit of the project, six person-weeks in January 2021, not in the index
    (VD-314(5)).
  - Its second week "used Echidna to check for rounding errors in the math contracts used by the pools, with a focus
    on the stable pool".
- **TOB-BALANCER-007, "StableMath._calcInGivenOut may allow free swaps":** severity Medium, difficulty High, target
  `StableMath.sol`.
  - "The in-given-out function has rounding to calculate swaps, which could enable an attacker to obtain tokens at no
    cost."
  - "we were not able to generate free tokens with large balances. However, that might still be possible in certain
    edge cases." (The same sentence appears word for word in 006 and 008.)
  - The exploit scenario is wei-scale: 20,368 wei for free, with one balance of 1.
  - Recommendation: "ensure that every function uses the appropriate rounding direction."
  - TOB-BALANCER-006 is the same for `_calcOutGivenIn`. TOB-BALANCER-008 is the same for
    `_calcTokenInGivenExactBptOut` ("may allow an attacker to join for free").
- **Appendix H, "Fixed-Point Rounding Recommendations":** "We recommended applying a strategy of rounding down or up
  such that the operations are always beneficial to the pool." Its worked example of "Determining the Rounding
  Direction" is `_inGivenOut`, and it says "The same analysis can be applied in all of the system's formulas."
- **What it does not contain:** scaling factors, `_upscale`, rate providers, any composable or phantom pool, or a fix
  log. The word "fixed" appears 3 times; none is a fix status for 007.
- **Where it sits in the chain.** The code predates the override (16 Jul 2021) and the phantom pool (20 Sep 2021), and
  the finding's target is StableMath, the part the post-mortem says carries the error, not where it enters. It is a
  first look at rounding direction on the exact-out math, at wei scale in a small-balance state. Separately, the
  post-mortem's third precondition is "a low liquidity state, required to magnify the imprecision".
- **Sentence tests to propose:**
  - No plaque says "Trail of Bits found this bug in 2021", or links 007 to the drain in anything but the report's and
    the post-mortem's own words, side by side.
  - Whether 007 was fixed is not in this report, so no plaque says "left open" of it.
- **The count:** with line 14 read, every index row that maps to V5 has been read except line 19, which was ruled
  irrelevant. The January 2021 audit this report mentions is not in the index and has not been read. This file gives
  no count; VD-312(4) decides whether any count goes on a plaque.
