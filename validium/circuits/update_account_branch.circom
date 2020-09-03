include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template UpdateAccountBranch(state_tree_depth) {
  signal input siblings[state_tree_depth];
  signal input accountId;
  signal input pubKey[2];
  signal input oldBalance;
  signal input newBalance;
  signal input oldRoot;
  signal output newRoot;

  component smt = SMTProcessor(state_tree_depth);
  smt.oldRoot <== oldRoot;
  for (var j=0; j<state_tree_depth; j++) {
    smt.siblings[j] <== siblings[j];
  }

  component oldHash = Poseidon(3);
  oldHash.inputs[0] <== pubKey[0];
  oldHash.inputs[1] <== pubKey[1];
  oldHash.inputs[2] <== oldBalance;

  component newHash = Poseidon(3);
  newHash.inputs[0] <== pubKey[0];
  newHash.inputs[1] <== pubKey[1];
  newHash.inputs[2] <== newBalance;

  smt.oldKey <== accountId;
  smt.oldValue <== oldHash.out;
  smt.newKey <== accountId;
  smt.newValue <== newHash.out;
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
  signal input pubKey[2];
  signal input oldBalance;
  signal input newBalance;
  signal input oldRoot;
  signal output newRoot;

  component smt = SMTProcessor(state_tree_depth);
  smt.oldRoot <== oldRoot;
  for (var j=0; j<state_tree_depth; j++) {
    smt.siblings[j] <== siblings[j];
  }

  component newHash = Poseidon(3);
  newHash.inputs[0] <== pubKey[0];
  newHash.inputs[1] <== pubKey[1];
  newHash.inputs[2] <== newBalance;

  smt.oldKey <== accountId;
  smt.oldValue <== 0;
  smt.newKey <== accountId;
  smt.newValue <== newHash.out;
  
  // update
  smt.isOld0 <== 1;
  smt.fnc[0] <== 1;
  smt.fnc[1] <== 0;
  smt.enabled <== 1;
  smt.newRoot ==> newRoot;
}
