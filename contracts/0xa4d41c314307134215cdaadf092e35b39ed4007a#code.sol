/**
 *Submitted for verification at Etherscan.io on 2024-10-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ClaudiusTreasury {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }

    function allocateFunds(address recipient, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient treasury balance");
        payable(recipient).transfer(amount);
    }

    function getTreasuryBalance() external view returns (uint256) {
        return address(this).balance;
    }
}