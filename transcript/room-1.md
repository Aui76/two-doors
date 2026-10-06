# Room 1, the auditor's room

[The transcript](README.md)

## Beanstalk on Ethereum, the block before it was drained

#### `exhibits/beanstalk-2022-04/Fork.t.sol`

`BeanstalkForkTest.test_forkStandsAtTheNamedBlock()` passed

It prints nothing; it asserts.

`BeanstalkForkTest.test_beanstalkCodeIsTheCodeTheVerdictNames()` passed

It prints nothing; it asserts.

`BeanstalkForkTest.test_theAttackHasNotBeenWrittenYet()` passed

It prints nothing; it asserts.

#### `exhibits/beanstalk-2022-04/Provenance.t.sol`

`ProvenanceTest.test_vendoredSourcesAreUnmodified()` passed

It prints nothing; it asserts.

`ProvenanceTest.test_governanceConstantsAreTheOnesTheSpecCites()` passed

It prints nothing; it asserts.

`ProvenanceTest.test_everyInvariantNamesItsSource()` passed

It prints nothing; it asserts.

## What the spec never says: the attack it allows, replayed on the fork

#### `exhibits/beanstalk-2022-04/replay/Replay.t.sol`

`ContractTest.testExploit()` passed

```text
museum: door one: the April 2022 Beanstalk drain, replayed on the fork
museum: the fork block: 14595905
museum: attacker USDC before the drain: 0.000000
Initial USDC balancer of attacker: 0
After initial ETH -> BEAN swap, Bean balance of attacker:: 217860
After BEAN deposit to SiloV2Facet, Bean balance of attacker:: 0
After deposit, Bean balance of attacker:: 0
After adding 3crv liquidity , bean3Crv_f balance of attacker:: 787617662720228963344921175
After Curvebean3Crv_f balance of attacker:: 787617662720228963344921175
After calling beanstalkgov.emergencyCommit() , bean3Crv_f balance of attacker:: 860843389256029477974324118
After removing liquidity from crvbean pool , bean3Crv_f balance of attacker:: 0
premiums[0]:: 315000000000000000000000
premiums[1]:: 450000000000
premiums[2]:: 135000000000
tempAmounts[0]:: 350315000000000000000000000
tempAmounts[1]:: 500450000000000
tempAmounts[2]:: 150135000000000
After removing 3crv liquidity from 3crv pool, usdc balance of attacker:: 542512065615197
After Flashloan repay, usdc balance of attacker:: 42062065615197
museum: attacker USDC after the drain: 42062065.615197
```

## The finding filed in review, and the re-run that upholds it, in memory

#### `exhibits/beanstalk-2022-04/Review.t.sol`

`ReviewTest.test_theFindingsWordsPointAtTheirSources()` passed

It prints nothing; it asserts.

`ReviewTest.test_theFindingIsTheGapsWords()` passed

It prints nothing; it asserts.

`ReviewTest.test_standRegistersTheRoomsToolsAndFundsOneReview()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
```

`ReviewTest.test_theAuditorFilesInReviewAndIsPaid()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
The auditor's room: a witness claim filed in review - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  row                      0
  row state                Claimed
  protocol (Beanstalk)     0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor (the visitor)    0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  claim stake (wei)        10000000000000000000
  re-run row               1
  re-run state             AwaitingWindow
  re-run auditor           0x658b2BE8068F3BC36e234CE7c616840f63E51840
  re-run bounty (wei)      20000000000000000000
  result root
0x0f00f111557e69da997a934b11450fc1c68964761db51264b16fe1c23d265974
the pot: 40.000000000000000000
the pool before the confirmation: 0.000000000000000000
the auditor holds after: 30.000000000000000000
returned to the protocol: 20.000000000000000000
the re-run's auditor holds after: 20.000000000000000000
```

`ReviewTest.test_theReRunWaitsForItsWindow()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
The auditor's room: a witness claim filed in review - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  row                      0
  row state                Claimed
  protocol (Beanstalk)     0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor (the visitor)    0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  claim stake (wei)        10000000000000000000
  re-run row               1
  re-run state             AwaitingWindow
  re-run auditor           0x658b2BE8068F3BC36e234CE7c616840f63E51840
  re-run bounty (wei)      20000000000000000000
  result root
0x0f00f111557e69da997a934b11450fc1c68964761db51264b16fe1c23d265974
```

`ReviewTest.test_refusesThreeSeatsOnTwoKeys()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
```

`ReviewTest.test_refusesAnAuditorTheStandDidNotName()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
```

`ReviewTest.test_refusesAKeyThatDidNotStandTheFixture()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
```

`ReviewTest.test_refusesFindingWordsTheStandDidNotFreeze()` passed

It prints nothing; it asserts.

`ReviewTest.test_filesOnce()` passed

```text
The auditor's room fixture: the DAN hull at 7fd937a - not the network's cell
  chain id                 31337
  fixture key (protocol)   0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  ClaimDisputeModule       0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  AuditCell runtime bytes  20909
  decision window (s)      300
  in-audit window (s)      600
  min audit window (s)     600
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  70000000000000000000
The auditor's room: a witness claim filed in review - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  row                      0
  row state                Claimed
  protocol (Beanstalk)     0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor (the visitor)    0x5B8461f0Ee439E70a75220f965F9A162c809BF41
  claim stake (wei)        10000000000000000000
  re-run row               1
  re-run state             AwaitingWindow
  re-run auditor           0x658b2BE8068F3BC36e234CE7c616840f63E51840
  re-run bounty (wei)      20000000000000000000
  result root
0x0f00f111557e69da997a934b11450fc1c68964761db51264b16fe1c23d265974
```
