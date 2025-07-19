// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract blindAuction is Ownable{
    struct Bid{
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

    mapping (address => Bid[]) public bids;
    mapping (address => Bid[]) public revealedBid;
    mapping (address => uint256) public pendingReturns;

    event bidSubmitted(address bidder);
    event auctionHasEnded(address winner, uint256 highestBid);
    event bidRevealed(address caller, uint256 bid);

    error tooEarly();
    error tooLate();
    error invalidDeposit();
    error lengthMismatch();

    constructor(
        address payable  _beneficiary
        )
    Ownable(_beneficiary){
        _transferOwnership(_beneficiary);

        auctionEndTime = block.timestamp + BIDDING_DURATION;
        revealEndTime =  auctionEndTime + REVEAL_DURATION;
    }

    function bid(bytes32 _blindedBid) external payable { 
            if(!(block.timestamp < auctionEndTime)) revert tooEarly();
            if( msg.value <= MINIMUM_DEPOSIT) revert invalidDeposit();

            bids[msg.sender].push(Bid({
                blindedBid: _blindedBid,
                deposit: msg.value
            }));
    }
    function revealBid(
        uint256[] calldata value,
        bool[] calldata fake,
        bytes32[] calldata secret
    ) external {
        if(block.timestamp < auctionEndTime) revert tooEarly();
        if(block.timestamp > revealEndTime) revert tooLate();

        uint256 length = bids[msg.sender].length;

        if(value.length != length) revert lengthMismatch();
        if(fake.length != length) revert lengthMismatch();
        if(secret.length != length) revert lengthMismatch();

        for (uint i = 0; i < length; i++){
            Bid storage bitToReveal = bids[msg.sender][i];
            bytes32 calculatedHash = keccak256(abi.encodePacked(value[i], fake[i], secret[i]));

            if(calculatedHash == bitToReveal.blindedBid && bitToReveal.deposit >= MINIMUM_DEPOSIT) {

                if(!fake[i] && value[i] > highestBid){
                    if(highestBidder != address(0)){
                        pendingReturns[address(uint160(msg.sender))] += highestBid;
                    }

                    highestBid = value[i];
                    highestBidder = msg.sender;
                }

                 bids[msg.sender] = revealedBid[msg.sender];
            }
            emit bidRevealed(msg.sender, highestBid);
        }
    }


} 