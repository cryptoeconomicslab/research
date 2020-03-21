const parser = require("@cryptoeconomicslab/ovm-parser");
const {
  applyLibraries
} = require("@cryptoeconomicslab/ovm-transpiler/lib/QuantifierTranslater");

const chamberParser = new parser.Parser();
const parsed = chamberParser.parse(`
@library
@quantifier("range,NUMBER,\${zero}-\${upper_bound}")
def LessThan(n, upper_bound) :=
  IsLessThan(n, upper_bound)

@library
@quantifier("proof.block\${b}.range\${token},RANGE,\${range}")
def IncludedAt(proof, leaf, token, range, b) :=
  VerifyInclusion(leaf, token, range, proof, b)

@library
@quantifier("so.block\${b}.range\${token},RANGE,\${range}")
def SU(so, token, range, b) :=
  IncludedAt(so, token, range, b).any()

def checkpoint(su) := 
  LessThan(su.2).all(b -> 
    SU(su.0, su.1, b).all(old_su -> old_su())
  )

`);
const transpiled = applyLibraries(parsed.declarations, [], { zero: 0 });
const property = transpiled[3].body;
console.log("V1");
showGameTree(property, 1);
console.log("V2");
showGameTree(property, 2);

function showGameTree(property, version, depth = 1) {
  console.log(new Array(depth).join("-"), formatProperty(property));
  challenge(property, version).map(p => showGameTree(p, version, depth + 1));
}

function formatProperty(property) {
  const predicate = property.predicate;
  if (predicate == "ForAllSuchThat" || predicate == "ThereExistsSuchThat") {
    return predicate + "(" + formatProperty(property.inputs[2]) + ")";
  } else if (predicate == "And" || predicate == "Or" || predicate == "Not") {
    return predicate + "(" + property.inputs.map(i => formatProperty(i)) + ")";
  } else {
    return predicate;
  }
}

function challenge(property, version) {
  if (version == 1) {
    return challengeV1(property);
  } else {
    return challengeV2(property);
  }
}

/**
 * V1: Original Rule
 * @param {*} property
 */
function challengeV1(property) {
  const predicate = property.predicate;
  if (predicate == "ForAllSuchThat") {
    return [
      {
        predicate: "Not",
        inputs: [property.inputs[2]]
      }
    ];
  } else if (predicate == "ThereExistsSuchThat") {
    return [
      {
        predicate: "ForAllSuchThat",
        inputs: [
          "",
          "",
          {
            predicate: "Not",
            inputs: [property.inputs[2]]
          }
        ]
      }
    ];
  } else if (predicate == "And") {
    return property.inputs.map(i => {
      return {
        predicate: "Not",
        inputs: [i]
      };
    });
  } else if (predicate == "Or") {
    return [
      {
        predicate: "And",
        inputs: property.inputs.map(i => {
          return {
            predicate: "Not",
            inputs: [i]
          };
        })
      }
    ];
  } else if (predicate == "Not") {
    return [property.inputs[0]];
  } else {
    return [];
  }
}

/**
 * V2: Optimized Rule
 * @param {*} property
 */
function challengeV2(property) {
  const predicate = property.predicate;
  if (predicate == "ForAllSuchThat") {
    const c = challengeV2(property.inputs[2]);
    if (c.length > 0) {
      return c;
    } else {
      return [
        {
          predicate: "Not",
          inputs: [property.inputs[2]]
        }
      ];
    }
  } else if (predicate == "ThereExistsSuchThat") {
    return [
      {
        predicate: "ForAllSuchThat",
        inputs: [
          "",
          "",
          {
            predicate: "Not",
            inputs: [property.inputs[2]]
          }
        ]
      }
    ];
  } else if (predicate == "And") {
    return property.inputs.map(i => {
      const c = challengeV2(i);
      if (c.length > 0) {
        return c[0];
      } else {
        return {
          predicate: "Not",
          inputs: [i]
        };
      }
    });
  } else if (predicate == "Or") {
    return [
      {
        predicate: "And",
        inputs: property.inputs.map(i => {
          return {
            predicate: "Not",
            inputs: [i]
          };
        })
      }
    ];
  } else if (predicate == "Not") {
    return [property.inputs[0]];
  } else {
    return [];
  }
}
