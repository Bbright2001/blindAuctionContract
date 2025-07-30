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