//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract StakingApp is Ownable{

    address public stakingToken;

    /** 
     * @dev using Access Control from Open Zeppelin
    */
    constructor(address stakingToken_, address owner_) Ownable(owner_){
        stakingToken = stakingToken_;
    } 

}