const snarkjs = require("snarkjs");
const fs = require("fs");
const circomlib = require("circomlib");
const eddsa = circomlib.eddsa;
const babyJub = circomlib.babyJub;
const smt = circomlib.smt;

const ffjs = require("ffjavascript");
const Fr = require("ffjavascript").Scalar;
const ethers = require("ethers");
const { arrayify, keccak256, toUtf8Bytes } = ethers.utils;

const alicePrvKey = Buffer.from(
  "0001020304050607080900010203040506070809000102030405060708090001",
  "hex"
);
const alicePubKey = eddsa.prv2pub(alicePrvKey);
const alicePackedPubKey = babyJub.packPoint(alicePubKey);

const bobPrvKey = Buffer.from(
  "0001020304050607080900010203040506070809000102030405060708090002",
  "hex"
);
const bobPubKey = eddsa.prv2pub(bobPrvKey);
const bobPackedPubKey = babyJub.packPoint(bobPubKey);

async function run() {
  await deposit();
}

run().then(() => {
  process.exit(0);
});

async function deposit() {
  const tree = await smt.newMemEmptyTrie();
  const res = await tree.insert(Fr.e(8), Fr.e(8));
  let siblings = res.siblings;
  while (siblings.length < 3) siblings.push(Fr.e(0));
  const inputs = {
    old_root: res.oldRoot,
    pub_txs: [0, 0],
    txs: [
      [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ],
      [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ],
    ],
  };
  console.log(inputs);
  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    inputs,
    "./build/circuits/state_transition_verifier.wasm",
    "./build/circuits/state_transition_verifier_circuit_final.zkey"
  );
  console.log("proof", proof);

  const vKey = JSON.parse(fs.readFileSync("./verification_key.json"));

  return await snarkjs.groth16.verify(vKey, publicSignals, proof);
}

function buffer2bits(buff) {
  const res = [];
  for (let i = 0; i < buff.length; i++) {
    for (let j = 0; j < 8; j++) {
      if ((buff[i] >> j) & 1) {
        res.push(Fr.one);
      } else {
        res.push(Fr.zero);
      }
    }
  }
  return res;
}

function bit2buffer(a) {
  const len = Math.floor((a.length - 1) / 8) + 1;
  const b = new Buffer.alloc(len);

  for (let i = 0; i < a.length; i++) {
    const p = Math.floor(i / 8);
    b[p] = b[p] | (Number(a[i]) << i % 8);
  }
  return b;
}
