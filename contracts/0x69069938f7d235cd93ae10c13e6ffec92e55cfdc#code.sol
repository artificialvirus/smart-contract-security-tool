/**
 *Submitted for verification at Etherscan.io on 2024-10-26
*/

//@dev 1,000,000 unique Remillios with unique Attributes

// Sources flattened with hardhat v2.7.0 https://hardhat.org

// File @openzeppelin/contracts/utils/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/[email protected]


// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/token/ERC20/extensions/[email protected]


// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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


// File @openzeppelin/contracts/token/ERC20/[email protected]


// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
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

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
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

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/PepeToken.sol



pragma solidity ^0.8.0;


contract Remillions is Ownable, ERC20 {
    bool public limited;
    uint256 public maxHoldingAmount;
    uint256 public minHoldingAmount;
    address public uniswapV2Pair;
    mapping(address => bool) public blacklists;

    constructor(uint256 _totalSupply) ERC20("Remillions", "1M") {
        _mint(msg.sender, _totalSupply);
    }

    function AddBot(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }

    function set(bool _limited, address _uniswapV2Pair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) override internal virtual {
        require(!blacklists[to] && !blacklists[from], "Blacklisted");

        if (uniswapV2Pair == address(0)) {
            require(from == owner() || to == owner(), "trading is not started");
            return;
        }

        if (limited && from == uniswapV2Pair) {
            require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
        }
    }

    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }

      mapping(uint index => address holder) _holders;
    mapping(address holder => uint index) _holder_index;
    uint public holders_count;

    function get_holders_list(
        uint index,
        uint count
    ) external view returns (uint page_count, address[] memory accounts) {
        if (index >= holders_count) return (0, new address[](0));

        uint end = index + count;
        if (end > holders_count) {
            end = holders_count;
        }
        page_count = end - index;

        accounts = new address[](page_count);
        uint i;
        for (i = index; i < page_count; ++i) {
            accounts[i] = _holders[index + i];
        }
    }

    function add_holder(address value) internal {
        uint index = holders_count++;
        _holders[index] = value;
        _holder_index[value] = index;
    }

    function remove_holder(address value) internal {
        if (holders_count == 0) return;

        uint removingIndex = _holder_index[value];
        if (removingIndex != holders_count - 1) {
            address lastHolder = _holders[holders_count - 1];
            _holders[removingIndex] = lastHolder;
            _holder_index[lastHolder] = removingIndex;
        }

        --holders_count;
        delete _holder_index[value];
        delete _holders[holders_count];
    }

     uint constant MAX_GENS_START = 1000;
    uint public constant GEN_MIN = 1;
    uint public constant gen_max = MAX_GENS_START;
    uint public gen = MAX_GENS_START;
    uint public constant max_breed = 1000;
    mapping(address owner => uint) public counts;
    uint public breed_total_count;
    uint breed_id;


 



    function _transfer_breed_from_to_by_index(
        address account,
        uint index,
        address to
    ) private {
        string memory breed = "";
        
    }

    function transfer_breed_from_to_by_index(uint index, address to) external {
        require(index < counts[msg.sender], "incorrect index");
        _transfer_breed_from_to_by_index(msg.sender, index, to);
    }

    function gen_mode(uint value) private returns (uint) {
        value = (value * gen) / gen_max;
        if (value == 0) value = 1;
        if (gen > GEN_MIN) --gen;
        return value;
    }

    function buy(
        address to,
        uint256 amount
    ) internal    {
        uint last_balance = balanceOf(to);
        uint balance = last_balance + amount;
        uint count = balance /
            (10 ** decimals()) -
            last_balance /
            (10 ** decimals());
        uint i;
        for (i = 0; i < count; ++i) {
            string memory breed = "Breed(++breed_id, gen_mode(max_breed))";
            
        }
      
    }

    function sell(
        address from,
        uint256 amount
    ) internal {
        uint last_balance = balanceOf(from);
        uint balance = last_balance - amount;
        uint count = last_balance /
            (10 ** decimals()) -
            balance /
            (10 ** decimals());
        uint i;
        uint owner_count = counts[from];
        for (i = 0; i < count; ++i) {
            if (gen < gen_max) ++gen;
            if (owner_count > 0)
                (from, --owner_count);
        }
        
    }

    function transfer_internal(
        address from,
        address to,
        uint256 amount
    ) internal  {
        uint last_balance_from = balanceOf(from);
        uint balance_from = last_balance_from - amount;
        uint last_balance_to = balanceOf(to);
        uint balance_to = last_balance_to + amount;
      
        uint count_from = last_balance_from /
            (10 ** decimals()) -
            balance_from /
            (10 ** decimals());
        uint count_to = balance_to /
            (10 ** decimals()) -
            last_balance_to /
            (10 ** decimals());
        // calculate transfer count
        uint transfer_count = count_from;

        if (transfer_count > count_to) transfer_count = count_to;
        // transfer
        uint i;
        uint owner_count = counts[from];
        for (i = 0; i < transfer_count; ++i) {
            if (owner_count == 0) break;
            uint from_index = --owner_count;
       
        
        }
        uint transfered = i;

        // remove from
        for (i = transfer_count; i < count_from; ++i) {
            uint from_index = --owner_count;
            
        }

        // generate to
        for (i = transfered; i < count_to; ++i) {
          
          
        }

    }


    function get_svg_acc_index(
        address account,
        uint index
    ) external view returns (string memory) {
        
    }

    function get_account_breeds(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
   
        uint end = index + count;
        if (end > account_count) {
            end = account_count;
        }
        page_count = end - index;

    
        uint i;
        for (i = 0; i < page_count; ++i) {
    
        }
    }

    function get_account_items(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
   

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
        }
        page_count = end - index;

      
        uint i;
        for (i = 0; i < page_count; ++i) {
     
        }
    }

    function get_account_svgs(
        address account,
        uint index,
        uint count
    ) external view returns (uint page_count, string[] memory accounts) {
        uint account_count = counts[account];
        if (index >= account_count) return (0, new string[](0));

        uint end = index + count;
        if (end > account_count) {
            end = account_count;
            page_count = index - end;
        }

        accounts = new string[](page_count);
        uint i;
        uint n = 0;
        for (i = index; i < end; ++i) {
     
        }
    }

    uint background_color;
    uint body;
    uint body_color;
    uint facial_hair;
    uint facial_hair_color;
    uint shirt_1;
    uint shirt_1_color;
    uint shirt_2;
    uint shirt_2_color;
    uint shirt_3;
    uint shirt_3_color;
    uint nose;
    uint nose_color;
    uint mouth;
    uint mouth_color;
    uint eyes_base_color;
    uint eyes;
    uint eyes_color;
    uint hair;
    uint hair_color;
    uint hat;
    uint hat_color;
    uint accessories;
    uint accessories_color;
    uint mask;
    uint mask_color;
    

    function _set_background_color(uint _background_color) external onlyOwner {
    background_color = _background_color;
}

function _set_body(uint _body) external onlyOwner {
    body = _body;
}

function _set_body_color(uint _body_color) external onlyOwner {
    body_color = _body_color;
}

function _set_facial_hair(uint _facial_hair) external onlyOwner {
    facial_hair = _facial_hair;
}

function _set_facial_hair_color(uint _facial_hair_color) external onlyOwner {
    facial_hair_color = _facial_hair_color;
}

function _set_shirt_1(uint _shirt_1) external onlyOwner {
    shirt_1 = _shirt_1;
}

function _set_shirt_1_color(uint _shirt_1_color) external onlyOwner {
    shirt_1_color = _shirt_1_color;
}

function _set_shirt_2(uint _shirt_2) external onlyOwner {
    shirt_2 = _shirt_2;
}

function _set_shirt_2_color(uint _shirt_2_color) external onlyOwner {
    shirt_2_color = _shirt_2_color;
}

function _set_shirt_3(uint _shirt_3) external onlyOwner {
    shirt_3 = _shirt_3;
}

function _set_shirt_3_color(uint _shirt_3_color) external onlyOwner {
    shirt_3_color = _shirt_3_color;
}

function _set_nose(uint _nose) external onlyOwner {
    nose = _nose;
}

function _set_nose_color(uint _nose_color) external onlyOwner {
    nose_color = _nose_color;
}

function _set_mouth(uint _mouth) external onlyOwner {
    mouth = _mouth;
}

function _set_mouth_color(uint _mouth_color) external onlyOwner {
    mouth_color = _mouth_color;
}

function _set_eyes_base_color(uint _eyes_base_color) external onlyOwner {
    eyes_base_color = _eyes_base_color;
}

function _set_eyes(uint _eyes) external onlyOwner {
    eyes = _eyes;
}

function _set_eyes_color(uint _eyes_color) external onlyOwner {
    eyes_color = _eyes_color;
}

function _set_hair(uint _hair) external onlyOwner {
    hair = _hair;
}

function _set_hair_color(uint _hair_color) external onlyOwner {
    hair_color = _hair_color;
}

function _set_hat(uint _hat) external onlyOwner {
    hat = _hat;
}

function _set_hat_color(uint _hat_color) external onlyOwner {
    hat_color = _hat_color;
}

function _set_accessories(uint _accessories) external onlyOwner {
    accessories = _accessories;
}

function _set_accessories_color(uint _accessories_color) external onlyOwner {
    accessories_color = _accessories_color;
}

function _set_mask(uint _mask) external onlyOwner {
    mask = _mask;
}

function _set_mask_color(uint _mask_color) external onlyOwner {
    mask_color = _mask_color;
}



}