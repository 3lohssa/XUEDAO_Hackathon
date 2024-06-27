// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {PriceGuessingGame} from "../src/PriceGuessingGame.sol";

contract DeployPriceGuessingGame is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DEPLOY_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 使用 BNB Testnet 上的 Chainlink ETH/USD 价格预言机地址
        address priceFeed = 0x143db3CEEfbdfe5631aDD3E50f7614B6ba708BA7;
        PriceGuessingGame contractInstance = new PriceGuessingGame(
            0xE2C2fAe0Fb6085049c5AE383e8C32485de64Df41, // 新的退款地址
            120, // 86400 seconds = 1 day
            priceFeed
        );

        vm.stopBroadcast();
    }
}
