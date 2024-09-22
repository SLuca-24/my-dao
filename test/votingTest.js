// SPDX-License-Identifier: MIT
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAOVoting", function () {
    let daoVoting;
    let owner;
    let member1;
    let member2;

    beforeEach(async function () {
        [owner, member1, member2] = await ethers.getSigners();
//deploy
        const DAOVoting = await ethers.getContractFactory("DAOVoting");
        daoVoting = await DAOVoting.deploy();
        await daoVoting.deployed();
    });

    it("should set the owner correctly", async function () {
        expect(await daoVoting.owner()).to.equal(owner.address);
    });

    it("should allow the owner to set the DAO contract", async function () {

        const FakeDAO = await ethers.getContractFactory("DAOContract");
        const fakeDAO = await FakeDAO.deploy();
        await fakeDAO.deployed();

        await daoVoting.setDAOContract(fakeDAO.address);
        expect(await daoVoting.MyDAO()).to.equal(fakeDAO.address);
    });

    it("should allow members to create proposals", async function () {

        await daoVoting.setDAOContract(owner.address);
        await daoVoting.createProposal("Proposal 1");
        
        const proposal = await daoVoting.proposals(1);
        expect(proposal.description).to.equal("Proposal 1");
        expect(proposal.active).to.be.true;
        expect(proposal.proposer).to.equal(owner.address);
    });

    it("should allow members to vote on proposals", async function () {

        await daoVoting.setDAOContract(owner.address);
        await daoVoting.createProposal("Proposal 1");

        await daoVoting.voteOnProposal(1, true);
        
        const proposal = await daoVoting.proposals(1);
        expect(proposal.votesPro).to.equal(1);
    });

    it("should allow the owner or proposer to close a proposal", async function () {
 
        await daoVoting.setDAOContract(owner.address);
        await daoVoting.createProposal("Proposal 1");
        
        await daoVoting.closeProposal(1);
        const proposal = await daoVoting.proposals(1);
        expect(proposal.active).to.be.false;
    });


});
