// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    uint256 public endTime;
    uint256 public commission;
    uint256 public maxPlayers;
    address payable[] public players;
    uint256 private nonce;

    constructor(uint256 _endTime, uint256 _commission, uint256 _maxPlayers) {
        manager = msg.sender;
        endTime = _endTime;
        commission = _commission;
        maxPlayers = _maxPlayers;
    }

    function enter() public payable {
        require(block.timestamp < endTime, "Lottery has ended");
        require(players.length < maxPlayers, "Max players limit reached");
        require(msg.value > 0, "Value must be greater than 0");
        players.push(payable(msg.sender));
    }

    function drawWinner() public onlyManager {
        require(block.timestamp >= endTime, "Lottery has not ended yet");
        require(players.length > 0, "No players entered");
        
        uint256 index = random() % players.length;
        address payable winner = players[index];
        uint256 prize = address(this).balance - (address(this).balance * commission / 100);
        winner.transfer(prize);
        payable(manager).transfer(address(this).balance);
        players = new address payable[](0);
    }

    function random() private returns (uint256) {
        nonce++;
        return uint256(keccak256(abi.encodePacked(block.timestamp, nonce)));
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setCommission(uint256 _commission) public onlyManager {
        require(_commission < 100, "Commission cannot be greater or equal to 100%");
        commission = _commission;
    }

    function setMaxPlayers(uint256 _maxPlayers) public onlyManager {
        require(_maxPlayers > players.length, "Max players limit cannot be less than current players");
        maxPlayers = _maxPlayers;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }
}
