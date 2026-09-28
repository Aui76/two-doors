<!-- SPDX-License-Identifier: MIT -->
# Room 3, the room with no seat

Bybit. On 21 February 2025 its cold wallet on Ethereum held 401,346.768858404671846374 ETH. Three of its six
owners signed a transaction, the wallet checked the three signatures and did what the transaction said, and
thirteen blocks later the ETH was gone.

The wallet is a Safe v1.1.1, and I wrote its spec from Safe's own words of 2019 (`spec/SOURCES.md`). The check
passes, and it is right to pass: the wallet's code did exactly what those words say. The money left anyway.
In Room 2 you can file the gap yourself. Here there is no gap to file, so this room has no button, and I won't
hand you a door that isn't there.

This one we could not have caught, and I will not pretend otherwise.

## The plaque

The tests below print every number here. I typed none of them from a write up.

The wallet, one block before, at 21,895,237 (21 February 2025, 14:13:23 UTC). It is 170 bytes of code, hash
`0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5`. That code forwards every call to the
address in its storage slot 0, which held the Safe v1.1.1 singleton `0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F`.
It needed 3 of 6 owners, its next transaction was nonce 71, and it held 401,346.768858404671846374 ETH.

The row. The protocol files it against that code hash, the auditor proves PASS against `spec/safe-v1.1.1.json`,
the window closes, and the state is InBlock. On the node, `dan-check` says CLEAN.

The signed transaction, `0x46deef0f…7882`, is Safe transaction hash
`0xb3476d061aeb8fc1d605a873c483a2402d88a68a9cdd1a8b47655dd55ba004f8`. It uses operation 1, a delegatecall, to
`0x96221423681A6d52E184D440a8eFCEbB105C7242`. The three signatures recover to owners `0x1F4EB0a9…2211`,
`0x3Cc3A225…C21A` and `0xe3dF2cCE…5a9E`, in the ascending order the wallet requires. After it runs, slot 0
holds `0xbDd077f651EBe7f7b3cE16fe5F2b025BE2969516`.

The sweep, `0xb61413c4…072c`, empties the wallet to 0, and 401,346.768858404671846374 ETH arrives at
`0x47666Fab8bd0Ac7003bce3f5C3585383F09486E2`, to the wei.

And after all of that, the wallet's code hash is `0xaea7d4…b7e5`, the same 170 bytes. The row is still
InBlock, and `dan-check` still says CLEAN.

## What the check reads, and what it doesn't

`dan-check` hashes the code at an address and asks the cell whether that hash has a settled row. The code
here never changed. What changed is one storage slot, and it changed because the owners signed a transaction
telling the wallet to change it. `operation-one-is-delegatecall` in the spec is the sentence that allows it,
and it had been in Safe's code since 13 December 2019.

I don't know what the three signers' screens showed them before they signed. It isn't on the chain, the check
can't read it, and I make no claim about it here. The room claims what the tests print: the wallet held, three
owners signed, the wallet obeyed, the money left, and the code the check reads did not move.

## Where the addresses came from

DeFiHackLabs keeps a public test for this attack, `src/test/2025-02/Bybit_exp.sol` (Apache 2.0). I took the
wallet, the singleton and the five transaction hashes from its header, fetched 25 September 2026, 12,529
bytes, sha256 `24df6430a21cd79f9c724f50d263804955cbd2efc077633b87a636a8e724d6d1`. Then I checked each one
against the chain myself with the commands below. I used none of its code. The room runs the chain's own
two transactions by hash, so there is nothing to port. The mETH, cmETH and stETH sweeps in that file are left
out, because this room is about the ETH.

```
cast storage 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 0 --block 21895237 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast storage 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 0 --block 21895238 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast balance 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 --block 21895250 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast balance 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 --block 21895251 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast codehash 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 --block 21895238 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast tx 0x46deef0f52e3a983b67abf4714448a41dd7ffd6d32d32da69d62081c68ad7882 --rpc-url $MAINNET_ARCHIVE_RPC_URL
cast tx 0xb61413c495fdad6114a7aa863a00b2e3c28945979a10885b12b30316ea9f072c --rpc-url $MAINNET_ARCHIVE_RPC_URL
```

## The tests

Setup is Room 1's, the `deps/dan` submodule and an archive endpoint (`../beanstalk-2022-04/verdict/README.md`).

```
forge test --match-path "exhibits/bybit-2025-02/*" -vv
```

`Fork.t.sol` checks the wallet as it stood against every constant in `Room3.sol`. `NoSeat.t.sol` has two
tests. The first rebuilds the signed calldata, requires it to appear byte for byte in the node's record of
that hash, and recovers the three signers. The second files and settles the row, runs the two real
transactions with `vm.transact`, and asks the row again.

## The row on a node

A fork one block before the signed transaction. That block is already Cancun, so anvil needs no hardfork flag.

```
anvil --fork-url $MAINNET_ARCHIVE_RPC_URL --fork-block-number 21895237
forge script exhibits/bybit-2025-02/NoSeat.s.sol:FileTheNoSeatRow --rpc-url http://127.0.0.1:8545 --broadcast
```

Put the printed cell in `CELL`, close the window, confirm the row, and ask the door:

```
cast rpc evm_increaseTime 1209601 --rpc-url http://127.0.0.1:8545
cast rpc evm_mine --rpc-url http://127.0.0.1:8545
cast send $CELL "confirmAudit(uint256)" 0 --unlocked --from 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --rpc-url http://127.0.0.1:8545
node exhibits/exit/dan-check/dan-check.mjs --target 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 --cell $CELL --home-rpc http://127.0.0.1:8545
```

Now send the two transactions as they were sent. The calldata is fetched from the chain, and anvil lets you
send as the account that sent them:

```
S=0x0fa09C3A328792253f8dee7116848723b72a6d2e
cast rpc anvil_impersonateAccount $S --rpc-url http://127.0.0.1:8545
cast send 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 $(cast tx 0x46deef0f52e3a983b67abf4714448a41dd7ffd6d32d32da69d62081c68ad7882 input --rpc-url $MAINNET_ARCHIVE_RPC_URL) --from $S --unlocked --rpc-url http://127.0.0.1:8545
cast send 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 $(cast tx 0xb61413c495fdad6114a7aa863a00b2e3c28945979a10885b12b30316ea9f072c input --rpc-url $MAINNET_ARCHIVE_RPC_URL) --from $S --unlocked --rpc-url http://127.0.0.1:8545
cast balance 0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4 --rpc-url http://127.0.0.1:8545
```

With the window still open, before the confirm, the door says `CANNOT VERIFY` and exits 2. After the confirm,
this is what it printed when I ran it on 25 September 2026:

```
  CLEAN — audit #0, state InBlock (settled and the adversarial window has closed)
  codehash 0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5
  [dan-check/1] home chain 1 @ block 0x14e1879 · computed 2026-09-25T11:43:51Z
```

Exit 0. Then the two transactions. Slot 0 read `0x…bdd077f651ebe7f7b3ce16fe5f2b025be2969516`, the wallet's balance
read 0, and the sweep's destination read 401346768858404671846374 wei. I asked the door again with the same
command:

```
  CLEAN — audit #0, state InBlock (settled and the adversarial window has closed)
  codehash 0xaea7d4252f6245f301e540cfbee27d3a88de543af8e49c5c62405d5499fab7e5
  [dan-check/1] home chain 1 @ block 0x14e187b · computed 2026-09-25T11:43:55Z
```

Exit 0, two blocks later, same code hash, same answer. The dashes in those lines are the tool's own output.
