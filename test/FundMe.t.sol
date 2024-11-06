// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() public {
        // I -> FundMeTest -> FundMe
        fundMe = new FundMe();
    }

    function test_MinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 1e18);
    }

    function test_WhoIsTheOwner() public view {
        // console.log("[sender] call the test contract", msg.sender);
        // console.log("[this test contract] deploy fundMe", address(this));
        // console.log("[owner] of fundMe contract", fundMe.i_owner());
        assertEq(fundMe.i_owner(), address(this));
    }
}
