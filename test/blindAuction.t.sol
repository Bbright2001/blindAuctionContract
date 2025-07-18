// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import{Test, console} from "../forge-std/Test.sol";
import {blindAuction}  from "../src/blindAuction.sol";

contract testBlindAuction is Test{
    blindAuction public auction;
     address payable public  beneficiary;
     address public bidder1 = address(0x2);
     address public bidder2 = address(0x3);

     function setUp() public {
        vm.prank(beneficiary);
        auction = new blindAuction( beneficiary);
     }
}