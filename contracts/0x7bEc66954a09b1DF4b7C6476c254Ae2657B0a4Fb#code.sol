// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/aave/v3/IPoolV3.sol";

interface IStrategyAaveV3 {
    function getLeverageAmount(bool _isDepositOrWithdraw, uint256 _depositOrWithdraw) external view returns (bool, uint256);
    function getAvailableBorrowsWSTETH() external view returns (uint256);
    function safeProtocolRatio() external view returns (uint256);
    function leverage(
        uint256 _deposit,
        uint256 _leverageAmount,
        bytes calldata _swapData,
        uint256 _swapGetMin,
        uint256 _flashloanSelector
    ) external;
    function enterProtocol() external;
}

/**
 * @title AaveV3FlashLeverageHelpers
 * @author Naturelab
 * @dev This contract is used to allow leverage on aaveV3 without simulation.
 */
contract AaveV3FlashLeverageHelper is Ownable {
    // The address of the strategy contract
    address public strategy;

    address public constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    address public constant EZETH = 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110;

    // The address of the AAVE v3 aToken for ezETH
    address internal constant A_EZETH_AAVEV3 = 0x74e5664394998f13B07aF42446380ACef637969f;

    // The address of the AAVE v3 variable debt token for wstETH
    address internal constant D_WSTETH_AAVEV3 = 0xE439edd2625772AA635B437C099C607B6eb7d35f;

    IPoolV3 internal constant POOL_AAVEV3 = IPoolV3(0x4e033931ad43597d96D6bcc25c280717730B58B1);

    uint256 constant fastWstETHToEzETHRate = 116;

    constructor(address _admin, address _strategy) Ownable(_admin) {
        // leverage by stake
        strategy = _strategy;
    }

    function setStrategy(address _strategy) external onlyOwner {
        strategy = _strategy;
    }

    function getLeverageableAmount() public view returns (uint256, uint256) {
        return (getSupplyCap(), getBorrowCap());
    }

    function isLeverageRequired() public view returns (bool) {
        // Get Contract's balance of EZETH
        uint256 balance_ = IERC20(EZETH).balanceOf(strategy);
        // Get the caps
        (uint256 supplyCap_, uint256 borrowCap_) = getLeverageableAmount();

        return balance_ > 1e18 && supplyCap_ > 1e18 && borrowCap_ > 1e18;
    }

    function getSupplyCap() internal view returns (uint256) {
        uint256 totalSupplied_ = IERC20(A_EZETH_AAVEV3).totalSupply();
        uint256 configMap_ = POOL_AAVEV3.getReserveData(EZETH).configuration.data;
        // Cut out bit 116-151 to get supply cap
        return ((configMap_ >> 116) & 0x7FFFF) * 1e18 - totalSupplied_;
    }

    function getBorrowCap() internal view returns (uint256) {
        uint256 totalBorrowed_ = IERC20(D_WSTETH_AAVEV3).totalSupply();
        uint256 configMap_ = POOL_AAVEV3.getReserveData(WSTETH).configuration.data;
        // Cut out bit 80-151 to get borrow cap
        return ((configMap_ >> 80) & 0x7FFFF) * 1e18 - totalBorrowed_;
    }

    function ezETHToWstETH(uint256 ezETHAmount) public view returns (uint256) {
        return ezETHAmount * 100 / fastWstETHToEzETHRate;
    }

    function getLeverageableAmount(uint256 depositAmount) public view returns (uint256) {
        uint256 safeRatio_ = IStrategyAaveV3(strategy).safeProtocolRatio();
        return (depositAmount * 1e18 / (1e18 - safeRatio_) - depositAmount) * 100 / fastWstETHToEzETHRate;
    }

    /**
     * @dev Allows the owner to leverage by stake, to the allowed maximum for contract.
     */
    function leverageMaxium() external onlyOwner {
        IStrategyAaveV3(strategy).enterProtocol();
        // First, get current total supply of EZETH
        (uint256 supplyCap_, uint256 borrowCap_) = getLeverageableAmount();
        // Get the current balance of the strategy
        uint256 balance_ = IERC20(EZETH).balanceOf(strategy);
        // If the remaining supply is less than the balance, set balance to remaining supply
        if (supplyCap_ < balance_) {
            balance_ = supplyCap_;
        }
        uint256 leverageableAmount_ = getLeverageableAmount(balance_); // Hold 5% for success rate
        leverageableAmount_ = leverageableAmount_ * 95 / 100;
        if (leverageableAmount_ > supplyCap_ - balance_) {
            leverageableAmount_ = supplyCap_ - balance_;
        }
        uint256 leveragable_ = getLeverageableAmount(balance_);
        if (leveragable_ > borrowCap_) {
            leveragable_ = borrowCap_;
        }
        if (leveragable_ > ezETHToWstETH(supplyCap_ - balance_)) {
            leveragable_ = ezETHToWstETH(supplyCap_ - balance_);
        }
        if (leveragable_ < 1e18) { 
            IStrategyAaveV3(strategy).leverage(balance_, 0, "", 0, 0);
            return;
        }
        IStrategyAaveV3(strategy).leverage(balance_, leveragable_ - 1e10, "", 0, 0);
    }
}