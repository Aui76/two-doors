<!-- SPDX-License-Identifier: MIT -->
# The exit, the empty pedestal

Run the check yourself, on any contract you like:

```
node exhibits/exit/dan-check/dan-check.mjs --cell 0xb034F198869726c36965B95879eCB65Bdb1076c9 --home-rpc https://sepolia.base.org --deep --target 0xYOURS
```

Put any address after `--target`. If it lives on a chain other than Base Sepolia, add `--target-rpc` with an
endpoint for that chain. You need Node 18 or later, and nothing else. I ran it on 24.3.0. The tool has no
dependencies, it only reads, and it writes nothing anywhere.

## What it can tell you

It hashes the code at your address on your chain, then asks DAN's cell on Base Sepolia whether a settled row
carries that hash. There are three answers, and each has its exit code.

CLEAN is exit 0. A row passed that exact code, and the window for anyone to claim a flaw closed with no claim.

REFUSE is exit 1. No row carries the hash, or the address has no code, or it is an EIP-7702 delegation (the tool
names the delegate to ask about instead), or the row went bad: a claim is open, it was exploited, or it was
invalidated.

CANNOT VERIFY is exit 2. A read failed, or the audit hasn't reached a verdict, or its window is still open, or
the row is about the same code on a different chain than the one you asked about. The tool won't carry a verdict
across chains by itself.

CLEAN never means safe. It means the row settled and nobody had claimed a flaw as of the block it prints, and
the code can still be claimed against after that.

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

So the pedestal is empty. A story the record can already show does not get a frame. An address with a settled
row reads CLEAN, and the row is its record. The pedestal is for the address with no row, and today that is
almost any address you try. It comes back REFUSE because nobody has filed a row for it yet, and the tool says
that instead of guessing. The rows the rooms file sit on local forks, in memory and on the museum's own
fixtures, so this cell doesn't know about them. The first row with your contract's hash in it gets there when
someone files it and an auditor passes it, the way Room 2 does on its fork.

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
