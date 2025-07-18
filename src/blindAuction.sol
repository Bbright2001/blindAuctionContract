// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract blindAuction is Ownable{
    struct Bid{
        uint256 deposit;
        bytes32 blindedBid;
    }

    uint256 public constant BIDDING_DURATION = 10 hours;
    uint256 public revealTime;
    uint256 public auctionEndTime;
    uint256 public revealEndTime;
    uint256 public highestBid;
    uint256 public highestBidder;
    bool public ended;
    address payable public beneficiary;
    uint256 public minimumDeposit;

    mapping (address => Bid[]) bids;
    mapping (address => uint256) public revealedBid;
    mapping (address => uint256) public pendingReturns;

    event bidSubmitted(address bidder);
    event auctionHasEnded(address winner, uint256 highestBid);

    error tooEarly();
    error tooLate();
    error invalidDeposit();

    constructor(
        address payable  _beneficiary
        )
    Ownable(_beneficiary){
        _transferOwnership(_beneficiary);

        auctionEndTime = block.timestamp + BIDDING_DURATION;
        revealEndTime =  auctionEndTime + revealTime;
    }

    function bid(bytes32 _blindedBid) external payable { 
            if(!(block.timestamp < auctionEndTime)) revert tooEarly();
            if( msg.value <= 5 ether) revert invalidDeposit();

            bids[msg.sender].push(Bid({
                blindedBid: _blindedBid,
                deposit: msg.value
            }));
    }



} 