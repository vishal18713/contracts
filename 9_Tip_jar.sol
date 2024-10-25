// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract TipJar {

    address public owner;
    address payable public recipient;
    uint public totalTips;

    event TipReceived(address indexed sender, uint amount);
    event Withdrawal(address indexed recipient, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
        
    }

    constructor(address payable _receipient) {
        owner = msg.sender;
        recipient = _receipient;
        totalTips =0;
    }

    function sendTips() external payable  {
        require(msg.value > 0, "No tip provided");
        
        totalTips += msg.value;

        emit TipReceived(msg.sender, msg.value);


        
    }
}
