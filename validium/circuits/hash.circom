include "../node_modules/circomlib/circuits/sha256/sha256.circom";

template HashPublicKey() {
  // Public inputs
  signal output ph[256];

  // private inputs
  signal private input pub_key[256];
  signal private input salt[256];

  component sha256 = Sha256(512)
  var i;

  for (i=0; i<256; i++) {
    sha256.in[i] <-- pub_key[i];
  }
  for (i=0; i<256; i++) {
    sha256.in[256 + i] <-- salt[i];
  }
  
  for (i=0; i<256; i++) {
    sha256.out[i] --> ph[i];
  }
}
