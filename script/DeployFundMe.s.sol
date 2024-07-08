// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before startBroadcast -> Not a real txn
        HelperConfig new_HelperConfig = new HelperConfig();
        address EthUSD_PriceFeed = new_HelperConfig.Active_NetworkConfig();

        // After startBraodcast -> Real txn
        vm.startBroadcast();
        FundMe new_fundme_contract = new FundMe(EthUSD_PriceFeed);
        vm.stopBroadcast();

        return new_fundme_contract;
    }
}
