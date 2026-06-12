//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title StakingApp
 * @notice A contract that allows users to stake ERC20 tokens and earn ETH rewards over fixed staking periods
 * @dev This contract uses OpenZeppelin's Ownable for access control. Users must deposit a fixed amount and wait for the staking period to elapse before claiming rewards.
 */
contract StakingApp is Ownable {
    /// @notice Address of the ERC20 token used for staking
    address public stakingToken;

    /// @notice Duration in seconds that users must wait before claiming rewards
    uint256 public stakingPeriod;

    /// @notice Fixed amount of tokens that users must deposit for staking
    uint256 public fixedDepositAmount;

    /// @notice Amount of ETH rewarded to users for each completed staking period
    uint256 public rewardAmountPerPeriod;

    /// @notice Tracks the staked token balance for each user
    mapping(address => uint256) public userBalances;

    /// @notice Tracks the timestamp of each user's last deposit or reward claim
    mapping(address => uint256) public depositStamp;

    event NewStakingPeriod(uint256 newStakingPeriod_, address modifier_);
    event DepositMade(uint256 tokenDepositAmount_, address depositer_);
    event WithdrawnTokens(uint256 tokenWithdrawnAmount_, address receiver_);
    event EtherSend(uint256 etherAmount_);

    /**
     * @notice Initializes the staking contract with configuration parameters
     * @param stakingToken_ Address of the ERC20 token to be staked
     * @param owner_ Address that will have owner privileges
     * @param stakingPeriod_ Duration in seconds users must wait to claim rewards
     * @param fixedDepositAmount_ Fixed amount of tokens users must deposit
     * @param rewardAmountPerPeriod_ Amount of ETH to reward per staking period
     */
    constructor(
        address stakingToken_,
        address owner_,
        uint256 stakingPeriod_,
        uint256 fixedDepositAmount_,
        uint256 rewardAmountPerPeriod_
    ) Ownable(owner_) {
        stakingToken = stakingToken_;
        stakingPeriod = stakingPeriod_;
        fixedDepositAmount = fixedDepositAmount_;
        rewardAmountPerPeriod = rewardAmountPerPeriod_;
    }

    /**
     * @notice Allows a user to deposit the fixed amount of staking tokens
     * @dev Transfers tokens from the caller to this contract using transferFrom. Each address can only have one active deposit at a time.
     * @param tokenDepositAmount_ The amount of tokens to deposit (must equal fixedDepositAmount)
     */
    function depositTokens(uint256 tokenDepositAmount_) external {
        require(tokenDepositAmount_ == fixedDepositAmount, "Can only deposit fixed amount");
        require(userBalances[msg.sender] == 0, "Already deposited");
        bool done = IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenDepositAmount_);
        require(done, "tranfer failed");
        userBalances[msg.sender] += tokenDepositAmount_;
        depositStamp[msg.sender] = block.timestamp;
        emit DepositMade(tokenDepositAmount_, msg.sender);
    }

    /**
     * @notice Allows a user to withdraw their staked tokens
     * @dev Only the exact staked amount (fixedDepositAmount) can be withdrawn. This function resets the user's balance to zero after withdrawal.
     * Note: Users can withdraw at any time, regardless of the staking period
     */
    function withdrawTokens() external {
        uint256 balanceToTranfer_ = userBalances[msg.sender];
        require(balanceToTranfer_ == fixedDepositAmount, "Not enought tokens to withdraw");
        userBalances[msg.sender] = 0;
        bool success = IERC20(stakingToken).transfer(msg.sender, balanceToTranfer_);
        require(success, "transfer failed");
        emit WithdrawnTokens(balanceToTranfer_, msg.sender);
    }

    /**
     * @notice Allows a user to claim their accumulated ETH rewards after the staking period has elapsed
     * @dev The depositStamp is updated to the current block timestamp when rewards are claimed, allowing periodic reward claims.
     * The staking period is measured from the last deposit or last reward claim.
     */
    function claimRewards() external {
        require(userBalances[msg.sender] == fixedDepositAmount, "Not staking");
        uint256 elapsePeriod_ = block.timestamp - depositStamp[msg.sender];
        require(elapsePeriod_ >= stakingPeriod, "no claim available yet");
        depositStamp[msg.sender] = block.timestamp;
        (bool success,) = msg.sender.call{value: rewardAmountPerPeriod}("");
        require(success, "transfer failed");
        emit WithdrawnTokens(rewardAmountPerPeriod, msg.sender);
    }

    /**
     * @notice Allows the contract to receive ETH, with funds tracked for reward distribution
     * @dev Only the contract owner can send ETH to this contract. This function is called when ETH is sent without calldata.
     * The contract relies on this to accumulate funds for reward payments to stakers.
     */
    receive() external payable onlyOwner {
        emit EtherSend(msg.value);
    }

    /**
     * @notice Allows the owner to update the staking period duration
     * @dev This change affects future reward eligibility calculations for all users but does not retroactively modify existing deposit timestamps
     * @param stakingPeriod_ The new staking period duration in seconds
     */
    function setNewStakingPeriod(uint256 stakingPeriod_) external onlyOwner {
        stakingPeriod = stakingPeriod_;
        emit NewStakingPeriod(stakingPeriod_, msg.sender);
    }
}
