<!-- SPDX-License-Identifier: MIT -->
# The exit, the empty pedestal

This is the last stop, and the only one that isn't in the past. The three rooms went back to old hacks, on
copies of Ethereum at the block before each one. Here you take DAN's own check home and point it at any contract
that exists today.

It answers one question: has an auditor on DAN passed this exact code? It reads the code at the address you give
it, hashes it, and asks DAN's live cell on Base Sepolia whether a settled audit carries that hash. It only reads
and writes nothing anywhere. You need Node 18 or later and nothing else. I ran it on 24.3.0.

```
node exhibits/exit/dan-check/dan-check.mjs --cell 0xb034F198869726c36965B95879eCB65Bdb1076c9 --home-rpc https://sepolia.base.org --deep --target 0xYOURS
```

Put the address after `--target`. If the contract lives on another chain, add `--target-rpc` with an endpoint
for that chain. You get one of three answers.

- **CLEAN**: an auditor passed this exact code, and the window for anyone to claim a flaw in it closed with no claim.
- **REFUSE**: nobody has passed this code, or there is no code at the address, or a claim against it is open, it was proved exploited, or its audit was invalidated. If the address is an EIP-7702 delegation, the tool names the contract it points to, so you can ask about that one.
- **CANNOT VERIFY**: the tool couldn't get an answer. A read failed, the audit is still running, its window is still open, or the only audit of this code is on a different chain.

CLEAN does not mean safe. It means the code kept the promise its owner wrote down, the spec, and nobody showed
otherwise in time. Room 1 is about a promise that left something out: Beanstalk's code kept every rule it was
given and was drained anyway. The check can't see past the spec either, and anyone can still claim a flaw
against the code after it reads CLEAN.

Today you will mostly get REFUSE. The live cell has audited one contract so far, the one it was started with,
`0xE546193fc52faa37413ab74d72092005115F4691`, and that address reads CLEAN. Ask about the Bybit wallet from
Room 2 and you get REFUSE, because nobody ever filed it. The audits in the rooms run on local copies of the
chain and on the museum's own test fixtures, so the live cell has never heard of them. That is why this room
is an empty pedestal. The first thing on it will be a real contract that someone files on DAN and an auditor
passes.

The test below checks that the tool you take home is the network's own. It hashes the tool's two files and
fails if one byte differs from the copy in DAN's public repository.

## What I got, 25 September 2026

The cell has filed one row. `nextAuditId` reads 1, and row 0 is the audit the cell was started with, of
`0xE546193fc52faa37413ab74d72092005115F4691` on Base Sepolia:

```
  CLEAN — audit #0, state InBlock (settled and the adversarial window has closed)
  codehash 0x2c2275fb4f36286144977d6213e37209231dbb39bb3762bee0faa21068e1cc17
  [dan-check/1] home chain 84532 @ block 0x2d18105 · computed 2026-09-25T11:54:19Z
```

The Bybit wallet from Room 2, asked on mainnet with `--target-rpc https://eth.drpc.org`:

```
  REFUSE: no settled audit reachable for this codehash
  Deep scan complete: all 1 of 1 rows read, none carries this artifactHash — NEVER AUDITED.
```

The cell itself gets the same answer, and so does an address with no code at all (`REFUSE: target has no
code`). The dashes in those lines are the tool's own output.

## Where the tool came from

The two files in `dan-check/` are DAN's own, copied byte for byte from the public repository
[`Aui76/decentralized-audit-network`](https://github.com/Aui76/decentralized-audit-network) at commit `0561a4b`.
`tools/dan-check.mjs` is 34,152 bytes, sha256 `f009360f507b50e7d2703c6251abf061b94905b15430486a410bb1f84a696d85`,
and `tools/keccak256.mjs` is 4,494 bytes, sha256 `195c078551e580b099ccdc49a15212373d3eb31f87649aded1b8d3dc1922824b`.
You can check both against GitHub yourself:

```
curl -s https://raw.githubusercontent.com/Aui76/decentralized-audit-network/0561a4b/tools/dan-check.mjs | sha256sum
```

This version of the tool has the fix for row 0, the first row any cell files. Before it, the tool said a
contract had never been audited when its row was row 0. I test the tool against that case in my private
tree, where it is built. That test file isn't in the public repo, because it reads paths that only exist
there, so no command in this tree prints its count.

`Exit.t.sol` hashes both files again and fails if one byte has moved. When I changed one character in
`dan-check.mjs`, it went red. Room 2 and the verdict on file run this same copy, so the tool the rooms were read with is the
tool you leave with.

```
forge test --match-path "exhibits/exit/*" -vv
```

The files are MIT, like the rest of this tree. The network's licence rule keeps everything that changes a
verdict, a payout or an audit's state under BUSL, and this tool changes none of them.
