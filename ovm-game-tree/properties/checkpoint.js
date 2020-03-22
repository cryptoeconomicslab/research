const checkpoint = `
@library
@quantifier("range,NUMBER,\${zero}-\${upper_bound}")
def LessThan(n, upper_bound) :=
  IsLessThan(n, upper_bound)

@library
@quantifier("proof.block\${b}.range\${token},RANGE,\${range}")
def IncludedAt(proof, leaf, token, range, b) :=
  VerifyInclusion(leaf, token, range, proof, b)

@library
@quantifier("so.block\${b}.range\${token},RANGE,\${range}")
def SU(so, token, range, b) :=
  IncludedAt(so, token, range, b).any()

def checkpoint(su) := 
  LessThan(su.2).all(b -> 
    SU(su.0, su.1, b).all(old_su -> old_su())
  )

`;
module.exports = checkpoint;
