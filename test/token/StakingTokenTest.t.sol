//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Test} from "forge-std/Test.sol";
import {StakingToken} from "../../src/StakingToken.sol";
import {IERC20} from "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract StakingTokenTest is Test {

    StakingToken stakingToken;
    address basicUser;

    function setUp() public {
        stakingToken = new StakingToken("Staking Token", "STK");
        basicUser = vm.addr(1);       
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