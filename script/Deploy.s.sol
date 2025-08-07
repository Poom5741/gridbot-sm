// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DepositCertificate.sol";

contract Deploy is Script {
    function run() external {
        address usdt = vm.envAddress("USDT_ADDRESS");
        address settlement = vm.envAddress("SETTLEMENT_WALLET_ADDRESS");

        address invest = vm.envAddress("INVEST_WALLET_ADDRESS");
        address devops = vm.envAddress("DEVOPS_WALLET_ADDRESS");
        address advisor = vm.envAddress("ADVISOR_WALLET_ADDRESS");
        address marketing = vm.envAddress("MARKETING_WALLET_ADDRESS");
        address ownerWallet = vm.envAddress("OWNER_WALLET_ADDRESS");
        
        address level1Wallet = vm.envAddress("LEVEL1_WALLET_ADDRESS");
        address level2Wallet = vm.envAddress("LEVEL2_WALLET_ADDRESS");
        address level3Wallet = vm.envAddress("LEVEL3_WALLET_ADDRESS");

        uint256 pk = vm.envUint("PRIVATE_KEY");

        require(usdt != address(0) && settlement != address(0), "bad core addresses");
        require(invest != address(0) && devops != address(0) && advisor != address(0) && marketing != address(0) && ownerWallet != address(0), "bad fixed wallet addresses");
        require(level1Wallet != address(0) && level2Wallet != address(0) && level3Wallet != address(0), "bad MLM wallet addresses");

        vm.startBroadcast(pk);
        DepositCertificate cert = new DepositCertificate(
            usdt,
            settlement,
            invest,
            devops,
            advisor,
            marketing,
            ownerWallet,
            level1Wallet,
            level2Wallet,
            level3Wallet
        );
        vm.stopBroadcast();

        // Set MLM wallet addresses after deployment
        vm.startBroadcast(pk);
        cert.updateMLMWallets(level1Wallet, level2Wallet, level3Wallet);
        vm.stopBroadcast();

        console2.log("DepositCertificate:", address(cert));
        console2.log("USDT:", usdt);
        console2.log("Settlement:", settlement);
        console2.log("Invest:", invest);
        console2.log("DevOps:", devops);
        console2.log("Advisor:", advisor);
        console2.log("Marketing:", marketing);
        console2.log("Owner:", ownerWallet);
        console2.log("Level1 MLM:", level1Wallet);
        console2.log("Level2 MLM:", level2Wallet);
        console2.log("Level3 MLM:", level3Wallet);
    }
}
