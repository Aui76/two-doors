<!-- SPDX-License-Identifier: MIT -->
# Provenance

What the first room stands on. I pulled all of it on 23 September 2026, and every number below carries the
command that printed it, so you can print it again yourself.

## The specimen

Ethereum mainnet at block 14,595,905.

```
cast block 14595905 --rpc-url https://eth.drpc.org
```

Number 14595905. Hash `0x64f414df5919cdb0184d4325bcfd24a3a9046f098baf31d74029b8c9cdffc487`. Timestamp
1650106482, which is Saturday 16 April 2022 at 10:54:42 UTC.

## An archive node that still serves it

Reading state at a 2022 block needs an archive node. I asked five public endpoints for one value at that block.
One answered.

```
cast call 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 "totalSupply()(uint256)" --block 14595905 --rpc-url ENDPOINT
```

| endpoint | what it returned |
|---|---|
| `https://eth.drpc.org` | `6321754516772103012504131` |
| `https://ethereum-rpc.publicnode.com` | 403, archive requests need a personal token |
| `https://eth.llamarpc.com` | 525 |
| `https://rpc.flashbots.net` | method is not whitelisted |
| `https://eth.merkle.io` | 429 |

That value is the total supply of WETH at the block. I used WETH because its address has not moved since 2017
and you can check it against any other source in a second. One free endpoint is thin, so a paid archive key
goes in before anyone is asked to watch this run.

## The addresses

I took these from the public exploit test in DeFiHackLabs rather than from a write up or from memory.
`src/test/2022-04/Beanstalk_exp.sol`, fetched 23 September 2026, 7374 bytes, sha256
`07c9396063f71acd5e6b4e688adb7bc1ebdd1022083cb05cfc997b3312b42256`.

Its constructor reads `cheat.createSelectFork("mainnet", 14_595_905)`, so the block this museum forks at is the
block their test forks at.

| what it is | address |
|---|---|
| Beanstalk, silo and governance behind one diamond | `0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5` |
| Bean, before the replant | `0xDC59ac4FeFa32293A95889Dc396682858d52e5Db` |
| BEAN3CRV-f | `0x3a70DfA7d2262988064A2D051dd47521E43c9BdD` |
| the attacker's proposal contract, submitted as BIP 18 | `0xE5eCF73603D98A0128F05ed30506ac7A663dBb69` |

The file header says `SPDX-License-Identifier: UNLICENSED`, which belongs to the abi-to-sol stub it was
generated from. The repository is Apache 2.0 and that is the licence governing the port. The port carries
attribution and the Apache notice.

## What the verdict binds

A verdict on an address alone cannot be re-checked, because the code at an address can change. So the verdict
names the code.

```
cast code 0xC1E088fC1323b20BCBee9bd1B9fC9546db5624C5 --block 14595905 --rpc-url https://eth.drpc.org | cast keccak
```

5547 bytes, keccak `0x2ff59388cd5e1842a3d057338010945a779a6c7d57abfb5e9ddc697838700870`. That hash sits beside
the address in the verdict and never replaces it, and your own run at your own endpoint has to print the same one.

## The attacker's contract is not there yet

The same two commands, the same block, against `0xE5eCF73603D98A0128F05ed30506ac7A663dBb69`.

Zero bytes. Keccak `0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470`, the hash of empty code.

You are standing on the chain the day before the hack, with the loophole already open and nothing built on it
yet. I did not take that from the story. I measured it.
