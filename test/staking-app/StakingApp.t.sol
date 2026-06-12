//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../../src/StakingToken.sol";
import {StakingApp} from "../../src/StakingApp.sol";
import {console} from "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingAppTest is Test {
    StakingToken stakingToken;
    StakingApp stakingApp;
    address basicUser;
    address owner;
    uint256 stakingPeriod = 1000000000000000;
    uint256 depositAmount = 10;
    uint56 rewardAmount = 3;

    function setUp() public {
        stakingToken = new StakingToken("Staking Token", "STK");
        basicUser = vm.addr(1);
        owner = vm.addr(2);
        stakingApp = new StakingApp(address(stakingToken), owner, stakingPeriod, depositAmount, rewardAmount);
    }

    /**
     *  Adresss 0 is the default of all smart contracts means it's not deployed)
     */
    function testStakingTokenDeployedPropperly() external view {
        assert(address(stakingToken) != address(0));
    }

    /**
     *  If different from zero means it's propperly deployed
     */
    function testStakingAppDeployedPropperly() external view {
        assert(address(stakingApp) != address(0));
    }

    // *************************
    // ACCESS CONTROL FUNCTIONS
    // *************************
    function testShouldRevertIfNotOwner() external {
        uint256 newStakingPeriod = 200;
        vm.expectRevert();
        stakingApp.setNewStakingPeriod(newStakingPeriod);
    }

    function testSetNewStakingPeriodPropperly() public {
        vm.startPrank(owner);
        uint256 newStakingPeriod_ = 10;
        stakingApp.setNewStakingPeriod(newStakingPeriod_);
        assert(stakingApp.stakingPeriod() == newStakingPeriod_);
        vm.stopPrank();
    }

    /**
     * @dev calling receive function
     * using vm.deal to add balance to the owner account
     */
    function testContractReceiveEtherPropperly() external {
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);
        uint256 feedAmount = 1 ether;
        uint256 balanceBefore = address(stakingApp).balance;
        (bool success,) = address(stakingApp).call{value: feedAmount}("");
        uint256 balanceAfter = address(stakingApp).balance;
        require(success, "transfer Failed");

        assert(balanceAfter - balanceBefore == feedAmount);
        vm.stopPrank();
    }

    // ******************
    // DEPOSIT FUNCTIONS
    // ******************
    /**
     * @dev using a random user from basicUser and checking it's balance before and after minting
     */
    function testDepositIncorrectAmountShouldRevert() external {
        vm.startPrank(basicUser);
        uint256 diffAmount = 20;
        vm.expectRevert("Can only deposit fixed amount");
        stakingApp.depositTokens(diffAmount);
        vm.stopPrank();
    }

    /**
     * @dev using a random user from basicUser and checking it's balance before and after minting
     */
    function testDepositPropperAmount() external {
        vm.startPrank(basicUser);
        uint256 amount_ = stakingApp.fixedDepositAmount();
        stakingToken.mint(amount_);

        uint256 initialElapse = stakingApp.depositStamp(basicUser);
        uint256 initialBalance = stakingApp.userBalances(basicUser);
        IERC20(stakingToken).approve(address(stakingApp), amount_);
        stakingApp.depositTokens(amount_);
        uint256 finalBalance = stakingApp.userBalances(basicUser);
        uint256 finalElapse = stakingApp.depositStamp(basicUser);

        assert(finalBalance - initialBalance == amount_);
        assert(initialElapse == 0);
        assert(finalElapse == block.timestamp);
        vm.stopPrank();
    }

    /**
     * @notice This funtion automates the deposit process for the
     * test that require that the user needs to deposit
     * @param user user address
     * @param amount_  amount to perform deposit
     */
    function _deposit(address user, uint256 amount_) internal {
        vm.startPrank(user);
        stakingToken.mint(amount_);
        IERC20(stakingToken).approve(address(stakingApp), amount_);
        stakingApp.depositTokens(amount_);
        vm.stopPrank();
    }

    /**
     * This functions simulates two continous deposits
     */
    function testCantDepositTwice() external {
        uint256 amount_ = stakingApp.fixedDepositAmount();
        _deposit(basicUser, amount_);
        vm.startPrank(basicUser);
        vm.expectRevert("Already deposited");
        stakingApp.depositTokens(amount_);
        vm.stopPrank();
    }

    // *******************
    // WITHDRAW FUNCTIONS
    // *******************
    function testWithdrawTokensShouldRevertWithoutPropperBalance() public {
        vm.startPrank(owner);
        uint256 _amount = 9;
        stakingToken.mint(_amount);

        vm.stopPrank();
    }

    function testWithdrawRevertsWithoutDeposit() external {
        vm.prank(basicUser);
        vm.expectRevert("Not enought tokens to withdraw");
        stakingApp.withdrawTokens();
        vm.stopPrank();
    }

    function testWithdrawWorksPropperly() external {
        _deposit(basicUser, stakingApp.fixedDepositAmount());
        vm.startPrank(basicUser);

        uint256 amountInMappingBefore = stakingApp.userBalances(basicUser);
        uint256 userBalanceBefore = IERC20(stakingToken).balanceOf(basicUser);
        console.log(userBalanceBefore);
        stakingApp.withdrawTokens();
        uint256 amountInMappingAfter = stakingApp.userBalances(basicUser);
        uint256 userBalanceAfter = IERC20(stakingToken).balanceOf(basicUser);

        assert(userBalanceAfter == stakingApp.fixedDepositAmount() + userBalanceBefore);
        assert(amountInMappingBefore - amountInMappingAfter == stakingApp.fixedDepositAmount());
        vm.stopPrank();
    }

    // ****************
    // CLAIM FUNCTIONS
    // ****************

    function testCanNotClainIfNotStaking() external {
        vm.startPrank(basicUser);
        vm.expectRevert("Not staking");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testCanNotClaimIfTimeNotElapsed() external {
        _deposit(basicUser, stakingApp.fixedDepositAmount());
        vm.startPrank(basicUser);
        vm.expectRevert("no claim available yet");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testClaimShouldRevertWithoutContractEther() public {
        _deposit(basicUser, stakingApp.fixedDepositAmount());
        vm.warp(stakingPeriod + block.timestamp);
        vm.startPrank(basicUser);
        //uint256 userBalanceBefore = IERC20(stakingToken).balanceOf(basicUser);
        vm.expectRevert("transfer failed");
        stakingApp.claimRewards();
        vm.stopPrank();
    }

    function testClaimRewardsPropperly() public {
        _deposit(basicUser, stakingApp.fixedDepositAmount());
        vm.warp(stakingPeriod + block.timestamp);

        uint256 ethAmount = 100 ether;
        vm.prank(owner);
        vm.deal(owner, ethAmount);
        (bool success,) = address(stakingApp).call{value: ethAmount}("");
        require(success, "test Transfer failed");

        vm.startPrank(basicUser);
        uint256 userBalanceBefore = address(basicUser).balance;
        stakingApp.claimRewards();
        assert(stakingApp.depositStamp(basicUser) == block.timestamp);
        uint256 userBalanceAfter = address(basicUser).balance;
        assert(userBalanceAfter == userBalanceBefore + rewardAmount);
        vm.stopPrank();
    }
}
