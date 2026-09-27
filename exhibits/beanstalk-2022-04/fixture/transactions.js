// SPDX-License-Identifier: MIT
// Writes record/84532.transactions.json: every transaction the stand and the filing
// sent on Base Sepolia, from forge's broadcast logs, with each block's time read from
// the node. The broadcast logs are gitignored and live on one machine; this record is
// the committed copy of what the plaque cites. Run once from the repository root after
// the filing. It refuses to overwrite the record.
//
//   node exhibits/beanstalk-2022-04/fixture/transactions.js
//
// With --check it writes nothing and compares the committed record with the logs and
// the node, if the logs are on this machine.
const fs = require('fs');

const RPC = process.env.RPC_URL || 'https://sepolia.base.org';
const OUT = 'exhibits/beanstalk-2022-04/fixture/record/84532.transactions.json';
const LOGS = [
  ['stand', 'broadcast/Fixture.s.sol/84532/stand-latest.json'],
  ['filing', 'broadcast/Filing.s.sol/84532/file-latest.json'],
];

async function blockTime(n) {
  const res = await fetch(RPC, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ jsonrpc: '2.0', id: 1, method: 'eth_getBlockByNumber', params: ['0x' + n.toString(16), false] }),
  });
  const j = await res.json();
  if (!j.result) throw new Error('no block ' + n + ' from ' + RPC);
  return parseInt(j.result.timestamp, 16);
}

async function build() {
  const txs = [];
  for (const [script, path] of LOGS) {
    const b = JSON.parse(fs.readFileSync(path, 'utf8'));
    if (b.chain !== 84532) throw new Error(path + ' is not Base Sepolia');
    const r = Object.fromEntries(b.receipts.map((x) => [x.transactionHash, x]));
    for (const t of b.transactions) {
      const rc = r[t.hash];
      if (!rc) throw new Error('no receipt for ' + t.hash);
      txs.push({
        script,
        type: t.transactionType,
        contract: t.contractName,
        address: t.contractAddress || rc.to,
        function: t.function,
        from: t.transaction.from,
        tx: t.hash,
        block: parseInt(rc.blockNumber, 16),
        status: parseInt(rc.status, 16),
      });
    }
  }
  const times = {};
  for (const n of [...new Set(txs.map((t) => t.block))]) times[n] = await blockTime(n);
  for (const t of txs) t.timestamp = times[t.block];
  return {
    what: 'Every transaction the stand and the filing sent on Base Sepolia, from forge broadcast logs; timestamps are each block\'s, read from the node. The confirm is in 84532.confirm.json.',
    chainId: 84532,
    transactions: txs,
  };
}

(async () => {
  const text = JSON.stringify(await build(), null, 2) + String.fromCharCode(10);
  if (process.argv[2] === '--check') {
    const same = fs.readFileSync(OUT, 'utf8') === text;
    console.log(same ? 'RECORD-MATCHES-LOGS' : 'RECORD-DIFFERS');
    process.exit(same ? 0 : 1);
  }
  fs.writeFileSync(OUT, text, { flag: 'wx' });
  console.log(JSON.parse(text).transactions.length, 'transactions written to', OUT);
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
