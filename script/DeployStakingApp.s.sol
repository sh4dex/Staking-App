//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Script} from "forge-std/Script.sol";
import {StakingApp} from "../src/StakingApp.sol";
import {StakingToken} from "../src/StakingToken.sol";

contract DeployStakingApp is Script {
    function run() external {
        vm.startBroadcast();
        StakingToken _stakingToken = new StakingToken("Sh4dex Thoken", "STKN");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        uint256 stakingPeriod = 300;
        uint256 depositAmount = 10;
        uint56 rewardAmount = 3;
        StakingApp _app = new StakingApp(address(_stakingToken), owner, stakingPeriod, depositAmount, rewardAmount);
        uint256 _amount = 1000;
        initialFeedApp(_amount);
        vm.stopBroadcast();
    }

    function initialFeedApp(uint256 _amount) private {
        //mint
        //aprove
        //deposit
    }
}
