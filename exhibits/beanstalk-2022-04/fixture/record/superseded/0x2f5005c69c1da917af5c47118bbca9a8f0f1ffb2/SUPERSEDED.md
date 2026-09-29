<!-- SPDX-License-Identifier: MIT -->
# The first fixture, superseded

These are the records of the first fixture I stood for Room 2 on Base Sepolia, on
27 September 2026, from museum `a3d577a`. Its AuditCell is
`0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2`. The gap was filed at block 47,385,257
and silence confirmed it at block 47,385,463, with the 10 AUDIT stake back to the
discoverer.

Basescan verified 15 of its 16 contracts, and AuditCell is the one it did not. The
museum's own files sorted ahead of the hull, so the only input I found that reproduced
AuditCell's code was 59 sources and 1.4 MB, and Basescan refused it twice. The network
tracks this as PC-138.

In `db0c107` I moved the hull from `lib/` to `deps/`, which sorts ahead of the museum's
files. The second fixture was stood from the commit that moved these records here, and
its address is in `../../84532.json`.

This fixture's transactions are still on chain. From the museum's root this proves the
same 15 contracts:

```bash
python exhibits/beanstalk-2022-04/fixture/verify.py --check --record=exhibits/beanstalk-2022-04/fixture/record/superseded/0x2f5005c69c1da917af5c47118bbca9a8f0f1ffb2
```
