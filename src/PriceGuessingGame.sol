// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorV3Interface.sol";
import "./KeeperCompatible.sol";

contract PriceGuessingGame is KeeperCompatibleInterface {
    struct Guess {
        address user;
        int256 guessedPrice;
        uint256 timestamp;
    }

    address public refundAddress;
    Guess[] public guesses;
    uint256 public totalAmount;
    uint256 public lastTimestamp;
    uint256 public interval;
    int256 public ethUsdCurrentPrice;

    AggregatorV3Interface internal priceFeed;

    event Deposit(address indexed from, uint256 amount);
    event GuessMade(address indexed user, int256 guessedPrice);
    event WinnerSelected(address indexed winner, uint256 totalAmount);
    event RefundFailed(address indexed from, uint256 amount);
    event PriceUpdated(int256 price);
    event UpkeepPerformed(bool success, uint256 timestamp);

    constructor(address _refundAddress, uint256 _interval, address _priceFeed) {
        refundAddress = _refundAddress;
        totalAmount = 0;
        lastTimestamp = block.timestamp;
        interval = _interval;

        // Initialize Chainlink price feed
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    receive() external payable {
        require(msg.value > 0, "No ether received");

        totalAmount += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function makeGuess(int256 _guessedPrice) public payable {
        require(
            msg.value == 0.001 ether,
            "Minimum guess amount is 0.001 ether"
        );

        guesses.push(
            Guess({
                user: msg.sender,
                guessedPrice: _guessedPrice,
                timestamp: block.timestamp
            })
        );
        totalAmount += msg.value;
        emit GuessMade(msg.sender, _guessedPrice);
    }

    function getLatestPrice() public view returns (int256) {
        (
            uint80 roundID,
            int256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price / 1e8;
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
            guesses.length > 0;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if (
            (block.timestamp - lastTimestamp) > interval && guesses.length > 0
        ) {
            // Update ETH/USD price
            ethUsdCurrentPrice = getLatestPrice();

            selectWinner();
            lastTimestamp = block.timestamp;
            emit UpkeepPerformed(true, block.timestamp);
        } else {
            emit UpkeepPerformed(false, block.timestamp);
        }
    }

    function selectWinner() private {
        require(guesses.length > 0, "No participants");

        address winner = address(0);
        int256 closestDifference = type(int256).max;
        uint256 earliestTimestamp = type(uint256).max;

        for (uint i = 0; i < guesses.length; i++) {
            int256 difference = guesses[i].guessedPrice > ethUsdCurrentPrice
                ? guesses[i].guessedPrice - ethUsdCurrentPrice
                : ethUsdCurrentPrice - guesses[i].guessedPrice;

            if (
                difference < closestDifference ||
                (difference == closestDifference &&
                    guesses[i].timestamp < earliestTimestamp)
            ) {
                closestDifference = difference;
                earliestTimestamp = guesses[i].timestamp;
                winner = guesses[i].user;
            }
        }

        require(winner != address(0), "No winner selected");
        uint256 totalAmountToSend = totalAmount; // 记录当前奖池金额
        totalAmount = 0; // 重置奖池
        (bool success, ) = winner.call{value: totalAmountToSend, gas: 50000}(
            ""
        );
        if (success) {
            emit WinnerSelected(winner, totalAmountToSend);
        } else {
            emit RefundFailed(winner, totalAmountToSend);
        }

        delete guesses; // 清空参与者列表
    }

    function withdraw() external {
        require(
            msg.sender == refundAddress,
            "Only the refund address can withdraw"
        );
        payable(refundAddress).transfer(address(this).balance);
    }
}
