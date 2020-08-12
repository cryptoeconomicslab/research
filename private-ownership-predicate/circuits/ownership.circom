include "../node_modules/circomlib/circuits/eddsa.circom";
include "../node_modules/circomlib/circuits/sha256/sha256.circom";

template PrivateOwnershipPredicate(n) {
  // private inputs
  signal private input pub_key[256];
  signal private input sig[2][256];
  signal private input salt[256];
  // Public inputs
  signal input tx[n];
  signal output ph[256];

  component sha256 = Sha256(512)
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
    sha256.in[i] <== pub_key[i];
  }
  for (i=0; i<256; i++) {
    sha256.in[256 + i] <== salt[i];
  }
  
  for (i=0; i<256; i++) {
    ph[i] <-- sha256.out[i];
  }
}
