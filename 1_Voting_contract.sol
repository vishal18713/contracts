// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Votting {
    struct Proposal {
        uint id;
        string description;
        uint voteCount;
    }

    Proposal[] public Proposals;
    mapping(address => mapping(uint => bool)) public votes;

    event proposalCreated(uint id, string description);
    event voted(uint proposalId, address voter);

    function createPraposal(string memory _description) public {
        uint proposalId = Proposals.length;
        Proposals.push(Proposal(proposalId, _description, 0));
        emit proposalCreated(proposalId, _description);
    }

    function vote(uint _proposalId) public {
        require(
            !votes[msg.sender][_proposalId],
            "already votedc for this proposal"
        );
        require(_proposalId < Proposals.length, "Invalid proposalID");
        Proposals[_proposalId].voteCount += 1;
        votes[msg.sender][_proposalId] = true;
        emit voted(_proposalId, msg.sender);
    }

    function getProposal(
        uint _proposalId
    ) public view returns (uint, string memory, uint) {
        require(_proposalId < Proposals.length, "Invalid Proposal Id");
        Proposal memory proposal = Proposals[_proposalId];
        return (proposal.id, proposal.description, proposal.voteCount);
    }

    function getProposals() public view returns (Proposal[] memory) {
        return Proposals;
    }
}
