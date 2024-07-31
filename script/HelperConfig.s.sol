// 1. Deploy mocks when we are on our local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD
// Mainnet ETH/USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local chain like anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network

    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    Network_Config public Active_NetworkConfig;

    struct Network_Config {
        address priceFeed; // ETH/USD  price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            Active_NetworkConfig = getSepoliaETH_Config();
        } else if (block.chainid == 1) {
            Active_NetworkConfig = getMainnetETH_Config();
        } else {
            Active_NetworkConfig = get0rCreate_AnvilETH_Config();
        }
    }

    function getSepoliaETH_Config()
        public
        pure
        returns (Network_Config memory)
    {
        // price feed address
        Network_Config memory Sepolia_Config = Network_Config({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return Sepolia_Config;
    }

    function getMainnetETH_Config()
        public
        pure
        returns (Network_Config memory)
    {
        // price feed address
        Network_Config memory Mainnet_Config = Network_Config({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return Mainnet_Config;
    }

    function get0rCreate_AnvilETH_Config()
        public
        returns (Network_Config memory)
    {
        // price feed address
        if (Active_NetworkConfig.priceFeed != address(0)) {
            return Active_NetworkConfig;
        }

        // 1. Deploy the Mocks
        // 2. Return the Mock Address

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            ETH_DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        Network_Config memory Anvil_Config = Network_Config({
            priceFeed: address(mockPriceFeed)
        });
        return Anvil_Config;
    }
}
