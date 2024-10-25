// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mines {
    address public manager;
    address public player;
    uint public betAmount;
    uint public noOfGems;
    uint public rewardAmount;
    uint public betRequired;
    event Bet(address indexed player, uint betAmount);
    event Reward(address indexed player, uint rewardAmount);
    

    constructor(uint _betAmount) {
        manager = msg.sender;
        betRequired = _betAmount;
    }

    function bet() public payable {
        // require(msg.value >= 0,"enter a valid bet amount");
        require(msg.value == betRequired ,"Sent value must match bet amount");
        betAmount = msg.value;
        player = msg.sender;
        emit Bet(player, betAmount);
    }

    function reward(uint _noOfGems) public {
         noOfGems = _noOfGems;
    require(noOfGems >= 0, "error");
    rewardAmount = betAmount;
    for (uint i = 0; i < noOfGems; i++) {
        rewardAmount += rewardAmount / 5; 
    }
    }
    function claimReward() public {
        require(msg.sender == player, "only player can claim reward");
        require(address(this).balance >= rewardAmount, "Contract does not have enough balance");
        uint remainingBalance = address(this).balance - rewardAmount;
        payable(player).transfer(rewardAmount);
        payable(manager).transfer(remainingBalance);

        emit Reward(player, rewardAmount);
    }

    function fundContract() public payable {
        require(msg.sender == manager, "Only manager can fund the contract");
        payable(address(this)).transfer(msg.value);
    }

}