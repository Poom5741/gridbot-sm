// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MockFundSplit
 * @dev A simplified demonstration of the Fixed Fund Split on Deposit feature
 * Shows how deposit amounts are split among 8 wallets (5 fixed, 3 dynamic MLM) with precision
 */
contract MockFundSplit {
    address public immutable investWallet;      // 55% (fixed)
    address public immutable devOpsWallet;      // 5%  (fixed)
    address public immutable advisorWallet;     // 5%  (fixed)
    address public immutable marketingWallet;   // 15% (fixed)
    address public immutable ownerWallet;       // 5%  (fixed)
    
    address public level1Wallet;                // 10% (dynamic, owner only)
    address public level2Wallet;                // 3%  (dynamic, owner only)
    address public level3Wallet;                // 2%  (dynamic, owner only)
    
    // Totals for demo accounting
    mapping(address => uint256) public walletBalances;
    uint256 public totalDeposited;
    
    event DepositedWithSplit(
        address indexed depositor,
        uint256 amount,
        uint256 investAmount,
        uint256 devOpsAmount,
        uint256 advisorAmount,
        uint256 marketingAmount,
        uint256 ownerAmount,
        uint256 level1Amount,
        uint256 level2Amount,
        uint256 level3Amount,
        address[] walletRecipients,
        uint256[] splitAmounts
    );
    
    event MLMWalletsUpdated(
        address indexed updater,
        address newLevel1,
        address newLevel2,
        address newLevel3
    );
    
    constructor(
        address _investWallet,
        address _devOpsWallet,
        address _advisorWallet,
        address _marketingWallet,
        address _ownerWallet
    ) {
        require(_investWallet != address(0) && 
                _devOpsWallet != address(0) && 
                _advisorWallet != address(0) && 
                _marketingWallet != address(0) && 
                _ownerWallet != address(0), "Wallet address cannot be zero");
        
        investWallet = _investWallet;
        devOpsWallet = _devOpsWallet;
        advisorWallet = _advisorWallet;
        marketingWallet = _marketingWallet;
        ownerWallet = _ownerWallet;
        
        level1Wallet = msg.sender; // Set to deployer initially
        level2Wallet = msg.sender;
        level3Wallet = msg.sender;
    }
    
    function deposit(
        uint256 amount,
        address _level1Wallet,
        address _level2Wallet,
        address _level3Wallet
    ) external {
        require(amount > 0, "Amount must be > 0");
        require(_level1Wallet != address(0) && 
                _level2Wallet != address(0) && 
                _level3Wallet != address(0), "MLM wallets cannot be zero");
        
        // Calculate fixed wallet split amounts (uses basis points: 5500 = 55%)
        uint256 basisPoints = 10000; // = 100%
        uint256 investAmount = (amount * 5500) / basisPoints;     // 55%
        uint256 devOpsAmount = (amount * 500) / basisPoints;      // 5%
        uint256 advisorAmount = (amount * 500) / basisPoints;     // 5%
        uint256 marketingAmount = (amount * 1500) / basisPoints;  // 15%
        uint256 ownerAmount = (amount * 500) / basisPoints;       // 5%
        uint256 level1Amount = (amount * 1000) / basisPoints;     // 10%
        uint256 level2Amount = (amount * 300) / basisPoints;      // 3%
        uint256 level3Amount = (amount * 200) / basisPoints;      // 2%
        
        // Validate total is 100%
        uint256 totalSplit = investAmount + devOpsAmount + advisorAmount + 
                            marketingAmount + ownerAmount + level1Amount + 
                            level2Amount + level3Amount;
        require(totalSplit == amount, "Fund split percentages must sum to 100%");
        
        // For demo, we'll just update balances (simulating transfers)
        walletBalances[investWallet] += investAmount;
        walletBalances[devOpsWallet] += devOpsAmount;
        walletBalances[advisorWallet] += advisorAmount;
        walletBalances[marketingWallet] += marketingAmount;
        walletBalances[ownerWallet] += ownerAmount;
        walletBalances[_level1Wallet] += level1Amount;
        walletBalances[_level2Wallet] += level2Amount;
        walletBalances[_level3Wallet] += level3Amount;
        
        totalDeposited += amount;
        
        // Prepare arrays for event emission
        address[] memory wallets = new address[](8);
        uint256[] memory amounts = new uint256[](8);
        wallets[0] = investWallet;      amounts[0] = investAmount;
        wallets[1] = devOpsWallet;      amounts[1] = devOpsAmount;
        wallets[2] = advisorWallet;     amounts[2] = advisorAmount;
        wallets[3] = marketingWallet;   amounts[3] = marketingAmount;
        wallets[4] = ownerWallet;       amounts[4] = ownerAmount;
        wallets[5] = _level1Wallet;     amounts[5] = level1Amount;
        wallets[6] = _level2Wallet;     amounts[6] = level2Amount;
        wallets[7] = _level3Wallet;     amounts[7] = level3Amount;
        
        emit DepositedWithSplit(
            msg.sender,
            amount,
            investAmount, devOpsAmount, advisorAmount, marketingAmount, ownerAmount,
            level1Amount, level2Amount, level3Amount,
            wallets,
            amounts
        );
    }
    
    function updateMLMWallets(
        address _level1,
        address _level2,
        address _level3
    ) external {
        require(_level1 != address(0) && 
                _level2 != address(0) && 
                _level3 != address(0), "MLM wallets cannot be zero");
        
        level1Wallet = _level1;
        level2Wallet = _level2;
        level3Wallet = _level3;
        
        emit MLMWalletsUpdated(msg.sender, _level1, _level2, _level3);
    }
    
    function getFundSplitCalculation(uint256 amount) 
        public 
        pure 
        returns (
            uint256 invest,
            uint256 devOps,
            uint256 advisor,
            uint256 marketing,
            uint256 owner,
            uint256 level1,
            uint256 level2,
            uint256 level3
        )
    {
        uint256 basisPoints = 10000;
        invest = (amount * 5500) / basisPoints; 
        devOps = (amount * 500) / basisPoints;
        advisor = (amount * 500) / basisPoints;
        marketing = (amount * 1500) / basisPoints;
        owner = (amount * 500) / basisPoints;
        level1 = (amount * 1000) / basisPoints;
        level2 = (amount * 300) / basisPoints;
        level3 = (amount * 200) / basisPoints;
    }
    
    function getAllWalletAddresses() 
        public 
        view 
        returns (address[8] memory addrs)
    {
        addrs[0] = investWallet;
        addrs[1] = devOpsWallet;
        addrs[2] = advisorWallet;
        addrs[3] = marketingWallet;
        addrs[4] = ownerWallet;
        addrs[5] = level1Wallet;
        addrs[6] = level2Wallet;
        addrs[7] = level3Wallet;
    }
    
    function getTotalBalance(address wallet) public view returns (uint256) {
        return walletBalances[wallet];
    }
}