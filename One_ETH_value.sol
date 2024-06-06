// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//1/ETH value calculator

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EthPriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    constructor() {

        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
function getLatestPrice() public view returns (int) {
    (
        uint80 roundID, 
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = priceFeed.latestRoundData();
    return price;
}
}