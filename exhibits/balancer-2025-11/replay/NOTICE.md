<!-- SPDX-License-Identifier: MIT -->
# Attribution — the replay is a port with credit

The replay in this directory is a port of the public exploit test carried by
**DeFiHackLabs**, `src/test/2025-11/BalancerV2_exp.sol`.

- Source repository: DeFiHackLabs (https://github.com/SunWeb3Sec/DeFiHackLabs)
- Licence governing the port: **Apache-2.0** (the repository's licence). If the
  file header carries a different SPDX line, that belongs to a generated interface
  stub, not to the test; the repository licence governs (as ruled for the Beanstalk
  port, VD-240).
- Fetched 2026-09-29: 19,080 bytes, sha256
  `9cf837fa17a20573fd6df4bdaa28b2e38c0e478e699bf0701efec8be5d8d17dc`
  (matches the GitHub API's listed byte count; the fetch command is in `README.md`).
- Its constructor forks at the block this museum forks at, 23,717,396 — to be
  confirmed against the fetched file (see `README.md`, "Footing").

DeFiHackLabs' own licence file is carried beside the port as `LICENSE`, byte for byte
(fetched 2026-10-07 from the repository's `main`: 11,347 bytes, sha256
`aa728951f2cd7399efd5fcb214cde9e8c12a4ebb3cf08222e7256b933a102bae`). The repository has no
NOTICE file to carry. `Replay.t.sol` is changed from the original, and says so at its top:
the imports, and the lines marked `museum:`, both listed in `README.md`. Every room that
shows the replay credits DeFiHackLabs by name.

This is not new. It is the exploit of 3 November 2025, on-chain and permanent,
replayed against a frozen snapshot of history on a fork — a replay a public
repository already carries. It steals from nobody and hands nobody anything new.
