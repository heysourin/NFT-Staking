const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  getAmountInWei,
  getAmountFromWei,
  moveTime,
} = require("../utils/helper-scripts");

describe("Contracts: ", function () {
  // let owner;
  let stakingVault;
  let nftContract;
  let tokenContract;

  const minCost = 100;
  const maxMintAmount = 5;
  const maxSupply = 50;

  async function runEveryTime() {
    const [owner, user1, user2, randomUser] = await ethers.getSigners();

    //Pixel NFT contract
    const NFTContract = await ethers.getContractFactory("PixelNFT");
    const nftContract = await NFTContract.deploy(
      maxSupply,
      minCost,
      maxMintAmount
    );
    await nftContract.deployed();

    //Pixel Rewards contract
    const TokenContract = await ethers.getContractFactory("PixelReward");
    const tokenContract = await TokenContract.deploy();
    await tokenContract.deployed();

    //Vault
    const Vault = await ethers.getContractFactory("NFTStakingVault");
    const stakingVault = await Vault.deploy(
      nftContract.address,
      tokenContract.address
    );
    await stakingVault.deployed();

    return {
      owner,
      user1,
      user2,
      randomUser,
      nftContract,
      tokenContract,
      stakingVault,
    };
  }
  describe("Correct Deployement Pixel NFT Smart Contract", () => {
    it("Should check the correct owner", async () => {
      const { owner, nftContract } = await loadFixture(runEveryTime);

      const nftContractOwner = await nftContract.owner();
      const ownerAddress = await owner.getAddress();
      expect(nftContractOwner).to.equal(ownerAddress);
    });

    it("Should return correct initial parameters", async () => {
      const { nftContract } = await loadFixture(runEveryTime);

      expect(await nftContract.baseURI()).to.equal("");
      expect(await nftContract.cost()).to.equal(minCost);
      expect(await nftContract.maxSupply()).to.equal(maxSupply);
      expect(await nftContract.maxMintAmountPerTx()).to.equal(maxMintAmount);
      expect(await nftContract.paused()).to.equal("1");
    });
  });

  describe("ERC20 Token Reward Contract", () => {
    it("ERC20 Token should have correct owner", async () => {
      const { tokenContract, owner } = await loadFixture(runEveryTime);

      const tokenContractOwner = await tokenContract.owner();
      const ownerAddress = await owner.getAddress();
      expect(tokenContractOwner).to.equal(ownerAddress);
    });
  });

  describe("Staking Vault Contract", () => {
    it("Vault token should have correct owner", async () => {
      const { owner, stakingVault } = await loadFixture(runEveryTime);

      const vaultContractOwner = await stakingVault.owner();
      const ownerAddress = await owner.getAddress();
      expect(vaultContractOwner).to.equal(ownerAddress);
    });
  });

  describe("Testing core functions", () => {
    beforeEach(async () => {
      const { nftContract, tokenContract, stakingVault, owner } =
        await loadFixture(runEveryTime);

      await nftContract.connect(owner).pause(2);

      await tokenContract
        .connect(owner)
        .setController(stakingVault.address, true);
    });
    it("Should allow users to mint NFTs", async () => {
      const { nftContract, user1, owner } = await loadFixture(runEveryTime);

      await nftContract.connect(owner).pause(2);
      const mintCost = await nftContract.cost();
      // const totalCost = getAmountFromWei(mintCost) * 3;
      await nftContract.connect(user1).mint(4, { value: 400 });

      expect(await nftContract.totalSupply()).to.equal("4");
      expect(await nftContract.balanceOf(user1.address)).to.equal("4");
      console.log((await nftContract.totalSupply()));

      userWallet = Array.from(
        await nftContract.tokensOfOwner(user1.address),
        (x) => Number(x)
      );
      expect(userWallet).to.have.members([0, 1, 2, 3]);
      
    });
  });
});
