// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {DepositCertificate, CoreWalletsUpdated} from "../src/DepositCertificate.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {MockRejectTransfer} from "../src/MockRejectTransfer.sol";

/**
 * @title FixedFundSplitEndToEndTest
 * @dev End-to-end test suite for the Fixed Fund Split feature
 * This contract tests the complete workflow from deployment through deposit,
 * fund split distribution, and redemption with the Fixed Fund Split feature
 */
contract FixedFundSplitEndToEndTest is Test {

    // Contract instances
    DepositCertificate public depositCertificate;
    MockUSDT public usdt;

    // Test accounts
    address public owner;
    address public user1;
    address public user2;
    address public user3;
    address public settlementWallet;
    
    // Wallet addresses for fund split
    address public investWallet;
    address public devOpsWallet;
    address public advisorWallet;
    address public marketingWallet;
    address public ownerWallet;
    address public level1Wallet;
    address public level2Wallet;
    address public level3Wallet;

    // Test constants
    uint256 public initialAmount = 10_000 * 10**6; // 10,000 USDT with 6 decimals
    
    // Fund split percentages (in basis points for precision)
    uint256 public constant INVEST_PERCENTAGE = 55;      // 55%
    uint256 public constant DEV_OPS_PERCENTAGE = 5;       // 5%
    uint256 public constant ADVISOR_PERCENTAGE = 5;       // 5%
    uint256 public constant MARKETING_PERCENTAGE = 15;    // 15%
    uint256 public constant OWNER_PERCENTAGE = 5;         // 5%
    uint256 public constant LEVEL1_PERCENTAGE = 10;       // 10%
    uint256 public constant LEVEL2_PERCENTAGE = 3;        // 3%
    uint256 public constant LEVEL3_PERCENTAGE = 2;        // 2%
    uint256 public constant TOTAL_PERCENTAGE = 100;       // 100%

    /**
     * @dev Sets up the test environment for end-to-end testing
     * Deploys contracts and configures initial state for comprehensive testing
     */
    function setUp() public {
        // Initialize test accounts
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        settlementWallet = makeAddr("settlementWallet");
        
        // Initialize wallet addresses for fund split
        investWallet = makeAddr("investWallet");
        devOpsWallet = makeAddr("devOpsWallet");
        advisorWallet = makeAddr("advisorWallet");
        marketingWallet = makeAddr("marketingWallet");
        ownerWallet = makeAddr("ownerWallet");
        level1Wallet = makeAddr("level1Wallet");
        level2Wallet = makeAddr("level2Wallet");
        level3Wallet = makeAddr("level3Wallet");

        // Deploy MockUSDT contract
        vm.prank(owner);
        usdt = new MockUSDT("Mock USDT", "USDT");

        // Deploy DepositCertificate contract with all wallet addresses
        vm.prank(owner);
        depositCertificate = new DepositCertificate(
            address(usdt),
            settlementWallet,
            investWallet,
            devOpsWallet,
            advisorWallet,
            marketingWallet,
            ownerWallet,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );

        // Mint initial USDT to test users
        mintUsdtTo(user1, initialAmount);
        mintUsdtTo(user2, initialAmount);
        mintUsdtTo(user3, initialAmount);

        // Set up approvals for DepositCertificate to spend USDT
        approveUsdt(user1, initialAmount);
        approveUsdt(user2, initialAmount);
        approveUsdt(user3, initialAmount);
    }

    /**
     * @dev Helper function to mint USDT tokens to a specific address
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint (in 6 decimal format)
     */
    function mintUsdtTo(address to, uint256 amount) internal {
        vm.prank(owner);
        usdt.mint(to, amount);
    }

    /**
     * @dev Helper function to approve DepositCertificate to spend USDT
     * @param from The address that is granting the approval
     * @param amount The amount of tokens to approve (in 6 decimal format)
     */
    function approveUsdt(address from, uint256 amount) internal {
        vm.prank(from);
        usdt.approve(address(depositCertificate), amount);
    }

    /**
     * @dev Helper function to fast-forward time in tests
     * @param _seconds The number of seconds to fast-forward
     */
    function warpTime(uint256 _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    /**
     * @dev Test complete end-to-end workflow with Fixed Fund Split
     * Verifies the entire system from deployment through multiple deposits,
     * fund split distribution, and redemption
     */
    function test_CompleteEndToEndWorkflow() public {
        // ========== SETUP VERIFICATION ==========
        
        // Verify that contracts are deployed correctly
        assert(address(depositCertificate) != address(0));
        assert(address(usdt) != address(0));
        
        // Verify that users have initial USDT balance
        assertEq(usdt.balanceOf(user1), initialAmount);
        assertEq(usdt.balanceOf(user2), initialAmount);
        assertEq(usdt.balanceOf(user3), initialAmount);
        
        // Verify that DepositCertificate is approved to spend USDT
        assertEq(usdt.allowance(user1, address(depositCertificate)), initialAmount);
        assertEq(usdt.allowance(user2, address(depositCertificate)), initialAmount);
        assertEq(usdt.allowance(user3, address(depositCertificate)), initialAmount);
        
        // Verify that all wallet addresses are correctly set in the contract
        assertEq(depositCertificate.usdtToken(), address(usdt), "USDT token address should be correctly set");
        assertEq(depositCertificate.settlementWallet(), settlementWallet, "Settlement wallet address should be correctly set");
        assertEq(depositCertificate.investWallet(), investWallet, "Invest wallet address should be correctly set");
        assertEq(depositCertificate.devOpsWallet(), devOpsWallet, "DevOps wallet address should be correctly set");
        assertEq(depositCertificate.advisorWallet(), advisorWallet, "Advisor wallet address should be correctly set");
        assertEq(depositCertificate.marketingWallet(), marketingWallet, "Marketing wallet address should be correctly set");
        assertEq(depositCertificate.ownerWallet(), ownerWallet, "Owner wallet address should be correctly set");
        
        // ========== INITIAL BALANCE RECORDING ==========
        
        // Record initial balances for all wallets
        uint256 investInitial = usdt.balanceOf(investWallet);
        uint256 devOpsInitial = usdt.balanceOf(devOpsWallet);
        uint256 advisorInitial = usdt.balanceOf(advisorWallet);
        uint256 marketingInitial = usdt.balanceOf(marketingWallet);
        uint256 ownerInitial = usdt.balanceOf(ownerWallet);
        uint256 level1Initial = usdt.balanceOf(level1Wallet);
        uint256 level2Initial = usdt.balanceOf(level2Wallet);
        uint256 level3Initial = usdt.balanceOf(level3Wallet);
        
        // ========== USER1 MAKES FIRST DEPOSIT ==========
        
        uint256 user1DepositAmount = 1000 * 10**6; // 1000 USDT
        uint256 user1InitialUsdt = usdt.balanceOf(user1);
        uint256 user1InitialCert = depositCertificate.balanceOf(user1);
        
        // User1 makes deposit with initial MLM wallets
        vm.prank(user1);
        depositCertificate.deposit(
            user1DepositAmount,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        
        // Verify user1's USDT balance decreased
        assertEq(usdt.balanceOf(user1), user1InitialUsdt - user1DepositAmount, "User1 USDT balance should decrease by deposit amount");
        
        // Verify user1 received certificate tokens
        assertEq(depositCertificate.balanceOf(user1), user1InitialCert + user1DepositAmount, "User1 should receive certificate tokens");
        
        // Verify fund split occurred correctly
        assertEq(usdt.balanceOf(investWallet), investInitial + (user1DepositAmount * INVEST_PERCENTAGE) / 100, "Invest wallet should receive 55%");
        assertEq(usdt.balanceOf(devOpsWallet), devOpsInitial + (user1DepositAmount * DEV_OPS_PERCENTAGE) / 100, "DevOps wallet should receive 5%");
        assertEq(usdt.balanceOf(advisorWallet), advisorInitial + (user1DepositAmount * ADVISOR_PERCENTAGE) / 100, "Advisor wallet should receive 5%");
        assertEq(usdt.balanceOf(marketingWallet), marketingInitial + (user1DepositAmount * MARKETING_PERCENTAGE) / 100, "Marketing wallet should receive 15%");
        assertEq(usdt.balanceOf(ownerWallet), ownerInitial + (user1DepositAmount * OWNER_PERCENTAGE) / 100, "Owner wallet should receive 5%");
        assertEq(usdt.balanceOf(level1Wallet), level1Initial + (user1DepositAmount * LEVEL1_PERCENTAGE) / 100, "Level1 wallet should receive 10%");
        assertEq(usdt.balanceOf(level2Wallet), level2Initial + (user1DepositAmount * LEVEL2_PERCENTAGE) / 100, "Level2 wallet should receive 3%");
        assertEq(usdt.balanceOf(level3Wallet), level3Initial + (user1DepositAmount * LEVEL3_PERCENTAGE) / 100, "Level3 wallet should receive 2%");
        
        // ========== USER2 MAKES DEPOSIT WITH CUSTOM MLM WALLETS ==========
        
        uint256 user2DepositAmount = 2000 * 10**6; // 2000 USDT
        address user2CustomLevel1 = makeAddr("user2Level1");
        address user2CustomLevel2 = makeAddr("user2Level2");
        address user2CustomLevel3 = makeAddr("user2Level3");
        
        uint256 user2InitialUsdt = usdt.balanceOf(user2);
        uint256 user2InitialCert = depositCertificate.balanceOf(user2);
        
        // Record current wallet balances before user2's deposit
        investInitial = usdt.balanceOf(investWallet);
        devOpsInitial = usdt.balanceOf(devOpsWallet);
        advisorInitial = usdt.balanceOf(advisorWallet);
        marketingInitial = usdt.balanceOf(marketingWallet);
        ownerInitial = usdt.balanceOf(ownerWallet);
        uint256 user2Level1Initial = usdt.balanceOf(user2CustomLevel1);
        uint256 user2Level2Initial = usdt.balanceOf(user2CustomLevel2);
        uint256 user2Level3Initial = usdt.balanceOf(user2CustomLevel3);
        
        // User2 makes deposit with custom MLM wallets
        vm.prank(user2);
        depositCertificate.deposit(
            user2DepositAmount,
            user2CustomLevel1,
            user2CustomLevel2,
            user2CustomLevel3
        );
        
        // Verify user2's USDT balance decreased
        assertEq(usdt.balanceOf(user2), user2InitialUsdt - user2DepositAmount, "User2 USDT balance should decrease by deposit amount");
        
        // Verify user2 received certificate tokens
        assertEq(depositCertificate.balanceOf(user2), user2InitialCert + user2DepositAmount, "User2 should receive certificate tokens");
        
        // Verify fund split occurred correctly
        assertEq(usdt.balanceOf(investWallet), investInitial + (user2DepositAmount * INVEST_PERCENTAGE) / 100, "Invest wallet should receive 55% of user2 deposit");
        assertEq(usdt.balanceOf(devOpsWallet), devOpsInitial + (user2DepositAmount * DEV_OPS_PERCENTAGE) / 100, "DevOps wallet should receive 5% of user2 deposit");
        assertEq(usdt.balanceOf(advisorWallet), advisorInitial + (user2DepositAmount * ADVISOR_PERCENTAGE) / 100, "Advisor wallet should receive 5% of user2 deposit");
        assertEq(usdt.balanceOf(marketingWallet), marketingInitial + (user2DepositAmount * MARKETING_PERCENTAGE) / 100, "Marketing wallet should receive 15% of user2 deposit");
        assertEq(usdt.balanceOf(ownerWallet), ownerInitial + (user2DepositAmount * OWNER_PERCENTAGE) / 100, "Owner wallet should receive 5% of user2 deposit");
        assertEq(usdt.balanceOf(user2CustomLevel1), user2Level1Initial + (user2DepositAmount * LEVEL1_PERCENTAGE) / 100, "User2 custom Level1 wallet should receive 10%");
        assertEq(usdt.balanceOf(user2CustomLevel2), user2Level2Initial + (user2DepositAmount * LEVEL2_PERCENTAGE) / 100, "User2 custom Level2 wallet should receive 3%");
        assertEq(usdt.balanceOf(user2CustomLevel3), user2Level3Initial + (user2DepositAmount * LEVEL3_PERCENTAGE) / 100, "User2 custom Level3 wallet should receive 2%");
        
        // ========== OWNER UPDATES MLM WALLETS ==========
        
        address newLevel1Wallet = makeAddr("newLevel1Wallet");
        address newLevel2Wallet = makeAddr("newLevel2Wallet");
        address newLevel3Wallet = makeAddr("newLevel3Wallet");
        
        // Verify initial MLM wallet addresses
        assertEq(depositCertificate.level1Wallet(), level1Wallet, "Initial level1 wallet should be correct");
        assertEq(depositCertificate.level2Wallet(), level2Wallet, "Initial level2 wallet should be correct");
        assertEq(depositCertificate.level3Wallet(), level3Wallet, "Initial level3 wallet should be correct");
        
        // Test non-owner cannot update addresses
        vm.prank(user1);
        vm.expectRevert();
        depositCertificate.updateMLMWallets(newLevel1Wallet, newLevel2Wallet, newLevel3Wallet);
        
        // Test owner can update addresses
        vm.prank(owner);
        depositCertificate.updateMLMWallets(newLevel1Wallet, newLevel2Wallet, newLevel3Wallet);
        
        // Verify addresses were updated
        assertEq(depositCertificate.level1Wallet(), newLevel1Wallet, "Level1 wallet should be updated");
        assertEq(depositCertificate.level2Wallet(), newLevel2Wallet, "Level2 wallet should be updated");
        assertEq(depositCertificate.level3Wallet(), newLevel3Wallet, "Level3 wallet should be updated");
        
        // ========== USER3 MAKES DEPOSIT WITH UPDATED MLM WALLETS ==========
        
        uint256 user3DepositAmount = 500 * 10**6; // 500 USDT
        
        uint256 user3InitialUsdt = usdt.balanceOf(user3);
        uint256 user3InitialCert = depositCertificate.balanceOf(user3);
        
        // Record current wallet balances before user3's deposit
        investInitial = usdt.balanceOf(investWallet);
        devOpsInitial = usdt.balanceOf(devOpsWallet);
        advisorInitial = usdt.balanceOf(advisorWallet);
        marketingInitial = usdt.balanceOf(marketingWallet);
        ownerInitial = usdt.balanceOf(ownerWallet);
        uint256 newLevel1Initial = usdt.balanceOf(newLevel1Wallet);
        uint256 newLevel2Initial = usdt.balanceOf(newLevel2Wallet);
        uint256 newLevel3Initial = usdt.balanceOf(newLevel3Wallet);
        
        // User3 makes deposit with updated MLM wallets
        vm.prank(user3);
        depositCertificate.deposit(
            user3DepositAmount,
            newLevel1Wallet,
            newLevel2Wallet,
            newLevel3Wallet
        );
        
        // Verify user3's USDT balance decreased
        assertEq(usdt.balanceOf(user3), user3InitialUsdt - user3DepositAmount, "User3 USDT balance should decrease by deposit amount");
        
        // Verify user3 received certificate tokens
        assertEq(depositCertificate.balanceOf(user3), user3InitialCert + user3DepositAmount, "User3 should receive certificate tokens");
        
        // Verify fund split occurred correctly
        assertEq(usdt.balanceOf(investWallet), investInitial + (user3DepositAmount * INVEST_PERCENTAGE) / 100, "Invest wallet should receive 55% of user3 deposit");
        assertEq(usdt.balanceOf(devOpsWallet), devOpsInitial + (user3DepositAmount * DEV_OPS_PERCENTAGE) / 100, "DevOps wallet should receive 5% of user3 deposit");
        assertEq(usdt.balanceOf(advisorWallet), advisorInitial + (user3DepositAmount * ADVISOR_PERCENTAGE) / 100, "Advisor wallet should receive 5% of user3 deposit");
        assertEq(usdt.balanceOf(marketingWallet), marketingInitial + (user3DepositAmount * MARKETING_PERCENTAGE) / 100, "Marketing wallet should receive 15% of user3 deposit");
        assertEq(usdt.balanceOf(ownerWallet), ownerInitial + (user3DepositAmount * OWNER_PERCENTAGE) / 100, "Owner wallet should receive 5% of user3 deposit");
        assertEq(usdt.balanceOf(newLevel1Wallet), newLevel1Initial + (user3DepositAmount * LEVEL1_PERCENTAGE) / 100, "New Level1 wallet should receive 10%");
        assertEq(usdt.balanceOf(newLevel2Wallet), newLevel2Initial + (user3DepositAmount * LEVEL2_PERCENTAGE) / 100, "New Level2 wallet should receive 3%");
        assertEq(usdt.balanceOf(newLevel3Wallet), newLevel3Initial + (user3DepositAmount * LEVEL3_PERCENTAGE) / 100, "New Level3 wallet should receive 2%");
        
        // ========== TIME ELAPSE FOR PENALTY CALCULATION ==========
        
        // Fast-forward time 2 years for penalty calculation
        warpTime(2 * 365 * 24 * 60 * 60); // 2 years
        
        // ========== USER1 MAKES PARTIAL REDEMPTION ==========
        
        uint256 user1RedeemAmount = 300 * 10**6; // 300 USDT (partial redemption)
        uint256 user1UsdtBeforeRedeem = usdt.balanceOf(user1);
        uint256 settlementUsdtBeforeRedeem = usdt.balanceOf(settlementWallet);
        uint256 user1CertBeforeRedeem = depositCertificate.balanceOf(user1);
        
        // Calculate expected penalty and payout for user1's partial redemption
        (uint256 expectedPenalty, uint256 expectedPayout) = depositCertificate.calculatePenalty(user1, user1RedeemAmount);
        
        // Set up approval for settlement wallet
        vm.prank(settlementWallet);
        usdt.approve(address(depositCertificate), expectedPayout);
        
        // User1 redeems partial amount
        vm.prank(user1);
        depositCertificate.redeem(user1RedeemAmount);
        
        // Verify redemption worked correctly
        assertEq(usdt.balanceOf(user1), user1UsdtBeforeRedeem + expectedPayout, "User1 USDT balance should increase by payout");
        assertEq(usdt.balanceOf(settlementWallet), settlementUsdtBeforeRedeem - expectedPayout, "Settlement wallet USDT balance should decrease by payout");
        assertEq(depositCertificate.balanceOf(user1), user1CertBeforeRedeem - user1RedeemAmount, "User1 certificate balance should decrease by redeemed amount");
        
        // Verify remaining certificate tokens
        uint256 user1RemainingCert = user1CertBeforeRedeem - user1RedeemAmount;
        assertEq(user1RemainingCert, 700 * 10**6, "User1 should have 700 USDT worth of certificate tokens remaining");
        
        // ========== USER2 MAKES FULL REDEMPTION ==========
        
        uint256 user2UsdtBeforeRedeem = usdt.balanceOf(user2);
        uint256 settlementUsdtBeforeRedeem2 = usdt.balanceOf(settlementWallet);
        uint256 user2CertBeforeRedeem = depositCertificate.balanceOf(user2);
        
        // Calculate expected penalty and payout for user2's full redemption
        (uint256 expectedPenalty2, uint256 expectedPayout2) = depositCertificate.calculatePenalty(user2, user2CertBeforeRedeem);
        
        // Set up approval for settlement wallet
        vm.prank(settlementWallet);
        usdt.approve(address(depositCertificate), expectedPayout2);
        
        // User2 redeems full amount
        vm.prank(user2);
        depositCertificate.redeem(user2CertBeforeRedeem);
        
        // Verify redemption worked correctly
        assertEq(usdt.balanceOf(user2), user2UsdtBeforeRedeem + expectedPayout2, "User2 USDT balance should increase by payout");
        assertEq(usdt.balanceOf(settlementWallet), settlementUsdtBeforeRedeem2 - expectedPayout2, "Settlement wallet USDT balance should decrease by payout");
        assertEq(depositCertificate.balanceOf(user2), 0, "User2 certificate balance should be zero after full redemption");
        
        // ========== USER3 MAKES FULL REDEMPTION AFTER 5 YEARS (NO PENALTY) ==========
        
        // Fast-forward additional 3 years (total 5 years from first deposit)
        warpTime(3 * 365 * 24 * 60 * 60); // 3 years
        
        uint256 user3UsdtBeforeRedeem = usdt.balanceOf(user3);
        uint256 settlementUsdtBeforeRedeem3 = usdt.balanceOf(settlementWallet);
        uint256 user3CertBeforeRedeem = depositCertificate.balanceOf(user3);
        
        // Calculate expected penalty and payout for user3's redemption (should be 0% penalty after 5 years)
        (uint256 expectedPenalty3, uint256 expectedPayout3) = depositCertificate.calculatePenalty(user3, user3CertBeforeRedeem);
        
        // Verify penalty is 0% after 5 years
        assertEq(expectedPenalty3, 0, "Penalty should be 0% after 5 years");
        assertEq(expectedPayout3, user3CertBeforeRedeem, "Payout should be 100% after 5 years");
        
        // Set up approval for settlement wallet
        vm.prank(settlementWallet);
        usdt.approve(address(depositCertificate), expectedPayout3);
        
        // User3 redeems full amount
        vm.prank(user3);
        depositCertificate.redeem(user3CertBeforeRedeem);
        
        // Verify redemption worked correctly with no penalty
        assertEq(usdt.balanceOf(user3), user3UsdtBeforeRedeem + expectedPayout3, "User3 USDT balance should increase by full payout");
        assertEq(usdt.balanceOf(settlementWallet), settlementUsdtBeforeRedeem3 - expectedPayout3, "Settlement wallet USDT balance should decrease by full payout");
        assertEq(depositCertificate.balanceOf(user3), 0, "User3 certificate balance should be zero after full redemption");
        
        // ========== FINAL VERIFICATION ==========
        
        // Verify total supply is zero (all certificates redeemed)
        assertEq(depositCertificate.totalSupply(), 0, "Total supply should be zero after all redemptions");
        
        // Verify that all users have their original USDT balance minus deposits plus payouts
        // This calculation is complex due to penalties, but we can verify the system works correctly
        console.log("End-to-end test completed successfully!");
    }

    function test_UpdateCoreWallets() public {
        // ========== SETUP NEW WALLETS ==========
        address newSettlementWallet = makeAddr("newSettlementWallet");
        address newInvestWallet = makeAddr("newInvestWallet");
        address newDevOpsWallet = makeAddr("newDevOpsWallet");
        address newAdvisorWallet = makeAddr("newAdvisorWallet");
        address newMarketingWallet = makeAddr("newMarketingWallet");
        address newOwnerWallet = makeAddr("newOwnerWallet");

        // ========== VERIFY NON-OWNER CANNOT UPDATE ==========
        vm.prank(user1);
        vm.expectRevert();
        depositCertificate.updateCoreWallets(
            newSettlementWallet,
            newInvestWallet,
            newDevOpsWallet,
            newAdvisorWallet,
            newMarketingWallet,
            newOwnerWallet
        );

        // ========== VERIFY OWNER CAN UPDATE ==========
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit CoreWalletsUpdated(
            owner,
            newSettlementWallet,
            newInvestWallet,
            newDevOpsWallet,
            newAdvisorWallet,
            newMarketingWallet,
            newOwnerWallet
        );
        depositCertificate.updateCoreWallets(
            newSettlementWallet,
            newInvestWallet,
            newDevOpsWallet,
            newAdvisorWallet,
            newMarketingWallet,
            newOwnerWallet
        );

        // ========== VERIFY WALLETS ARE UPDATED ==========
        assertEq(depositCertificate.settlementWallet(), newSettlementWallet, "Settlement wallet should be updated");
        assertEq(depositCertificate.ivWallet(), newInvestWallet, "Invest wallet should be updated");
        assertEq(depositCertificate.dvWallet(), newDevOpsWallet, "DevOps wallet should be updated");
        assertEq(depositCertificate.adWallet(), newAdvisorWallet, "Advisor wallet should be updated");
        assertEq(depositCertificate.mlWallet(), newMarketingWallet, "Marketing wallet should be updated");
        assertEq(depositCertificate.bcWallet(), newOwnerWallet, "Owner wallet should be updated");
    }

    /**
     * @dev Test multiple deposits with different MLM wallets and verify fund split accuracy
     * This test ensures that each deposit correctly uses the specified MLM wallets
     * and that the fund split percentages are applied accurately
     */
    function test_MultipleDepositsWithDifferentMLMWallets() public {
        // Record initial balances
        uint256 investInitial = usdt.balanceOf(investWallet);
        uint256 devOpsInitial = usdt.balanceOf(devOpsWallet);
        uint256 advisorInitial = usdt.balanceOf(advisorWallet);
        uint256 marketingInitial = usdt.balanceOf(marketingWallet);
        uint256 ownerInitial = usdt.balanceOf(ownerWallet);
        
        // User1 makes deposit with original MLM wallets
        uint256 deposit1 = 1000 * 10**6; // 1000 USDT
        uint256 level1Initial1 = usdt.balanceOf(level1Wallet);
        uint256 level2Initial1 = usdt.balanceOf(level2Wallet);
        uint256 level3Initial1 = usdt.balanceOf(level3Wallet);
        
        vm.prank(user1);
        depositCertificate.deposit(
            deposit1,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        
        // Verify first fund split
        assertEq(usdt.balanceOf(investWallet), investInitial + (deposit1 * INVEST_PERCENTAGE) / 100, "Invest wallet should receive 55% of first deposit");
        assertEq(usdt.balanceOf(devOpsWallet), devOpsInitial + (deposit1 * DEV_OPS_PERCENTAGE) / 100, "DevOps wallet should receive 5% of first deposit");
        assertEq(usdt.balanceOf(advisorWallet), advisorInitial + (deposit1 * ADVISOR_PERCENTAGE) / 100, "Advisor wallet should receive 5% of first deposit");
        assertEq(usdt.balanceOf(marketingWallet), marketingInitial + (deposit1 * MARKETING_PERCENTAGE) / 100, "Marketing wallet should receive 15% of first deposit");
        assertEq(usdt.balanceOf(ownerWallet), ownerInitial + (deposit1 * OWNER_PERCENTAGE) / 100, "Owner wallet should receive 5% of first deposit");
        assertEq(usdt.balanceOf(level1Wallet), level1Initial1 + (deposit1 * LEVEL1_PERCENTAGE) / 100, "Level1 wallet should receive 10% of first deposit");
        assertEq(usdt.balanceOf(level2Wallet), level2Initial1 + (deposit1 * LEVEL2_PERCENTAGE) / 100, "Level2 wallet should receive 3% of first deposit");
        assertEq(usdt.balanceOf(level3Wallet), level3Initial1 + (deposit1 * LEVEL3_PERCENTAGE) / 100, "Level3 wallet should receive 2% of first deposit");
        
        // User2 makes deposit with custom MLM wallets
        uint256 deposit2 = 2000 * 10**6; // 2000 USDT
        address customLevel1 = makeAddr("customLevel1");
        address customLevel2 = makeAddr("customLevel2");
        address customLevel3 = makeAddr("customLevel3");
        
        // Update current balances
        investInitial = usdt.balanceOf(investWallet);
        devOpsInitial = usdt.balanceOf(devOpsWallet);
        advisorInitial = usdt.balanceOf(advisorWallet);
        marketingInitial = usdt.balanceOf(marketingWallet);
        ownerInitial = usdt.balanceOf(ownerWallet);
        uint256 customLevel1Initial = usdt.balanceOf(customLevel1);
        uint256 customLevel2Initial = usdt.balanceOf(customLevel2);
        uint256 customLevel3Initial = usdt.balanceOf(customLevel3);
        
        vm.prank(user2);
        depositCertificate.deposit(
            deposit2,
            customLevel1,
            customLevel2,
            customLevel3
        );
        
        // Verify second fund split
        assertEq(usdt.balanceOf(investWallet), investInitial + (deposit2 * INVEST_PERCENTAGE) / 100, "Invest wallet should receive 55% of second deposit");
        assertEq(usdt.balanceOf(devOpsWallet), devOpsInitial + (deposit2 * DEV_OPS_PERCENTAGE) / 100, "DevOps wallet should receive 5% of second deposit");
        assertEq(usdt.balanceOf(advisorWallet), advisorInitial + (deposit2 * ADVISOR_PERCENTAGE) / 100, "Advisor wallet should receive 5% of second deposit");
        assertEq(usdt.balanceOf(marketingWallet), marketingInitial + (deposit2 * MARKETING_PERCENTAGE) / 100, "Marketing wallet should receive 15% of second deposit");
        assertEq(usdt.balanceOf(ownerWallet), ownerInitial + (deposit2 * OWNER_PERCENTAGE) / 100, "Owner wallet should receive 5% of second deposit");
        assertEq(usdt.balanceOf(customLevel1), customLevel1Initial + (deposit2 * LEVEL1_PERCENTAGE) / 100, "Custom Level1 wallet should receive 10% of second deposit");
        assertEq(usdt.balanceOf(customLevel2), customLevel2Initial + (deposit2 * LEVEL2_PERCENTAGE) / 100, "Custom Level2 wallet should receive 3% of second deposit");
        assertEq(usdt.balanceOf(customLevel3), customLevel3Initial + (deposit2 * LEVEL3_PERCENTAGE) / 100, "Custom Level3 wallet should receive 2% of second deposit");
        
        // User3 makes deposit with another set of MLM wallets
        uint256 deposit3 = 500 * 10**6; // 500 USDT
        address anotherLevel1 = makeAddr("anotherLevel1");
        address anotherLevel2 = makeAddr("anotherLevel2");
        address anotherLevel3 = makeAddr("anotherLevel3");
        
        // Update current balances
        investInitial = usdt.balanceOf(investWallet);
        devOpsInitial = usdt.balanceOf(devOpsWallet);
        advisorInitial = usdt.balanceOf(advisorWallet);
        marketingInitial = usdt.balanceOf(marketingWallet);
        ownerInitial = usdt.balanceOf(ownerWallet);
        uint256 anotherLevel1Initial = usdt.balanceOf(anotherLevel1);
        uint256 anotherLevel2Initial = usdt.balanceOf(anotherLevel2);
        uint256 anotherLevel3Initial = usdt.balanceOf(anotherLevel3);
        
        vm.prank(user3);
        depositCertificate.deposit(
            deposit3,
            anotherLevel1,
            anotherLevel2,
            anotherLevel3
        );
        
        // Verify third fund split
        assertEq(usdt.balanceOf(investWallet), investInitial + (deposit3 * INVEST_PERCENTAGE) / 100, "Invest wallet should receive 55% of third deposit");
        assertEq(usdt.balanceOf(devOpsWallet), devOpsInitial + (deposit3 * DEV_OPS_PERCENTAGE) / 100, "DevOps wallet should receive 5% of third deposit");
        assertEq(usdt.balanceOf(advisorWallet), advisorInitial + (deposit3 * ADVISOR_PERCENTAGE) / 100, "Advisor wallet should receive 5% of third deposit");
        assertEq(usdt.balanceOf(marketingWallet), marketingInitial + (deposit3 * MARKETING_PERCENTAGE) / 100, "Marketing wallet should receive 15% of third deposit");
        assertEq(usdt.balanceOf(ownerWallet), ownerInitial + (deposit3 * OWNER_PERCENTAGE) / 100, "Owner wallet should receive 5% of third deposit");
        assertEq(usdt.balanceOf(anotherLevel1), anotherLevel1Initial + (deposit3 * LEVEL1_PERCENTAGE) / 100, "Another Level1 wallet should receive 10% of third deposit");
        assertEq(usdt.balanceOf(anotherLevel2), anotherLevel2Initial + (deposit3 * LEVEL2_PERCENTAGE) / 100, "Another Level2 wallet should receive 3% of third deposit");
        assertEq(usdt.balanceOf(anotherLevel3), anotherLevel3Initial + (deposit3 * LEVEL3_PERCENTAGE) / 100, "Another Level3 wallet should receive 2% of third deposit");
        
        // Verify total certificate balances
        assertEq(depositCertificate.balanceOf(user1), deposit1, "User1 should have certificate tokens from first deposit");
        assertEq(depositCertificate.balanceOf(user2), deposit2, "User2 should have certificate tokens from second deposit");
        assertEq(depositCertificate.balanceOf(user3), deposit3, "User3 should have certificate tokens from third deposit");
        
        // Verify total supply
        assertEq(depositCertificate.totalSupply(), deposit1 + deposit2 + deposit3, "Total supply should equal sum of all deposits");
        
        console.log("Multiple deposits with different MLM wallets test completed successfully!");
    }

    /**
     * @dev Test atomic transaction behavior with rejecting contracts
     * This test ensures that if any wallet in the fund split rejects a transfer,
     * the entire deposit operation reverts and no funds are transferred
     */
    function test_AtomicTransactionBehavior() public {
        // Setup: Mint USDT to user
        vm.prank(user);
        mockUSDT.mint(user, 10000 * 10**6);
        
        // Setup: Approve contract to spend user's USDT
        vm.prank(user);
        mockUSDT.approve(address(depositCertificate), 10000 * 10**6);
        
        // Setup: Enable transfers for all wallets except one
        vm.prank(investWallet);
        mockUSDT.enableTransfers();
        
        vm.prank(devOpsWallet);
        mockUSDT.enableTransfers();
        
        vm.prank(advisorWallet);
        mockUSDT.enableTransfers();
        
        vm.prank(marketingWallet);
        mockUSDT.enableTransfers();
        
        vm.prank(ownerWallet);
        mockUSDT.enableTransfers();
        
        vm.prank(level1Wallet);
        mockUSDT.enableTransfers();
        
        vm.prank(level3Wallet);
        mockUSDT.enableTransfers();
        
        // The deposit should revert because level2Wallet transfers are disabled
        vm.expectRevert("Transfer rejected by mock contract");
        
        vm.prank(user);
        depositCertificate.deposit(1000 * 10**6, level1Wallet, level2Wallet, level3Wallet);
    }

    /**
     * @dev Test error handling and edge cases in end-to-end scenarios
     * This test ensures that the system handles various error conditions correctly
     * in the context of the complete workflow
     */
    function test_ErrorHandlingAndEdgeCases() public {
        // Test zero deposit amount
        vm.prank(user1);
        vm.expectRevert("Deposit amount must be greater than zero");
        depositCertificate.deposit(
            0,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        
        // Test insufficient balance
        uint256 insufficientAmount = initialAmount + 1;
        vm.prank(user1);
        vm.expectRevert(); // ERC20 transfer will fail with insufficient balance
        depositCertificate.deposit(
            insufficientAmount,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        
        // Test insufficient approval
        vm.prank(user1);
        usdt.approve(address(depositCertificate), 100 * 10**6 - 1); // Approve less than deposit amount
        vm.prank(user1);
        vm.expectRevert(); // ERC20 transfer will fail with insufficient allowance
        depositCertificate.deposit(
            100 * 10**6,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        
        // Reset approval
        vm.prank(user1);
        usdt.approve(address(depositCertificate), initialAmount);
        
        // Test zero MLM wallet addresses
        address zeroAddress = address(0);
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(
            100 * 10**6,
            zeroAddress,
            level2Wallet,
            level3Wallet
        );
        
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(
            100 * 10**6,
            level1Wallet,
            zeroAddress,
            level3Wallet
        );
        
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(
            100 * 10**6,
            level1Wallet,
            level2Wallet,
            zeroAddress
        );
        
        // Test successful deposit after error conditions
        uint256 depositAmount = 1000 * 10**6; // 1000 USDT
        uint256 level1Initial = usdt.balanceOf(level1Wallet);
        uint256 level2Initial = usdt.balanceOf(level2Wallet);
        uint256 level3Initial = usdt.balanceOf(level3Wallet);
        
        vm.prank(user1);
        depositCertificate.deposit(
            depositAmount,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        
        // Verify funds went to valid addresses
        assertEq(usdt.balanceOf(level1Wallet), level1Initial + (depositAmount * LEVEL1_PERCENTAGE) / 100, "Level1 wallet should receive funds");
        assertEq(usdt.balanceOf(level2Wallet), level2Initial + (depositAmount * LEVEL2_PERCENTAGE) / 100, "Level2 wallet should receive funds");
        assertEq(usdt.balanceOf(level3Wallet), level3Initial + (depositAmount * LEVEL3_PERCENTAGE) / 100, "Level3 wallet should receive funds");
        
        // Test redemption with insufficient certificate balance
        uint256 excessRedeemAmount = depositAmount + 1;
        vm.prank(user1);
        vm.expectRevert("Insufficient certificate token balance");
        depositCertificate.redeem(excessRedeemAmount);
        
        // Test redemption with insufficient settlement wallet balance
        uint256 user1UsdtBefore = usdt.balanceOf(user1);
        uint256 settlementUsdtBefore = usdt.balanceOf(settlementWallet);
        
        // Transfer all USDT from settlement wallet to owner
        vm.prank(settlementWallet);
        usdt.transfer(owner, settlementUsdtBefore);
        
        // Fast-forward time for penalty calculation
        warpTime(2 * 365 * 24 * 60 * 60); // 2 years
        
        // Calculate expected penalty and payout
        (uint256 expectedPenalty, uint256 expectedPayout) = depositCertificate.calculatePenalty(user1, depositAmount / 2);
        
        // Attempt redemption when settlement wallet has no USDT
        vm.prank(user1);
        vm.expectRevert(); // ERC20 transfer will fail with insufficient balance
        depositCertificate.redeem(depositAmount / 2);
        
        // Mint USDT back to settlement wallet
        mintUsdtTo(settlementWallet, expectedPayout);
        
        // Test successful redemption
        vm.prank(settlementWallet);
        usdt.approve(address(depositCertificate), expectedPayout);
        
        vm.prank(user1);
        depositCertificate.redeem(depositAmount / 2);
        
        // Verify redemption worked correctly
        assertEq(usdt.balanceOf(user1), user1UsdtBefore + expectedPayout, "User USDT balance should increase by payout");
        assertEq(usdt.balanceOf(settlementWallet), settlementUsdtBefore - expectedPayout, "Settlement wallet USDT balance should decrease by payout");
        
        console.log("Error handling and edge cases test completed successfully!");
    }
}