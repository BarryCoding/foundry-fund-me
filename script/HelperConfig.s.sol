// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {V3Aggregator} from "../test/mock/V3Aggregator.sol";

contract HelperConfig is Script {
    uint8 constant MOCK_DECIMALS = 8;
    int256 constant MOCK_INITIAL_PRICE = 2000e8;

    struct NetwrokConfig {
        address priceFeed;
    }

    NetwrokConfig public activeNetworkConfig;

    constructor() {
        // https://chainlist.org/chain/11155111
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetwrokConfig memory) {
        return
            NetwrokConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getAnvilEthConfig() public returns (NetwrokConfig memory) {
        vm.startBroadcast();
        V3Aggregator MockAggregator = new V3Aggregator(
            MOCK_DECIMALS,
            MOCK_INITIAL_PRICE
        );
        vm.stopBroadcast();
        return NetwrokConfig({priceFeed: address(MockAggregator)});
    }
}
