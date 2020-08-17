include "../node_modules/circomlib/circuits/eddsa.circom";
include "../node_modules/circomlib/circuits/sha256/sha256.circom";
include "./hash.circom";

template PrivateOwnershipPredicate(n) {
  // Public inputs
  signal input tx[n];
  signal output ph[256];

  // private inputs
  signal private input pub_key[256];
  signal private input sig[2][256];
  signal private input salt[256];

  component hashPublicKey = HashPublicKey()
  component eddsa = EdDSAVerifier(n)
  var i;

  for (i=0; i<n; i++) {
    eddsa.msg[i] <== tx[i];
  }

  for (i=0; i<256; i++) {
    eddsa.A[i]  <== pub_key[i];
    eddsa.R8[i] <== sig[0][i];
    eddsa.S[i]  <== sig[1][i];
  }
  
  for (i=0; i<256; i++) {
    hashPublicKey.pub_key[i] <== pub_key[i];
  }
  for (i=0; i<256; i++) {
    hashPublicKey.salt[i] <== salt[i];
  }
  
  for (i=0; i<256; i++) {
    hashPublicKey.ph[i] ==> ph[i];
  }
}
