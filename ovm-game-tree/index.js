const parser = require("@cryptoeconomicslab/ovm-parser");
const {
  applyLibraries
} = require("@cryptoeconomicslab/ovm-transpiler/lib/QuantifierTranslater");
const challengeV1 = require("./rules/v1");
const challengeV2 = require("./rules/v2");
const challengeV3 = require("./rules/v3");
const checkpoint = require("./properties/checkpoint");
const swap = require("./properties/swap");
const exit = require("./properties/exit");

const chamberParser = new parser.Parser();

function transpile(source) {
  const parsed = chamberParser.parse(source);
  return applyLibraries(parsed.declarations, [], { zero: 0 });
}

const checkpointProperty = transpile(checkpoint)[3].body;
const swapProperty = transpile(swap)[7].body;
const exitProperty = transpile(exit)[0].body;
const Entity1 = 1;
const Entity2 = -1;

showResult("Checkpoint", checkpointProperty);
showResult("Swap", swapProperty);
showResult("Exit", exitProperty);

function showResult(name, property) {
  console.log("==========");
  console.log(name);
  console.log("V1");
  console.log("Max depth", showGameTree(property, 1));
  console.log("V2");
  console.log("Max depth", showGameTree(property, 2));
  console.log("V3");
  console.log("Max depth", showGameTree(property, 3));
  console.log("==========");
}

function showGameTree(property, version, depth = 1, entity = Entity1) {
  console.log(
    `${getEntity(entity)}:`,
    new Array(depth).join("-"),
    formatProperty(property)
  );
  const depthArray = challenge(property, version).map(p =>
    showGameTree(p, version, depth + 1, entity * -1)
  );
  if (depthArray.length === 0) {
    return depth;
  }
  return Math.max(...depthArray);
}

function getEntity(entity) {
  if (entity == Entity1) return "Q";
  else if (entity == Entity2) return "P";
  else throw new Error("invalid entity");
}

function formatProperty(property) {
  const predicate = property.predicate;
  if (predicate == "ForAllSuchThat" || predicate == "ThereExistsSuchThat") {
    return (
      replaceName(predicate) + "(" + formatProperty(property.inputs[2]) + ")"
    );
  } else if (predicate == "And" || predicate == "Or" || predicate == "Not") {
    return predicate + "(" + property.inputs.map(i => formatProperty(i)) + ")";
  } else {
    return predicate;
  }
}

function replaceName(predicate) {
  if (predicate === "ForAllSuchThat") {
    return "All";
  } else if (predicate === "ThereExistsSuchThat") {
    return "Any";
  } else {
    throw new Error("invalid predicate name");
  }
}

function challenge(property, version) {
  if (version === 1) {
    return challengeV1(property);
  } else if (version === 2) {
    return challengeV2(property);
  } else {
    return challengeV3(property);
  }
}
