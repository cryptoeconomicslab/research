#!/bin/bash

ARTIFACTS="build/keys"
mkdir -p $ARTIFACTS
R1CS="build/circuits/main.r1cs"
SYM="build/circuits/main.sym"
R1CSNAME="main"
CIRCOM="./node_modules/.bin/circom"
SNARKJS="./node_modules/.bin/snarkjs"

$SNARKJS powersoftau new bn128 18 $ARTIFACTS/pot12_0000.ptau -v
#$SNARKJS powersoftau contribute $ARTIFACTS/pot12_0000.ptau $ARTIFACTS/pot12_0001.ptau --name="First contribution" -v
#$SNARKJS powersoftau contribute $ARTIFACTS/pot12_0001.ptau $ARTIFACTS/pot12_0002.ptau --name="Second contribution" -v -e="some random text"
#$SNARKJS powersoftau export challenge $ARTIFACTS/pot12_0002.ptau $ARTIFACTS/challenge_0003
#$SNARKJS powersoftau challenge contribute bn128 $ARTIFACTS/challenge_0003 $ARTIFACTS/response_0003 -e="some random text"
#$SNARKJS powersoftau import response $ARTIFACTS/pot12_0002.ptau $ARTIFACTS/response_0003 $ARTIFACTS/pot12_0003.ptau -n="Third contribution name"

$SNARKJS powersoftau verify $ARTIFACTS/pot12_0000.ptau
$SNARKJS powersoftau beacon $ARTIFACTS/pot12_0000.ptau $ARTIFACTS/pot12_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"

echo "1"
$SNARKJS powersoftau prepare phase2 $ARTIFACTS/pot12_beacon.ptau $ARTIFACTS/pot12_final.ptau -v
echo "2"
$SNARKJS powersoftau verify $ARTIFACTS/pot12_final.ptau

sh scripts/compile.sh

