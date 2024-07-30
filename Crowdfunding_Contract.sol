// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // State variables
    address public projectCreator;
    uint256 public fundingGoal;
    uint256 public totalFunds;
    uint256 public deadline;
    bool public fundingGoalReached;
    bool public campaignClosed;

    mapping(address => uint256) public contributions;

    // Events
    event FundTransfer(address backer, uint256 amount, bool isContribution);
    event GoalReached(address projectCreator, uint256 totalFunds);

    // Modifiers
    modifier afterDeadline() {
        require(block.timestamp >= deadline, "The deadline has not passed yet.");
        _;
    }

    modifier onlyCreator() {
        require(msg.sender == projectCreator, "Only the project creator can call this function.");
        _;
    }

    // Constructor
    constructor(
        uint256 _fundingGoal,
        uint256 _durationInMinutes
    ) {
        projectCreator = msg.sender;
        fundingGoal = _fundingGoal;
        deadline = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    // Function to contribute to the crowdfunding campaign
    function contribute() public payable {
        require(!campaignClosed, "The campaign is closed.");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
        emit FundTransfer(msg.sender, msg.value, true);
    }

    // Function to check if the funding goal has been reached
    function checkGoalReached() public afterDeadline {
        if (totalFunds >= fundingGoal) {
            fundingGoalReached = true;
            emit GoalReached(projectCreator, totalFunds);
        }
        campaignClosed = true;
    }

    // Function to withdraw funds by the project creator if the goal is reached
    function withdrawFunds() public onlyCreator {
        require(fundingGoalReached, "Funding goal has not been reached.");
        require(address(this).balance > 0, "No funds to withdraw.");
        payable(projectCreator).transfer(address(this).balance);
        emit FundTransfer(projectCreator, address(this).balance, false);
    }

    // Function to refund contributions if the goal is not reached
    function refund() public afterDeadline {
        require(!fundingGoalReached, "Funding goal was reached, no refunds.");
        require(contributions[msg.sender] > 0, "No contributions to refund.");
        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit FundTransfer(msg.sender, amount, false);
    }
}
