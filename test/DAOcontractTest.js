// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAOContract", function () {
    let daoContract;
    let owner;
    let addr1;
    const sharePrice = ethers.utils.parseEther("1");

    beforeEach(async function () {
        [owner, addr1] = await ethers.getSigners();

        const DAOContract = await ethers.getContractFactory("DAOContract");
        daoContract = await DAOContract.deploy();
        await daoContract.deployed();
    });

    it("should set the owner correctly", async function () {
        expect(await daoContract.owner()).to.equal(owner.address);
    });

    it("should allow the owner to toggle sale state", async function () {
        await daoContract.toggleSaleState();
        expect(await daoContract.isSaleActive()).to.equal(false);
        
        await daoContract.toggleSaleState();
        expect(await daoContract.isSaleActive()).to.equal(true);
    });

    it("should allow members to buy shares and become a member", async function () {

        await daoContract.connect(addr1).buyShares(1, { value: sharePrice });

        expect(await daoContract.isMember(addr1.address)).to.equal(true);
        expect(await daoContract.sharesOwned(addr1.address)).to.equal(1);
    });

    it("should not allow to buy shares if sale is inactive", async function () {
        await daoContract.toggleSaleState();
        
        await expect(daoContract.connect(addr1).buyShares(1, { value: sharePrice }))
            .to.be.revertedWith("We are not selling shares right now, please retry later");
    });

    it("should not allow to buy shares with incorrect payment", async function () {
        await expect(daoContract.connect(addr1).buyShares(1, { value: ethers.utils.parseEther("0.5") }))
            .to.be.revertedWith("Incorrect payment amount, the change is 1 ETH x shares, example: 5 shares = 5 ETH");
    });

    it("should allow the owner to withdraw funds", async function () {
        await daoContract.connect(addr1).buyShares(10, { value: sharePrice });

        const initialOwnerBalance = await ethers.provider.getBalance(owner.address);
        await daoContract.withdrawFunds();
        const finalOwnerBalance = await ethers.provider.getBalance(owner.address);

        expect(finalOwnerBalance).to.be.above(initialOwnerBalance);
    });

    it("should correctly check the ETH balance of the contract", async function () {
        await daoContract.connect(addr1).buyShares(1, { value: sharePrice });
        
        expect(await daoContract.checkContractEthBalance()).to.equal(sharePrice);
    });
});
