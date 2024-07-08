// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "script/Interactions.s.sol";
import {WithdrawFundMe} from "script/Interactions.s.sol";

//import {PriceConvertor} from "../src/PriceConvertor.sol";

contract FundMeTestIntegration is Test {
    FundMe new_FundMe_contract;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        new_FundMe_contract = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.deal(USER, 1e18);
        fundFundMe.fundFundMe(address(new_FundMe_contract));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(new_FundMe_contract));

        assert(address(new_FundMe_contract).balance == 0);
    }
}
