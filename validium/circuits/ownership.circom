include "../node_modules/circomlib/circuits/eddsamimc.circom";
include "./tx_hash.circom";

template OwnershipPredicate() {
  signal input pub_tx;
  // [tx_type, from, to, amount, sig, sig, sig]
  signal input tx[7];
  signal input pub_key[2];

  component eddsamimc = EdDSAMiMCVerifier();
  component txhash = TxHash();
  txhash.tx_type <== tx[0];
  txhash.from <== tx[1];
  txhash.to <== tx[2];
  txhash.amount <== tx[3];
  eddsamimc.enabled <== 1;
  eddsamimc.Ax <== pub_key[0];
  eddsamimc.Ay <== pub_key[1];
  eddsamimc.S <== tx[4];
  eddsamimc.R8x <== tx[5];
  eddsamimc.R8y <== tx[6];
  eddsamimc.M <== txhash.out;

  //
  pub_tx === tx[1];
}
