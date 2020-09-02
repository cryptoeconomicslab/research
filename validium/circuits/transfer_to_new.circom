include "./ownership.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template TransferToNew(state_tree_depth) {
  // [tx_type, from, to, amount, sig, sig, sig]
  signal input pub_tx;
  signal input tx[7];
  signal input old_leaf_from[3];
  signal input new_leaf_from[3];
  signal input old_leaf_to[3];
  signal input new_leaf_to[3];
  signal input siblings_from[state_tree_depth];
  signal input siblings_to[state_tree_depth];
  signal input old_root;
  signal output new_root;

  var j = 0;

  component smt = SMTProcessor(state_tree_depth);
  smt.oldRoot <== old_root;
  for (j=0; j<state_tree_depth; j++) {
    smt.siblings[j] <== siblings_from[j];
  }

  component oldHash = Poseidon(2);
  oldHash.inputs[0] <== old_leaf_from[0];
  oldHash.inputs[1] <== old_leaf_from[1];
  component newHash = Poseidon(2);
  newHash.inputs[0] <== new_leaf_from[0];
  newHash.inputs[1] <== new_leaf_from[1];

  smt.oldKey <== oldHash.out;
  smt.oldValue <== old_leaf_from[2];
  smt.newKey <== newHash.out;
  smt.newValue <== new_leaf_from[2];
  // update
  smt.isOld0 <== 0;
  smt.fnc[0] <== 0;
  smt.fnc[1] <== 1;
  smt.enabled <== 1;

  component smtTo = SMTProcessor(state_tree_depth);
  smtTo.oldRoot <== smt.newRoot;
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

  component ownership = OwnershipPredicate();
  ownership.pub_tx <== pub_tx;
  for (j=0; j<7; j++) {
    ownership.tx[j] <== tx[j];
  }
  ownership.pub_key[0] <== old_leaf_from[0];
  ownership.pub_key[1] <== old_leaf_from[1];

  new_leaf_from[2] === old_leaf_from[2] - tx[3];
  new_leaf_to[2] === tx[3];
}
