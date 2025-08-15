// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MockRejectTransfer
 * @dev Mock contract that implements ERC20 but rejects all transfers
 * Used to test atomic transfers in DepositCertificate
 */
contract MockRejectTransfer is ERC20 {
    using SafeERC20 for IERC20;
    
    bool public should_reject = true;
    
    constructor() ERC20("Mock Reject Transfer", "MRT") {
        // Mint some initial tokens to the contract itself
        _mint(address(this), 1000000 * 10**18);
    }
    
    /**
     * @dev Override transfer function to always revert
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        if (should_reject) {
            revert("Transfer rejected by mock contract");
        }
        return super.transfer(to, amount);
    }
    
    /**
     * @dev Override transferFrom function to always revert
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (should_reject) {
            revert("Transfer rejected by mock contract");
        }
        return super.transferFrom(from, to, amount);
    }
    
    /**
     * @dev Allow transfers to be enabled for testing
     */
    function enableTransfers() external {
        should_reject = false;
    }
    
    /**
     * @dev Disable transfers again
     */
    function disableTransfers() external {
        should_reject = true;
    }
}