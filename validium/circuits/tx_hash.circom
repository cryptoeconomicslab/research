include "../node_modules/circomlib/circuits/poseidon.circom";

template TxHash() {
    signal input tx_type;
    signal input from;
    signal input to;
    signal input amount;
    signal output out;

    component hash = Poseidon(4);
    hash.inputs[0] <== tx_type;
    hash.inputs[1] <== from;
    hash.inputs[2] <== to;
    hash.inputs[3] <== amount;
    hash.out ==> out;
}