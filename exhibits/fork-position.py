#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Shows that each room's fork block is the state its attack met, not only the block before it.

A fork by block number, createSelectFork(url, N), is the state at the end of block N. Each
room forks at the block before its attack. That is the state the attacker met only if no
transaction ahead of the attack, in the attack's own block, touched what the room reads.
Forking by transaction hash would replay those transactions; the rooms fork by number, so
this checks that there was nothing to replay.

For each room it reads the attack transaction's block and index, then every receipt in that
block ahead of it, and counts a receipt as touching when its `to` or any of its logs'
addresses is one of the room's contracts. It prints the position and what it found, and
exits 1 if any receipt touches, or if a position differs from the one the room states.

It reads receipts, not traces. A transaction that reached a room's contract through an
internal call and emitted no log there would not be seen.

    python exhibits/fork-position.py

The node is $MAINNET_ARCHIVE_RPC_URL (.env.example). It must serve eth_getBlockReceipts.
Nothing is sent.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.request

ROOMS = [
    # room, attack transaction, its block and index as the room states them, contracts the room reads
    ('beanstalk-2022-04', '0x68cdec0ac76454c3b0f7af0b8a3895db00adf6daaf3b50a99716858c4fa54c6f', 14595906, 94,
     {'0xc1e088fc1323b20bcbee9bd1b9fc9546db5624c5': 'Beanstalk diamond',
      '0x3a70dfa7d2262988064a2d051dd47521e43c9bdd': 'BEAN3CRV',
      '0xd652c40fbb3f06d6b58cb9aa9cff063ee63d465d': 'BEANLUSD',
      '0xdc59ac4fefa32293a95889dc396682858d52e5db': 'BEAN',
      '0x87898263b6c5babe34b4ec53f22d98430b91e371': 'BEAN/ETH'}),
    ('bybit-2025-02', '0x46deef0f52e3a983b67abf4714448a41dd7ffd6d32d32da69d62081c68ad7882', 21895238, 116,
     {'0x1db92e2eebc8e0c075a02bea49a2935bcd2dfcf4': 'the Safe'}),
    ('balancer-2025-11', '0x6ed07db1a9fe5c0794d44cd36081d6a6df103fab868cdd75d581e3bd23bc9742', 23717397, 1,
     {'0xba12222222228d8ba445958a75a0704d566bf2c8': 'the Vault',
      '0xdacf5fa19b1f720111609043ac67a9818262850c': 'pool A',
      '0x93d199263632a4ef4bb438f1feb99e57b4b5f0bd': 'pool B'}),
]


def call(rpc, method, params):
    body = json.dumps({'jsonrpc': '2.0', 'id': 1, 'method': method, 'params': params}).encode()
    req = urllib.request.Request(rpc, data=body, headers={'content-type': 'application/json', 'user-agent': 'curl/8'})
    for wait in (2, 5, 10, 20, None):  # public nodes answer 429 when asked too fast
        try:
            reply = json.load(urllib.request.urlopen(req, timeout=60))
            break
        except urllib.error.HTTPError as e:
            if e.code != 429 or wait is None:
                raise
            time.sleep(wait)
    if 'error' in reply:
        sys.exit('%s: %s' % (method, reply['error']))
    return reply['result']


def main():
    rpc = os.environ.get('MAINNET_ARCHIVE_RPC_URL')
    if not rpc:
        sys.exit('set MAINNET_ARCHIVE_RPC_URL (see .env.example)')
    bad = False
    for room, tx_hash, want_block, want_index, watched in ROOMS:
        tx = call(rpc, 'eth_getTransactionByHash', [tx_hash])
        block, index = int(tx['blockNumber'], 16), int(tx['transactionIndex'], 16)
        receipts = call(rpc, 'eth_getBlockReceipts', [hex(block)])
        hits = []
        for r in receipts[:index]:
            touched = {(r.get('to') or '').lower()} | {log['address'].lower() for log in r['logs']}
            names = [watched[a] for a in watched if a in touched]
            if names:
                hits.append('%d %s (%s)' % (int(r['transactionIndex'], 16), r['transactionHash'], ', '.join(names)))
        print('%-18s block %s, transaction %d of %d; ahead of it, receipts touching %s: %s'
              % (room, format(block, ','), index, len(receipts), ', '.join(watched.values()),
                 'none' if not hits else '; '.join(hits)))
        if (block, index) != (want_block, want_index):
            print('%-18s EXPECTED block %s, transaction %d' % (room, format(want_block, ','), want_index))
            bad = True
        bad = bad or bool(hits)
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
