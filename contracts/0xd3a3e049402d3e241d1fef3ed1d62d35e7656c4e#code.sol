// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PyPouch {
    address public owner;
    IERC20 public pyusdToken;
    IERC20 public aPYUSD;  // aToken (e.g., aPYUSD) to track interest accrual
    IPool public aavePool;

    struct UserInfo {
        uint256 netDeposits;  // Total amount the user has deposited (without interest)
        uint256 aTokenBalanceAtLastCheckpoint;  // Balance of aPYUSD at the last checkpoint
    }

    mapping(address => UserInfo) public users;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, address indexed receiver, uint256 amount);
    event YieldEarned(address indexed user, uint256 yield);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Initialize the contract
    function initialize(address _owner, address _pyusdToken, address _aPYUSD, address _aavePool) external {
        require(owner == address(0), "Already initialized");
        owner = _owner;
        pyusdToken = IERC20(_pyusdToken);
        aPYUSD = IERC20(_aPYUSD);
        aavePool = IPool(_aavePool);
    }

    // Deposit PYUSD into Aave through PyPouch contract
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");

        // Transfer PYUSD from user to this contract
        pyusdToken.transferFrom(msg.sender, address(this), amount);

        // Approve Aave pool to spend PYUSD
        pyusdToken.approve(address(aavePool), amount);

        // Deposit PYUSD into Aave pool
        aavePool.supply(address(pyusdToken), amount, address(this), 0);

        // Checkpoint and update balances
        _checkpointYield(msg.sender, 0, amount);
        users[msg.sender].netDeposits += amount;
        users[msg.sender].aTokenBalanceAtLastCheckpoint = aPYUSD.balanceOf(address(this));

        emit Deposit(msg.sender, amount);
    }

    // Withdraw PYUSD from Aave and checkpoint yield
    // Allows specifying a receiver address for withdrawal
    function withdraw(uint256 amount, address receiver) external {
        require(amount > 0 && amount <= users[msg.sender].netDeposits, "Invalid withdraw amount");
        require(receiver != address(0), "Invalid receiver address");

        // Withdraw PYUSD from Aave pool
        aavePool.withdraw(address(pyusdToken), amount, address(this));

        // Transfer PYUSD to the receiver
        pyusdToken.transfer(receiver, amount);

        // Checkpoint and update balances
        _checkpointYield(msg.sender, amount, 0);
        users[msg.sender].netDeposits -= amount;
        users[msg.sender].aTokenBalanceAtLastCheckpoint = aPYUSD.balanceOf(address(this));

        emit Withdraw(msg.sender, receiver, amount);
    }

    // Checkpoint yield by comparing aPYUSD balance with the user's net deposits
    function _checkpointYield(address user, uint256 withdrawnAmount, uint256 depositedAmount) internal {
        UserInfo storage userInfo = users[user];

        // Get the current aPYUSD balance in the contract (accrued interest included)
        uint256 currentATokenBalance = aPYUSD.balanceOf(address(this));
        if (depositedAmount > 0) {
            // Get the balance before the deposit was made
            currentATokenBalance -= depositedAmount;
        }
        
        // Calculate interest accrued since the last checkpoint
        if (currentATokenBalance + withdrawnAmount > userInfo.aTokenBalanceAtLastCheckpoint) {
            uint256 yieldEarned = currentATokenBalance + withdrawnAmount - userInfo.aTokenBalanceAtLastCheckpoint;
            emit YieldEarned(user, yieldEarned);
        }

        // Update the checkpoint balance
        userInfo.aTokenBalanceAtLastCheckpoint = currentATokenBalance;
    }

    // Get user's current net deposit balance in PyPouch
    function getNetDeposits(address user) external view returns (uint256) {
        return users[user].netDeposits;
    }

    // Get aPYUSD balance in PyPouch (includes interest accrued)
    function getAPYUSDBalance() external view returns (uint256) {
        return aPYUSD.balanceOf(address(this));
    }
}