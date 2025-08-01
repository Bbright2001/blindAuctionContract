//function reveal Bid 
takes in value, fake, secret ... has the function argument

The auction end time awas declared in the constructor because the bidding starts when the contract was deployed

the bids mapping is mapping an address to an array... keeping track of every bid that a bidder bidded stored it in an array.... so a bidder can place multiple bids which are stored in the array.

what does this auction contract do????
# allows users to bid
    - keeps tracks of users bids 
///bid function

# allows users to reveal there inital bids
    
# allows users to withdraw their bid if they aren't the highest bidder

>>> users are only allowed to withdraw their bids when
 - auction has ended
 - when the winner has been declared.


>>>  THe auction has ended if and only id
- all bids has been revealed 
- if the highest bidder has been declared
## what happens when the auction has ended
    - the beneficiary declares the auction closed
    - the highest bid is transfer to the beneficiairy
    - declare ended = true

>>> Difficulty Encountered
 - panic: arithmetic underflow or overflow (0x11)
    Causes: I was trying to subtract a smaller integer from  a bigger one
     i.e refun -= value[i];
     solution: I solved it by add a check to make sure that refund was greater or equal to value[i];
 -  error: valueLengtheMismatch
        CAUSE:  I didn't prank the bidder before making the revealed function call so the terminal was reading from address this instead of the  bidder
        SOLUTION: I prank the bidder immediately before i made the reveal function call.
## Breakdown of the reveal function

 - takes in an array of value, fake, secret and stores them in the call data
 - checks: checks if the function is called before the auction duration or after the reveal duration

 - variable length = is the length of bids array of  msg.sender i.e the caller

# Notes: value is the real bid amount
"
 for (uint i = 0; i < length; i++)// loops through the caller bids {
            Bid storage bidToReveal = bids[msg.sender][i];// access the bid at position i.

            bytes32 calculatedHash = keccak256(
                abi.encodePacked(value[i], fake[i], secret[i])
            );// calculates the hash of the bid at position i

            if (
                calculatedHash == bidToReveal.blindedBid &&
                bidToReveal.deposit >= MINIMUM_DEPOSIT
            )//checks if the calculatedHash matches msg.sender hash and if amount deposit is valid  {

                if (!fake[i] && value[i] > highestBid)// if fake is not true and the value at i is greater than the highest bidder {
                    if (highestBidder != address(0)) {
                        pendingReturns[
                            address(uint160(highestBidder))
                        ] += highestBid;// refund the previous highst bidder
                    }

                    highestBid = value[i];// update the highest bid
                    highestBidder = msg.sender;// update the highest bidder
                }

                bids[msg.sender] = revealedBid[msg.sender]; save the bid array in then revealed bid array.
            }
        }
