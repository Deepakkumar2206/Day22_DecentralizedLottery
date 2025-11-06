// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "chainlink-brownie-contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "chainlink-brownie-contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";


contract FairChainLottery is VRFConsumerBaseV2 {

    enum LOTTERY_STATE { OPEN, CLOSED, CALCULATING }
    LOTTERY_STATE public lotteryState;

    address payable[] public players;
    address public recentWinner;
    uint256 public entryFee;

    // Chainlink VRF config
    VRFCoordinatorV2Interface COORDINATOR;
    uint64 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;
    uint256 public latestRequestId;

    constructor(
        address vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint256 _entryFee
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        entryFee = _entryFee;
        lotteryState = LOTTERY_STATE.CLOSED;
    }

    function enter() public payable {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        require(msg.value >= entryFee, "Not enough ETH");
        players.push(payable(msg.sender));
    }

    modifier onlyOwner() {
        require(msg.sender == tx.origin, "Only owner");
        _;
    }

    function startLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.CLOSED, "Cannot start");
        lotteryState = LOTTERY_STATE.OPEN;
    }

    function endLottery() external onlyOwner {
        require(lotteryState == LOTTERY_STATE.OPEN, "Lottery not open");
        lotteryState = LOTTERY_STATE.CALCULATING;

        latestRequestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, 
        uint256[] memory randomWords
    ) internal override {
        require(lotteryState == LOTTERY_STATE.CALCULATING, "Not ready");

        uint256 winnerIndex = randomWords[0] % players.length;
        address payable winner = players[winnerIndex];
        recentWinner = winner;

        // reset
        delete players;
        lotteryState = LOTTERY_STATE.CLOSED;

        // send ETH
        (bool sent, ) = winner.call{value: address(this).balance}("");
        require(sent, "ETH Transfer failed");
    }

    function getPlayers() external view returns (address payable[] memory) {
        return players;
    }
}
