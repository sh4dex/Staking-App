//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingToken is ERC20{

    /**
     * @dev Arguments from Open Zeppelin Constructor
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
    }

    /**
     * @dev calling _mint fucntion from ERC20.sol from Open Zeppelin
     */
    function mint(uint256 amount_) external {
        _mint(msg.sender, amount_);
    }
}