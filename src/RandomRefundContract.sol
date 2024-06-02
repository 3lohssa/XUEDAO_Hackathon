// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RandomRefundContract {
    address public refundAddress;
    address[] public participants;
    uint256 public totalAmount;

    event Deposit(address indexed from, uint256 amount);
    event WinnerSelected(address indexed winner, uint256 totalAmount);
    event RefundFailed(address indexed from, uint256 amount);

    constructor(address _refundAddress) {
        refundAddress = _refundAddress;
        totalAmount = 0;
    }

    receive() external payable {
        require(msg.value > 0, "No ether received");

        // 記錄參與者和總金額
        participants.push(msg.sender);
        totalAmount += msg.value;
        emit Deposit(msg.sender, msg.value);

        // 當有兩名參與者時選擇贏家
        if (participants.length == 2) {
            selectWinner();
        }
    }

    function selectWinner() private {
        // 使用區塊哈希作為隨機數種子
        uint256 randomIndex = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty))
        ) % participants.length;
        address winner = participants[randomIndex];

        // 將總金額轉給贏家
        (bool success, ) = winner.call{value: totalAmount}("");
        if (success) {
            emit WinnerSelected(winner, totalAmount);
        } else {
            emit RefundFailed(winner, totalAmount);
        }

        // 重置參與者和總金額
        delete participants;
        totalAmount = 0;
    }
}
