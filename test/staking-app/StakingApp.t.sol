//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../../src/StakingToken.sol";
import {StakingApp} from "../../src/StakingApp.sol";
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
     *  Adresss 0 is the default of all smart contracts means it's not ddeployed)
     */
    function testStakingTokenDeployedPropperly() external view {
        assert(address(stakingToken) != address(0));
    }

    /**
     * 
     */
    function testStakingAppDeployedPropperly() external view {
        assert(address(stakingApp) != address(0));
    }

    function testShouldRevertIfNotOwner() external {
        uint256 newStakingPeriod = 200;
        vm.expectRevert();
        stakingApp.setNewStakingPeriod(newStakingPeriod);
    }

    function testAdminCanChangeSakingperiod() external {
        vm.startPrank(owner);
        uint256 newStakingPeriod = 1000;

        uint256 oldStakingPeriod = stakingApp.stakingPeriod();
        stakingApp.setNewStakingPeriod(newStakingPeriod);
        uint256 actualStakingPeriod = stakingApp.stakingPeriod();
        
        assert(oldStakingPeriod != actualStakingPeriod);
        assert(actualStakingPeriod == newStakingPeriod);
        vm.stopPrank();
    }

    /**
     * @dev calling receive function
     * using vm.deal to add balnce to the owner account
     */
    function testContractReceiveEtherPropperly() external {
        vm.startPrank(owner);
        vm.deal(owner, 1 ether);
        uint256 feedAmount = 1 ether;
        uint256 balanceBefore = address(stakingApp).balance;
        (bool success,) = address(stakingApp).call{value : feedAmount}("");
        uint256 balanceAfter = address(stakingApp).balance;
        require(success, "transfer Failed");

        assert(balanceAfter - balanceBefore == feedAmount);
        vm.stopPrank();
    }

    //Tests Deposit

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
     * 
     */
    function testWithdrawTokens() public {
        vm.startPrank(owner);
        vm.stopPrank();
    }

    /**
     * 
     */
    function setClaimRewards() public {
        vm.startPrank(owner);
        vm.stopPrank();
    }

    /**
     * 
     */
    function testSetNewStakingPeriod() public {
        vm.startPrank(owner);
        vm.stopPrank();
    }
}
