// Get Funds from Users
//Withdraw Funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConvertor} from "./PriceConvertor.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConvertor for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // minimum amt of USD to be sent = $5

    address[] private s_funders; // to store address of funders

    mapping(address s_funders => uint256 amountFunded)
        private s_AddressToAmountFunded;

    AggregatorV3Interface private s_PriceFeed;

    address private immutable i_OWNER;

    constructor(address pricefeed) {
        s_PriceFeed = AggregatorV3Interface(pricefeed);
        i_OWNER = msg.sender;
    }

    function Fund() public payable {
        require(
            msg.value.getConversionRate(s_PriceFeed) >= MINIMUM_USD,
            "NOT ENOUGH ETH SENT"
        );

        s_funders.push(msg.sender);
        s_AddressToAmountFunded[msg.sender] =
            s_AddressToAmountFunded[msg.sender] +
            msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_PriceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "MUST BE OWNER");
        if (msg.sender != i_OWNER) revert FundMe__NotOwner();
        _;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderindex = 0;
            funderindex < fundersLength;
            funderindex++
        ) {
            address funder = s_funders[funderindex];
            s_AddressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    function Withdraw() public onlyOwner {
        for (
            uint256 funderindex = 0;
            funderindex < s_funders.length;
            funderindex++
        ) {
            address funder = s_funders[funderindex];
            s_AddressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0); // reset the funders array

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    receive() external payable {
        Fund();
    }

    fallback() external payable {
        Fund();
    }

    // Getter Functions

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_AddressToAmountFunded[fundingAddress];
    }

    function getOwner() external view returns (address) {
        return i_OWNER;
    }
}
