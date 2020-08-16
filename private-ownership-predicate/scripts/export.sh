#!/bin/bash

ARTIFACTS="build/circuits"
ARTIFACTS_KEYS="build/keys"

MAX_JOB=32
mkdir -p $ARTIFACTS
CIRCOM="./node_modules/.bin/circom"
SNARKJS="./node_modules/.bin/snarkjs"

for circuit in "circuits"/*.circom;
do
    FNAME=${circuit##*/}
    echo "export verification_key.json"
    $SNARKJS zkey export verificationkey $ARTIFACTS_KEYS/${FNAME}_circuit_final.zkey ${FNAME}_verification_key.json
    echo "export contracts/verifier.sol"
    $SNARKJS zkey export solidityverifier $ARTIFACTS_KEYS/${FNAME}_circuit_final.zkey contracts/${FNAME}_verifier.sol

done
