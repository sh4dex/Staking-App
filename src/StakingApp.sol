//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingApp is Ownable{

    address public stakingToken;
    uint256 public stakingPeriod;

    event newStakingPeriod(uint256 newStakingPeriod_, address modifier_);

    /** 
     * @dev using Access Control from Open Zeppelin
    */
    constructor(address stakingToken_, address owner_) Ownable(owner_){
        stakingToken = stakingToken_;
    } 


    //TODO: Deposit-Withdraw-Claim

    function setNewStakingPeriod(uint256 stakingPeriod_) external onlyOwner {
        stakingPeriod = stakingPeriod_;
        emit newStakingPeriod(stakingPeriod_, msg.sender);
    }
}