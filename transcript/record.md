# On file: the row passed, and the gap filed after it

[The transcript](README.md)

## The verdict on the fork: the row passed and the door read CLEAN

#### `exhibits/beanstalk-2022-04/Verdict.t.sol`

`BeanstalkVerdictTest.test_theRowIsFiledSettledAndFoundByTheCodeHash()` passed

```text
fork block: 14595905
cell: 0x2e234DAe75C793f67A35089C9d99245E1C58470b
audit id: 0
artifact hash (Beanstalk diamond code): 0x2ff59388cd5e1842a3d057338010945a779a6c7d57abfb5e9ddc697838700870
spec hash (governance-v0.json): 0x67134c2f4385d783b8d7bf0833d9e8ef2d0dac0a4c3e78acc038405b27d0088a
case root: 0xbc7d4587db7059b977be92237c92d706145251f896f1909fe4e69e5b066b838d
min audit window (seconds): 1209600
state (6 = InBlock): 6
```

`BeanstalkVerdictTest.test_aDifferentHashFindsNoRow()` passed

It prints nothing; it asserts.

`BeanstalkVerdictTest.test_theWindowCannotBeSkipped()` passed

It prints nothing; it asserts.

## The second fixture: the same words filed as a gap after the PASS

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

### The second fixture on Base Sepolia, from the committed records

`exhibits/beanstalk-2022-04/fixture/record/84532.json`, which the stand wrote:

```text
Room 2 fixture: an instance of the DAN hull at 0f3eaf8, deployed on Base Sepolia by the museum for one filing. Not the network's cell.

AssignmentModule          0xA1b36137ee4039C3844f1830f35040B0a3709E23
AuditCell                 0x5D76C2127Ea49F1f6cc4b7228608d4ccD9c62016
BlockhashEntropy          0xF931753eCCA3beAEca3dFa05609208DF7e394f9b
CellEscrow                0x4d953DC5d5c773D169fc01b82541763Aa0aD982B
CellToken                 0xC694fd2e77465B3133485e402b9a2cc18BFAEB7c
ClaimDisputeModule        0x5aB566Ed5C5af94cdb71B140b709DF09Fa7b0392
FmeaRegistry              0x1aA596748f13346052830daC3807C662d2d3787a
IntegrityReviewModule     0x6FA8Da30EA3D2760ef0B10B8FC48c0166Aa90743
IssuanceModule            0x44ee11787BD55cE6d29CCcaD14B84b43865f58bd
SpecArbiterModule         0x2AA7e65f56473BEc2A96929123b4215DB0227565
SpecGapModule             0xf618111097e302dF6Db5378122715c2Aed9214C6
StructuralUpgradeModule   0xF3143C33bf0073165464ED3fFe8E87953E0870e7
auditCellRuntimeBytes     20909
auditCellRuntimeCodehash  0x268d9d15a3544c2b58db188784dbce9514de6a9add99e44b903f3973f4f2dfed
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
standCommit               55511e4dff671a7e3f81be683d2a6c1d99458b0b
```

`exhibits/beanstalk-2022-04/fixture/record/84532.filing.json`, which the filing wrote:

```text
Room 2, door two: a spec gap filed on the fixture, an instance of the DAN hull at 0f3eaf8 on Base Sepolia. Not the network's cell.

AuditCell           0x5D76C2127Ea49F1f6cc4b7228608d4ccD9c62016
SpecGapModule       0xf618111097e302dF6Db5378122715c2Aed9214C6
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
SpecGapModule     0xf618111097e302dF6Db5378122715c2Aed9214C6
auditId           0
classId           0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
status            Confirmed
confirmedBy       0xfEE57981D498a5b3882ac464344687A12c8d4cC9
tx                0xc57c1c1f8de7a7e7ecf945bf469d64266807e8eaf7c9acfe7eff89ff19840b46
block             47448860
timestamp         1790666008
stakeReturnedTo   0xfEE57981D498a5b3882ac464344687A12c8d4cC9
stakeReturnedWei  10000000000000000000
```

`exhibits/beanstalk-2022-04/fixture/record/84532.transactions.json`: 75 transactions the stand and the filing sent, 0 of them failed.

| # | script | type | contract | function | block | tx |
|---|---|---|---|---|---|---|
| 0 | stand | CREATE2 | DiscovererPayoutLib |  | 47447921 | [0xae45370c…](https://sepolia.basescan.org/tx/0xae45370c3c7da4054b3d45075a2c03f236a93ae0786fa112f37536866f8d3a4c) |
| 1 | stand | CREATE2 | ToolUseLib |  | 47447922 | [0xd795dd95…](https://sepolia.basescan.org/tx/0xd795dd95f5b35714d741fbebe1e4ca5c911d9e68f45e0e6b63dc6a063562d0d4) |
| 2 | stand | CREATE2 | CellLogicLib |  | 47447923 | [0x26235de3…](https://sepolia.basescan.org/tx/0x26235de3b3876d7e6b92dbc154737fec625a20a0f66f0126a520b32eb19b54c5) |
| 3 | stand | CREATE2 | SubmitAuditLib |  | 47447924 | [0x1defc8b7…](https://sepolia.basescan.org/tx/0x1defc8b7a0dc431552b35ee3535ee356a104b3b4d6d598aa59e50e4426a109f5) |
| 4 | stand | CREATE | CellToken |  | 47447925 | [0x28a8b425…](https://sepolia.basescan.org/tx/0x28a8b4253ed56192c7d7a0c7c8049c59254b9ac001dc0beedda46cbaf571c815) |
| 5 | stand | CREATE | AuditCell |  | 47447926 | [0x6a869677…](https://sepolia.basescan.org/tx/0x6a869677248b64f71898f093c29f4d593e2bac84bdb7f14d936dc18cc1249609) |
| 6 | stand | CALL | AuditCell | setGenesisBootstrap | 47447927 | [0xd42dd948…](https://sepolia.basescan.org/tx/0xd42dd948794021370d71ae041b403c915f045c9b4ac2dccf7e1a4aaa5f782f10) |
| 7 | stand | CREATE | CellEscrow |  | 47447928 | [0xc5b0d379…](https://sepolia.basescan.org/tx/0xc5b0d37926863f9cebba0af03baa066a1b4cb61390b70f89fb5e57ccdb552b07) |
| 8 | stand | CREATE | IssuanceModule |  | 47447929 | [0xde11a711…](https://sepolia.basescan.org/tx/0xde11a711cb17dfc1cb280384c444d8a19ce30f3f8a71e0a411d26e0282b15910) |
| 9 | stand | CREATE | ClaimDisputeModule |  | 47447930 | [0xac84310d…](https://sepolia.basescan.org/tx/0xac84310d44bcc3f81aee9543077ddf56d51e400313925458d54d2e19590dc7dd) |
| 10 | stand | CREATE | SpecGapModule |  | 47447931 | [0x1d78784f…](https://sepolia.basescan.org/tx/0x1d78784f0488aad1fd7ca1b9a93de5b80f1203e5c1b3e3090d77e48311726306) |
| 11 | stand | CREATE | SpecArbiterModule |  | 47447932 | [0x0d585d37…](https://sepolia.basescan.org/tx/0x0d585d3711e72c83b232a74ea093643d045fbf16b7b3329a156050d9f4427c96) |
| 12 | stand | CREATE | IntegrityReviewModule |  | 47447933 | [0x4d3a510b…](https://sepolia.basescan.org/tx/0x4d3a510b195f7451472c7541b8a60a55bd88f780be31c4aae556b551ae12f742) |
| 13 | stand | CREATE | StructuralUpgradeModule |  | 47447934 | [0xae9ca4ce…](https://sepolia.basescan.org/tx/0xae9ca4cedbdc29aba5f69b551e63163f0165276930c94506366a0fea88a4ab8d) |
| 14 | stand | CREATE | FmeaRegistry |  | 47447935 | [0xd21317ed…](https://sepolia.basescan.org/tx/0xd21317edc44e53f9786749bd93d83624de3bf8ab974c2797f777fc2d0ae5e08e) |
| 15 | stand | CREATE | AssignmentModule |  | 47447936 | [0x86eda0f7…](https://sepolia.basescan.org/tx/0x86eda0f71cf6d583ea63da748a3d286053adbc440cdb5a2d4d81b29b2a1017eb) |
| 16 | stand | CREATE | BlockhashEntropy |  | 47447937 | [0x644ddaa1…](https://sepolia.basescan.org/tx/0x644ddaa19f522a610df7de6d7e4d71c2cc8b1890fd2613a9d0caf649c359a4f7) |
| 17 | stand | CALL | IssuanceModule | wire | 47447938 | [0x48e5ec0e…](https://sepolia.basescan.org/tx/0x48e5ec0e6d288e26c72665c7666858f6ff0fe9b0ba94a92a6865f0ee1c632989) |
| 18 | stand | CALL | IssuanceModule | setEmaToMintBps | 47447939 | [0x5b005820…](https://sepolia.basescan.org/tx/0x5b005820d2e3845e433504762621247fc3e42a1a0149ab8dee1316262692351b) |
| 19 | stand | CALL | IssuanceModule | setMintLpCapBps | 47447940 | [0x6b8e698e…](https://sepolia.basescan.org/tx/0x6b8e698e8b15a09433fa3ae241eac0decefdda0fcb20e1511434b022b3231f7a) |
| 20 | stand | CALL | ClaimDisputeModule | wire | 47447941 | [0xb952b939…](https://sepolia.basescan.org/tx/0xb952b93977b646875ca6307a6568f47038695a3239f06bda4ec3f7a2e017ea64) |
| 21 | stand | CALL | FmeaRegistry | wireClaimModule | 47447942 | [0x6b19a03f…](https://sepolia.basescan.org/tx/0x6b19a03f1dfac3acbb47599fe1a17ac21bac2cb0c5eb2c9766079b1071705cec) |
| 22 | stand | CALL | ClaimDisputeModule | wireFmeaRegistry | 47447943 | [0xfca9c683…](https://sepolia.basescan.org/tx/0xfca9c683c469d219561cbc7973c2af781e478607af3d4e1c4e7cce8b096bcacf) |
| 23 | stand | CALL | AssignmentModule | wire | 47447944 | [0x08b09aa1…](https://sepolia.basescan.org/tx/0x08b09aa1424140a12c18644a98116f899f126a7550dfc8868a406abd1a0c217a) |
| 24 | stand | CALL | SpecGapModule | wire | 47447945 | [0x02354b1d…](https://sepolia.basescan.org/tx/0x02354b1deb1112974d2ebf5cad28b7e86c6100fd3bb6b02eabacd15a34835fbb) |
| 25 | stand | CALL | SpecArbiterModule | wire | 47447946 | [0x9caf0056…](https://sepolia.basescan.org/tx/0x9caf00565a902bf29d4bc7641edff0f42d52ecac85eec753c8df785c7cd63065) |
| 26 | stand | CALL | IntegrityReviewModule | wire | 47447947 | [0x5786d134…](https://sepolia.basescan.org/tx/0x5786d134bdda52b8f6de2062a7043e5a4818e44b2767dc065e9749df893341ef) |
| 27 | stand | CALL | StructuralUpgradeModule | wire | 47447948 | [0xe381050e…](https://sepolia.basescan.org/tx/0xe381050e62805fd761aee4a4f5704438569af0e879d3462bdfe9e09e5e7c867f) |
| 28 | stand | CALL | IssuanceModule | setStructuralModule | 47447949 | [0xf9fd8fb7…](https://sepolia.basescan.org/tx/0xf9fd8fb733753a5a9b03fe678948e6d68d864d20ab4661933225d6c68a1899a9) |
| 29 | stand | CALL | CellEscrow | setFounderReleaseTarget | 47447950 | [0x107d4534…](https://sepolia.basescan.org/tx/0x107d4534457cc93a75625791447a0c77b7b9063af3160001927940b1ddcf228d) |
| 30 | stand | CALL | CellEscrow | setNetwork | 47447951 | [0x3fa65cd4…](https://sepolia.basescan.org/tx/0x3fa65cd4e73e536c87a4bd0268399f48090edbf79fe31b2f7ae1fd4fb6ff50c9) |
| 31 | stand | CALL | CellEscrow | setIssuanceModule | 47447952 | [0xcd13b849…](https://sepolia.basescan.org/tx/0xcd13b849134a9f684ae32ba465ea8c5e0d2d7557f9abe5611f4917f8337cf988) |
| 32 | stand | CALL | CellEscrow | setStructuralUpgradeModule | 47447953 | [0x749d9e58…](https://sepolia.basescan.org/tx/0x749d9e58a82a436f46f68d53192c1c75f27726a156814bad24bfb8a97dcf6a2d) |
| 33 | stand | CALL | CellEscrow | setIntegrityReviewModule | 47447954 | [0x90b19cf6…](https://sepolia.basescan.org/tx/0x90b19cf6c065d702e4049f9c196f2ba28b5ad95414220f116b7d5ca72711802a) |
| 34 | stand | CALL | AuditCell | setTreasuryEscrow | 47447955 | [0xf48a8483…](https://sepolia.basescan.org/tx/0xf48a8483c295ad132c3a7c22d9acf9814c6af8eadd60b7a657f2d8bfe282ee40) |
| 35 | stand | CALL | AuditCell | setIssuanceModule | 47447956 | [0x37d027af…](https://sepolia.basescan.org/tx/0x37d027af4d497a8a34f08bc61246761f5972aca5597252d16fe5be723b851eef) |
| 36 | stand | CALL | AuditCell | setDisputeModule | 47447957 | [0xa1d8abe4…](https://sepolia.basescan.org/tx/0xa1d8abe42048b8b36e7eebd5194cb7704ced2e90c73f8d7dd066f9dbbf5f2867) |
| 37 | stand | CALL | AuditCell | setDisputeModule | 47447958 | [0xdbebb1f3…](https://sepolia.basescan.org/tx/0xdbebb1f32c3aa30e33c8e3de88dcc5b18df349e107f57849f912687d1b8c8be7) |
| 38 | stand | CALL | AuditCell | setDisputeModule | 47447959 | [0xae621493…](https://sepolia.basescan.org/tx/0xae621493855119083cb660704a566374d1fbc606716ff5b020f325e7c2a4bdd5) |
| 39 | stand | CALL | AuditCell | setDisputeModule | 47447960 | [0x24e28500…](https://sepolia.basescan.org/tx/0x24e285007b300d8e2b53ea5061f934c3c4496f045a5316f6a2d4faafb6cfe427) |
| 40 | stand | CALL | AuditCell | setDisputeModule | 47447961 | [0xe1d9694b…](https://sepolia.basescan.org/tx/0xe1d9694b2b16dbf67038345aab50578855e1f0dac1d0b8b4c7657a14cbf5f910) |
| 41 | stand | CALL | AuditCell | setAssignmentModule | 47447962 | [0x5c2c79ee…](https://sepolia.basescan.org/tx/0x5c2c79ee593d9dd04b5c30ea8f16bd8f55d9eec9ccb9c20365ca2509e650e256) |
| 42 | stand | CALL | AuditCell | setEntropyProvider | 47447963 | [0xf0ece08e…](https://sepolia.basescan.org/tx/0xf0ece08e09a97f471bddc303d22b496317538bc7dc911d2bfba114e3bda3c16d) |
| 43 | stand | CALL | AuditCell | setParam | 47447964 | [0x9fb06e61…](https://sepolia.basescan.org/tx/0x9fb06e6174e3f8b3098e496cb87e5864c80705521203db289af367e5621b0474) |
| 44 | stand | CALL | AuditCell | setParam | 47447965 | [0x8682ddc2…](https://sepolia.basescan.org/tx/0x8682ddc2c2d1b02933e18a31e9d5275c8c7a92e34e3fe37ec3d85cc598cd2722) |
| 45 | stand | CALL | AuditCell | setParam | 47447966 | [0x2d8e64a4…](https://sepolia.basescan.org/tx/0x2d8e64a4bb0fe5dc4f38b63dad10388da3f86ad4d39ac07015fc078d4a1e822d) |
| 46 | stand | CALL | AuditCell | setParam | 47447967 | [0xe9787d18…](https://sepolia.basescan.org/tx/0xe9787d186356ad5d1dbda5b2f4eb139b081008ac1ae20bdef8223b7565efdd75) |
| 47 | stand | CALL | AuditCell | setParam | 47447968 | [0x73081215…](https://sepolia.basescan.org/tx/0x730812159c34e0f11b80981d203d6c5e876da9fd5e75d3d6d59863e338f1258f) |
| 48 | stand | CALL | ClaimDisputeModule | setProtocolClaimDecisionWindow | 47447969 | [0x5b975a04…](https://sepolia.basescan.org/tx/0x5b975a04fc664c344ef56d6681b66b39450e2cbd0827a3464d44fcca91909fb6) |
| 49 | stand | CALL | AuditCell | setParam | 47447970 | [0x4411fe7d…](https://sepolia.basescan.org/tx/0x4411fe7d49f1ed253039d934fa75ce966142683c3280ec2d109f2f680145c990) |
| 50 | stand | CALL | SpecArbiterModule | setSpecChallengeStake | 47447971 | [0xbddcee64…](https://sepolia.basescan.org/tx/0xbddcee64be1254432238ffebd1235b1afa1b0e544e0d1cac7eea3228dbd05c81) |
| 51 | stand | CALL | IntegrityReviewModule | setIntegrityFilingStake | 47447972 | [0x28e5ca84…](https://sepolia.basescan.org/tx/0x28e5ca84e1f2dd9223f79fb718afd9506607f8930a1edc3ee51b42597527a7c9) |
| 52 | stand | CALL | IntegrityReviewModule | setIntegrityContestStake | 47447973 | [0x598595da…](https://sepolia.basescan.org/tx/0x598595da08577ca6df2e85bac4a567b63f9444f655d70f5d8e6637654c95439f) |
| 53 | stand | CALL | StructuralUpgradeModule | setGapFilingStake | 47447974 | [0x8a374e7e…](https://sepolia.basescan.org/tx/0x8a374e7edc760df4b207e6ebbd3d0e420cb1495c394ab5d0efeb17a5aa98dfe4) |
| 54 | stand | CALL | SpecArbiterModule | setSpecChallengeFee | 47447975 | [0x8cce40b2…](https://sepolia.basescan.org/tx/0x8cce40b23c48c1613d9f11487663060576e43acf95ea7715d967f02fe1db6475) |
| 55 | stand | CALL | AuditCell | registerTool | 47447976 | [0x24cfc001…](https://sepolia.basescan.org/tx/0x24cfc0016b21d274a1d5e10820a9949b8fb9605dfe66059a8391bfebc901e3b1) |
| 56 | stand | CALL | AuditCell | registerTool | 47447977 | [0x9d757bd1…](https://sepolia.basescan.org/tx/0x9d757bd17f96d279207e676501b3a5b062317335c20a60c37c31cdf6d30775fa) |
| 57 | stand | CALL | AuditCell | registerTool | 47447978 | [0x7b3acda3…](https://sepolia.basescan.org/tx/0x7b3acda3745ecfcfa5f9b7f5e33383b56d178afb1062c5a5b8385aeb4365f5cf) |
| 58 | stand | CALL | AuditCell | registerTool | 47447979 | [0x5ada5146…](https://sepolia.basescan.org/tx/0x5ada51466ec72890a565a404f5351957b0e2e48b06a397bcd790c0c9869df72c) |
| 59 | stand | CALL | AuditCell | registerTool | 47447980 | [0x48aa923c…](https://sepolia.basescan.org/tx/0x48aa923c181e2a6600fa3f6e331c8d783f7858d567d9e4234b1e10b271884972) |
| 60 | stand | CALL | AuditCell | registerTool | 47447981 | [0xb177101e…](https://sepolia.basescan.org/tx/0xb177101ef03348cd4e17596377df3f2ac9b50e218ff54ee54ed2fd354f949060) |
| 61 | stand | CALL | AuditCell | setToolWitnessFlags | 47447982 | [0x41feea4c…](https://sepolia.basescan.org/tx/0x41feea4c67c434d146dcf5ecece2184f095c6b369df88fa54b26a1b155df118a) |
| 62 | stand | CALL | SpecGapModule | registerClass | 47447983 | [0xa9a13697…](https://sepolia.basescan.org/tx/0xa9a1369776840665add96864471cfe525621e713c5976a0abbdc2c5fc22ada73) |
| 63 | stand | CALL | CellToken | genesisMint | 47447984 | [0x7a1d27ee…](https://sepolia.basescan.org/tx/0x7a1d27eec9cdc051c39a67d81dae9ff359e656661326e6302f781c1c80e2a85f) |
| 64 | stand | CALL | CellToken | setMinter | 47447985 | [0x3318a567…](https://sepolia.basescan.org/tx/0x3318a5675aa46c7581f67541a366177d0974c6057201eb522f3ac8e189773e0c) |
| 65 | filing | CALL |  | register | 47448683 | [0xe2ede1de…](https://sepolia.basescan.org/tx/0xe2ede1de0e5357a267df2222ad6bdcebd28cffcf9ae4c79bb7b8dc6e17b3a9db) |
| 66 | filing | CALL |  | approve | 47448683 | [0x3801c3b8…](https://sepolia.basescan.org/tx/0x3801c3b881917191e6c4a8484e418a5cd2c7bde6b6e6f453e8002acc4af6ed6e) |
| 67 | filing | CALL |  | submitArtifactAudit | 47448684 | [0x370c6d8f…](https://sepolia.basescan.org/tx/0x370c6d8fe841bd8fceceee758113254c17c9dc30abc7212e8174627984a127aa) |
| 68 | filing | CALL |  | protocolAcceptAuditor | 47448685 | [0xa705b6d2…](https://sepolia.basescan.org/tx/0xa705b6d20099b4153e6bff330f052586fe5d34ac9d80e604b6d4932a2f9e2524) |
| 69 | filing | CALL |  | acceptAudit | 47448685 | [0x8f3f1f36…](https://sepolia.basescan.org/tx/0x8f3f1f36cd74a6417be52fc24e5d5aba93226a7e3e2ac88faa31de7864e5cce4) |
| 70 | filing | CALL |  | provePass | 47448686 | [0xa6a4b3d1…](https://sepolia.basescan.org/tx/0xa6a4b3d10c0a39aa23a1bedf41d7f9f0c1bafb3cb509cb17fb3297c887f7f87b) |
| 71 | filing | CALL |  | transfer | 47448686 | [0x38c61912…](https://sepolia.basescan.org/tx/0x38c6191265bb86cfd7277f606cbd78d78acc70133d580f7b4da5aa311eb4fe45) |
| 72 | filing | CALL |  | register | 47448687 | [0x428b0e20…](https://sepolia.basescan.org/tx/0x428b0e2080e9e9e175d500394aa6a14efd7afd16d6b52b2be44ff809aeb26fba) |
| 73 | filing | CALL |  | approve | 47448688 | [0x560d1099…](https://sepolia.basescan.org/tx/0x560d10991616896bcd3772e8521773de841592e5131d8bdb5eaf88469b00a62e) |
| 74 | filing | CALL |  | openSpecGap | 47448689 | [0xd5cc45f3…](https://sepolia.basescan.org/tx/0xd5cc45f3d58578a0e652f4bb000a87682373a67dff5aa6d4e0cd01c3cb8898bf) |

### The second fixture on Base Sepolia, read from the chain in this run

<!-- live -->
`ReadTheFixture` and `ReadTheFiling` read the chain from https://sepolia.base.org and send nothing:

```text
Room 2 fixture: the DAN hull at 0f3eaf8 - not the network's cell
  chain id                 84532
  fixture key              0x85F9549e4fdCa52fF56742B27b6C037ae5B06966
  genesis auditor          0xEdB37f4C862fC94A63Fe826baCefF2fF17016839
  AuditCell                0x5D76C2127Ea49F1f6cc4b7228608d4ccD9c62016
  CellToken                0xC694fd2e77465B3133485e402b9a2cc18BFAEB7c
  SpecGapModule            0xf618111097e302dF6Db5378122715c2Aed9214C6
  StructuralUpgradeModule  0xF3143C33bf0073165464ED3fFe8E87953E0870e7
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
  AuditCell                0x5D76C2127Ea49F1f6cc4b7228608d4ccD9c62016
  SpecGapModule            0xf618111097e302dF6Db5378122715c2Aed9214C6
  row                      0
  protocol                 0x85F9549e4fdCa52fF56742B27b6C037ae5B06966
  auditor                  0xEdB37f4C862fC94A63Fe826baCefF2fF17016839
  discoverer               0xfEE57981D498a5b3882ac464344687A12c8d4cC9
  fixture key's seat       protocol
  row state                6
  gap status               Confirmed
  filing stake (wei)       10000000000000000000
  filed at                 1790665666
  silence confirms from    1790665966
  gap class
0xf265280a77ba6123996963ca5c8304643796f2443d1c448144d3f41c86c139b3
  result root
0x41922cf47145f448a316089973c55a15409ff973e5c68c50115cbd598d759b1e
  row bounty (wei)         40000000000000000000
  row window opened        1790665660
  row window (s)           600
  row window closed        1790666260
  cell holds (wei)         0
  auditor holds (wei)      40625000000000000000
  discoverer holds (wei)   10000000000000000000
  fixture key holds (wei)  0
  fixture key's nonce      140
  read at block            47800127
  read at (unix s)         1791368542
  read back from           exhibits/beanstalk-2022-04/fixture/record/84532.filing.json
```
<!-- /live -->
