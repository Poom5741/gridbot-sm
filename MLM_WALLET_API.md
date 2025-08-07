# MLM Wallet Address Update API

## Overview

The DepositCertificate contract provides a comprehensive API for managing Multi-Level Marketing (MLM) wallet addresses. This document details the functions, parameters, and usage patterns for updating MLM wallet addresses.

## API Functions

### 1. updateMLMWallets

**Description:**
Updates the MLM wallet addresses (Level1, Level2, Level3) in a single atomic operation. This function can only be called by the contract owner.

**Function Signature:**

```solidity
function updateMLMWallets(
    address level1Wallet,
    address level2Wallet,
    address level3Wallet
) external onlyOwner
```

**Parameters:**

- `level1Wallet` (address): The new address for Level1 wallet distribution
- `level2Wallet` (address): The new address for Level2 wallet distribution
- `level3Wallet` (address): The new address for Level3 wallet distribution

**Returns:**

- None

**Access Control:**

- `onlyOwner` modifier - only the contract owner can call this function

**Validation Rules:**

- All addresses must be non-zero (not the zero address)
- All addresses must be valid Ethereum addresses
- Updates are atomic - all three addresses are updated together or not at all

**Events Emitted:**

```solidity
event MLMWalletsUpdated(
    address indexed level1Wallet,
    address indexed level2Wallet,
    address indexed level3Wallet,
    uint256 timestamp
);
```

**Usage Example:**

```solidity
// Update all MLM wallet addresses in a single call
contract.updateMLMWallets(
    0x1234567890123456789012345678901234567890, // Level1
    0x2345678901234567890123456789012345678901, // Level2
    0x3456789012345667890123456789012345678902  // Level3
);
```

### 2. getMLMWallets

**Description:**
Retrieves the current MLM wallet addresses.

**Function Signature:**

```solidity
function getMLMWallets() external view returns (
    address level1Wallet,
    address level2Wallet,
    address level3Wallet
)
```

**Parameters:**

- None

**Returns:**

- `level1Wallet` (address): Current Level1 wallet address
- `level2Wallet` (address): Current Level2 wallet address
- `level3Wallet` (address): Current Level3 wallet address

**Access Control:**

- `external view` - can be called by anyone without modifying state

**Usage Example:**

```solidity
// Get current MLM wallet addresses
(address level1, address level2, address level3) = contract.getMLMWallets();
```

### 3. getWalletDistribution

**Description:**
Retrieves the complete wallet distribution structure including both immutable and dynamic addresses.

**Function Signature:**

```solidity
function getWalletDistribution() external view returns (
    address investWallet,
    address devOpsWallet,
    address advisorWallet,
    address marketingWallet,
    address ownerWallet,
    address level1Wallet,
    address level2Wallet,
    address level3Wallet
)
```

**Parameters:**

- None

**Returns:**

- `investWallet` (address): Investment wallet address
- `devOpsWallet` (address): DevOps wallet address
- `advisorWallet` (address): Advisor wallet address
- `marketingWallet` (address): Marketing wallet address
- `ownerWallet` (address): Owner wallet address
- `level1Wallet` (address): Current Level1 MLM wallet address
- `level2Wallet` (address): Current Level2 MLM wallet address
- `level3Wallet` (address): Current Level3 MLM wallet address

**Access Control:**

- `external view` - can be called by anyone without modifying state

**Usage Example:**

```solidity
// Get complete wallet distribution
(
    address invest,
    address devOps,
    address advisor,
    address marketing,
    address owner,
    address level1,
    address level2,
    address level3
) = contract.getWalletDistribution();
```

## API Usage Patterns

### 1. Basic Address Update

```solidity
// Update MLM wallets with new addresses
contract.updateMLMWallets(
    0x1234567890123456789012345678901234567890, // Level1
    0x2345678901234567890123456789012345678901, // Level2
    0x3456789012345678901234567890123456789012  // Level3
);
```

### 2. Conditional Update with Validation

```solidity
// Only update if new addresses are valid and different
address currentLevel1 = contract.getMLMWallets().level1Wallet;
if (newLevel1 != currentLevel1 && newLevel1 != address(0)) {
    contract.updateMLMWallets(newLevel1, newLevel2, newLevel3);
}
```

### 3. Batch Update with Multiple Wallets

```solidity
// Update MLM wallets from an array
address[3] memory newMLMWallets = [
    0x1234567890123456789012345678901234567890, // Level1
    0x2345678901234567890123456789012345678901, // Level2
    0x3456789012345678901234567890123456789012  // Level3
];
contract.updateMLMWallets(
    newMLMWallets[0],
    newMLMWallets[1],
    newMLMWallets[2]
);
```

### 4. Event Monitoring

```solidity
// Listen for MLM wallet update events
contract.on("MLMWalletsUpdated", function(level1, level2, level3, event) {
    console.log("MLM wallets updated:");
    console.log("Level1:", level1);
    console.log("Level2:", level2);
    console.log("Level3:", level3);
    console.log("Timestamp:", event.blockNumber);
});
```

## Error Handling

### Common Error Scenarios

1. **Zero Address Error**

   ```solidity
   // Error: MLM wallet address cannot be zero address
   contract.updateMLMWallets(address(0), level2, level3);
   ```

2. **Unauthorized Access Error**

   ```solidity
   // Error: Caller is not the owner
   contract.updateMLMWallets(level1, level2, level3); // Called by non-owner
   ```

3. **Invalid Address Error**
   ```solidity
   // Error: Invalid Ethereum address format
   contract.updateMLMWallets(
       0x1234, // Invalid address
       level2,
       level3
   );
   ```

### Error Codes

| Error Code       | Description                                      |
| ---------------- | ------------------------------------------------ |
| `InvalidAddress` | Provided address is not a valid Ethereum address |
| `ZeroAddress`    | Provided address is the zero address             |
| `Unauthorized`   | Caller is not the contract owner                 |
| `Revert`         | Transaction was reverted for other reasons       |

## Security Considerations

### 1. Access Control

- Only the contract owner can update MLM wallet addresses
- Owner address is set during contract deployment and cannot be changed
- Consider implementing multi-signature requirements for critical updates

### 2. Input Validation

- All addresses are validated for proper format
- Zero addresses are rejected
- Updates are atomic to prevent partial updates

### 3. Event Logging

- All updates are logged with timestamps
- Events include both old and new addresses for auditability
- Events can be monitored for real-time updates

### 4. Gas Optimization

- Single function call updates all three addresses
- No unnecessary storage operations
- Efficient validation logic

## Integration Examples

### 1. Web3.js Integration

```javascript
const Web3 = require("web3");
const web3 = new Web3("https://mainnet.infura.io/v3/YOUR_INFURA_KEY");

// Update MLM wallets
async function updateMLMWallets(contract, level1, level2, level3) {
  try {
    const tx = await contract.methods
      .updateMLMWallets(level1, level2, level3)
      .send({ from: ownerAddress });

    console.log("MLM wallets updated:", tx.transactionHash);
    return tx;
  } catch (error) {
    console.error("Error updating MLM wallets:", error);
    throw error;
  }
}

// Get current MLM wallets
async function getMLMWallets(contract) {
  try {
    const wallets = await contract.methods.getMLMWallets().call();
    return wallets;
  } catch (error) {
    console.error("Error getting MLM wallets:", error);
    throw error;
  }
}
```

### 2. Ethers.js Integration

```javascript
const { ethers } = require("ethers");

// Update MLM wallets
async function updateMLMWallets(contract, level1, level2, level3) {
  try {
    const tx = await contract.updateMLMWallets(level1, level2, level3);
    await tx.wait();

    console.log("MLM wallets updated:", tx.hash);
    return tx;
  } catch (error) {
    console.error("Error updating MLM wallets:", error);
    throw error;
  }
}

// Get current MLM wallets
async function getMLMWallets(contract) {
  try {
    const wallets = await contract.getMLMWallets();
    return wallets;
  } catch (error) {
    console.error("Error getting MLM wallets:", error);
    throw error;
  }
}
```

### 3. React Integration

```javascript
import { useState, useEffect } from "react";
import { useContract, useSigner } from "wagmi";

function MLMWalletManager({ contractAddress }) {
  const [level1, setLevel1] = useState("");
  const [level2, setLevel2] = useState("");
  const [level3, setLevel3] = useState("");
  const [currentWallets, setCurrentWallets] = useState({});

  const { data: signer } = useSigner();
  const contract = useContract({
    address: contractAddress,
    abi: DepositCertificateABI,
    signerOrProvider: signer,
  });

  // Get current MLM wallets
  const fetchMLMWallets = async () => {
    try {
      const wallets = await contract.getMLMWallets();
      setCurrentWallets({
        level1: wallets[0],
        level2: wallets[1],
        level3: wallets[2],
      });
    } catch (error) {
      console.error("Error fetching MLM wallets:", error);
    }
  };

  // Update MLM wallets
  const updateWallets = async () => {
    try {
      const tx = await contract.updateMLMWallets(level1, level2, level3);
      await tx.wait();
      await fetchMLMWallets();
    } catch (error) {
      console.error("Error updating MLM wallets:", error);
    }
  };

  useEffect(() => {
    fetchMLMWallets();
  }, []);

  return (
    <div>
      <h2>MLM Wallet Manager</h2>
      <div>
        <h3>Current Wallets:</h3>
        <p>Level1: {currentWallets.level1}</p>
        <p>Level2: {currentWallets.level2}</p>
        <p>Level3: {currentWallets.level3}</p>
      </div>
      <div>
        <h3>Update Wallets:</h3>
        <input
          type="text"
          placeholder="Level1 Address"
          value={level1}
          onChange={(e) => setLevel1(e.target.value)}
        />
        <input
          type="text"
          placeholder="Level2 Address"
          value={level2}
          onChange={(e) => setLevel2(e.target.value)}
        />
        <input
          type="text"
          placeholder="Level3 Address"
          value={level3}
          onChange={(e) => setLevel3(e.target.value)}
        />
        <button onClick={updateWallets}>Update</button>
      </div>
    </div>
  );
}
```

## Best Practices

### 1. Address Management

- Always validate addresses before updating
- Keep a record of all address changes
- Use multi-signature wallets for large amounts

### 2. Security

- Regularly monitor wallet activity
- Implement proper access controls
- Consider time-locked updates for critical changes

### 3. Monitoring

- Set up event monitoring for real-time updates
- Regularly audit wallet distributions
- Maintain comprehensive logs

### 4. Testing

- Test address updates in a development environment first
- Verify all addresses are properly formatted
- Test error conditions and edge cases

This API provides a comprehensive and secure way to manage MLM wallet addresses while maintaining transparency and auditability.
