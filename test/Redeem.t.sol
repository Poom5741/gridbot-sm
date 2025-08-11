// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DepositCertificate} from "../src/DepositCertificate.sol";
import {MockUSDT} from "../src/MockUSDT.sol";

/**
 * @title RedeemTest
 * @dev Test suite for the redeem functionality of the DepositCertificate system
 */
contract RedeemTest is Test {

    // Contract instances
    DepositCertificate public depositCertificate;
    MockUSDT public usdt;

    // Test accounts
    address public owner;
    address public user1;
    address public settlementWallet;

    // Wallet addresses for fund split
    address public ivWallet;
    address public dvWallet;
    address public adWallet;
    address public maWallet;
    address public owWallet;
    address public ml1Wallet;
    address public ml2Wallet;
    address public ml3Wallet;

    // Test constants
    uint256 public initialAmount = 1000 * 10**6; // 1000 USDT with 6 decimals

    /**
     * @dev Sets up the test environment
     * Deploys contracts and configures initial state for testing
     */
    function setUp() public {
        // Initialize test accounts
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        settlementWallet = makeAddr("settlementWallet");

        // Initialize wallet addresses for fund split
        ivWallet = makeAddr("ivWallet");
        dvWallet = makeAddr("dvWallet");
        adWallet = makeAddr("adWallet");
        maWallet = makeAddr("maWallet");
        owWallet = makeAddr("owWallet");
        ml1Wallet = makeAddr("ml1Wallet");
        ml2Wallet = makeAddr("ml2Wallet");
        ml3Wallet = makeAddr("ml3Wallet");

        // Deploy MockUSDT contract
        vm.prank(owner);
        usdt = new MockUSDT("Mock USDT", "USDT");

        // Deploy DepositCertificate contract with all wallet addresses
        vm.prank(owner);
        depositCertificate = new DepositCertificate(
            address(usdt),
            settlementWallet,
            ivWallet,
            dvWallet,
            adWallet,
            maWallet,
            owWallet,
            ml1Wallet,
            ml2Wallet,
            ml3Wallet
        );

        // Mint initial USDT to test users and settlement wallet
        mintUsdtTo(user1, initialAmount);
        mintUsdtTo(settlementWallet, initialAmount * 10); // Give settlement wallet ample funds

        // Set up approvals for DepositCertificate to spend USDT
        approveUsdt(user1, address(depositCertificate), initialAmount);
        approveUsdt(settlementWallet, address(depositCertificate), initialAmount * 10);
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
     * @dev Helper function to approve a spender to use USDT
     * @param from The address that is granting the approval
     * @param spender The address of the spender
     * @param amount The amount of tokens to approve (in 6 decimal format)
     */
    function approveUsdt(address from, address spender, uint256 amount) internal {
        vm.prank(from);
        usdt.approve(spender, amount);
    }

    /**
     * @dev Helper function to fast-forward time in tests
     * @param _seconds The number of seconds to fast-forward
     */
    function warpTime(uint256 _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    function test_SetUp() public view {
        assert(address(depositCertificate) != address(0));
        assert(address(usdt) != address(0));
        assertEq(usdt.balanceOf(user1), initialAmount);
        assertEq(usdt.allowance(user1, address(depositCertificate)), initialAmount);
        assertEq(depositCertificate.ivWallet(), ivWallet);
    }

    function test_redeem_successful_no_penalty() public {
        // Arrange
        uint256 depositAmount = 100 * 10**6; // 100 USDT

        // User1 deposits USDT to get certificates
        vm.prank(user1);
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);

        // Fast-forward time by 5 years
        warpTime(5 * 365 days);

        uint256 user1UsdtBalanceBefore = usdt.balanceOf(user1);
        uint256 settlementWalletUsdtBalanceBefore = usdt.balanceOf(settlementWallet);
        uint256 user1CertificateBalanceBefore = depositCertificate.balanceOf(user1);

        // Act
        vm.prank(user1);
        depositCertificate.redeem(depositAmount);

        // Assert
        assertEq(depositCertificate.balanceOf(user1), user1CertificateBalanceBefore - depositAmount, "User1 certificate balance should decrease by redeemed amount");
        assertEq(usdt.balanceOf(user1), user1UsdtBalanceBefore + depositAmount, "User1 USDT balance should increase by full deposit amount");
        assertEq(usdt.balanceOf(settlementWallet), settlementWalletUsdtBalanceBefore - depositAmount, "Settlement wallet USDT balance should decrease by full deposit amount");
    }

    function test_redeem_successful_partial_penalty() public {
        // Arrange
        uint256 depositAmount = 100 * 10**6; // 100 USDT

        // User1 deposits USDT to get certificates
        vm.prank(user1);
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);

        // Fast-forward time by 2.5 years
        warpTime(2 * 365 days + 182 days);

        (uint256 penaltyAmount, uint256 payoutAmount) = depositCertificate.calculatePenalty(user1, depositAmount);

        uint256 user1UsdtBalanceBefore = usdt.balanceOf(user1);
        uint256 settlementWalletUsdtBalanceBefore = usdt.balanceOf(settlementWallet);
        uint256 user1CertificateBalanceBefore = depositCertificate.balanceOf(user1);

        // Act
        vm.prank(user1);
        depositCertificate.redeem(depositAmount);

        // Assert
        assertEq(depositCertificate.balanceOf(user1), user1CertificateBalanceBefore - depositAmount, "User1 certificate balance should decrease by redeemed amount");
        assertEq(usdt.balanceOf(user1), user1UsdtBalanceBefore + payoutAmount, "User1 USDT balance should increase by payout amount");
        assertEq(usdt.balanceOf(settlementWallet), settlementWalletUsdtBalanceBefore - payoutAmount, "Settlement wallet USDT balance should decrease by payout amount");
        assertTrue(penaltyAmount > 0 && penaltyAmount < depositAmount / 2, "Penalty should be partial");
    }

    function test_redeem_successful_max_penalty() public {
        // Arrange
        uint256 depositAmount = 100 * 10**6; // 100 USDT

        // User1 deposits USDT to get certificates
        vm.prank(user1);
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);

        // Fast-forward time by 6 months
        warpTime(182 days);

        (uint256 penaltyAmount, uint256 payoutAmount) = depositCertificate.calculatePenalty(user1, depositAmount);

        uint256 user1UsdtBalanceBefore = usdt.balanceOf(user1);
        uint256 settlementWalletUsdtBalanceBefore = usdt.balanceOf(settlementWallet);
        uint256 user1CertificateBalanceBefore = depositCertificate.balanceOf(user1);

        // Act
        vm.prank(user1);
        depositCertificate.redeem(depositAmount);

        // Assert
        assertEq(depositCertificate.balanceOf(user1), user1CertificateBalanceBefore - depositAmount, "User1 certificate balance should decrease by redeemed amount");
        assertEq(usdt.balanceOf(user1), user1UsdtBalanceBefore + payoutAmount, "User1 USDT balance should increase by payout amount");
        assertEq(usdt.balanceOf(settlementWallet), settlementWalletUsdtBalanceBefore - payoutAmount, "Settlement wallet USDT balance should decrease by payout amount");
        assertEq(penaltyAmount, depositAmount / 2, "Penalty should be 50%");
    }

    function test_redeem_fails_insufficient_balance() public {
        // Arrange
        uint256 depositAmount = 100 * 10**6; // 100 USDT
        uint256 redeemAmount = depositAmount + 1;

        // User1 deposits USDT to get certificates
        vm.prank(user1);
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert("Insufficient certificate token balance");
        depositCertificate.redeem(redeemAmount);
    }

    function test_redeem_fails_zero_amount() public {
        // Arrange
        uint256 depositAmount = 100 * 10**6; // 100 USDT
        uint256 redeemAmount = 0;

        // User1 deposits USDT to get certificates
        vm.prank(user1);
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);

        // Act & Assert
        vm.prank(user1);
        vm.expectRevert("Redeem amount must be greater than zero");
        depositCertificate.redeem(redeemAmount);
    }

    function test_redeem_fails_no_certificates() public {
        // Arrange
        uint256 redeemAmount = 100 * 10**6; // 100 USDT
        address user2 = makeAddr("user2");

        // Act & Assert
        vm.prank(user2);
        vm.expectRevert("Insufficient certificate token balance");
        depositCertificate.redeem(redeemAmount);
    }
}
