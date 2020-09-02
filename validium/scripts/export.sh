#!/bin/bash

ARTIFACTS="build/circuits"
ARTIFACTS_KEYS="build/keys"

MAX_JOB=32
mkdir -p $ARTIFACTS
CIRCOM="./node_modules/.bin/circom"
SNARKJS="./node_modules/.bin/snarkjs"

echo "export verification_key.json"
$SNARKJS zkey export verificationkey ${ARTIFACTS}/ownership_circuit_final.zkey verification_key.json
echo "export contracts/verifier.sol"
$SNARKJS zkey export solidityverifier ${ARTIFACTS}/ownership_circuit_final.zkey contracts/verifier.sol
