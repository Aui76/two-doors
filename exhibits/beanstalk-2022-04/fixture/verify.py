#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Verify the fixture's sixteen contracts on Basescan, after proving each one locally.

The fixture's contracts are the DAN hull compiled with via_ir. Under via_ir the code solc
generates depends on the compilation unit, not only on the target's own imports. DAN met
this on its own cell on 13 September 2026: forge verify-contract submits the target's
imports, and for CellLogicLib that compiled 674 bytes shorter than the deployment, so
Basescan refused it. This tool rebuilds the input from the build that deployed the
fixture, compiles it here with the same solc, and submits a contract only when the
result equals the creation code the stand sent. It tries the target's imports first, then
for each build in out/build-info every source numbered at or before the target, plus
their imports. The builds are forge's, so run it on the tree that stood the fixture.

The creation code comes from the chain: each stand transaction's hash is in the committed
record/84532.transactions.json, and the node returns what the transaction carried. So a
clone can run the proof, not only the machine that stood the fixture. Until that record is
written, after the filing, the creation code comes from forge's broadcast log, which git
ignores. When both are here they must agree.

    python exhibits/beanstalk-2022-04/fixture/verify.py --check   # the local proof, nothing sent
    python exhibits/beanstalk-2022-04/fixture/verify.py           # the proof, then Basescan
    python exhibits/beanstalk-2022-04/fixture/verify.py --check --record=<dir>   # a superseded fixture

Run it from the repo root after forge build. The node is $RPC_URL, or Base Sepolia's public
one. The API key comes from $BASESCAN_API_KEY (an Etherscan key; the v2 API serves Base
Sepolia) and is never printed. Transport is curl with the form on stdin, so the key is on
no command line.
"""
import json
import os
import subprocess
import sys
import tempfile
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CHAIN_ID = "84532"
API = "https://api.etherscan.io/v2/api?chainid=" + CHAIN_ID
RPC = os.environ.get("RPC_URL", "").strip() or "https://sepolia.base.org"
RECORD = ROOT / "exhibits/beanstalk-2022-04/fixture/record" / (CHAIN_ID + ".json")
TRANSACTIONS = RECORD.with_name(CHAIN_ID + ".transactions.json")
BROADCAST = ROOT / "broadcast/Fixture.s.sol" / CHAIN_ID / "stand-latest.json"
CREATE2_FACTORY = "0x4e59b44847b379578588920ca78fbf26c0b4956c"
META_MARK = "a264697066735822"
# Libraries first, in link order, and the cell last, as the stand deployed them.
ORDER = ["ToolUseLib", "CellLogicLib", "DiscovererPayoutLib", "SubmitAuditLib", "CellToken", "CellEscrow",
         "IssuanceModule", "ClaimDisputeModule", "SpecGapModule", "SpecArbiterModule", "IntegrityReviewModule",
         "StructuralUpgradeModule", "FmeaRegistry", "AssignmentModule", "BlockhashEntropy", "AuditCell"]


def die(msg):
    print("REFUSING: " + msg)
    sys.exit(2)


def read_json(p):
    return json.loads(Path(p).read_text(encoding="utf-8"))


def rpc(method, params):
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": method, "params": params}).encode()
    req = urllib.request.Request(RPC, data=body, headers={"content-type": "application/json",
                                                          "user-agent": "two-doors-verify/1"})
    with urllib.request.urlopen(req, timeout=60) as r:
        res = json.loads(r.read().decode("utf-8"))
    if res.get("result") is None:
        die("the node gave no answer to %s %s: %s" % (method, params, res.get("error")))
    return res["result"]


def from_broadcast():
    """Address and initcode without any CREATE2 salt per contract, and the library table."""
    b = read_json(BROADCAST)
    out = {}
    for t in b["transactions"]:
        if t.get("transactionType") in ("CREATE", "CREATE2"):
            raw = t["transaction"]["input"].lower().removeprefix("0x")
            to = (t["transaction"].get("to") or "").lower()
            out[t["contractName"]] = (t["contractAddress"], raw[64:] if to == CREATE2_FACTORY else raw)
    libs = {}
    for entry in b.get("libraries", []):
        path, name, addr = entry.rsplit(":", 2)
        libs[name] = (path, addr)
    return out, libs


def from_chain():
    """The same, from the transactions the committed record names, as the node returns them.

    A CREATE must have made the recorded address, by its receipt. A CREATE2 must have gone
    to the factory; the libraries are the stand's CREATE2s, which is how forge deploys them."""
    out, libs = {}, {}
    for t in read_json(TRANSACTIONS)["transactions"]:
        if t["script"] != "stand" or t["type"] not in ("CREATE", "CREATE2"):
            continue
        if t["status"] != 1:
            die("the record marks %s's creation %s as failed" % (t["contract"], t["tx"]))
        tx = rpc("eth_getTransactionByHash", [t["tx"]])
        if tx["from"].lower() != t["from"].lower():
            die("%s was sent from %s, the record says %s" % (t["tx"], tx["from"], t["from"]))
        raw = tx["input"].lower().removeprefix("0x")
        to = (tx.get("to") or "").lower()
        if t["type"] == "CREATE":
            made = (rpc("eth_getTransactionReceipt", [t["tx"]]).get("contractAddress") or "").lower()
            if to or made != t["address"].lower():
                die("%s did not create %s at %s" % (t["tx"], t["contract"], t["address"]))
        else:
            if to != CREATE2_FACTORY:
                die("%s is a CREATE2 that did not go to the factory" % t["tx"])
            raw = raw[64:]
            libs[t["contract"]] = ("", t["address"])
        out[t["contract"]] = (t["address"], raw)
    return out, libs


def deployments():
    """Address, initcode without any CREATE2 salt, and the library table: from the chain when the
    transaction record is committed, from the stand's broadcast log until then."""
    if TRANSACTIONS.exists():
        out, libs = from_chain()
        print("creation code: from %s, by the transaction hashes in %s" % (RPC.split("?")[0], TRANSACTIONS.name))
        if BROADCAST.exists():
            logged, _ = from_broadcast()
            for name, (addr, raw) in out.items():
                if name not in logged or logged[name][0].lower() != addr.lower() or logged[name][1] != raw:
                    die("the chain and the broadcast log disagree about %s" % name)
            print("  and the broadcast log on this machine carries the same %d creations" % len(out))
    elif BROADCAST.exists():
        out, libs = from_broadcast()
        print("creation code: from the broadcast log %s, which git ignores" % BROADCAST.relative_to(ROOT))
    else:
        die("neither %s nor a broadcast log is here" % TRANSACTIONS.name)
    record = read_json(RECORD)
    for name, (addr, _) in out.items():
        if name in record and record[name].lower() != addr.lower():
            die("the broadcast puts %s at %s, the record at %s" % (name, addr, record[name]))
    return out, libs


def artifact(name):
    cache = read_json(ROOT / "cache/solidity-files-cache.json")["files"]
    for src, entry in cache.items():
        for ver in entry.get("artifacts", {}).get(name, {}).values():
            for prof in ver.values():
                return src.replace("\\", "/"), read_json(ROOT / "out" / prof["path"]), prof["build_id"]
    die("no artifact for %s, run forge build" % name)


def solc_path(version):
    for base in (Path(os.environ.get("APPDATA", "")) / "svm", Path.home() / ".svm"):
        p = base / version / ("solc-" + version)
        for cand in (p, p.with_suffix(".exe")):
            if cand.exists():
                return cand
    die("solc %s not found under svm, run forge build once" % version)


def closure(start, imports):
    keep, todo = set(), list(start)
    while todo:
        p = todo.pop()
        if p not in keep:
            keep.add(p)
            todo.extend(imports.get(p, []))
    return keep


def prove(name, libs, deployed):
    """The smallest input that compiles here to the deployed creation code, and the constructor arguments."""
    src, art, build_id = artifact(name)
    meta = json.loads(art["rawMetadata"]) if art.get("rawMetadata") else art["metadata"]
    cache = read_json(ROOT / "cache/solidity-files-cache.json")["files"]
    imports = {k.replace("\\", "/"): [i.replace("\\", "/") for i in v.get("imports", [])] for k, v in cache.items()}
    candidates = [("imports", closure([src], imports))]
    # The cache names the last build that wrote the artifact, which need not be the build
    # that deployed it. On 27 September 2026 it named a build from 17:29 while the stand
    # compiled at 21:38, and AuditCell's immutables sat at other memory offsets. So every
    # build that holds the target is tried, the newest first.
    infos = sorted((ROOT / "out/build-info").glob("*.json"), key=lambda f: f.stat().st_mtime, reverse=True)
    for info in infos:
        unit = read_json(info)["source_id_to_path"]
        ids = [int(i) for i, p in unit.items() if p == src]
        if ids:
            candidates.append(("prefix of build " + info.stem,
                               closure([p for i, p in unit.items() if int(i) <= ids[0]], imports)))
    libraries = {}
    for lib_src, refs in art["bytecode"].get("linkReferences", {}).items():
        for lib in refs:
            if lib not in libs:
                die("%s links %s, which the broadcast does not list" % (name, lib))
            libraries.setdefault(lib_src, {})[lib] = libs[lib][1]
    ms = meta["settings"]
    settings = {"optimizer": ms["optimizer"], "evmVersion": ms["evmVersion"], "viaIR": ms.get("viaIR", False),
                "metadata": {"bytecodeHash": ms.get("metadata", {}).get("bytecodeHash", "ipfs")},
                "remappings": ms.get("remappings", []), "libraries": libraries}
    version = meta["compiler"]["version"].split("+")[0]
    solc = solc_path(version)
    addr, chain = deployed
    chain_body = chain[:chain.rfind(META_MARK)]
    tried = []
    for label, keep in candidates:
        if any(keep == k for _, k in tried):
            continue
        sources = {p: {"content": (ROOT / p).read_bytes().decode("utf-8").replace("\r\n", "\n")} for p in sorted(keep)}
        std = {"language": "Solidity", "sources": sources,
               "settings": dict(settings, outputSelection={src: {name: ["evm.bytecode.object"]}})}
        t0 = time.time()
        # solc reads an import it was not given from its working directory. Run from the
        # repo, it compiled a set without forge-std and matched, because it read forge-std
        # from disk; Basescan would have had none. An empty directory makes the input whole.
        with tempfile.TemporaryDirectory() as empty:
            r = subprocess.run([str(solc), "--standard-json"], input=json.dumps(std), capture_output=True,
                               text=True, encoding="utf-8", cwd=empty)
        out = json.loads(r.stdout)
        errors = [e["formattedMessage"] for e in out.get("errors", []) if e["severity"] == "error"]
        if errors:
            die("%s: local compile failed: %s" % (name, errors[0][:300]))
        built = out["contracts"][src][name]["evm"]["bytecode"]["object"].lower()
        body_ok = built[:built.rfind(META_MARK)] == chain_body
        exact = chain.startswith(built)
        # The input's size is printed because Basescan's answer depends on it: it refused
        # AuditCell's 59 sources at 1.4 MB twice on 27 September 2026.
        print("  %s: %s, %d sources, %d B input, %d B built vs %d B sent, body %s, metadata %s, %.0f s"
              % (name, label, len(sources), len(json.dumps(std)), len(built) // 2, len(chain) // 2,
                 "same" if body_ok else "DIFFERS", "same" if exact else "differs", time.time() - t0))
        tried.append((label, keep))
        if body_ok:
            std["settings"]["outputSelection"] = {src: {name: ["abi", "evm.bytecode.object",
                                                               "evm.deployedBytecode.object", "metadata"]}}
            return {"name": name, "address": addr, "src": src, "std": std,
                    "compiler": "v" + meta["compiler"]["version"].removeprefix("v"),
                    "args": chain[len(built):], "how": label}
    return None


def curl_call(data):
    r = subprocess.run(["curl", "-s", "-S", "--max-time", "180", "-X", "POST",
                        "-H", "Content-Type: application/x-www-form-urlencoded",
                        "-A", "two-doors-verify/1", "--data-binary", "@-", API],
                       input=urllib.parse.urlencode(data).encode(), capture_output=True)
    if r.returncode != 0:
        die("curl exit %d: %s" % (r.returncode, r.stderr.decode("utf-8", "replace")[:300]))
    try:
        return json.loads(r.stdout.decode("utf-8"))
    except ValueError:
        die("reply is not JSON: %s" % r.stdout.decode("utf-8", "replace")[:300])


def submit(p, key):
    form = {"module": "contract", "action": "verifysourcecode", "apikey": key, "contractaddress": p["address"],
            "sourceCode": json.dumps(p["std"]), "codeformat": "solidity-standard-json-input",
            "contractname": "%s:%s" % (p["src"], p["name"]), "compilerversion": p["compiler"],
            "constructorArguements": p["args"]}
    res = curl_call(form)
    text = str(res.get("result"))
    if res.get("status") != "1":
        print("  submit: %s" % text)
        return "already verified" in text.lower()
    for _ in range(30):
        time.sleep(10)
        text = str(curl_call({"module": "contract", "action": "checkverifystatus", "guid": res["result"],
                              "apikey": key}).get("result"))
        if "pending" not in text.lower():
            print("  status: %s" % text)
            return "pass" in text.lower() or "already verified" in text.lower()
    print("  still pending after 300 s, GUID %s" % res["result"])
    return False


def main(argv):
    global RECORD, TRANSACTIONS, BROADCAST
    check_only = "--check" in argv
    names = [a for a in argv[1:] if not a.startswith("--")] or ORDER
    for a in argv[1:]:
        if a.startswith("--record="):
            # A superseded fixture's records, moved to record/superseded/<its cell>/. Its creation
            # code can come only from the chain: the broadcast log here is the latest stand's.
            d = ROOT / a.split("=", 1)[1]
            RECORD, TRANSACTIONS = d / (CHAIN_ID + ".json"), d / (CHAIN_ID + ".transactions.json")
            BROADCAST = d / "no-broadcast-log"
            if not (RECORD.exists() and TRANSACTIONS.exists()):
                die("%s holds no %s.json and %s.transactions.json" % (d, CHAIN_ID, CHAIN_ID))
    key = None
    if not check_only:
        key = os.environ.get("BASESCAN_API_KEY", "").strip() or die("set BASESCAN_API_KEY in this shell")
        # On 27 September 2026 an RPC URL went in at the key prompt, and the first run sent
        # it to Etherscan with every submission. The key's shape is checked here, before
        # anything leaves this machine, and Etherscan is asked once before the first proof.
        if len(key) != 34 or not key.isalnum():
            die("BASESCAN_API_KEY is not an Etherscan API key (34 letters and digits); nothing was sent")
        probe = str(curl_call({"module": "contract", "action": "checkverifystatus", "guid": "x", "apikey": key}).get("result"))
        if "invalid api key" in probe.lower() or "missing" in probe.lower():
            die("Etherscan refuses this key (%s); nothing was submitted" % probe)
    deployed, libs = deployments()
    results = []
    for name in names:
        if name not in deployed:
            die("the stand's broadcast created no %s" % name)
        print("%s @ %s" % (name, deployed[name][0]))
        p = prove(name, libs, deployed[name])
        if p is None:
            print("  no input reproduces the deployment here, so it is not submitted")
            results.append((name, deployed[name][0], "not reproduced"))
            continue
        if check_only:
            results.append((name, p["address"], "proven (" + p["how"] + ")"))
            continue
        ok = submit(p, key)
        results.append((name, p["address"], "verified" if ok else "NOT verified"))
    print()
    for name, addr, state in results:
        print("%-24s %s  %s" % (name, addr, state))
    bad = [r for r in results if not (r[2].startswith("proven") or r[2] == "verified")]
    print("%d of %d %s" % (len(results) - len(bad), len(results), "proven here" if check_only else "verified on Basescan"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
