// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() public {
        fundMe = new FundMe();
    }

    function test_IsMinimumUSDFive() public view {
        console.log("test_IsMinimumUSDFive", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5 * 1e18);
    }
}
