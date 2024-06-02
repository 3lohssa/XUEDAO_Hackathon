// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/TimeBasedRefundContract.sol";

contract DeployTimeBasedRefundContract is Script {
    function run() external {
        address refundAddress = 0xE2C2fAe0Fb6085049c5AE383e8C32485de64Df41;
        uint256 interval = 120; // 设置时间间隔为 3600 秒，即 1 小时

        vm.startBroadcast();

        new TimeBasedRefundContract(refundAddress, interval);

        vm.stopBroadcast();
    }
}
