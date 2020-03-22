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
