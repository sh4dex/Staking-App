//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../../src/StakingToken.sol";
import {StakingApp} from "../../src/StakingApp.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    StakingApp stakingApp;
    address basicUser;
    address owner;

    function setUp() public {
        stakingToken = new StakingToken("Staking Token", "STK");
        basicUser = vm.addr(1);
        owner = vm.addr(2);
        uint256 stakingPeriod = 300;
        uint256 depositAmount = 10;
        uint56 rewardAmount = 3;
        stakingApp = new StakingApp(address(stakingToken), owner, stakingPeriod, depositAmount, rewardAmount);
    }

    /**
     * @dev using a random user from basicUser and checking it's balance before and after minting
     */
    function testStakingTokenMintingPropperly() public {
        vm.startPrank(basicUser);
        uint256 amount_ = 1 ether;
        uint256 initialBalance_ = IERC20(address(stakingToken)).balanceOf(basicUser);
        stakingToken.mint(amount_);
        uint256 finalBalance_ = IERC20(address(stakingToken)).balanceOf(basicUser);
        assert(finalBalance_ - initialBalance_ == amount_);
        vm.stopPrank();
    }
}
