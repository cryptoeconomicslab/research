const snarkjs = require("snarkjs");
const fs = require("fs");
const circomlib = require("circomlib");
const sha256 = require("circomlib/test/helpers/sha256");
const eddsa = circomlib.eddsa;
const babyJub = circomlib.babyJub;
const ffjs = require("ffjavascript");
const Fr = require("ffjavascript").Scalar;
const ethers = require("ethers");
const { arrayify, keccak256, toUtf8Bytes } = ethers.utils;

const privateKey = Buffer.from(
  arrayify("0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3")
);
const publicKey = eddsa.prv2pub(privateKey);
const pPubKey = babyJub.packPoint(publicKey);
const salt = Buffer.from(arrayify(keccak256(toUtf8Bytes("salt"))));
const hashedPubKey = Buffer.from(
  arrayify(
    "0x" +
      sha256.hash(
        Buffer.concat([pPubKey, salt], pPubKey.length + salt.length).toString(
          "hex"
        ),
        {
          msgFormat: "hex-bytes",
        }
      )
  )
);

const message = Buffer.from(arrayify(keccak256(toUtf8Bytes("message"))));
const signature = eddsa.sign(privateKey, message);
const pSignature = eddsa.packSignature(signature);
const uSignature = eddsa.unpackSignature(pSignature);
console.log(
  "verify signature in local",
  eddsa.verify(message, uSignature, publicKey)
);

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

function buffer2bitArray(b) {
  const res = [];
  for (let i = 0; i < b.length; i++) {
    for (let j = 0; j < 8; j++) {
      res.push((b[i] >> (7 - j)) & 1);
    }
  }
  return res;
}

function bitArray2buffer(a) {
  const len = Math.floor((a.length - 1) / 8) + 1;
  const b = new Buffer.alloc(len);

  for (let i = 0; i < a.length; i++) {
    const p = Math.floor(i / 8);
    b[p] = b[p] | (Number(a[i]) << (7 - (i % 8)));
  }
  return b;
}

async function run() {
  const inputs = {
    pub_key: buffer2bits(pPubKey),
    sig: [
      buffer2bits(pSignature.slice(0, 32)),
      buffer2bits(pSignature.slice(32, 64)),
    ],
    salt: buffer2bits(salt),
    //    ph: buffer2bitArray(hashedPubKey),
    tx: buffer2bits(message),
  };

  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    inputs,
    "./build/circuits/main.wasm",
    "./build/keys/circuit_final.zkey"
  );

  const publicInputs = ffjs.utils.unstringifyBigInts(publicSignals);
  console.log("hashedPubKey: ", hashedPubKey.toString("hex"));
  console.log("message: ", message.toString("hex"));
  console.log("publicInputs: ", bitArray2buffer(publicInputs).toString("hex"));
  const vKey = JSON.parse(fs.readFileSync("./verification_key.json"));

  const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);
  if (res === true) {
    console.log("Verification OK");
  } else {
    console.log("Invalid proof");
  }
}

run().then(() => {
  process.exit(0);
});
