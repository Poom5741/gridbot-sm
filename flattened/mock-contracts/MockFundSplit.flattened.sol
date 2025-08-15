// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 ^0.8.20;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.4.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// src/MockFundSplit.sol

/**
 * @title MockFundSplit
 * @dev A simplified demonstration of the Fixed Fund Split on Deposit feature
 * Shows how deposit amounts are split among 8 wallets (5 fixed, 3 dynamic MLM) with precision
 */
contract MockFundSplit {
    address public immutable invest_wallet;      // 55% (fixed)
    address public immutable dev_ops_wallet;      // 5%  (fixed)
    address public immutable advisor_wallet;     // 5%  (fixed)
    address public immutable marketing_wallet;   // 15% (fixed)
    address public immutable owner_wallet;       // 5%  (fixed)
    
    address public level1_wallet;                // 10% (dynamic, owner only)
    address public level2_wallet;                // 3%  (dynamic, owner only)
    address public level3_wallet;                // 2%  (dynamic, owner only)
    
    // Totals for demo accounting
    mapping(address => uint256) public wallet_balances;
    uint256 public total_deposited;
    
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
        address _invest_wallet,
        address _dev_ops_wallet,
        address _advisor_wallet,
        address _marketing_wallet,
        address _owner_wallet
    ) {
        require(_invest_wallet != address(0) &&
                _dev_ops_wallet != address(0) &&
                _advisor_wallet != address(0) &&
                _marketing_wallet != address(0) &&
                _owner_wallet != address(0), "Wallet address cannot be zero");
        
        invest_wallet = _invest_wallet;
        dev_ops_wallet = _dev_ops_wallet;
        advisor_wallet = _advisor_wallet;
        marketing_wallet = _marketing_wallet;
        owner_wallet = _owner_wallet;
        
        level1_wallet = msg.sender; // Set to deployer initially
        level2_wallet = msg.sender;
        level3_wallet = msg.sender;
    }
    
    function deposit(
        uint256 amount,
        address _level1_wallet,
        address _level2_wallet,
        address _level3_wallet
    ) external {
        require(amount > 0, "Amount must be > 0");
        require(_level1_wallet != address(0) &&
                _level2_wallet != address(0) &&
                _level3_wallet != address(0), "MLM wallets cannot be zero");
        
        // Calculate fixed wallet split amounts (uses basis points: 5500 = 55%)
        uint256 basisPoints = 10000; // = 100%
        uint256 invest_amount = (amount * 5500) / basisPoints;     // 55%
        uint256 dev_ops_amount = (amount * 500) / basisPoints;      // 5%
        uint256 advisor_amount = (amount * 500) / basisPoints;     // 5%
        uint256 marketing_amount = (amount * 1500) / basisPoints;  // 15%
        uint256 owner_amount = (amount * 500) / basisPoints;       // 5%
        uint256 level1_amount = (amount * 1000) / basisPoints;     // 10%
        uint256 level2_amount = (amount * 300) / basisPoints;      // 3%
        uint256 level3_amount = (amount * 200) / basisPoints;      // 2%
        
        // Validate total is 100%
        uint256 total_split = invest_amount + dev_ops_amount + advisor_amount +
                            marketing_amount + owner_amount + level1_amount +
                            level2_amount + level3_amount;
        require(total_split == amount, "Fund split percentages must sum to 100%");
        
        // For demo, we'll just update balances (simulating transfers)
        wallet_balances[invest_wallet] += invest_amount;
        wallet_balances[dev_ops_wallet] += dev_ops_amount;
        wallet_balances[advisor_wallet] += advisor_amount;
        wallet_balances[marketing_wallet] += marketing_amount;
        wallet_balances[owner_wallet] += owner_amount;
        wallet_balances[_level1_wallet] += level1_amount;
        wallet_balances[_level2_wallet] += level2_amount;
        wallet_balances[_level3_wallet] += level3_amount;
        
        total_deposited += amount;
        
        // Prepare arrays for event emission
        address[] memory wallets = new address[](8);
        uint256[] memory amounts = new uint256[](8);
        wallets[0] = invest_wallet;      amounts[0] = invest_amount;
        wallets[1] = dev_ops_wallet;      amounts[1] = dev_ops_amount;
        wallets[2] = advisor_wallet;     amounts[2] = advisor_amount;
        wallets[3] = marketing_wallet;   amounts[3] = marketing_amount;
        wallets[4] = owner_wallet;       amounts[4] = owner_amount;
        wallets[5] = _level1_wallet;     amounts[5] = level1_amount;
        wallets[6] = _level2_wallet;     amounts[6] = level2_amount;
        wallets[7] = _level3_wallet;     amounts[7] = level3_amount;
        
        emit DepositedWithSplit(
            msg.sender,
            amount,
            invest_amount, dev_ops_amount, advisor_amount, marketing_amount, owner_amount,
            level1_amount, level2_amount, level3_amount,
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
        
        level1_wallet = _level1;
        level2_wallet = _level2;
        level3_wallet = _level3;
        
        emit MLMWalletsUpdated(msg.sender, _level1, _level2, _level3);
    }
    
    function getFundSplitCalculation(uint256 amount)
        public
        pure
        returns (
            uint256 invest_amount,
            uint256 dev_ops_amount,
            uint256 advisor_amount,
            uint256 marketing_amount,
            uint256 owner_amount,
            uint256 level1_amount,
            uint256 level2_amount,
            uint256 level3_amount
        )
    {
        uint256 basisPoints = 10000;
        invest_amount = (amount * 5500) / basisPoints;
        dev_ops_amount = (amount * 500) / basisPoints;
        advisor_amount = (amount * 500) / basisPoints;
        marketing_amount = (amount * 1500) / basisPoints;
        owner_amount = (amount * 500) / basisPoints;
        level1_amount = (amount * 1000) / basisPoints;
        level2_amount = (amount * 300) / basisPoints;
        level3_amount = (amount * 200) / basisPoints;
    }
    
    function getAllWalletAddresses()
        public
        view
        returns (address[8] memory addrs)
    {
        addrs[0] = invest_wallet;
        addrs[1] = dev_ops_wallet;
        addrs[2] = advisor_wallet;
        addrs[3] = marketing_wallet;
        addrs[4] = owner_wallet;
        addrs[5] = level1_wallet;
        addrs[6] = level2_wallet;
        addrs[7] = level3_wallet;
    }
    
    function getTotalBalance(address wallet) public view returns (uint256) {
        return wallet_balances[wallet];
    }
}
