# Room 1, the last safe moment

[The transcript](README.md)

## Beanstalk on Ethereum, the block before it was drained

#### `exhibits/beanstalk-2022-04/Fork.t.sol`

`BeanstalkForkTest.test_forkStandsAtTheNamedBlock()` passed

It prints nothing; it asserts.

`BeanstalkForkTest.test_beanstalkCodeIsTheCodeTheVerdictNames()` passed

It prints nothing; it asserts.

`BeanstalkForkTest.test_theAttackHasNotBeenWrittenYet()` passed

It prints nothing; it asserts.

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

#### `exhibits/beanstalk-2022-04/Provenance.t.sol`

`ProvenanceTest.test_vendoredSourcesAreUnmodified()` passed

It prints nothing; it asserts.

`ProvenanceTest.test_governanceConstantsAreTheOnesTheSpecCites()` passed

It prints nothing; it asserts.

`ProvenanceTest.test_everyInvariantNamesItsSource()` passed

It prints nothing; it asserts.
