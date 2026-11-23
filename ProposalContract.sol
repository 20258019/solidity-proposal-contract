// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address public owner;
    uint256 public counter;

    struct Proposal {
        string title;
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) public proposal_history;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function create(
        string calldata _title,
        string calldata _description,
        uint256 _total_vote_to_end
    ) external onlyOwner {
        require(_total_vote_to_end > 0, "Invalid vote limit");

        counter += 1;

        proposal_history[counter] = Proposal(
            _title,
            _description,
            0,
            0,
            0,
            _total_vote_to_end,
            false,
            true
        );
    }

    function vote(uint8 choice) external {
        require(counter > 0, "No proposal");

        Proposal storage proposal = proposal_history[counter];
        require(proposal.is_active, "Proposal is closed");

        if (choice == 1) {
            proposal.approve += 1;
        } else if (choice == 2) {
            proposal.reject += 1;
        } else if (choice == 0) {
            proposal.pass += 1;
        } else {
            revert("Invalid choice");
        }

        proposal.current_state = calculateCurrentState();

        uint256 totalVotes =
            proposal.approve + proposal.reject + proposal.pass;

        if (totalVotes >= proposal.total_vote_to_end) {
            proposal.is_active = false;
        }
    }

    // Task 4: Custom approval rule (> 60%)
    function calculateCurrentState() private view returns (bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 total = approve + reject;

        if (total == 0) {
            return false;
        }

        return approve * 100 > total * 60;
    }
}
