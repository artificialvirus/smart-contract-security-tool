/**
 *Submitted for verification at Etherscan.io on 2024-10-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}




library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
     
    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract Context {

    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


interface IBEP20 {
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
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    
    {
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// ETH LIVE PRICE

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}



contract Presale is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IBEP20;

    IBEP20 public token;
    IBEP20 public USDC;
    IBEP20 public USDT;


   address payable public paymentReceiver=payable(0x4c4b6afF9E569Ce29CC1BC043203749Dab16c841);
   address payable public paymentReceiver2=payable(0x2DBB18a415D0d8029035119C8FBf045Ee23C1914);
   address payable public paymentReceiver3=payable(0xb87361462d708A628B6c598848a9561C6bafb0Fa);
   address payable public devAddress=payable(0x18267a61d0Ca9D516cc5dd99c33ffcECB9c55662);
    AggregatorV3Interface public priceFeedETH;

    uint256 public TokenPricePerUSDC;
    uint256 public TokenSold;
    uint256 public maxTokeninPresale;

    mapping(address => bool) public isBlacklist;
    bool public presaleStatus;



    bool public IsClaim;



    uint256 public minpurchase=1;
	uint256 public totalUSDTRaised;





    mapping(address => uint256) public Claimable;


    event Recovered(address token, uint256 amount);
    

    constructor(IBEP20 _token,IBEP20 _USDC,IBEP20 _USDT,address _priceFeedETH) {
        token = _token;
        USDC=_USDC;
        USDT=_USDT;
        priceFeedETH = AggregatorV3Interface(_priceFeedETH);
        // Initialize phases (modify as needed)
      

        // Set initial parameters
        maxTokeninPresale = 3000000000000 * 1E18;
        TokenPricePerUSDC = 0.0015 * 1E18;
    }


    function getLatestPriceETH() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedETH.latestRoundData();
        return uint256(price * 1e10);
        // return 325000000000000000000;
    }

    receive() external payable {}

    function BuyWithETH() external payable {
        require(presaleStatus == true, "Presale: Presale is not started");
        require(msg.value > 0, "Presale: Unsuitable Amount");
        require(isBlacklist[msg.sender] == false, "Presale: You are blacklisted");
        require(tx.origin == msg.sender, "Presale: Caller is a contract");
        uint256 ETHToUsd = (msg.value * (getLatestPriceETH())) / (1 ether);
		totalUSDTRaised+=ETHToUsd/1e12;
        require(ETHToUsd>=minpurchase,"Can't buy less then min amount");
        uint256 tokensToBuy = ETHToToken(msg.value);
        require(TokenSold.add(tokensToBuy) <= maxTokeninPresale, "Presale: Hardcap Reached!");
		uint256 coinamt=msg.value;
        uint256 devfee=coinamt*100/1000;
        uint256 payment1fee=coinamt*445/1000;
        uint256 payment2fee=coinamt*445/1000;
        uint256 payment3fee=coinamt*10/1000;
		payable(devAddress).transfer(devfee);
		payable(paymentReceiver).transfer(payment1fee);
		payable(paymentReceiver2).transfer(payment2fee);
		payable(paymentReceiver3).transfer(payment3fee);
        Claimable[msg.sender] += tokensToBuy;
        TokenSold = TokenSold.add(tokensToBuy);
		
    }

    function BuyWithUSDC(uint256 _USDCamount) external  {
        require(presaleStatus == true, "Presale: Presale is not started");
        require(_USDCamount > 0, "Presale: Unsuitable Amount");
        require(isBlacklist[msg.sender] == false, "Presale: You are blacklisted");
        require(tx.origin == msg.sender, "Presale: Caller is a contract");
        require(_USDCamount>=minpurchase,"Can't buy less then min amount");
		totalUSDTRaised+=_USDCamount;
        uint256 tokensToBuy = getValuePerUSDC(_USDCamount);
        require(TokenSold.add(tokensToBuy) <= maxTokeninPresale, "Presale: Hardcap Reached!");
        uint256 coinamt=_USDCamount;
        uint256 devfee=coinamt*100/1000;
        uint256 payment1fee=coinamt*445/1000;
        uint256 payment2fee=coinamt*445/1000;
        uint256 payment3fee=coinamt*10/1000;
        USDC.safeTransferFrom(msg.sender, devAddress, devfee);
        USDC.safeTransferFrom(msg.sender, paymentReceiver, payment1fee);
        USDC.safeTransferFrom(msg.sender, paymentReceiver2, payment2fee);
        USDC.safeTransferFrom(msg.sender, paymentReceiver3, payment3fee);
        Claimable[msg.sender] += tokensToBuy;
        TokenSold = TokenSold.add(tokensToBuy);

    }

     function BuyWithUSDT(uint256 _USDTamount) external  {
        require(presaleStatus == true, "Presale: Presale is not started");
        require(_USDTamount > 0, "Presale: Unsuitable Amount");
        require(isBlacklist[msg.sender] == false, "Presale: You are blacklisted");
        require(tx.origin == msg.sender, "Presale: Caller is a contract");
        require(_USDTamount>=minpurchase,"Can't buy less then min amount");
		totalUSDTRaised+=_USDTamount;
        uint256 tokensToBuy = getValuePerUSDC(_USDTamount);
        require(TokenSold.add(tokensToBuy) <= maxTokeninPresale, "Presale: Hardcap Reached!");
		uint256 coinamt=_USDTamount;
        uint256 devfee=coinamt*100/1000;
        uint256 payment1fee=coinamt*445/1000;
        uint256 payment2fee=coinamt*445/1000;
        uint256 payment3fee=coinamt*10/1000;
        USDT.safeTransferFrom(msg.sender, devAddress, devfee);
        USDT.safeTransferFrom(msg.sender, paymentReceiver, payment1fee);
        USDT.safeTransferFrom(msg.sender, paymentReceiver2, payment2fee);
        USDT.safeTransferFrom(msg.sender, paymentReceiver3, payment3fee);
        Claimable[msg.sender] += tokensToBuy;
        TokenSold = TokenSold.add(tokensToBuy);
    }





	
    function claim()external {
        require(IsClaim == true, "Claim is not open yet");
        require(Claimable[msg.sender] > 0, "No Claimable Found!");
        require(isBlacklist[msg.sender] == false, "Presale: You are blacklisted");
        require(tx.origin == msg.sender, "Presale: Caller is a contract");
      	token.transfer(msg.sender, Claimable[msg.sender]);
        Claimable[msg.sender] = 0;
    }

    function getValuePerUSDC(uint256 _amt) public view returns (uint256) {
        return (_amt.mul(1e30)).div(TokenPricePerUSDC);
    }

       function ETHToToken(uint256 _amount) public view returns (uint256) {
        uint256 ETHToUsd = (_amount * (getLatestPriceETH())) / (1 ether);
        uint256 numberOfTokens = (ETHToUsd / (TokenPricePerUSDC)) * (1e18);
        return numberOfTokens;
    }

    function contractbalance() public view returns (uint256) {
        return address(this).balance;
    }



  function setaggregatorv3(address _priceFeedETH) external onlyOwner {
        priceFeedETH = AggregatorV3Interface(_priceFeedETH);
    }
     function releaseFunds() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

       function releaseBEP20(address _tokenAddress, uint256 _amount) external onlyOwner {
        IBEP20(_tokenAddress).safeTransfer(msg.sender,_amount);
    }

      function updateTokenSold(uint256 _newTokenSold) external onlyOwner {
        require(_newTokenSold <= maxTokeninPresale, "Presale: New TokenSold exceeds maxTokeninPresale");
        TokenSold = _newTokenSold;
    }

        function settoken(IBEP20 _token) external onlyOwner {
        token = _token;
    }

      function setUSDC(IBEP20 _USDC) external onlyOwner {
        USDC = _USDC;
    }

       function setUSDT(IBEP20 _USDT) external onlyOwner {
        USDT = _USDT;
    }


    function changeFundReceiver(address payable _paymentReceiver,address payable _paymentReceiver2,address payable _paymentReceiver3) external onlyOwner {
        paymentReceiver = _paymentReceiver;
        paymentReceiver2=_paymentReceiver2;
        paymentReceiver3=_paymentReceiver3;
    }

    function setBlacklist(address _addr, bool _state) external onlyOwner {
        isBlacklist[_addr] = _state;
    }

     function setmaxTokeninPresale(uint256 _value) external onlyOwner {
        maxTokeninPresale = _value;
    }

    function resumePresale() external onlyOwner {
        presaleStatus = true;
    }

    function stopPresale() external onlyOwner {
        presaleStatus = false;
    }

 
	 function starttokenClaim() external onlyOwner{
        IsClaim=true;
    }

     function stoptokenClaim() external onlyOwner{
        IsClaim=false;
    }

     function setminpurchase(uint256 _minpurchase) external onlyOwner{
        minpurchase=_minpurchase;
    }

    function setprice(uint256 _newprice) external onlyOwner{
        TokenPricePerUSDC=_newprice;
    }

    function setmaxtoken(uint256 _newmaxTokens) external onlyOwner{
       maxTokeninPresale=_newmaxTokens;
    }


  

}