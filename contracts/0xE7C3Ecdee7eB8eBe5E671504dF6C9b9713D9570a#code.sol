// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/* @title ScribblePartyProceedsManager
 * @author minimizer <[email protected]>; https://www.minimizer.art/
 * 
 * This is a helper contract for Scribble Party, a project to be released on Plottables.
 * Scribble Party is an experiment where each mint contributes to a prize pool, which the last minter 
 * can claim. A countdown timer determines when the project ends and who the last minter is. 
 * Each mint extends this countdown timer. 
 * 
 * As minting progresses the portion of each mint that is contributed to the pool reduces, and the time
 * which each mint extends countdown is reduced. This encourages the project to eventually end and for
 * the prize to be claimable.
 * 
 * 
 * This contract is responsible for:
 *   - collecting primary sales proceeds for the project (the "palette pool")
 *   - tracking which portion goes to the artist and which portion goes to the pool
 *   - managing the countdown timer, and refusing any further payment (thereby blocking further mints) 
 *   - when the countdown timer has passed
 *   - allowing the artist to withdraw the non-prize portion of proceeds
 *   - allowing the final holder of the final mint to withdraw the price portion of proceeds
 *   - sharing information about current state for the Plottables UI
 * 
 * 
 * Inputs for this contract are:
 *   - ArtBlocks settings: contract address and project id
 *   - Mint configuration: 
 *              initialPrizePortionBasisPoints, prizePortionHalveningNumMints, 
 *              initialTimeExtensionSeconds, timeExtensionHalveningNumMints
 * 
 * 
 * Stages of the process are:
 * 1) Initialization - the contract is deployed pointing to the specific ArtBlocks contract and project id
 * 2) Minting - while the primary sales occur, this contract can receive funds and calculate portions to 
 *    artist and prize pool, and extend timer
 * 3) Conclusion - one timer is depleted, contract will no longer accept funds and will only allow withdrawal
 * 
 */


import { Ownable } from '@openzeppelin-4.7/contracts/access/Ownable.sol';
import { Math } from '@openzeppelin-4.7/contracts/utils/math/Math.sol';
import { IERC721 } from '@openzeppelin-4.7/contracts/token/ERC721/IERC721.sol';
import { IGenArt721CoreContractV3_Engine } from '@artblocks/contracts/contracts/interfaces/v0.8.x/IGenArt721CoreContractV3_Engine.sol';
import { GenArt721CoreV3_Engine } from '@artblocks/contracts/contracts/engine/V3/GenArt721CoreV3_Engine.sol';
import { IMinterFilterV1 } from '@artblocks/contracts/contracts/interfaces/v0.8.x/IMinterFilterV1.sol';

contract ScribblePartyProceedsManager is Ownable {
    
    struct ArtBlocksConfiguration {
        address engineContract;
        uint projectId;
        address minterContract;
    }
    
    struct MintConfiguration {
        uint initialPrizePortionBasisPoints;
        uint prizePortionHalveningNumMints;
        uint initialTimeExtensionSeconds;
        uint timeExtensionHalveningNumMints;
        uint startingTokenId;
    }
    
    struct MintStatus {
        bool started;
        uint endTime;
        bool finished;
        uint nextMintPrizePortionBasisPoints;
        uint nextMintTimeExtensionSeconds;
        address latestMintOwner;
        uint prizeAmount;
        bool prizeWithdrawn;
    }
    
    ArtBlocksConfiguration public artblocksConfiguration;
    MintConfiguration public mintConfiguration;
    
    uint private endTime;
    uint private prizeAmount;
    bool private prizeWithdrawn;
    
    constructor(address _plottablesContract, uint _projectId, 
                uint _initialPrizePortionBasisPoints, uint _prizePortionHalveningNumMints,
                uint _initialTimeExtensionSeconds, uint _timeExtensionHalveningNumMints) 
    Ownable() 
    {
        require(IGenArt721CoreContractV3_Engine(_plottablesContract).projectIdToArtistAddress(_projectId) == msg.sender, 'Deployer must be project artist');
        
        artblocksConfiguration = ArtBlocksConfiguration(
            _plottablesContract,
            _projectId,
            IMinterFilterV1(GenArt721CoreV3_Engine(_plottablesContract).minterContract()).getMinterForProject(_projectId, address(_plottablesContract))
        );
        
        mintConfiguration = MintConfiguration(
            _initialPrizePortionBasisPoints,
            _prizePortionHalveningNumMints,
            _initialTimeExtensionSeconds,
            _timeExtensionHalveningNumMints,
            0
        );
    }
    
    
    receive() external payable { 
        require(!finished(), 'Minting is closed');
        require(msg.sender == artblocksConfiguration.minterContract, 'Can only receive from minter');
        bool alreadyStarted = started();
        if(alreadyStarted || tx.origin != owner()) {
            if(!alreadyStarted) {
                mintConfiguration.startingTokenId = latestTokenId();
            }
            
            uint mintCount = mintsSoFar();
            prizeAmount += msg.value * mintPrizePortionBasisPointsAtMintCount(mintCount) / 10000;
            endTime = Math.max(endTime, block.timestamp + timeExtensionSecondsAtMintCount(mintCount));
        }
    }
    
    function status() public view returns (MintStatus memory currentStatus) {
        currentStatus.started = started();
        currentStatus.endTime = endTime;
        currentStatus.finished = finished();
        
        if(!currentStatus.finished) {
            uint nextMint = mintsSoFar() + 1;
            currentStatus.nextMintPrizePortionBasisPoints = mintPrizePortionBasisPointsAtMintCount(nextMint);
            currentStatus.nextMintTimeExtensionSeconds = timeExtensionSecondsAtMintCount(nextMint);
        }
        
        currentStatus.latestMintOwner = latestMintOwnerAddress();
        currentStatus.prizeAmount = prizeAmount;
        currentStatus.prizeWithdrawn = prizeWithdrawn;
    }
    
    function withdrawPrize() public {
        require(finished(), 'Minting still active');
        require(msg.sender == latestMintOwnerAddress(), 'Not holder of final token');
        require(!prizeWithdrawn, 'Prize already withdrawn');
        
        prizeWithdrawn = true;
        sendToMsgSender(prizeAmount);
    }
    
    function withdrawProceeds() public onlyOwner {
        uint withdrawalAmount = address(this).balance - (prizeWithdrawn ? 0 : prizeAmount);
        sendToMsgSender(withdrawalAmount);
    }
    
    
    
    
    
    
    function started() private view returns (bool) {
        return endTime > 0;
    }
    
    function finished() private view returns (bool) {
        return started() && endTime < block.timestamp;
    }
    
    function numInvocations() private view returns (uint) {
        (uint invocations, , , , , ) = IGenArt721CoreContractV3_Engine(artblocksConfiguration.engineContract).projectStateData(artblocksConfiguration.projectId);
        return invocations;
    }
    
    function latestTokenId() private view returns (uint) {
        return artblocksConfiguration.projectId * 1e6 + numInvocations() - 1;
    }
    
    function latestMintOwnerAddress() private view returns (address) {
        if(!started()) {
            return address(0);
        } else {
            return IERC721(artblocksConfiguration.engineContract).ownerOf(latestTokenId());
        }
    }
    
    function mintsSoFar() private view returns (uint) {
        return started() ? latestTokenId() - mintConfiguration.startingTokenId : 0;
    }
    
    function mintPrizePortionBasisPointsAtMintCount(uint mintCount) private view returns (uint) {
        return applyHalvening(mintConfiguration.initialPrizePortionBasisPoints, mintConfiguration.prizePortionHalveningNumMints, mintCount);
    }
    
    function timeExtensionSecondsAtMintCount(uint mintCount) private view returns (uint) {
        return applyHalvening(mintConfiguration.initialTimeExtensionSeconds, mintConfiguration.timeExtensionHalveningNumMints, mintCount);
    }
    
    
    function applyHalvening(uint initialValue, uint halveningNumMints, uint mintCount) private pure returns (uint) {
        while(mintCount >= halveningNumMints) {
            mintCount -= halveningNumMints;
            initialValue /= 2;
        }
        return initialValue;
    }
    
    function sendToMsgSender(uint amount) private {
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send");
    }
}