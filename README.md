# DepositCertificate with Fixed Fund Split

A smart contract system for tokenized deposits with automatic fund distribution to 8 different wallet addresses according to fixed percentages.

## Features

- **Deposit Certificate System**: Tokenize deposits with automatic penalty calculation
- **Fixed Fund Split**: Automatic distribution of deposits to 8 wallet addresses with fixed percentages
- **Multi-Level Marketing (MLM)**: Support for dynamic MLM wallet address updates
- **Penalty System**: Calculate and apply penalties based on token transfer timestamps
- **Redemption**: Full and partial redemption of deposit certificates
- **Comprehensive Testing**: Full test suite with edge cases

## Fixed Fund Split Architecture

The contract implements a Fixed Fund Split architecture that distributes deposits to 8 different wallet addresses:

### Wallet Distribution Structure

| Wallet Type                            | Wallet Variable            | Percentage | Purpose                          |
| -------------------------------------- | -------------------------- | ---------- | -------------------------------- |
| **Fixed Wallet Addresses (Immutable)** |                            |            |
| Investment                             | `INVEST_WALLET_ADDRESS`    | 55%        | Investment fund allocation       |
| DevOps                                 | `DEVOPS_WALLET_ADDRESS`    | 5%         | Development and operations       |
| Advisor                                | `ADVISOR_WALLET_ADDRESS`   | 5%         | Advisory services                |
| Marketing                              | `MARKETING_WALLET_ADDRESS` | 15%        | Marketing and promotion          |
| Owner                                  | `OWNER_WALLET_ADDRESS`     | 5%         | Platform ownership               |
| **MLM Wallet Addresses (Dynamic)**     |                            |            |
| Level 1                                | `LEVEL1_WALLET_ADDRESS`    | 10%        | First level of MLM distribution  |
| Level 2                                | `LEVEL2_WALLET_ADDRESS`    | 3%         | Second level of MLM distribution |
| Level 3                                | `LEVEL3_WALLET_ADDRESS`    | 2%         | Third level of MLM distribution  |

### Key Features

- **Atomic Transactions**: All USDT transfers are executed atomically to ensure consistency
- **Immutable Fixed Addresses**: Investment, DevOps, Advisor, Marketing, and Owner addresses are set once during deployment
- **Dynamic MLM Addresses**: Level 1, 2, and 3 addresses can be updated by the contract owner
- **Comprehensive Validation**: All addresses are validated to be non-zero
- **Event Logging**: All fund split operations are logged for transparency

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

- [Foundry Book](https://book.getfoundry.sh/)
- [Wallet Configuration](./WALLET_CONFIGURATION.md)
- [Contract API](./docs/contract-api.md)
- [Deployment Guide](./docs/deployment.md)

## Setup

### Prerequisites

- Rust and Cargo
- Foundry toolkit

### Installation

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone the repository
git clone <repository-url>
cd gridbot-contract

# Install dependencies
forge install
```

### Configuration

1. Copy the environment template:

```bash
cp .env.example .env
```

2. Configure the environment variables in `.env`:

```bash
# Network Configuration
PRIVATE_KEY=your_private_key_here
RPC_URL=https://sepolia.infura.io/v3/your_infura_key
ETHERSCAN_API_KEY=your_etherscan_api_key

# USDT Configuration
USDT_ADDRESS=0x1234567890123456789012345678901234567890

# Settlement Wallet (for testing)
SETTLEMENT_WALLET_ADDRESS=0x1234567890123456789012345678901234567890

# Fixed Fund Split Wallet Addresses
# These addresses are immutable and should be set once during deployment
INVEST_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
DEVOPS_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
ADVISOR_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
MARKETING_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
OWNER_WALLET_ADDRESS=0x1234567890123456789012345678901234567890

# MLM Wallet Addresses (can be updated by owner after deployment)
LEVEL1_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
LEVEL2_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
LEVEL3_WALLET_ADDRESS=0x1234567890123456789012345678901234567890
```

For detailed wallet configuration requirements, see [Wallet Configuration](./WALLET_CONFIGURATION.md).

### Environment Configuration Files

For convenience, example configuration files are provided in the `configs/` directory:

- `configs/local.env` - Local development environment configuration
- `configs/sepolia.env` - Sepolia testnet environment configuration
- `configs/mainnet.env` - Ethereum mainnet environment configuration

Copy the appropriate file to `.env` and update the values:

```bash
# For local development
cp configs/local.env .env

# For Sepolia testnet
cp configs/sepolia.env .env

# For Ethereum mainnet
cp configs/mainnet.env .env
```

### Wallet Address Configuration

The Fixed Fund Split feature requires 8 wallet addresses with specific purposes:

**Immutable Addresses (set once during deployment):**

- Investment (55%): Primary investment fund allocation
- DevOps (5%): Development and operations costs
- Advisor (5%): Advisory services compensation
- Marketing (15%): Marketing and promotion budget
- Owner (5%): Platform ownership and maintenance

**Dynamic Addresses (can be updated by owner):**

- Level 1 (10%): First level of MLM distribution
- Level 2 (3%): Second level of MLM distribution
- Level 3 (2%): Third level of MLM distribution

Important: All wallet addresses must be valid Ethereum addresses (non-zero). The immutable addresses cannot be changed after deployment, while MLM addresses can be updated by the contract owner.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Run Specific Test

```shell
$ forge test --match-contract DepositCertificate -vvv
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

#### Local Deployment

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --private-key <your_private_key>
```

#### Testnet Deployment (Sepolia)

```shell
$ forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://sepolia.infura.io/v3/your_infura_key \
  --private-key <your_private_key> \
  --broadcast \
  --verify \
  --etherscan-api-key <your_etherscan_api_key>
```

#### Mainnet Deployment

```shell
$ forge script script/Deploy.s.sol:DeployScript \
  --rpc-url https://mainnet.infura.io/v3/your_infura_key \
  --private-key <your_private_key> \
  --broadcast \
  --verify \
  --etherscan-api-key <your_etherscan_api_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

## Contract Interaction

### Deposit

```solidity
// Deposit USDT and receive deposit certificates
function deposit(uint256 amount) external;
```

### Redeem

```solidity
// Redeem deposit certificates for USDT
function redeem(uint256 amount) external;
```

### Update MLM Wallet Addresses

```solidity
// Update MLM wallet addresses (owner only)
function updateMLMWalletAddresses(
    address level1Wallet,
    address level2Wallet,
    address level3Wallet
) external;
```

### Get Wallet Distribution

```solidity
// Get wallet distribution percentages
function getWalletDistribution() external view returns (
    uint256 investPercentage,
    uint256 devOpsPercentage,
    uint256 advisorPercentage,
    uint256 marketingPercentage,
    uint256 ownerPercentage,
    uint256 level1Percentage,
    uint256 level2Percentage,
    uint256 level3Percentage
);
```

## Testing

The project includes comprehensive tests covering:

- Deposit and redemption functionality
- Fixed Fund Split distribution
- MLM wallet address updates
- Penalty calculation
- Edge cases and error conditions

Run tests with:

```shell
# Run all tests
forge test

# Run tests with coverage
forge test --coverage

# Run tests with gas snapshot
forge test --gas-snapshot
```

## Security Considerations

- All wallet addresses must be carefully validated before deployment
- Private keys should be stored securely and never committed to version control
- The contract owner should use a secure, offline wallet for critical operations
- Regular security audits are recommended before mainnet deployment
- Consider implementing a time lock for critical operations

## License

This project is licensed under the MIT License.
