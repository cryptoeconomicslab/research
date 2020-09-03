const chai = require("chai");
const {
  MockProvider,
  deployContract,
  getWallets,
  solidity,
} = require("ethereum-waffle");
const Verifier = require("../build/Verifier.json");
const ethers = require("ethers");
const snarkjs = require("snarkjs");
const fs = require("fs");
const circomlib = require("circomlib");
const eddsa = circomlib.eddsa;
const babyJub = circomlib.babyJub;
const smt = circomlib.smt;
const poseidon = circomlib.poseidon;

const Fr = require("ffjavascript").Scalar;
const { arrayify, keccak256, toUtf8Bytes } = ethers.utils;

async function deposit() {
  const tree = await smt.newMemEmptyTrie();
  const newLeaf = poseidon([0, 0, 0]);
  const res = await tree.insert(Fr.e(0), newLeaf);
  let siblings = res.siblings;
  while (siblings.length < 3) siblings.push(Fr.e(0));
  const inputs = {
    old_root: res.oldRoot,
    pub_txs: [0, 0],
    txs: [
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        .concat(siblings)
        .concat([0]),
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        .concat(siblings)
        .concat([0]),
    ],
  };
  console.log(inputs, res.oldRoot);
  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    inputs,
    "./build/circuits/state_transition_verifier.wasm",
    "./build/circuits/state_transition_verifier_circuit_final.zkey"
  );
  console.log("proof", proof, publicSignals);
  return { proof, publicSignals };
  //const vKey = JSON.parse(fs.readFileSync("./verification_key.json"));
  //return await snarkjs.groth16.verify(vKey, publicSignals, proof);
}

chai.use(solidity);
chai.use(require("chai-as-promised"));
const { expect, assert } = chai;

describe("Verifier", () => {
  const [wallet] = new MockProvider().getWallets();
  let verifier;

  beforeEach(async () => {
    verifier = await deployContract(wallet, Verifier, []);
  });

  describe("Verifier", () => {
    beforeEach(async () => {});

    it("verifyProof", async () => {
      const result = await deposit();
      const gas = await verifier.estimateGas.verifyProof(
        result.proof.pi_a.slice(0, 2),
        result.proof.pi_b.slice(0, 2),
        result.proof.pi_c.slice(0, 2),
        result.publicSignals
      );
      console.log(gas.toString());
      await verifier.verifyProof(
        result.proof.pi_a.slice(0, 2),
        result.proof.pi_b.slice(0, 2),
        result.proof.pi_c.slice(0, 2),
        result.publicSignals
      );
    }).timeout(20000);
  });
});
