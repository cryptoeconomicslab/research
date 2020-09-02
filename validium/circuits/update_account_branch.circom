include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template UpdateAccountBranch(state_tree_depth) {
  signal input siblings[state_tree_depth];
  signal input accountId;
  signal input oldBalance;
  signal input newBalance;
  signal input oldRoot;
  signal output newRoot;

  component smt = SMTProcessor(state_tree_depth);
  smt.oldRoot <== oldRoot;
  for (var j=0; j<state_tree_depth; j++) {
    smt.siblings[j] <== siblings[j];
  }
  
  smt.oldKey <== accountId;
  smt.oldValue <== oldBalance;
  smt.newKey <== accountId;
  smt.newValue <== newBalance;
  // update
  smt.isOld0 <== 0;
  smt.fnc[0] <== 0;
  smt.fnc[1] <== 1;
  smt.enabled <== 1;
  smt.newRoot ==> newRoot;
}


template InsertAccountBranch(state_tree_depth) {
  signal input siblings[state_tree_depth];
  signal input accountId;
  signal input oldBalance;
  signal input newBalance;
  signal input oldRoot;
  signal output newRoot;

  component smt = SMTProcessor(state_tree_depth);
  smt.oldRoot <== oldRoot;
  for (var j=0; j<state_tree_depth; j++) {
    smt.siblings[j] <== siblings[j];
  }

  smt.oldKey <== accountId;
  smt.oldValue <== oldBalance;
  smt.newKey <== accountId;
  smt.newValue <== newBalance;
  // update
  smt.isOld0 <== 1;
  smt.fnc[0] <== 1;
  smt.fnc[1] <== 0;
  smt.enabled <== 1;
  smt.newRoot ==> newRoot;
}
