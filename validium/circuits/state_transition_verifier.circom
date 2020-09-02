include "./deposit.circom";
include "./transfer.circom";
include "./transfer_to_new.circom";
include "./utils.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";

template StateTransitionVerifier(txn, state_tree_depth) {
  // Public inputs
  signal input old_root;
  signal output new_root;
  signal input pub_txs[txn];

  // private inputs
  // [tx_type, from, to, amount, sig, sig, sig]
  signal private input txs[txn][19 + state_tree_depth * 2];

  var cur_root = old_root;

  for (var i=0; i<txn; i++) {
    component transfer = Transfer(state_tree_depth);

    transfer.pub_tx <== pub_txs[i];
    for (var j=0; j<7; j++) {
      transfer.tx[j] <== txs[i][j];
    }
    for (var j=0; j<3; j++) {
      transfer.old_leaf_from[j] <== txs[i][7 + j];
      transfer.new_leaf_from[j] <== txs[i][10 + j];
      transfer.old_leaf_to[j] <== txs[i][13 + j];
      transfer.new_leaf_to[j] <== txs[i][16 + j];
    }
    for (var j=0; j<state_tree_depth; j++) {
      transfer.siblings_from[j] <== txs[i][19 + j];
      transfer.siblings_to[j] <== txs[i][19 + state_tree_depth + j];
    }
    transfer.old_root <== cur_root;

    component transferToNew = TransferToNew(state_tree_depth);

    transferToNew.pub_tx <== pub_txs[i];
    for (var j=0; j<7; j++) {
      transferToNew.tx[j] <== txs[i][j];
    }
    for (var j=0; j<3; j++) {
      transferToNew.old_leaf_from[j] <== txs[i][7 + j];
      transferToNew.new_leaf_from[j] <== txs[i][10 + j];
      transferToNew.old_leaf_to[j] <== txs[i][13 + j];
      transferToNew.new_leaf_to[j] <== txs[i][16 + j];
    }
    for (var j=0; j<state_tree_depth; j++) {
      transferToNew.siblings_from[j] <== txs[i][19 + j];
      transferToNew.siblings_to[j] <== txs[i][19 + state_tree_depth + j];
    }
    transferToNew.old_root <== cur_root;

    component deposit = Deposit(state_tree_depth);
    deposit.pub_tx <== pub_txs[i];
    for (var j=0; j<3; j++) {
      deposit.tx[j] <== txs[i][j];
    }
    for (var j=0; j<3; j++) {
      deposit.old_leaf_to[j] <== txs[i][3 + j];
      deposit.new_leaf_to[j] <== txs[i][6 + j];
    }
    for (var j=0; j<state_tree_depth; j++) {
      deposit.siblings_to[j] <== txs[i][9 + state_tree_depth + j];
    }
    deposit.old_root <== cur_root;

    component txResult = IfElseThen(1);
    txResult.obj1[0] <== txs[i][0];
    txResult.obj2[0] <== 0;
    txResult.if_v <== deposit.new_root;
    txResult.else_v <== transfer.new_root;

    component txResultNew = IfElseThen(1);
    txResultNew.obj1[0] <== txs[i][0];
    txResultNew.obj2[0] <== 1;
    txResultNew.if_v <== txResult.out;
    txResultNew.else_v <== transferToNew.new_root;

    cur_root = txResultNew.out;
  }
  new_root <== cur_root;
}
