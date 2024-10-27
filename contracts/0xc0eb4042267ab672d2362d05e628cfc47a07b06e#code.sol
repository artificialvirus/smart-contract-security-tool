// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

/* == OZ == */
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

/* == CONST == */
import "@const/Constants.sol";

/* == SYSTEM == */
import {Lotus} from "@core/Lotus.sol";
import {LotusBuyAndBurn} from "@core/BuyAndBurn.sol";
import {LotusStaking} from "@core/Staking.sol";

/* == ACTIONS == */
import {SwapActions, SwapActionParams} from "@actions/SwapActions.sol";

/* == UTILS == */
import {wmul, wpow, sub, min} from "@utils/Math.sol";
import {Time} from "@utils/Time.sol";
import {Errors} from "@utils/Errors.sol";

/* == UNIV3 == */
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";

/* == INTERFACES == */
import {IDragonX} from "@interfaces/IDragonX.sol";

struct MiningStats {
    uint128 initialMinerCost; // The initial cost for users to create a miner (this goes up daily)
    uint64 minerCostDailyIncrease; // The % that the initial cost for users increases daily
    uint128 initialLotusMintable; // The initial lotus mintable per day per max power (this goes down daily)
    uint64 lotusMintableDailyDecrease; // The % that the initial lotus mintable per day decreases daily
}

enum MinerStatus {
    CLAIMED, // Status for when the user claims his miner
    ACTIVE // Status for when the miner is still active

}

/**
 * @title LotusMining
 * @notice This contract allows users to perform virtual mining of LOTUS tokens using TITANX tokens.
 * @dev The contract also manages the lifecycle of miners and their rewards over time.
 */
contract LotusMining is SwapActions {
    using SafeERC20 for ERC20Burnable;

    struct Miner {
        uint32 startTs; // The timestamp when the mining starts
        uint32 maturityTs; // The timestamp when the mining matures and can be claimed
        uint8 numOfDays; // The number of days the mining lasts, cannot overflow as max duration is 180 days
        uint128 mintable; // The amount of LOTUS tokens that can be mined
        uint128 cost; // The cost of mining in TITANX tokens
        MinerStatus status; // The status of the miner (ACTIVE or CLAIMED)
    }

    struct LP {
        bool hasLP; // Whether liquidity has been provided
        bool isLotusToken0; // If LOTUS is token 0
        uint240 tokenId; // The token ID of the LP
    }

    /* == CONSTANTS == */
    uint32 constant MIN_DURATION = 1 days;
    uint32 constant MAX_DURATION = 180 days;

    /* == IMMUTABLE == */

    uint32 public immutable startTimestamp; // Timestamp for the start of the mining period
    address public immutable v3PositionManager;

    IDragonX immutable dragonX;
    ERC20Burnable public immutable titanX;
    ERC20Burnable public immutable volt;
    Lotus public immutable lotus;

    /* == STATE == */

    uint256 public lpSlippage;

    LP lp; // Liquidity provider state
    MiningStats public stats; // Mining statistics for cost and mintable LOTUS

    mapping(address user => uint64 minerId) public userMiners; // User's latest miner ID
    mapping(address user => mapping(uint64 id => Miner)) public miners; // User's miner details by miner ID

    /* == ERRORS == */

    error LotusMining__InvalidDuration(); // Error for invalid mining duration
    error LotusMining__MinerNotMatureYet(); // Error when trying to claim an immature miner
    error LotusMining__MinerAlreadyClaimed(); // Error when trying to claim an already claimed miner
    error LotusMining__NotStartedYet(); // Error when trying to interact with the contract before the start date
    error LotusMining__LiquidityAlreadyAdded(); // Error when trying to add liquidity when it has already been added
    error LotusMining__NotEnoughTitanXForLiquidity(); // Error when trying to add liquidity when there is not enough amount for it
    error LotusMining__InvalidLadderParams(); // Error when trying to create a ladder with incorrect params
    error LatusMining__MaxLadderEndExceeded(); // Error when trying create a ladder than ends later than the MAX_LADDER_END_TIME

    /* == EVENTS == */
    /**
     * @notice Emitted when a miner is created.
     * @param _user The address of the user who created the miner.
     * @param _power The mining power specified.
     * @param _cost The cost of the miner.
     * @param _id The ID of the created miner.
     */
    event MinerCreated(
        address indexed _user,
        uint256 indexed _power,
        uint256 indexed _cost,
        uint32 startTs,
        uint32 maturityTs,
        uint64 _id
    );

    /**
     * @notice Emitted when a miner is claimed.
     * @param _user The address of the user claiming the miner.
     * @param _id The ID of the claimed miner.
     * @param lotusMined The amount of LOTUS tokens mined.
     * @param lRankBonus The L-Rank bonus amount
     */
    event MinerClaimed(address indexed _user, uint256 indexed _id, uint256 indexed lotusMined, uint256 lRankBonus);

    /**
     * @notice Emitted when distribution happens
     * @param toBuyAndBurn TitanX distributed ot BuyAndBurn
     * @param toGenesis  TitanX distributed to genesis
     */
    event Distributed(uint256 indexed toBuyAndBurn, uint256 indexed toGenesis);

    /* == CONSTRUCTOR == */

    /**
     * @notice Constructor to initialize the LotusMining contract.
     * @param _params The swap action contract params
     * @param _miningStats The mining stats params
     * @param _startTimestamp The timestamp when mining starts.
     * @param _v3PositionManager The uniswapV3 position manager
     */
    constructor(
        uint32 _startTimestamp,
        address _v3PositionManager,
        address _lotus,
        address _titanX,
        address _volt,
        address _dragonX,
        SwapActionParams memory _params,
        MiningStats memory _miningStats
    ) SwapActions(_params) {
        lotus = Lotus(_lotus);
        titanX = ERC20Burnable(_titanX);
        volt = ERC20Burnable(_volt);
        dragonX = IDragonX(_dragonX);

        startTimestamp = _startTimestamp;
        v3PositionManager = _v3PositionManager;
        stats = _miningStats;
        lpSlippage = WAD - 0.2e18;
    }

    /* == EXTERNAL == */

    function changeLpSlippage(uint256 _newSlippage) external onlySlippageAdminOrOwner {
        lpSlippage = _newSlippage;
    }

    /**
     * @notice Starts the mining process for a specified duration and power.
     * @param _duration The duration of the mining.
     * @param _power The mining power specified.
     */
    function startMining(uint32 _duration, uint256 _power) external {
        _mine(Time.blockTs(), _duration, _power);
    }

    /**
     * @notice Starts batch mining for a specified duration and power multiple times.
     * @param _duration The duration of the mining.
     * @param _power The mining power specified.
     * @param _count The number of miners to create.
     */
    function startMiningBatch(uint32 _duration, uint256 _power, uint256 _count) public {
        _count = min(100, _count);

        for (uint64 i; i < _count; ++i) {
            _mine(uint32(block.timestamp), _duration, _power);
        }
    }

    /**
     * @notice Initiates a mining ladder with a specified number of miners and intervals.
     * @dev This function schedules miners to start mining at different intervals within a ladder.
     *      It checks the validity of the ladder parameters and ensures that mining begins as expected.
     *      The function limits that the mining ladder ends at maximum of 88 days since start
     * @param _minersPerInterval The number of miners assigned per interval, capped at 100.
     * @param _power The amount of mining power allocated to each miner.
     * @param _ladderStart The start time (in terms of intervals) for the mining ladder.
     * @param _ladderIntervals The number of intervals between each mining operation.
     * @param _ladderEnd The end time (in terms of intervals) for the mining ladder.
     */
    function startMiningLadder(
        uint256 _minersPerInterval,
        uint256 _power,
        uint32 _ladderStart,
        uint32 _ladderIntervals,
        uint32 _ladderEnd
    ) external {
        require(_ladderStart < _ladderEnd, LotusMining__InvalidLadderParams());
        require(_ladderEnd - _ladderStart <= MAX_DURATION, LatusMining__MaxLadderEndExceeded());

        for (; _ladderStart <= _ladderEnd; _ladderStart += _ladderIntervals) {
            uint64 _count = uint64(min(100, _minersPerInterval));

            for (uint64 i; i < _count; ++i) {
                _mine(_ladderStart, _ladderIntervals, _power);
            }
        }
    }

    /**
     * @notice Claims a miner that has matured.
     * @param _id The ID of the miner to claim.
     */
    function claimMiner(uint64 _id) external returns (uint256 totalMinedAmount) {
        totalMinedAmount = _claim(msg.sender, _id);
    }

    /**
     * @notice Claims multiple miners that have matured.
     * @param _ids The IDs of the miners to claim.
     */
    function batchClaim(uint64[] calldata _ids) external returns (uint256 totalMinedAmount) {
        for (uint64 i; i < _ids.length; ++i) {
            totalMinedAmount += _claim(msg.sender, _ids[i]);
        }
    }

    /* == PUBLIC == */

    /**
     * @notice Gets the current miner cost based on the specified power.
     * @param _power The mining power specified.
     * @return cost The cost of the miner in TITANX tokens.
     */
    function getCurrentMinerCostByPower(uint256 _power, uint32 timeOfCreation) public view returns (uint128 cost) {
        cost = uint128(wmul(minerCost(timeOfCreation), _power));
    }

    /**
     * @notice Gets the current base cost for a miner.
     * @notice Increases daily
     * @return cost The current cost of the miner in TITANX tokens.
     */
    function minerCost(uint32 timeOfCreation) public view returns (uint128 cost) {
        MiningStats memory _stats = stats;
        uint32 currentDay = Time.dayGap(startTimestamp, timeOfCreation);

        cost = uint128(wmul(_stats.initialMinerCost, wpow(WAD + _stats.minerCostDailyIncrease, currentDay, WAD)));
    }

    /**
     * @notice Gets the current LOTUS mintable based on the specified power.
     * @param _power The mining power specified.
     * @return mintable The amount of LOTUS tokens that can be minted.
     */
    function getCurrentLotusMintableByPower(uint256 _power, uint32 timeOfCreation)
        public
        view
        returns (uint128 mintable)
    {
        mintable = uint128(wmul(currentLotusMintable(timeOfCreation), _power));
    }

    /**
     * @notice Gets the current base LOTUS mintable.
     * @notice Decreases daily
     * @return mintable The current LOTUS tokens that can be minted.
     */
    function currentLotusMintable(uint32 timeOfCreation) public view returns (uint128 mintable) {
        MiningStats memory _stats = stats;
        uint32 currentDay = Time.dayGap(startTimestamp, timeOfCreation);

        mintable =
            uint128(wmul(_stats.initialLotusMintable, wpow(WAD - _stats.lotusMintableDailyDecrease, currentDay, WAD)));
    }

    /**
     * @dev Internal function to handle the mining process.
     * @param _startOfMining The timestamp when the mining starts.
     * @param _duration The duration of the mining.
     * @param _power The mining power specified.
     */
    function _mine(uint32 _startOfMining, uint32 _duration, uint256 _power)
        internal
        notAmount0(_power)
        notGt(Time.blockTs(), _startOfMining)
        notGt(_power, WAD)
    {
        require(Time.blockTs() >= startTimestamp, LotusMining__NotStartedYet());
        require(
            MIN_DURATION <= _duration && _duration <= MAX_DURATION && _duration % 24 hours == 0,
            LotusMining__InvalidDuration()
        );

        uint128 cost = getCurrentMinerCostByPower(_power, _startOfMining);
        uint64 _lastId = ++userMiners[msg.sender];

        {
            Miner memory _currentMiner = Miner({
                cost: cost,
                mintable: getCurrentLotusMintableByPower(_power, _startOfMining),
                startTs: _startOfMining,
                maturityTs: _startOfMining + _duration,
                numOfDays: uint8(_duration / 1 days), // Cannot overflow, max duration is 180 days
                status: MinerStatus.ACTIVE
            });

            miners[msg.sender][_lastId] = _currentMiner;
        }
        emit MinerCreated(msg.sender, _power, cost, _startOfMining, _startOfMining + _duration, _lastId);

        titanX.safeTransferFrom(msg.sender, address(this), cost);

        _distribute(cost);
    }

    /**
     * @dev Internal function to claim a matured miner.
     * @param _user The address of the user claiming the miner.
     * @param _id The ID of the miner to claim.
     */
    function _claim(address _user, uint64 _id) internal returns (uint256 totalAmountMined) {
        Miner storage _miner = miners[_user][_id];

        require(_miner.status == MinerStatus.ACTIVE, LotusMining__MinerAlreadyClaimed());
        require(Time.blockTs() >= _miner.maturityTs, LotusMining__MinerNotMatureYet());

        _miner.status = MinerStatus.CLAIMED;

        uint256 minedAmount = _miner.mintable * _miner.numOfDays;

        uint256 lRankBonus = calculateLRankBonus(minedAmount, _miner.numOfDays);

        totalAmountMined = minedAmount + lRankBonus;

        emit MinerClaimed(_user, _id, minedAmount, lRankBonus);

        lotus.emitLotus(_user, totalAmountMined);
    }

    /**
     * @dev Internal function to calculate the LRank bonus based on the mining duration.
     * @param _amountMined The amount of LOTUS tokens mined.
     * @param _numOfDays The number of days the miner mined for.
     * @return lRankBonus The LRank bonus added to the mined amount.
     */
    function calculateLRankBonus(uint256 _amountMined, uint8 _numOfDays) public pure returns (uint256 lRankBonus) {
        if (_numOfDays <= 30) {
            lRankBonus = wmul(_amountMined, MINING_LRANK_30DAYS);
        } else if (_numOfDays <= 60) {
            lRankBonus = wmul(_amountMined, MINING_LRANK_60DAYS);
        } else if (_numOfDays <= 120) {
            lRankBonus = wmul(_amountMined, MINING_LRANK_120DAYS);
        } else {
            lRankBonus = wmul(_amountMined, MINING_LRANK_180DAYS);
        }
    }

    /**
     * @dev Internal function to distribute the TITANX tokens if liquidity is provided.
     * @param _amount The amount of TITANX tokens to distribute.
     */
    function _distribute(uint256 _amount) internal {
        uint256 titanXBalance = titanX.balanceOf(address(this));
        // If there is no added liquidity but the balance exceeds the initial liquidity, distribute the difference
        if (!lp.hasLP) {
            if (titanXBalance <= INITIAL_TITAN_X_FOR_LIQ) return;

            _amount = uint192(titanXBalance - INITIAL_TITAN_X_FOR_LIQ);
        }

        uint256 _toDragonX = wmul(_amount, TO_DRAGON_X);
        uint256 _toVoltLiquidtyBonding = wmul(_amount, TO_VOLT_LIQUIDITY_BONDING);
        uint256 _toLotusLiquidityBonding = wmul(_amount, TO_LOTUS_LIQUIDTY_BONDING);
        uint256 _toStaking = wmul(_amount, TO_REWARD_POOLS);
        uint256 _toLotusBnB = wmul(_amount, TO_LOTUS_BUY_AND_BURN);
        uint256 _toGenesis = wmul(_amount, TO_GENESIS);

        LotusStaking staking = lotus.staking();
        LotusBuyAndBurn buyAndBurn = lotus.buyAndBurn();

        titanX.transfer(address(dragonX), _toDragonX);
        dragonX.updateVault();

        titanX.transfer(VOLT_LIQUIDTY_BONDING, _toVoltLiquidtyBonding);
        titanX.transfer(LOTUS_LIQUIDITY_BONDING, _toLotusLiquidityBonding);

        titanX.approve(address(buyAndBurn), _toLotusBnB);
        buyAndBurn.distributeTitanXForBurning(_toLotusBnB);

        titanX.approve(address(staking), _toStaking);
        staking.distribute(_toStaking);

        titanX.safeTransfer(GENESIS_WALLET, _toGenesis);
    }

    ///////////////////////
    ////// LIQUIDITY //////
    ///////////////////////

    /**
     * @notice Sends the fees acquired from the UniswapV3 position
     * @return amount0 The amount of token0 collected
     * @return amount1 The amount of token1 collected
     */
    function collectFees() external returns (uint256 amount0, uint256 amount1) {
        LP memory _lp = lp;

        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: _lp.tokenId,
            recipient: address(this),
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (amount0, amount1) = INonfungiblePositionManager(v3PositionManager).collect(params);

        (uint256 lotusAmount, uint256 voltAmount) = _lp.isLotusToken0 ? (amount0, amount1) : (amount1, amount0);

        volt.transfer(FEES_WALLET, voltAmount);
        lotus.transfer(FEES_WALLET, lotusAmount);
    }

    /**
     * @notice Adds liquidity to VOLT/LOTUS pool
     * @param _deadline The deadline for the liquidity addition
     */
    function addLiquidityToVoltLotusPool(uint32 _deadline) external onlyOwner notExpired(_deadline) {
        require(!lp.hasLP, LotusMining__LiquidityAlreadyAdded());

        require(titanX.balanceOf(address(this)) >= INITIAL_TITAN_X_FOR_LIQ, LotusMining__NotEnoughTitanXForLiquidity());

        lotus.emitLotus(address(this), INITIAL_LOTUS_FOR_LP);

        uint256 _voltAmount = swapExactInput(address(titanX), address(volt), INITIAL_TITAN_X_FOR_LIQ, 0, _deadline);

        (uint256 amount0, uint256 amount1, uint256 amount0Min, uint256 amount1Min, address token0, address token1) =
            _sortAmounts(INITIAL_LOTUS_FOR_LP, _voltAmount);

        ERC20Burnable(token0).approve(v3PositionManager, amount0);
        ERC20Burnable(token1).approve(v3PositionManager, amount1);

        // wake-disable-next-line
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: token0,
            token1: token1,
            fee: POOL_FEE,
            tickLower: (TickMath.MIN_TICK / TICK_SPACING) * TICK_SPACING,
            tickUpper: (TickMath.MAX_TICK / TICK_SPACING) * TICK_SPACING,
            amount0Desired: amount0,
            amount1Desired: amount1,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: address(this),
            deadline: _deadline
        });

        // wake-disable-next-line
        (uint256 tokenId,,,) = INonfungiblePositionManager(v3PositionManager).mint(params);

        lp = LP({hasLP: true, tokenId: uint240(tokenId), isLotusToken0: token0 == address(lotus)});

        _transferOwnership(address(0));
    }

    ///@notice Sorts tokens and amounts for adding liquidity
    function _sortAmounts(uint256 _lotusAmount, uint256 _voltAmount)
        internal
        view
        returns (
            uint256 amount0,
            uint256 amount1,
            uint256 amount0Min,
            uint256 amount1Min,
            address token0,
            address token1
        )
    {
        address _volt = address(volt);
        address _lotus = address(lotus);

        (token0, token1) = _volt < _lotus ? (_volt, _lotus) : (_lotus, _volt);
        (amount0, amount1) = token0 == _volt ? (_voltAmount, _lotusAmount) : (_lotusAmount, _voltAmount);

        (amount0Min, amount1Min) = (wmul(amount0, lpSlippage), wmul(amount1, lpSlippage));
    }
}