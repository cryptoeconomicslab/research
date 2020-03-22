const isImmediateDecidable = require("./decide");

/**
 * V2: Optimized Rule
 * @param {*} property
 */
function challengeV2(property) {
  const predicate = property.predicate;
  if (isImmediateDecidable(property)) {
    //return [];
  }
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

module.exports = challengeV2;
