const hre = require("hardhat");
const fs = require("fs");
const fse = require("fs-extra");
const { verify } = require("../utils/verify");
const {
  getAmountInWei,
  developmentChains,
} = require("../utils/helper-scripts");

async function main() {
  const deployNetwork = hre.network.name;
  console.log(deployNetwork);
  // console.log(verify);//[AsyncFunction: verify]
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
