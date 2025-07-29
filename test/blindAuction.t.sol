// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {Test, console} from "../forge-std/Test.sol";
import {blindAuction} from "../src/blindAuction.sol";

contract testBlindAuction is Test {
    blindAuction public auction;
    address payable public beneficiary;
    address public bidder1 = address(0x2);
    address public bidder2 = address(0x3);

    function setUp() public {
        vm.warp(100);

        vm.prank(beneficiary);
        beneficiary = payable(address(0x1));
        vm.deal(beneficiary, 10 ether);
        auction = new blindAuction(beneficiary);
    }

    function testBid() public {
        vm.deal(bidder1, 10 ether);
        vm.prank(bidder1);
        uint value = 7 ether;
        bool fake = false;
        bytes32 secret = keccak256(abi.encodePacked("mySecret"));
        bytes32 blindedBid = keccak256(abi.encodePacked(value, fake, secret));

        auction.bid{value: 5 ether}(blindedBid);
        // Access the value field from the tuple (assuming bids returns array of (uint256 value, bytes32 blindedBid))
        (uint256 deposit, ) = auction.bids(bidder1, 0);
        assertEq(deposit, 5 ether, "Bid value should be 5 ether");
    }

    function testBidFail() public {
        vm.deal(bidder2, 10 ether);
        vm.prank(bidder2);
        uint value = 7 ether;
        bool fake = false;
        bytes32 secret = keccak256(abi.encodePacked("mySecret"));
        bytes32 blindedBid = keccak256(abi.encodePacked(value, fake, secret));

        vm.expectRevert(blindAuction.invalidDeposit.selector);
        auction.bid{value: 3 ether}(blindedBid);
    }

    function testRevealBid() public {
        vm.deal(bidder1, 15 ether);
        vm.prank(bidder1);

        uint value = 7 ether;
        bool fake = false;
        bytes32 secret = keccak256(abi.encodePacked("mySecret"));
        bytes32 blindedBId = keccak256(abi.encodePacked(value, fake, secret));

        auction.bid{value: 5 ether}(blindedBId);

        vm.warp(auction.auctionEndTime() + 1);

        uint256[] memory values = new uint256[](1);
        bool[] memory fakes = new bool[](1);
        bytes32[] memory secrets = new bytes32[](1);

        values[0] = value;
        fakes[0] = fake;
        secrets[0] = secret;

        vm.prank(bidder1);
        auction.revealBid(values, fakes, secrets);

        assertEq(auction.highestBid(), 7 ether);
    }

    function test_expectRevertRevealFunctionTooEarly() public {
        vm.deal(bidder1, 15 ether);
        vm.prank(bidder1);

        uint256 value = 7 ether;
        bool fake = false;
        bytes32 secret = keccak256(abi.encodePacked("mySecret"));

        bytes32 blindedBid = keccak256(abi.encodePacked(value, fake, secret));

        auction.bid{value: 5 ether}(blindedBid);

        uint256[] memory values = new uint256[](1);
        bool[] memory fakes = new bool[](1);
        bytes32[] memory secrets = new bytes32[](1);

        values[0] = value;
        fakes[0] = fake;
        secrets[0] = secret;

        vm.warp(5 hours);
        vm.expectRevert(blindAuction.tooEarly.selector);
        auction.revealBid(values, fakes, secrets);
    }

    function test_expectRevertRevealFUntionTooLate() public {
        vm.deal(bidder2, 20 ether);
        vm.prank(bidder2);

        uint256 value = 10 ether;
        bool fake = false;
        bytes32 secret = keccak256(abi.encodePacked("mySecret"));

        bytes32 blindedBid = keccak256(abi.encodePacked(value, fake, secret));

        auction.bid{value: 10 ether}(blindedBid);

        uint256[] memory values = new uint256[](1);
        bool[] memory fakes = new bool[](1);
        bytes32[] memory secrets = new bytes32[](1);

        values[0] = value;
        fakes[0] = fake;
        secrets[0] = secret;

        vm.warp(2 days);
        vm.expectRevert(blindAuction.tooLate.selector);
        auction.revealBid(values, fakes, secrets);
    }
}
