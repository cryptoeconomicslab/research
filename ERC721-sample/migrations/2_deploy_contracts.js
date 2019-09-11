
var ERC721 = artifacts.require("ERC721");
var ERC721TestToken = artifacts.require("ERC721TestToken");

module.exports = function(deployer) {
  deployer.deploy(ERC721);
  deployer.deploy(ERC721TestToken);
};
