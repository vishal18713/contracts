// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MyNFTCollection is ERC1155 {
    uint256 public currentTokenID = 0;
    address public contractOwner;

    struct data {
        uint tokenSupply;
        string uri;
        address creator;
        uint countoftotalsupply;
        // address[] participants;
        uint fundsCollected;
        uint revenue;
        uint totalFractionalAmount;
        // mapping(address => uint) fractionalOwnership;
        bool soldOut;
        bool isReleased;
        uint percentageShare;
    }


    mapping(uint256 => data) public tokenData;
    mapping (uint => address[]) public participants;
    mapping(uint=> mapping (address => uint)) public fractionalOwnership;

    event NFTMinted(uint256 indexed tokenId, address indexed creator, uint256 totalSupply, uint256 totalFractionalAmount);
    event RevenueDistributed(uint256 indexed tokenId, uint256 amount);
    event FundsAdded(uint256 indexed tokenId, uint256 amount);
    event StakePurchased(uint256 indexed tokenId, address indexed buyer, uint256 tokensPurchased, uint256 amountPaid);

    constructor(string memory baseURI) ERC1155(baseURI) {
        contractOwner = msg.sender;
    }

    // Mint a new NFT representing a song with fractional ownership
    function mintNFT(uint256 _totalSupply, string memory _uri, uint256 _totalFractionalAmount, uint _percentageShare) external {
        uint256 _id = currentTokenID;

        _mint(msg.sender, _id, _totalSupply, ""); // Mint one NFT with total supply representing fractions
        _setTokenURI(_id, _uri);
        tokenData[_id].tokenSupply = _totalSupply;
        tokenData[_id].countoftotalsupply = _totalSupply;
        tokenData[_id].creator = msg.sender;
        tokenData[_id].totalFractionalAmount = _totalFractionalAmount;
        tokenData[_id].fundsCollected = 0;
        currentTokenID++;
        tokenData[_id].soldOut = false;
        tokenData[_id].isReleased = false;
        tokenData[_id].percentageShare = _percentageShare;

        emit NFTMinted(_id, msg.sender, _totalSupply, _totalFractionalAmount);
    }

    // Set the URI for a specific token ID
    function _setTokenURI(uint256 tokenId, string memory _uri) internal {
        tokenData[tokenId].uri = _uri;
    }

    // Override the uri function to return the correct metadata URI
    function uri(uint256 tokenId) public view override returns (string memory) {
        return tokenData[tokenId].uri;
    }

    // Buy stakes in an NFT by specifying the number of tokens
    function buyStake(uint256 tokenId) external payable {
        uint256 availableFraction = tokenData[tokenId].tokenSupply;
        require(tokenData[tokenId].soldOut == false, "Token is sold out");
        require(availableFraction > 0, "No fractional ownership available");
        require(availableFraction >= 1, "Not enough fractional ownership available");

        uint256 pricePerToken = tokenData[tokenId].totalFractionalAmount / tokenData[tokenId].tokenSupply;
        uint256 requiredAmount = pricePerToken;

        // Ensure enough ETH is sent (should be handled by the front-end)
        require(msg.value >= requiredAmount, "Incorrect amount of ETH sent");

        if (fractionalOwnership[tokenId][msg.sender] == 0) {
            participants[tokenId].push(msg.sender);
        }

        fractionalOwnership[tokenId][msg.sender]++;
        tokenData[tokenId].fundsCollected += msg.value;
        tokenData[tokenId].tokenSupply--;

        emit StakePurchased(tokenId, msg.sender, 1, requiredAmount);

        // If all fractions are sold, mark as sold out
        if (tokenData[tokenId].tokenSupply == 0) {
            tokenData[tokenId].soldOut = true;
        }
    }

    // Distribute revenue to all token holders based on their fractional ownership
    function distributeRevenue(uint256 tokenId) public payable onlyOwner {
        uint256 amountToDistribute = (tokenData[tokenId].revenue * tokenData[tokenId].percentageShare) / 100; 
        uint256 artistShare = tokenData[tokenId].revenue - amountToDistribute;

        require(tokenData[tokenId].isReleased == true, "Song must be released to distribute revenue");
        require(amountToDistribute > 0, "No funds available for distribution");

        uint256 totalFraction = tokenData[tokenId].totalFractionalAmount;
        require(totalFraction > 0, "No fractions sold");

        // Transfer artist share
        payable(tokenData[tokenId].creator).transfer(artistShare);

        // Distribute the revenue to participants
        for (uint256 i = 0; i < participants[tokenId].length; i++) {
            address receiver = participants[tokenId][i];
            uint256 holderFraction =  fractionalOwnership[tokenId][receiver];
            if (holderFraction > 0) {
                uint256 share = (amountToDistribute * holderFraction) / totalFraction;
                payable(receiver).transfer(share);
            }
        }

        emit RevenueDistributed(tokenId, amountToDistribute);
    }

    // Function for the owner to add revenue to a specific NFT
    function addRevenueGen(uint256 tokenId) public payable onlyOwner {
        require(tokenData[tokenId].totalFractionalAmount > 0, "NFT does not exist");
        require(msg.value > 0, "No funds provided");
        tokenData[tokenId].revenue += msg.value;

        emit FundsAdded(tokenId, msg.value);
    }

    // Withdraw the contract's revenue for a specific token
    function withdrawFunds(uint256 tokenId) external onlyOwner {
        uint256 balance = tokenData[tokenId].revenue;
        require(balance > 0, "No funds to withdraw");
        payable(contractOwner).transfer(balance);
    }

    // Release the song (after all NFTs are sold)
    function releaseSong(uint256 tokenId) external onlyOwner {
        require(tokenData[tokenId].isReleased == false, "Song is already released");
        tokenData[tokenId].isReleased = true;
    }

    // Transfer funds to the artist after all tokens are sold
    function artistTokenSales(uint256 tokenId) public payable onlyOwner {
        require(tokenData[tokenId].isReleased == true, "Song not released yet");
        payable(tokenData[tokenId].creator).transfer(tokenData[tokenId].fundsCollected);
    }

    modifier onlyOwner {
        require(msg.sender == contractOwner, "Not the owner");
        _;
    }

    // Receive function to accept ETH
    receive() external payable {}

    // Fallback function to handle ETH sent to the contract
    fallback() external payable {}
}
