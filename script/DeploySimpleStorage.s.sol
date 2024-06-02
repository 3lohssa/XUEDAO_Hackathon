// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external {
        vm.startBroadcast();

        // 部署合約
        new SimpleStorage();

        vm.stopBroadcast();
    }
}
