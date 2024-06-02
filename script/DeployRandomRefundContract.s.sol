// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/RandomRefundContract.sol";

contract DeployRandomRefundContract is Script {
    function run() external {
        address refundAddress = 0xE2C2fAe0Fb6085049c5AE383e8C32485de64Df41;

        vm.startBroadcast();

        // 部署合約
        new RandomRefundContract(refundAddress);

        vm.stopBroadcast();
    }
}
