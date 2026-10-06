# Room 3, the Balancer room

[The transcript](README.md)

## Balancer's Vault on Ethereum, the block before it was drained

#### `exhibits/balancer-2025-11/Fork.t.sol`

`BalancerForkTest.test_forkStandsAtTheNamedBlock()` passed

It prints nothing; it asserts.

`BalancerForkTest.test_vaultCodeIsTheCodeTheRoomNames()` passed

It prints nothing; it asserts.

`BalancerForkTest.test_theDrainerHasNotBeenDeployedYet()` passed

It prints nothing; it asserts.

#### `exhibits/balancer-2025-11/Provenance.t.sol`

`BalancerProvenanceTest.test_vendoredSourcesAreUnmodified()` passed

It prints nothing; it asserts.

`BalancerProvenanceTest.test_roundingWordsAreTheOnesTheSpecCites()` passed

It prints nothing; it asserts.

`BalancerProvenanceTest.test_everyInvariantNamesItsSource()` passed

It prints nothing; it asserts.

`BalancerProvenanceTest.test_specNamesThePoolTheRoomForks()` passed

It prints nothing; it asserts.

## The drain, rebuilt and replayed on the fork

#### `exhibits/balancer-2025-11/replay/Replay.t.sol`

`ContractTest.testPoC()` passed

```text
museum: fork block: 23717396
museum: before pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 4922.356564867078856521
museum: before pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 6851.581236039298760900
museum: before pool B wstETH/WETH 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0: 4270.841022451395518160
museum: before pool B wstETH/WETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 1977.057709608602150017
before attack: balance of address(beneficiary): 0.000000000000000000
before attack: balance of address(beneficiary): 0.000000000000000000
before attack: balance of address(beneficiary): 0.000000000000000000
before attack: balance of address(beneficiary): 0.000000000000000000
before attack: balance of address(beneficiary): 0.000000000000000000
after attack: balance of address(beneficiary): 6588.253514734564770216
after attack: balance of address(beneficiary): 44.154666372672521145
after attack: balance of address(beneficiary): 6851.122954230748094260
after attack: balance of address(beneficiary): 4227.257976115652204400
after attack: balance of address(beneficiary): 10020.413668455251157822
museum: after pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 298.755056013795788021
museum: after pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 0.458281808550666640
museum: after pool B wstETH/WETH 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0: 43.583046335743313760
museum: after pool B wstETH/WETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 12.405703727320448301
```

## The chain's own drain transaction, run on the fork

#### `exhibits/balancer-2025-11/Transact.t.sol`

`BalancerTransactTest.test_theChainsOwnDrainRunsOnTheFork()` passed

```text
museum: rule set these transactions run under: prague
museum: fork block: 23717396
museum: before pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 4922.356564867078856521
museum: before pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 6851.581236039298760900
museum: before pool B wstETH/WETH 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0: 4270.841022451395518160
museum: before pool B wstETH/WETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 1977.057709608602150017
Start.
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
0xDACf5Fa19b1f720111609043ac67A9818262850c
0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38
sF: 1000000000000000000
sF: 1000000000000000000
sF: 1058109553424427048
trickIndex: 2
trickRate: 1058109553424427048
nonTrickIndex: 0
currentAmp: 200000
tS: 11882638644986383885507
Done with amts1
trickAmt: 17
Here: 0x54B53503c0e2173Df29f8da735fBd45Ee8aBa30d
Doing Batch
startBalancesi: 4922356564867078856521
Asset Deltasi: -4623601508853283067843
startBalancesi: 2596148429267421974637745197985291
Asset Deltasi: -44154666355785411629
startBalancesi: 6851581236039298760900
Asset Deltasi: -6851122954235076557965
Ending Invariant
end__balances[i]: 298755056013795788678
end__balances[i]: 2596148429267377819971389412573662
end__balances[i]: 458281804222202935
poolRate0: 1027347674695370742
poolRate1: 20189496181073356
Start.
0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0
0x93d199263632a4EF4Bb438F1feB99e57b4b5f0BD
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
sF: 1218116415279760760
sF: 1000000000000000000
sF: 1000000000000000000
trickIndex: 0
trickRate: 1218116415279760760
nonTrickIndex: 2
currentAmp: 5000000
tS: 6846019253517852539419
Done with amts1
trickAmt: 4
Here: 0x54B53503c0e2173Df29f8da735fBd45Ee8aBa30d
Doing Batch
startBalancesi: 4270841022451395518160
Asset Deltasi: -4259843451780587743322
startBalancesi: 2596148429267825815119599282622812
Asset Deltasi: -20413668455251157822
startBalancesi: 1977057709608602150017
Asset Deltasi: -1963838806164214870519
Ending Invariant
end__balances[i]: 10997570670807774838
end__balances[i]: 2596148429267805401451144031464990
end__balances[i]: 13218903444387279498
poolRate0: 1051822276543189290
poolRate1: 3887495432689447
museum: drainer code bytes after the chain's own transaction: 17337
museum: after pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 298.755056013795788678
museum: after pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 0.458281804222202935
museum: after pool B wstETH/WETH 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0: 10.997570670807774838
museum: after pool B wstETH/WETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 13.218903444387279498
```

`BalancerTransactTest.test_theEndOfTheBlockIsTheDrainAndOneMoreSwapInPoolA()` passed

```text
museum: rule set these transactions run under: prague
Start.
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
0xDACf5Fa19b1f720111609043ac67A9818262850c
0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38
sF: 1000000000000000000
sF: 1000000000000000000
sF: 1058109553424427048
trickIndex: 2
trickRate: 1058109553424427048
nonTrickIndex: 0
currentAmp: 200000
tS: 11882638644986383885507
Done with amts1
trickAmt: 17
Here: 0x54B53503c0e2173Df29f8da735fBd45Ee8aBa30d
Doing Batch
startBalancesi: 4922356564867078856521
Asset Deltasi: -4623601508853283067843
startBalancesi: 2596148429267421974637745197985291
Asset Deltasi: -44154666355785411629
startBalancesi: 6851581236039298760900
Asset Deltasi: -6851122954235076557965
Ending Invariant
end__balances[i]: 298755056013795788678
end__balances[i]: 2596148429267377819971389412573662
end__balances[i]: 458281804222202935
poolRate0: 1027347674695370742
poolRate1: 20189496181073356
Start.
0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0
0x93d199263632a4EF4Bb438F1feB99e57b4b5f0BD
0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
sF: 1218116415279760760
sF: 1000000000000000000
sF: 1000000000000000000
trickIndex: 0
trickRate: 1218116415279760760
nonTrickIndex: 2
currentAmp: 5000000
tS: 6846019253517852539419
Done with amts1
trickAmt: 4
Here: 0x54B53503c0e2173Df29f8da735fBd45Ee8aBa30d
Doing Batch
startBalancesi: 4270841022451395518160
Asset Deltasi: -4259843451780587743322
startBalancesi: 2596148429267825815119599282622812
Asset Deltasi: -20413668455251157822
startBalancesi: 1977057709608602150017
Asset Deltasi: -1963838806164214870519
Ending Invariant
end__balances[i]: 10997570670807774838
end__balances[i]: 2596148429267805401451144031464990
end__balances[i]: 13218903444387279498
poolRate0: 1051822276543189290
poolRate1: 3887495432689447
museum: end-of-block fork: 23717397
museum: after the drain alone, pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 298.755056013795788678
museum: after the drain alone, pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 0.458281804222202935
museum: after the drain and the next transaction, pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 256.225665224466838146
museum: after the drain and the next transaction, pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 1.722174904005183525
museum: end of block 23,717,397, pool A osETH/wETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 256.225665224466838146
museum: end of block 23,717,397, pool A osETH/wETH 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38: 1.722174904005183525
museum: after the drain alone, pool B wstETH/WETH 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0: 10.997570670807774838
museum: after the drain alone, pool B wstETH/WETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 13.218903444387279498
museum: end of block 23,717,397, pool B wstETH/WETH 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0: 10.997570670807774838
museum: end of block 23,717,397, pool B wstETH/WETH 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2: 13.218903444387279498
museum: pool A asset the next transaction took out: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
museum: amount out: 42.529390789328950532
museum: pool A asset the next transaction put in: 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38
museum: amount in: 1.263893099782980590
```

## The finding filed in review, and the re-run that upholds it, in memory

#### `exhibits/balancer-2025-11/Review.t.sol`

`BalancerReviewTest.test_theFindingsWordsPointAtTheirSources()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_theSpecNeverSaysIt()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_standRegistersTheRoomsToolsAndFundsOneReview()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_theAuditorFilesInReviewAndIsPaid()` passed

```text
The Balancer room: a witness claim filed in review, in memory - not the network's cell
  row                      0
  row state                Claimed
  protocol (Balancer)      0xdc47BaB3450832D97198bF148B1f08f2416AE5BD
  auditor (the visitor)    0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  claim stake (wei)        10000000000000000000
  re-run row               1
  re-run state             AwaitingWindow
  re-run auditor           0x658b2BE8068F3BC36e234CE7c616840f63E51840
  re-run bounty (wei)      20000000000000000000
  result root
0x5b657d874fe0957bbe39a42dd5ab9c22759309bd1cf65f5e1a0f3a29684bbf31
the pot: 40.000000000000000000
the pool before the confirmation: 0.000000000000000000
the auditor holds after: 30.000000000000000000
returned to the protocol: 20.000000000000000000
the re-run's auditor holds after: 20.000000000000000000
```

`BalancerReviewTest.test_theReRunWaitsForItsWindow()` passed

```text
The Balancer room: a witness claim filed in review, in memory - not the network's cell
  row                      0
  row state                Claimed
  protocol (Balancer)      0xdc47BaB3450832D97198bF148B1f08f2416AE5BD
  auditor (the visitor)    0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  claim stake (wei)        10000000000000000000
  re-run row               1
  re-run state             AwaitingWindow
  re-run auditor           0x658b2BE8068F3BC36e234CE7c616840f63E51840
  re-run bounty (wei)      20000000000000000000
  result root
0x5b657d874fe0957bbe39a42dd5ab9c22759309bd1cf65f5e1a0f3a29684bbf31
```

`BalancerReviewTest.test_refusesThreeSeatsOnTwoKeys()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_refusesAnAuditorTheStandDidNotName()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_refusesAKeyThatDidNotStandTheFixture()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_refusesAnyChainButMemory()` passed

It prints nothing; it asserts.

`BalancerReviewTest.test_filesOnce()` passed

```text
The Balancer room: a witness claim filed in review, in memory - not the network's cell
  row                      0
  row state                Claimed
  protocol (Balancer)      0xdc47BaB3450832D97198bF148B1f08f2416AE5BD
  auditor (the visitor)    0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  claim stake (wei)        10000000000000000000
  re-run row               1
  re-run state             AwaitingWindow
  re-run auditor           0x658b2BE8068F3BC36e234CE7c616840f63E51840
  re-run bounty (wei)      20000000000000000000
  result root
0x5b657d874fe0957bbe39a42dd5ab9c22759309bd1cf65f5e1a0f3a29684bbf31
```
