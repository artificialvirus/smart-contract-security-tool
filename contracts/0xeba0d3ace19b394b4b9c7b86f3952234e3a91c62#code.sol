/**
 *Submitted for verification at Etherscan.io on 2024-10-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTs {
    string public name = "Claudius";
    string public symbol = "$CLAUDIUS";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public treasury;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(address _treasury) {
        treasury = _treasury;
    }

    modifier ClauNFTsPositionManage() {
        require(msg.sender == treasury, "Not authorized");
        _;
    }

    function mint(address account, uint256 amount) external ClauNFTsPositionManage {
        totalSupply += amount;
        balanceOf[account] += amount;
    }

    function burn(address account, uint256 amount) external ClauNFTsPositionManage {
        totalSupply -= amount;
        balanceOf[account] -= amount;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        return true;
    }
}