// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public projetCreater;
    uint public fundingGoal;
    uint public deadLine;
    uint public totalFunds;
    bool public fundingGoalReached;
    bool public campainClosed;

    mapping(address => uint) public contributions;

    event fundTransfer(address backer, uint amount, bool isContribution);
    event goalReached(address projetCreater, uint totalFunds);

    modifier afterDeadline() {
        require(
            block.timestamp >= deadLine,
            "the deadline has not passed yet."
        );
        _;
    }

    modifier onlyProjetCreater() {
        require(
            msg.sender == projetCreater,
            "only the projet creater can call this function."
        );
        _;
    }

    constructor(uint _fundingGoal, uint _durationInMinutes) {
        projetCreater = msg.sender;
        fundingGoal = _fundingGoal;
        deadLine = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    function contribute() public payable {
        require(!campainClosed, "the campain is closed.");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
        emit fundTransfer(msg.sender, msg.value, true);
    }

    function checkGoalReached() public afterDeadline {
        if (totalFunds >= fundingGoal) {
            fundingGoalReached = true;
            emit goalReached(projetCreater, totalFunds);
        }
        campainClosed = true;
    }

    function withdrawFunds() public onlyProjetCreater{
        require(fundingGoalReached, "funding goal was not reached.");
        require(address(this).balance > 0,"no funds to withdraw.");
        payable(projetCreater).transfer(address(this).balance);
        emit fundTransfer(projetCreater, address(this).balance, false);
    }

    function refund() public afterDeadline{
        require(!fundingGoalReached,"funding goal was reached.");
        require(contributions[msg.sender] > 0, "no funds to refund.");
        uint amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit fundTransfer(msg.sender, amount, false);
    }

}
