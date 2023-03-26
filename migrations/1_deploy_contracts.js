const MockUSDT = artifacts.require("MockUSDT");
const FGT = artifacts.require("FGT");
const Factory = artifacts.require("Factory");

module.exports = function(deployer) {
  deployer.deploy(Factory);
};
