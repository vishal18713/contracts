// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleLottery {
    address public manager;
    address[] public players;
    address[] public previousWinners;
    uint256 public entryFee;

    event WinnerPaid(address indexed winner, uint256 winnerAmount, address indexed manager, uint256 managerAmount);
    event EntryFeeChanged(uint256 newEntryFee);

    constructor(uint256 _initialEntryFee) {
        manager = msg.sender;
        entryFee = _initialEntryFee;
    }

    function enter() public payable {
        require(msg.value == entryFee, "Incorrect ETH amount sent for entry");
        require(msg.sender != manager, "Manager cannot participate in the lottery");
        players.push(msg.sender);
    }

    function pickWinner() public onlyManager {
        require(players.length > 0, "No players in the lottery");

        uint256 index = random() % players.length;
        address winner = players[index];
        uint256 totalAmount = address(this).balance;
        
        uint256 managerAmount = totalAmount * 20 / 100;
        uint256 winnerAmount = totalAmount - managerAmount;
        
        payable(manager).transfer(managerAmount);

        payable(winner).transfer(winnerAmount);

        emit WinnerPaid(winner, winnerAmount, manager, managerAmount);

        previousWinners.push(winner);

        players = new address[](0);
    }

    function setEntryFee(uint256 _newEntryFee) public onlyManager {
        entryFee = _newEntryFee;
        emit EntryFeeChanged(_newEntryFee);
    }

    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    function getPreviousWinners() public view returns (address[] memory) {
        return previousWinners;
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, players)));
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }
}
