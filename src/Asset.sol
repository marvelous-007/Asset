// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract SellNFT is IERC721Receiver {

    IERC721 public nft; // the NFT contract
    address public seller; // the seller of the NFT
    uint256 public price_; // the price of the NFT in USDT
    AggregatorV3Interface internal priceFeed; // Chainlink price feed contract
    bool public purchased = false; // whether the NFT has been purchased or not


    event NFTPurchased(address buyer);

    constructor(address _nft, uint256 _price) {
        nft = IERC721(_nft);
        seller = msg.sender;
        price_ = _price;
        priceFeed = AggregatorV3Interface(0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);

    }

    function buyNFT() public payable {
        require(!purchased, "NFT has already been purchased");
        require(msg.value == convertToETH(price_), "Incorrect payment amount");
        purchased = true;
        nft.safeTransferFrom(address(this), msg.sender, 1); // assuming the NFT ID is 1
        emit NFTPurchased(msg.sender);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function convertToETH(uint256 _usdtAmount) internal view returns (uint256) {
        uint256 ethPrice = getEthPrice();
        require(ethPrice > 0, "ETH price not available");
        return _usdtAmount * (1e18) / (ethPrice);
    }

    function getEthPrice() internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Price not available");
        return uint256(price);
    }

    function withdraw() public {
        require(msg.sender == seller, "Only seller can withdraw funds");
        require(purchased, "NFT has not been purchased yet");
        (bool success, ) = seller.call{value: address(this).balance}("");
        require(success, "Transfer failed!!!");
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == seller, "Only seller can set price");
        price_ = _price;
    } 

    function cancelSale() public {
        require(msg.sender == seller, "Only seller can cancel sale!");
        require(!purchased, "NFT has already been purchased");
        purchased = true;
        nft.safeTransferFrom(address(this), seller, 1);
    }

    function getNFT() public view returns(address, uint256) {
        return (address(nft), 1);
    }

    function getPrice() public view returns (uint256) {
        return price_;
    }

}