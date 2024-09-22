const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Slunicoin", function () {
    let slunicoin;
    let owner, addr1, daoContract;

    beforeEach(async function () {
        const Slunicoin = await ethers.getContractFactory("Slunicoin");
        [owner, addr1] = await ethers.getSigners();
        slunicoin = await Slunicoin.deploy();
    });

    it("Dovrebbe avere il nome e il simbolo corretti", async function () {
        expect(await slunicoin.name()).to.equal("Slunicoin");
        expect(await slunicoin.symbol()).to.equal("SLC");
    });

    it("Dovrebbe assegnare tutti i 20 milioni di token all'owner", async function () {
        const ownerBalance = await slunicoin.balanceOf(owner.address);
        expect(await slunicoin.totalSupply()).to.equal(ownerBalance);
    });

});
