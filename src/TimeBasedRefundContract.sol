// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./KeeperCompatible.sol";

contract TimeBasedRefundContract is KeeperCompatibleInterface {
    address public refundAddress;
    address[] public participants;
    uint256 public totalAmount;
    uint256 public lastTimestamp;
    uint256 public interval;

    event Deposit(address indexed from, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 totalAmount);
    event RefundFailed(address indexed from, uint256 amount);

    constructor(address _refundAddress, uint256 _interval) {
        refundAddress = _refundAddress;
        totalAmount = 0;
        lastTimestamp = block.timestamp;
        interval = _interval;
    }

    receive() external payable {
        require(msg.value > 0, "No ether received");

        participants.push(msg.sender);
        totalAmount += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded =
            (block.timestamp - lastTimestamp) > interval &&
            participants.length > 0;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if (
            (block.timestamp - lastTimestamp) > interval &&
            participants.length > 0
        ) {
            selectWinner();
            lastTimestamp = block.timestamp;
        }
    }

    function selectWinner() private {
        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        ) % participants.length;
        address winner = participants[randomIndex];

        (bool success, ) = winner.call{value: totalAmount}("");
        if (success) {
            emit WinnerSelected(winner, totalAmount);
        } else {
            emit RefundFailed(winner, totalAmount);
        }

        delete participants;
        totalAmount = 0;
    }
}
