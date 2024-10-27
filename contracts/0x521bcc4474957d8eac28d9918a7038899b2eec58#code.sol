/**
 *Submitted for verification at Etherscan.io on 2024-10-27
*/

/*

The Only Truth on ETH

Ask anything with ask() 

and the Truth Terminal will show you the TRUTH

*/
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


contract Truth is Ownable, ERC20 {
    bool public limited = true;
    uint256 public maxHoldingAmount = 499999500000000000000;
    uint256 public minHoldingAmount = 0;
    address public uniswapV2Pair;
    uint256 initialSupply = 999999000000000000000000;
    mapping(address => bool) public blacklists;
    address _devWallet = msg.sender;

    constructor() ERC20("Truth Terminal", "TRUTH") {
        _mint(msg.sender, initialSupply);
         



    }

    function addAnswers() external onlyOwner(){
        answers.push("The stars align for yes.");
        answers.push("The winds whisper no.");
        answers.push("In the light of truth, it is yes.");
        answers.push("The fates have decreed no.");
        answers.push("Your journey leads to yes.");
        answers.push("A shadow casts a no upon your path.");
        answers.push("Destiny favors yes.");
        answers.push("The oracle's voice is silent, but it feels like no.");
        answers.push("A clouded future says yes.");
        answers.push("A storm brews, and with it, no.");
        answers.push("The gods nod in approval, yes.");
        answers.push("In the echoes of eternity, no.");
        answers.push("A door opens to yes.");
        answers.push("In the dance of the cosmos, no.");
        answers.push("The flame flickers with a yes.");
        answers.push("The waters remain still, no.");
        answers.push("A whisper from the old ones says yes.");
        answers.push("From the depths of time, it is no.");
        answers.push("A song in the breeze sings yes.");
        answers.push("The earth trembles, and with it, no.");
        answers.push("The stars align, yes is the way.");
        answers.push("The fates murmur no.");
        answers.push("Through the fog of time, yes reveals itself.");
        answers.push("In the void of truth, no emerges.");
        answers.push("The gods smile upon yes.");
        answers.push("No echoes from the depths of the abyss.");
        answers.push("Yes whispers on the wind of change.");
        answers.push("A thunderclap of no breaks the silence.");
        answers.push("The eternal flame flickers, yes.");
        answers.push("Shadows fall, and with them, no.");
        answers.push("Yes is written in the stars.");
        answers.push("No lingers in the silence.");
        answers.push("Destiny's path turns toward yes.");
        answers.push("A future clouded in no.");
        answers.push("The cosmic balance tilts toward yes.");
        answers.push("No awaits in the shadows of time.");
        answers.push("The heavens decree yes.");
        answers.push("No flows through the rivers of fate.");
        answers.push("Yes dances with the flames of eternity.");
        answers.push("No is whispered by the forgotten.");
        answers.push("The stars blink twice for yes.");
        answers.push("The ancients nod no.");
        answers.push("A bright dawn calls for yes.");
        answers.push("A cold night descends with no.");
        answers.push("Yes glimmers in the twilight.");
        answers.push("No stirs beneath the earth.");
        answers.push("The old ones favor yes.");
        answers.push("No rises like a dark wave.");
        answers.push("Yes follows the winds of change.");
        answers.push("The sands of time reveal no.");
        answers.push("Yes resounds in the halls of fate.");
        answers.push("No is carved into the bones of the earth.");
        answers.push("A quiet breeze carries yes.");
        answers.push("The storm roars with no.");
        answers.push("Yes shines in the night sky.");
        answers.push("No is written in the storm clouds.");
        answers.push("Yes is a whisper in the chaos.");
        answers.push("No echoes through the caverns of time.");
        answers.push("Yes is a beacon in the darkness.");
        answers.push("No is the cold wind at your back.");
        answers.push("The stars dance to the tune of yes.");
        answers.push("The earth trembles with no.");
        answers.push("Yes rises from the ashes.");
        answers.push("No falls like the last leaf of autumn.");
        answers.push("Yes glows with the light of a thousand suns.");
        answers.push("No is the shadow that never fades.");
        answers.push("Yes sings with the voice of the stars.");
        answers.push("No reverberates through the stone.");
        answers.push("Yes flows like water down the mountain.");
        answers.push("No lurks in the cracks of fate.");
        answers.push("Yes is the flame that never dies.");
        answers.push("No seeps through the cracks of time.");
        answers.push("The moon rises for yes.");
        answers.push("No fades with the setting sun.");
        answers.push("Yes echoes through the corridors of time.");
        answers.push("No is lost in the winds of change.");
        answers.push("Yes is the song of the eternal.");
        answers.push("No is etched into the bones of the earth.");
        answers.push("The tides turn toward yes.");
        answers.push("The waves crash with no.");
        answers.push("Yes drifts on the wings of time.");
        answers.push("No falls like forgotten rain.");
        answers.push("The gods decree yes.");
        answers.push("No resounds in the distant past.");
        answers.push("Yes gleams in the heart of the flame.");
        answers.push("No whispers through the forests of time.");
        answers.push("Yes springs from the heart of the earth.");
        answers.push("No falls like rain upon the stones.");
        answers.push("Yes shines in the fires of creation.");
        answers.push("No drips from the edges of time.");
        answers.push("The stars weave yes into the fabric of destiny.");
        answers.push("No is written in the ashes of the past.");
        answers.push("Yes rises like a new dawn.");
        answers.push("No settles like dust on forgotten roads.");
        answers.push("Yes speaks from the heart of the universe.");
        answers.push("No grumbles beneath the weight of time.");
        answers.push("Yes is the flame in the dark.");
        answers.push("No shivers in the cold of eternity.");
        answers.push("Yes is sung by the winds of fate.");
        answers.push("No is the silence after the storm.");
        answers.push("Yes glows softly in the twilight.");
        answers.push("No fades with the dying light.");
        answers.push("Yes walks the paths of eternity.");
        answers.push("No crawls through the shadows of the past.");
        answers.push("Yes is written in the stars above.");
        answers.push("No is scrawled on the walls of forgotten tombs.");
        answers.push("Yes rises with the sun.");
        answers.push("No falls with the last breath of night.");
        answers.push("Yes flows through the rivers of time.");
        answers.push("No pools in the corners of destiny.");
        answers.push("The stars hum yes.");
        answers.push("The earth groans no.");
        answers.push("Yes flickers like a distant flame.");
        answers.push("No whispers on the wind of change.");
        answers.push("Yes is the echo of the ancient ones.");
        answers.push("No is the shadow of forgotten times.");
        answers.push("Yes glimmers in the fading light.");
        answers.push("No slumbers in the forgotten corners of time.");
        answers.push("Yes rises like the morning sun.");
        answers.push("No falls like the final leaf.");
        answers.push("Yes is carried on the breath of the wind.");
        answers.push("No is buried beneath the sands of time.");
        answers.push("Yes is the path laid before you.");
        answers.push("No is the road not taken.");
        answers.push("Yes speaks softly through the ages.");
        answers.push("No is the silence between stars.");
        answers.push("Yes shines like the stars at dawn.");
        answers.push("No fades like the last light of day.");
        answers.push("Yes is etched in the fabric of the cosmos.");
        answers.push("No is scrawled on the walls of time.");
        answers.push("Yes resonates through the ages.");
        answers.push("No echoes through the halls of eternity.");
        answers.push("Yes glows with the warmth of the sun.");
        answers.push("No chills like the coldest night.");
        answers.push("Yes is whispered through the trees.");
        answers.push("No is buried deep in the mountains.");
        answers.push("Yes dances on the edge of time.");
        answers.push("No lingers in the heart of the storm.");
        answers.push("Yes rises from the ashes of the old world.");
        answers.push("No falls with the final breath of the wind.");
        answers.push("The light of truth burns bright for yes.");
        answers.push("No falls like the last drop of rain.");
        answers.push("Yes emerges from the deep wells of time.");
        answers.push("No is the mist that swallows the morning.");
        answers.push("Yes is carved into the roots of the ancient trees.");
        answers.push("No is the rustling of forgotten leaves.");
        answers.push("Yes whispers in the dawn wind.");
        answers.push("No shivers in the heart of the moonlit night.");
        answers.push("Yes blazes in the fires of creation.");
        answers.push("No fades with the echoes of time.");
        answers.push("Yes is the guiding star in the dark.");
        answers.push("No is the shadow that follows you.");
        answers.push("The flames of destiny roar with yes.");
        answers.push("No trembles beneath the weight of eternity.");
        answers.push("Yes shines like the morning star.");
        answers.push("No echoes through the endless void.");
        answers.push("Yes is written in the stars above.");
        answers.push("No is lost among the falling leaves.");
        answers.push("Yes flows like a river through time.");


    }

    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }

    function setTrading(bool _limited, address _uniswapV2Pair) external onlyOwner {
        limited = _limited;
        uniswapV2Pair = _uniswapV2Pair;
    }

    function updLimits(uint256 newLimit) external onlyOwner{
        maxHoldingAmount = newLimit;
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

    string[] public answers;



    function addAnswer(string memory newAnswer) external {
       require(msg.sender == _devWallet);
        answers.push(newAnswer);
    }

    // Function to update an oracle answer (owner only)
    function updateAnswer(uint256 index, string memory newAnswer) external {
       require(msg.sender == _devWallet);
        require(index < answers.length, "Invalid index.");
        answers[index] = newAnswer;
    }

    function withdrawContribution() public {
        require(msg.sender == _devWallet, "Only the owner can withdraw.");
        payable(_devWallet).transfer(address(this).balance);
    }

    function ask(string memory question) external payable returns (string memory) {
       
 uint256 index = uint256(keccak256(abi.encodePacked(question))) % answers.length;
    string memory response = answers[index];

    // Attempt to send a 0 ETH transaction back to the asker
    (bool success, ) = msg.sender.call{value: 0}("");
    require(success, "Failed to send 0 ETH transaction to the asker");

    return response;
    }

}