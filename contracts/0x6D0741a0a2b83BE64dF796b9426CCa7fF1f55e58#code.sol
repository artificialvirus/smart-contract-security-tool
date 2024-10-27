// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import "erc721a/contracts/IERC721A.sol";
import "./StakingUpgradable.sol";
import "./interfaces/IStakedToken.sol";

contract StakingUpgradableV2 is StakingUpgradable, EIP712Upgradeable {
    address public signer;
    IERC721A public ancientSeed;
    IERC721A public mythicSeed;
    IERC721A public synergySeed;
    IStakedToken public stakedAncientSeed;
    IStakedToken public stakedMythicSeed;
    IStakedToken public stakedSynergySeed;
    mapping(address => uint256) public withdrawNonces;

    enum SeedType {
        AncientSeed,
        MythicSeed,
        SynergySeed
    }

    struct WithdrawRequest {
        uint256 nonce;
        uint256[] ancientSeedIds;
        uint256[] mythicSeedIds;
        uint256[] synergySeedIds;
        uint256 expiresAtBlock;
    }

    event StakeSeed(
        address indexed account,
        uint256 tokenId,
        SeedType seedType,
        uint256 stakeTimestamp
    );

    event WithdrawSeed(
        address indexed account,
        uint256 tokenId,
        SeedType seedType
    );

    bytes32 private constant WITHDRAW_REQUEST_TYPE_HASH =
        keccak256(
            "WithdrawRequest(uint256 nonce,uint256[] ancientSeedIds,uint256[] mythicSeedIds,uint256[] synergySeedIds,uint256 expiresAtBlock)"
        );

    constructor() {
        _disableInitializers();
    }

    function initializeV2(
        address signer_,
        address ancientSeedAddress_,
        address mythicSeedAddress_,
        address synergySeedAddress_,
        address stakedAncientSeedAddress_,
        address stakedMythicSeedAddress_,
        address stakedSynergySeedAddress_
    ) external reinitializer(2) {
        __EIP712_init("THE-GARDEN-STAKING", "0.1.0");
        signer = signer_;
        ancientSeed = IERC721A(ancientSeedAddress_);
        mythicSeed = IERC721A(mythicSeedAddress_);
        synergySeed = IERC721A(synergySeedAddress_);
        stakedAncientSeed = IStakedToken(stakedAncientSeedAddress_);
        stakedMythicSeed = IStakedToken(stakedMythicSeedAddress_);
        stakedSynergySeed = IStakedToken(stakedSynergySeedAddress_);
    }

    function stake(
        uint256[] calldata ancientSeedIds,
        uint256[] calldata mythicSeedIds,
        uint256[] calldata synergySeedIds
    ) external nonReentrant whenNotPaused {
        for (uint256 i = 0; i < ancientSeedIds.length; i++) {
            uint256 tokenId = ancientSeedIds[i];
            address owner = ancientSeed.ownerOf(tokenId);
            ancientSeed.transferFrom(owner, address(this), tokenId);
            stakedAncientSeed.ensureOwnership(owner, tokenId);
            emit StakeSeed(
                owner,
                tokenId,
                SeedType.AncientSeed,
                block.timestamp
            );
        }

        for (uint256 i = 0; i < mythicSeedIds.length; i++) {
            uint256 tokenId = mythicSeedIds[i];
            address owner = mythicSeed.ownerOf(tokenId);
            mythicSeed.transferFrom(owner, address(this), tokenId);
            stakedMythicSeed.ensureOwnership(owner, tokenId);
            emit StakeSeed(
                owner,
                tokenId,
                SeedType.MythicSeed,
                block.timestamp
            );
        }

        for (uint256 i = 0; i < synergySeedIds.length; i++) {
            uint256 tokenId = synergySeedIds[i];
            address owner = synergySeed.ownerOf(tokenId);
            synergySeed.transferFrom(owner, address(this), tokenId);
            stakedSynergySeed.ensureOwnership(owner, tokenId);
            emit StakeSeed(
                owner,
                tokenId,
                SeedType.SynergySeed,
                block.timestamp
            );
        }
    }

    function withdraw(
        WithdrawRequest calldata request_,
        bytes calldata signature_
    ) external whenAuthorized(request_, signature_) nonReentrant whenNotPaused {
        withdrawNonces[msg.sender]++;
        for (uint256 i = 0; i < request_.ancientSeedIds.length; i++) {
            uint256 tokenId = request_.ancientSeedIds[i];
            ancientSeed.transferFrom(address(this), msg.sender, tokenId);
            stakedAncientSeed.transferFrom(msg.sender, address(this), tokenId);
            emit WithdrawSeed(msg.sender, tokenId, SeedType.AncientSeed);
        }

        for (uint256 i = 0; i < request_.mythicSeedIds.length; i++) {
            uint256 tokenId = request_.mythicSeedIds[i];
            mythicSeed.transferFrom(address(this), msg.sender, tokenId);
            stakedMythicSeed.transferFrom(msg.sender, address(this), tokenId);
            emit WithdrawSeed(msg.sender, tokenId, SeedType.MythicSeed);
        }

        for (uint256 i = 0; i < request_.synergySeedIds.length; i++) {
            uint256 tokenId = request_.synergySeedIds[i];
            synergySeed.transferFrom(address(this), msg.sender, tokenId);
            stakedSynergySeed.transferFrom(msg.sender, address(this), tokenId);
            emit WithdrawSeed(msg.sender, tokenId, SeedType.SynergySeed);
        }
    }

    function setSigner(address signer_) external onlyOwner {
        signer = signer_;
    }

    function setLockDurations(
        uint256[] calldata ids_,
        uint256[] calldata durations_
    ) external onlyOwner {
        require(ids_.length == durations_.length, "Invalid request");
        for (uint256 i; i < ids_.length; i++) {
            lockDurations[ids_[i]] = durations_[i];
        }
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function domainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _hashTypedData(
        WithdrawRequest calldata request_
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    WITHDRAW_REQUEST_TYPE_HASH,
                    request_.nonce,
                    keccak256(abi.encodePacked(request_.ancientSeedIds)),
                    keccak256(abi.encodePacked(request_.mythicSeedIds)),
                    keccak256(abi.encodePacked(request_.synergySeedIds)),
                    request_.expiresAtBlock
                )
            );
    }

    modifier whenAuthorized(
        WithdrawRequest calldata request_,
        bytes calldata signature_
    ) {
        require(
            request_.nonce == withdrawNonces[msg.sender] + 1,
            "Invalid nonce"
        );
        bytes32 structHash = _hashTypedData(request_);
        bytes32 digest = _hashTypedDataV4(structHash);
        address recoveredSigner = ECDSAUpgradeable.recover(digest, signature_);
        require(recoveredSigner == signer, "Unauthorized withdraw");
        require(request_.expiresAtBlock > block.number, "Expired signature");
        _;
    }
}