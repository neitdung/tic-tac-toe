// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract TicTacToe {
    uint256 private count;
    mapping(uint256 => Match) private matches;

    struct Match {
        uint256 matchId;
        address challenger;
        address accpetor;
        bytes32 hash1;
        uint8 choice2;
        uint256 amount;
        uint blockHeight;
        uint8 status;
    }

    constructor() {
        count = 0;
    }

    function play(bytes32 hash) public payable {
        matches[count] = Match(
            count,
            msg.sender,
            address(0),
            hash,
            0,
            msg.value,
            block.number,
            1
        );
        count++;
    }

    function accept(uint8 choice2, uint256 matchId) public payable {
        require(choice2 <=2 , "INVALID_CHOICE");
        require(msg.value == matches[matchId].amount && matches[matchId].challenger != address(0), "CAN_ACCEPT");
        require(matches[matchId].status == 1, "Match not active");
        matches[matchId].choice2 = choice2;
    }

    function reveal(uint8 choice1, string memory privateKey, uint256 matchId) public payable {
        bytes32 hash1 = keccak256(abi.encodePacked(privateKey, choice1, msg.sender));
        require(choice1 <=2 , "INVALID_CHOICE");
        require(hash1 == matches[matchId].hash1, "HASH_FAILED");
        require(matches[matchId].status == 1, "Match not active");
        matches[matchId].status = 2;
        uint8 choice2 = matches[matchId].choice2;
        if (choice1 == choice2) {
            payable(msg.sender).transfer(matches[matchId].amount);
            payable(matches[matchId].accpetor).transfer(matches[matchId].amount);
        } else if (choice1 > choice2 && choice2 !=0) {
            payable(msg.sender).transfer(matches[matchId].amount * 2);
        } else if (choice1 == 0 && choice2 == 2) {
            payable(msg.sender).transfer(matches[matchId].amount * 2);
        } else {
            payable(matches[matchId].accpetor).transfer(matches[matchId].amount * 2);
        }
    }

    function liquidate(uint256 matchId) public payable {
        require(msg.sender == matches[matchId].accpetor, "NOT_ACCEPTOR");
        require(block.number > matches[matchId].blockHeight + 5, "NOT_ENOUGH_TIME");
        require(matches[matchId].status == 1, "Match not active");
        matches[matchId].status = 2;
        payable(msg.sender).transfer(matches[matchId].amount *2);
    }
}