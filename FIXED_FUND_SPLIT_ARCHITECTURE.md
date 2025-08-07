# Fixed Fund Split Architecture

## Overview

The Fixed Fund Split feature is a core component of the DepositCertificate contract that implements an automated distribution system for deposited USDT tokens across 8 different wallet addresses according to predefined percentages. This feature ensures transparent, automated, and secure fund distribution with both immutable and dynamic wallet address management.

## Architecture Components

### 1. Wallet Distribution Structure

The Fixed Fund Split architecture manages 8 wallet addresses with the following distribution:

| Wallet Type | Address Type | Percentage | Purpose                              |
| ----------- | ------------ | ---------- | ------------------------------------ |
| Invest      | Immutable    | 55%        | Investment and development funding   |
| DevOps      | Immutable    | 5%         | Infrastructure and operational costs |
| Advisor     | Immutable    | 5%         | Advisory services and consultation   |
| Marketing   | Immutable    | 15%        | Marketing and promotional activities |
| Owner       | Immutable    | 5%         | Project ownership and management     |
| Level1      | Dynamic      | 10%        | First level of MLM distribution      |
| Level2      | Dynamic      | 3%         | Second level of MLM distribution     |
| Level3      | Dynamic      | 2%         | Third level of MLM distribution      |

### 2. Address Management Types

#### Immutable Addresses

- **Invest, DevOps, Advisor, Marketing, Owner** addresses
- Set once during contract deployment
- Cannot be changed after deployment
- Stored as immutable state variables
- Ensure long-term stability for core stakeholders

#### Dynamic Addresses

- **Level1, Level2, Level3** MLM addresses
- Can be updated by contract owner
- Stored as mutable state variables
- Enable flexible MLM structure management
- Require non-zero address validation

### 3. Atomic Transaction Structure

The fund split implementation uses an atomic transaction structure:

1. **Deposit Receipt**: User receives deposit certificates representing their deposit
2. **Fund Split Calculation**: System calculates exact distribution amounts based on percentages
3. **Atomic Transfer**: All 8 wallet transfers executed in a single transaction
4. **Event Logging**: All distribution events are logged for transparency

### 4. Validation Logic

#### Address Validation

- All addresses must be non-zero
- Dynamic addresses must be valid Ethereum addresses
- Owner address cannot be zero address
- Immutable addresses cannot be changed after deployment

#### Percentage Validation

- Total percentage must equal 100% (10,000 basis points)
- Individual percentages must be non-negative
- No single percentage can exceed 100%

#### Transfer Validation

- Sufficient USDT balance must be available
- Contract must have approval for token transfers
- All transfers must succeed atomically

### 5. Event Structure

The system emits comprehensive events for transparency:

```solidity
event FundSplitExecuted(
    address indexed depositor,
    uint256 totalAmount,
    uint256 investAmount,
    uint256 devOpsAmount,
    uint256 advisorAmount,
    uint256 marketingAmount,
    uint256 ownerAmount,
    uint256 level1Amount,
    uint256 level2Amount,
    uint256 level3Amount,
    uint256 timestamp
);

event MLMWalletsUpdated(
    address indexed level1Wallet,
    address indexed level2Wallet,
    address indexed level3Wallet,
    address indexed updatedBy,
    uint256 timestamp
);
```

### 6. Security Considerations

#### Atomicity Guarantees

- All transfers succeed or fail together
- No partial distribution scenarios
- User always receives complete deposit certificate

#### Access Control

- Only owner can update MLM wallet addresses
- Immutable addresses protected by constructor
- All functions have proper access control modifiers

#### Error Handling

- Comprehensive error messages for all failure scenarios
- Input validation for all parameters
- Revert on any validation failure

### 7. Integration Points

#### Deposit Flow Integration

- Deposit function automatically triggers fund split
- No separate fund split function required
- Seamless integration with existing deposit logic

#### Token Contract Integration

- Uses standard ERC20 transferFrom pattern
- Requires proper token approval before deposits
- Handles token transfer failures gracefully

#### Event System Integration

- Fund split events logged for transparency
- Integration with external monitoring systems
- Historical tracking of all distributions

## Design Benefits

1. **Transparency**: All distributions are logged and verifiable on-chain
2. **Automation**: No manual intervention required for fund distribution
3. **Security**: Atomic transactions ensure all-or-nothing distribution
4. **Flexibility**: Dynamic MLM addresses allow structure updates
5. **Stability**: Immutable addresses ensure long-term stakeholder stability
6. **Compliance**: Clear audit trail for all fund movements

## Usage Flow

1. **Configuration**: Set wallet addresses during deployment
2. **Deposit**: User deposits USDT, receives certificates
3. **Distribution**: System automatically splits funds to 8 wallets
4. **Logging**: All distributions logged with full details
5. **Updates**: Owner can update MLM addresses as needed

This architecture provides a robust, secure, and transparent fund distribution system that supports both the core business needs and flexible MLM structure management.
