<!-- SPDX-License-Identifier: MIT -->
# Vendored, unmodified

These seven files are the source of Balancer's composable stable pool, version 5, as it was deployed at
`0xDACf5Fa19b1f720111609043ac67A9818262850c` on Ethereum, the first pool the drain of 3 November 2025 touched.
They are copied byte for byte, and I got the same bytes from two places that don't depend on each other.

- **From the chain's side:** Sourcify holds this address as an exact match, creation and runtime, compiled with
  solc 0.7.1. Sourcify only gives that answer when these sources compile to the bytes deployed at the address.
- **From Balancer's side:** `balancer/balancer-v2-monorepo` at commit `6198fd700204ed143a33b06539954d218845b3dc`,
  dated 11 July 2023, "Patch (single flag version): Composable stable pool v5". Each of the seven files hashes the
  same there as here.

The commands, and the hash every file arrived with, are in `../../exhibits/balancer-2025-11/spec/SOURCES.md`.

Each file carries `SPDX-License-Identifier: GPL-3.0-or-later` in its own header and is reproduced under that
licence, unmodified, for study. The licence's full text is `COPYING` beside them, copied byte for byte from
`LICENSE` in `balancer/balancer-v2-monorepo` at the same commit (35,149 bytes, sha256
`3972dc9744f6499f0f9b2dbf76696f2ae7ad8af9b23dde66d6af86c9dfb36986`). That is not this repository's licence. The rest of the museum is MIT, and these
seven files stay GPL-3.0-or-later. Nothing in the museum compiles or links them, and `foundry.toml` reads them only
as text, to hash them and to find the lines the room cites.

They are here so the exhibit can be checked without a network and without trusting this repository.
