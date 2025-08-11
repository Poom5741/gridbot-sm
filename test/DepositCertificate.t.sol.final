// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DepositCertificate} from "../src/DepositCertificate.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {MockRejectTransfer} from "../src/MockRejectTransfer.sol";

contract DepositCertificateTest is Test {
    DepositCertificate public depositCertificate;
    MockUSDT public usdt;

    address public owner;
    address public user1;
    address public user2;
    address public settlementWallet;

    address public ivWallet;
    address public dvWallet;
    address public adWallet;
    address public mlWallet;
    address public bcWallet;
    address public ml1Wallet;
    address public ml2Wallet;
    address public ml3Wallet;

    uint256 public initialAmount = 1000 * 10**6;

    uint256 public constant P_IV_TEST = 55;
    uint256 public constant P_DV_TEST = 5;
    uint256 public constant P_AD_TEST = 5;
    uint256 public constant P_ML_TEST = 15;
    uint256 public constant P_BC_TEST = 5;
    uint256 public constant P_ML1_TEST = 10;
    uint256 public constant P_ML2_TEST = 3;
    uint256 public constant P_ML3_TEST = 2;
    uint256 public constant TOTAL_PERCENTAGE = 100;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        settlementWallet = makeAddr("settlementWallet");

        ivWallet = makeAddr("ivWallet");
        dvWallet = makeAddr("dvWallet");
        adWallet = makeAddr("adWallet");
        mlWallet = makeAddr("mlWallet");
        bcWallet = makeAddr("bcWallet");
        ml1Wallet = makeAddr("ml1Wallet");
        ml2Wallet = makeAddr("ml2Wallet");
        ml3Wallet = makeAddr("ml3Wallet");

        vm.prank(owner);
        usdt = new MockUSDT("Mock USDT", "USDT");

        vm.prank(owner);
        depositCertificate = new DepositCertificate(
            address(usdt),
            settlementWallet,
            ivWallet,
            dvWallet,
            adWallet,
            mlWallet,
            bcWallet,
            ml1Wallet,
            ml2Wallet,
            ml3Wallet
        );

        mintUsdtTo(user1, initialAmount);
        mintUsdtTo(user2, initialAmount);

        approveUsdt(user1, initialAmount);
        approveUsdt(user2, initialAmount);
    }

    function mintUsdtTo(address to, uint256 amount) internal {
        vm.prank(owner);
        usdt.mint(to, amount);
    }

    function approveUsdt(address from, uint256 amount) internal {
        vm.prank(from);
        usdt.approve(address(depositCertificate), amount);
    }

    function warpTime(uint256 _seconds) internal {
        vm.warp(block.timestamp + _seconds);
    }

    function test_SetUp() public view {
        assert(address(depositCertificate) != address(0));
        assert(address(usdt) != address(0));
        assertEq(usdt.balanceOf(user1), initialAmount);
        assertEq(usdt.balanceOf(user2), initialAmount);
        assertEq(usdt.allowance(user1, address(depositCertificate)), initialAmount);
        assertEq(usdt.allowance(user2, address(depositCertificate)), initialAmount);
        assertEq(depositCertificate.usdtToken(), address(usdt));
        assertEq(depositCertificate.settlementWallet(), settlementWallet);
        assertEq(depositCertificate.ivWallet(), ivWallet);
        assertEq(depositCertificate.dvWallet(), dvWallet);
        assertEq(depositCertificate.adWallet(), adWallet);
        assertEq(depositCertificate.mlWallet(), mlWallet);
        assertEq(depositCertificate.bcWallet(), bcWallet);
    }

    function test_Deposit_Success() public {
        uint256 depositAmount = 100 * 10**6;
        uint256 user1InitialUsdtBalance = usdt.balanceOf(user1);
        uint256 user1InitialCertificateBalance = depositCertificate.balanceOf(user1);

        uint256 ivWalletInitialBalance = usdt.balanceOf(ivWallet);
        uint256 dvWalletInitialBalance = usdt.balanceOf(dvWallet);
        uint256 adWalletInitialBalance = usdt.balanceOf(adWallet);
        uint256 mlWalletInitialBalance = usdt.balanceOf(mlWallet);
        uint256 bcWalletInitialBalance = usdt.balanceOf(bcWallet);
        uint256 ml1WalletInitialBalance = usdt.balanceOf(ml1Wallet);
        uint256 ml2WalletInitialBalance = usdt.balanceOf(ml2Wallet);
        uint256 ml3WalletInitialBalance = usdt.balanceOf(ml3Wallet);

        uint256 expectedIvAmount = (depositAmount * P_IV_TEST) / 100;
        uint256 expectedDvAmount = (depositAmount * P_DV_TEST) / 100;
        uint256 expectedAdAmount = (depositAmount * P_AD_TEST) / 100;
        uint256 expectedMlAmount = (depositAmount * P_ML_TEST) / 100;
        uint256 expectedBcAmount = (depositAmount * P_BC_TEST) / 100;
        uint256 expectedMl1Amount = (depositAmount * P_ML1_TEST) / 100;
        uint256 expectedMl2Amount = (depositAmount * P_ML2_TEST) / 100;
        uint256 expectedMl3Amount = (depositAmount * P_ML3_TEST) / 100;

        vm.prank(user1);
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);

        assertEq(usdt.balanceOf(user1), user1InitialUsdtBalance - depositAmount);

        assertEq(usdt.balanceOf(ivWallet), ivWalletInitialBalance + expectedIvAmount);
        assertEq(usdt.balanceOf(dvWallet), dvWalletInitialBalance + expectedDvAmount);
        assertEq(usdt.balanceOf(adWallet), adWalletInitialBalance + expectedAdAmount);
        assertEq(usdt.balanceOf(mlWallet), mlWalletInitialBalance + expectedMlAmount);
        assertEq(usdt.balanceOf(bcWallet), bcWalletInitialBalance + expectedBcAmount);
        assertEq(usdt.balanceOf(ml1Wallet), ml1WalletInitialBalance + expectedMl1Amount);
        assertEq(usdt.balanceOf(ml2Wallet), ml2WalletInitialBalance + expectedMl2Amount);
        assertEq(usdt.balanceOf(ml3Wallet), ml3WalletInitialBalance + expectedMl3Amount);

        assertEq(depositCertificate.balanceOf(user1), user1InitialCertificateBalance + depositAmount);

        assertEq(depositCertificate.lastDepositTime(user1), block.timestamp);
    }

    function test_Deposit_ZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert("Deposit amount must be greater than zero");
        depositCertificate.deposit(0, ml1Wallet, ml2Wallet, ml3Wallet);
    }

    function test_Deposit_InsufficientBalance() public {
        uint256 depositAmount = initialAmount + 1;
        vm.prank(user1);
        vm.expectRevert();
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);
    }

    function test_Deposit_InsufficientApproval() public {
        uint256 depositAmount = 100 * 10**6;
        vm.prank(user1);
        usdt.approve(address(depositCertificate), depositAmount - 1);
        vm.prank(user1);
        vm.expectRevert();
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, ml3Wallet);
    }

    function test_Deposit_ZeroLevel1Wallet() public {
        uint256 depositAmount = 100 * 10**6;
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(depositAmount, address(0), ml2Wallet, ml3Wallet);
    }

    function test_Deposit_ZeroLevel2Wallet() public {
        uint256 depositAmount = 100 * 10**6;
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(depositAmount, ml1Wallet, address(0), ml3Wallet);
    }

    function test_Deposit_ZeroLevel3Wallet() public {
        uint256 depositAmount = 100 * 10**6;
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(depositAmount, ml1Wallet, ml2Wallet, address(0));
    }

    function test_Deposit_AllZeroMLMWallets() public {
        uint256 depositAmount = 100 * 10**6;
        vm.prank(user1);
        vm.expectRevert("MLM wallet addresses cannot be zero address");
        depositCertificate.deposit(depositAmount, address(0), address(0), address(0));
    }
}
