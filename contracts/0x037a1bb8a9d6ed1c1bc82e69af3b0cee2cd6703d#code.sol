// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// oz imports
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// local imports
import { IUniswapV2Router02 } from "./interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "./interfaces/IUniswapV2Factory.sol";

/**
 * @title VFIToken
 * @notice ERC-20 contract for $VFI token. This contract does contain a taxing mechanism on buys, sells, & transfers.
 */
contract VFIToken is ERC20, Ownable {

    // ---------------
    // State Variables
    // ---------------

    /// @notice Amount of accumulated $VFI royalties needed to distribute royalties.
    uint256 public swapTokensAtAmount;

    /// @notice If true, `account` is excluded from fees (aka whitelisted).
    mapping(address account => bool) public isExcludedFromFees;

    /// @notice If true, `account` is blacklisted from buying, selling, or transferring tokens.
    /// @dev Unless the recipient or sender is whitelisted.
    mapping(address account => bool) public isBlacklisted;

    /// @notice If true, `pair` is a verified pair/pool.
    mapping(address pair => bool) public automatedMarketMakerPairs;

    /// @notice Stores the contract reference to the local Uniswap V2 Router contract.
    IUniswapV2Router02 public uniswapV2Router;
    
    /// @notice Stores the address to the VFI/WETH Uniswap pair.
    address public uniswapV2Pair;

    /// @notice Stores the address of a tax beneficiary.
    address public taxReceiver1;

    /// @notice Stores the address of a tax beneficiary.
    address public taxReceiver2;

    /// @notice Stores the address of a tax beneficiary.
    address public taxReceiver3;

    /// @notice Stores the address of a tax beneficiary.
    address public taxReceiver4;

    /// @notice Fee allocation for `taxReceiver1`.
    uint8 public fee1;

    /// @notice Fee allocation for `taxReceiver2`.
    uint8 public fee2;

    /// @notice Fee allocation for `taxReceiver3`.
    uint8 public fee3;

    /// @notice Fee allocation for `taxReceiver4`.
    uint8 public fee4;

    /// @notice Total fee taken. `fee1` + `fee2` + `fee3` + `fee4`.
    uint8 public totalFees;

    /// @notice Used to prevent re-entrancy during royalty distribution.
    bool private swapping;

    /// @notice If true, trading is active.
    bool public tradingActive;

    /// @notice If true, a `totalFee` fee is taken from traders.
    bool public feesEnabled;

    /// @notice Maximum amount of tokens allowed in a tx.
    uint256 public maxTxAmount;

    /// @notice If true, all buyers and sellers will be blacklisted.
    bool public antiBotEnabled;

    /// @notice Max amount to sell on royalty handling.
    uint256 public swapTokensUpperLimit;


    // ------
    // Events
    // ------

    /**
     * @notice This event is emitted when `excludeFromFees` is executed.
     * @param account Address that was (or was not) excluded from fees.
     * @param isExcluded If true, `account` is excluded from fees. Otherwise, false.
     */
    event ExcludedFromFees(address indexed account, bool isExcluded);

    /**
     * @notice This event is emitted when `modifyBlacklist` is executed.
     * @param account Address that was (or was not) blacklisted.
     * @param blacklisted If true, `account` is blacklisted. Otherwise, false.
     */
    event BlacklistModified(address indexed account, bool blacklisted);

    /**
     * @notice This event is emitted when `automatedMarketMakerPairs` is modified.
     * @param pair Pair contract address.
     * @param value If true, `pair` is a verified pair address or pool. Otherwise, false.
     */
    event SetAutomatedMarketMakerPair(address indexed pair, bool value);

    /**
     * @notice This event is emitted when `updateFees` is executed.
     */
    event FeesUpdated(uint256 totalFee, uint8 fee1, uint8 fee2, uint8 fee3, uint8 fee4);

    /**
     * @notice This event is emitted when fees are distributed.
     */
    event FeesDistributed(uint256 totalAmountETH);

    /**
     * @notice This event is emitted when trading is enabled.
     */
    event TradingEnabled();

    /**
     * @notice This event is emitted when the anti bot system is disabled.
     */
    event AntiBotDisabled();


    // ------
    // Errors
    // ------

    /**
     * @notice This error is emitted when an account that is blacklisted tries to buy, sell, or transfer $VFI.
     * @param account Blacklisted account that attempted transaction.
     */
    error Blacklisted(address account);

    /**
     * @notice This error is emitted from an invalid address(0) input.
     */
    error ZeroAddress();


    // ---------
    // Modifiers
    // ---------

    modifier lockSwap() {
        swapping = true;
        _;
        swapping = false;
    }


    // -----------
    // Constructor
    // -----------

    /**
     * @notice This initializes VFICoin.
     * @param _admin Initial default admin address.
     * @param _router Local Uniswap v2 router address.
     */
    constructor(address _admin, address _router) ERC20("Vital Few Individuals", "VFI") Ownable(_admin) {
        taxReceiver1 = 0x7a8BE766C269dc3bB7cbF5d65c17180d1465038b;
        taxReceiver2 = 0x7a8BE766C269dc3bB7cbF5d65c17180d1465038b;
        taxReceiver3 = 0x7a8BE766C269dc3bB7cbF5d65c17180d1465038b;
        taxReceiver4 = 0x7a8BE766C269dc3bB7cbF5d65c17180d1465038b;

        isExcludedFromFees[0x7a8BE766C269dc3bB7cbF5d65c17180d1465038b] = true;
        isExcludedFromFees[address(this)] = true;
        isExcludedFromFees[_admin] = true;
        isExcludedFromFees[address(0)] = true;

        if (_router != address(0)) {
            uniswapV2Router = IUniswapV2Router02(_router);
            uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
            _setAutomatedMarketMakerPair(uniswapV2Pair, true);
        }

        swapTokensAtAmount =    10_000_000 ether; // $100 at init price ($0.00001)
        swapTokensUpperLimit = 100_000_000 ether; // $1000 at init price ($0.00001)

        uint256 supply = 10_000_000_000 ether;
        maxTxAmount =       100_000_000 ether; // 1% of supply -> $1000 at init price ($0.00001)

        fee1 = 7;
        fee2 = 2;
        fee3 = 1;
        fee4 = 1;
        totalFees = fee1 + fee2 + fee3 + fee4;
        
        _mint(_admin, supply);
    }


    // -------
    // Methods
    // -------

    /// @dev Allows address(this) to receive ETH.
    receive() external payable {}

    function enableTrading() external onlyOwner {
        tradingActive = true;
        antiBotEnabled = true;
        feesEnabled = true;

        emit TradingEnabled();
    }

    function disableAntiBot() external onlyOwner {
        antiBotEnabled = false;

        emit AntiBotDisabled();
    }

    function toggleFees() external onlyOwner {
        feesEnabled = !feesEnabled;
    }
    
    function manualSwapAndSend() external {
        require(!swapping, "royalty dist in progress");

        uint256 amount = balanceOf(address(this));
        require(amount != 0, "insufficient balance");

        _handleRoyalties(amount);
    }

    function manualSend() external {
        require(address(this).balance != 0, "insufficient balance");
        _distributeETH();
    }

    /**
     * @notice This method allows a permissioned admin to update the fees.
     * @dev If fees are being set to 0 -> It's preferred to just disable feesEnabled.
     *      Otherwise, make sure ETH balance in contract is 0 first.
     */
    function updateFees(uint8 _fee1, uint8 _fee2, uint8 _fee3, uint8 _fee4) external onlyOwner {
        totalFees = _fee1 + _fee2 + _fee3 + _fee4;

        require(totalFees <= 20, "sum of fees cannot exceed 20");
        
        fee1 = _fee1;
        fee2 = _fee2;
        fee3 = _fee3;
        fee4 = _fee4;

        emit FeesUpdated(totalFees, _fee1, _fee2, _fee3, _fee4);
    }

    function updateTaxReceiver1(address _account) external onlyOwner {
        require(taxReceiver1 != _account, "value already set");
        if (_account == address(0)) revert ZeroAddress();

        taxReceiver1 = _account;
        isExcludedFromFees[taxReceiver1] = true;
    }

    function updateTaxReceiver2(address _account) external onlyOwner {
        require(taxReceiver2 != _account, "value already set");
        if (_account == address(0)) revert ZeroAddress();
        
        taxReceiver2 = _account;
        isExcludedFromFees[taxReceiver2] = true;
    }

    function updateTaxReceiver3(address _account) external onlyOwner {
        require(taxReceiver3 != _account, "value already set");
        if (_account == address(0)) revert ZeroAddress();
        
        taxReceiver3 = _account;
        isExcludedFromFees[taxReceiver3] = true;
    }

    function updateTaxReceiver4(address _account) external onlyOwner {
        require(taxReceiver4 != _account, "value already set");
        if (_account == address(0)) revert ZeroAddress();
        
        taxReceiver4 = _account;
        isExcludedFromFees[taxReceiver4] = true;
    }

    function setMaxTxAmount(uint256 _maxTxAmount) external onlyOwner {
        maxTxAmount = _maxTxAmount;
    }

    /**
     * @notice This method allows a permissioned admin to update the `uniswapV2Pair` var.
     * @dev Used in the event the pool has to be created post deployment.
     * @param pair Pair Address -> Should be VFI/WETH.
     */
    function setUniswapV2Pair(address pair) external onlyOwner {
        if (pair == address(0)) revert ZeroAddress();
        uniswapV2Pair = pair;
        _setAutomatedMarketMakerPair(pair, true);
    }

    /**
     * @notice This method allows a permissioned admin to set a new automated market maker pair.
     * @param pair Pair contract address.
     * @param value If true, `pair` is a verified pair address or pool. Otherwise, false.
     */
    function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner {
        if (pair == address(0)) revert ZeroAddress();
        _setAutomatedMarketMakerPair(pair, value);
    }

    /**
     * @notice This method allows a permissioned admin to modify whitelisted addresses.
     * @dev Whitelisted addresses are excluded from fees.
     * @param account Address that is (or is not) excluded from fees.
     * @param excluded If true, `account` is excluded from fees. Otherwise, false.
     */
    function excludeFromFees(address account, bool excluded) external onlyOwner {
        isExcludedFromFees[account] = excluded;
        emit ExcludedFromFees(account, excluded);
    }

    /**
     * @notice This method allows a permissioned admin to modify blacklisted addresses.
     * @param account Address that is (or is not) blacklisted.
     * @param blacklisted If true, `account` is blacklisted. Otherwise, false.
     */
    function modifyBlacklist(address account, bool blacklisted) external onlyOwner {
        _modifyBlacklist(account, blacklisted);
    }

    /**
     * @notice This method allows a permissioned admin to set the new royalty balance threshold to trigger distribution.
     * @param swapAmount New amount of tokens to accumulate before distributing.
     */
    function setSwapTokensAtAmount(uint256 swapAmount) onlyOwner external {
        swapTokensAtAmount = swapAmount;
    }

    /**
     * @notice This method allows a permissioned admin to set the upper limit of royalty balance that can be distributed.
     * @param upperLimit The max amount of royalties that can be sold on sell/transfer.
     */
    function setSwapTokensUpperLimit(uint256 upperLimit) onlyOwner external {
        require(upperLimit >= swapTokensAtAmount, "must be >= swapTokensAtAmount");
        swapTokensUpperLimit = upperLimit;
    }

    
    // ----------------
    // Internal Methods
    // ----------------

    /**
     * @notice Transfers an `amount` amount of tokens from `from` to `to`.
     * @dev This overrides `_update` from ERC20.`
     *      Unless `from` or `to` is excluded, there will be a tax on the transfer.
     * @param from Address balance decreasing.
     * @param to Address balance increasing.
     * @param amount Amount of tokens being transferred.
     */
    function _update(address from, address to, uint256 amount) internal override {

        // note: if automatedMarketMakerPairs[from] == true -> BUY
        // note: if automatedMarketMakerPairs[to] == true   -> SELL

        bool excludedAccount = isExcludedFromFees[from] || isExcludedFromFees[to];

        if (!excludedAccount) { //If not whitelisted

            require(tradingActive, "Trading has not yet been enabled");

            if (isBlacklisted[from]) revert Blacklisted(from);
            if (isBlacklisted[to]) revert Blacklisted(to);

            // if `antiBotEnabled` is true, buyers will be blacklisted and not allowed to sell
            if (automatedMarketMakerPairs[from] && antiBotEnabled) {
                _modifyBlacklist(to, true);
            }

            // if buy or sell, check maxTx amount
            if (automatedMarketMakerPairs[from] || automatedMarketMakerPairs[to]) {
                require(amount <= maxTxAmount, "Max Tx Amount exceeded");
            }

            if (!automatedMarketMakerPairs[from]) { // if NOT a buy, distribute royalties and make swaps
            
                // take contract balance of royalty tokens
                uint256 contractTokenBalance = balanceOf(address(this));

                // if the contract balance is greater than swapTokensAtAmount, we swap
                bool canSwap = contractTokenBalance >= swapTokensAtAmount;
                
                if (!swapping && canSwap) {
                    // if contract balance is greater than swapTokensUpperLimit, set to swapTokensUpperLimit
                    if (contractTokenBalance > swapTokensUpperLimit) {
                        contractTokenBalance = swapTokensUpperLimit;
                    }
                    _handleRoyalties(contractTokenBalance);
                }
            }
        }

        bool takeFee = !swapping && !excludedAccount && feesEnabled;

        // `takeFee` == true if no distribution && non-WL && fees enabled
        if(takeFee) {
            uint256 fees;

            fees = (amount * totalFees) / 100;        
            amount -= fees;

            super._update(from, address(this), fees);
        }

        super._update(from, to, amount);
    }

    function _handleRoyalties(uint256 amount) internal {
        _swapTokensForETH(amount);
        if (address(this).balance > 0) {
            _distributeETH();
        }
    }

    /**
     * @notice This internal method takes `tokenAmount` of tokens and swaps it for ETH.
     * @param tokenAmount Amount of $VFI tokens being swapped/sold for ETH.
     */
    function _swapTokensForETH(uint256 tokenAmount) internal lockSwap {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETH(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp + 300
        );
    }

    function _distributeETH() internal {
        uint256 amount = address(this).balance;
        bool sent;

        (sent,) = taxReceiver1.call{value: amount * fee1 / totalFees}("");
        require(sent, "Failed to send Ether to recipient 1");

        (sent,) = taxReceiver2.call{value: amount * fee2 / totalFees}("");
        require(sent, "Failed to send Ether to recipient 2");

        (sent,) = taxReceiver3.call{value: amount * fee3 / totalFees}("");
        require(sent, "Failed to send Ether to recipient 3");

        (sent,) = taxReceiver4.call{value: amount * fee4 / totalFees}("");
        require(sent, "Failed to send Ether to recipient 4");

        emit FeesDistributed(amount);
    }

    function _modifyBlacklist(address account, bool blacklisted) internal {
        if (blacklisted) {
            if (account == address(0)) revert ZeroAddress();
            require(
                account != address(uniswapV2Router) &&
                account != uniswapV2Pair &&
                !isExcludedFromFees[account] &&
                !automatedMarketMakerPairs[account],
                "Invalid input"
            );
        }

        isBlacklisted[account] = blacklisted;
        emit BlacklistModified(account, blacklisted);
    }

    /**
     * @notice This internal method updates the `automatedMarketMakerPairs` mapping.
     * @param pair Pair contract address.
     * @param value If true, address is set as an AMM pair. Otherwise, false.
     */
    function _setAutomatedMarketMakerPair(address pair, bool value) internal {
        require(automatedMarketMakerPairs[pair] != value, "Already set");

        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }
}