const snarkjs = require("snarkjs");
const fs = require("fs");
const circomlib = require("circomlib");
const eddsa = circomlib.eddsa;
const babyJub = circomlib.babyJub;
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
  // Alice transfer coin to Bob
  const {
    hashedOwner,
    senderSalt,
    recipientSalt,
    transaction,
    zkProof,
  } = await executeSenderProcedure(bobPackedPubKey);
  // Bob check transaction's sender and recipient addresses.
  const isValidTransferForBob = await executeRecipientProcedure(
    alicePackedPubKey,
    bobPackedPubKey,
    senderSalt,
    recipientSalt,
    transaction,
    zkProof
  );
  // Carol can check transaction with hashed owner address, transaction and zk-proof.
  const isValidTransferForCarol = await executeVerifierProcedure(
    hashedOwner,
    transaction,
    zkProof
  );
  console.log(isValidTransferForBob && isValidTransferForCarol);
}

run().then(() => {
  process.exit(0);
});

async function executeSenderProcedure(recipientPackedPublicKey) {
  const senderSalt = Buffer.from(arrayify(keccak256(toUtf8Bytes("alicesalt"))));
  const recipientSalt = Buffer.from(
    arrayify(keccak256(toUtf8Bytes("bobsalt")))
  );
  const hashedOwner = await hashPublicKey(alicePackedPubKey, senderSalt);
  const bobHashedPublicKey = await hashPublicKey(
    recipientPackedPublicKey,
    recipientSalt
  );
  const transaction = bobHashedPublicKey; //Buffer.from(arrayify(keccak256(toUtf8Bytes("message"))));
  const signature = eddsa.sign(alicePrvKey, transaction);
  const pSignature = eddsa.packSignature(signature);
  const uSignature = eddsa.unpackSignature(pSignature);
  console.log(
    "verify signature in local",
    eddsa.verify(transaction, uSignature, alicePubKey)
  );
  const inputs = {
    sig: [
      buffer2bits(pSignature.slice(0, 32)),
      buffer2bits(pSignature.slice(32, 64)),
    ],
    pub_key: buffer2bits(alicePackedPubKey),
    salt: buffer2bits(senderSalt),
    tx: buffer2bits(transaction),
  };

  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    inputs,
    "./build/circuits/ownership.wasm",
    "./build/keys/ownership.circom_circuit_final.zkey"
  );

  return {
    hashedOwner,
    senderSalt,
    recipientSalt,
    transaction,
    pSignature,
    zkProof: {
      proof,
      publicSignals,
    },
  };
}

async function executeRecipientProcedure(
  senderPackedPubKey,
  recipientPackedPubKey,
  senderSalt,
  recipientSalt,
  transaction,
  zkProof
) {
  const senderHashedPublicKey = await hashPublicKey(
    senderPackedPubKey,
    senderSalt
  );
  const recipientHashedPublicKey = await hashPublicKey(
    recipientPackedPubKey,
    recipientSalt
  );
  if (
    transaction.toString("hex") !== recipientHashedPublicKey.toString("hex")
  ) {
    return false;
  }
  return await executeVerifierProcedure(
    senderHashedPublicKey,
    transaction,
    zkProof
  );
}

async function executeVerifierProcedure(
  hashedPublicKey,
  transaction,
  { proof, publicSignals }
) {
  const publicInputs = ffjs.utils.unstringifyBigInts(publicSignals);
  const publicInputsBuffer = bit2buffer(publicInputs);
  if (
    hashedPublicKey.toString("hex") !==
    publicInputsBuffer.slice(0, 32).toString("hex")
  ) {
    return false;
  }
  if (
    transaction.toString("hex") !==
    publicInputsBuffer.slice(32, 64).toString("hex")
  ) {
    return false;
  }

  const vKey = JSON.parse(fs.readFileSync("./verification_key.json"));

  const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);
  return res;
}

async function hashPublicKey(pPubKey, salt) {
  const { publicSignals } = await snarkjs.groth16.fullProve(
    {
      pub_key: buffer2bits(pPubKey),
      salt: buffer2bits(salt),
    },
    "./build/circuits/hash.wasm",
    "./build/keys/hash.circom_circuit_final.zkey"
  );
  const publicInputs = ffjs.utils.unstringifyBigInts(publicSignals);
  const publicInputsBuffer = bit2buffer(publicInputs);
  return publicInputsBuffer.slice(0, 32);
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
