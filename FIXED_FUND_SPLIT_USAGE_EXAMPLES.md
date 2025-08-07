# Fixed Fund Split Feature Usage Examples

This document provides practical examples of how to use the Fixed Fund Split feature in the DepositCertificate contract. These examples cover various scenarios from basic deposits to advanced wallet management.

## Table of Contents

- [Basic Deposit Example](#basic-deposit-example)
- [Large Deposit Example](#large-deposit-example)
- [MLM Wallet Update Example](#mlm-wallet-update-example)
- [Wallet Distribution Query Example](#wallet-distribution-query-example)
- [Event Monitoring Example](#event-monitoring-example)
- [React Integration Example](#react-integration-example)
- [Batch Operations Example](#batch-operations-example)
- [Error Handling Example](#error-handling-example)

## Basic Deposit Example

### Scenario

A user deposits 100 USDT into the DepositCertificate contract.

### Expected Distribution

- Invest Wallet: 55 USDT (55%)
- DevOps Wallet: 5 USDT (5%)
- Advisor Wallet: 5 USDT (5%)
- Marketing Wallet: 15 USDT (15%)
- Owner Wallet: 5 USDT (5%)
- Level1 Wallet: 10 USDT (10%)
- Level2 Wallet: 3 USDT (3%)
- Level3 Wallet: 2 USDT (2%)

### Web3.js Implementation

```javascript
const { ethers } = require("ethers");

// Configuration
const contractAddress = "0xYourContractAddress";
const privateKey = "your_private_key";
const rpcUrl = "https://mainnet.infura.io/v3/YOUR_INFURA_KEY";

// Create provider and signer
const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
const wallet = new ethers.Wallet(privateKey, provider);

// Contract ABI (simplified)
const contractABI = [
  "function deposit(uint256 amount) external",
  "function balanceOf(address account) external view returns (uint256)",
  "event Deposited(address indexed user, uint256 amount, uint256 penalty)",
  "event FundSplit(address indexed investWallet, address indexed devOpsWallet, address indexed advisorWallet, address indexed marketingWallet, address indexed ownerWallet, address indexed level1Wallet, address indexed level2Wallet, address indexed level3Wallet, uint256 totalAmount)",
];

// Create contract instance
const contract = new ethers.Contract(contractAddress, contractABI, wallet);

async function basicDepositExample() {
  try {
    // Deposit amount (100 USDT with 18 decimals)
    const depositAmount = ethers.utils.parseUnits("100", 18);

    console.log("Depositing 100 USDT...");
    console.log("Expected distribution:");
    console.log("- Invest Wallet: 55 USDT (55%)");
    console.log("- DevOps Wallet: 5 USDT (5%)");
    console.log("- Advisor Wallet: 5 USDT (5%)");
    console.log("- Marketing Wallet: 15 USDT (15%)");
    console.log("- Owner Wallet: 5 USDT (5%)");
    console.log("- Level1 Wallet: 10 USDT (10%)");
    console.log("- Level2 Wallet: 3 USDT (3%)");
    console.log("- Level3 Wallet: 2 USDT (2%)");

    // Execute deposit
    const tx = await contract.deposit(depositAmount);
    console.log("Transaction hash:", tx.hash);

    // Wait for transaction confirmation
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);

    // Check user balance
    const userBalance = await contract.balanceOf(wallet.address);
    console.log(
      "User balance after deposit:",
      ethers.utils.formatUnits(userBalance, 18),
      "USDT"
    );

    return receipt;
  } catch (error) {
    console.error("Deposit failed:", error);
    throw error;
  }
}

// Execute the example
basicDepositExample()
  .then((receipt) => {
    console.log("Deposit completed successfully!");
  })
  .catch((error) => {
    console.error("Example failed:", error);
  });
```

### Ethers.js Implementation

```typescript
import { ethers } from "ethers";

// Configuration
const contractAddress = "0xYourContractAddress";
const privateKey = "your_private_key";
const rpcUrl = "https://mainnet.infura.io/v3/YOUR_INFURA_KEY";

async function basicDepositExampleEthers() {
  // Setup provider and wallet
  const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
  const wallet = new ethers.Wallet(privateKey, provider);

  // Contract interface
  const contractInterface = new ethers.utils.Interface([
    "function deposit(uint256 amount) external",
    "function balanceOf(address account) external view returns (uint256)",
    "event Deposited(address indexed user, uint256 amount, uint256 penalty)",
    "event FundSplit(address indexed investWallet, address indexed devOpsWallet, address indexed advisorWallet, address indexed marketingWallet, address indexed ownerWallet, address indexed level1Wallet, address indexed level2Wallet, address indexed level3Wallet, uint256 totalAmount)",
  ]);

  // Contract instance
  const contract = new ethers.Contract(
    contractAddress,
    contractInterface,
    wallet
  );

  // Deposit amount
  const depositAmount = ethers.utils.parseUnits("100", 18);

  console.log("=== Basic Deposit Example ===");
  console.log("User:", wallet.address);
  console.log(
    "Deposit Amount:",
    ethers.utils.formatUnits(depositAmount, 18),
    "USDT"
  );

  // Get current wallet distribution
  const distribution = await contract.getWalletDistribution();
  console.log("Current wallet distribution:", distribution);

  // Execute deposit
  const tx = await contract.deposit(depositAmount);
  console.log("Transaction sent:", tx.hash);

  // Wait for confirmation
  const receipt = await tx.wait();
  console.log("Transaction confirmed in block:", receipt.blockNumber);

  // Check balance
  const balance = await contract.balanceOf(wallet.address);
  console.log("User balance:", ethers.utils.formatUnits(balance, 18), "USDT");

  return receipt;
}

// Execute the example
basicDepositExampleEthers()
  .then(() => console.log("Example completed successfully!"))
  .catch((error) => console.error("Example failed:", error));
```

## Large Deposit Example

### Scenario

A user deposits 10,000 USDT into the DepositCertificate contract.

### Expected Distribution

- Invest Wallet: 5,500 USDT (55%)
- DevOps Wallet: 500 USDT (5%)
- Advisor Wallet: 500 USDT (5%)
- Marketing Wallet: 1,500 USDT (15%)
- Owner Wallet: 500 USDT (5%)
- Level1 Wallet: 1,000 USDT (10%)
- Level2 Wallet: 300 USDT (3%)
- Level3 Wallet: 200 USDT (2%)

### Implementation

```javascript
async function largeDepositExample() {
  try {
    // Large deposit amount (10,000 USDT with 18 decimals)
    const depositAmount = ethers.utils.parseUnits("10000", 18);

    console.log("=== Large Deposit Example ===");
    console.log("Depositing 10,000 USDT...");

    // Calculate expected distribution
    const expectedDistribution = {
      invest: ethers.utils.parseUnits("5500", 18),
      devOps: ethers.utils.parseUnits("500", 18),
      advisor: ethers.utils.parseUnits("500", 18),
      marketing: ethers.utils.parseUnits("1500", 18),
      owner: ethers.utils.parseUnits("500", 18),
      level1: ethers.utils.parseUnits("1000", 18),
      level2: ethers.utils.parseUnits("300", 18),
      level3: ethers.utils.parseUnits("200", 18),
    };

    console.log("Expected distribution:");
    Object.entries(expectedDistribution).forEach(([wallet, amount]) => {
      console.log(
        `- ${
          wallet.charAt(0).toUpperCase() + wallet.slice(1)
        } Wallet: ${ethers.utils.formatUnits(amount, 18)} USDT (${(
          (ethers.utils.formatUnits(amount, 18) / 100) *
          100
        ).toFixed(1)}%)`
      );
    });

    // Execute deposit
    const tx = await contract.deposit(depositAmount);
    console.log("Transaction hash:", tx.hash);

    // Wait for confirmation
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);

    // Check user balance
    const userBalance = await contract.balanceOf(wallet.address);
    console.log(
      "User balance after deposit:",
      ethers.utils.formatUnits(userBalance, 18),
      "USDT"
    );

    return receipt;
  } catch (error) {
    console.error("Large deposit failed:", error);
    throw error;
  }
}
```

## MLM Wallet Update Example

### Scenario

The contract owner needs to update the MLM wallet addresses for a new distribution structure.

### Implementation

```javascript
// Contract ABI for MLM wallet management
const mlmABI = [
  "function updateMLMWallets(address level1Wallet, address level2Wallet, address level3Wallet) external",
  "function getMLMWallets() external view returns (address, address, address)",
  "event MLMWalletsUpdated(address indexed level1Wallet, address indexed level2Wallet, address indexed level3Wallet, address indexed owner)",
];

async function updateMLMWalletsExample() {
  try {
    // Create contract instance with MLM functions
    const mlmContract = new ethers.Contract(contractAddress, mlmABI, wallet);

    // New MLM wallet addresses
    const newLevel1Wallet = "0xNewLevel1WalletAddress";
    const newLevel2Wallet = "0xNewLevel2WalletAddress";
    const newLevel3Wallet = "0xNewLevel3WalletAddress";

    console.log("=== MLM Wallet Update Example ===");
    console.log("Current MLM wallets:");

    // Get current MLM wallets
    const currentMLMWallets = await mlmContract.getMLMWallets();
    console.log("Level1:", currentMLMWallets[0]);
    console.log("Level2:", currentMLMWallets[1]);
    console.log("Level3:", currentMLMWallets[2]);

    // Update MLM wallets (only owner can do this)
    console.log("\nUpdating MLM wallets...");
    console.log("New Level1:", newLevel1Wallet);
    console.log("New Level2:", newLevel2Wallet);
    console.log("New Level3:", newLevel3Wallet);

    // Execute update
    const tx = await mlmContract.updateMLMWallets(
      newLevel1Wallet,
      newLevel2Wallet,
      newLevel3Wallet
    );
    console.log("Transaction hash:", tx.hash);

    // Wait for confirmation
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);

    // Verify update
    const updatedMLMWallets = await mlmContract.getMLMWallets();
    console.log("\nUpdated MLM wallets:");
    console.log("Level1:", updatedMLMWallets[0]);
    console.log("Level2:", updatedMLMWallets[1]);
    console.log("Level3:", updatedMLMWallets[2]);

    return receipt;
  } catch (error) {
    console.error("MLM wallet update failed:", error);
    throw error;
  }
}
```

## Wallet Distribution Query Example

### Scenario

A user wants to check the current wallet distribution configuration.

### Implementation

```javascript
// Contract ABI for wallet distribution
const distributionABI = [
  "function getWalletDistribution() external view returns (address, address, address, address, address, address, address, address, address)",
  "function getWalletPercentages() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)",
];

async function queryWalletDistributionExample() {
  try {
    // Create contract instance with distribution functions
    const distributionContract = new ethers.Contract(
      contractAddress,
      distributionABI,
      provider
    );

    console.log("=== Wallet Distribution Query Example ===");

    // Get wallet addresses
    const walletDistribution =
      await distributionContract.getWalletDistribution();
    const [
      usdtAddress,
      settlementWallet,
      investWallet,
      devOpsWallet,
      advisorWallet,
      marketingWallet,
      ownerWallet,
      level1Wallet,
      level2Wallet,
      level3Wallet,
    ] = walletDistribution;

    console.log("Wallet Addresses:");
    console.log("USDT:", usdtAddress);
    console.log("Settlement Wallet:", settlementWallet);
    console.log("Invest Wallet:", investWallet);
    console.log("DevOps Wallet:", devOpsWallet);
    console.log("Advisor Wallet:", advisorWallet);
    console.log("Marketing Wallet:", marketingWallet);
    console.log("Owner Wallet:", ownerWallet);
    console.log("Level1 Wallet:", level1Wallet);
    console.log("Level2 Wallet:", level2Wallet);
    console.log("Level3 Wallet:", level3Wallet);

    // Get wallet percentages
    const percentages = await distributionContract.getWalletPercentages();
    const [
      investPercentage,
      devOpsPercentage,
      advisorPercentage,
      marketingPercentage,
      ownerPercentage,
      level1Percentage,
      level2Percentage,
      level3Percentage,
    ] = percentages;

    console.log("\nWallet Percentages (basis points):");
    console.log(
      "Invest:",
      investPercentage.toString(),
      "(",
      (investPercentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "DevOps:",
      devOpsPercentage.toString(),
      "(",
      (devOpsPercentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "Advisor:",
      advisorPercentage.toString(),
      "(",
      (advisorPercentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "Marketing:",
      marketingPercentage.toString(),
      "(",
      (marketingPercentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "Owner:",
      ownerPercentage.toString(),
      "(",
      (ownerPercentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "Level1:",
      level1Percentage.toString(),
      "(",
      (level1Percentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "Level2:",
      level2Percentage.toString(),
      "(",
      (level2Percentage / 100).toFixed(1),
      "%)"
    );
    console.log(
      "Level3:",
      level3Percentage.toString(),
      "(",
      (level3Percentage / 100).toFixed(1),
      "%)"
    );

    // Calculate total percentage
    const totalPercentage =
      investPercentage +
      devOpsPercentage +
      advisorPercentage +
      marketingPercentage +
      ownerPercentage +
      level1Percentage +
      level2Percentage +
      level3Percentage;

    console.log(
      "\nTotal Percentage:",
      totalPercentage.toString(),
      "basis points (",
      (totalPercentage / 100).toFixed(1),
      "%)"
    );

    return {
      addresses: walletDistribution,
      percentages: percentages,
    };
  } catch (error) {
    console.error("Wallet distribution query failed:", error);
    throw error;
  }
}
```

## Event Monitoring Example

### Scenario

A user wants to monitor deposit and fund split events in real-time.

### Implementation

```javascript
// Contract ABI with events
const eventABI = [
  "event Deposited(address indexed user, uint256 amount, uint256 penalty)",
  "event FundSplit(address indexed investWallet, address indexed devOpsWallet, address indexed advisorWallet, address indexed marketingWallet, address indexed ownerWallet, address indexed level1Wallet, address indexed level2Wallet, address indexed level3Wallet, uint256 totalAmount)",
  "event MLMWalletsUpdated(address indexed level1Wallet, address indexed level2Wallet, address indexed level3Wallet, address indexed owner)",
];

async function monitorEventsExample() {
  try {
    // Create contract instance with events
    const eventContract = new ethers.Contract(
      contractAddress,
      eventABI,
      provider
    );

    console.log("=== Event Monitoring Example ===");

    // Set up event listeners
    eventContract.on("Deposited", (user, amount, penalty, event) => {
      console.log("\n=== Deposited Event ===");
      console.log("User:", user);
      console.log("Amount:", ethers.utils.formatUnits(amount, 18), "USDT");
      console.log("Penalty:", ethers.utils.formatUnits(penalty, 18), "USDT");
      console.log("Transaction Hash:", event.transactionHash);
      console.log("Block Number:", event.blockNumber);
    });

    eventContract.on(
      "FundSplit",
      (
        investWallet,
        devOpsWallet,
        advisorWallet,
        marketingWallet,
        ownerWallet,
        level1Wallet,
        level2Wallet,
        level3Wallet,
        totalAmount,
        event
      ) => {
        console.log("\n=== Fund Split Event ===");
        console.log("Invest Wallet:", investWallet);
        console.log("DevOps Wallet:", devOpsWallet);
        console.log("Advisor Wallet:", advisorWallet);
        console.log("Marketing Wallet:", marketingWallet);
        console.log("Owner Wallet:", ownerWallet);
        console.log("Level1 Wallet:", level1Wallet);
        console.log("Level2 Wallet:", level2Wallet);
        console.log("Level3 Wallet:", level3Wallet);
        console.log(
          "Total Amount:",
          ethers.utils.formatUnits(totalAmount, 18),
          "USDT"
        );
        console.log("Transaction Hash:", event.transactionHash);
        console.log("Block Number:", event.blockNumber);
      }
    );

    eventContract.on(
      "MLMWalletsUpdated",
      (level1Wallet, level2Wallet, level3Wallet, owner, event) => {
        console.log("\n=== MLM Wallets Updated Event ===");
        console.log("Level1 Wallet:", level1Wallet);
        console.log("Level2 Wallet:", level2Wallet);
        console.log("Level3 Wallet:", level3Wallet);
        console.log("Owner:", owner);
        console.log("Transaction Hash:", event.transactionHash);
        console.log("Block Number:", event.blockNumber);
      }
    );

    console.log("Event monitoring started. Listening for events...");

    // Monitor for 5 minutes
    await new Promise((resolve) => setTimeout(resolve, 5 * 60 * 1000));

    // Remove event listeners
    eventContract.removeAllListeners();
    console.log("Event monitoring stopped.");
  } catch (error) {
    console.error("Event monitoring failed:", error);
    throw error;
  }
}
```

## React Integration Example

### Scenario

A React application that allows users to deposit USDT and view their balance.

### React Component Implementation

```jsx
import React, { useState, useEffect } from "react";
import { ethers } from "ethers";

const DepositCertificateApp = () => {
  const [contract, setContract] = useState(null);
  const [provider, setProvider] = useState(null);
  const [account, setAccount] = useState("");
  const [balance, setBalance] = useState("0");
  const [depositAmount, setDepositAmount] = useState("");
  const [isDepositing, setIsDepositing] = useState(false);
  const [walletDistribution, setWalletDistribution] = useState({});
  const [error, setError] = useState("");

  // Contract address
  const CONTRACT_ADDRESS = "0xYourContractAddress";

  // Initialize
  useEffect(() => {
    const init = async () => {
      try {
        // Check if MetaMask is installed
        if (window.ethereum) {
          // Create provider
          const provider = new ethers.providers.Web3Provider(window.ethereum);
          setProvider(provider);

          // Get signer
          const signer = provider.getSigner();

          // Create contract instance
          const contract = new ethers.Contract(
            CONTRACT_ADDRESS,
            [
              "function deposit(uint256 amount) external",
              "function balanceOf(address account) external view returns (uint256)",
              "function getWalletDistribution() external view returns (address, address, address, address, address, address, address, address, address)",
              "event Deposited(address indexed user, uint256 amount, uint256 penalty)",
              "event FundSplit(address indexed investWallet, address indexed devOpsWallet, address indexed advisorWallet, address indexed marketingWallet, address indexed ownerWallet, address indexed level1Wallet, address indexed level2Wallet, address indexed level3Wallet, uint256 totalAmount)",
            ],
            signer
          );
          setContract(contract);

          // Get accounts
          const accounts = await provider.send("eth_requestAccounts", []);
          setAccount(accounts[0]);

          // Get balance
          const userBalance = await contract.balanceOf(accounts[0]);
          setBalance(ethers.utils.formatUnits(userBalance, 18));

          // Get wallet distribution
          const distribution = await contract.getWalletDistribution();
          setWalletDistribution({
            invest: distribution[2],
            devOps: distribution[3],
            advisor: distribution[4],
            marketing: distribution[5],
            owner: distribution[6],
            level1: distribution[7],
            level2: distribution[8],
            level3: distribution[9],
          });

          // Set up event listeners
          contract.on("Deposited", (user, amount, penalty) => {
            console.log(
              "Deposited:",
              ethers.utils.formatUnits(amount, 18),
              "USDT"
            );
            // Update balance
            contract.balanceOf(accounts[0]).then((newBalance) => {
              setBalance(ethers.utils.formatUnits(newBalance, 18));
            });
          });

          contract.on(
            "FundSplit",
            (
              investWallet,
              devOpsWallet,
              advisorWallet,
              marketingWallet,
              ownerWallet,
              level1Wallet,
              level2Wallet,
              level3Wallet,
              totalAmount
            ) => {
              console.log(
                "Fund split:",
                ethers.utils.formatUnits(totalAmount, 18),
                "USDT"
              );
            }
          );
        } else {
          setError("Please install MetaMask!");
        }
      } catch (err) {
        console.error("Initialization error:", err);
        setError("Failed to initialize: " + err.message);
      }
    };

    init();

    // Cleanup
    return () => {
      if (contract) {
        contract.removeAllListeners();
      }
    };
  }, []);

  const handleDeposit = async () => {
    if (!contract || !depositAmount) return;

    try {
      setIsDepositing(true);
      setError("");

      // Parse deposit amount
      const amount = ethers.utils.parseUnits(depositAmount, 18);

      // Execute deposit
      const tx = await contract.deposit(amount);

      // Wait for confirmation
      await tx.wait();

      // Update balance
      const userBalance = await contract.balanceOf(account);
      setBalance(ethers.utils.formatUnits(userBalance, 18));

      // Reset deposit amount
      setDepositAmount("");

      console.log("Deposit successful!");
    } catch (err) {
      console.error("Deposit error:", err);
      setError("Deposit failed: " + err.message);
    } finally {
      setIsDepositing(false);
    }
  };

  const formatAddress = (address) => {
    return address ? `${address.slice(0, 6)}...${address.slice(-4)}` : "";
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-3xl font-bold mb-6">
        Deposit Certificate with Fixed Fund Split
      </h1>

      {error && (
        <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* User Info */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-4">User Information</h2>
          <div className="space-y-2">
            <p>
              <strong>Account:</strong> {formatAddress(account)}
            </p>
            <p>
              <strong>Balance:</strong> {balance} USDT
            </p>
          </div>
        </div>

        {/* Deposit Form */}
        <div className="bg-white p-6 rounded-lg shadow">
          <h2 className="text-xl font-semibold mb-4">Deposit USDT</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Amount (USDT)
              </label>
              <input
                type="number"
                value={depositAmount}
                onChange={(e) => setDepositAmount(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter amount"
                step="0.01"
                min="0"
              />
            </div>
            <button
              onClick={handleDeposit}
              disabled={isDepositing || !depositAmount}
              className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed"
            >
              {isDepositing ? "Depositing..." : "Deposit"}
            </button>
          </div>
        </div>
      </div>

      {/* Wallet Distribution */}
      <div className="mt-6 bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-4">Wallet Distribution</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Invest (55%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.invest)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">DevOps (5%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.devOps)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Advisor (5%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.advisor)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Marketing (15%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.marketing)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Owner (5%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.owner)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Level1 (10%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.level1)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Level2 (3%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.level2)}
            </p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <h3 className="font-medium">Level3 (2%)</h3>
            <p className="text-sm text-gray-600">
              {formatAddress(walletDistribution.level3)}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DepositCertificateApp;
```

## Batch Operations Example

### Scenario

A user wants to perform multiple deposits in a single transaction.

### Implementation

```javascript
// Contract ABI for batch operations
const batchABI = [
  "function deposit(uint256 amount) external",
  "function batchDeposits(address[] users, uint256[] amounts) external",
];

async function batchDepositsExample() {
  try {
    // Create contract instance
    const batchContract = new ethers.Contract(
      contractAddress,
      batchABI,
      wallet
    );

    // Multiple users and amounts
    const users = [
      "0xUser1Address",
      "0xUser2Address",
      "0xUser3Address",
      "0xUser4Address",
      "0xUser5Address",
    ];

    const amounts = [
      ethers.utils.parseUnits("100", 18), // 100 USDT
      ethers.utils.parseUnits("250", 18), // 250 USDT
      ethers.utils.parseUnits("500", 18), // 500 USDT
      ethers.utils.parseUnits("1000", 18), // 1000 USDT
      ethers.utils.parseUnits("2000", 18), // 2000 USDT
    ];

    console.log("=== Batch Deposits Example ===");
    console.log("Processing", users.length, "deposits...");

    // Calculate total distribution
    let totalDistribution = {
      invest: ethers.BigNumber.from(0),
      devOps: ethers.BigNumber.from(0),
      advisor: ethers.BigNumber.from(0),
      marketing: ethers.BigNumber.from(0),
      owner: ethers.BigNumber.from(0),
      level1: ethers.BigNumber.from(0),
      level2: ethers.BigNumber.from(0),
      level3: ethers.BigNumber.from(0),
    };

    amounts.forEach((amount, index) => {
      const invest = amount.mul(55).div(100);
      const devOps = amount.mul(5).div(100);
      const advisor = amount.mul(5).div(100);
      const marketing = amount.mul(15).div(100);
      const owner = amount.mul(5).div(100);
      const level1 = amount.mul(10).div(100);
      const level2 = amount.mul(3).div(100);
      const level3 = amount.mul(2).div(100);

      totalDistribution.invest = totalDistribution.invest.add(invest);
      totalDistribution.devOps = totalDistribution.devOps.add(devOps);
      totalDistribution.advisor = totalDistribution.advisor.add(advisor);
      totalDistribution.marketing = totalDistribution.marketing.add(marketing);
      totalDistribution.owner = totalDistribution.owner.add(owner);
      totalDistribution.level1 = totalDistribution.level1.add(level1);
      totalDistribution.level2 = totalDistribution.level2.add(level2);
      totalDistribution.level3 = totalDistribution.level3.add(level3);

      console.log(`\nDeposit ${index + 1}:`);
      console.log(`User: ${users[index]}`);
      console.log(`Amount: ${ethers.utils.formatUnits(amount, 18)} USDT`);
      console.log(
        `- Invest: ${ethers.utils.formatUnits(invest, 18)} USDT (55%)`
      );
      console.log(
        `- DevOps: ${ethers.utils.formatUnits(devOps, 18)} USDT (5%)`
      );
      console.log(
        `- Advisor: ${ethers.utils.formatUnits(advisor, 18)} USDT (5%)`
      );
      console.log(
        `- Marketing: ${ethers.utils.formatUnits(marketing, 18)} USDT (15%)`
      );
      console.log(`- Owner: ${ethers.utils.formatUnits(owner, 18)} USDT (5%)`);
      console.log(
        `- Level1: ${ethers.utils.formatUnits(level1, 18)} USDT (10%)`
      );
      console.log(
        `- Level2: ${ethers.utils.formatUnits(level2, 18)} USDT (3%)`
      );
      console.log(
        `- Level3: ${ethers.utils.formatUnits(level3, 18)} USDT (2%)`
      );
    });

    console.log("\nTotal Distribution:");
    console.log(
      `- Invest: ${ethers.utils.formatUnits(
        totalDistribution.invest,
        18
      )} USDT (55%)`
    );
    console.log(
      `- DevOps: ${ethers.utils.formatUnits(
        totalDistribution.devOps,
        18
      )} USDT (5%)`
    );
    console.log(
      `- Advisor: ${ethers.utils.formatUnits(
        totalDistribution.advisor,
        18
      )} USDT (5%)`
    );
    console.log(
      `- Marketing: ${ethers.utils.formatUnits(
        totalDistribution.marketing,
        18
      )} USDT (15%)`
    );
    console.log(
      `- Owner: ${ethers.utils.formatUnits(
        totalDistribution.owner,
        18
      )} USDT (5%)`
    );
    console.log(
      `- Level1: ${ethers.utils.formatUnits(
        totalDistribution.level1,
        18
      )} USDT (10%)`
    );
    console.log(
      `- Level2: ${ethers.utils.formatUnits(
        totalDistribution.level2,
        18
      )} USDT (3%)`
    );
    console.log(
      `- Level3: ${ethers.utils.formatUnits(
        totalDistribution.level3,
        18
      )} USDT (2%)`
    );

    // Execute batch deposits
    const tx = await batchContract.batchDeposits(users, amounts);
    console.log("\nTransaction hash:", tx.hash);

    // Wait for confirmation
    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);

    return receipt;
  } catch (error) {
    console.error("Batch deposits failed:", error);
    throw error;
  }
}
```

## Error Handling Example

### Scenario

Handling various error scenarios that can occur when using the Fixed Fund Split feature.

### Implementation

```javascript
async function errorHandlingExample() {
  try {
    console.log("=== Error Handling Example ===");

    // Example 1: Invalid deposit amount
    try {
      console.log("\n1. Testing invalid deposit amount...");
      const invalidAmount = ethers.utils.parseUnits("0", 18);
      await contract.deposit(invalidAmount);
      console.log("ERROR: Should have failed with zero amount");
    } catch (error) {
      console.log("✓ Correctly caught zero amount error:", error.message);
    }

    // Example 2: Insufficient balance
    try {
      console.log("\n2. Testing insufficient balance...");
      const largeAmount = ethers.utils.parseUnits("1000000", 18); // 1M USDT
      await contract.deposit(largeAmount);
      console.log("ERROR: Should have failed with insufficient balance");
    } catch (error) {
      console.log(
        "✓ Correctly caught insufficient balance error:",
        error.message
      );
    }

    // Example 3: Invalid MLM wallet update (non-owner)
    try {
      console.log("\n3. Testing invalid MLM wallet update (non-owner)...");
      const notOwnerWallet = new ethers.Wallet(
        "0xNotOwnerPrivateKey",
        provider
      );
      const notOwnerContract = new ethers.Contract(
        contractAddress,
        mlmABI,
        notOwnerWallet
      );

      await notOwnerContract.updateMLMWallets(
        "0xNewLevel1Wallet",
        "0xNewLevel2Wallet",
        "0xNewLevel3Wallet"
      );
      console.log("ERROR: Should have failed with non-owner");
    } catch (error) {
      console.log("✓ Correctly caught non-owner error:", error.message);
    }

    // Example 4: Invalid MLM wallet address (zero address)
    try {
      console.log("\n4. Testing invalid MLM wallet address (zero address)...");
      await contract.updateMLMWallets(
        ethers.constants.AddressZero,
        "0xNewLevel2Wallet",
        "0xNewLevel3Wallet"
      );
      console.log("ERROR: Should have failed with zero address");
    } catch (error) {
      console.log("✓ Correctly caught zero address error:", error.message);
    }

    // Example 5: Contract call failure
    try {
      console.log("\n5. Testing contract call failure...");
      // Use a non-existent function
      await contract.callStatic("nonExistentFunction");
      console.log("ERROR: Should have failed with non-existent function");
    } catch (error) {
      console.log(
        "✓ Correctly caught non-existent function error:",
        error.message
      );
    }

    // Example 6: Transaction revert with reason
    try {
      console.log("\n6. Testing transaction revert with reason...");
      // This should revert with a specific reason
      await contract.deposit(ethers.utils.parseUnits("-1", 18));
      console.log("ERROR: Should have failed with negative amount");
    } catch (error) {
      console.log("✓ Correctly caught revert error:", error.message);
    }

    console.log("\n✓ All error handling tests completed successfully!");
  } catch (error) {
    console.error("Error handling example failed:", error);
    throw error;
  }
}
```

## Complete Usage Example

### Scenario

A complete example that combines multiple operations to demonstrate the full Fixed Fund Split functionality.

### Implementation

```javascript
async function completeUsageExample() {
  try {
    console.log("=== Complete Fixed Fund Split Usage Example ===");

    // Step 1: Query wallet distribution
    console.log("\n1. Querying wallet distribution...");
    const distribution = await contract.getWalletDistribution();
    console.log("Wallet distribution retrieved successfully");

    // Step 2: Monitor events
    console.log("\n2. Setting up event monitoring...");
    contract.on("Deposited", (user, amount, penalty) => {
      console.log(
        `Deposit event: ${ethers.utils.formatUnits(
          amount,
          18
        )} USDT from ${user}`
      );
    });

    contract.on(
      "FundSplit",
      (
        investWallet,
        devOpsWallet,
        advisorWallet,
        marketingWallet,
        ownerWallet,
        level1Wallet,
        level2Wallet,
        level3Wallet,
        totalAmount
      ) => {
        console.log(
          `Fund split event: ${ethers.utils.formatUnits(
            totalAmount,
            18
          )} USDT distributed`
        );
      }
    );

    // Step 3: Perform multiple deposits
    console.log("\n3. Performing multiple deposits...");
    const deposits = [
      {
        amount: ethers.utils.parseUnits("100", 18),
        description: "Small deposit",
      },
      {
        amount: ethers.utils.parseUnits("1000", 18),
        description: "Medium deposit",
      },
      {
        amount: ethers.utils.parseUnits("5000", 18),
        description: "Large deposit",
      },
    ];

    for (const deposit of deposits) {
      console.log(
        `\nProcessing ${deposit.description}: ${ethers.utils.formatUnits(
          deposit.amount,
          18
        )} USDT`
      );

      // Calculate expected distribution
      const expected = {
        invest: deposit.amount.mul(55).div(100),
        devOps: deposit.amount.mul(5).div(100),
        advisor: deposit.amount.mul(5).div(100),
        marketing: deposit.amount.mul(15).div(100),
        owner: deposit.amount.mul(5).div(100),
        level1: deposit.amount.mul(10).div(100),
        level2: deposit.amount.mul(3).div(100),
        level3: deposit.amount.mul(2).div(100),
      };

      console.log("Expected distribution:");
      console.log(
        `- Invest: ${ethers.utils.formatUnits(expected.invest, 18)} USDT (55%)`
      );
      console.log(
        `- DevOps: ${ethers.utils.formatUnits(expected.devOps, 18)} USDT (5%)`
      );
      console.log(
        `- Advisor: ${ethers.utils.formatUnits(expected.advisor, 18)} USDT (5%)`
      );
      console.log(
        `- Marketing: ${ethers.utils.formatUnits(
          expected.marketing,
          18
        )} USDT (15%)`
      );
      console.log(
        `- Owner: ${ethers.utils.formatUnits(expected.owner, 18)} USDT (5%)`
      );
      console.log(
        `- Level1: ${ethers.utils.formatUnits(expected.level1, 18)} USDT (10%)`
      );
      console.log(
        `- Level2: ${ethers.utils.formatUnits(expected.level2, 18)} USDT (3%)`
      );
      console.log(
        `- Level3: ${ethers.utils.formatUnits(expected.level3, 18)} USDT (2%)`
      );

      // Execute deposit
      const tx = await contract.deposit(deposit.amount);
      const receipt = await tx.wait();

      console.log(`Deposit confirmed in block: ${receipt.blockNumber}`);

      // Check user balance
      const balance = await contract.balanceOf(wallet.address);
      console.log(
        `User balance: ${ethers.utils.formatUnits(balance, 18)} USDT`
      );
    }

    // Step 4: Update MLM wallets
    console.log("\n4. Updating MLM wallets...");
    const newMLMWallets = [
      "0xNewLevel1WalletAddress",
      "0xNewLevel2WalletAddress",
      "0xNewLevel3WalletAddress",
    ];

    const tx = await contract.updateMLMWallets(...newMLMWallets);
    const receipt = await tx.wait();

    console.log("MLM wallets updated in block:", receipt.blockNumber);

    // Verify update
    const updatedMLMWallets = await contract.getMLMWallets();
    console.log("Updated MLM wallets:");
    console.log("Level1:", updatedMLMWallets[7]);
    console.log("Level2:", updatedMLMWallets[8]);
    console.log("Level3:", updatedMLMWallets[9]);

    // Step 5: Final balance check
    console.log("\n5. Final balance check...");
    const finalBalance = await contract.balanceOf(wallet.address);
    console.log(
      `Final user balance: ${ethers.utils.formatUnits(finalBalance, 18)} USDT`
    );

    // Step 6: Clean up event listeners
    console.log("\n6. Cleaning up event listeners...");
    contract.removeAllListeners();

    console.log("\n✓ Complete usage example completed successfully!");

    return {
      deposits: deposits.length,
      finalBalance: ethers.utils.formatUnits(finalBalance, 18),
      mlmWalletsUpdated: true,
    };
  } catch (error) {
    console.error("Complete usage example failed:", error);
    throw error;
  }
}
```

## Summary

These usage examples demonstrate the comprehensive functionality of the Fixed Fund Split feature in the DepositCertificate contract. The examples cover:

1. **Basic Operations**: Depositing USDT and checking balances
2. **Advanced Operations**: Updating MLM wallet addresses and querying configurations
3. **Event Monitoring**: Listening for deposit and fund split events
4. **Frontend Integration**: React components for user interaction
5. **Batch Operations**: Processing multiple deposits efficiently
6. **Error Handling**: Managing various error scenarios
7. **Complete Workflows**: End-to-end usage scenarios

Each example includes detailed explanations and code implementations using both Web3.js and Ethers.js, making it easy for developers to integrate the Fixed Fund Split feature into their applications.
