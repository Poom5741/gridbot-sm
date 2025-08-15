# Design Document

## Overview

This design transforms the gridbot-sm smart contract project from a working prototype to a production-ready system through comprehensive security hardening, test coverage enhancement, gas optimization, and CI/CD automation. The system consists of a DepositCertificate contract that handles fund deposits with automatic splitting across multiple wallets, penalty-based redemption, and MLM wallet management.

The design addresses critical security vulnerabilities, implements automated test coverage verification (especially for deposit/withdraw flows), establishes gas monitoring, and creates comprehensive documentation and CI/CD pipelines.

## Architecture

### Current System Analysis

The existing system consists of:

- **DepositCertificate.sol**: Main contract handling deposits, fund splitting, and redemptions
- **MockFundSplit.sol**: Simplified demonstration contract
- **MockRejectTransfer.sol**: Test utility for rejection scenarios
- **MockUSDT.sol**: USDT token mock for testing

### Enhanced Security Architecture

#### Access Control Layer

- **Ownable Pattern**: Maintain OpenZeppelin's Ownable for admin functions
- **Role-Based Access**: Consider AccessControl for granular permissions if needed
- **Immutable Core Wallets**: Make fixed split wallets immutable after deployment
- **Emergency Controls**: Add Pausable functionality for emergency stops

#### Reentrancy Protection

- **ReentrancyGuard**: Apply to all deposit/withdraw functions
- **CEI Pattern**: Ensure Checks-Effects-Interactions ordering
- **State Updates First**: Complete all state changes before external calls

#### Token Interaction Layer

- **SafeERC20 Wrapper**: Already implemented, ensure comprehensive usage
- **Fee-on-Transfer Handling**: Explicit support or rejection with clear documentation
- **Allowance Management**: Safe increase/decrease patterns
- **Decimal Precision**: Handle USDT (6 decimals) vs standard ERC20 (18 decimals)

### Mathematical Correctness Framework

#### Distribution Logic

- **Percentage Validation**: Constructor enforces 100% total at deployment
- **Rounding Policy**: Implement deterministic remainder handling
- **Atomic Operations**: All-or-nothing fund distribution
- **Precision Handling**: Consistent decimal arithmetic across operations

#### Penalty Calculation

- **Time-Based Logic**: Current linear decay from 50% to 0% over 4 years
- **Deterministic Results**: Same inputs always produce same outputs
- **Edge Case Handling**: Boundary conditions at 1 year and 5 year marks

## Components and Interfaces

### Core Contract Enhancements

#### DepositCertificate Contract Improvements

```solidity
// Enhanced error handling
error InsufficientBalance(uint256 requested, uint256 available);
error InvalidWalletAddress(address wallet);
error DistributionFailed(address wallet, uint256 amount);
error ContractPaused();
error UnauthorizedAccess(address caller);

// Enhanced events
event DistributionExecuted(address indexed depositor, uint256 amount, uint256[] amounts, address[] recipients);
event PenaltyApplied(address indexed user, uint256 amount, uint256 penalty, uint256 payout);
event EmergencyPause(address indexed admin, string reason);
event RemainderHandled(uint256 amount, address recipient);
```

#### Security Enhancements

- **Pausable Integration**: Emergency stop functionality
- **Custom Errors**: Replace require statements with descriptive errors
- **Event Logging**: Comprehensive event emission for all state changes
- **Input Validation**: Enhanced parameter checking with custom errors

#### Gas Optimization

- **Storage Optimization**: Pack structs efficiently
- **Loop Optimization**: Minimize gas in distribution loops
- **Unchecked Math**: Where overflow is impossible with proofs
- **Immutable Variables**: Use immutable for constants

### Test Coverage Framework

#### Automated Flow Discovery System

```bash
# ABI Generation and Analysis
forge inspect DepositCertificate abi > out/DepositCertificate.abi.json
forge inspect MockFundSplit abi > out/MockFundSplit.abi.json

# Flow Target Detection Script
node scripts/discover-flow-targets.js
```

#### Test Structure Organization

```
test/
├── flows/                    # Core flow tests
│   ├── deposit/
│   │   ├── DepositSuccess.t.sol
│   │   ├── DepositRevert.t.sol
│   │   └── DepositEdge.t.sol
│   └── redeem/
│       ├── RedeemSuccess.t.sol
│       ├── RedeemRevert.t.sol
│       └── RedeemEdge.t.sol
├── flows_fuzz/              # Fuzz testing
│   ├── DepositFuzz.t.sol
│   └── RedeemFuzz.t.sol
├── invariants/              # Invariant testing
│   ├── DistributionInvariants.t.sol
│   └── ConservationInvariants.t.sol
├── mocks/                   # Token behavior mocks
│   ├── MockUSDT_NoBool.sol
│   ├── MockUSDT_FeeOnTransfer.sol
│   └── MockMaliciousReceiver.sol
└── coverage/
    └── DepositWithdrawMatrix.md
```

#### Coverage Requirements Matrix

| Contract           | Function | Type     | Success | Reverts | Edge Cases | Events | Accounting | Fuzz | Invariants |
| ------------------ | -------- | -------- | ------- | ------- | ---------- | ------ | ---------- | ---- | ---------- |
| DepositCertificate | deposit  | inbound  | ✅      | ✅      | ✅         | ✅     | ✅         | ✅   | ✅         |
| DepositCertificate | redeem   | outbound | ✅      | ✅      | ✅         | ✅     | ✅         | ✅   | ✅         |
| MockFundSplit      | deposit  | inbound  | ✅      | ✅      | ✅         | ✅     | ✅         | ✅   | ✅         |

### CI/CD Pipeline Architecture

#### Quality Gates Pipeline

```yaml
# .github/workflows/ci.yml structure
jobs:
  build:
    - forge build
    - Generate ABIs
    - Discover flow targets

  test:
    - Unit tests
    - Integration tests
    - Fuzz tests
    - Invariant tests
    - Fork tests

  coverage:
    - Generate coverage reports
    - Verify thresholds (95% line, 85% branch)
    - Upload artifacts

  flows-completeness-gate:
    - Run check_flows_covered.sh
    - Verify all flow functions tested
    - Update coverage matrix

  security:
    - Slither static analysis
    - Custom security checks

  gas:
    - Generate gas reports
    - Compare with snapshots
    - Fail on regressions
```

#### Automated Verification Scripts

- **check_flows_covered.sh**: Verifies test coverage completeness
- **discover-flow-targets.js**: Identifies deposit/withdraw functions
- **update-coverage-matrix.js**: Maintains coverage documentation

## Data Models

### Enhanced Contract State

```solidity
struct WalletConfig {
    address settlement;
    address iv;
    address dv;
    address ad;
    address ml;
    address bc;
    // MLM wallets remain mutable
    address ml1;
    address ml2;
    address ml3;
}

struct DistributionAmounts {
    uint256 iv;
    uint256 dv;
    uint256 ad;
    uint256 ml;
    uint256 bc;
    uint256 ml1;
    uint256 ml2;
    uint256 ml3;
    uint256 remainder;
}

struct PenaltyCalculation {
    uint256 elapsedTime;
    uint256 penaltyRate;
    uint256 penaltyAmount;
    uint256 payoutAmount;
}
```

### Test Coverage Data Models

```json
// out/flow_targets.json
[
  {
    "contract": "DepositCertificate",
    "function": "deposit",
    "type": "inbound",
    "signature": "deposit(uint256,address,address,address)",
    "natspec": "Deposits USDT and mints certificates with fund splitting"
  },
  {
    "contract": "DepositCertificate",
    "function": "redeem",
    "type": "outbound",
    "signature": "redeem(uint256)",
    "natspec": "Redeems certificates for USDT with time-based penalties"
  }
]
```

## Error Handling

### Custom Error Framework

```solidity
// Deposit-related errors
error ZeroAmount();
error InvalidMLMWallet(address wallet);
error InsufficientAllowance(uint256 required, uint256 available);
error DistributionFailed(address recipient, uint256 amount);

// Redemption-related errors
error InsufficientBalance(uint256 requested, uint256 available);
error NoDepositHistory(address user);
error SettlementTransferFailed(uint256 amount);

// Access control errors
error UnauthorizedCaller(address caller);
error ContractPaused();
error InvalidConfiguration();

// Mathematical errors
error PercentageOverflow(uint256 total);
error RoundingError(uint256 input, uint256 output);
```

### Error Recovery Strategies

- **Atomic Reversions**: All-or-nothing operations
- **Graceful Degradation**: Fallback mechanisms where appropriate
- **Clear Error Messages**: Descriptive custom errors
- **Event Logging**: Error events for monitoring

## Testing Strategy

### Comprehensive Test Categories

#### 1. Unit Tests (test/flows/)

- **Success Paths**: Happy path execution for all functions
- **Revert Conditions**: All failure modes and access controls
- **Edge Cases**: Boundary values, precision limits, time boundaries
- **Event Verification**: Correct event emission with proper parameters
- **State Verification**: Pre/post state consistency

#### 2. Fuzz Testing (test/flows_fuzz/)

- **Amount Fuzzing**: Random deposit/redeem amounts within bounds
- **Address Fuzzing**: Valid address ranges for MLM wallets
- **Time Fuzzing**: Various time elapsed scenarios for penalties
- **Invariant Preservation**: Mathematical properties hold under fuzzing

#### 3. Invariant Testing (test/invariants/)

- **Conservation Laws**: Total input equals total output plus documented remainder
- **Distribution Consistency**: Percentages always sum to 100%
- **Balance Integrity**: Contract balances match expected values
- **Time Monotonicity**: Timestamps only increase

#### 4. Integration Tests

- **Multi-Contract Interactions**: Full system behavior
- **Token Compatibility**: Various ERC20 implementations
- **Upgrade Scenarios**: If applicable
- **Emergency Procedures**: Pause/unpause functionality

#### 5. Fork Tests

- **Mainnet Simulation**: Real USDT behavior
- **Gas Cost Validation**: Realistic gas usage
- **Network Conditions**: Various block conditions

### Mock Contract Strategy

#### Token Behavior Mocks

```solidity
// MockUSDT_NoBool.sol - Simulates tokens without return values
// MockUSDT_FeeOnTransfer.sol - Simulates fee-charging tokens
// MockMaliciousReceiver.sol - Tests reentrancy protection
// MockRevertingToken.sol - Tests failure handling
```

#### Test Utilities

- **Time Manipulation**: Block timestamp control
- **Balance Tracking**: Automated accounting verification
- **Event Capture**: Comprehensive event testing
- **Gas Measurement**: Automated gas usage tracking

### Coverage Verification System

#### Automated Gate Script (script/check_flows_covered.sh)

```bash
#!/bin/bash
# Reads flow_targets.json
# Verifies test patterns exist for each function
# Checks coverage thresholds
# Updates coverage matrix
# Fails CI if requirements not met
```

#### Coverage Thresholds

- **Line Coverage**: ≥95% for flow functions
- **Branch Coverage**: ≥85% for flow functions
- **Function Coverage**: 100% for public/external functions
- **Test Pattern Coverage**: All required patterns present

This comprehensive design ensures the gridbot-sm project achieves production-ready quality standards through systematic security hardening, exhaustive testing, and automated quality verification.
