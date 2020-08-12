#!/bin/bash

ARTIFACTS="build/circuits"
ARTIFACTS_KEYS="build/keys"

MAX_JOB=32
mkdir -p $ARTIFACTS
SOURCE="circuits/main.circom"
OUTPUT=$ARTIFACTS"/main"
R1CS=$OUTPUT".r1cs"
CIRCOM="./node_modules/.bin/circom"
SNARKJS="./node_modules/.bin/snarkjs"

CIRCOM "$SOURCE" -r "$OUTPUT.r1cs"
echo "Compile Start: $(basename "$SOURCE" ".circom")"
snarkjs ri "$OUTPUT.r1cs"
echo "Compile End: $(basename "$SOURCE" ".circom")"
CIRCOM "$SOURCE" -w "$OUTPUT.wasm"
CIRCOM "$SOURCE" -s "$OUTPUT.sym"

echo "export " "$R1CS" ".json"
$SNARKJS r1cs export json $R1CS $R1CS.json
$SNARKJS zkey new $R1CS $ARTIFACTS_KEYS/pot12_final.ptau $ARTIFACTS_KEYS/circuit_0000.zkey
$SNARKJS zkey verify $R1CS $ARTIFACTS_KEYS/pot12_final.ptau $ARTIFACTS_KEYS/circuit_0000.zkey
$SNARKJS zkey beacon $ARTIFACTS_KEYS/circuit_0000.zkey $ARTIFACTS_KEYS/circuit_final.zkey 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon phase2"
$SNARKJS zkey verify $R1CS $ARTIFACTS_KEYS/pot12_final.ptau $ARTIFACTS_KEYS/circuit_final.zkey

sh ./scripts/export.sh
