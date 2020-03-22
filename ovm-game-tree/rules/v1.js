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

module.exports = challengeV1;
