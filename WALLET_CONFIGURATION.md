# Wallet Address Configuration Requirements

## Overview

The DepositCertificate contract implements a Fixed Fund Split feature that distributes deposits to 8 different wallet addresses according to predefined percentages. This document provides detailed requirements for configuring these wallet addresses.

## Wallet Types

### 1. Fixed Wallet Addresses (Immutable)

These addresses are set during contract deployment and cannot be changed afterward. They represent the core distribution structure of the platform.

| Wallet Variable            | Percentage | Purpose                    |
| -------------------------- | ---------- | -------------------------- |
| `INVEST_WALLET_ADDRESS`    | 55%        | Investment fund allocation |
| `DEVOPS_WALLET_ADDRESS`    | 5%         | Development and operations |
| `ADVISOR_WALLET_ADDRESS`   | 5%         | Advisory services          |
| `MARKETING_WALLET_ADDRESS` | 15%        | Marketing and promotion    |
| `OWNER_WALLET_ADDRESS`     | 5%         | Platform ownership         |

### 2. MLM Wallet Addresses (Dynamic)

These addresses can be updated by the contract owner after deployment. They are used for the Multi-Level Marketing distribution structure.

| Wallet Variable         | Percentage | Purpose                          |
| ----------------------- | ---------- | -------------------------------- |
| `LEVEL1_WALLET_ADDRESS` | 10%        | First level of MLM distribution  |
| `LEVEL2_WALLET_ADDRESS` | 3%         | Second level of MLM distribution |
| `LEVEL3_WALLET_ADDRESS` | 2%         | Third level of MLM distribution  |

## Configuration Requirements

### Address Format Requirements

All wallet addresses must:

1. **Be Valid Ethereum Addresses**

   - Start with `0x` prefix
   - Be exactly 42 characters long (including `0x`)
   - Contain only hexadecimal characters (0-9, a-f, A-F)
   - Pass basic checksum validation

2. **Be Non-Zero Addresses**

   - Cannot be the zero address (`0x0000000000000000000000000000000000000000`)
   - Cannot be null or empty

3. **Be Properly Funded**
   - Must have sufficient ETH balance to receive gas fees for transactions
   - For receiving USDT, must have ERC20 token approval if needed

### Security Requirements

1. **Private Key Security**

   - Never commit actual private keys to version control
   - Use environment variables for sensitive configuration
   - Consider using hardware wallets for large amounts

2. **Address Validation**

   - Verify all addresses on the target network before deployment
   - Test with small amounts before large deployments
   - Use multiple verification methods (checksum, balance check, etc.)

3. **Access Control**
   - MLM wallet addresses should be controlled by trusted parties
   - Consider using multi-signature wallets for high-value addresses
   - Implement proper access controls for address update functions

### Environment Configuration

#### .env File Structure

```bash
# Required for deployment
PRIVATE_KEY=0x...
RPC_URL=https://...
USDT_ADDRESS=0x...

# Fixed wallet addresses (immutable)
INVEST_WALLET_ADDRESS=0x...
DEVOPS_WALLET_ADDRESS=0x...
ADVISOR_WALLET_ADDRESS=0x...
MARKETING_WALLET_ADDRESS=0x...
OWNER_WALLET_ADDRESS=0x...

# MLM wallet addresses (dynamic)
LEVEL1_WALLET_ADDRESS=0x...
LEVEL2_WALLET_ADDRESS=0x...
LEVEL3_WALLET_ADDRESS=0x...

# Optional for contract verification
ETHERSCAN_API_KEY=...
```

#### .env.example File

The `.env.example` file provides a template with all required variables:

```bash
# Environment variables for ERC20 Deposit Certificate project
# Copy this file to .env and fill in your actual values

# Private key for deploying contracts (DO NOT commit actual private keys to version control)
PRIVATE_KEY=0xYOUR_PRIVATE_KEY_HERE

# RPC URL for the network you're deploying to
RPC_URL=https://your-rpc-url-here

# USDT contract address on the network you're deploying to
USDT_ADDRESS=0xUSDT_CONTRACT_ADDRESS_HERE

# Settlement wallet address for receiving funds
SETTLEMENT_WALLET_ADDRESS=0xSETTLEMENT_WALLET_ADDRESS_HERE

# Fixed fund split addresses (immutable)
INVEST_WALLET_ADDRESS=0xINVEST_WALLET_ADDRESS_HERE
DEVOPS_WALLET_ADDRESS=0xDEVOPS_WALLET_ADDRESS_HERE
ADVISOR_WALLET_ADDRESS=0xADVISOR_WALLET_ADDRESS_HERE
MARKETING_WALLET_ADDRESS=0xMARKETING_WALLET_ADDRESS_HERE
OWNER_WALLET_ADDRESS=0xOWNER_WALLET_ADDRESS_HERE

# MLM wallet addresses (can be updated by owner)
LEVEL1_WALLET_ADDRESS=0xLEVEL1_WALLET_ADDRESS_HERE
LEVEL2_WALLET_ADDRESS=0xLEVEL2_WALLET_ADDRESS_HERE
LEVEL3_WALLET_ADDRESS=0xLEVEL3_WALLET_ADDRESS_HERE

# Optional: Etherscan API key for contract verification
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY_HERE
```

## Network-Specific Considerations

### Testnet (e.g., Sepolia)

1. **Use Test Addresses**

   - Consider using disposable test addresses for testing
   - Use faucet tokens for testing USDT transfers
   - Test with small amounts first

2. **Mock Contracts**
   - Use MockUSDT for testing during development
   - Verify MockUSDT deployment before testing DepositCertificate

### Mainnet

1. **Production Addresses**

   - Use secure, well-funded production addresses
   - Implement proper security measures
   - Consider using time-locked addresses

2. **Real USDT**
   - Use the official USDT contract address for the target network
   - Ensure sufficient USDT balance in the settlement wallet
   - Verify USDT contract compatibility

## Validation and Testing

### Pre-Deployment Checklist

1. [ ] Validate all wallet address formats
2. [ ] Verify addresses have sufficient ETH balance for gas
3. [ ] Test with MockUSDT on testnet first
4. [ ] Verify contract deployment parameters
5. [ ] Test fund split calculations with sample amounts

### Post-Deployment Verification

1. [ ] Verify contract deployment on the correct network
2. [ ] Test fund split functionality with small deposits
3. [ ] Verify MLM address update functionality
4. [ ] Test error handling and edge cases
5. [ ] Monitor contract events for proper logging

## Troubleshooting

### Common Issues

1. **Invalid Address Format**

   - Error: "Invalid address format"
   - Solution: Verify all addresses follow the 0x... format and are 42 characters

2. **Zero Address Error**

   - Error: "Cannot use zero address"
   - Solution: Ensure no wallet address is set to 0x000...000

3. **Insufficient Gas**

   - Error: "insufficient funds for gas"
   - Solution: Ensure all receiving addresses have sufficient ETH balance

4. **USDT Transfer Failures**
   - Error: "USDT transfer failed"
   - Solution: Verify USDT contract address and token approval

## Best Practices

1. **Use Environment Variables**

   - Never hardcode addresses in source code
   - Use different .env files for different environments
   - Keep .env files in .gitignore

2. **Regular Security Audits**

   - Regularly review wallet address permissions
   - Monitor contract activity
   - Update MLM addresses as needed

3. **Documentation**

   - Keep detailed records of address assignments
   - Document the purpose of each wallet
   - Maintain change logs for address updates

4. **Backup and Recovery**
   - Maintain secure backups of private keys
   - Implement recovery procedures for lost access
   - Consider using multi-signature wallets for critical addresses
