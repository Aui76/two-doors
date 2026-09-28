# Room 2, the two doors

[The transcript](README.md)

## Door one, the attacker's: the attack replayed on the fork

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

## Door two, the discoverer's: the fixture and the filing, in memory

#### `exhibits/beanstalk-2022-04/Fixture.t.sol`

`FixtureTest.test_standsTheHullUnderTheTestnetProfile()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0xC37aacEDc6AD1Ca2c0aCf9B5f268D480bE31187D
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
fixture key AUDIT (wei): 50000000000000000000
AuditCell runtime bytes: 20909
```

`FixtureTest.test_mintIsOneRowAndTheClaimStakeAgainstIt()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0xC37aacEDc6AD1Ca2c0aCf9B5f268D480bE31187D
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
requiredClaimStake (wei): 10000000000000000000
```

`FixtureTest.test_theOpenSeatIsAChoice()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x0000000000000000000000000000000000000000
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0xB210725ffcda9B1091BF5dD6995E2389e97B4470
  StructuralUpgradeModule  0xc6F5a8D29AB8Cb8e87A5A44764193bb84A2262B6
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
```

`FixtureTest.test_refusesTheFixtureKeyAsItsOwnAuditor()` passed

It prints nothing; it asserts.

`FixtureTest.test_refusesEveryNetworkKeyInTheAuditorSeat()` passed

It prints nothing; it asserts.

`FixtureTest.test_standsOnlyOnBaseSepoliaOrTheRehearsal()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 84532
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0xC37aacEDc6AD1Ca2c0aCf9B5f268D480bE31187D
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
```

#### `exhibits/beanstalk-2022-04/Filing.t.sol`

`FilingTest.test_theGapsWordsPointAtTheirSources()` passed

It prints nothing; it asserts.

`FilingTest.test_standMakesDoorTwosAdminActsInItsOneBroadcast()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
```

`FilingTest.test_filesWithTheFixtureKeyAsProtocol()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  row                      0
  protocol                 0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor                  0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  discoverer               0xbEf90eBc5ACBa59135460e426f10A107495F646E
  fixture key's seat       protocol
  row state                4
  gap status               Filed
  filing stake (wei)       10000000000000000000
  filed at                 ReadTheFiling prints it once the filing is mined
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
filing stake (wei): 10000000000000000000
result root: 0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
```

`FilingTest.test_filesWithTheFixtureKeyAsDiscoverer()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  row                      0
  protocol                 0xbEf90eBc5ACBa59135460e426f10A107495F646E
  auditor                  0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  discoverer               0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  fixture key's seat       discoverer
  row state                4
  gap status               Filed
  filing stake (wei)       10000000000000000000
  filed at                 ReadTheFiling prints it once the filing is mined
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
```

`FilingTest.test_silenceConfirmsTheGapAndReturnsTheStake()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  row                      0
  protocol                 0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor                  0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  discoverer               0xbEf90eBc5ACBa59135460e426f10A107495F646E
  fixture key's seat       protocol
  row state                4
  gap status               Filed
  filing stake (wei)       10000000000000000000
  filed at                 ReadTheFiling prints it once the filing is mined
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
```

`FilingTest.test_adoptionIsPaidFromTheProtocol()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  row                      0
  protocol                 0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor                  0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  discoverer               0xbEf90eBc5ACBa59135460e426f10A107495F646E
  fixture key's seat       protocol
  row state                4
  gap status               Filed
  filing stake (wei)       10000000000000000000
  filed at                 ReadTheFiling prints it once the filing is mined
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
```

`FilingTest.test_theRowSettlesBesideTheGap()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  row                      0
  protocol                 0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor                  0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  discoverer               0xbEf90eBc5ACBa59135460e426f10A107495F646E
  fixture key's seat       protocol
  row state                4
  gap status               Filed
  filing stake (wei)       10000000000000000000
  filed at                 ReadTheFiling prints it once the filing is mined
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
row state after its window: 6
auditor AUDIT after its window (wei): 40625000000000000000
```

`FilingTest.test_refusesThreeSeatsOnTwoKeys()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
```

`FilingTest.test_refusesAnAuditorTheStandDidNotName()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
```

`FilingTest.test_refusesAKeyThatDidNotStandTheFixture()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
```

`FilingTest.test_refusesGapWordsTheStandDidNotFreeze()` passed

It prints nothing; it asserts.

`FilingTest.test_filesOnce()` passed

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 31337
  fixture key              0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  genesis auditor          0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  CellToken                0x4E94bc6BEe56055EE08325d3c327DC99cDD45ab8
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  StructuralUpgradeModule  0x08022159A0A78a189229E96C684D4629E418C36c
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  50000000000000000000
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 31337
  AuditCell                0x4fe58B74404E7A54849CD6b434240FA55E52f06C
  SpecGapModule            0x4DAB1c1794Ed63C914C2cd64be4E63C8945E29e1
  row                      0
  protocol                 0xB4f6a60Cb9fE65A2E90ddd02e47f5c139B1C14a3
  auditor                  0x34FDFDF44132766B224fE4F738F8F4311D3E86Fc
  discoverer               0xbEf90eBc5ACBa59135460e426f10A107495F646E
  fixture key's seat       protocol
  row state                4
  gap status               Filed
  filing stake (wei)       10000000000000000000
  filed at                 ReadTheFiling prints it once the filing is mined
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
```

### Door two on Base Sepolia, from the committed records

`exhibits/beanstalk-2022-04/fixture/record/84532.json`, which the stand wrote:

```text
Room 2 fixture: an instance of the DAN hull at 0f3eaf8, deployed on Base Sepolia by the museum for one filing. Not the network's cell.

AssignmentModule          0xe470890315f59f9aD5dEFc0BEaA65c8fb3D2B1a6
AuditCell                 0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2
BlockhashEntropy          0xe0B7bb2d1A74F52193A4c81c093172e60e0b52ab
CellEscrow                0x2D2cb5C9E37B9A047291703e829259009a3339a6
CellToken                 0x9C667B21C072D2Cf816fF458D6698be8D21f6A33
ClaimDisputeModule        0x9Ec29eC41137d0aCc1Af4f9269D74C844f6eBFC7
FmeaRegistry              0x13be4c808b3e36047cF99B925E24E82F2479a1dB
IntegrityReviewModule     0xa1E2E7Afbc28DE286B2cD91bbE5B9B1b0CC8A5d4
IssuanceModule            0x45Fc8848c7Fe1cC0D227Ac52D5e19Ed5c742660f
SpecArbiterModule         0x12fb0d9415C9a35A41d7E47Af8953C1d5d751E3D
SpecGapModule             0xd17E1b67F438532036F279b08b34DEb264338a9C
StructuralUpgradeModule   0x2D068330484DF8269218f804Fdad6d04BfE041E0
auditCellRuntimeBytes     20909
auditCellRuntimeCodehash  0x03096cea080c40581f861a2172a23c2bed32a183e9a131d63cf18e214faa69d1
chainId                   84532
fixtureKey                0x85F9549e4fdCa52fF56742B27b6C037ae5B06966
gapClassId                0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
gapContext                0xd1ad769dcd6d5c9503a2c0c16566ead2c91b07af6da3664dec2113071299f87d
gapInvariantId            0xdf72d13f08e815ecf21fe62b2f24a6283826a0b12cc5bb1769ab5288b175bc95
gapLocation               0x1fd9a9d992908f2c1107d52442c6023f868a043c13698b6b6ad64915f4f4ad66
gapWitness                0x67ac345b341006be892721e935bfc71542d27e8ca67dabe79a150ca90743e53c
gapWords                  exhibits/beanstalk-2022-04/filing/gap.json
genesisAuditor            0xEdB37f4C862fC94A63Fe826baCefF2fF17016839
genesisMint               50000000000000000000
hull                      0f3eaf8
standCommit               a3d577a0294da949038c96ffe89949157a50e47b
```

`exhibits/beanstalk-2022-04/fixture/record/84532.filing.json`, which the filing wrote:

```text
Room 2, door two: a spec gap filed on the fixture, an instance of the DAN hull at 0f3eaf8 on Base Sepolia. Not the network's cell.

AuditCell           0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2
SpecGapModule       0xd17E1b67F438532036F279b08b34DEb264338a9C
artifactHash        0x2ff59388cd5e1842a3d057338010945a779a6c7d57abfb5e9ddc697838700870
auditId             0
auditor             0xEdB37f4C862fC94A63Fe826baCefF2fF17016839
chainId             84532
classId             0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
contextRoot         0xd1ad769dcd6d5c9503a2c0c16566ead2c91b07af6da3664dec2113071299f87d
discoverer          0xfEE57981D498a5b3882ac464344687A12c8d4cC9
evaluatorToolId     0xac6b12f92c30ef9b42ba27fa763e9753304bc08051b4fe21a9cbe1e7e9faec71
filingStake         10000000000000000000
finderToolId        0x3a05af87d6078f203b5cb12dfa6a1b76fe4c3567ce1026302e580a4bd50dbb92
fixtureKeySeat      protocol
gapWords            exhibits/beanstalk-2022-04/filing/gap.json
hull                0f3eaf8
invariantId         0xdf72d13f08e815ecf21fe62b2f24a6283826a0b12cc5bb1769ab5288b175bc95
locationCommitment  0x1fd9a9d992908f2c1107d52442c6023f868a043c13698b6b6ad64915f4f4ad66
protocol            0x85F9549e4fdCa52fF56742B27b6C037ae5B06966
resultRoot          0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
specHash            0x67134c2f4385d783b8d7bf0833d9e8ef2d0dac0a4c3e78acc038405b27d0088a
witnessCommitment   0x67ac345b341006be892721e935bfc71542d27e8ca67dabe79a150ca90743e53c
```

`exhibits/beanstalk-2022-04/fixture/record/84532.confirm.json`, the transaction that closed the gap:

```text
Room 2, door two: silence confirmed the spec gap on the fixture, an instance of the DAN hull at 0f3eaf8 on Base Sepolia. Not the network's cell.

chainId           84532
SpecGapModule     0xd17E1b67F438532036F279b08b34DEb264338a9C
auditId           0
classId           0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
status            Confirmed
confirmedBy       0xfEE57981D498a5b3882ac464344687A12c8d4cC9
tx                0x36d26fe400734e1c4b1ce2efdf6c1297f5f348519510ea1e7019cf1ea43712b4
block             47385463
timestamp         1790539214
stakeReturnedTo   0xfEE57981D498a5b3882ac464344687A12c8d4cC9
stakeReturnedWei  10000000000000000000
```

`exhibits/beanstalk-2022-04/fixture/record/84532.transactions.json`: 75 transactions the stand and the filing sent, 0 of them failed.

| # | script | type | contract | function | block | tx |
|---|---|---|---|---|---|---|
| 0 | stand | CREATE2 | DiscovererPayoutLib |  | 47384931 | [0x7390e803…](https://sepolia.basescan.org/tx/0x7390e8035e01c85080a6407da498af3ed62c1a7caada877718b78b633faf2e05) |
| 1 | stand | CREATE2 | ToolUseLib |  | 47384932 | [0xec70a3c6…](https://sepolia.basescan.org/tx/0xec70a3c61e144dbec037de3d271eb7f5d4b8fed5e580a5df4ff212ce22c2420c) |
| 2 | stand | CREATE2 | CellLogicLib |  | 47384933 | [0xd1c1ae23…](https://sepolia.basescan.org/tx/0xd1c1ae23e084f16db35b8ffa8db4a8a674370c446b3818e974998c9772f2c077) |
| 3 | stand | CREATE2 | SubmitAuditLib |  | 47384934 | [0x293a72b9…](https://sepolia.basescan.org/tx/0x293a72b9f688ef6dc587aae5fc3d470ee26f6a2bfd38c2f81b4ea48b4b29788e) |
| 4 | stand | CREATE | CellToken |  | 47384935 | [0xdba56627…](https://sepolia.basescan.org/tx/0xdba566273c48640e82fae61c4ad576b83faa3272d8cfcd0c4926040fbb2b696f) |
| 5 | stand | CREATE | AuditCell |  | 47384936 | [0x171d5aed…](https://sepolia.basescan.org/tx/0x171d5aedf40ce2d0606e8ae857051bf249ae1627d3ccda52f32489b09b55b8d6) |
| 6 | stand | CALL | AuditCell | setGenesisBootstrap | 47384937 | [0xd1b6241f…](https://sepolia.basescan.org/tx/0xd1b6241f5133cf2c7dcc7dd62290cd4abafbfa8081e56972c9dcc881abe7a4ce) |
| 7 | stand | CREATE | CellEscrow |  | 47384938 | [0xf86f45f5…](https://sepolia.basescan.org/tx/0xf86f45f56f3f0830bdc0ce4e1dc075958231c933410f6f3125ab4e2726567135) |
| 8 | stand | CREATE | IssuanceModule |  | 47384939 | [0xebb81a0a…](https://sepolia.basescan.org/tx/0xebb81a0ab66613f592a4d34d30bdece3b53106778f89d440b10b50d3bbe9b611) |
| 9 | stand | CREATE | ClaimDisputeModule |  | 47384940 | [0x84ee0152…](https://sepolia.basescan.org/tx/0x84ee01529777a2444c21974e9a867ae546b78e82268a28faf11bcdf16e0ee061) |
| 10 | stand | CREATE | SpecGapModule |  | 47384941 | [0x699972c8…](https://sepolia.basescan.org/tx/0x699972c8a53c9dddae9d187db09c4b999f6f9a1b8da2ea4ab4d04697e7920de1) |
| 11 | stand | CREATE | SpecArbiterModule |  | 47384942 | [0x7d6142bf…](https://sepolia.basescan.org/tx/0x7d6142bf0ecf4f61d0b084771d7f17d2490dee648a85cc609a07444aa4c8f3c1) |
| 12 | stand | CREATE | IntegrityReviewModule |  | 47384943 | [0xb9a1aac9…](https://sepolia.basescan.org/tx/0xb9a1aac95853c78316086f40675bb4e57f59803597db59522ceb8b5051ba1c75) |
| 13 | stand | CREATE | StructuralUpgradeModule |  | 47384944 | [0x5f08026d…](https://sepolia.basescan.org/tx/0x5f08026d4ccd64cac088b932ec38af6690ebfafaa7963ee064d630b8020e9c8d) |
| 14 | stand | CREATE | FmeaRegistry |  | 47384945 | [0x4d0187b0…](https://sepolia.basescan.org/tx/0x4d0187b08a276f61be11b7e7cb8a4646dc61f4d3ff55402a30f6c5dd96df4460) |
| 15 | stand | CREATE | AssignmentModule |  | 47384946 | [0xf1b4687a…](https://sepolia.basescan.org/tx/0xf1b4687a672122ad7d7a626b4e63e660c642d68ee5e29cb8e1e81435c3c918ef) |
| 16 | stand | CREATE | BlockhashEntropy |  | 47384947 | [0x5e13edbd…](https://sepolia.basescan.org/tx/0x5e13edbdd9d128374f0e962902d3370af0b345c81ae443e2a8093f07d92d1783) |
| 17 | stand | CALL | IssuanceModule | wire | 47384948 | [0xe35341c3…](https://sepolia.basescan.org/tx/0xe35341c37b16774503b253947560505d532e8400d3a16392f024104908ce7537) |
| 18 | stand | CALL | IssuanceModule | setEmaToMintBps | 47384949 | [0x4fc185c7…](https://sepolia.basescan.org/tx/0x4fc185c73b853ac02c4b60b99edab0c4719f6ea460551f3aa55ba1d9c4e60b56) |
| 19 | stand | CALL | IssuanceModule | setMintLpCapBps | 47384950 | [0x27ad689f…](https://sepolia.basescan.org/tx/0x27ad689fa5a176f0dd533809ca5bb9128cb63b4ffdf2c2e2600a864c3bbbfcd0) |
| 20 | stand | CALL | ClaimDisputeModule | wire | 47384951 | [0x1c329f5a…](https://sepolia.basescan.org/tx/0x1c329f5a2c46ababe899323a18e1c97e64083687ba221eda79cf336c3d9860a2) |
| 21 | stand | CALL | FmeaRegistry | wireClaimModule | 47384952 | [0x9e1090ce…](https://sepolia.basescan.org/tx/0x9e1090ce509e598d417b578308802634c395f775259e9077433d6dcdfcfa2fdc) |
| 22 | stand | CALL | ClaimDisputeModule | wireFmeaRegistry | 47384953 | [0x641e0f6c…](https://sepolia.basescan.org/tx/0x641e0f6c67b92b6b424f9373004bab780051db944e3ae8ee8745974c58d7d0f2) |
| 23 | stand | CALL | AssignmentModule | wire | 47384954 | [0xe885a73a…](https://sepolia.basescan.org/tx/0xe885a73a0fc4c1ab57643f94cab16368915f7ac262ccec53813553a54a6ad2e0) |
| 24 | stand | CALL | SpecGapModule | wire | 47384955 | [0xd1b57156…](https://sepolia.basescan.org/tx/0xd1b57156f4a923240db782d2c59274fcac389abad9cf83fc81df6aa04403c308) |
| 25 | stand | CALL | SpecArbiterModule | wire | 47384956 | [0x570df77b…](https://sepolia.basescan.org/tx/0x570df77b105a598ecb9eaa1d0e04b26af8e53c44404878d7a543d7b6493cc74b) |
| 26 | stand | CALL | IntegrityReviewModule | wire | 47384957 | [0xb0a49596…](https://sepolia.basescan.org/tx/0xb0a49596fb45b9339f5122f10a32d9fc36066368db4e3c4b4be2ac89bd4cede1) |
| 27 | stand | CALL | StructuralUpgradeModule | wire | 47384958 | [0x4d75314d…](https://sepolia.basescan.org/tx/0x4d75314d1df7719f9a5ccbc947860b2c3d6265b424e8764a15651c357412ef11) |
| 28 | stand | CALL | IssuanceModule | setStructuralModule | 47384959 | [0xf3cfdc06…](https://sepolia.basescan.org/tx/0xf3cfdc063ffd3a77cdf3de566170f07134099e6bdb6558b63ef3534526e75a01) |
| 29 | stand | CALL | CellEscrow | setFounderReleaseTarget | 47384960 | [0x4773cac1…](https://sepolia.basescan.org/tx/0x4773cac1b17c8c03331c100373e1056d25c16e5caa602d9558eeaba7d9c0433c) |
| 30 | stand | CALL | CellEscrow | setNetwork | 47384961 | [0x3a8ebb64…](https://sepolia.basescan.org/tx/0x3a8ebb64be4ef0ed99627ffd1816a4066fa9d02d79bc8b8136a3178633348d90) |
| 31 | stand | CALL | CellEscrow | setIssuanceModule | 47384962 | [0x9b3169ee…](https://sepolia.basescan.org/tx/0x9b3169ee5fe43e1c1c6bc70a4b5b78700c8beff42d245680fee419b8183608ed) |
| 32 | stand | CALL | CellEscrow | setStructuralUpgradeModule | 47384963 | [0xf795faa0…](https://sepolia.basescan.org/tx/0xf795faa058dc4453a124241a0989232d2d57863cb39c6ae9592e13fe48c40dfa) |
| 33 | stand | CALL | CellEscrow | setIntegrityReviewModule | 47384964 | [0xeba6a3f6…](https://sepolia.basescan.org/tx/0xeba6a3f694fd238ab1de7438e19e69ca85b2e52ea4f1f4b21c0375c394c1aea1) |
| 34 | stand | CALL | AuditCell | setTreasuryEscrow | 47384965 | [0x2bf2c2a7…](https://sepolia.basescan.org/tx/0x2bf2c2a7a916b0e549982a78318c5af27e28b881b90c15a2ebb07e01b572cad3) |
| 35 | stand | CALL | AuditCell | setIssuanceModule | 47384966 | [0x3d7b3f59…](https://sepolia.basescan.org/tx/0x3d7b3f593744009b417a3b0e1d55f8262f5c5397dc687d3455a0a636ff3b1dd4) |
| 36 | stand | CALL | AuditCell | setDisputeModule | 47384967 | [0x99c478ec…](https://sepolia.basescan.org/tx/0x99c478ecc6dcb844a09addde372d6d89692945de874b89f60f1cabc8c3ff4234) |
| 37 | stand | CALL | AuditCell | setDisputeModule | 47384969 | [0x468cdb2f…](https://sepolia.basescan.org/tx/0x468cdb2fdf594874d508caa6fee7298f8b9aa95064539bf8db39d88f14de137f) |
| 38 | stand | CALL | AuditCell | setDisputeModule | 47384970 | [0x11243a49…](https://sepolia.basescan.org/tx/0x11243a49a8d2fde0276724428356ffebf90447422871dbcb8a8cb0dfb8e6f9f3) |
| 39 | stand | CALL | AuditCell | setDisputeModule | 47384971 | [0x1a927fa6…](https://sepolia.basescan.org/tx/0x1a927fa6e095bd7c82aab7b7205e4dd662e76b51c338734c5b7d048177503217) |
| 40 | stand | CALL | AuditCell | setDisputeModule | 47384972 | [0x3b33ccf2…](https://sepolia.basescan.org/tx/0x3b33ccf21a5e9e0ebe8b9f7d7409ca72765902d07942c76ff795290577304558) |
| 41 | stand | CALL | AuditCell | setAssignmentModule | 47384973 | [0x1aed6f46…](https://sepolia.basescan.org/tx/0x1aed6f46a6318a18276dae6e7ce759cead8a70ce373e4e3c03967618b4521bd7) |
| 42 | stand | CALL | AuditCell | setEntropyProvider | 47384974 | [0x3063d9c4…](https://sepolia.basescan.org/tx/0x3063d9c428c859b078910c1acaae9e5af182815514f1e4cef50f24823151c1ec) |
| 43 | stand | CALL | AuditCell | setParam | 47384975 | [0x3d387871…](https://sepolia.basescan.org/tx/0x3d3878715644a96fdf20e628a059f3200a3854abd026e61716766410ad59c06e) |
| 44 | stand | CALL | AuditCell | setParam | 47384976 | [0x50bf9fc1…](https://sepolia.basescan.org/tx/0x50bf9fc1651407511a1af85b5147690179cac6f82d93e801b10a56d3382ce5f6) |
| 45 | stand | CALL | AuditCell | setParam | 47384977 | [0x48404af7…](https://sepolia.basescan.org/tx/0x48404af781a7211d6afadf6f0d4423d5a878b4458dcda18e72c1399c3e203a48) |
| 46 | stand | CALL | AuditCell | setParam | 47384978 | [0xfebda28c…](https://sepolia.basescan.org/tx/0xfebda28c0c988ad0e54167e786c61a9f94612a12ec7f96b635003804a6cedc68) |
| 47 | stand | CALL | AuditCell | setParam | 47384979 | [0xc4b90571…](https://sepolia.basescan.org/tx/0xc4b905711eaeeb6c958f1f093444badeb786871b37529c6b2c58f395cf351cc2) |
| 48 | stand | CALL | ClaimDisputeModule | setProtocolClaimDecisionWindow | 47384980 | [0x0035d63f…](https://sepolia.basescan.org/tx/0x0035d63f21f58ce2f0ac155e04c086f09d6b4beb3462094d445e34b126239a34) |
| 49 | stand | CALL | AuditCell | setParam | 47384981 | [0xeb70c96f…](https://sepolia.basescan.org/tx/0xeb70c96f7c0223d162a61d8028ba19c9be3a4c44476335bb25afb6e8a440a1dc) |
| 50 | stand | CALL | SpecArbiterModule | setSpecChallengeStake | 47384982 | [0xe6191b16…](https://sepolia.basescan.org/tx/0xe6191b1659b051de2094cb86236009b4da37f3f0b0fc30675c8c115efd3627db) |
| 51 | stand | CALL | IntegrityReviewModule | setIntegrityFilingStake | 47384983 | [0xbc9a9c86…](https://sepolia.basescan.org/tx/0xbc9a9c862c6124156cf52ba2b87b9a2d250feb658a2d85ed6a0c5de25794ce55) |
| 52 | stand | CALL | IntegrityReviewModule | setIntegrityContestStake | 47384984 | [0xff614de6…](https://sepolia.basescan.org/tx/0xff614de67b9317c713325fc96963eaa580651bcb06f6fd2e64ce3da5cbc23752) |
| 53 | stand | CALL | StructuralUpgradeModule | setGapFilingStake | 47384985 | [0x67938694…](https://sepolia.basescan.org/tx/0x67938694034824b1c45c2b3eb3f41c8afed370781325b6da26cef86cfc958a5d) |
| 54 | stand | CALL | SpecArbiterModule | setSpecChallengeFee | 47384986 | [0xea5efa8e…](https://sepolia.basescan.org/tx/0xea5efa8e7a97590860d87350ac9b702132a9d46a70f0e14465436aee79f8e98e) |
| 55 | stand | CALL | AuditCell | registerTool | 47384987 | [0xf8fda210…](https://sepolia.basescan.org/tx/0xf8fda2100caae387ad02842d6ea21c460bf04743be7706037e753d52e5f4daae) |
| 56 | stand | CALL | AuditCell | registerTool | 47384988 | [0x171ca02b…](https://sepolia.basescan.org/tx/0x171ca02be927f79c9d92ddfc8b3c32ae5fddae44ddb391452c14bc76cd779a9d) |
| 57 | stand | CALL | AuditCell | registerTool | 47384989 | [0xa4b1c499…](https://sepolia.basescan.org/tx/0xa4b1c4997da762c606f662097b150df1e88a785f947083e9795b5f55887f6c31) |
| 58 | stand | CALL | AuditCell | registerTool | 47384990 | [0xe9896028…](https://sepolia.basescan.org/tx/0xe98960281f0350ffd070ff3fb9699a86e6eb79acf65de9c932b3b176175e5352) |
| 59 | stand | CALL | AuditCell | registerTool | 47384991 | [0x9b523eb6…](https://sepolia.basescan.org/tx/0x9b523eb6dff1a18a5b608df4704840f375e27130e1b2a821e399d3f0e52f75e8) |
| 60 | stand | CALL | AuditCell | registerTool | 47384992 | [0x1338470d…](https://sepolia.basescan.org/tx/0x1338470dbf6fbbcaadd46089391904d3af8dd6014e535a77b737f5b59e4c23d8) |
| 61 | stand | CALL | AuditCell | setToolWitnessFlags | 47384993 | [0x3ff6aa38…](https://sepolia.basescan.org/tx/0x3ff6aa382db25a2f415ca26a0fe892a9a034e5e3f53bfd8b5b124591915036f5) |
| 62 | stand | CALL | SpecGapModule | registerClass | 47384994 | [0x7a5969dd…](https://sepolia.basescan.org/tx/0x7a5969dd55c1631a80bb0b40a7b388bb1723eb0b74c8e753296e7d0a07197505) |
| 63 | stand | CALL | CellToken | genesisMint | 47384995 | [0xfca511b5…](https://sepolia.basescan.org/tx/0xfca511b55683fdbf7795b069c96f22bf643d21f518f723ff413db51652e52bde) |
| 64 | stand | CALL | CellToken | setMinter | 47384996 | [0xe081bfda…](https://sepolia.basescan.org/tx/0xe081bfdaed19ec8ac6e75c330ab2d1f5d05a7000e66ad91b2da5e1ae9fe84594) |
| 65 | filing | CALL |  | register | 47385250 | [0xdec225f7…](https://sepolia.basescan.org/tx/0xdec225f79c117fc7f05510c56a7657a37063c7676a642da1e347b675f6e16196) |
| 66 | filing | CALL |  | approve | 47385250 | [0xf1c03783…](https://sepolia.basescan.org/tx/0xf1c037831c06996d2db2db4f8295b156408a3dd3af8d54e3097512f5cbef07e4) |
| 67 | filing | CALL |  | submitArtifactAudit | 47385251 | [0x1e798a6e…](https://sepolia.basescan.org/tx/0x1e798a6e1915bff956f005b42acf8bb230e4349e9f5e750962693262fd07cec8) |
| 68 | filing | CALL |  | protocolAcceptAuditor | 47385252 | [0x9311d0ce…](https://sepolia.basescan.org/tx/0x9311d0ce566d69da0c1d7c246f4c99f4e7c642200dc4458281ecfa95694fb0ad) |
| 69 | filing | CALL |  | acceptAudit | 47385253 | [0xc220ff75…](https://sepolia.basescan.org/tx/0xc220ff75bb546a8b761b4bb9f37d3e4cd14fa58dae637d0f5b51a0b82ad3f0c5) |
| 70 | filing | CALL |  | provePass | 47385254 | [0x2e94b58f…](https://sepolia.basescan.org/tx/0x2e94b58f7ed0e9e42bb1e9c269cbf3a2d1bdf2c2491b8d2be41ebe04ef6002dd) |
| 71 | filing | CALL |  | transfer | 47385254 | [0xefe8b8dd…](https://sepolia.basescan.org/tx/0xefe8b8dd7513bfa3c9ce629b95c7cc0d22d2783aaf6b02af3476d69707e17b11) |
| 72 | filing | CALL |  | register | 47385255 | [0xa5cfba38…](https://sepolia.basescan.org/tx/0xa5cfba38b7bfcaa7223694a691cded754b4d871ff9eb1d1f8457b42b4face0ec) |
| 73 | filing | CALL |  | approve | 47385256 | [0xdc78e5a4…](https://sepolia.basescan.org/tx/0xdc78e5a40f042dbd06f7b096a3a75821b6b783a738d1bb454481b8e0ce6c7bc7) |
| 74 | filing | CALL |  | openSpecGap | 47385257 | [0x7ac4a1f5…](https://sepolia.basescan.org/tx/0x7ac4a1f5256d25f5c7ab76080086e01edbed6f48cd9260cf51dbde9c8787b5ac) |

### Door two on Base Sepolia, read from the chain in this run

<!-- live -->
`ReadTheFixture` and `ReadTheFiling` read the chain from https://sepolia.base.org and send nothing:

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 84532
  fixture key              0x85F9549e4fdCa52fF56742B27b6C037ae5B06966
  genesis auditor          0xEdB37f4C862fC94A63Fe826baCefF2fF17016839
  AuditCell                0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2
  CellToken                0x9C667B21C072D2Cf816fF458D6698be8D21f6A33
  SpecGapModule            0xd17E1b67F438532036F279b08b34DEb264338a9C
  StructuralUpgradeModule  0x2D068330484DF8269218f804Fdad6d04BfE041E0
  AuditCell runtime bytes  20909
  decision window (s)      300
  protocol decision (s)    300
  in-audit window (s)      600
  min audit window (s)     600
  claim resolution (s)     1800
  claim filing stake (wei) 10000000000000000000
  fixture key AUDIT (wei)  0
  read back from           exhibits/beanstalk-2022-04/fixture/record/84532.json
```

```text
Room 2, door two: a spec gap on the fixture - not the network's cell
  chain id                 84532
  AuditCell                0x2f5005C69C1da917AF5C47118BBCa9a8f0f1Ffb2
  SpecGapModule            0xd17E1b67F438532036F279b08b34DEb264338a9C
  row                      0
  protocol                 0x85F9549e4fdCa52fF56742B27b6C037ae5B06966
  auditor                  0xEdB37f4C862fC94A63Fe826baCefF2fF17016839
  discoverer               0xfEE57981D498a5b3882ac464344687A12c8d4cC9
  fixture key's seat       protocol
  row state                4
  gap status               Confirmed
  filing stake (wei)       10000000000000000000
  filed at                 1790538802
  silence confirms from    1790539102
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
  row bounty (wei)         40000000000000000000
  row window opened        1790538796
  row window (s)           600
  row window closed        1790539396
  cell holds (wei)         40000000000000000000
  auditor holds (wei)      0
  discoverer holds (wei)   10000000000000000000
  fixture key holds (wei)  0
  fixture key's nonce      71
  read at block            47434123
  read at (unix s)         1790636534
  read back from           exhibits/beanstalk-2022-04/fixture/record/84532.filing.json
```
<!-- /live -->
