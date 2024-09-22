// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyDAO.sol";

contract DAOVoting {

    address public owner;
    DAOContract public MyDAO;
    uint256 public proposalCount;

    struct Proposal {
        uint256 id;
        string description;
        uint256 votesPro;
        uint256 votesAgainst;
        bool active;
        address proposer;
        uint256 creationTime;
        uint256 duration; 
        bool accepted;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 id, string description);
    event VoteCasted(address voter, uint256 proposalId, bool votePro, uint256 voteWeight);
    event ProposalClosed(uint256 id, bool approved);

    modifier onlyMembers() {
        require(address(MyDAO) != address(0), "DAO contract not linked");
        require(MyDAO.isMember(msg.sender) == true, "Only DAO members can vote");
        _; 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _; 
    }

    constructor() {
        owner = msg.sender;
        proposalCount = 0;
    }


    function setDAOContract(address _daoContract) public onlyOwner {
        MyDAO = DAOContract(_daoContract);
    }

    function createProposal(string memory _description) public onlyMembers {
        proposalCount++;
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = _description;
        newProposal.active = true;
        newProposal.proposer = msg.sender;
        newProposal.creationTime = block.timestamp;
        newProposal.duration = 5 days;
        newProposal.accepted = false;

        emit ProposalCreated(proposalCount, _description);
    }

    function voteOnProposal(uint256 _proposalId, bool _votePro) public onlyMembers {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active, "Proposal is not active");
        require(!proposal.hasVoted[msg.sender], "Already voted on this proposal");

        uint256 voterShares = MyDAO.sharesOwned(msg.sender);
        require(voterShares > 0, "No shares owned");

        proposal.hasVoted[msg.sender] = true; 

        if (_votePro) {
            proposal.votesPro += voterShares;
        } else {
            proposal.votesAgainst += voterShares;
        }

        emit VoteCasted(msg.sender, _proposalId, _votePro, voterShares);
    }

    function closeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active, "Proposal is already closed");
        require(msg.sender == proposal.proposer || msg.sender == owner, "Only proposer or owner can close the proposal");


        if (block.timestamp > proposal.creationTime + proposal.duration) {
            proposal.active = false;
        } else {
            proposal.accepted = proposal.votesPro > proposal.votesAgainst;
            proposal.active = false;
            emit ProposalClosed(_proposalId, proposal.accepted);
        }
    }

    function isProposalExpired(uint256 _proposalId) public view returns (bool) {
        Proposal storage proposal = proposals[_proposalId];
        return !proposal.active || block.timestamp > proposal.creationTime + proposal.duration;
    }

    function getAllProposals() public view returns (
        uint256[] memory ids,
        string[] memory descriptions,
        bool[] memory active,
        bool[] memory accepted
    ) {
        ids = new uint256[](proposalCount);
        descriptions = new string[](proposalCount);
        active = new bool[](proposalCount);
        accepted = new bool[](proposalCount);

        for (uint256 i = 1; i <= proposalCount; i++) {
            Proposal storage proposal = proposals[i];
            ids[i - 1] = proposal.id;
            descriptions[i - 1] = proposal.description;
            active[i - 1] = proposal.active;
            accepted[i - 1] = proposal.accepted;
        }
    }

    function getAcceptedProposals() public view returns (
        uint256[] memory ids,
        string[] memory descriptions
    ) {
        uint256 acceptedCount = 0;
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (proposals[i].accepted) {
                acceptedCount++;
            }
        }

        ids = new uint256[](acceptedCount);
        descriptions = new string[](acceptedCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (proposals[i].accepted) {
                ids[index] = proposals[i].id;
                descriptions[index] = proposals[i].description;
                index++;
            }
        }
    }

    function getRejectedProposals() public view returns (
        uint256[] memory ids,
        string[] memory descriptions
    ) {
        uint256 rejectedCount = 0;
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (!proposals[i].active && !proposals[i].accepted) {
                rejectedCount++;
            }
        }

        ids = new uint256[](rejectedCount);
        descriptions = new string[](rejectedCount);

        uint256 index = 0;
        for (uint256 i = 1; i <= proposalCount; i++) {
            if (!proposals[i].active && !proposals[i].accepted) {
                ids[index] = proposals[i].id;
                descriptions[index] = proposals[i].description;
                index++;
            }
        }
    }
}
