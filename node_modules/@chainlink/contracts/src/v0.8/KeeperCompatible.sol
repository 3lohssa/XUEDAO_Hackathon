// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
    function checkUpkeep(
        bytes calldata checkData
    ) external view returns (bool upkeepNeeded, bytes memory performData);
    function performUpkeep(bytes calldata performData) external;
}

contract KeeperBase {
    error OnlySimulatedBackend();

    function preventExecution() internal view {
        if (tx.origin != address(0)) {
            revert OnlySimulatedBackend();
        }
    }

    modifier cannotExecute() {
        preventExecution();
        _;
    }
}

abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}
