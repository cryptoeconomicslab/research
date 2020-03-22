function isImmediateDecidable(property) {
  const predicate = property.predicate;
  if (predicate == "ThereExistsSuchThat") {
    return isImmediateDecidable(property.inputs[2]);
  } else if (predicate == "And" || predicate == "Or") {
    return property.inputs.reduce(
      (acc, i) => acc && isImmediateDecidable(i),
      true
    );
  } else if (predicate == "ForAllSuchThat" || predicate == "Not") {
    return false;
  } else {
    return true;
  }
}
module.exports = isImmediateDecidable;
