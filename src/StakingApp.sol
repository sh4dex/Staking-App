//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingApp is Ownable {
    address public stakingToken;
    uint256 public stakingPeriod;
    uint256 public fixedDepositAmount;
    uint256 public rewardAmountPerPeriod;
    mapping(address => uint256) public userBalances;
    mapping(address => uint256) public depositStamp;

    event NewStakingPeriod(uint256 newStakingPeriod_, address modifier_);
    event DepositMade(uint256 tokenDepositAmount_, address depositer_);
    event WithdrawnTokens(uint256 tokenWithdrawnAmount_, address receiver_);
    event EtherSend(uint256 etherAmount_);

    /**
     * @dev using Access Control from Open Zeppelin
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
     * @dev Updates mapping and contract gets tokens using {transferFrom}
     * from msg.sender to this smart contract
     * @param tokenDepositAmount_  tokenDepositAmount Amount of tokens
     * emit {DepositMade}
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
     * @notice User can only Withdraw the staked amount (deposited amount)
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
     * @dev {depositStamp} refers to the last snapshot where the user has deposit
     * this means that the time from it to the {block.timestamp} should be greater
     * than the {stakingPeriod} in order to get rewards
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
     * @dev If the owner do not send ether, then the ether is gonna be out
     */
    receive() external payable onlyOwner {
        emit EtherSend(msg.value);
    }

    /**
     * @notice Only Owner can call this function
     * @param stakingPeriod_  New staking period
     * emit {NewStakingPeriod}
     */
    function setNewStakingPeriod(uint256 stakingPeriod_) external onlyOwner {
        stakingPeriod = stakingPeriod_;
        emit NewStakingPeriod(stakingPeriod_, msg.sender);
    }
}
