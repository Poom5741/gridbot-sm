# Requirements Document

## Introduction

This feature implements an ERC-20 deposit certificate token system that allows users to deposit USDT and receive transferable certificate tokens. The system includes a time-based penalty mechanism for early redemption, encouraging long-term deposits. Users deposit USDT which is transferred to a settlement wallet, receive ERC-20 certificate tokens, and can later redeem these tokens for USDT with penalties applied based on holding duration.

## Requirements

### Requirement 1

**User Story:** As a user, I want to deposit USDT and receive transferable ERC-20 certificate tokens, so that I can participate in the deposit system while maintaining liquidity through token transfers.

#### Acceptance Criteria

1. WHEN a user calls the deposit function with a valid USDT amount THEN the system SHALL transfer the USDT from the user to the settlement wallet
2. WHEN USDT is successfully transferred to the settlement wallet THEN the system SHALL mint an equal amount of ERC-20 certificate tokens to the depositor
3. WHEN certificate tokens are minted THEN the system SHALL record the current timestamp as the user's deposit time
4. WHEN a user deposits USDT THEN the system SHALL use SafeERC20 for all USDT transfers to ensure security

### Requirement 2

**User Story:** As a certificate token holder, I want my deposit timestamp to be updated when I receive tokens through transfers, so that the penalty calculation reflects my actual holding period.

#### Acceptance Criteria

1. WHEN certificate tokens are transferred from one address to another THEN the system SHALL update the recipient's deposit timestamp to the current block timestamp
2. WHEN tokens are minted (from address zero) THEN the system SHALL update the recipient's deposit timestamp
3. WHEN tokens are burned (to address zero) THEN the system SHALL NOT update any timestamps
4. WHEN a user already holds tokens and receives additional tokens THEN the system SHALL update their timestamp to the current time

### Requirement 3

**User Story:** As a certificate token holder, I want to redeem my tokens for USDT with time-based penalties, so that I can exit the system while the protocol maintains incentives for long-term holding.

#### Acceptance Criteria

1. WHEN a user redeems tokens within 0-1 year THEN the system SHALL apply a 50% penalty rate
2. WHEN a user redeems tokens after exactly 5 years or more THEN the system SHALL apply a 0% penalty rate
3. WHEN a user redeems tokens between 1-5 years THEN the system SHALL apply a linear penalty decrease from 50% to 0%
4. WHEN calculating payout THEN the system SHALL use the formula: payout = amount \* (1 - penaltyRate)
5. WHEN redeeming tokens THEN the system SHALL burn the certificate tokens from the user's balance
6. WHEN redeeming tokens THEN the system SHALL transfer the calculated payout amount of USDT from the settlement wallet to the user
7. WHEN redeeming tokens THEN the system SHALL require the settlement wallet to have pre-approved the contract to spend USDT

### Requirement 4

**User Story:** As a system administrator, I want to deploy the system with proper configuration and testing infrastructure, so that the protocol can operate securely on mainnet and testnet environments.

#### Acceptance Criteria

1. WHEN deploying for testing THEN the system SHALL include a MockUSDT contract with 6 decimals
2. WHEN deploying the main contract THEN the system SHALL accept immutable USDT token address and settlement wallet address parameters
3. WHEN deploying THEN the system SHALL inherit from OpenZeppelin's ERC20 and Ownable contracts
4. WHEN configuring the system THEN the system SHALL support both testnet MockUSDT and mainnet USDT addresses
5. WHEN verifying deployment THEN the system SHALL support Etherscan contract verification

### Requirement 5

**User Story:** As a developer, I want comprehensive test coverage and deployment scripts, so that I can confidently deploy and maintain the system.

#### Acceptance Criteria

1. WHEN running tests THEN the system SHALL verify deposit functionality mints correct tokens and transfers USDT
2. WHEN running tests THEN the system SHALL verify token transfers update recipient timestamps correctly
3. WHEN running tests THEN the system SHALL verify penalty calculations for different time periods (0-1 year, 1-5 years, 5+ years)
4. WHEN running tests THEN the system SHALL verify redemption burns tokens and transfers correct USDT amounts
5. WHEN deploying THEN the system SHALL use environment variables for private keys, RPC URLs, and contract addresses
6. WHEN deploying THEN the system SHALL provide scripts for compilation, testing, deployment, and verification

### Requirement 6

**User Story:** As a settlement wallet operator, I want the system to handle USDT transfers securely and predictably, so that I can manage the protocol's USDT reserves effectively.

#### Acceptance Criteria

1. WHEN users deposit USDT THEN the system SHALL transfer all deposited USDT directly to the settlement wallet
2. WHEN users redeem tokens THEN the system SHALL transfer USDT from the settlement wallet to the user using transferFrom
3. WHEN handling USDT transfers THEN the system SHALL use OpenZeppelin's SafeERC20 library for all operations
4. WHEN the settlement wallet has insufficient USDT balance or approval THEN redemption transactions SHALL revert with appropriate error messages
5. WHEN calculating penalties THEN any penalty amount SHALL remain in the settlement wallet (not explicitly transferred)
