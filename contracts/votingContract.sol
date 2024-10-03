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
        uint256 abstainedVotes;
        bool active;
        address proposer;
        uint256 creationTime;
        uint256 duration; 
        bool accepted;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => address) public voteDelegation;
    mapping(address => uint256) public delegatedShares;


    event ProposalCreated(uint256 id, string description);
    event VoteCasted(address voter, uint256 proposalId, bool votePro, uint256 voteWeight);
    event ProposalClosed(uint256 id, bool approved);

    modifier onlyMembers() {
        require(address(MyDAO) != address(0), "DAO contract not linked");
        require(MyDAO.isMember(msg.sender), "Only DAO members can vote");
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



   function delegateVote(address _delegate) public onlyMembers {
    require(_delegate != msg.sender, "You cannot delegate your vote to yourself");
    require(MyDAO.isMember(_delegate), "Delegate must be a DAO member");
    require(voteDelegation[msg.sender] == address(0), "You have already delegated your vote");

    for (uint256 i = 0; i < proposalCount; i++) {
        Proposal storage proposal = proposals[i];
        if (proposal.active && proposal.hasVoted[msg.sender]) {
            revert("You cannot delegate your vote after voting on an active proposal");
        }
    }

    voteDelegation[msg.sender] = _delegate;
    delegatedShares[_delegate] += MyDAO.sharesOwned(msg.sender);
}



function voteOnProposal(uint256 _proposalId, uint8 _voteOption) public onlyMembers {
    // type 1 to vote pro, type 2 to vote against, evertything else will count as abstained
    require(_voteOption <= 2, "Invalid vote option");
    Proposal storage proposal = proposals[_proposalId];
    require(proposal.active, "Proposal is not active");

    address voter = msg.sender;

    
    require(voteDelegation[voter] == address(0), "You cant vote because you have delegated your vote");

    uint256 voterShares = MyDAO.sharesOwned(voter);
    require(voterShares > 0, "No shares owned");

   
    uint256 totalShares = voterShares + delegatedShares[voter];

    require(!proposal.hasVoted[voter], "You have already voted on this proposal");
    proposal.hasVoted[voter] = true;

    if (_voteOption == 1) {
        proposal.votesPro += totalShares;
    } else if (_voteOption == 2) {
        proposal.votesAgainst += totalShares;
    } else {
        proposal.abstainedVotes += totalShares;
    }

    emit VoteCasted(voter, _proposalId, _voteOption == 1, totalShares);
}

function revokeDelegation() public onlyMembers {
    address delegate = voteDelegation[msg.sender];
    require(delegate != address(0), "No active delegation to revoke");

    delegatedShares[delegate] -= MyDAO.sharesOwned(msg.sender);
    voteDelegation[msg.sender] = address(0);
}



    function closeProposal(uint256 _proposalId) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active, "Proposal is already closed");
        require(msg.sender == proposal.proposer || msg.sender == owner, "Only proposer or owner can close the proposal");

        if (block.timestamp > proposal.creationTime + proposal.duration) {
            proposal.active = false;
        } else {
            proposal.accepted = proposal.votesPro > proposal.votesAgainst;
        }
        proposal.active = false;
        emit ProposalClosed(_proposalId, proposal.accepted);
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
