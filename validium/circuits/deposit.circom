include "./ownership.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template Deposit(state_tree_depth) {
  // [tx_type, to, amount]
  signal input pub_tx;
  signal input tx[3];
  signal input old_leaf_to[3];
  signal input new_leaf_to[3];
  signal input siblings_to[state_tree_depth];
  signal input old_root;
  signal output new_root;

  var j = 0;

  component smtTo = SMTProcessor(state_tree_depth);
  smtTo.oldRoot <== old_root;
  for (j=0; j<state_tree_depth; j++) {
    smtTo.siblings[j] <== siblings_to[j];
  }

  component oldHashTo = Poseidon(2);
  oldHashTo.inputs[0] <== old_leaf_to[0];
  oldHashTo.inputs[1] <== old_leaf_to[1];
  component newHashTo = Poseidon(2);
  newHashTo.inputs[0] <== new_leaf_to[0];
  newHashTo.inputs[1] <== new_leaf_to[1];

  smtTo.oldKey <== oldHashTo.out;
  smtTo.oldValue <== old_leaf_to[2];
  smtTo.newKey <== newHashTo.out;
  smtTo.newValue <== new_leaf_to[2];
  // update
  smtTo.isOld0 <== 1;
  smtTo.fnc[0] <== 1;
  smtTo.fnc[1] <== 0;
  smtTo.enabled <== 1;
  smtTo.newRoot ==> new_root;

  new_leaf_to[2] === old_leaf_to[2] + tx[2];
}
