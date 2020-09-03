include "./ownership.circom";
include "./update_account_branch.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template Deposit(state_tree_depth) {
  // [tx_type, from, to, amount]
  signal input pub_tx;
  signal input tx[7];
  signal input fromId;
  signal input toId;
  signal input toAddress[2];
  signal input balanceFrom;
  signal input balanceTo;
  signal input siblings_from[state_tree_depth];
  signal input siblings_to[state_tree_depth];
  signal input oldRoot;
  signal input enabled;
  // isValid and newRoot
  signal output out[2];

  var j = 0;

  component accountTo = InsertAccountBranch(state_tree_depth);
  accountTo.oldRoot <== oldRoot;
  for (j=0; j<state_tree_depth; j++) {
    accountTo.siblings[j] <== siblings_to[j];
  }
  accountTo.accountId <== toId;
  accountTo.pubKey[0] <== toAddress[0];
  accountTo.pubKey[1] <== toAddress[1];
  accountTo.oldBalance <== balanceTo;
  accountTo.newBalance <== balanceTo + tx[3];

  out[0] <== 1;
  out[1] <== accountTo.newRoot;
}
