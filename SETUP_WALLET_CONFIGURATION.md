# Setup Documentation with Wallet Configuration

## Overview

This document provides a comprehensive setup guide for the DepositCertificate contract with the Fixed Fund Split feature. It includes all necessary steps for configuring wallet addresses, setting up the environment, and deploying the contract.

## Prerequisites

### System Requirements

- Node.js (v14 or higher)
- Foundry development environment
- Ethereum wallet (MetaMask, etc.)
- Testnet ETH for deployment (testnet) or Mainnet ETH (mainnet)

### Foundry Installation

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc

# Verify installation
foundryup
forge --version
```

## Environment Setup

### 1. Clone and Setup Repository

```bash
# Clone the repository
git clone <repository-url>
cd gridbot-contract

# Install dependencies
forge install
```

### 2. Environment Configuration

#### Create Environment File

```bash
# Copy the example environment file
cp .env.example .env
```

#### Configure Environment Variables

Edit the `.env` file with the following configuration:

```bash
# Network Configuration
PRIVATE_KEY=your_private_key_here
RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
NETWORK=mainnet

# Contract Configuration
USDT_ADDRESS=0xdAC17F958D2ee523a2206206994597C13D831ec7
SETTLEMENT_WALLET=0xYourSettlementWalletAddress

# Fixed Fund Split Wallet Addresses
INVEST_WALLET=0x1234567890123456789012345678901234567890
DEVOPS_WALLET=0x2345678901234567890123456789012345678901
ADVISOR_WALLET=0x3456789012345678901234567890123456789012
MARKETING_WALLET=0x4567890123456789012345678901234567890123
OWNER_WALLET=0x5678901234567890123456789012345678901234
LEVEL1_WALLET=0x6789012345678901234567890123456789012345
LEVEL2_WALLET=0x7890123456789012345678901234567890123456
LEVEL3_WALLET=0x8901234567890123456789012345678901234567

# Etherscan Configuration
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### 3. Wallet Address Configuration

#### Understanding Wallet Types

The Fixed Fund Split feature uses 8 different wallet addresses with specific purposes:

| Wallet Type | Percentage | Basis Points | Purpose                       | Address Type |
| ----------- | ---------- | ------------ | ----------------------------- | ------------ |
| Invest      | 55%        | 5500         | Investment allocation         | Immutable    |
| DevOps      | 5%         | 500          | Development and operations    | Immutable    |
| Advisor     | 5%         | 500          | Advisory services             | Immutable    |
| Marketing   | 15%        | 1500         | Marketing and promotion       | Immutable    |
| Owner       | 5%         | 500          | Contract owner fees           | Immutable    |
| Level1      | 10%        | 1000         | First level MLM distribution  | Dynamic      |
| Level2      | 3%         | 300          | Second level MLM distribution | Dynamic      |
| Level3      | 2%         | 200          | Third level MLM distribution  | Dynamic      |

#### Address Configuration Steps

1. **Prepare Wallet Addresses**

   - Create or identify the 8 wallet addresses
   - Ensure each wallet has sufficient balance for gas fees
   - For testnet, obtain test ETH from faucets

2. **Configure Immutable Addresses**

   - These addresses cannot be changed after contract deployment
   - Set them carefully as they will be permanent
   - Include: Invest, DevOps, Advisor, Marketing, Owner wallets

3. **Configure Dynamic Addresses**

   - These addresses can be updated by the contract owner
   - Set initial addresses for Level1, Level2, Level3 MLM wallets
   - Can be changed later using the `updateMLMWallets` function

4. **Validate Addresses**
   ```bash
   # Validate all addresses using forge
   forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
   ```

### 4. Configuration Examples

#### Testnet Configuration (Sepolia)

```bash
# .env.sepolia
PRIVATE_KEY=your_test_private_key
RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
NETWORK=sepolia
USDT_ADDRESS=0x1234567890123456789012345678901234567890  # MockUSDT for testing
SETTLEMENT_WALLET=0xYourTestSettlementWallet

# Fixed Fund Split Wallet Addresses (Testnet)
INVEST_WALLET=0x1234567890123456789012345678901234567890
DEVOPS_WALLET=0x2345678901234567890123456789012345678901
ADVISOR_WALLET=0x3456789012345678901234567890123456789012
MARKETING_WALLET=0x4567890123456789012345678901234567890123
OWNER_WALLET=0x5678901234567890123456789012345678901234
LEVEL1_WALLET=0x6789012345678901234567890123456789012345
LEVEL2_WALLET=0x7890123456789012345678901234567890123456
LEVEL3_WALLET=0x8901234567890123456789012345678901234567

ETHERSCAN_API_KEY=your_etherscan_api_key
```

#### Mainnet Configuration

```bash
# .env.mainnet
PRIVATE_KEY=your_mainnet_private_key
RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
NETWORK=mainnet
USDT_ADDRESS=0xdAC17F958D2ee523a2206206994597C13D831ec7  # Real USDT
SETTLEMENT_WALLET=0xYourMainnetSettlementWallet

# Fixed Fund Split Wallet Addresses (Mainnet)
INVEST_WALLET=0x1234567890123456789012345678901234567890
DEVOPS_WALLET=0x2345678901234567890123456789012345678901
ADVISOR_WALLET=0x3456789012345678901234567890123456789012
MARKETING_WALLET=0x4567890123456789012345678901234567890123
OWNER_WALLET=0x5678901234567890123456789012345678901234
LEVEL1_WALLET=0x6789012345678901234567890123456789012345
LEVEL2_WALLET=0x7890123456789012345678901234567890123456
LEVEL3_WALLET=0x8901234567890123456789012345678901234567

ETHERSCAN_API_KEY=your_etherscan_api_key
```

### 5. Deployment Process

#### Step 1: Compile Contracts

```bash
# Compile all contracts
forge build

# Compile specific contract
forge build src/DepositCertificate.sol
```

#### Step 2: Run Tests

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -vvv

# Run specific test file
forge test test/DepositCertificate.t.sol
```

#### Step 3: Deploy Contract

```bash
# Deploy to local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast

# Deploy to testnet
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify

# Deploy to mainnet
forge script script/Deploy.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

#### Step 4: Verify Contract

```bash
# Verify contract on Etherscan
forge verify-contract <contract_address> src/DepositCertificate.sol --constructor-args $(cast abi-encode "constructor(address,address,address,address,address,address,address,address,address,address)" $USDT_ADDRESS $SETTLEMENT_WALLET $INVEST_WALLET $DEVOPS_WALLET $ADVISOR_WALLET $MARKETING_WALLET $OWNER_WALLET $LEVEL1_WALLET $LEVEL2_WALLET $LEVEL3_WALLET) --etherscan-api-key $ETHERSCAN_API_KEY
```

### 6. Post-Deployment Configuration

#### 1. Verify Contract Deployment

```bash
# Check contract deployment
cast call <contract_address> "owner()(address)" --rpc-url $RPC_URL

# Check wallet configuration
cast call <contract_address> "getWalletDistribution()(address,address,address,address,address,address,address,address,address)" --rpc-url $RPC_URL
```

#### 2. Settle USDT Approval

```bash
# Approve the contract to spend USDT
cast send $USDT_ADDRESS "approve(address,uint256)" <contract_address> <amount> --private-key $PRIVATE_KEY --rpc-url $RPC_URL
```

#### 3. Test Fund Split

```bash
# Test with a small deposit amount
cast send <contract_address> "deposit(uint256)" 1000000000000000000 --private-key $PRIVATE_KEY --rpc-url $RPC_VALUE
```

### 7. Configuration Management

#### Environment File Management

```bash
# Create different environment files
cp .env.example .env.local
cp .env.example .env.sepolia
cp .env.example .env.mainnet

# Load environment variables
source .env.sepolia
```

#### Configuration Validation

```bash
# Validate all addresses
forge script script/ValidateConfig.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY

# Check configuration
cast call <contract_address> "getWalletDistribution()(address,address,address,address,address,address,address,address,address)" --rpc-url $RPC_URL
```

### 8. Troubleshooting

#### Common Issues

1. **Address Validation Errors**

   - Ensure all addresses are valid Ethereum addresses
   - Check for typos in address strings
   - Verify addresses have proper checksums

2. **Insufficient Balance**

   - Ensure the deployment wallet has sufficient ETH for gas fees
   - Check testnet ETH balance for test deployments

3. **Contract Verification Failures**

   - Verify constructor arguments match exactly
   - Check Etherscan API key validity
   - Ensure contract source code matches exactly

4. **USDT Approval Issues**
   - Ensure sufficient USDT balance in settlement wallet
   - Verify USDT contract address is correct
   - Check approval amount is sufficient for deposits

#### Debug Commands

```bash
# Debug transaction
cast receipt <tx_hash> --rpc-url $RPC_URL

# Debug failed transaction
cast debug <tx_hash> --rpc-url $RPC_URL

# Check contract state
cast storage <contract_address> <slot> --rpc-url $RPC_URL
```

### 9. Security Considerations

#### Wallet Security

- Use hardware wallets for large amounts
- Implement proper access controls
- Regularly review wallet addresses
- Monitor contract activity

#### Configuration Security

- Keep private keys secure
- Use environment variables for sensitive data
- Regularly rotate private keys
- Implement proper backup procedures

#### Contract Security

- Regularly audit contract code
- Monitor for suspicious activity
- Implement proper access controls
- Keep contract updated with latest security patches

### 10. Best Practices

#### Configuration Management

- Use version control for configuration files
- Document all wallet addresses and their purposes
- Regularly review and update configuration
- Maintain proper backup procedures

#### Deployment Process

- Test thoroughly on testnet before mainnet deployment
- Use proper validation for all parameters
- Maintain detailed deployment logs
- Implement proper rollback procedures

#### Monitoring and Maintenance

- Set up proper monitoring for contract activity
- Regularly review wallet distributions
- Maintain proper documentation
- Implement proper upgrade procedures

This setup documentation provides a comprehensive guide for configuring and deploying the DepositCertificate contract with the Fixed Fund Split feature. Follow these steps carefully to ensure proper setup and deployment.
