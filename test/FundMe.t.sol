// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() public {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); // I run deployFundMe, I am the sender
    }

    function test_MinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 1e18);
    }

    function test_WhoIsTheOwner() public view {
        // console.log("[sender] call the test contract", msg.sender);
        // console.log("[this test contract] deploy fundMe", address(this));
        // console.log("[owner] of fundMe contract", fundMe.i_owner());
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Command: `forge test --match-test test_PriceFeedIsFour -vvvv --fork-url $SEPOLIA_RPC_URL`
    function test_PriceFeedIsFour() public view {
        // console.log("priceFeed version:", fundMe.getVersion());
        assertEq(fundMe.getVersion(), 4);
    }

    // Command: forge coverage --fork-url $SEPOLIA_RPC_URL -vvvv

    function test_FundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }
}
