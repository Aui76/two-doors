# The transcript

What every room prints, and nothing typed. Each page is the output of the commands named on it,
written by `transcript/generate.py`. Run the same commit and you get the same lines, apart from
the times and the live read of Base Sepolia:

```bash
python transcript/generate.py --check
```

<!-- stamp -->
Made from commit `a58f81c9f07cdf2f6f53ade7ab44c9b1cbf7443e`, tree clean, on 2026-10-07 10:22 UTC.

- `forge --version`: forge Version: 1.7.1
- `forge build`: No files changed, compilation skipped, 5 s
- `forge test --json -vv`: 5 s
<!-- /stamp -->

**63 passed, 0 failed.**

- [Room 1, the auditor's room](room-1.md)
- [Room 2, the room with no seat](room-2.md)
- [Room 3, the Balancer room](room-3.md)
- [The exit](exit.md)
- [On file: the row passed, and the gap filed after it](record.md)

The same run, laid out as the walk a visitor clicks through, is `transcript/site/`.
