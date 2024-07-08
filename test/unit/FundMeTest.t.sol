// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

import {PriceConvertor} from "../../src/PriceConvertor.sol";

contract FundMeTest is Test {
    FundMe new_FundMe_contract;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // us -> FundMeTest -> FundMe
        // fundme = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe new_deployFundMe_contract = new DeployFundMe();
        new_FundMe_contract = new_deployFundMe_contract.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(new_FundMe_contract.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(new_FundMe_contract.getOwner());
        console.log(address(this));
        console.log(msg.sender);
        assertEq(new_FundMe_contract.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = new_FundMe_contract.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // the next line should revert
        // assert (this txn fails/reverts)
        new_FundMe_contract.Fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER); // The next Txn will be sent by USER

        new_FundMe_contract.Fund{value: SEND_VALUE}();

        uint256 amountFunded = new_FundMe_contract.getAddressToAmountFunded(
            USER
        );
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundsToArrayOfFunders() public {
        vm.prank(USER);

        new_FundMe_contract.Fund{value: SEND_VALUE}();
        address funder = new_FundMe_contract.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        new_FundMe_contract.Fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWIthdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        new_FundMe_contract.Withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //  Arrange
        uint256 StartingOwnerBalance = new_FundMe_contract.getOwner().balance;
        uint256 StartingFundMeBalance = address(new_FundMe_contract).balance;

        // Act
        vm.prank(new_FundMe_contract.getOwner());
        new_FundMe_contract.Withdraw();

        // Assert
        uint256 EndingOwnerBalance = new_FundMe_contract.getOwner().balance;
        uint256 EndingFundMeBalance = address(new_FundMe_contract).balance;

        assertEq(EndingFundMeBalance, 0);
        assertEq(
            EndingOwnerBalance,
            StartingOwnerBalance + StartingFundMeBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm prank new address
            // vm deal new address

            hoax(address(i), SEND_VALUE);

            console.log(address(i));
            console.log(
                new_FundMe_contract.getAddressToAmountFunded(address(i))
            );
            //deal(address(i), SEND_VALUE);
            //assertEq(address(i).balance, SEND_VALUE);

            new_FundMe_contract.Fund{value: SEND_VALUE};
            // fund the fundMe
        }

        uint256 StartingOwnerBalance = new_FundMe_contract.getOwner().balance;
        uint256 StartingFundMeBalance = address(new_FundMe_contract).balance;

        // Act
        vm.prank(new_FundMe_contract.getOwner());
        new_FundMe_contract.Withdraw();
        vm.stopPrank();

        // Assert
        assert(address(new_FundMe_contract).balance == 0);
        assert(
            StartingFundMeBalance + StartingOwnerBalance ==
                new_FundMe_contract.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            new_FundMe_contract.Fund{value: SEND_VALUE};

            console.log(address(i));
            console.log(
                new_FundMe_contract.getAddressToAmountFunded(address(i))
            );
        }

        uint256 StartingOwnerBalance = new_FundMe_contract.getOwner().balance;
        uint256 StartingFundMeBalance = address(new_FundMe_contract).balance;

        // Act
        vm.startPrank(new_FundMe_contract.getOwner());
        new_FundMe_contract.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(new_FundMe_contract).balance == 0);
        assert(
            StartingFundMeBalance + StartingOwnerBalance ==
                new_FundMe_contract.getOwner().balance
        );
    }
}
