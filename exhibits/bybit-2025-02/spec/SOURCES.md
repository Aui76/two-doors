<!-- SPDX-License-Identifier: MIT -->
# Where every word in the spec came from

Same rule as Room 1. The spec is written from what Safe published about its own contracts before 21 February
2025, and from nothing else. This file names the source of every line with the command that fetched it and
the hash it had when it arrived.

Pulled 25 September 2026.

## The cut-off

The room forks at block 21,895,237, mined at 1740147203, which is Friday 21 February 2025 at 14:13:23 UTC.
The signed transaction is in the next block, transaction 116 of 202. No receipt ahead of it in that block
touches the Safe, so the fork is the state the signers' transaction met. The check reads receipts, not traces.

```
cast block 21895237 --rpc-url $MAINNET_ARCHIVE_RPC_URL
python exhibits/fork-position.py
```

## The words

The wallet runs Safe v1.1.1. Its slot 0 held the v1.1.1 singleton, `0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F`,
and its own 170 bytes are the v1.1.1 proxy. Safe tagged that release on 13 December 2019, five years before
the fork block. The tag is commit `892448e93f6203b530630f20de45d8a55fde7463` of
`safe-global/safe-smart-account`, and its message reads "Merge pull request #160 from gnosis/deploy_1_1_1".

```
curl -sL https://api.github.com/repos/safe-global/safe-smart-account/git/refs/tags/v1.1.1
curl -sL https://raw.githubusercontent.com/safe-global/safe-smart-account/892448e93f6203b530630f20de45d8a55fde7463/contracts/PATH
```

| file | bytes | sha256 |
|---|---|---|
| `GnosisSafe.sol` | 19766 | `06977c9d783606f2588e5cbc34dac24826c94d6eecbc1d1e7ce19f22009ecbf6` |
| `base/Executor.sol` | 1272 | `4da2a7a8f7161dd721c2229ed4de5e2ac4f3882e7a60b251dd1bd601f27a7410` |
| `base/OwnerManager.sol` | 6748 | `6c5a01dcddd7fd554b35141a00129864e04e086fb5afd4b128f754de61825a51` |
| `common/Enum.sol` | 203 | `5e3d7e92f70cb559255ef36bc16f91195759293991829930c484913d16a0f8f9` |
| `common/MasterCopy.sol` | 1099 | `e76dac70095e8c047e1de4a3b7058348d9768dccece9e8bc6b47dc7cf2e5a254` |
| `common/SelfAuthorized.sol` | 327 | `bb99fd45980f9ba54f612d96a1c3c369e60685ac485ab23553929f6fa310271c` |
| `proxies/Proxy.sol` | 1980 | `f7a59e959a2c0ab968564fccfa5d8aab15d2cbceb08901caaf3e3d220f760b53` |

I didn't copy the files into this tree. Safe released them under LGPL 3.0, and this tree is MIT, so the room
names them by commit and hash and you fetch them yourself.

The link from those sources to the bytes on chain is Sourcify's full match for both addresses, the singleton
and the wallet. Anyone can run that verification again, so it does not ask you to trust the date it was run.

```
curl -s https://sourcify.dev/server/v2/contract/1/0x34CfAC646f301356fAa8B21e94227e3583Fe3F5F
curl -s https://sourcify.dev/server/v2/contract/1/0x1Db92e2EeBC8E0c075a02BeA49a2935BcD2dFCF4
```

## The two sentences the room is built on

The first says what the wallet does when owners sign:

> "Allows to execute a Safe transaction confirmed by required number of owners and then pays the account
> that submitted the transaction."
>
> `GnosisSafe.sol:102`, Safe v1.1.1, 13 December 2019

The second says what operation 1 is. Safe wrote it as code, and the code is short enough to read:

```
else if (operation == Enum.Operation.DelegateCall)
    success = executeDelegateCall(to, data, txGas);
```

`Executor.sol:15-16`. A delegatecall runs someone else's code against the wallet's own storage, and slot 0 is
where the wallet keeps the address of the code it runs (`Proxy.sol:14-16`). So a transaction that the owners
sign with operation 1 can move slot 0. The spec says so in `operation-one-is-delegatecall`, and that is the
power the transaction on 21 February used.

## Line by line

| invariant | where it was read |
|---|---|
| `proxy-forwards-to-slot-zero` | `Proxy.sol:14-16`, the storage slot; `:27-44`, the fallback |
| `exec-requires-threshold-owner-signatures` | `GnosisSafe.sol:102`, the sentence; `:129-140`, the hash over the transaction and nonce; `:189-258`, the check, one owner per signature in ascending order |
| `exec-consumes-the-nonce` | `GnosisSafe.sol:137-140` |
| `operation-one-is-delegatecall` | `Enum.sol:6-11`; `Executor.sol:9-19`, `:31-39`; `GnosisSafe.sol:107`; `Proxy.sol:14-16` |
| `upgrade-only-by-safe-transaction` | `MasterCopy.sol:16-25`; `SelfAuthorized.sol:7-10` |
| `owners-and-threshold-change-only-by-safe-transaction` | `OwnerManager.sol:52-54`, `:74-76`, `:97-99`, `:115-128`; `SelfAuthorized.sol:7-10` |
