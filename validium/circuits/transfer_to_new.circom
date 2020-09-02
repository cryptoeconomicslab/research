include "./ownership.circom";
include "./update_account_branch.circom";
include "../node_modules/circomlib/circuits/smt/smtprocessor.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template TransferToNew(state_tree_depth) {
  // [tx_type, from, to, amount, sig, sig, sig]
  signal input pub_tx;
  signal input tx[7];
  signal input fromId;
  signal input toId;
  signal input fromAddress[2];
  signal input balanceFrom;
  signal input balanceTo;
  signal input siblings_from[state_tree_depth];
  signal input siblings_to[state_tree_depth];
  signal input oldRoot;
  signal input enabled;
  // isValid and newRoot
  signal output out[2];

  var j = 0;

  component account = UpdateAccountBranch(state_tree_depth);
  account.oldRoot <== oldRoot;
  for (j=0; j<state_tree_depth; j++) {
    account.siblings[j] <== siblings_from[j];
  }
  account.accountId <== fromId;
  account.oldBalance <== balanceFrom;
  account.newBalance <== balanceFrom - tx[3];

  component accountTo = InsertAccountBranch(state_tree_depth);
  accountTo.oldRoot <== account.newRoot;
  for (j=0; j<state_tree_depth; j++) {
    accountTo.siblings[j] <== siblings_to[j];
  }
  accountTo.accountId <== toId;
  accountTo.oldBalance <== balanceTo;
  accountTo.newBalance <== balanceTo + tx[3];

  component ownership = OwnershipPredicate();
  ownership.enabled <== enabled;
  for (j=0; j<7; j++) {
    ownership.tx[j] <== tx[j];
  }
  ownership.pub_key[0] <== fromAddress[0];
  ownership.pub_key[1] <== fromAddress[1];

  // TODO: accountId == pub_tx
  out[0] <== 1;
  out[1] <== accountTo.newRoot;
}
