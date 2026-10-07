<!-- SPDX-License-Identifier: MIT -->
# Attribution — the replay is a port with credit

The replay in this directory is a port of the public exploit test carried by
**DeFiHackLabs**, `src/test/2022-04/Beanstalk_exp.sol`.

- Source repository: DeFiHackLabs (https://github.com/SunWeb3Sec/DeFiHackLabs)
- Licence governing the port: **Apache-2.0** (the repository's licence). The file
  header reads `SPDX-License-Identifier: UNLICENSED`; that belongs to the
  abi-to-sol interface stub the file was generated against, not to the test. The
  repository licence governs (read 2026-09-19, VD-240).
- File fetched 23 September 2026: 7374 bytes,
  sha256 `07c9396063f71acd5e6b4e688adb7bc1ebdd1022083cb05cfc997b3312b42256`.
- Its constructor forks at the same block this museum forks at:
  `createSelectFork("mainnet", 14_595_905)`.

DeFiHackLabs' own licence file is carried beside the port as `LICENSE`, byte for byte
(fetched 2026-10-07 from the repository's `main`: 11,347 bytes, sha256
`aa728951f2cd7399efd5fcb214cde9e8c12a4ebb3cf08222e7256b933a102bae`). The repository has no
NOTICE file to carry. `Replay.t.sol` is changed from the original, and says so at its top:
the imports, and the lines marked `museum:`, both listed in `README.md`. Every room that
shows the replay credits DeFiHackLabs by name.

This is not new. It is a hack from April 2022, on-chain and permanent, replayed
against a frozen snapshot of history on a fork — a replay a public repository has
carried for years. It steals from nobody and hands nobody anything new.
