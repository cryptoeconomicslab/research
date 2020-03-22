const swap = `
@library
@quantifier("signatures,KEY,\${m}")
def SignedBy(sig, m, signer) := IsValidSignature(m, sig, signer, $secp256k1)

@library
@quantifier("proof.block\${b}.range\${token},RANGE,\${range}")
def IncludedAt(proof, leaf, token, range, b) :=
  Stored(c_token, b).any(root ->
    VerifyInclusion(leaf, token, range, proof, root)
  )

  @library
@quantifier("so.block\${b}.range\${token},RANGE,\${range}")
def SU(so, token, range, b) :=
  IncludedAt(so, token, range, b).any()

@library
@quantifier("stored.\${contract},KEY,\${key}")
def Stored(value, contract, key) := IsStored(contract, key, value)

@library
@quantifier("-,CONCAT,\${a}-\${b}")
def Concat(c, a, b) := IsConcatenatedWith(c, a, b)

@library
@quantifier("-,HASH,\${p}")
def Hash(h, p) := IsValidHash(h, p)

@library
def Confsig(tx, root, owner) := Hash(tx).any(tx_hash ->
  Concat(root, tx_hash).any(conf_tx ->
    SignedBy(conf_tx, new_owner).any()
  )
)

def swap(new_owner, prev_owner, c_token, c_range, block_number, tx) :=
  SU(c_token, c_range, block_number).any(c_so ->
    Equal(c_so.address, self.address)
    and Equal(c_so.0, prev_owner)
    and Equal(c_so.1, new_owner)
    and Stored(c_token, block_number).any(root ->
      IncludedAt(c_so, c_token, c_range, root).any()
      and Confsig(tx, root, new_owner)
    )
  ) and SignedBy(tx, new_owner).any()

`;
module.exports = swap;
