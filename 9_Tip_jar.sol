// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract TipJar {

    address public owner;
    address payable public recipient;
    uint public totalTips;

    event TipReceived(address indexed sender, uint amount);

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

        recipient.transfer(msg.value);

    }

    function getBalance() external view returns (uint) {
        return address(this).balance;        
    }

     function changeRecipient(address payable newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient address");
        recipient = newRecipient;
    }

  
}
