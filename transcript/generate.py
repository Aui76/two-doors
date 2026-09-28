#!/usr/bin/env python3
"""Writes the museum's transcript: what every room prints, page by page, stamped with the commit.

Nothing on these pages is typed. The rooms' lines are what `forge test --json -vv` returns
in each test's decoded_logs. Door two's Base Sepolia facts are the committed records in
exhibits/beanstalk-2022-04/fixture/record/ and what ReadTheFixture and ReadTheFiling print
when they read the chain. The exit's bytes and hashes are computed here from its files.

    python transcript/generate.py            # run everything, write transcript/*.md
    python transcript/generate.py --check    # run everything again, compare with the pages here
    python transcript/generate.py --offline  # skip the Base Sepolia read (the pages say so)
    python transcript/generate.py --draft    # from a dirty tree, to look at; the stamp says so

Run it from a clean tree: the pages name the commit they were made from, and a page that
names a commit which does not hold the code it ran proves nothing. --check accepts a HEAD
that differs from the stamped commit only under transcript/, which is the commit that adds
the pages. What it compares is everything except the stamp (date, elapsed times) and the
live read of Base Sepolia, whose block, time and balances move.

The fork rooms need MAINNET_ARCHIVE_RPC_URL (foundry.toml). The Base read uses
BASE_SEPOLIA_RPC_URL, or Base Sepolia's public node. The scripts are only simulated: forge
simulates deploying the hull's libraries for them, and no --broadcast is ever passed.
"""
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "transcript"
RECORDS = "exhibits/beanstalk-2022-04/fixture/record/"
BASE_RPC = os.environ.get("BASE_SEPOLIA_RPC_URL", "").strip() or "https://sepolia.base.org"
EXPLORER = "https://sepolia.basescan.org/tx/"
STAMP = ("<!-- stamp -->", "<!-- /stamp -->")
LIVE = ("<!-- live -->", "<!-- /live -->")

# Each page, and the test files whose output it carries, in the order the visitor walks.
# A test file that no page claims stops the run, so a new room cannot go missing quietly.
PAGES = [
    ("room-1", "Room 1, the last safe moment", [
        ("Beanstalk on Ethereum, the block before it was drained", [
            "exhibits/beanstalk-2022-04/Fork.t.sol",
            "exhibits/beanstalk-2022-04/Verdict.t.sol",
            "exhibits/beanstalk-2022-04/Provenance.t.sol",
        ]),
    ]),
    ("room-2", "Room 2, the two doors", [
        ("Door one, the attacker's: the attack replayed on the fork", [
            "exhibits/beanstalk-2022-04/replay/Replay.t.sol",
        ]),
        ("Door two, the discoverer's: the fixture and the filing, in memory", [
            "exhibits/beanstalk-2022-04/Fixture.t.sol",
            "exhibits/beanstalk-2022-04/Filing.t.sol",
        ]),
    ]),
    ("room-3", "Room 3, the room with no seat", [
        ("Bybit's wallet on Ethereum, February 2025", [
            "exhibits/bybit-2025-02/Fork.t.sol",
            "exhibits/bybit-2025-02/NoSeat.t.sol",
        ]),
    ]),
    ("exit", "The exit", [
        ("The tool you leave with", [
            "exhibits/exit/Exit.t.sol",
        ]),
    ]),
]
EXIT_FILES = ["exhibits/exit/dan-check/dan-check.mjs", "exhibits/exit/dan-check/keccak256.mjs"]


def die(msg):
    print("REFUSING: " + msg, file=sys.stderr)
    sys.exit(2)


def run(cmd, check=True):
    r = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if check and r.returncode != 0:
        die("%s exited %d: %s" % (" ".join(cmd), r.returncode, (r.stderr or r.stdout)[-600:]))
    return r


def git(*args):
    return run(["git"] + list(args)).stdout.strip()


def tree_state():
    """The commit, and whether the tree outside transcript/ differs from it."""
    dirty = run(["git", "status", "--porcelain", "--untracked-files=all", "--", ".", ":(exclude)transcript"]).stdout.rstrip()
    return git("rev-parse", "HEAD"), dirty


def fence(lines):
    return ["```text"] + lines + ["```"]


def block(marks, lines):
    return [marks[0]] + lines + [marks[1]]


def forge_build():
    t0 = time.time()
    r = run(["forge", "build"])
    # forge also prints its linter's warnings (the ported attack's unchecked transfers);
    # the line that says what was compiled is the one kept.
    said = [l.strip() for l in (r.stdout + r.stderr).splitlines()
            if re.match(r"\s*(No files changed|Compiling \d+ files|Compiler run|Nothing to compile)", l)]
    return ("; ".join(said) if said else "no compile line"), time.time() - t0


def forge_test():
    t0 = time.time()
    r = run(["forge", "test", "--json", "-vv"], check=False)
    try:
        suites = json.loads(r.stdout)
    except ValueError:
        die("forge test gave no JSON (exit %d): %s" % (r.returncode, (r.stderr or r.stdout)[-600:]))
    return suites, time.time() - t0


def source_order(path):
    text = (ROOT / path).read_text(encoding="utf-8")
    return [m.group(1) for m in re.finditer(r"function\s+(test\w*)\s*\(", text)]


def tests_of(suites, path):
    """The tests of one file in the order its source declares them, as (suite, name, result)."""
    found = {}
    for suite, s in suites.items():
        if suite.split(":")[0] == path:
            for name, res in s["test_results"].items():
                found[name.split("(")[0]] = (suite.split(":")[1], name, res)
    order = source_order(path)
    missing = [n for n in found if n not in order]
    if missing:
        die("%s ran tests its source does not declare: %s" % (path, missing))
    return [found[n] for n in order if n in found]


def test_lines(suites, files, tally):
    out = []
    for path in files:
        out.append("")
        out.append("#### `%s`" % path)
        for contract, name, res in tests_of(suites, path):
            ok = res["status"] == "Success"
            tally[0 if ok else 1] += 1
            out.append("")
            out.append("`%s.%s` %s%s" % (contract, name, "passed" if ok else "FAILED",
                                         "" if ok else ": " + str(res.get("reason"))))
            logs = res.get("decoded_logs") or []
            if logs:
                out.append("")
                out += fence(logs)
            else:
                out.append("")
                out.append("It prints nothing; it asserts.")
    return out


def pairs(record, skip=()):
    items = [(k, v) for k, v in record.items() if k not in skip]
    width = max(len(k) for k, _ in items)
    return ["%s  %s" % (k.ljust(width), v) for k, v in items]


def read_json(rel):
    return json.loads((ROOT / rel).read_text(encoding="utf-8"))


def base_records():
    stood = read_json(RECORDS + "84532.json")
    filed = read_json(RECORDS + "84532.filing.json")
    confirm = read_json(RECORDS + "84532.confirm.json")
    txs = read_json(RECORDS + "84532.transactions.json")["transactions"]
    out = ["", "### Door two on Base Sepolia, from the committed records", ""]
    out.append("`%s84532.json`, which the stand wrote:" % RECORDS)
    out.append("")
    out += fence([stood["what"], ""] + pairs(stood, skip=("what",)))
    out.append("")
    out.append("`%s84532.filing.json`, which the filing wrote:" % RECORDS)
    out.append("")
    out += fence([filed["what"], ""] + pairs(filed, skip=("what",)))
    out.append("")
    out.append("`%s84532.confirm.json`, the transaction that closed the gap:" % RECORDS)
    out.append("")
    out += fence([confirm["what"], ""] + pairs(confirm, skip=("what",)))
    out.append("")
    failed = sum(1 for t in txs if t["status"] != 1)
    out.append("`%s84532.transactions.json`: %d transactions the stand and the filing sent, %d of them failed."
               % (RECORDS, len(txs), failed))
    out.append("")
    out.append("| # | script | type | contract | function | block | tx |")
    out.append("|---|---|---|---|---|---|---|")
    for i, t in enumerate(txs):
        fn = (t.get("function") or "").split("(")[0]
        out.append("| %d | %s | %s | %s | %s | %d | [%s…](%s%s) |" % (
            i, t["script"], t["type"], t.get("contract") or "", fn, t["block"], t["tx"][:10], EXPLORER, t["tx"]))
    return out


def script_logs(target):
    r = run(["forge", "script", target, "--sig", "check()", "--rpc-url", BASE_RPC])
    lines = r.stdout.splitlines()
    if "== Logs ==" not in lines:
        die("%s printed no logs" % target)
    logs = []
    for line in lines[lines.index("== Logs ==") + 1:]:
        if not line.strip():
            break
        logs.append(line[2:] if line.startswith("  ") else line)
    return logs


def base_live(offline):
    out = ["", "### Door two on Base Sepolia, read from the chain in this run", ""]
    if offline:
        return out + block(LIVE, ["Not read: this run was made with --offline."])
    body = ["`ReadTheFixture` and `ReadTheFiling` read the chain from %s and send nothing:" % BASE_RPC, ""]
    body += fence(script_logs("exhibits/beanstalk-2022-04/fixture/Fixture.s.sol:ReadTheFixture"))
    body.append("")
    body += fence(script_logs("exhibits/beanstalk-2022-04/filing/Filing.s.sol:ReadTheFiling"))
    return out + block(LIVE, body)


def exit_files():
    out = ["", "### The tool's two files, measured in this run", "",
           "| file | bytes | sha256 |", "|---|---|---|"]
    for rel in EXIT_FILES:
        data = (ROOT / rel).read_bytes()
        out.append("| `%s` | %d | `%s` |" % (rel, len(data), hashlib.sha256(data).hexdigest()))
    return out


def pages(suites, offline, tally):
    claimed = {p for _, _, sections in PAGES for _, files in sections for p in files}
    ran = {s.split(":")[0] for s in suites}
    if ran - claimed:
        die("no page carries %s" % sorted(ran - claimed))
    if claimed - ran:
        die("forge ran nothing from %s" % sorted(claimed - ran))
    built = {}
    for slug, title, sections in PAGES:
        lines = ["# " + title, "", "[The transcript](README.md)"]
        for heading, files in sections:
            lines += ["", "## " + heading]
            lines += test_lines(suites, files, tally)
            if slug == "room-2" and heading.startswith("Door two"):
                lines += base_records()
                lines += base_live(offline)
            if slug == "exit":
                lines += exit_files()
        built[slug + ".md"] = lines
    return built


def index(commit, dirty, build, test_s, tally, offline):
    stamp = ["Made from commit `%s`, %s, on %s UTC." % (
                 commit, "tree NOT clean, a draft" if dirty else "tree clean", datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M")),
             "",
             "- `forge --version`: %s" % run(["forge", "--version"]).stdout.splitlines()[0],
             "- `forge build`: %s, %.0f s" % build,
             "- `forge test --json -vv`: %.0f s" % test_s]
    if offline:
        stamp.append("- Base Sepolia: not read (--offline)")
    lines = ["# The transcript", "",
             "What every room prints, and nothing typed. Each page is the output of the commands named on it,",
             "written by `transcript/generate.py`. Run the same commit and you get the same lines, apart from",
             "the times and the live read of Base Sepolia:", "",
             "```bash", "python transcript/generate.py --check", "```", ""]
    lines += block(STAMP, stamp)
    lines += ["", "**%d passed, %d failed.**" % tuple(tally), ""]
    for slug, title, _ in PAGES:
        lines.append("- [%s](%s.md)" % (title, slug))
    return lines


def comparable(text):
    """The page without its stamp and live blocks, which move from run to run."""
    for a, b in (STAMP, LIVE):
        text = re.sub(re.escape(a) + r".*?" + re.escape(b), a + b, text, flags=re.S)
    return text


def main(argv):
    check = "--check" in argv
    offline = "--offline" in argv
    draft = "--draft" in argv
    commit, dirty = tree_state()
    if check:
        committed = (OUT / "README.md").read_text(encoding="utf-8")
        m = re.search(r"Made from commit `([0-9a-f]{40})`, tree clean", committed)
        if not m:
            die("transcript/README.md names no commit made from a clean tree")
        stamped = m.group(1)
        if run(["git", "diff", "--quiet", stamped, "HEAD", "--", ".", ":(exclude)transcript"],
               check=False).returncode != 0:
            die("HEAD differs from the stamped commit %s outside transcript/" % stamped[:7])
        if dirty:
            die("the tree differs from HEAD outside transcript/:\n" + dirty)
    elif dirty and not draft:
        die("the tree differs from HEAD outside transcript/, so no commit holds what this run would print:\n"
            + dirty)
    build = forge_build()
    suites, test_s = forge_test()
    tally = [0, 0]
    built = pages(suites, offline, tally)
    built["README.md"] = index(commit, dirty, build, test_s, tally, offline)
    texts = {name: "\n".join(lines) + "\n" for name, lines in built.items()}
    if check:
        differ = []
        for name, text in texts.items():
            here = OUT / name
            if not here.exists() or comparable(here.read_text(encoding="utf-8")) != comparable(text):
                differ.append(name)
        for name in differ:
            print("DIFFERS  transcript/" + name)
        print("%d passed, %d failed; %d of %d pages match"
              % (tally[0], tally[1], len(texts) - len(differ), len(texts)))
        return 1 if differ or tally[1] else 0
    for name, text in texts.items():
        (OUT / name).write_bytes(text.encode("utf-8"))
        print("wrote transcript/" + name)
    print("%d passed, %d failed, from %s" % (tally[0], tally[1], commit[:7]))
    return 1 if tally[1] else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
