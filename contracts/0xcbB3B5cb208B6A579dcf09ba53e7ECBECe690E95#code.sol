pragma solidity >=0.5.16;
pragma experimental ABIEncoderV2;

import "./EIP20Interface.sol";
import "./SafeMath.sol";

contract EsgSHIPV3Pro{
    using SafeMath for uint256;
    EIP20Interface public esg;
    address public owner;

    event SetInvitee(address referrerAddress, address inviteeAddress);

    event SetInviteeByOwner(address[] referrerAddress, address[] inviteeAddress);

    event EsgInvest(address account, uint256 amount, uint256 price);

    event EsgInvestByOwner(address[] account, uint256[] values, uint256[] withdraws, uint256[] bonuss, uint256[] lastTimes, uint256[] endTimes, uint256[] releaseRates);

    event EsgClaimed(address account, uint256 amount, uint256 price);

    event EsgChangeLockInfo(address _user, uint256 _value, uint256 _withdraw, uint256 _bonus, uint256 _lastTime, uint256 _endTime, uint256 _releaseRate);

    event FeeWalletChanged(address feewallet, address miniwallet);

    struct Lock {
        uint256 value;
        uint256 withdraw;
        uint256 bonus;
        uint256 lastTime;
        uint256 endTime;
        uint256 releaseRate;
    }
    mapping(address => Lock) public locks;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    struct Referrer {
        address[] invitees;
    }
    mapping (address => Referrer) internal inviteeslist;

    struct User {
        address referrer_addr;
    }
    mapping (address => User) public referreraddr;

    address public feeWallet = 0xaAc08D7CF5e7D9b0418e841d1E68cb5a2904A08C;
    uint256 public fee_rate = 5;
    address public miniWallet = 0x22656e9DeeCD1fC1D9380b1D5db11522c6139899;
    uint256 public mini_rate = 10;
    uint256 public fee_rate2 = 15;

    uint256 public invest_days1 = 350;
    uint256 public invest_days2 = 300;
    uint256 public invest_rate = 10;
    uint256 public first_level = 20000 * 1e24;

    uint256 public referralThreshold = 1000 * 1e24;
    uint256 public total_deposited;
    uint256 public total_user;
    uint256 public total_amount;
    uint256 public total_extracted;
    uint256 public total_claim_amount;
    uint256 public lockRates = 100;
    uint256 public staticRewardRate = 10;
    uint256 public invest_price = 511000;
    uint256 public claim_price = 511000;
    bool public investEnabled;
    bool public claimEnabled;

    constructor(address esgAddress) public {
        owner = msg.sender;
        investEnabled = true;
        claimEnabled = true;
        esg = EIP20Interface(esgAddress);
    }

    function setPrice(uint256 investPrice, uint256 claimPrice) onlyOwner public {
        require(investPrice > 0 && claimPrice > 0, "Price must be positive");
        invest_price = investPrice;
        claim_price = claimPrice;
    }

    function setFee(uint256 _fee, uint256 _minifee, uint256 _fee2) onlyOwner public {
        require(_fee2 >= _fee + _minifee, "_fee2 must be greater than the sum of the first two numbers");
        fee_rate = _fee;
        mini_rate = _minifee;
        fee_rate2 = _fee2;
    }

    function setFeeWallets(address _feewallet, address _miniwallet) onlyOwner public {
        require(_feewallet != address(0) && _miniwallet != address(0), "Invalid address");
        feeWallet = _feewallet;
        miniWallet = _miniwallet;
        emit FeeWalletChanged(_feewallet, _miniwallet);
    }

    function setInvestRate(uint256 _rate) onlyOwner public {
        invest_rate = _rate;
    }

    function setTotalNum(uint256 _deposited, uint256 _user, uint256 _amount, uint256 _extracted, uint256 _claimnum) onlyOwner public {
        total_deposited = _deposited;
        total_user = _user;
        total_amount = _amount;
        total_extracted = _extracted;
        total_claim_amount = _claimnum;
    }

    function setInvestEnabled(bool _investEnabled) onlyOwner public {
        investEnabled = _investEnabled;
    }

    function setClaimEnabled(bool _claimEnabled) onlyOwner public {
        claimEnabled = _claimEnabled;
    }

    function setInvestDays(uint256 days1, uint256 days2) onlyOwner public {
        require(days1 > 0 && days2 > 0, "days should be greater than 0");
        invest_days1 = days1;
        invest_days2 = days2;
    }

    function setInvestLevels(uint256 level) onlyOwner public {
        require(level > 0, "level should be greater than 0");
        first_level = level;
    }

    function setLockRates(uint256 _lockRates) onlyOwner public {
        lockRates = _lockRates;
    }

    function setReferralThreshold(uint256 _referralThreshold) onlyOwner public {
        referralThreshold = _referralThreshold;
    }

    function setStaticRewardRate(uint256 _staticRewardRate) onlyOwner public {
        staticRewardRate = _staticRewardRate;
    }

    function setInvitee(address inviteeAddress) public returns (bool) {
        require(inviteeAddress != address(0), "inviteeAddress cannot be 0x0.");

        User storage user = referreraddr[inviteeAddress];
        require(user.referrer_addr == address(0), "This account had been invited!");
        
        Lock storage lock = locks[msg.sender];
        require(lock.value.mul(lockRates).div(100).add(lock.value).sub(lock.withdraw).sub(lock.bonus) >= referralThreshold, "Referrer has no referral qualification.");

        Lock storage inviteeLocks = locks[inviteeAddress];
        require(inviteeLocks.value == 0, "This account had staked!");
        
        Referrer storage referrer = inviteeslist[msg.sender];
        referrer.invitees.push(inviteeAddress);

        User storage _user = referreraddr[inviteeAddress];
        _user.referrer_addr = msg.sender;

        emit SetInvitee(msg.sender, inviteeAddress);
        return true;   
    }

    function setInviteeByOwner(address[] memory referrerAddress, address[] memory inviteeAddress) public onlyOwner returns (bool) {
        require(referrerAddress.length == inviteeAddress.length, "The length of the two arrays must be the same");

        for (uint256 i = 0; i < inviteeAddress.length; i++) {
            Referrer storage referrer = inviteeslist[referrerAddress[i]];
            referrer.invitees.push(inviteeAddress[i]);
            User storage _user = referreraddr[inviteeAddress[i]];
            _user.referrer_addr = referrerAddress[i];
        }

        emit SetInviteeByOwner(referrerAddress, inviteeAddress);
        return true;   
    }

    function removeInvitee(address referrer, address invitee) public onlyOwner {
        address[] storage invitees = inviteeslist[referrer].invitees;
        for (uint i = 0; i < invitees.length; i++) {
            if (invitees[i] == invitee) {
                invitees[i] = invitees[invitees.length - 1];
                invitees.pop();
                break;
            }
        }
    }

    function changeReferrerAddr(address referrer, address invitee) public onlyOwner {
        require(invitee != address(0), "inviteeAddress cannot be 0x0.");
        User storage _user = referreraddr[invitee];
        _user.referrer_addr = referrer;
    }

    function getInviteelist(address referrerAddress) public view returns (address[] memory) {
        require(referrerAddress != address(0), "referrerAddress cannot be 0x0.");
        Referrer storage referrer = inviteeslist[referrerAddress];
        return referrer.invitees;
    }

    function getReferrer(address inviteeAddress) public view returns (address) {
        require(inviteeAddress != address(0), "inviteeAddress cannot be 0x0.");
        User storage user = referreraddr[inviteeAddress];
        return user.referrer_addr;
    }

    function invest(uint256 _amount) public returns (bool) {
        require(investEnabled == true, "No invest allowed!");
        require(_amount > 0, "Invalid amount.");

        uint256 fee_amount = _amount.mul(invest_rate).div(100);
        esg.transferFrom(msg.sender, feeWallet, fee_amount);
        esg.transferFrom(msg.sender, address(this), _amount - fee_amount);

        Lock storage user_locks = locks[msg.sender];
        uint256 invest_days = 0;
        if(user_locks.lastTime > 0){
            user_locks.bonus += block.timestamp.sub(user_locks.lastTime).mul(user_locks.releaseRate).div(86400);
        }

        if(user_locks.value == 0){
            total_user = total_user + 1;
        }
        
        user_locks.value += _amount.mul(invest_price);
        user_locks.lastTime = block.timestamp;
        
        uint256 deposit = user_locks.value.mul(lockRates).div(100).add(user_locks.value).sub(user_locks.withdraw).sub(user_locks.bonus);
        if(deposit < first_level){
            invest_days = invest_days1;
        }else{
            invest_days = invest_days2;
        } 
        user_locks.endTime = block.timestamp + (invest_days * 86400);
        user_locks.releaseRate = deposit.div(invest_days);

        total_deposited += _amount.mul(invest_price);
        total_amount += _amount;
            
        User storage user = referreraddr[msg.sender];

        if(user.referrer_addr != address(0)){
            locks[user.referrer_addr].bonus += _amount.mul(invest_price).mul(staticRewardRate).div(100);
        }

        emit EsgInvest(msg.sender, _amount, invest_price);
        return true;
    }

    function investByOwner(address[] memory investAddress, uint256[] memory _value, uint256[] memory _withdraw, uint256[] memory _bonus, uint256[] memory _lastTime, uint256[] memory _endTime, uint256[] memory _releaseRate) public onlyOwner returns (bool) {
        require(investAddress.length == _value.length && investAddress.length == _withdraw.length && investAddress.length == _bonus.length && investAddress.length == _lastTime.length && investAddress.length == _endTime.length && investAddress.length == _releaseRate.length, "The length of the arrays must be the same");
        
        for (uint256 i = 0; i < investAddress.length; i++) {
            Lock storage user_locks = locks[investAddress[i]];
            user_locks.value = _value[i];
            user_locks.withdraw = _withdraw[i];
            user_locks.bonus = _bonus[i];
            user_locks.lastTime = _lastTime[i];
            user_locks.endTime = _endTime[i];
            user_locks.releaseRate = _releaseRate[i];
        }

        emit EsgInvestByOwner(investAddress, _value, _withdraw, _bonus, _lastTime, _endTime, _releaseRate);
        return true;
    }

    function claim() public returns (bool) {
        require(claimEnabled == true, "No claim allowed!");
        Lock storage userLocks = locks[msg.sender];
        require(userLocks.releaseRate > 0 && userLocks.lastTime > 0, "No locked amount.");

        uint256 totalInterest = userLocks.bonus;
        uint256 userDeposit = userLocks.value.mul(lockRates).div(100).add(userLocks.value);
        uint256 userWithdraw = userLocks.withdraw;
        require(userDeposit > userWithdraw, "All investments have been fully withdrawn");

        uint256 interest = (block.timestamp.sub(userLocks.lastTime)).mul(userLocks.releaseRate).div(86400);    
        totalInterest += interest;
        userLocks.lastTime = block.timestamp;
        userLocks.bonus = 0;   
        require(totalInterest > 0, "No interest to claim.");

        uint256 transfer_amount = 0;
        uint256 feeAmount = 0;
        uint256 miniAmount = 0;
        uint256 total_withdraw = userLocks.withdraw + totalInterest;
        if(total_withdraw >= userDeposit){
            transfer_amount = (userDeposit.sub(userWithdraw)).div(claim_price);
            userLocks.withdraw = userDeposit;
            feeAmount = transfer_amount.mul(fee_rate).div(100);
            miniAmount = transfer_amount.mul(mini_rate).div(100);
            uint256 fee = 0;
            if(userLocks.withdraw > userLocks.value){
                fee = fee_rate2 - fee_rate - mini_rate;
                feeAmount += transfer_amount.mul(fee).div(100);
            }
            if(feeAmount > 0){
                esg.transfer(feeWallet, feeAmount);  
            }
            if(miniAmount > 0){
                esg.transfer(miniWallet, miniAmount);  
            }
            esg.transfer(msg.sender, transfer_amount.sub(feeAmount).sub(miniAmount));
            userLocks.releaseRate = 0;
            userLocks.lastTime = 0;
            userLocks.endTime = 0;
        }else{
            transfer_amount = totalInterest.div(claim_price);
            userLocks.withdraw += totalInterest;
            feeAmount = transfer_amount.mul(fee_rate).div(100);
            miniAmount = transfer_amount.mul(mini_rate).div(100);
            uint256 fee = 0;
            if(userLocks.withdraw > userLocks.value){
                fee = fee_rate2 - fee_rate - mini_rate;
                feeAmount += transfer_amount.mul(fee).div(100);
            }
            if(feeAmount > 0){
                esg.transfer(feeWallet, feeAmount);  
            }
            if(miniAmount > 0){
                esg.transfer(miniWallet, miniAmount);  
            }
            esg.transfer(msg.sender, transfer_amount.sub(feeAmount).sub(miniAmount));

            uint256 deposit = userDeposit.sub(total_withdraw);
            uint256 invest_days = 0;
            if(deposit < first_level){
                invest_days = invest_days1;
            }else{
                invest_days = invest_days2;
            } 
            userLocks.releaseRate = deposit.div(invest_days);
            userLocks.endTime = block.timestamp + (invest_days * 86400);
        }
        total_claim_amount += transfer_amount;
        total_extracted += transfer_amount.mul(claim_price);

        emit EsgClaimed (msg.sender, transfer_amount, claim_price); 
        return true;
    }

    function getUnclaimValue(address _user) public view returns (uint256) {
        require(_user != address(0), "_user cannot be 0x0.");
        Lock storage userLocks = locks[_user];
        if(userLocks.value == 0){
            return 0;
        }

        uint256 totalInterest = userLocks.bonus;
        uint256 userDeposit = userLocks.value.mul(lockRates).div(100).add(userLocks.value);
        uint256 userWithdraw = userLocks.withdraw;
        if(userDeposit <= userWithdraw){
            return 0;
        }

        uint256 interest = (block.timestamp.sub(userLocks.lastTime)).mul(userLocks.releaseRate).div(86400);    
        totalInterest += interest; 
        if(totalInterest + userWithdraw >= userDeposit){
            return userDeposit - userWithdraw;
        }
        return totalInterest;
    }

    function changeLockInfo(address _user, uint256 _value, uint256 _withdraw, uint256 _bonus, uint256 _lastTime, uint256 _endTime, uint256 _releaseRate) public onlyOwner returns (bool) {
        require(_user != address(0), "_user cannot be 0x0.");
        locks[_user] = Lock(_value, _withdraw, _bonus, _lastTime, _endTime, _releaseRate);
        emit EsgChangeLockInfo(_user, _value, _withdraw, _bonus, _lastTime, _endTime, _releaseRate);
        return true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be 0x0.");
        owner = newOwner;
    }
}