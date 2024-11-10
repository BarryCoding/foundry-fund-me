// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address userAlice = makeAddr("Alice");
    uint256 constant SEND_VALUE = 0.1 ether; // 1e17
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        vm.deal(userAlice, STARTING_BALANCE);
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
        assertEq(fundMe.getOwner(), msg.sender);
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

    function test_FundUpdatesFundDataStructure() public {
        vm.prank(userAlice);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getAddressToAmountFunded(userAlice), SEND_VALUE);
    }

    function test_AddsFunderToArrayOfFunders() public {
        vm.prank(userAlice);
        fundMe.fund{value: SEND_VALUE}();
        assertEq(fundMe.getFunder(0), userAlice);
    }

    function test_OnlyOwnerCanWithdraw() public fundedByAlice {
        vm.expectRevert();
        vm.prank(userAlice);
        fundMe.withdraw();
    }

    modifier fundedByAlice() {
        vm.prank(userAlice);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function test_WithdrawFromOwner() public fundedByAlice {
        // Arrage
        address owner = fundMe.getOwner();
        uint256 ownerBalanceBefore = owner.balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 fundMeBalanceAfter = address(fundMe).balance;
        uint256 ownerBalanceAfter = owner.balance;
        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + fundMeBalanceBefore);
    }

    function test_WithdrawAfterMultipleFunds() public fundedByAlice {
        // Arrange
        uint160 NUMBER_OF_FUNDS = 20;
        // start from 1 as Alice is the first funder
        for (uint160 i = 1; i < NUMBER_OF_FUNDS; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        address owner = fundMe.getOwner();
        uint256 ownerBalanceBefore = owner.balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 fundMeBalanceAfter = address(fundMe).balance;
        uint256 ownerBalanceAfter = owner.balance;
        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + fundMeBalanceBefore);
        assertEq(
            ownerBalanceAfter,
            ownerBalanceBefore + SEND_VALUE * NUMBER_OF_FUNDS
        );
    }

    function test_WithdrawAfterMultipleFundsCheaper() public fundedByAlice {
        // Arrange
        uint160 NUMBER_OF_FUNDS = 20;
        // start from 1 as Alice is the first funder
        for (uint160 i = 1; i < NUMBER_OF_FUNDS; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        address owner = fundMe.getOwner();
        uint256 ownerBalanceBefore = owner.balance;
        uint256 fundMeBalanceBefore = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdrawCheaper();

        // Assert
        uint256 fundMeBalanceAfter = address(fundMe).balance;
        uint256 ownerBalanceAfter = owner.balance;
        assertEq(fundMeBalanceAfter, 0);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + fundMeBalanceBefore);
        assertEq(
            ownerBalanceAfter,
            ownerBalanceBefore + SEND_VALUE * NUMBER_OF_FUNDS
        );
    }
}
