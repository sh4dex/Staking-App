//SPDX-License-Identifier: MIT

pragma solidity 0.8.34;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title StakingToken
 * @notice A simple ERC20 token that allows unrestricted minting by any caller
 * @dev This is a basic ERC20 implementation used as the staking asset in the StakingApp contract
 */
contract StakingToken is ERC20 {
    /**
     * @notice Initializes the token with a name and symbol
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token (e.g., "STK")
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    /**
     * @notice Allows any caller to mint new tokens to their address
     * @dev This function does not have access control, so anyone can mint tokens
     * In production, consider adding access control (e.g., Ownable) to restrict minting
     * @param amount_ The number of tokens to mint
     */
    function mint(uint256 amount_) external {
        _mint(msg.sender, amount_);
    }
}
