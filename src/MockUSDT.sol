// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockUSDT
 * @dev Mock USDT token for testing the ERC20 Deposit Certificate system
 * This contract mimics the behavior of real USDT with 6 decimals
 */
contract MockUSDT is ERC20 {
    /**
     * @dev Constructor that initializes the token with name and symbol
     * @param name The name of the token (e.g., "Mock USDT")
     * @param symbol The symbol of the token (e.g., "USDT")
     */
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // The ERC20 constructor will handle the initialization
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For USDT, this is 6 decimals.
     */
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    /**
     * @dev Mints new tokens and assigns them to the specified address
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint (in 6 decimal format)
     */
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}