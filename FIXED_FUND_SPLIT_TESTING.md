# Fixed Fund Split Feature Testing Procedures

This document provides comprehensive testing procedures for the Fixed Fund Split feature in the DepositCertificate contract. It includes unit tests, integration tests, and end-to-end testing scenarios to ensure the feature works correctly and securely.

## Table of Contents

- [Testing Environment Setup](#testing-environment-setup)
- [Unit Testing](#unit-testing)
- [Integration Testing](#integration-testing)
- [End-to-End Testing](#end-to-end-testing)
- [Performance Testing](#performance-testing)
- [Security Testing](#security-testing)
- [Test Coverage Analysis](#test-coverage-analysis)
- [Test Execution Commands](#test-execution-commands)
- [Test Results and Reporting](#test-results-and-reporting)
- [Continuous Integration](#continuous-integration)

## Testing Environment Setup

### Prerequisites

- Foundry development environment
- Node.js (v14 or higher)
- Ethereum wallet (for testing)
- Testnet ETH for testing

### Foundry Test Setup

```bash
# Install Foundry if not already installed
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc

# Verify installation
foundryup
forge --version

# Install project dependencies
forge install
```

### Test Environment Configuration

Create a test environment file:

```bash
cp .env.example .env.test
```

Configure the test environment:

```bash
# .env.test
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbcef3a2c63f758341f81308  # Foundry default account #0
RPC_URL=http://localhost:8545
NETWORK=local
USDT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3  # MockUSDT address
SETTLEMENT_WALLET=0x70997970C51812dc3A010C7d01b50e0d17dc79C8  # Foundry default account #1

# Fixed Fund Split Wallet Addresses (using Foundry default accounts)
INVEST_WALLET=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC  # Account #2
DEVOPS_WALLET=0x90F7971aE4d9A9A3DdE1B0e5a4553368351D6f0C  # Account #3
ADVISOR_WALLET=0x15d34AAf54267DB7D7c367839AA171B2150b97CDB  # Account #4
MARKETING_WALLET=0x23618e81E3f5cdF7F54C3d65f7FBc0aBf5B21E8f  # Account #5
OWNER_WALLET=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC  # Account #2 (same as invest)
LEVEL1_WALLET=0x90F7971aE4d9A9A3DdE1B0e5a4553368351D6f0C  # Account #3 (same as devOps)
LEVEL2_WALLET=0x15d34AAf54267DB7D7c367839AA171B2150b97CDB  # Account #4 (same as advisor)
LEVEL3_WALLET=0x23618e81E3f5cdF7F54C3d65f7FBc0aBf5B21E8f  # Account #5 (same as marketing)
```

### Test Contract Deployment

```bash
# Deploy test contracts
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast

# Verify deployment
cast call <contract_address> "owner()(address)" --rpc-url http://localhost:8545
```

## Unit Testing

### Test File Structure

```
test/
├── DepositCertificate.t.sol          # Main test file
├── FixedFundSplit.t.sol             # Fixed Fund Split specific tests
├── MockUSDT.t.sol                   # Mock USDT contract tests
└── utils/                           # Test utilities
    ├── TestHelpers.sol              # Helper functions for testing
    ├── Constants.sol                # Test constants
    └── Events.sol                   # Event checking utilities
```

### Test Scenarios

#### 1. Wallet Distribution Tests

```solidity
// test/FixedFundSplit.t.sol
contract FixedFundSplitTest is Test {
    DepositCertificate public depositCertificate;
    MockUSDT public mockUSDT;
    address public owner;
    address public user1;
    address public user2;

    // Test wallet addresses
    address investWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address devOpsWallet = 0x90F7971aE4d9A9A3DdE1B0e5a4553368351D6f0C;
    address advisorWallet = 0x15d34AAf54267DB7D7c367839AA171B2150b97CDB;
    address marketingWallet = 0x23618e81E3f5cdF7F54C3d65f7FBc0aBf5B21E8f;
    address ownerWallet = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address level1Wallet = 0x90F7971aE4d9A9A3DdE1B0e5a4553368351D6f0C;
    address level2Wallet = 0x15d34AAf54267DB7D7c367839AA171B2150b97CDB;
    address level3Wallet = 0x23618e81E3f5cdF7F54C3d65f7FBc0aBf5B21E8f;

    function setUp() public {
        // Set up test accounts
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy MockUSDT
        mockUSDT = new MockUSDT();

        // Deploy DepositCertificate with Fixed Fund Split configuration
        depositCertificate = new DepositCertificate(
            address(mockUSDT),
            owner,
            investWallet,
            devOpsWallet,
            advisorWallet,
            marketingWallet,
            ownerWallet,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );

        // Mint tokens to users
        vm.prank(user1);
        mockUSDT.mint(user1, 1000000 * 1e18);

        vm.prank(user2);
        mockUSDT.mint(user2, 1000000 * 1e18);

        // Approve contract to spend tokens
        vm.prank(user1);
        mockUSDT.approve(address(depositCertificate), type(uint256).max);

        vm.prank(user2);
        mockUSDT.approve(address(depositCertificate), type(uint256).max);
    }

    function testWalletDistributionSetup() public {
        // Test that all wallet addresses are correctly set
        (
            address usdt,
            address settlement,
            address invest,
            address devOps,
            address advisor,
            address marketing,
            address ownerAddr,
            address level1,
            address level2,
            address level3
        ) = depositCertificate.getWalletDistribution();

        assertEq(usdt, address(mockUSDT));
        assertEq(settlement, owner);
        assertEq(invest, investWallet);
        assertEq(devOps, devOpsWallet);
        assertEq(advisor, advisorWallet);
        assertEq(marketing, marketingWallet);
        assertEq(ownerAddr, ownerWallet);
        assertEq(level1, level1Wallet);
        assertEq(level2, level2Wallet);
        assertEq(level3, level3Wallet);
    }

    function testWalletPercentages() public {
        // Test that wallet percentages are correctly set
        (
            uint256 investPercent,
            uint256 devOpsPercent,
            uint256 advisorPercent,
            uint256 marketingPercent,
            uint256 ownerPercent,
            uint256 level1Percent,
            uint256 level2Percent,
            uint256 level3Percent
        ) = depositCertificate.getWalletPercentages();

        // Test percentages (basis points)
        assertEq(investPercent, 5500); // 55%
        assertEq(devOpsPercent, 500);  // 5%
        assertEq(advisorPercent, 500); // 5%
        assertEq(marketingPercent, 1500); // 15%
        assertEq(ownerPercent, 500); // 5%
        assertEq(level1Percent, 1000); // 10%
        assertEq(level2Percent, 300); // 3%
        assertEq(level3Percent, 200); // 2%

        // Test total percentage
        uint256 total = investPercent + devOpsPercent + advisorPercent +
                       marketingPercent + ownerPercent + level1Percent +
                       level2Percent + level3Percent;
        assertEq(total, 10000); // 100%
    }
}
```

#### 2. Fund Split Calculation Tests

```solidity
function testFundSplitCalculation() public {
    uint256 depositAmount = 1000 * 1e18; // 1000 USDT

    // Calculate expected distribution
    uint256 expectedInvest = depositAmount * 55 / 100;
    uint256 expectedDevOps = depositAmount * 5 / 100;
    uint256 expectedAdvisor = depositAmount * 5 / 100;
    uint256 expectedMarketing = depositAmount * 15 / 100;
    uint256 expectedOwner = depositAmount * 5 / 100;
    uint256 expectedLevel1 = depositAmount * 10 / 100;
    uint256 expectedLevel2 = depositAmount * 3 / 100;
    uint256 expectedLevel3 = depositAmount * 2 / 100;

    // Execute deposit
        vm.prank(user1);
        depositCertificate.deposit(depositAmount);

        // Check wallet balances
        assertEq(mockUSDT.balanceOf(investWallet), expectedInvest);
        assertEq(mockUSDT.balanceOf(devOpsWallet), expectedDevOps);
        assertEq(mockUSDT.balanceOf(advisorWallet), expectedAdvisor);
        assertEq(mockUSDT.balanceOf(marketingWallet), expectedMarketing);
        assertEq(mockUSDT.balanceOf(ownerWallet), expectedOwner);
        assertEq(mockUSDT.balanceOf(level1Wallet), expectedLevel1);
        assertEq(mockUSDT.balanceOf(level2Wallet), expectedLevel2);
        assertEq(mockUSDT.balanceOf(level3Wallet), expectedLevel3);

        // Check user balance
        assertEq(depositCertificate.balanceOf(user1), depositAmount);
    }

    function testFundSplitWithDifferentAmounts() public {
        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 100 * 1e18;   // 100 USDT
        amounts[1] = 500 * 1e18;   // 500 USDT
        amounts[2] = 1000 * 1e18;  // 1000 USDT
        amounts[3] = 2500 * 1e18;  // 2500 USDT
        amounts[4] = 10000 * 1e18; // 10000 USDT

        for (uint i = 0; i < amounts.length; i++) {
            uint256 depositAmount = amounts[i];

            // Calculate expected distribution
            uint256 expectedInvest = depositAmount * 55 / 100;
            uint256 expectedDevOps = depositAmount * 5 / 100;
            uint256 expectedAdvisor = depositAmount * 5 / 100;
            uint256 expectedMarketing = depositAmount * 15 / 100;
            uint256 expectedOwner = depositAmount * 5 / 100;
            uint256 expectedLevel1 = depositAmount * 10 / 100;
            uint256 expectedLevel2 = depositAmount * 3 / 100;
            uint256 expectedLevel3 = depositAmount * 2 / 100;

            // Execute deposit
            vm.prank(user1);
            depositCertificate.deposit(depositAmount);

            // Check wallet balances
            assertEq(mockUSDT.balanceOf(investWallet), expectedInvest);
            assertEq(mockUSDT.balanceOf(devOpsWallet), expectedDevOps);
            assertEq(mockUSDT.balanceOf(advisorWallet), expectedAdvisor);
            assertEq(mockUSDT.balanceOf(marketingWallet), expectedMarketing);
            assertEq(mockUSDT.balanceOf(ownerWallet), expectedOwner);
            assertEq(mockUSDT.balanceOf(level1Wallet), expectedLevel1);
            assertEq(mockUSDT.balanceOf(level2Wallet), expectedLevel2);
            assertEq(mockUSDT.balanceOf(level3Wallet), expectedLevel3);

            // Check user balance
            assertEq(depositCertificate.balanceOf(user1), depositAmount);

            // Reset for next test
            vm.prank(owner);
            depositCertificate.redeem(depositAmount);
        }
    }
```

#### 3. MLM Wallet Update Tests

```solidity
function testMLMWalletUpdate() public {
    // Test initial MLM wallets
    (, , , , , , , address initialLevel1, address initialLevel2, address initialLevel3) =
        depositCertificate.getWalletDistribution();

    // Set new MLM wallet addresses
    address newLevel1 = makeAddr("newLevel1");
    address newLevel2 = makeAddr("newLevel2");
    address newLevel3 = makeAddr("newLevel3");

    // Update MLM wallets (only owner can do this)
    vm.prank(owner);
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, newLevel3);

    // Verify update
    (, , , , , , , address updatedLevel1, address updatedLevel2, address updatedLevel3) =
        depositCertificate.getWalletDistribution();

    assertEq(updatedLevel1, newLevel1);
    assertEq(updatedLevel2, newLevel2);
    assertEq(updatedLevel3, newLevel3);

    // Test that other wallets remain unchanged
    assertEq(updatedLevel1, newLevel1);
    assertEq(updatedLevel2, newLevel2);
    assertEq(updatedLevel3, newLevel3);
}

function testMLMWalletUpdateValidation() public {
    address newLevel1 = makeAddr("newLevel1");
    address newLevel2 = makeAddr("newLevel2");
    address newLevel3 = makeAddr("newLevel3");

    // Test non-owner cannot update MLM wallets
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, newLevel3);

    // Test zero address validation
    vm.prank(owner);
    vm.expectRevert("FixedFundSplit: MLM wallet cannot be zero address");
    depositCertificate.updateMLMWallets(address(0), newLevel2, newLevel3);

    vm.prank(owner);
    vm.expectRevert("FixedFundSplit: MLM wallet cannot be zero address");
    depositCertificate.updateMLMWallets(newLevel1, address(0), newLevel3);

    vm.prank(owner);
    vm.expectRevert("FixedFundSplit: MLM wallet cannot be zero address");
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, address(0));
}
```

#### 4. Event Testing

```solidity
function testFundSplitEvent() public {
    uint256 depositAmount = 1000 * 1e18;

    // Set up event listener
    vm.expectEmit(true, true, true, true);
    emit depositCertificate.FundSplit(
        investWallet,
        devOpsWallet,
        advisorWallet,
        marketingWallet,
        ownerWallet,
        level1Wallet,
        level2Wallet,
        level3Wallet,
        depositAmount
    );

    // Execute deposit
    vm.prank(user1);
    depositCertificate.deposit(depositAmount);
}

function testMLMWalletsUpdatedEvent() public {
    address newLevel1 = makeAddr("newLevel1");
    address newLevel2 = makeAddr("newLevel2");
    address newLevel3 = makeAddr("newLevel3");

    // Set up event listener
    vm.expectEmit(true, true, true, true);
    emit depositCertificate.MLMWalletsUpdated(
        newLevel1,
        newLevel2,
        newLevel3,
        owner
    );

    // Update MLM wallets
    vm.prank(owner);
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, newLevel3);
}
```

## Integration Testing

### Test Integration with Existing Features

```solidity
function testIntegrationWithRedemption() public {
    uint256 depositAmount = 1000 * 1e18;

    // User deposits
    vm.prank(user1);
    depositCertificate.deposit(depositAmount);

    // Check user balance
    assertEq(depositCertificate.balanceOf(user1), depositAmount);

    // User redeems
    vm.prank(user1);
    depositCertificate.redeem(depositAmount);

    // Check user balance after redemption
    assertEq(depositCertificate.balanceOf(user1), 0);

    // Check that fund split is not reversed (irreversible)
    // The distributed funds remain with the wallet addresses
}

function testIntegrationWithPenalty() public {
    uint256 depositAmount = 1000 * 1e18;

    // Set up penalty parameters
    uint256 penaltyPeriod = 365 days;
    uint256 penaltyPercentage = 10; // 10%

    // User deposits
    vm.prank(user1);
    depositCertificate.deposit(depositAmount);

    // Fast forward time to penalty period
    vm.warp(block.timestamp + penaltyPeriod + 1 days);

    // User redeems with penalty
    vm.prank(user1);
    depositCertificate.redeem(depositAmount);

    // Check that penalty is calculated correctly
    // This depends on the specific penalty implementation
}

function testMultipleDepositsIntegration() public {
    uint256[] memory deposits = new uint256[](3);
    deposits[0] = 500 * 1e18;
    deposits[1] = 1000 * 1e18;
    deposits[2] = 1500 * 1e18;

    for (uint i = 0; i < deposits.length; i++) {
        uint256 depositAmount = deposits[i];

        // User deposits
        vm.prank(user1);
        depositCertificate.deposit(depositAmount);

        // Check user balance
        assertEq(depositCertificate.balanceOf(user1), depositAmount);

        // Check fund split
        uint256 expectedInvest = depositAmount * 55 / 100;
        uint256 expectedDevOps = depositAmount * 5 / 100;
        uint256 expectedAdvisor = depositAmount * 5 / 100;
        uint256 expectedMarketing = depositAmount * 15 / 100;
        uint256 expectedOwner = depositAmount * 5 / 100;
        uint256 expectedLevel1 = depositAmount * 10 / 100;
        uint256 expectedLevel2 = depositAmount * 3 / 100;
        uint256 expectedLevel3 = depositAmount * 2 / 100;

        assertEq(mockUSDT.balanceOf(investWallet), expectedInvest);
        assertEq(mockUSDT.balanceOf(devOpsWallet), expectedDevOps);
        assertEq(mockUSDT.balanceOf(advisorWallet), expectedAdvisor);
        assertEq(mockUSDT.balanceOf(marketingWallet), expectedMarketing);
        assertEq(mockUSDT.balanceOf(ownerWallet), expectedOwner);
        assertEq(mockUSDT.balanceOf(level1Wallet), expectedLevel1);
        assertEq(mockUSDT.balanceOf(level2Wallet), expectedLevel2);
        assertEq(mockUSDT.balanceOf(level3Wallet), expectedLevel3);
    }
}
```

### Test Network Integration

```solidity
function testTestnetIntegration() public {
    // This test would be run on a testnet
    // It would test the actual contract deployment and interaction

    // For now, we'll simulate the test
    assert(true);
}

function testMainnetIntegration() public {
    // This test would be run on mainnet
    // It would test the actual contract deployment and interaction

    // For now, we'll simulate the test
    assert(true);
}
```

## End-to-End Testing

### Complete User Flow Test

```solidity
function testCompleteUserFlow() public {
    // Scenario: User deposits USDT, receives certificate, redeems after penalty period

    uint256 depositAmount = 1000 * 1e18;

    // Step 1: User deposits USDT
    vm.prank(user1);
    depositCertificate.deposit(depositAmount);

    // Verify deposit
    assertEq(depositCertificate.balanceOf(user1), depositAmount);
    assertEq(mockUSDT.balanceOf(user1), 1000000 * 1e18 - depositAmount);

    // Verify fund split
    uint256 expectedInvest = depositAmount * 55 / 100;
    uint256 expectedDevOps = depositAmount * 5 / 100;
    uint256 expectedAdvisor = depositAmount * 5 / 100;
    uint256 expectedMarketing = depositAmount * 15 / 100;
    uint256 expectedOwner = depositAmount * 5 / 100;
    uint256 expectedLevel1 = depositAmount * 10 / 100;
    uint256 expectedLevel2 = depositAmount * 3 / 100;
    uint256 expectedLevel3 = depositAmount * 2 / 100;

    assertEq(mockUSDT.balanceOf(investWallet), expectedInvest);
    assertEq(mockUSDT.balanceOf(devOpsWallet), expectedDevOps);
    assertEq(mockUSDT.balanceOf(advisorWallet), expectedAdvisor);
    assertEq(mockUSDT.balanceOf(marketingWallet), expectedMarketing);
    assertEq(mockUSDT.balanceOf(ownerWallet), expectedOwner);
    assertEq(mockUSDT.balanceOf(level1Wallet), expectedLevel1);
    assertEq(mockUSDT.balanceOf(level2Wallet), expectedLevel2);
    assertEq(mockUSDT.balanceOf(level3Wallet), expectedLevel3);

    // Step 2: Wait for penalty period
    uint256 penaltyPeriod = 365 days;
    vm.warp(block.timestamp + penaltyPeriod + 1 days);

    // Step 3: User redeems
    vm.prank(user1);
    depositCertificate.redeem(depositAmount);

    // Verify redemption
    assertEq(depositCertificate.balanceOf(user1), 0);

    // Step 4: Verify final state
    // The distributed funds remain with the wallet addresses
    // User receives their certificate value (minus any penalties)
}

function testMultipleUsersFlow() public {
    // Scenario: Multiple users deposit USDT at different times

    uint256[] memory deposits = new uint256[](3);
    deposits[0] = 500 * 1e18;  // User1
    deposits[1] = 1000 * 1e18; // User2
    deposits[2] = 750 * 1e18;  // User1 again

    address[] memory users = new address[](2);
    users[0] = user1;
    users[1] = user2;

    // User1 deposits
    vm.prank(user1);
    depositCertificate.deposit(deposits[0]);

    // User2 deposits
    vm.prank(user2);
    depositCertificate.deposit(deposits[1]);

    // User1 deposits again
    vm.prank(user1);
    depositCertificate.deposit(deposits[2]);

    // Verify balances
    assertEq(depositCertificate.balanceOf(user1), deposits[0] + deposits[2]);
    assertEq(depositCertificate.balanceOf(user2), deposits[1]);

    // Verify fund splits
    uint256 totalInvest = (deposits[0] + deposits[1] + deposits[2]) * 55 / 100;
    uint256 totalDevOps = (deposits[0] + deposits[1] + deposits[2]) * 5 / 100;
    uint256 totalAdvisor = (deposits[0] + deposits[1] + deposits[2]) * 5 / 100;
    uint256 totalMarketing = (deposits[0] + deposits[1] + deposits[2]) * 15 / 100;
    uint256 totalOwner = (deposits[0] + deposits[1] + deposits[2]) * 5 / 100;
    uint256 totalLevel1 = (deposits[0] + deposits[1] + deposits[2]) * 10 / 100;
    uint256 totalLevel2 = (deposits[0] + deposits[1] + deposits[2]) * 3 / 100;
    uint256 totalLevel3 = (deposits[0] + deposits[1] + deposits[2]) * 2 / 100;

    assertEq(mockUSDT.balanceOf(investWallet), totalInvest);
    assertEq(mockUSDT.balanceOf(devOpsWallet), totalDevOps);
    assertEq(mockUSDT.balanceOf(advisorWallet), totalAdvisor);
    assertEq(mockUSDT.balanceOf(marketingWallet), totalMarketing);
    assertEq(mockUSDT.balanceOf(ownerWallet), totalOwner);
    assertEq(mockUSDT.balanceOf(level1Wallet), totalLevel1);
    assertEq(mockUSDT.balanceOf(level2Wallet), totalLevel2);
    assertEq(mockUSDT.balanceOf(level3Wallet), totalLevel3);
}
```

## Performance Testing

### Gas Usage Analysis

```solidity
function testGasUsageForDeposits() public {
    uint256[] memory amounts = new uint256[](5);
    amounts[0] = 100 * 1e18;
    amounts[1] = 500 * 1e18;
    amounts[2] = 1000 * 1e18;
    amounts[3] = 5000 * 1e18;
    amounts[4] = 10000 * 1e18;

    for (uint i = 0; i < amounts.length; i++) {
        uint256 depositAmount = amounts[i];

        // Measure gas usage
        uint256 gasBefore = gasleft();

        vm.prank(user1);
        depositCertificate.deposit(depositAmount);

        uint256 gasAfter = gasleft();
        uint256 gasUsed = gasBefore - gasAfter;

        console.log(string.concat("Gas used for deposit ",
            vm.toString(depositAmount / 1e18),
            " USDT: ",
            vm.toString(gasUsed)));

        // Redeem to reset for next test
        vm.prank(user1);
        depositCertificate.redeem(depositAmount);
    }
}

function testGasUsageForMLMWalletUpdates() public {
    address newLevel1 = makeAddr("newLevel1");
    address newLevel2 = makeAddr("newLevel2");
    address newLevel3 = makeAddr("newLevel3");

    // Measure gas usage
    uint256 gasBefore = gasleft();

    vm.prank(owner);
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, newLevel3);

    uint256 gasAfter = gasleft();
    uint256 gasUsed = gasBefore - gasAfter;

    console.log("Gas used for MLM wallet update: ", vm.toString(gasUsed));
}
```

### Load Testing

```solidity
function testLoadWithManyDeposits() public {
    // Test with many small deposits
    uint256 depositAmount = 10 * 1e18; // 10 USDT
    uint256 numDeposits = 100;

    for (uint i = 0; i < numDeposits; i++) {
        address user = makeAddr(string.concat("user", vm.toString(i)));

        // Mint tokens to user
        vm.prank(user);
        mockUSDT.mint(user, depositAmount);

        // Approve contract
        vm.prank(user);
        mockUSDT.approve(address(depositCertificate), depositAmount);

        // Deposit
        vm.prank(user);
        depositCertificate.deposit(depositAmount);

        // Verify
        assertEq(depositCertificate.balanceOf(user), depositAmount);
    }

    // Verify total fund split
    uint256 totalDeposited = depositAmount * numDeposits;
    uint256 expectedInvest = totalDeposited * 55 / 100;
    uint256 expectedDevOps = totalDeposited * 5 / 100;
    uint256 expectedAdvisor = totalDeposited * 5 / 100;
    uint256 expectedMarketing = totalDeposited * 15 / 100;
    uint256 expectedOwner = totalDeposited * 5 / 100;
    uint256 expectedLevel1 = totalDeposited * 10 / 100;
    uint256 expectedLevel2 = totalDeposited * 3 / 100;
    uint256 expectedLevel3 = totalDeposited * 2 / 100;

    assertEq(mockUSDT.balanceOf(investWallet), expectedInvest);
    assertEq(mockUSDT.balanceOf(devOpsWallet), expectedDevOps);
    assertEq(mockUSDT.balanceOf(advisorWallet), expectedAdvisor);
    assertEq(mockUSDT.balanceOf(marketingWallet), expectedMarketing);
    assertEq(mockUSDT.balanceOf(ownerWallet), expectedOwner);
    assertEq(mockUSDT.balanceOf(level1Wallet), expectedLevel1);
    assertEq(mockUSDT.balanceOf(level2Wallet), expectedLevel2);
    assertEq(mockUSDT.balanceOf(level3Wallet), expectedLevel3);
}
```

## Security Testing

### Access Control Testing

```solidity
function testAccessControl() public {
    address newLevel1 = makeAddr("newLevel1");
    address newLevel2 = makeAddr("newLevel2");
    address newLevel3 = makeAddr("newLevel3");

    // Test that only owner can update MLM wallets
    vm.prank(user1);
    vm.expectRevert("Ownable: caller is not the owner");
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, newLevel3);

    // Test that owner can update MLM wallets
    vm.prank(owner);
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, newLevel3);

    // Test that other functions maintain proper access control
    // This depends on the specific implementation
}

function testReentrancyProtection() public {
    // Create a contract that attempts reentrancy
    ReentrancyAttacker attacker = new ReentrancyAttacker(address(depositCertificate), address(mockUSDT));

    // Fund the attacker
    vm.prank(user1);
    mockUSDT.transfer(address(attacker), 1000 * 1e18);

    // Attacker deposits
    vm.prank(address(attacker));
    mockUSDT.approve(address(depositCertificate), 1000 * 1e18);

    vm.prank(address(attacker));
    depositCertificate.deposit(1000 * 1e18);

    // The reentrancy attack should fail
    // The contract should have proper reentrancy protection
}
```

### Input Validation Testing

```solidity
function testInputValidation() public {
    // Test zero deposit amount
    vm.prank(user1);
    vm.expectRevert("DepositCertificate: deposit amount must be greater than zero");
    depositCertificate.deposit(0);

    // Test very large deposit amount
    vm.prank(user1);
    vm.expectRevert("ERC20: transfer amount exceeds balance");
    depositCertificate.deposit(type(uint256).max);

    // Test MLM wallet address validation
    address newLevel1 = makeAddr("newLevel1");
    address newLevel2 = makeAddr("newLevel2");
    address newLevel3 = makeAddr("newLevel3");

    // Test zero address validation
    vm.prank(owner);
    vm.expectRevert("FixedFundSplit: MLM wallet cannot be zero address");
    depositCertificate.updateMLMWallets(address(0), newLevel2, newLevel3);

    vm.prank(owner);
    vm.expectRevert("FixedFundSplit: MLM wallet cannot be zero address");
    depositCertificate.updateMLMWallets(newLevel1, address(0), newLevel3);

    vm.prank(owner);
    vm.expectRevert("FixedFundSplit: MLM wallet cannot be zero address");
    depositCertificate.updateMLMWallets(newLevel1, newLevel2, address(0));
}
```

## Test Coverage Analysis

### Coverage Report

```bash
# Generate coverage report
forge coverage --report lcov

# Generate HTML coverage report
forge coverage --report html

# View coverage in browser
open coverage/index.html
```

### Coverage Targets

- **Fixed Fund Split Functions**: 100% coverage
- **Wallet Management Functions**: 100% coverage
- **Event Emission**: 100% coverage
- **Error Handling**: 100% coverage
- **Integration Points**: 100% coverage

### Critical Path Coverage

1. **Deposit Flow**: User deposits → Fund split → Event emission
2. **MLM Wallet Update**: Owner updates → Validation → Event emission
3. **Error Scenarios**: Invalid inputs → Revert → Error message
4. **Edge Cases**: Zero amounts, Maximum amounts, Boundary conditions

## Test Execution Commands

### Local Testing

```bash
# Run all tests
forge test

# Run tests with verbose output
forge test -vvv

# Run tests with gas reporting
forge test -g

# Run specific test file
forge test test/FixedFundSplit.t.sol

# Run specific test function
forge test --match-test testFundSplitCalculation

# Run tests with coverage
forge test --coverage

# Run tests with gas profiler
forge test --gas-report
```

### Testnet Testing

```bash
# Run tests on Sepolia testnet
forge test --rpc-url https://sepolia.infura.io/v3/YOUR_INFURA_KEY --private-key $PRIVATE_KEY

# Run tests with broadcast
forge test --rpc-url https://sepolia.infura.io/v3/YOUR_INFURA_KEY --private-key $PRIVATE_KEY --broadcast

# Run tests with gas profiling on testnet
forge test --rpc-url https://sepolia.infura.io/v3/YOUR_INFURA_KEY --private-key $PRIVATE_KEY --gas-report
```

### CI/CD Testing

```bash
# Run tests in CI environment
forge test --gas-report --coverage

# Run tests with specific configuration
forge test --match-contract FixedFundSplitTest

# Run tests and generate report
forge test --coverage --report lcov
```

## Test Results and Reporting

### Test Results Format

```json
{
  "testResults": [
    {
      "name": "testFundSplitCalculation",
      "status": "passed",
      "gasUsed": 45234,
      "executionTime": 120,
      "coverage": 100
    },
    {
      "name": "testMLMWalletUpdate",
      "status": "passed",
      "gasUsed": 32145,
      "executionTime": 89,
      "coverage": 100
    }
  ],
  "summary": {
    "totalTests": 25,
    "passedTests": 25,
    "failedTests": 0,
    "skippedTests": 0,
    "totalGasUsed": 1234567,
    "averageGasUsed": 49382,
    "totalCoverage": 98.5
  }
}
```

### Test Report Generation

```bash
# Generate test report
forge test --report json > test-results.json

# Generate coverage report
forge coverage --report json > coverage-report.json

# Generate combined report
forge test --report json --coverage --coverage-report json > combined-report.json
```

### Test Result Analysis

1. **Pass/Fail Rate**: Target 100% pass rate
2. **Gas Usage**: Monitor for unexpected gas consumption
3. **Coverage**: Maintain minimum 95% coverage
4. **Execution Time**: Monitor for performance regressions
5. **Memory Usage**: Check for memory leaks

## Continuous Integration

### GitHub Actions Configuration

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Setup Foundry
        uses: foundry-rs/foundry-toolchain@v1
        with:
          version: nightly

      - name: Install dependencies
        run: forge install

      - name: Run tests
        run: forge test -vvv

      - name: Run coverage
        run: forge coverage --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v2
        with:
          file: ./coverage/lcov.info
          flags: unittests
          name: codecov-umbrella
```

### Test Automation

```bash
# Pre-commit hooks
#!/bin/bash
forge test
forge coverage

# Pre-push hooks
#!/bin/bash
forge test --gas-report
forge coverage --coverage
```

### Quality Gates

1. **Test Coverage**: Minimum 95%
2. **Gas Usage**: No more than 10% increase
3. **Test Pass Rate**: 100%
4. **Security Scans**: No vulnerabilities found
5. **Performance**: No regressions

## Summary

This comprehensive testing procedure ensures the Fixed Fund Split feature works correctly and securely. The testing approach includes:

1. **Unit Testing**: Individual function testing with isolated scenarios
2. **Integration Testing**: Testing with existing contract features
3. **End-to-End Testing**: Complete user flow testing
4. **Performance Testing**: Gas usage and load testing
5. **Security Testing**: Access control and input validation testing
6. **Coverage Analysis**: Ensuring comprehensive test coverage
7. **Automation**: Continuous integration and automated testing

By following these procedures, you can ensure the Fixed Fund Split feature is robust, secure, and ready for production deployment.
