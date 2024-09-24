// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Wallet {
    struct Deposit {
        uint amount;
        uint unlockTime;
    }

    mapping(address => Deposit) public deposits;

    function deposit(uint lockPeriod) external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        require(
            deposits[msg.sender].amount == 0,
            "Existing deposit in progress"
        );

        deposits[msg.sender] = Deposit({
            amount: msg.value,
            unlockTime: block.timestamp + lockPeriod
        });
    }

    function withdraw() external {
        Deposit memory userDeposit = deposits[msg.sender];
        require(userDeposit.amount > 0,"No deposit found");
        require(block.timestamp >= userDeposit.unlockTime,"Deposit is still locked");

        uint amount = userDeposit.amount;
        deposits[msg.sender] = Deposit({amount: 0, unlockTime: 0});

        payable(msg.sender).transfer(amount);
    }

    function getRemainingLockTime() external view returns (uint) {
        Deposit memory userDeposit = deposits[msg.sender];
         if (block.timestamp >= userDeposit.unlockTime) {
            return 0;
        }

        return userDeposit.unlockTime - block.timestamp;
        
    }
}
