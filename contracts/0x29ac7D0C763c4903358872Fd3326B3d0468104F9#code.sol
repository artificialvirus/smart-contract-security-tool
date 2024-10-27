// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { TokenRegistry, Ownable2Step, Ownable } from "./TokenRegistry.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IdenticalValue, ZeroAddress, ETH, ZeroValue, DIVISOR } from "./Common.sol";

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TaskManager is TokenRegistry, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @member title The title of the task
    /// @member description The description of the task describing complete requirements
    /// @member reward The amount of reward given to the person who completes the task
    /// @member rewardToken The currecny in which the rewards is given
    /// @member creator The address of the wallet which created the task
    /// @member refunded A boolean value representing whether the task has been refunded or not
    /// @member redeemed A boolean value representing whether the task has been completed and redeemed
    /// @member redeemed A boolean value representing whether the task has been disputed
    /// @member redeemer The address of the wallet which redemeed the task and earned reward
    /// @member feeTreasury The amount of fee allocated for setting up the task
    /// @member feeDao The amount of fee allocated for the dao
    struct Task {
        string title;
        string description;
        uint256 reward;
        IERC20 rewardToken;
        address creator;
        bool refunded;
        bool redeemed;
        bool disputed;
        address redeemer;
        uint256 feeTreasury;
        uint256 feeDao;
    }

    /// @member Redeem Representing whether the signarure generated is intented to redeem the task
    /// @member Refund Representing whether the signarure generated is intented to Refund the task
    /// @member Dispute Representing whether the signarure generated is intented to resolve the Dispute of the task
    enum SignatureType {
        Redeem,
        Refund,
        Dispute
    }

    /// @notice The count of total tasks created thus far
    uint256 public totalTasks;

    /// @notice The address where the treasury fee per task will be sent
    address public feeWallet;

    /// @notice The address where the dao fee per task will be sent
    address public daoWallet;

    /// @notice The percentage of treasury fee deducted per task
    uint256 public treasuryFee;

    /// @notice The percentage of dao fee deducted in case of dispute on a task
    uint256 public daoFee;

    /// @notice The address of signer wallet
    address public signerWallet;

    /// @notice Gives task info of every task created
    mapping(uint256 => Task) public tasks;

    /// @dev Emitted when treasury fee wallet is changed
    event TreasuryFeeWalletChanged(address oldWallet, address newWallet);

    /// @dev Emitted when treasury fee wallet is changed
    event DaoFeeWalletChanged(address oldWallet, address newWallet);

    /// @dev Emitted when treasury fee is changed
    event TreasuryFeeChanged(uint256 oldFee, uint256 newFee);

    /// @dev Emitted when dao fee wallet is changed
    event DaoFeeChanged(uint256 oldFee, uint256 newFee);

    /// @dev Emitted when a new task is created
    event TaskCreated(
        string title,
        string description,
        uint256 reward,
        IERC20 rewardingToken,
        address creator,
        uint256 taskId
    );

    /// @dev Emitted when a task is redeemed
    event TaskRedeemed(uint256 taskId, address redeemer);

    /// @dev Emitted when a task is refunded back to creator
    event TaskRefunded(uint256 taskId);

    /// @dev Emitted when a task is disputed
    event TaskDisputed(uint256 taskId);

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @notice Thrown when sign is invalid
    error InvalidSignature();

    /// @notice Thrown when input array length is zero
    error InvalidData();

    /// @notice Thrown when deadline is wrong
    error InvalidDeadline();

    /// @notice Thrown when reward token is not supported by contract
    error InvalidRewardToken();

    /// @notice Thrown when taskId doesn't exists or not created by caller
    error InvalidTask();

    /// @notice Thrown when task is already redeemed
    error TaskAlreadyRedeemed();

    /// @notice Thrown when task is already refunded
    error TaskAlreadyRefunded();

    /// @notice Thrown when task is already disputed
    error TaskAlreadyDisputed();

    /// @notice Thrown when task creator is trying to redeem task or trying to refund someone's else task
    error InvalidRedeemer();

    /// @notice Thrown when msg.value is less than reward value while creating task
    error InvalidPayableValue();

    /// @notice Restricts when updating wallet/contract address with zero address
    modifier checkAddressZero(address which) {
        if (which == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    /// @dev Constructor
    /// @param initialOwner The addresses of the owner of the contract
    /// @param treasuryFeeWalletAddress The address of the wallet treasury fee wil be sent to
    /// @param daoFeeWalletAddress The address of the wallet dao fee wil be sent to
    /// @param signer The address of signer wallet
    /// @param treasuryFeePercentage The percentage
    /// @param daoFeePercentage The last round created
    constructor(
        address initialOwner,
        address treasuryFeeWalletAddress,
        address daoFeeWalletAddress,
        address signer,
        uint256 treasuryFeePercentage,
        uint256 daoFeePercentage
    ) Ownable(initialOwner) {
        if (
            initialOwner == address(0) ||
            treasuryFeeWalletAddress == address(0) ||
            daoFeeWalletAddress == address(0) ||
            signer == address(0)
        ) {
            revert ZeroAddress();
        }

        if (treasuryFeePercentage == 0 || daoFeePercentage == 0) {
            revert ZeroValue();
        }

        feeWallet = treasuryFeeWalletAddress;
        daoWallet = daoFeeWalletAddress;
        treasuryFee = treasuryFeePercentage;
        daoFee = daoFeePercentage;
        signerWallet = signer;
    }

    /// @notice Changes treasury fee wallet
    /// @param newFeeWalletAddress The address of the new treasury fee wallet
    function changeTreasuryFeeWallet(
        address newFeeWalletAddress
    ) external checkAddressZero(newFeeWalletAddress) onlyOwner {
        if (feeWallet == newFeeWalletAddress) {
            revert IdenticalValue();
        }

        emit TreasuryFeeWalletChanged({ oldWallet: feeWallet, newWallet: newFeeWalletAddress });
        feeWallet = newFeeWalletAddress;
    }

    /// @notice Changes dao fee wallet
    /// @param newFeeWalletAddress The address of the new dao fee wallet
    function changeDaoFeeWallet(address newFeeWalletAddress) external checkAddressZero(newFeeWalletAddress) onlyOwner {
        if (daoWallet == newFeeWalletAddress) {
            revert IdenticalValue();
        }

        emit DaoFeeWalletChanged({ oldWallet: feeWallet, newWallet: newFeeWalletAddress });
        daoWallet = newFeeWalletAddress;
    }

    /// @notice Changes treasury fee
    /// @param newTreasuryFee The new percentage of treasury fee
    function changeTreasuryFee(uint256 newTreasuryFee) external onlyOwner {
        if (newTreasuryFee == 0) {
            revert ZeroValue();
        }

        if (treasuryFee == newTreasuryFee) {
            revert IdenticalValue();
        }

        emit TreasuryFeeChanged({ oldFee: treasuryFee, newFee: newTreasuryFee });
        treasuryFee = newTreasuryFee;
    }

    /// @notice Changes dai fee
    /// @param newDaoFee The new percentage of dao fee
    function changeDaoFee(uint256 newDaoFee) external onlyOwner {
        if (newDaoFee == 0) {
            revert ZeroValue();
        }

        if (daoFee == newDaoFee) {
            revert IdenticalValue();
        }

        emit DaoFeeChanged({ oldFee: daoFee, newFee: newDaoFee });
        daoFee = newDaoFee;
    }

    /// @notice Changes signer wallet address
    /// @param newSigner The address of the new signer wallet
    function changeSigner(address newSigner) external checkAddressZero(newSigner) onlyOwner {
        address oldSigner = signerWallet;
        if (oldSigner == newSigner) {
            revert IdenticalValue();
        }
        emit SignerUpdated({ oldSigner: oldSigner, newSigner: newSigner });
        signerWallet = newSigner;
    }

    /// @notice Created a new task
    /// @param title The title of the task
    /// @param description The description of the task
    /// @param reward The reward to be given to the person who completes the task
    /// @param token The currency in which reward is given
    function createTask(
        string calldata title,
        string calldata description,
        uint256 reward,
        IERC20 token
    ) external payable nonReentrant returns (uint256) {
        if (reward == 0) {
            revert ZeroValue();
        }

        if (!acceptableTokens[token]) {
            revert InvalidRewardToken();
        }

        uint256 taskId = totalTasks++;
        address taskCreator = msg.sender;

        uint256 feeTreasury = ((reward * treasuryFee) / DIVISOR);
        uint256 feeDao = ((reward * daoFee) / DIVISOR);

        uint256 amount = reward - feeTreasury;

        if (token != ETH) {
            token.safeTransferFrom(msg.sender, address(this), amount);
            token.safeTransferFrom(msg.sender, feeWallet, feeTreasury);
        } else {
            if (msg.value != reward) {
                revert InvalidPayableValue();
            }
            payable(feeWallet).sendValue(feeTreasury);
        }

        amount -= feeDao;

        Task memory newTask;

        newTask.title = title;
        newTask.description = description;
        newTask.reward = amount;
        newTask.rewardToken = token;
        newTask.creator = taskCreator;
        newTask.redeemed = false;
        newTask.feeTreasury = feeTreasury;
        newTask.feeDao = feeDao;

        tasks[taskId] = newTask;

        emit TaskCreated({
            title: title,
            description: description,
            reward: reward,
            rewardingToken: token,
            creator: taskCreator,
            taskId: taskId
        });

        return taskId;
    }

    /// @notice Created a new task
    /// @param taskId The id of the task to be redeemed
    /// @param creatorSignature The signature of the creator indicating he chose this person
    /// @param signerSignature The signature of the platform indicating all off chain requirements met
    function redeemTask(
        uint256 taskId,
        bytes calldata creatorSignature,
        bytes calldata signerSignature
    ) external nonReentrant {
        if (taskId >= totalTasks) {
            revert InvalidTask();
        }

        Task memory task = tasks[taskId];

        if (task.redeemed) {
            revert TaskAlreadyRedeemed();
        }

        if (task.refunded) {
            revert TaskAlreadyRefunded();
        }

        if (task.disputed) {
            revert TaskAlreadyDisputed();
        }

        address redeemer = msg.sender;

        if (redeemer == task.creator) {
            revert InvalidRedeemer();
        }

        _verifySignature(taskId, SignatureType.Redeem, creatorSignature, task.creator);
        _verifySignature(taskId, SignatureType.Redeem, signerSignature, signerWallet);

        tasks[taskId].redeemed = true;
        tasks[taskId].redeemer = redeemer;

        if (task.rewardToken == ETH) {
            payable(daoWallet).sendValue(task.feeDao);
            payable(redeemer).sendValue(task.reward);
        } else {
            task.rewardToken.safeTransfer(daoWallet, task.feeDao);
            task.rewardToken.safeTransfer(redeemer, task.reward);
        }

        emit TaskRedeemed({ taskId: taskId, redeemer: redeemer });
    }

    /// @notice Created a new task
    /// @param taskId The id of the task to be redeemed
    /// @param signerSignature The signature of the platform indicating all off chain requirements met
    function refundTask(uint256 taskId, bytes calldata signerSignature) external nonReentrant {
        if (taskId >= totalTasks) {
            revert InvalidTask();
        }

        Task memory task = tasks[taskId];

        if (task.redeemed) {
            revert TaskAlreadyRedeemed();
        }

        if (task.refunded) {
            revert TaskAlreadyRefunded();
        }

        if (task.disputed) {
            revert TaskAlreadyDisputed();
        }

        address refundTo = msg.sender;

        if (refundTo != task.creator) {
            revert InvalidTask();
        }

        _verifySignature(taskId, SignatureType.Refund, signerSignature, signerWallet);

        tasks[taskId].refunded = true;

        if (task.rewardToken == ETH) {
            payable(daoWallet).sendValue(task.feeDao);
            payable(refundTo).sendValue(task.reward);
        } else {
            task.rewardToken.safeTransfer(daoWallet, task.feeDao);
            task.rewardToken.safeTransfer(refundTo, task.reward);
        }

        emit TaskRefunded({ taskId: taskId });
    }

    /// @notice Created a new task
    /// @param taskId The id of the task to be redeemed
    /// @param signerSignature The signature of the platform indicating all off chain requirements met
    function disputeTask(uint256 taskId, bytes calldata signerSignature) external nonReentrant {
        if (taskId >= totalTasks) {
            revert InvalidTask();
        }

        Task memory task = tasks[taskId];

        if (task.redeemed) {
            revert TaskAlreadyRedeemed();
        }

        if (task.refunded) {
            revert TaskAlreadyRefunded();
        }

        if (task.disputed) {
            revert TaskAlreadyDisputed();
        }

        address disputeTo = msg.sender;

        _verifySignature(taskId, SignatureType.Dispute, signerSignature, signerWallet);

        tasks[taskId].disputed = true;

        if (task.rewardToken == ETH) {
            payable(daoWallet).sendValue(task.feeDao);
            payable(disputeTo).sendValue(task.reward);
        } else {
            task.rewardToken.safeTransfer(daoWallet, task.feeDao);
            task.rewardToken.safeTransfer(disputeTo, task.reward);
        }

        emit TaskDisputed({ taskId: taskId });
    }

    /// @dev The helper function which verifies signature, signed by intended signer, reverts if Invalid
    function _verifySignature(
        uint256 taskId,
        SignatureType sigType,
        bytes calldata signature,
        address signatureSigner
    ) private view {
        bytes32 encodedMessageHash = keccak256(abi.encodePacked(msg.sender, taskId, sigType));
        _verifyMessage(encodedMessageHash, signature, signatureSigner);
    }

    /// @dev Verifies the address that signed a hashed message (`hash`) with `signature`
    function _verifyMessage(
        bytes32 encodedMessageHash,
        bytes calldata signature,
        address signatureSigner
    ) private pure {
        if (signatureSigner != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(encodedMessageHash), signature)) {
            revert InvalidSignature();
        }
    }
}