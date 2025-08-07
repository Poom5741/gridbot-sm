// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/DepositCertificate.sol";
import "../src/MockRejectTransfer.sol";

contract DeployMockAndCert is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(pk);
        // Using MockRejectTransfer as placeholder; replace with actual MockUSDT if available
        MockRejectTransfer usdt = new MockRejectTransfer();

        address settlement = vm.addr(0x1000);
        address invest = vm.addr(0x1001);
        address devops = vm.addr(0x1002);
        address advisor = vm.addr(0x1003);
        address marketing = vm.addr(0x1004);
        address ownerWallet = vm.addr(0x1005);
        address level1Wallet = vm.addr(0x1006);
        address level2Wallet = vm.addr(0x1007);
        address level3Wallet = vm.addr(0x1008);

        DepositCertificate cert = new DepositCertificate(
            address(usdt),
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

        console2.log("USDT (mock reject):", address(usdt));
        console2.log("DepositCertificate:", address(cert));
    }
}
