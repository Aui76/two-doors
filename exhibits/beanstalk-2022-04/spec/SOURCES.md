<!-- SPDX-License-Identifier: MIT -->
# Where every word in the spec came from

The rule this exhibit lives by: the spec is written from what Beanstalk published about itself
*before* it was drained, and from nothing else. That rule is worth nothing if you have to take my
word for it, so this file names the source of every line, with the command that fetched it and the
hash it had when it arrived. Check any of it. All of it is public.

Pulled 23 September 2026.

## The cut-off

Block 14,595,905 was mined at 1650106482, which is 16 April 2022 at 10:54:42 UTC. Anything published
after that instant is out of bounds.

```
curl -s 'https://api.github.com/repos/BeanstalkFarms/Beanstalk/commits?until=2022-04-16T10:54:42Z&per_page=1'
```

The last commit under the line is `e9f49910e287e7a7afaa6db8f536b7194728b0af`, dated 2022-04-11T18:27:52Z,
and its message is "Update whitepaper version 1.16.0 (#67)". Every source below is read at that commit.
That is the whole trick: a commit hash is a dated snapshot anyone can fetch, and it does not depend on
an archive service still being up.

## The two kinds of words

Beanstalk described its governance twice, once for people and once for the machine, and the exhibit uses both.

**For people: the whitepaper.** `beanstalk.pdf` at that commit, 1,015,842 bytes, sha256
`2665d9e9fcf32e9ee64d706b91f560066a38dd9031bddfd50a2dca91216264d4`. Its own title page reads Published
August 6, 2021, Modified April 11, 2022, Whitepaper Version 1.16.0, Code Version 1.16.0. Governance is
section 6.5, pages 10 to 12.

**For the machine: the facet.** Four files, vendored under `specimens/beanstalk-2022-04/` so the exhibit
is self-contained and you can hash them without a network.

```
curl -sL https://raw.githubusercontent.com/BeanstalkFarms/Beanstalk/e9f49910e287e7a7afaa6db8f536b7194728b0af/PATH
```

| file | bytes | sha256 |
|---|---|---|
| `protocol/contracts/farm/facets/GovernanceFacet/GovernanceFacet.sol` | 9326 | `27938091a8fd181e62246d9f365e3d5523d8b825b1c562243ffa9d6db908efad` |
| `protocol/contracts/farm/facets/GovernanceFacet/Bip.sol` | 5927 | `ef726c967c38bfab4474b64942efb534694d06473f2fd91ddc5a807d382b73f7` |
| `protocol/contracts/farm/facets/GovernanceFacet/VotingBooth.sol` | 1746 | `8f4bc3b86403814495490089e4300da66f42b34bdd4210d82bbf9abf7e2fe484` |
| `protocol/contracts/C.sol` | 7232 | `d32adf7a7344fa132703f5c54b0f56419499c77ec5d876cc93ace279f5a4b40d` |

All four carry `SPDX-License-Identifier: MIT` in their own headers. They are reproduced under that licence,
unmodified, for study.

## The sentence the room is built on

Section 6.5.2, Voting Period, is the rule that decides what happened on 17 April 2022. It is quoted here
in full, once, and referred to by section everywhere else:

> "If at any time 24 hours or more after the beginning and before the end of the Voting Period more
> than two-thirds of the total outstanding Stalk votes in favor of the BIP, it can be committed to the
> Ethereum blockchain."
>
> Beanstalk whitepaper v1.16.0, section 6.5.2, dated 11 April 2022

The contract says the same thing in Solidity at `GovernanceFacet.sol:180-190`, with the numbers coming
from `C.sol:47` and `C.sol:49-50`. Read them side by side. They agree.

## What backs each invariant

The spec file carries a `_source` on every invariant pointing at a whitepaper section or a source line.
The mapping is meant to be walked, not admired: open `governance-v0.json`, take an invariant, open the
line it names, and satisfy yourself that the invariant says what the line says and no more.

## Two things I did not do, and why

**I did not use an archive of the website.** The Internet Archive was returning "Temporarily Offline"
when I went looking on 23 September 2026, and a source that has to be up for the exhibit to be checkable
is a weak source. A commit hash does not go offline.

**I did not write an invariant for one whitepaper sentence.** Section 6.5.4 ends by saying the deployment
address can pause, unpause, and commit a BIP. The facet at this commit gives the owner `ownerPause` and
`ownerUnpause`, and I could not find an owner path to commit. Rather than write an invariant I cannot
ground in the code, or quietly drop the sentence, it is recorded here as a gap between the two kinds of
words. The spec constrains what the code does. This line describes something else, and saying so is
cheaper than pretending the two documents agree everywhere.

## The scope manifest

The spec's scope tags were run through the network's own deriver rather than checked by eye.

```
node cell/indexer/deriveScope.mjs   # via deriveScopeFromSpec(spec.invariants)
```

14 invariants, 8 categories, no warnings, no unknown symbols.

```
scopeRoot 0x02d96f1d8e856ddd5d16d617552df7e22abf75c00f1cecbfb5e30ab616ec8181
```

ACCESS-CONTROL, BALANCE-ACCOUNTING, GOVERNANCE-DRAIN-PATH, INPUT-VALIDATION, PAUSE-EMERGENCY,
STATE-LIFECYCLE, SUPPLY-CONSERVATION, TIME-LOGIC.

One of those categories is registered in the network's taxonomy against the question "Even the owner,
can they take my money?" You will want to remember that later.
