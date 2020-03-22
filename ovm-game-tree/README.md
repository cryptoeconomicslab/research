# ovm-game-tree

## Result

### Challenge Rules

- V1: Original rule from OVM paper
- V2: Optimized rule from https://github.com/cryptoeconomicslab/ovm-plasma-chamber-spec/blob/master/core-spec/index.md
- V3: Replacing not(not(p)) https://github.com/cryptoeconomicslab/ovm-compiler/pull/85

### Max depth of game tree

Best Case(can use immedeate decidable)

| name       | V1  | V2  | V3  |
| ---------- | --- | --- | --- |
| checkpoint | 18  | 6   | 6   |
| swap       | 35  | 1   | 1   |
| exit       | 4   | 3   | 3   |

Worst Case(can't use immedeate decidable)

| name       | V1  | V2  | V3  |
| ---------- | --- | --- | --- |
| checkpoint | 18  | 8   | 6   |
| swap       | 35  | 7   | 7   |
| exit       | 4   | 3   | 3   |

### Install

```
npm i
```

### Run

```
node index.js
```

### Example Game Tree

```
==========
Checkpoint
V1
Q:  All(Or(Not(IsLessThan),All(Or(Not(Any(VerifyInclusion)),old_su))))
P: - Not(Or(Not(IsLessThan),All(Or(Not(Any(VerifyInclusion)),old_su))))
Q: -- Or(Not(IsLessThan),All(Or(Not(Any(VerifyInclusion)),old_su)))
P: --- And(Not(Not(IsLessThan)),Not(All(Or(Not(Any(VerifyInclusion)),old_su))))
Q: ---- Not(Not(Not(IsLessThan)))
P: ----- Not(Not(IsLessThan))
Q: ------ Not(IsLessThan)
P: ------- IsLessThan
Q: ---- Not(Not(All(Or(Not(Any(VerifyInclusion)),old_su))))
P: ----- Not(All(Or(Not(Any(VerifyInclusion)),old_su)))
Q: ------ All(Or(Not(Any(VerifyInclusion)),old_su))
P: ------- Not(Or(Not(Any(VerifyInclusion)),old_su))
Q: -------- Or(Not(Any(VerifyInclusion)),old_su)
P: --------- And(Not(Not(Any(VerifyInclusion))),Not(old_su))
Q: ---------- Not(Not(Not(Any(VerifyInclusion))))
P: ----------- Not(Not(Any(VerifyInclusion)))
Q: ------------ Not(Any(VerifyInclusion))
P: ------------- Any(VerifyInclusion)
Q: -------------- All(Not(VerifyInclusion))
P: --------------- Not(Not(VerifyInclusion))
Q: ---------------- Not(VerifyInclusion)
P: ----------------- VerifyInclusion
Q: ---------- Not(Not(old_su))
P: ----------- Not(old_su)
Q: ------------ old_su
Max depth 18
V2
Q:  All(Or(Not(IsLessThan),All(Or(Not(Any(VerifyInclusion)),old_su))))
P: - And(Not(Not(IsLessThan)),Not(All(Or(Not(Any(VerifyInclusion)),old_su))))
Q: -- Not(IsLessThan)
P: --- IsLessThan
Q: -- All(Or(Not(Any(VerifyInclusion)),old_su))
P: --- And(Not(Not(Any(VerifyInclusion))),Not(old_su))
Q: ---- Not(Any(VerifyInclusion))
P: ----- Any(VerifyInclusion)
Q: ---- old_su
Max depth 6
V3
Q:  All(Or(Not(IsLessThan),All(Or(Not(Any(VerifyInclusion)),old_su))))
P: - And(IsLessThan,Not(All(Or(Not(Any(VerifyInclusion)),old_su))))
Q: -- Not(IsLessThan)
P: --- IsLessThan
Q: -- All(Or(Not(Any(VerifyInclusion)),old_su))
P: --- And(Any(VerifyInclusion),Not(old_su))
Q: ---- Not(Any(VerifyInclusion))
P: ----- Any(VerifyInclusion)
Q: ---- old_su
Max depth 6
==========
```
