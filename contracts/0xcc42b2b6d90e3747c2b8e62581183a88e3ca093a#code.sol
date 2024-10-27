// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/* === OZ === */
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/* = SYSTEM =  */
import {LotusMining, MiningStats} from "./Mining.sol";
import {LotusBuyAndBurn} from "./BuyAndBurn.sol";
import {LotusStaking} from "./Staking.sol";

/* == ACTIONS == */
import {SwapActionParams} from "./actions/SwapActions.sol";

/* = UNIV3 = */
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {INonfungiblePositionManager} from "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import {IQuoter} from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

/* LIBS == */
import {PoolAddress} from "@uniswap/v3-periphery/contracts/libraries/PoolAddress.sol";
import {OracleLibrary} from "@libs/OracleLibrary.sol";

/* == UTILS ==  */
import {sqrt} from "@utils/Math.sol";

/* = CONST = */
import "@const/Constants.sol";

/**
 * @title Lotus
 * @dev ERC20 token contract for LOTUS tokens.
 */
contract Lotus is ERC20Burnable, Ownable {
    //========IMMUTABLES========//

    address public immutable pool;
    LotusMining public mining;
    LotusStaking public staking;
    LotusBuyAndBurn public buyAndBurn;

    //===========ERRORS===========//

    error Lotus__OnlyMining();

    //=======CONSTRUCTOR=========//

    constructor(address _v3PositionManager, address _titanX, address _volt, address _v3Quoter)
        ERC20("LOTUS", "LOTUS")
        Ownable(msg.sender)
    {
        _mint(LOTUS_LIQUIDITY_BONDING, 33_333_340e18);
        pool = _createUniswapV3Pool(_titanX, _volt, _v3Quoter, _v3PositionManager);
    }

    //=======MODIFIERS=========//

    modifier onlyMining() {
        _onlyMining();
        _;
    }

    function setBnB(LotusBuyAndBurn _bnb) external onlyOwner {
        buyAndBurn = _bnb;
    }

    function setStaking(LotusStaking _staking) external onlyOwner {
        staking = _staking;
    }

    function setMining(LotusMining _mining) external onlyOwner {
        mining = _mining;
    }

    //==========================//
    //==========PUBLIC==========//
    //==========================//

    function emitLotus(address _receiver, uint256 _amount) external onlyMining {
        _mint(_receiver, _amount);
    }

    //==========================//
    //=========INTERNAL=========//
    //==========================//

    function _createUniswapV3Pool(
        address _titanX,
        address _volt,
        address UNISWAP_V3_QUOTER,
        address UNISWAP_V3_POSITION_MANAGER
    ) internal returns (address _pool) {
        address _lotus = address(this);

        IQuoter quoter = IQuoter(UNISWAP_V3_QUOTER);

        bytes memory path = abi.encodePacked(address(_titanX), POOL_FEE, address(_volt));

        uint256 voltAmount = quoter.quoteExactInput(path, INITIAL_TITAN_X_FOR_LIQ);

        uint256 lotusAmount = INITIAL_LOTUS_FOR_LP;

        (address token0, address token1) = _lotus < _volt ? (_lotus, _volt) : (_volt, _lotus);

        (uint256 amount0, uint256 amount1) = token0 == _volt ? (voltAmount, lotusAmount) : (lotusAmount, voltAmount);

        uint160 sqrtPX96 = uint160((sqrt((amount1 * 1e18) / amount0) * 2 ** 96) / 1e9);

        INonfungiblePositionManager manager = INonfungiblePositionManager(UNISWAP_V3_POSITION_MANAGER);

        _pool = manager.createAndInitializePoolIfNecessary(token0, token1, POOL_FEE, sqrtPX96);

        IUniswapV3Pool(_pool).increaseObservationCardinalityNext(uint16(100));
    }

    function _onlyMining() internal view {
        require(msg.sender == address(mining), Lotus__OnlyMining());
    }
}