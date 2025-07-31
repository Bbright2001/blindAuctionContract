// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract blindAuction is Ownable {
    struct Bid {
        uint256 deposit;
        bytes32 blindedBid;
    }

    uint256 public constant BIDDING_DURATION = 10 hours;
    uint256 public constant REVEAL_DURATION = 1 hours;
    uint256 public auctionEndTime;
    uint256 public revealEndTime;
    uint256 public highestBid;
    address public highestBidder;
    bool public ended;
    address payable public beneficiary;
    uint256 public constant MINIMUM_DEPOSIT = 4 ether;

    mapping(address => Bid[]) public bids;
    mapping(address => Bid[]) public revealedBid;
    mapping(address => uint256) public pendingReturns;

    event bidSubmitted(address bidder);
    event auctionHasEnded(address winner, uint256 highestBid);
    event bidRevealed(address caller, uint256 bid);

    error tooEarly();
    error tooLate();
    error invalidDeposit();
    error valueLengthMismatch();
    error fakeLengthMismatch();
    error secretLengthMismatch();
    error auctionStillOngoing();

    constructor(address payable _beneficiary) Ownable(_beneficiary) {
        _transferOwnership(_beneficiary);

        auctionEndTime = block.timestamp + BIDDING_DURATION;
        revealEndTime = auctionEndTime + REVEAL_DURATION;
    }

    function bid(bytes32 _blindedBid) external payable {
        if (!(block.timestamp < auctionEndTime)) revert tooEarly();
        if (msg.value <= MINIMUM_DEPOSIT) revert invalidDeposit();

        bids[msg.sender].push(
            Bid({blindedBid: _blindedBid, deposit: msg.value})
        );
    }

    function getBidLength(address _bidder) public view returns (uint256) {
        return bids[_bidder].length;
    }

    function revealBid(
        uint256[] calldata value,
        bool[] calldata fake,
        bytes32[] calldata secret
    ) external {
        if (block.timestamp < auctionEndTime) revert tooEarly();
        if (block.timestamp > revealEndTime) revert tooLate();

        uint256 length = bids[msg.sender].length;

        if (value.length != length) revert valueLengthMismatch();
        if (fake.length != length) revert fakeLengthMismatch();
        if (secret.length != length) revert secretLengthMismatch();

        for (uint i = 0; i < length; i++) {
            Bid storage bidToReveal = bids[msg.sender][i];
            bytes32 calculatedHash = keccak256(
                abi.encodePacked(value[i], fake[i], secret[i])
            );

            if (
                calculatedHash == bidToReveal.blindedBid &&
                bidToReveal.deposit >= MINIMUM_DEPOSIT
            ) {
                if (!fake[i] && value[i] > highestBid) {
                    if (highestBidder != address(0)) {
                        pendingReturns[
                            address(uint160(highestBidder))
                        ] += highestBid;
                    }

                    highestBid = value[i];
                    highestBidder = msg.sender;
                }
                bidToReveal.blindedBid = bytes32(0);
                bids[msg.sender] = revealedBid[msg.sender];
            }
        }
        emit bidRevealed(msg.sender, highestBid);
    }

    function withdraw() external {
        if (block.timestamp < revealEndTime) revert auctionStillOngoing();

        ended = true;
        uint256 amount = pendingReturns[msg.sender];

        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
        }

        (bool success, ) = msg.sender.call{value: amount}("");

        require(success, "Transaction failed");
    }

    function auctionEnd() external onlyOwner {
        if (!ended) revert auctionStillOngoing();

        ended = true;

        (bool success, ) = beneficiary.call{value: highestBid}("");
        require(success, "Transaction failed");
    }
}
