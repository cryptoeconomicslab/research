#!/bin/bash

ARTIFACTS="build/keys"
mkdir -p $ARTIFACTS
R1CS="build/circuits/main.r1cs"
SYM="build/circuits/main.sym"
R1CSNAME="main"
CIRCOM="./node_modules/.bin/circom"
SNARKJS="./node_modules/.bin/snarkjs"

echo "export verification_key.json"
$SNARKJS zkey export verificationkey $ARTIFACTS/circuit_final.zkey verification_key.json
echo "export contracts/verifier.sol"
$SNARKJS zkey export solidityverifier $ARTIFACTS/circuit_final.zkey contracts/verifier.sol
