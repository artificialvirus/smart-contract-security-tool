// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Create2} from "openzeppelin-contracts/contracts/utils/Create2.sol";
import {FairLaunchLimitAmountToken} from "./FairLaunchLimitAmount.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {IFairLaunch, FairLaunchLimitAmountStruct} from "./IFairLaunch.sol";

/**
To new issuers, in order to avoid this situation, 
please use the factory contract to deploy the Token contract when deploying new contracts in the future. 

Please use a new address that has not actively initiated transactions on any chain to deploy. 
The factory contract can create the same address on each evm chain through the create2 function. 
If a player transfers ETHs to the wrong chain, you can also help the player get his ETH back by refunding his money by deploying a contract on a specific chain.
 */
contract FairLaunchLimitAmountFactory is IFairLaunch, ReentrancyGuard {
    uint256 public price;
    address public owner;
    address public feeTo;

    uint256 public constant FAIR_LAUNCH_LIMIT_AMOUNT = 1;
    uint256 public constant FAIR_LAUNCH_LIMIT_BLOCK = 2;

    address public immutable locker;

    mapping(address => bool) public allowlist;

    // owner modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(
        address _feeTo,
        address _locker,
        address _positionManager,
        address _factory
    ) {
        owner = msg.sender;
        locker = _locker;

        allowlist[_positionManager] = true;
        allowlist[_factory] = true;

        feeTo = _feeTo;
    }

    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setFeeTo(address _feeTo) public onlyOwner {
        feeTo = _feeTo;
    }

    function getTokenAddress(
        uint256 salt,
        uint24 _poolFee,
        address _projectOwner,
        FairLaunchLimitAmountStruct memory params
    ) public view returns (address) {
        bytes32 _salt = keccak256(abi.encodePacked(salt));

        return
            Create2.computeAddress(
                _salt,
                keccak256(
                    abi.encodePacked(
                        type(FairLaunchLimitAmountToken).creationCode,
                        abi.encode(locker, _poolFee, _projectOwner, params)
                    )
                )
            );
    }

    function deployToken(
        uint256 salt,
        uint24 _poolFee,
        FairLaunchLimitAmountStruct memory params
    ) public payable nonReentrant {
        if (feeTo != address(0) && price > 0) {
            require(msg.value >= price, "insufficient price");

            (bool success, ) = payable(feeTo).call{value: msg.value}("");
            require(success, "Transfer failed.");
        }

        require(msg.sender == tx.origin, "only eoa");

        require(
            allowlist[params.uniswapFactory] && allowlist[params.uniswapRouter],
            "Uniswap factory or router should be in allowlist."
        );

        bytes32 _salt = keccak256(abi.encodePacked(salt));
        bytes memory bytecode = abi.encodePacked(
            type(FairLaunchLimitAmountToken).creationCode,
            abi.encode(locker, _poolFee, msg.sender, params)
        );
        address addr = Create2.deploy(0, _salt, bytecode);
        emit Deployed(addr, FAIR_LAUNCH_LIMIT_AMOUNT);
    }
}
// WRB