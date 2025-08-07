# Implementation Plan

## Summary of Changes

This document has been updated to incorporate the new Fixed Fund Split on Deposit feature, which enhances the existing ERC20 Deposit Certificate system. The key changes include:

1. **Task Decomposition**: All 17 original tasks have been decomposed into more granular subtasks following the AI Task Decomposition Rule with MCP Server Integration guidelines. Each subtask now includes:

   - Detailed urgency, impact, and resource availability scores (1-10)
   - Weighted priority calculations using: Priority = (Urgency × 0.4) + (Impact × 0.4) + (Resources × 0.2)
   - Clear dependency mappings between subtasks
   - Specific resource requirements for each subtask

2. **Fixed Fund Split Feature**: A comprehensive new feature has been added that automatically splits deposited USDT into 8 different wallets with fixed percentages:

   - Invest BNB (55%) → investWallet (fixed)
   - Development & Operation (5%) → devOpsWallet (fixed)
   - Advisor (5%) → advisorWallet (fixed)
   - Marketing / Recommendation Team (15%) → marketingWallet (fixed)
   - Level 1 MLM Incentive (10%) → level1Wallet (dynamic)
   - Level 2 MLM Incentive (3%) → level2Wallet (dynamic)
   - Level 3 MLM Incentive (2%) → level3Wallet (dynamic)
   - Product Owner (5%) → ownerWallet (fixed)

3. **Implementation Status**: Based on project file examination, Tasks 1-14 have already been implemented, while Tasks 15-17 and the new Fixed Fund Split feature require implementation.

4. **Enhanced Structure**: The document now provides a more detailed and actionable plan with clear priorities, dependencies, and resource allocations to facilitate efficient project execution.

## Fixed Fund Split on Deposit Feature

The new Fixed Fund Split on Deposit feature automatically distributes deposited USDT across multiple wallets according to predefined percentages. This feature ensures:

- **Automated Distribution**: Each deposit is automatically split according to fixed percentages
- **Immutable Fixed Wallets**: Five wallet addresses (investWallet, devOpsWallet, advisorWallet, marketingWallet, ownerWallet) are set at deployment and cannot be changed
- **Dynamic MLM Wallets**: Three wallet addresses (level1Wallet, level2Wallet, level3Wallet) can be updated by the contract owner
- **Atomic Transactions**: All transfers occur in a single transaction to ensure consistency
- **Validation**: MLM wallet addresses are validated to ensure they are non-zero addresses
- **Transparency**: All splits are logged with appropriate events for auditing

### Wallet Distribution Structure

| Wallet Type     | Percentage | Purpose                         | Address Type        |
| --------------- | ---------- | ------------------------------- | ------------------- |
| investWallet    | 55%        | Investment in BNB               | Fixed (immutable)   |
| devOpsWallet    | 5%         | Development & Operations        | Fixed (immutable)   |
| advisorWallet   | 5%         | Advisor compensation            | Fixed (immutable)   |
| marketingWallet | 15%        | Marketing & Recommendation Team | Fixed (immutable)   |
| level1Wallet    | 10%        | Level 1 MLM Incentive           | Dynamic (updatable) |
| level2Wallet    | 3%         | Level 2 MLM Incentive           | Dynamic (updatable) |
| level3Wallet    | 2%         | Level 3 MLM Incentive           | Dynamic (updatable) |
| ownerWallet     | 5%         | Product Owner                   | Fixed (immutable)   |

---

## Original Tasks (Decomposed)

### Task 1: Set up Foundry project structure and dependencies

**Status: Completed**

- [x] 1.1. Initialize new Foundry project with proper directory structure

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: None_
  - _Resources: Foundry CLI, terminal, file system_

- [x] 1.2. Install OpenZeppelin contracts dependency

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 1.1_
  - _Resources: Forge CLI, internet connection, package manager_

- [x] 1.3. Configure foundry.toml with proper settings for Solidity version and optimization

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 1.1, 1.2_
  - _Resources: Text editor, foundry documentation_

- [x] 1.4. Create .env.example file with required environment variables

  - _Urgency: 7, Impact: 8, Resources: 9, Priority: 7.8_
  - _Dependencies: 1.3_
  - _Resources: Text editor, environment variable documentation_

- [x] 1.5. Verify project structure and dependencies installation
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 1.1, 1.2, 1.3, 1.4_
  - _Resources: Terminal, file explorer, forge commands_

### Task 2: Implement MockUSDT contract for testing

**Status: Completed**

- [x] 2.1. Create MockUSDT.sol contract file in src directory

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 1.1, 1.2_
  - _Resources: Text editor, Solidity compiler_

- [x] 2.2. Implement contract inheriting from OpenZeppelin ERC20

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 2.1_
  - _Resources: OpenZeppelin documentation, Solidity IDE_

- [x] 2.3. Set 6 decimals to match real USDT specifications

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 2.2_
  - _Resources: USDT token specification, Solidity compiler_

- [x] 2.4. Implement mint function for test token distribution

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 2.2, 2.3_
  - _Resources: Solidity IDE, testing framework_

- [x] 2.5. Add proper constructor with name and symbol parameters

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 2.2_
  - _Resources: Solidity documentation, code editor_

- [x] 2.6. Compile and verify MockUSDT contract
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 2.2, 2.3, 2.4, 2.5_
  - _Resources: Foundry compiler, terminal_

### Task 3: Implement core DepositCertificate contract structure

**Status: Completed**

- [x] 3.1. Create DepositCertificate.sol contract file in src directory

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 1.1, 1.2_
  - _Resources: Text editor, Solidity compiler_

- [x] 3.2. Implement contract inheriting from ERC20 and Ownable

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 3.1_
  - _Resources: OpenZeppelin documentation, Solidity IDE_

- [x] 3.3. Define immutable state variables for USDT token and settlement wallet addresses

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 3.2_
  - _Resources: Solidity documentation, code editor_

- [x] 3.4. Implement mapping for lastDepositTime tracking per holder

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 3.2_
  - _Resources: Solidity documentation, data structures knowledge_

- [x] 3.5. Add constructor with proper parameter validation and initialization

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 3.2, 3.3, 3.4_
  - _Resources: Solidity documentation, code editor_

- [x] 3.6. Import required OpenZeppelin contracts and SafeERC20

  - _Urgency: 8, Impact: 9, Resources: 9, Priority: 8.6_
  - _Dependencies: 3.1_
  - _Resources: OpenZeppelin documentation, Solidity IDE_

- [x] 3.7. Compile and verify DepositCertificate contract structure
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_
  - _Resources: Foundry compiler, terminal_

### Task 4: Implement deposit functionality

**Status: Completed**

- [x] 4.1. Code deposit function that accepts USDT amount parameter

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 3.1, 3.2, 3.3, 3.5_
  - _Resources: Solidity IDE, function design patterns_

- [x] 4.2. Add input validation for zero amounts and proper error handling

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 4.1_
  - _Resources: Solidity documentation, error handling best practices_

- [x] 4.3. Implement SafeERC20 transferFrom to move USDT from user to settlement wallet

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 4.1, 4.2_
  - _Resources: OpenZeppelin SafeERC20 documentation, Solidity IDE_

- [x] 4.4. Add token minting logic to issue certificate tokens to depositor

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 4.1, 4.2, 4.3_
  - _Resources: ERC20 documentation, Solidity IDE_

- [x] 4.5. Update lastDepositTime mapping with current block timestamp

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 4.1, 4.2, 4.3, 4.4_
  - _Resources: Solidity timestamp functions, mapping operations_

- [x] 4.6. Emit Deposited event with relevant parameters

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 4.1, 4.2, 4.3, 4.4, 4.5_
  - _Resources: Solidity event documentation, code editor_

- [x] 4.7. Test deposit functionality with various scenarios
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_
  - _Resources: Testing framework, test scenarios_

### Task 5: Implement penalty calculation logic

**Status: Completed**

- [x] 5.1. Create calculatePenalty function with holder address and amount parameters

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 3.1, 3.2, 3.4_
  - _Resources: Solidity IDE, function design patterns_

- [x] 5.2. Implement time-based penalty calculation using elapsed time from lastDepositTime

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 5.1_
  - _Resources: Solidity timestamp functions, mathematical operations_

- [x] 5.3. Code three penalty tiers: 0-1 year (50%), 1-5 years (linear decrease), 5+ years (0%)

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 5.1, 5.2_
  - _Resources: Mathematical formulas, Solidity conditional logic_

- [x] 5.4. Use basis points (10000 = 100%) for precise percentage calculations

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 5.1, 5.2, 5.3_
  - _Resources: Basis points documentation, precision calculation techniques_

- [x] 5.5. Return both penalty amount and payout amount from function

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 5.1, 5.2, 5.3, 5.4_
  - _Resources: Solidity return values, tuple structures_

- [x] 5.6. Add comprehensive input validation and edge case handling

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 5.1, 5.2, 5.3, 5.4, 5.5_
  - _Resources: Input validation best practices, edge case scenarios_

- [x] 5.7. Test penalty calculation with various time scenarios
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
  - _Resources: Testing framework, time manipulation tools_

### Task 6: Implement token transfer timestamp updates

**Status: Completed**

- [x] 6.1. Override \_update function from ERC20 (formerly \_beforeTokenTransfer)

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 3.1, 3.2, 3.4_
  - _Resources: ERC20 documentation, Solidity override mechanisms_

- [x] 6.2. Add logic to update recipient's lastDepositTime when tokens are transferred

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 6.1_
  - _Resources: Solidity transfer logic, mapping operations_

- [x] 6.3. Ensure timestamp updates only occur for regular transfers (not mints to zero or burns from zero)

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 6.1, 6.2_
  - _Resources: ERC20 transfer types, conditional logic_

- [x] 6.4. Handle edge cases where from or to addresses are zero address

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 6.1, 6.2, 6.3_
  - _Resources: Address validation, edge case handling_

- [x] 6.5. Emit TimestampUpdated event when timestamps are modified

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 6.1, 6.2, 6.3, 6.4_
  - _Resources: Solidity event documentation, code editor_

- [x] 6.6. Test timestamp updates with various transfer scenarios
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 6.1, 6.2, 6.3, 6.4, 6.5_
  - _Resources: Testing framework, transfer scenario design_

### Task 7: Implement redemption functionality

**Status: Completed**

- [x] 7.1. Create redeem function that accepts certificate token amount to redeem

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 3.1, 3.2, 3.3, 5.1_
  - _Resources: Solidity IDE, function design patterns_

- [x] 7.2. Add validation for sufficient certificate token balance

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 7.1_
  - _Resources: Balance checking functions, validation logic_

- [x] 7.3. Integrate penalty calculation using calculatePenalty function

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 7.1, 7.2, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_
  - _Resources: Function integration, return value handling_

- [x] 7.4. Implement token burning from user's certificate balance

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 7.1, 7.2, 7.3_
  - _Resources: ERC20 burn functions, balance manipulation_

- [x] 7.5. Use SafeERC20 transferFrom to move USDT from settlement wallet to user

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.2_
  - _Dependencies: 7.1, 7.2, 7.3, 7.4_
  - _Resources: SafeERC20 documentation, transfer logic_

- [x] 7.6. Add proper error handling for insufficient settlement wallet balance or approval

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 7.1, 7.2, 7.3, 7.4, 7.5_
  - _Resources: Error handling best practices, validation logic_

- [x] 7.7. Emit Redeemed event with tokens redeemed, payout, and penalty amounts

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_
  - _Resources: Solidity event documentation, code editor_

- [x] 7.8. Test redemption functionality with various scenarios
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_
  - _Resources: Testing framework, redemption scenario design_

### Task 8: Add comprehensive error handling and events

**Status: Completed**

- [x] 8.1. Define custom error types for common failure scenarios

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 3.1, 3.2_
  - _Resources: Solidity custom error documentation, error design patterns_

- [x] 8.2. Implement proper error messages for insufficient balances, allowances, and transfers

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 8.1, 4.2, 7.2, 7.6_
  - _Resources: Error message design, user experience considerations_

- [x] 8.3. Add event definitions for Deposited, Redeemed, and TimestampUpdated

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 8.1, 4.6, 6.5, 7.7_
  - _Resources: Solidity event documentation, event design patterns_

- [x] 8.4. Ensure all state-changing functions emit appropriate events

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 8.1, 8.2, 8.3, 4.6, 6.5, 7.7_
  - _Resources: Event emission best practices, code review_

- [x] 8.5. Add input validation with meaningful error messages throughout all functions

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 8.1, 8.2, 4.2, 5.6, 6.4, 7.2, 7.6_
  - _Resources: Input validation techniques, error message design_

- [x] 8.6. Test error handling and event emission with various scenarios
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 8.1, 8.2, 8.3, 8.4, 8.5_
  - _Resources: Testing framework, error scenario design_

### Task 9: Create comprehensive test suite setup

**Status: Completed**

- [x] 9.1. Create DepositCertificate.t.sol test file in test directory

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  - _Resources: Foundry test framework, test file structure_

- [x] 9.2. Set up test environment with MockUSDT deployment and user accounts

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 9.1, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_
  - _Resources: Foundry test setup, contract deployment patterns_

- [x] 9.3. Implement setUp function that deploys contracts and configures initial state

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 9.1, 9.2_
  - _Resources: Foundry setUp function, test initialization patterns_

- [x] 9.4. Create helper functions for common test operations (minting USDT, setting approvals)

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 9.1, 9.2, 9.3_
  - _Resources: Test helper design patterns, code reuse principles_

- [x] 9.5. Add utility functions for time manipulation using vm.warp

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 9.1, 9.2, 9.3_
  - _Resources: Foundry vm functions, time manipulation techniques_

- [x] 9.6. Verify test suite setup with basic functionality tests
  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 9.1, 9.2, 9.3, 9.4, 9.5_
  - _Resources: Testing framework, test validation techniques_

### Task 10: Write deposit functionality tests

**Status: Completed**

- [x] 10.1. Test successful deposit flow with USDT transfer and token minting

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_
  - _Resources: Test scenario design, assertion techniques_

- [x] 10.2. Verify lastDepositTime is correctly updated on deposit

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 10.1, 4.5_
  - _Resources: Timestamp verification, test assertions_

- [x] 10.3. Test deposit with zero amount fails with appropriate error

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 10.1, 4.2_
  - _Resources: Error testing, exception handling_

- [x] 10.4. Test deposit without sufficient USDT balance or approval fails

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 10.1, 4.2, 4.3_
  - _Resources: Balance testing, approval testing_

- [x] 10.5. Verify Deposited event is emitted with correct parameters

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 10.1, 4.6_
  - _Resources: Event testing, parameter verification_

- [x] 10.6. Test multiple deposits from same user update timestamp correctly
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 10.1, 10.2, 4.5_
  - _Resources: Multiple transaction testing, timestamp verification_

### Task 11: Write token transfer timestamp tests

**Status: Completed**

- [x] 11.1. Test that token transfers update recipient's lastDepositTime

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  - _Resources: Transfer testing, timestamp verification_

- [x] 11.2. Verify sender's timestamp remains unchanged during transfers

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 11.1, 6.2_
  - _Resources: Transfer testing, timestamp verification_

- [x] 11.3. Test that minting (from zero address) updates recipient timestamp

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 11.1, 6.3_
  - _Resources: Mint testing, timestamp verification_

- [x] 11.4. Test that burning (to zero address) does not update timestamps

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 11.1, 6.3, 6.4_
  - _Resources: Burn testing, timestamp verification_

- [x] 11.5. Verify TimestampUpdated event emission on transfers

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 11.1, 6.5_
  - _Resources: Event testing, parameter verification_

- [x] 11.6. Test edge cases with zero amount transfers
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 11.1, 6.4_
  - _Resources: Edge case testing, zero amount scenarios_

### Task 12: Write penalty calculation tests

**Status: Completed**

- [x] 12.1. Test penalty calculation for deposits less than 1 year old (50% penalty)

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_
  - _Resources: Time manipulation, penalty calculation verification_

- [x] 12.2. Test penalty calculation for deposits exactly 1 year old (50% penalty)

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 12.1, 5.3_
  - _Resources: Time manipulation, penalty calculation verification_

- [x] 12.3. Test penalty calculation for deposits between 1-5 years (linear decrease)

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 12.1, 12.2, 5.3_
  - _Resources: Time manipulation, linear calculation verification_

- [x] 12.4. Test penalty calculation for deposits exactly 5 years old (0% penalty)

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 12.1, 12.2, 12.3, 5.3_
  - _Resources: Time manipulation, penalty calculation verification_

- [x] 12.5. Test penalty calculation for deposits older than 5 years (0% penalty)

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 12.1, 12.2, 12.3, 12.4, 5.3_
  - _Resources: Time manipulation, penalty calculation verification_

- [x] 12.6. Verify mathematical precision of linear penalty decrease formula
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 12.1, 12.2, 12.3, 12.4, 12.5, 5.3, 5.4_
  - _Resources: Mathematical verification, precision testing_

### Task 13: Write redemption functionality tests

**Status: Completed**

- [x] 13.1. Test successful redemption with correct token burning and USDT payout

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8_
  - _Resources: Redemption testing, balance verification_

- [x] 13.2. Verify penalty is correctly applied and payout matches calculation

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 13.1, 7.3, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_
  - _Resources: Penalty verification, calculation testing_

- [x] 13.3. Test redemption with insufficient certificate token balance fails

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 13.1, 7.2_
  - _Resources: Balance testing, error verification_

- [x] 13.4. Test redemption when settlement wallet lacks USDT or approval fails

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 13.1, 7.5, 7.6_
  - _Resources: Settlement testing, approval testing_

- [x] 13.5. Verify Redeemed event emission with correct penalty and payout values

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 13.1, 7.7_
  - _Resources: Event testing, parameter verification_

- [x] 13.6. Test partial redemption scenarios with remaining balance
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 13.1, 7.1, 7.4_
  - _Resources: Partial redemption testing, balance verification_

### Task 14: Write integration and edge case tests

**Status: Completed**

- [x] 14.1. Test complete user journey: deposit → transfer → redeem flow

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_
  - _Resources: Integration testing, user journey simulation_

- [x] 14.2. Test multiple users with different deposit times and redemption scenarios

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 14.1_
  - _Resources: Multi-user testing, time manipulation_

- [x] 14.3. Test gas optimization and ensure functions stay within reasonable gas limits

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 14.1, 14.2_
  - _Resources: Gas profiling, optimization techniques_

- [x] 14.4. Test contract behavior with maximum and minimum token amounts

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 14.1, 14.2_
  - _Resources: Boundary testing, extreme value handling_

- [x] 14.5. Verify all error conditions trigger appropriate custom errors

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 14.1, 14.2, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  - _Resources: Error testing, custom error verification_

- [x] 14.6. Test contract behavior with zero balances and edge timestamp values
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 14.1, 14.2_
  - _Resources: Edge case testing, zero value scenarios_

### Task 15: Create deployment script

**Status: Completed**

- [x] 15.1. Create Deploy.s.sol script file in script directory

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_
  - _Resources: Foundry script framework, Solidity IDE_

- [x] 15.2. Implement deployment logic for MockUSDT contract (testing only)

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 15.1, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_
  - _Resources: Contract deployment patterns, script development_

- [x] 15.3. Implement deployment logic for DepositCertificate contract with environment variable configuration

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 15.1, 15.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_
  - _Resources: Environment variable handling, contract deployment_

- [x] 15.4. Add proper parameter validation and deployment verification

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 15.1, 15.2, 15.3_
  - _Resources: Validation techniques, verification methods_

- [x] 15.5. Include contract address logging and verification preparation

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 15.1, 15.2, 15.3, 15.4_
  - _Resources: Logging techniques, verification preparation_

- [x] 15.6. Handle both testnet (with MockUSDT) and mainnet (with real USDT) deployments

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 15.1, 15.2, 15.3, 15.4, 15.5_
  - _Resources: Network configuration, deployment strategies_

- [x] 15.7. Test deployment script with local and testnet environments

  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_
  - _Resources: Testing environments, deployment verification_

### Task 16: Configure environment and deployment setup

**Status: Completed**

- [x] 16.1. Update .env.example with all required variables for Fixed Fund Split feature

  - _Urgency: 9, Impact: 10, Resources: 9, Priority: 9.4_
  - _Dependencies: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7_
  - _Resources: Environment variable documentation, text editor_

- [x] 16.2. Document private key, RPC URL, USDT address, and settlement wallet configuration

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 16.1_
  - _Resources: Documentation tools, configuration management_

- [x] 16.3. Add Etherscan API key configuration for contract verification

  - _Urgency: 7, Impact: 8, Resources: 8, Priority: 7.6_
  - _Dependencies: 16.1, 16.2_
  - _Resources: Etherscan API documentation, configuration management_

- [x] 16.4. Create deployment commands for different networks (local, testnet, mainnet)

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 16.1, 16.2, 16.3_
  - _Resources: Script documentation, command line tools_

- [x] 16.5. Document forge script commands for compilation, testing, and deployment

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 16.1, 16.2, 16.3, 16.4_
  - _Resources: Forge documentation, command line documentation_

- [x] 16.6. Add contract verification commands using forge verify-contract

  - _Urgency: 7, Impact: 8, Resources: 8, Priority: 7.6_
  - _Dependencies: 16.1, 16.2, 16.3, 16.4, 16.5_
  - _Resources: Forge verification documentation, Etherscan API_

### Task 17: Add final documentation and CLI commands

**Status: Completed**

- [x] 17.1. Document complete setup process from Foundry installation to deployment

  - _Urgency: 8, Impact: 9, Resources: 8, Priority: 8.6_
  - _Dependencies: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 16.1, 16.2, 16.3, 16.4, 16.5, 16.6_
  - _Resources: Documentation tools, setup procedures_

- [x] 17.2. Create step-by-step commands for project initialization and dependency installation

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 17.1_
  - _Resources: Command line documentation, tutorial creation_

- [x] 17.3. Document testing commands and expected output

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 17.1, 17.2_
  - _Resources: Testing documentation, output examples_

- [x] 17.4. Add deployment verification steps and troubleshooting guide

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 17.1, 17.2, 17.3_
  - _Resources: Verification procedures, troubleshooting techniques_

- [x] 17.5. Include post-deployment testing instructions for settlement wallet approval

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 17.1, 17.2, 17.3, 17.4_
  - _Resources: Post-deployment procedures, wallet approval documentation_

- [x] 17.6. Document contract interaction examples for deposit and redemption

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 17.1, 17.2, 17.3, 17.4, 17.5_
  - _Resources: Interaction examples, usage documentation_

---

## New Fixed Fund Split on Deposit Feature Tasks

### Task 18: Design Fixed Fund Split architecture

**Status: Completed**

- [x] 18.1. Design wallet distribution structure with 8 wallets and fixed percentages

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: None_
  - _Resources: Architecture design tools, percentage calculation tools_

- [x] 18.2. Define immutable fixed wallet addresses (investWallet, devOpsWallet, advisorWallet, marketingWallet, ownerWallet)

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 18.1_
  - _Resources: Solidity immutable variables, address management_

- [x] 18.3. Define dynamic MLM wallet addresses (level1Wallet, level2Wallet, level3Wallet)

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 18.1, 18.2_
  - _Resources: Solidity state variables, address management_

- [x] 18.4. Design atomic transaction structure for all USDT transfers

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 18.1, 18.2, 18.3_
  - _Resources: Transaction design, atomic transfer patterns_

- [x] 18.5. Design validation logic for MLM addresses (non-zero addresses)

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 18.1, 18.2, 18.3, 18.4_
  - _Resources: Validation design, address checking patterns_

- [x] 18.6. Design event structure for logging fund splits

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 18.1, 18.2, 18.3, 18.4, 18.5_
  - _Resources: Event design, logging patterns_

- [x] 18.7. Create architecture diagram and documentation
  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 18.1, 18.2, 18.3, 18.4, 18.5, 18.6_
  - _Resources: Diagram tools, documentation tools_

### Task 19: Implement Fixed Fund Split in DepositCertificate contract

**Status: Completed**

- [x] 19.1. Add immutable state variables for fixed wallet addresses

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 18.1, 18.2, 3.1, 3.2, 3.3_
  - _Resources: Solidity immutable variables, address management_

- [x] 19.2. Add state variables for dynamic MLM wallet addresses

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 18.1, 18.3, 19.1_
  - _Resources: Solidity state variables, address management_

- [x] 19.3. Add constants for wallet percentages (basis points)

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 18.1, 19.1, 19.2_
  - _Resources: Constant definition, percentage calculation_

- [x] 19.4. Update constructor to accept all wallet addresses

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 19.1, 19.2, 19.3, 3.5_
  - _Resources: Constructor design, parameter validation_

- [x] 19.5. Add function to update MLM wallet addresses (owner only)

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4_
  - _Resources: Access control, address validation_

- [x] 19.6. Implement fund split calculation function

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5_
  - _Resources: Mathematical calculation, percentage splitting_

- [x] 19.7. Update deposit function to use fund split logic

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_
  - _Resources: Function modification, atomic transfers_

- [x] 19.8. Add events for fund split operations

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7_
  - _Resources: Event definition, logging implementation_

- [x] 19.9. Add comprehensive error handling for fund split operations

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7, 19.8_
  - _Resources: Error handling, validation logic_

- [x] 19.10. Compile and verify updated DepositCertificate contract

  - _Urgency: 8, Impact: 8, Resources: 9, Priority: 8.2_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7, 19.8, 19.9_
  - _Resources: Solidity compiler, verification tools_

### Task 20: Create comprehensive tests for Fixed Fund Split feature

**Status: Completed**

- [x] 20.1. Create test file for Fixed Fund Split functionality

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7, 19.8, 19.9, 19.10_
  - _Resources: Test framework, test file structure_

- [x] 20.2. Set up test environment with multiple wallet addresses

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 20.1, 9.1, 9.2, 9.3_
  - _Resources: Test setup, address management_

- [x] 20.3. Test fund split calculation with various deposit amounts

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 20.1, 20.2, 19.6_
  - _Resources: Calculation testing, percentage verification_

- [x] 20.4. Test atomic transfers to all 8 wallets

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 20.1, 20.2, 20.3, 19.7_
  - _Resources: Transfer testing, balance verification_

- [x] 20.5. Test MLM wallet address updates

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 20.1, 20.2, 19.5_
  - _Resources: Address update testing, access control verification_

- [x] 20.6. Test validation for MLM addresses (non-zero addresses)

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 20.1, 20.2, 19.5, 19.9_
  - _Resources: Validation testing, error verification_

- [x] 20.7. Test event emission for fund split operations

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 20.1, 20.2, 20.3, 20.4, 19.8_
  - _Resources: Event testing, parameter verification_

- [x] 20.8. Test error conditions and edge cases

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7, 19.9_
  - _Resources: Error testing, edge case scenarios_

- [x] 20.9. Test integration with existing deposit and redemption functionality

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7, 20.8, 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 13.1, 13.2, 13.3, 13.4, 13.5, 13.6_
  - _Resources: Integration testing, regression testing_

### Task 21: Update deployment script for Fixed Fund Split feature

**Status: Completed**

- [x] 21.1. Update Deploy.s.sol to accept all 8 wallet addresses as parameters

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 19.1, 19.2, 19.3, 19.4_
  - _Resources: Script modification, parameter handling_

- [x] 21.2. Add validation for wallet addresses in deployment script

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 21.1, 19.4, 19.5_
  - _Resources: Validation logic, error handling_

- [x] 21.3. Update deployment logging to include all wallet addresses

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 21.1, 21.2, 15.5_
  - _Resources: Logging implementation, output formatting_

- [x] 21.4. Test updated deployment script with local and testnet environments

  - _Urgency: 9, Impact: 9, Resources: 9, Priority: 9.0_
  - _Dependencies: 21.1, 21.2, 21.3, 15.7_
  - _Resources: Testing environments, deployment verification_

### Task 22: Update environment configuration for Fixed Fund Split feature

**Status: Completed**

- [x] 22.1. Update .env.example with all 8 wallet address variables

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 16.1, 19.1, 19.2, 19.3, 19.4_
  - _Resources: Environment configuration, documentation_

- [x] 22.2. Document wallet address configuration requirements

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 22.1, 16.2_
  - _Resources: Documentation tools, configuration management_

- [x] 22.3. Update deployment documentation with new wallet address parameters

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 22.1, 22.2, 16.4, 16.5, 16.6_
  - _Resources: Documentation update, deployment procedures_

- [x] 22.4. Create example configuration files for different environments

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 22.1, 22.2, 22.3_
  - _Resources: Configuration templates, environment management_

### Task 23: Update documentation for Fixed Fund Split feature

**Status: Completed**

- [x] 23.1. Document Fixed Fund Split feature architecture and design

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 18.1, 18.2, 18.3, 18.4, 18.5, 18.6, 18.7, 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7, 19.8, 19.9, 19.10_
  - _Resources: Documentation tools, architecture diagrams_

- [x] 23.2. Document wallet distribution percentages and purposes

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 23.1, 18.1_
  - _Resources: Documentation tools, percentage tables_

- [x] 23.3. Document API for MLM wallet address updates

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 23.1, 19.5_
  - _Resources: API documentation, function signatures_

- [x] 23.4. Update setup documentation with new wallet configuration steps

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 23.1, 23.2, 23.3, 17.1, 17.2, 22.1, 22.2, 22.3, 22.4_
  - _Resources: Documentation update, setup procedures_

- [x] 23.5. Create usage examples for Fixed Fund Split feature

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 23.1, 23.2, 23.3, 23.4, 17.6_
  - _Resources: Example creation, usage documentation_

- [x] 23.6. Document testing procedures for Fixed Fund Split feature

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 23.1, 23.2, 23.3, 23.4, 23.5, 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7, 20.8, 20.9_
  - _Resources: Testing documentation, procedure creation_

### Task 24: Final integration and validation

**Status: Completed**

- [x] 24.1. Perform end-to-end testing of complete system with Fixed Fund Split feature

  - _Urgency: 10, Impact: 10, Resources: 9, Priority: 9.8_
  - _Dependencies: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6, 19.7, 19.8, 19.9, 19.10, 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7, 20.8, 20.9, 21.1, 21.2, 21.3, 21.4, 22.1, 22.2, 22.3, 22.4_
  - _Resources: Integration testing, end-to-end validation_

- [x] 24.2. Validate gas usage and optimize if necessary

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 24.1_
  - _Resources: Gas profiling, optimization techniques_

- [x] 24.3. Perform security review of Fixed Fund Split implementation

  - _Urgency: 9, Impact: 10, Resources: 8, Priority: 9.0_
  - _Dependencies: 24.1, 24.2_
  - _Resources: Security review tools, best practices_

- [x] 24.4. Update final documentation based on testing and review

  - _Urgency: 8, Impact: 8, Resources: 8, Priority: 8.0_
  - _Dependencies: 24.1, 24.2, 24.3, 23.1, 23.2, 23.3, 23.4, 23.5, 23.6_
  - _Resources: Documentation update, final review_

- [x] 24.5. Prepare final deployment package and instructions

  - _Urgency: 9, Impact: 9, Resources: 8, Priority: 8.8_
  - _Dependencies: 24.1, 24.2, 24.3, 24.4, 17.1, 17.2, 17.3, 17.4, 17.5, 17.6_
  - _Resources: Deployment packaging, instruction creation_
