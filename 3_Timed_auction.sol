// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimedAuction {
    address payable public beneficiary;
    uint public auctionEndTime;
    uint public remaining_time;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturens;
    bool public auctionStatus;

    event highestBidIncreased(address bidder, uint amount);
    event auctionEnded(address winner, uint amount);

    constructor(address payable _beneficiary, uint _biddingTime) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
        remaining_time = auctionEndTime - block.timestamp;
    }

   

    function bid() public payable {
        require(block.timestamp <= auctionEndTime, "Auction already ended");
        require(msg.value > highestBid, "There already is a higher bid");
        if (highestBid != 0) {
            pendingReturens[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit highestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturens[msg.sender];
        if (amount > 0) {
            pendingReturens[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                pendingReturens[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public payable {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!auctionStatus, "auctionEnd has already been called");
        auctionStatus  =true;
        emit auctionEnded(highestBidder, highestBid);

        payable(beneficiary).transfer(highestBid);
    }
}
