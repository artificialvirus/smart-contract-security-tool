// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.6;

/**
 * Otacon is the World's 1st Artificial Intelligence and Peer-to-Peer Bug Bounty Hunting experience.
 */

// Import statements
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// Uniswap V3 Interfaces
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/**
 * @dev Interface for the ProofCollectible contract.
 */
interface IProofCollectible is IERC721 {
    struct BugInfo {
        address targetSmartContract;
        uint8 severity;
        bytes32 targetFunction;
        bytes32 targetDescription;
        bytes32 targetNetwork;
        bytes32 targetEnvironment;
    }

    function getBugInfo(uint256 tokenId) external view returns (BugInfo memory);

    function grantWhitelistAccess(uint256 tokenId, address user) external;

    function revokeWhitelistAccess(uint256 tokenId, address user) external;

    function isWhitelisted(uint256 tokenId, address user)
        external
        view
        returns (bool);

    function burn(uint256 tokenId) external;
}

/**
 * @dev Interface for the SnippetCollectible contract (ERC721).
 * An Otacon Snippet is a code snippet collectible acting as a proof of concept for a vulnerability submitted to a bug bounty program.
 */
interface ISnippetCollectible is IERC721 {
    function burn(uint256 tokenId) external;
}

/**
 * @dev Interface for the BountyPassCollectible contract (ERC1155).
 * An Otacon Bounty Pass is a semi-fungible collectible allowing the creation of a bug bounty program.
 */
interface IBountyPassCollectible is IERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;
}

/**
 * @dev Interface for the MultiplierCollectible contract (ERC1155).
 * An Otacon Multiplier is a semi-fungible collectible allowing the weighted distribution of bug bounty rewards across Otacon stakeholders.
 */
interface IMultiplierCollectible is IERC1155 {
    function burn(
        address account,
        uint256 id,
        uint256 value
    ) external;
}

/**
 * @title OtaconBountyRegistry
 * @notice Contract for managing bounties, staking collectibles, distributing rewards.
 */
contract OtaconBountyRegistry is
    Ownable,
    ReentrancyGuard,
    IERC1155Receiver,
    IERC721Receiver,
    ERC165
{
    using SafeERC20 for IERC20;

    uint256 public otaconFee = 100000 * 1e18; // 100,000 OTACON
    uint256 public ethFee = 1 ether; // 1 ETH
    uint256 public nextBountyId = 1336;
    uint8 public protocolFeePercentage = 20; // Protocol fee expressed as a percentage (e.g., 20%)

    IERC20 public immutable otaconToken;

    // Collectible contracts
    IProofCollectible public proofCollectible;
    ISnippetCollectible public snippetCollectible; // ERC721
    IBountyPassCollectible public bountyPassCollectible; // ERC1155

    // Multiplier tiers correspond to collectibleType IDs in the MultiplierCollectible ERC1155 contract
    enum MultiplierTier {
        S,
        A,
        B,
        C,
        D,
        F
    }

    struct MultiplierCollectibleInfo {
        IMultiplierCollectible token;
        uint256 multiplierValue; // Fixed-point uint256, e.g., 2e18 for 2x
        uint256 collectibleType; // Token ID in the ERC1155 contract
    }

    mapping(MultiplierTier => MultiplierCollectibleInfo)
        public multiplierCollectibles;

    struct StakedProofCollectible {
        uint256 tokenId;
        address staker;
    }

    struct StakedSnippetCollectible {
        uint256 tokenId;
        address staker;
    }

    struct StakedMultiplierCollectible {
        MultiplierTier tier;
        uint256 amount;
    }

    struct Bounty {
        bool isActive;
        bool requireSnippet; // Proof of Concept requirement for vulnerabilities
        address owner; // Manager of the bounty program
        address targetContract; // Target of vulnerability scans
        IERC20 rewardToken; // Bounty rewards currency
        mapping(uint8 => uint256) rewards; // severity => reward
        mapping(address => bool) validators;
        address[] validatorList; // List of validators
        mapping(uint256 => StakedProofCollectible) stakedProofs; // proofCollectibleId => StakedProofCollectible
        mapping(uint256 => StakedSnippetCollectible) stakedSnippets; // snippetCollectibleId => StakedSnippetCollectible
        mapping(address => StakedMultiplierCollectible) stakedMultipliers; // staker address => StakedMultiplierCollectible
        uint256 totalMultiplierValueStaked; // Total multiplier value staked to the bounty
        mapping(address => bool) multiplierHasClaimed; // staker address => whether they have claimed
        mapping(address => bool) hasStakedProof; // hunter address => whether they have staked a proof
        uint256 totalProtocolBountyReward; // Total protocol bounty rewards accumulated
        uint256 totalProtocolRewardClaimed; // Total protocol bounty rewards claimed
        bytes32 targetNetwork; // e.g. ethereum
        bytes32 targetEnvironment; // e.g. testnet
    }

    struct BountyInfo {
        uint256 bountyId;
        bool isActive;
        bool requireSnippet;
        address owner;
        address targetContract;
        IERC20 rewardToken;
        uint256[4] rewards;
        address[] validators;
        uint256 totalProtocolBountyReward;
        uint256 totalProtocolRewardClaimed;
        uint256 totalMultiplierValueStaked;
        bytes32 targetNetwork;
        bytes32 targetEnvironment;
    }

    mapping(uint256 => Bounty) public bounties;

    // Keep track of reward tokens held by the contract that are owed to users
    mapping(address => uint256) public totalUnclaimedProtocolRewards; // rewardToken address => amount

    // Uniswap V3 Router and WETH9 addresses
    ISwapRouter public immutable swapRouter;
    address public immutable WETH9;
    uint24 public constant poolFee = 3000; // Pool fee for OTACON/ETH pool (0.3%)

    event FeeUpdated(string feeType, uint256 fee);
    event ProtocolFeePercentageUpdated(uint8 feePercentage);
    event BountyRewardUpdated(
        uint256 indexed bountyId,
        uint8 severity,
        uint256 reward
    );
    event BountyStarted(
        uint256 indexed bountyId,
        address indexed owner,
        address targetContract,
        address rewardToken
    );
    event BountyStopped(uint256 indexed bountyId);
    event ProofCollectibleStaked(
        uint256 indexed bountyId,
        uint256 collectibleId,
        address indexed staker
    );
    event ProofCollectibleUnstaked(
        uint256 indexed bountyId,
        uint256 collectibleId,
        address indexed staker
    );
    event SnippetCollectibleStaked(
        uint256 indexed bountyId,
        uint256 collectibleId,
        address indexed staker
    );
    event SnippetCollectibleUnstaked(
        uint256 indexed bountyId,
        uint256 collectibleId,
        address indexed staker
    );
    event MultiplierCollectibleStaked(
        uint256 indexed bountyId,
        address indexed staker,
        MultiplierTier tier,
        uint256 amount
    );
    event MultiplierCollectibleUnstaked(
        uint256 indexed bountyId,
        address indexed staker,
        MultiplierTier tier,
        uint256 amount
    );
    event MultiplierCollectibleUpdated(
        MultiplierTier tier,
        address tokenAddress,
        uint256 multiplierValue,
        uint256 collectibleType
    );
    event CollectibleContractUpdated(string collectibleType, address token);
    event ProofValidated(
        uint256 indexed bountyId,
        uint8 severity,
        address indexed bountyHunter,
        uint256 hunterReward,
        uint256 protocolBountyReward
    );
    event ValidatorAdded(uint256 indexed bountyId, address indexed validator);
    event ValidatorRemoved(uint256 indexed bountyId, address indexed validator);
    event BountyShareClaimed(
        uint256 indexed bountyId,
        address indexed claimant,
        uint256 share
    );
    event OtaconPurchased(address buyer, uint256 amountIn, uint256 amountOut);

    /**
     * @notice Initializes the contract with required parameters.
     */
    constructor() Ownable(msg.sender) ReentrancyGuard() {
        otaconToken = IERC20(0x0F17eeCcc84739b9450C88dE0429020e2DEC05eb);
        swapRouter = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        transferOwnership(msg.sender);
    }

    // Modifiers

    modifier onlyBountyOwner(uint256 bountyId) {
        require(bounties[bountyId].owner == msg.sender, "Not the bounty owner");
        _;
    }

    // Collectibles Management

    /**
     * @notice Updates the proof collectible contract address.
     * @param tokenAddress The address of the proof collectible contract.
     */
    function setProofCollectibleContract(address tokenAddress)
        external
        onlyOwner
    {
        require(tokenAddress != address(0), "Invalid token address");
        proofCollectible = IProofCollectible(tokenAddress);
        emit CollectibleContractUpdated("Proof", tokenAddress);
    }

    /**
     * @notice Updates the snippet collectible contract address.
     * @param tokenAddress The address of the snippet collectible contract.
     */
    function setSnippetCollectibleContract(address tokenAddress)
        external
        onlyOwner
    {
        require(tokenAddress != address(0), "Invalid token address");
        snippetCollectible = ISnippetCollectible(tokenAddress);
        emit CollectibleContractUpdated("Snippet", tokenAddress);
    }

    /**
     * @notice Updates the bounty pass collectible contract address.
     * @param tokenAddress The address of the bounty pass collectible contract.
     */
    function setBountyPassCollectibleContract(address tokenAddress)
        external
        onlyOwner
    {
        require(tokenAddress != address(0), "Invalid token address");
        bountyPassCollectible = IBountyPassCollectible(tokenAddress);
        emit CollectibleContractUpdated("BountyPass", tokenAddress);
    }

    /**
     * @notice Updates the multiplier collectible for a specific tier.
     * @param tier The multiplier tier (S to F).
     * @param tokenAddress The address of the multiplier collectible contract.
     * @param multiplierValue The multiplier value (e.g., 2e18 for 2x).
     * @param collectibleType The token ID representing this tier in the ERC1155 contract.
     */
    function setMultiplierCollectible(
        MultiplierTier tier,
        address tokenAddress,
        uint256 multiplierValue,
        uint256 collectibleType
    ) external onlyOwner {
        require(tokenAddress != address(0), "Invalid token address");
        require(multiplierValue >= 1e18, "Multiplier must be >= 1x");
        multiplierCollectibles[tier] = MultiplierCollectibleInfo(
            IMultiplierCollectible(tokenAddress),
            multiplierValue,
            collectibleType
        );
        emit MultiplierCollectibleUpdated(
            tier,
            tokenAddress,
            multiplierValue,
            collectibleType
        );
    }

    // Validator Management

    /**
     * @notice Adds a validator to a bounty.
     * @param bountyId The ID of the bounty.
     * @param validator The address of the validator.
     */
    function addValidator(uint256 bountyId, address validator) public {
        require(bounties[bountyId].isActive, "Bounty is not active");
        Bounty storage bounty = bounties[bountyId];
        require(
            msg.sender == bounty.owner || msg.sender == owner(),
            "Not authorized"
        );
        if (!bounty.validators[validator]) {
            bounty.validators[validator] = true;
            bounty.validatorList.push(validator);
            emit ValidatorAdded(bountyId, validator);
        }
    }

    /**
     * @notice Removes a validator from a bounty.
     * @param bountyId The ID of the bounty.
     * @param validator The address of the validator.
     */
    function removeValidator(uint256 bountyId, address validator) public {
        Bounty storage bounty = bounties[bountyId];
        require(
            msg.sender == bounty.owner || msg.sender == owner(),
            "Not authorized"
        );
        require(bounty.validators[validator], "Validator does not exist");
        delete bounty.validators[validator];
        // Remove validator from validatorList
        uint256 validatorCount = bounty.validatorList.length;
        for (uint256 i = 0; i < validatorCount; i++) {
            if (bounty.validatorList[i] == validator) {
                bounty.validatorList[i] = bounty.validatorList[
                    validatorCount - 1
                ];
                bounty.validatorList.pop();
                break;
            }
        }
        emit ValidatorRemoved(bountyId, validator);
    }

    // Bounty Management

    struct BountyCreationParams {
        address targetContract;
        uint256[] rewards;
        IERC20 rewardToken;
        bool requireSnippet;
        bytes32 targetNetwork;
        bytes32 targetEnvironment;
        address[] validators;
    }

    /**
     * @notice Starts a new bounty program.
     * @param params The parameters for the bounty creation.
     * @param useOtaconToken Whether to use Otacon token for the bounty creation fee.
     * @param useETH Whether to use ETH for the bounty creation fee.
     * @param bountyPassTokenId The token ID of the bounty pass to burn (if not using Otacon token or ETH).
     */
    function startBounty(
        BountyCreationParams calldata params,
        bool useOtaconToken,
        bool useETH,
        uint256 bountyPassTokenId
    ) external payable nonReentrant {
        handleBountyCreationFee(useOtaconToken, useETH, bountyPassTokenId);

        _startBounty(params, msg.sender);
    }

    function _startBounty(
        BountyCreationParams calldata params,
        address bountyOwner
    ) internal {
        uint256 bountyId = nextBountyId;
        nextBountyId++;
        Bounty storage newBounty = bounties[bountyId];
        newBounty.isActive = true;
        newBounty.requireSnippet = params.requireSnippet;
        newBounty.owner = bountyOwner;
        newBounty.targetContract = params.targetContract;
        newBounty.rewardToken = params.rewardToken;
        newBounty.targetNetwork = params.targetNetwork;
        newBounty.targetEnvironment = params.targetEnvironment;

        _setRewards(bountyId, newBounty, params.rewards);
        _addValidators(bountyId, params.validators);
        // Automatically add the bounty owner as a validator
        addValidator(bountyId, bountyOwner);

        emit BountyStarted(
            bountyId,
            bountyOwner,
            params.targetContract,
            address(params.rewardToken)
        );
    }

    function _setRewards(
        uint256 bountyId,
        Bounty storage newBounty,
        uint256[] calldata rewards
    ) internal {
        require(
            rewards.length == 4,
            "Rewards array must contain exactly 4 elements"
        );
        for (uint8 i = 0; i < rewards.length; i++) {
            newBounty.rewards[i] = rewards[i];
            emit BountyRewardUpdated(bountyId, i, rewards[i]);
        }
    }

    function _addValidators(uint256 bountyId, address[] calldata validators)
        internal
    {
        for (uint256 i = 0; i < validators.length; i++) {
            addValidator(bountyId, validators[i]);
        }
    }

    function handleBountyCreationFee(
        bool useOtaconToken,
        bool useETH,
        uint256 bountyPassTokenId
    ) internal {
        require(
            !(useOtaconToken && useETH),
            "Cannot use both Otacon token and ETH"
        );
        if (useOtaconToken) {
            // Pay with otaconToken
            otaconToken.safeTransferFrom(msg.sender, address(this), otaconFee);
        } else if (useETH) {
            // Pay with ETH
            require(msg.value == ethFee, "Incorrect ETH amount sent");

            uint256 buybackAmount = ethFee / 2;

            // Perform buyback with 50% of ethFee
            buybackPurchase(buybackAmount);

            // The remaining ETH stays in the contract and can be withdrawn by the owner
        } else {
            // Use bountyPassCollectible
            require(
                address(bountyPassCollectible) != address(0),
                "Bounty pass collectible not set"
            );
            require(
                bountyPassCollectible.balanceOf(
                    msg.sender,
                    bountyPassTokenId
                ) >= 1,
                "You do not own the bounty pass"
            );
            // Transfer and burn the bountyPassCollectible
            bountyPassCollectible.safeTransferFrom(
                msg.sender,
                address(this),
                bountyPassTokenId,
                1,
                ""
            );
            bountyPassCollectible.burn(address(this), bountyPassTokenId, 1);
        }
    }

    /**
     * @notice Buys back OTACON tokens using Uniswap V3.
     * @param amountIn The amount of ETH to use for the buyback.
     */
    function buybackPurchase(uint256 amountIn) internal {
        require(amountIn > 0, "Amount must be greater than zero");

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: WETH9,
                tokenOut: address(otaconToken),
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp + 15,
                amountIn: amountIn,
                amountOutMinimum: 1, // Set to a minimum acceptable amount
                sqrtPriceLimitX96: 0
            });

        // Perform the swap using ETH
        uint256 amountOut = swapRouter.exactInputSingle{value: amountIn}(
            params
        );

        emit OtaconPurchased(msg.sender, amountIn, amountOut);
    }

    /**
     * @notice Stops an active bounty.
     * @param bountyId The ID of the bounty.
     */
    function stopBounty(uint256 bountyId) external onlyBountyOwner(bountyId) {
        Bounty storage bounty = bounties[bountyId];
        bounty.isActive = false;
        emit BountyStopped(bountyId);
    }

    /**
     * @notice Sets the reward for a specific severity level in a bounty.
     * @param bountyId The ID of the bounty.
     * @param severity The severity level.
     * @param reward The reward amount.
     */
    function setBountyReward(
        uint256 bountyId,
        uint8 severity,
        uint256 reward
    ) external onlyBountyOwner(bountyId) {
        Bounty storage bounty = bounties[bountyId];
        bounty.rewards[severity] = reward;
        emit BountyRewardUpdated(bountyId, severity, reward);
    }

    /**
     * @notice Sets the protocol fee percentage.
     * @param _protocolFeePercentage The new protocol fee percentage.
     */
    function setProtocolFeePercentage(uint8 _protocolFeePercentage)
        external
        onlyOwner
    {
        require(
            _protocolFeePercentage <= 100,
            "Fee percentage cannot exceed 100"
        );
        protocolFeePercentage = _protocolFeePercentage;
        emit ProtocolFeePercentageUpdated(_protocolFeePercentage);
    }

    // Staking Functions

    /**
     * @notice Stake a proof collectible to a bounty.
     * @param bountyId The bounty to stake the collectible to.
     * @param collectibleId The proof collectible ID to stake.
     */
    function stakeProofCollectible(uint256 bountyId, uint256 collectibleId)
        external
        nonReentrant
    {
        require(bounties[bountyId].isActive, "Bounty is not active");

        // Check ownership of the proof collectible
        require(
            proofCollectible.ownerOf(collectibleId) == msg.sender,
            "Not owner of the proof collectible"
        );

        // Transfer the proof collectible to the contract
        proofCollectible.safeTransferFrom(
            msg.sender,
            address(this),
            collectibleId
        );

        bounties[bountyId].stakedProofs[collectibleId] = StakedProofCollectible(
            collectibleId,
            msg.sender
        );
        bounties[bountyId].hasStakedProof[msg.sender] = true;

        emit ProofCollectibleStaked(bountyId, collectibleId, msg.sender);
    }

    /**
     * @notice Unstake a proof collectible from a bounty.
     * @param bountyId The bounty to unstake the collectible from.
     * @param collectibleId The proof collectible ID to unstake.
     */
    function unstakeProofCollectible(uint256 bountyId, uint256 collectibleId)
        external
        nonReentrant
    {
        StakedProofCollectible storage staked = bounties[bountyId].stakedProofs[
            collectibleId
        ];
        require(staked.staker == msg.sender, "Not the staker");

        // Transfer the proof collectible back to the staker
        proofCollectible.safeTransferFrom(
            address(this),
            msg.sender,
            collectibleId
        );

        delete bounties[bountyId].stakedProofs[collectibleId];
        bounties[bountyId].hasStakedProof[msg.sender] = false;

        emit ProofCollectibleUnstaked(bountyId, collectibleId, msg.sender);
    }

    /**
     * @notice Stake a snippet collectible to a bounty.
     * @param bountyId The bounty to stake the collectible to.
     * @param collectibleId The snippet collectible ID to stake.
     */
    function stakeSnippetCollectible(uint256 bountyId, uint256 collectibleId)
        external
        nonReentrant
    {
        require(bounties[bountyId].isActive, "Bounty is not active");

        // Check ownership of the snippet collectible
        require(
            snippetCollectible.ownerOf(collectibleId) == msg.sender,
            "Not owner of the snippet collectible"
        );

        // Transfer the snippet collectible to the contract
        snippetCollectible.safeTransferFrom(
            msg.sender,
            address(this),
            collectibleId
        );

        bounties[bountyId].stakedSnippets[
            collectibleId
        ] = StakedSnippetCollectible(collectibleId, msg.sender);

        emit SnippetCollectibleStaked(bountyId, collectibleId, msg.sender);
    }

    /**
     * @notice Unstake a snippet collectible from a bounty.
     * @param bountyId The bounty to unstake the collectible from.
     * @param collectibleId The snippet collectible ID to unstake.
     */
    function unstakeSnippetCollectible(uint256 bountyId, uint256 collectibleId)
        external
        nonReentrant
    {
        StakedSnippetCollectible storage staked = bounties[bountyId]
            .stakedSnippets[collectibleId];
        require(staked.staker == msg.sender, "Not the staker");

        // Transfer the snippet collectible back to the staker
        snippetCollectible.safeTransferFrom(
            address(this),
            msg.sender,
            collectibleId
        );

        delete bounties[bountyId].stakedSnippets[collectibleId];

        emit SnippetCollectibleUnstaked(bountyId, collectibleId, msg.sender);
    }

    /**
     * @notice Stake a multiplier collectible to a bounty.
     * @param bountyId The bounty to stake the multiplier collectible to.
     * @param multiplierTier The tier of the multiplier collectible.
     * @param amount The amount of multiplier collectibles to stake.
     */
    function stakeMultiplierCollectible(
        uint256 bountyId,
        MultiplierTier multiplierTier,
        uint256 amount
    ) external nonReentrant {
        require(bounties[bountyId].isActive, "Bounty is not active");
        require(amount > 0, "Amount must be greater than zero");

        MultiplierCollectibleInfo memory multiplier = multiplierCollectibles[
            multiplierTier
        ];
        require(
            address(multiplier.token) != address(0),
            "Multiplier not set for this tier"
        );

        // Transfer the multiplier collectibles to the contract
        multiplier.token.safeTransferFrom(
            msg.sender,
            address(this),
            multiplier.collectibleType,
            amount,
            ""
        );

        StakedMultiplierCollectible storage staked = bounties[bountyId]
            .stakedMultipliers[msg.sender];

        // Allow multiple stakes by adding to the existing amount
        if (staked.amount > 0) {
            require(
                staked.tier == multiplierTier,
                "Cannot stake different multiplier tiers"
            );
        } else {
            staked.tier = multiplierTier;
        }
        staked.amount += amount;

        bounties[bountyId].totalMultiplierValueStaked +=
            multiplier.multiplierValue *
            amount;

        emit MultiplierCollectibleStaked(
            bountyId,
            msg.sender,
            multiplierTier,
            amount
        );
    }

    /**
     * @notice Unstake a multiplier collectible from a bounty.
     * @param bountyId The bounty to unstake the multiplier collectible from.
     * @param amount The amount of multiplier collectibles to unstake.
     */
    function unstakeMultiplierCollectible(uint256 bountyId, uint256 amount)
        external
        nonReentrant
    {
        require(amount > 0, "Amount must be greater than zero");

        Bounty storage bounty = bounties[bountyId];
        require(
            !bounty.multiplierHasClaimed[msg.sender],
            "Cannot unstake after claiming"
        );

        StakedMultiplierCollectible storage staked = bounty.stakedMultipliers[
            msg.sender
        ];
        require(
            staked.amount >= amount,
            "Not enough staked multiplier collectibles"
        );

        MultiplierCollectibleInfo memory multiplier = multiplierCollectibles[
            staked.tier
        ];

        // Transfer the multiplier collectibles back to the staker
        multiplier.token.safeTransferFrom(
            address(this),
            msg.sender,
            multiplier.collectibleType,
            amount,
            ""
        );

        bounty.totalMultiplierValueStaked -=
            multiplier.multiplierValue *
            amount;
        staked.amount -= amount;

        if (staked.amount == 0) {
            delete bounty.stakedMultipliers[msg.sender];
        }

        emit MultiplierCollectibleUnstaked(
            bountyId,
            msg.sender,
            staked.tier,
            amount
        );
    }

    // Validation and Rewards

    /**
     * @notice Validates a proof collectible.
     * @param bountyId The bounty associated with the proof.
     * @param proofCollectibleId The proof collectible to validate.
     * @param severity The severity level of the bug.
     */
    function validateProof(
        uint256 bountyId,
        uint256 proofCollectibleId,
        uint8 severity
    ) external nonReentrant {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.validators[msg.sender], "Not a validator");
        require(
            bounty.stakedProofs[proofCollectibleId].tokenId != 0,
            "Proof not staked"
        );
        require(bounty.rewards[severity] > 0, "Invalid severity or no reward");

        address hunter = bounty.stakedProofs[proofCollectibleId].staker;
        uint256 rewardAmount = bounty.rewards[severity];
        uint256 protocolFee = (rewardAmount * protocolFeePercentage) / 100;
        uint256 hunterReward = rewardAmount - protocolFee;

        // Update state before external calls
        bounty.totalProtocolBountyReward += protocolFee;
        totalUnclaimedProtocolRewards[
            address(bounty.rewardToken)
        ] += protocolFee;

        // Delete staked proof
        delete bounty.stakedProofs[proofCollectibleId];
        bounty.hasStakedProof[hunter] = false;

        // Burn the proof collectible (external call)
        proofCollectible.burn(proofCollectibleId);

        // Transfer reward to the hunter (external call)
        bounty.rewardToken.safeTransfer(hunter, hunterReward);

        emit ProofValidated(
            bountyId,
            severity,
            hunter,
            hunterReward,
            protocolFee
        );
    }

    /**
     * @notice Claim a share of the protocol bounty.
     * @param bountyId The bounty to claim the share from.
     */
    function claimBountyShare(uint256 bountyId) external nonReentrant {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.totalProtocolBountyReward > 0, "No protocol rewards");
        require(bounty.hasStakedProof[msg.sender], "Must have staked a proof");
        require(!bounty.multiplierHasClaimed[msg.sender], "Already claimed");

        StakedMultiplierCollectible storage staked = bounty.stakedMultipliers[
            msg.sender
        ];
        require(staked.amount > 0, "No staked multiplier");

        MultiplierCollectibleInfo memory multiplier = multiplierCollectibles[
            staked.tier
        ];

        uint256 stakerTotalMultiplierValue = multiplier.multiplierValue *
            staked.amount;

        uint256 maxUserShare = bounty.totalProtocolBountyReward / 2;
        uint256 userShare = (bounty.totalProtocolBountyReward *
            stakerTotalMultiplierValue) / bounty.totalMultiplierValueStaked;

        if (userShare > maxUserShare) {
            userShare = maxUserShare;
        }

        require(userShare > 0, "No share available");

        // Update state before external calls
        bounty.multiplierHasClaimed[msg.sender] = true;
        bounty.totalProtocolRewardClaimed += userShare;
        totalUnclaimedProtocolRewards[address(bounty.rewardToken)] -= userShare;

        // Remove staked multiplier record
        delete bounty.stakedMultipliers[msg.sender];
        bounty.totalMultiplierValueStaked -= stakerTotalMultiplierValue;

        // Burn the multiplier collectibles (external call)
        multiplier.token.burn(
            address(this),
            multiplier.collectibleType,
            staked.amount
        );

        // Transfer the user's share (external call)
        bounty.rewardToken.safeTransfer(msg.sender, userShare);

        emit BountyShareClaimed(bountyId, msg.sender, userShare);
    }

    /**
     * @notice Allows the protocol to claim its share of the protocol bounty rewards.
     * @param bountyId The bounty to claim the protocol share from.
     */
    function claimProtocolBountyShare(uint256 bountyId)
        external
        onlyOwner
        nonReentrant
    {
        Bounty storage bounty = bounties[bountyId];
        uint256 totalReward = bounty.totalProtocolBountyReward;
        uint256 maxProtocolShare = totalReward / 2; // Cannot be greater than half
        uint256 protocolShare = totalReward - bounty.totalProtocolRewardClaimed;
        if (protocolShare > maxProtocolShare) {
            protocolShare = maxProtocolShare;
        }
        require(protocolShare > 0, "No protocol share available");

        // Update claimed amount
        bounty.totalProtocolRewardClaimed += protocolShare;
        totalUnclaimedProtocolRewards[
            address(bounty.rewardToken)
        ] -= protocolShare;

        // Transfer the protocol share to the owner
        bounty.rewardToken.safeTransfer(owner(), protocolShare);
    }

    // Administrative Functions

    /**
     * @notice Sets the Otacon or ETH fee.
     * @param feeType The type of fee to update ("Otacon" or "ETH").
     * @param fee The new fee amount.
     */
    function setFee(string calldata feeType, uint256 fee) external onlyOwner {
        bytes32 feeHash = keccak256(abi.encodePacked(feeType));
        if (feeHash == keccak256("Otacon")) {
            otaconFee = fee;
        } else if (feeHash == keccak256("ETH")) {
            ethFee = fee;
        } else {
            revert("Invalid fee type");
        }
        emit FeeUpdated(feeType, fee);
    }

    /**
     * @notice Withdraws the accumulated bounty creation fees (Otacon tokens and ETH).
     */
    function claimRevenue() external onlyOwner nonReentrant {
        // Withdraw Otacon tokens (bounty creation fees)
        uint256 otaconBalance = otaconToken.balanceOf(address(this));
        if (otaconBalance > 0) {
            otaconToken.safeTransfer(owner(), otaconBalance);
        }

        // Withdraw ETH (bounty creation fees)
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            Address.sendValue(payable(owner()), ethBalance);
        }
    }

    /**
     * @notice Retrieves detailed information about a specific bounty.
     * @dev Internal function that constructs a BountyInfo struct for a given bountyId.
     * @param bountyId The ID of the bounty to retrieve information for.
     * @return A BountyInfo struct containing the bounty details.
     */
    function _getBountyInfo(uint256 bountyId)
        internal
        view
        returns (BountyInfo memory)
    {
        Bounty storage bounty = bounties[bountyId];
        uint256[4] memory rewardsArray;
        rewardsArray[0] = bounty.rewards[0];
        rewardsArray[1] = bounty.rewards[1];
        rewardsArray[2] = bounty.rewards[2];
        rewardsArray[3] = bounty.rewards[3];
        return
            BountyInfo({
                bountyId: bountyId,
                isActive: bounty.isActive,
                requireSnippet: bounty.requireSnippet,
                owner: bounty.owner,
                targetContract: bounty.targetContract,
                rewardToken: bounty.rewardToken,
                rewards: rewardsArray,
                validators: bounty.validatorList,
                totalProtocolBountyReward: bounty.totalProtocolBountyReward,
                totalProtocolRewardClaimed: bounty.totalProtocolRewardClaimed,
                totalMultiplierValueStaked: bounty.totalMultiplierValueStaked,
                targetNetwork: bounty.targetNetwork,
                targetEnvironment: bounty.targetEnvironment
            });
    }

    /**
     * @notice Returns all bounty information for a given bounty ID.
     * @param bountyId The ID of the bounty.
     * @return A BountyInfo struct containing the bounty details.
     */
    function getBounty(uint256 bountyId)
        external
        view
        returns (BountyInfo memory)
    {
        return _getBountyInfo(bountyId);
    }

    /**
     * @notice Lists bounties within a specified range.
     * @dev Returns an array of BountyInfo structs for bounties from `fromBountyId` to `toBountyId`.
     * @param fromBountyId The starting bounty ID (inclusive).
     * @param toBountyId The ending bounty ID (inclusive).
     * @return An array of BountyInfo structs containing the bounty details.
     */
    function listBounties(uint256 fromBountyId, uint256 toBountyId)
        external
        view
        returns (BountyInfo[] memory)
    {
        require(fromBountyId <= toBountyId, "Invalid bounty IDs");
        require(toBountyId < nextBountyId, "Invalid bounty ID");
        uint256 length = toBountyId - fromBountyId + 1;
        BountyInfo[] memory bountiesList = new BountyInfo[](length);
        for (uint256 i = 0; i < length; i++) {
            uint256 bountyId = fromBountyId + i;
            bountiesList[i] = _getBountyInfo(bountyId);
        }
        return bountiesList;
    }

    // ERC165 Supports Interface Implementation
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    // ERC1155Receiver Implementation

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    // ERC721Receiver Implementation

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // Fallback functions to receive ETH

    receive() external payable {}

    fallback() external payable {}
}