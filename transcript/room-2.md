<!-- SPDX-License-Identifier: MIT -->
# Room 2, the room with no seat

[The transcript](README.md)

## Bybit's wallet on Ethereum, February 2025

#### `exhibits/bybit-2025-02/Fork.t.sol`

`BybitForkTest.test_theForkIsTheBlockBefore()` passed

It prints nothing; it asserts.

`BybitForkTest.test_theWalletAsItStood()` passed

```text
fork block: 21895237
fork timestamp: 1740147203
wallet: 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4
wallet code hash: 0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5
wallet code length (bytes): 170
slot 0 (master copy): 0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F
master copy code hash: 0x56b8be58b5ad629a621593a2e5e5e8e9a28408dc06e95597497b303902772e45
threshold: 3
owners: 6
nonce: 71
balance (ETH): 401346.768858404671846374
```

#### `exhibits/bybit-2025-02/NoSeat.t.sol`

`BybitNoSeatTest.test_threeOwnersSignedThisTransaction()` passed

```text
signed transaction: 0x46deef0f52e3a983b67abf4714448a41dd7ffd6d32d32da69d62081c68ad7882
Safe nonce: 71
Safe transaction hash: 0xb3476d061aeb8fc1d605a873c483a2402d88a68a9cdd1a8b47655dd55ba004f8
operation (1 = delegatecall): 1
destination: 0x96221423681A6d52E184D440a8eFCEbB105C7242
signed by owner: 0x1F4EB0a903619ac168b19A82F1a6e2e426522211
signed by owner: 0x3Cc3A225769900e003E264dd4CB43E90896BC21A
signed by owner: 0xe3dF2cCEAc61B1aFA311372ecC5B40A3A6585a9E
signatures required (threshold): 3
```

`BybitNoSeatTest.test_theCheckPassesAndTheMoneyLeaves()` passed

```text
sweep transaction: 0xb61413c495fdad6114a7aa863a00b2e3c28945979a10885b12b30316ea9f072c
fork block: 21895237
cell: 0x2e234DAe75C793f67A35089C9d99245E1C58470b
audit id: 0
artifact hash (wallet code): 0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5
spec hash (safe-v1.1.1.json): 0xe1fa770433719a987352b2d2dbcf84c14c847b2100e845aa419649a4e2ae001e
state (6 = InBlock): 6
wallet holds (ETH): 401346.768858404671846374
slot 0 after the signed transaction: 0xbDd077f651EBe7f7b3cE16fe5F2b025BE2969516
wallet holds after the sweep (ETH): 0.000000000000000000
sweep destination: 0x47666Fab8bd0Ac7003bce3f5C3585383F09486E2
moved to the sweep's destination (ETH): 401346.768858404671846374
artifact hash after (wallet code): 0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5
state after (6 = InBlock): 6
```
