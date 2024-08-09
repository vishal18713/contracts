// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public depositor;
    address public beneficiary;
    address public escrowAgent;
    uint public amount;
    bool public conditionMet;

    modifier onlyDepositor() {
        require(
            msg.sender == depositor,
            "only depositor can call this function!"
        );
        _;
    }

    modifier onlyEscroAgent() {
        require(
            msg.sender == escrowAgent,
            "only escrow agent can call this function !"
        );
        _;
    }

    constructor(address _beneficiary, address _escrowAgent) {
        depositor = msg.sender;
        beneficiary = _beneficiary;
        escrowAgent = _escrowAgent;
        conditionMet = false;
    }

    function deposit() public payable onlyDepositor {
        require(amount == 0, "funds have already been deposited.");
        amount = msg.value;
    }

    function setConditionMet() public onlyEscroAgent {
        conditionMet = true;
    }

    function releaseFunds() public onlyEscroAgent {
        require(conditionMet, "condition not met yet.");
        require(amount > 0, "mo funds to release");

        uint releaseAmount = amount;
        amount = 0;
        payable(beneficiary).transfer(releaseAmount);
    }
    function refund() public onlyEscroAgent {
        require(!conditionMet, "Condition has been met, cannot refund.");
        require(amount > 0, "No funds to refund.");
        uint refundAmount = amount;
        amount = 0;
        payable(depositor).transfer(refundAmount);
    }
}
