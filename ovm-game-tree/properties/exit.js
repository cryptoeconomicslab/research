const exit = `
def exit(su, proof) := 
  VerifyInclusion(su, su.0, su.1, proof, su.2)
  and !su()
  and Checkpoint(su)

`;
module.exports = exit;
