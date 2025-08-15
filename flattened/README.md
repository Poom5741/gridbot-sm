# Flattened Smart Contracts

This directory contains flattened versions of all smart contracts in the project, created using Foundry's `forge flatten` command. Flattened contracts combine all imports and dependencies into a single file for easier deployment and verification.

## Directory Structure

- `main-contracts/` - Production contracts that form the core functionality
- `mock-contracts/` - Mock contracts used for testing and development
- `test-contracts/` - Simple test contracts

## Contract Details

### Main Contracts

#### DepositCertificate.flattened.sol

- **Purpose**: Main contract for handling deposit certificates and fund distribution
- **Original Location**: `src/DepositCertificate.sol`
- **Dependencies**: OpenZeppelin ERC20, Math, SafeMath, and custom fund split logic
- **Status**: ✅ Compiled successfully

### Mock Contracts

#### MockFundSplit.flattened.sol

- **Purpose**: Mock implementation of fund splitting logic for testing
- **Original Location**: `src/MockFundSplit.sol`
- **Dependencies**: OpenZeppelin ERC20, Math, SafeMath
- **Status**: ✅ Compiled successfully

#### MockRejectTransfer.flattened.sol

- **Purpose**: Mock contract that simulates transfer rejections for testing error handling
- **Original Location**: `src/MockRejectTransfer.sol`
- **Dependencies**: OpenZeppelin ERC20
- **Status**: ✅ Compiled successfully

#### MockUSDT.flattened.sol

- **Purpose**: Mock USDT token with 6 decimals for testing
- **Original Location**: `src/MockUSDT.sol`
- **Dependencies**: OpenZeppelin ERC20
- **Status**: ✅ Compiled successfully

### Test Contracts

#### Counter.flattened.sol

- **Purpose**: Simple counter contract for basic testing
- **Original Location**: `src/Counter.sol`
- **Dependencies**: None
- **Status**: ✅ Compiled successfully

## Compilation Status

All flattened contracts compile successfully with Solc 0.8.20. The only warnings are about unused variables in test files, which is expected behavior.

## Usage

These flattened contracts can be used for:

- Contract deployment to networks
- Contract verification on block explorers
- Security audits
- Integration testing

## Notes

- Variable names have been updated from camelCase to snake_case for consistency
- All imports have been flattened into single files
- Original source files remain unchanged in the `src/` directory
- These flattened versions maintain the exact same functionality as the original contracts
