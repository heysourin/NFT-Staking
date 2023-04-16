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

  const baseURI = "ipffs://QmSfRvWHmZVBvSTjzGghsFzDEuMDdT2ZceS8Nvn35Lq2Wr";

  const maxSupply = 50;
  const minCost = getAmountInWei(0.01);
  const maxMintAmount = 5;

  //Deploy Pixel NFT smart contract
  const NFTContract = await ethers.getContractFactory("PixelNFT");
  const nftContract = await NFTContract.deploy(
    maxSupply,
    minCost,
    maxMintAmount
  );

  await nftContract.deployed();

  const set_tx = await nftContract.setBaseURI(baseURI);
  await set_tx.wait();

  //Deploy rewards tokes
  const TokenContract = await ethers.getContractFactory("PixelReward");
  const tokenContract = await TokenContract.deploy();

  await tokenContract.deployed();

  //Deploying the vault contract
  const Vault = await ethers.getContractFactory("NFTStakingVault");
  const stakingVault = await Vault.deploy(
    nftContract.address,
    tokenContract.address
  );
  await stakingVault.deployed();

  const control_tx = await tokenContract.setController(
    stakingVault.address,
    true
  );

  await control_tx.wait();

  console.log("Pixel NFT contract deployed at", nftContract.address);
  console.log("Pixel rewards token deployed at", tokenContract.address);
  console.log("NFT Staking vault deployed at", stakingVault.address);
  console.log("Network deployed at: \n", deployNetwork);

  //TODO: Transfer the contract and ABI to the frontend
  // if(fs.existsSync("../"))

  if (
    !developmentChains.includes(deployNetwork) &&
    hre.config.etherscan.apiKey[deployNetwork]
  ) {
    console.log("Waiting 6 blocks for verification");

    await stakingVault.deployTransaction.wait(6);

    const args = [nftContract.address, tokenContract.address];
    await verify(stakingVault.address, args);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
