// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Asset.sol";
import "./myNFT/NFT.sol";

contract AssetTest is Test {
    SellNFT asset;
    myNFT nft;

    address marvelous = 0x5E583B6a1686f7Bc09A6bBa66E852A7C80d36F00;
    address lucky = 0x7465518570e5fA2D070B44450467f5D33b4A12ba;
  //  address marvelous = mkaddr("marvelous");

    function setUp() public {
        nft = new myNFT();
        asset = new SellNFT(address(nft), 3.5 ether);
    }

    function test() public {
        vm.startPrank(marvelous);
        nft.mint(address(asset));

       // vm.prank(address(asset));
       // asset.getNFT();
        vm.stopPrank();
    }

    function buyNFT() public {
        test();
       vm.prank(lucky);
       asset.buyNFT();
        asset.getPrice();

    }

    
}
