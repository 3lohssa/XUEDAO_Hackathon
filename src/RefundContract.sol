// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RefundContract {
    address public refundAddress;

    event Refund(address indexed from, address indexed to, uint256 amount);
    event RefundFailed(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    constructor(address _refundAddress) {
        refundAddress = _refundAddress;
    }

    receive() external payable {
        require(msg.value > 0, "No ether received");

        // 將收到的以太幣返還給發送者
        (bool success, ) = msg.sender.call{value: msg.value}("");
        if (success) {
            emit Refund(address(this), msg.sender, msg.value);
        } else {
            emit RefundFailed(address(this), msg.sender, msg.value);
        }
    }
}
