// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/MockFundSplit.sol";

contract ShowFundSplitDemo is Script {
    function run() external {
        address invest = 0x1000000000000000000000000000000000001000;
        address devops = 0x1000000000000000000000000000000000001001;
        address advisor = 0x1000000000000000000000000000000000001002;
        address marketing = 0x1000000000000000000000000000000000001003;
        address owner = 0x1000000000000000000000000000000000001004;

        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        
        MockFundSplit fundSplit = new MockFundSplit(
            invest, devops, advisor, marketing, owner
        );
        
        console2.log("MockFundSplit deployed:", address(fundSplit));
        console2.log("Fixed wallets:");
        console2.log("  invest: ", invest);
        console2.log("  devops: ", devops);
        console2.log("  advisor:", advisor);
        console2.log("  marketing:", marketing);
        console2.log("  owner:", owner);
        console2.log("Dynamic MLM (initially same as deployer):");
        console2.log("  level1:", fundSplit.level1_wallet());
        console2.log("  level2:", fundSplit.level2_wallet());
        console2.log("  level3:", fundSplit.level3_wallet());
        console2.log("");

        // Show calculation
        uint256 depositAmount = 1000 ether; // 1000 for easy math
        (uint256 investAmt, uint256 devopsAmt, uint256 advisorAmt, 
         uint256 marketingAmt, uint256 ownerAmt, 
         uint256 level1Amt, uint256 level2Amt, uint256 level3Amt) = 
            fundSplit.getFundSplitCalculation(depositAmount);

        console2.log("For $",depositAmount," deposit:");
        console2.log("  invest (55%): ", investAmt);
        console2.log("  devops (5%): ", devopsAmt);
        console2.log("  advisor (5%): ", advisorAmt);
        console2.log("  marketing (15%): ", marketingAmt);
        console2.log("  owner (5%): ", ownerAmt);
        console2.log("  level1 (10%): ", level1Amt);
        console2.log("  level2 (3%): ", level2Amt);
        console2.log("  level3 (2%): ", level3Amt);
        console2.log("");

        // New MLMs for demo
        address newLevel1 = 0x1000000000000000000000000000000000002000;
        address newLevel2 = 0x1000000000000000000000000000000000002001;
        address newLevel3 = 0x1000000000000000000000000000000000002002;

        fundSplit.updateMLMWallets(newLevel1, newLevel2, newLevel3);
        console2.log("MLM wallets updated to:");
        console2.log("  level1:", fundSplit.level1_wallet());
        console2.log("  level2:", fundSplit.level2_wallet());
        console2.log("  level3:", fundSplit.level3_wallet());

        vm.stopBroadcast();
    }
}