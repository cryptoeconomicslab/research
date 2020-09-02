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
  signal private input txs[txn][13 + state_tree_depth * 2];

  var cur_root = old_root;

  for (var i=0; i<txn; i++) {

    component isTransfer = IsEqual();
    isTransfer.in[0] <== txs[i][0];
    isTransfer.in[1] <== 1;
    component isTransferNew = IsEqual();
    isTransferNew.in[0] <== txs[i][0];
    isTransferNew.in[1] <== 2;

    component transfer = Transfer(state_tree_depth);
    transfer.enabled <== isTransfer.out;
    transfer.pub_tx <== pub_txs[i];
    for (var j=0; j<7; j++) {
      transfer.tx[j] <== txs[i][j];
    }
    transfer.fromId <== txs[i][7];
    transfer.toId <== txs[i][8];
    transfer.fromAddress[0] <== txs[i][9];
    transfer.fromAddress[1] <== txs[i][10];    
    transfer.balanceFrom <== txs[i][11];
    transfer.balanceTo <== txs[i][12];

    for (var j=0; j<state_tree_depth; j++) {
      transfer.siblings_from[j] <== txs[i][13 + j];
      transfer.siblings_to[j] <== txs[i][13 + state_tree_depth + j];
    }
    transfer.oldRoot <== cur_root;

    component deposit = Deposit(state_tree_depth);
    deposit.pub_tx <== pub_txs[i];
    for (var j=0; j<7; j++) {
      deposit.tx[j] <== txs[i][j];
    }
    deposit.toId <== txs[i][7];
    deposit.balanceTo <== txs[i][10];

    for (var j=0; j<state_tree_depth; j++) {
      deposit.siblings_to[j] <== txs[i][11 + state_tree_depth + j];
    }
    deposit.oldRoot <== cur_root;

    component transferToNew = TransferToNew(state_tree_depth);
    transferToNew.enabled <== isTransferNew.out;
    transferToNew.pub_tx <== pub_txs[i];
    for (var j=0; j<7; j++) {
      transferToNew.tx[j] <== txs[i][j];
    }
    transferToNew.fromId <== txs[i][7];
    transferToNew.toId <== txs[i][8];
    transfer.fromAddress[0] <== txs[i][9];
    transfer.fromAddress[1] <== txs[i][10];
    transferToNew.balanceFrom <== txs[i][11];
    transferToNew.balanceTo <== txs[i][12];

    for (var j=0; j<state_tree_depth; j++) {
      transferToNew.siblings_from[j] <== txs[i][13 + j];
      transferToNew.siblings_to[j] <== txs[i][13 + state_tree_depth + j];
    }
    transferToNew.oldRoot <== cur_root;

    component txResult = IfElseThen(1);
    txResult.obj1[0] <== txs[i][0];
    txResult.obj2[0] <== 0;
    txResult.if_v <== deposit.out[1];
    txResult.else_v <== transfer.out[1];

    component txResultNew = IfElseThen(1);
    txResultNew.obj1[0] <== txs[i][0];
    txResultNew.obj2[0] <== 1;
    txResultNew.if_v <== txResult.out;
    txResultNew.else_v <== transferToNew.out[1];

    cur_root = txResultNew.out;
  }
  new_root <== cur_root;
}
