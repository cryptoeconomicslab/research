#!/bin/bash

ARTIFACTS="build/circuits"
ARTIFACTS_KEYS="build/keys"

MAX_JOB=32
mkdir -p $ARTIFACTS
CIRCOM="./node_modules/.bin/circom"
SNARKJS="./node_modules/.bin/snarkjs"

for circuit in "impls"/*.circom;
do
    FNAME=${circuit##*/}
    prefix="$ARTIFACTS/$(basename "$circuit" ".circom")"
    OUTPUT=$prefix
    R1CS=$OUTPUT".r1cs"
    SOURCE=$circuit
    CIRCOM "$SOURCE" -r "$OUTPUT.r1cs"
    echo "Compile Start: $(basename "$SOURCE" ".circom")"
    $SNARKJS ri "$OUTPUT.r1cs"
    echo "Compile End: $(basename "$SOURCE" ".circom")"
    CIRCOM "$SOURCE" -w "$OUTPUT.wasm"
    CIRCOM "$SOURCE" -s "$OUTPUT.sym"

    echo "export " "$R1CS" ".json"
    $SNARKJS r1cs export json $R1CS $R1CS.json
    $SNARKJS zkey new $R1CS $ARTIFACTS_KEYS/pot12_final.ptau ${OUTPUT}_circuit_0000.zkey
    $SNARKJS zkey verify $R1CS $ARTIFACTS_KEYS/pot12_final.ptau ${OUTPUT}_circuit_0000.zkey
    $SNARKJS zkey beacon ${OUTPUT}_circuit_0000.zkey ${OUTPUT}_circuit_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
    $SNARKJS zkey verify $R1CS $ARTIFACTS_KEYS/pot12_final.ptau ${OUTPUT}_circuit_final.zkey
done

echo "export verification_key.json"
$SNARKJS zkey export verificationkey ${ARTIFACTS}/state_transition_verifier_circuit_final.zkey verification_key.json
echo "export contracts/verifier.sol"
$SNARKJS zkey export solidityverifier ${ARTIFACTS}/state_transition_verifier_circuit_final.zkey contracts/verifier.sol
