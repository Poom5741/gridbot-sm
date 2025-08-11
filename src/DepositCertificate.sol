// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title DepositCertificate
 * @dev ERC20 Deposit Certificate system that represents deposits of USDT tokens
 * This contract manages the creation and redemption of deposit certificates
 */
contract DepositCertificate is ERC20, Ownable {
    using SafeERC20 for IERC20;

    // Immutable state variables
    address public immutable usdtToken;
    address public immutable settlementWallet;
    
    // Fixed wallet addresses for fund split
    address public immutable ivWallet;
    address public immutable dvWallet;
    address public immutable adWallet;
    address public immutable maWallet;
    address public immutable owWallet;

    // Dynamic MLM wallet addresses (can be updated by owner)
    address public ml1Wallet;
    address public ml2Wallet;
    address public ml3Wallet;

    // Constants for fund split percentages (in basis points)
    uint256 public constant INVEST_PERCENTAGE = 5500;
    uint256 public constant DEV_OPS_PERCENTAGE = 500;
    uint256 public constant ADVISOR_PERCENTAGE = 500;
    uint256 public constant MARKETING_PERCENTAGE = 1500;
    uint256 public constant OWNER_PERCENTAGE = 500;
    uint256 public constant LEVEL1_PERCENTAGE = 1000;
    uint256 public constant LEVEL2_PERCENTAGE = 300;
    uint256 public constant LEVEL3_PERCENTAGE = 200;

    // Event emitted when wallet addresses are updated
    event WalletAddressesUpdated(
        address indexed updater,
        address newMl1Wallet,
        address newMl2Wallet,
        address newMl3Wallet
    );

    // Event emitted when wallet addresses are updated
    event FundSplitCalculated(
        address indexed caller,
        uint256 amount,
        uint256 investAmount,
        uint256 devOpsAmount,
        uint256 advisorAmount,
        uint256 marketingAmount,
        uint256 ownerAmount,
        uint256 level1Amount,
        uint256 level2Amount,
        uint256 level3Amount
    );

    // Mapping to track the last deposit time for each holder
    mapping(address => uint256) public lastDepositTime;

    // Event emitted when a deposit is made
    event Deposited(
        address indexed depositor,
        uint256 amount,
        uint256 timestamp,
        address ml1Wallet,
        address ml2Wallet,
        address ml3Wallet
    );

    // Event emitted when a timestamp is updated
    event TimestampUpdated(
        address indexed holder,
        uint256 newTimestamp
    );

    // Event emitted when certificates are redeemed
    event Redeemed(
        address indexed redeemer,
        uint256 redeemedAmount,
        uint256 payoutAmount,
        uint256 penaltyAmount
    );

    // Constants for penalty calculation
    uint256 public constant ONE_YEAR_IN_SECONDS = 365 days;
    uint256 public constant FIVE_YEARS_IN_SECONDS = 5 * 365 days;
    uint256 public constant BASIS_POINTS = 10000; // 100% in basis points

    /**
     * @dev Constructor that initializes the Deposit Certificate contract
     * @param _usdtTokenAddress The address of the USDT token contract
     * @param _settlementWalletAddress The address that will receive USDT deposits
     * @param _ivWalletAddress The address that will receive 55% of deposits
     * @param _dvWalletAddress The address that will receive 5% of deposits
     * @param _adWalletAddress The address that will receive 5% of deposits
     * @param _maWalletAddress The address that will receive 15% of deposits
     * @param _owWalletAddress The address that will receive 5% of deposits
     */
    constructor(
        address _usdtTokenAddress,
        address _settlementWalletAddress,
        address _ivWalletAddress,
        address _dvWalletAddress,
        address _adWalletAddress,
        address _maWalletAddress,
        address _owWalletAddress,
        address _ml1WalletAddress,
        address _ml2WalletAddress,
        address _ml3WalletAddress
    ) ERC20("Deposit Certificate", "DC") Ownable(msg.sender) {
        require(_usdtTokenAddress != address(0), "USDT token address cannot be zero");
        require(_settlementWalletAddress != address(0), "Settlement wallet address cannot be zero");
        require(_ivWalletAddress != address(0), "Invest wallet address cannot be zero");
        require(_dvWalletAddress != address(0), "DevOps wallet address cannot be zero");
        require(_adWalletAddress != address(0), "Advisor wallet address cannot be zero");
        require(_maWalletAddress != address(0), "Marketing wallet address cannot be zero");
        require(_owWalletAddress != address(0), "Owner wallet address cannot be zero");
        require(_ml1WalletAddress != address(0), "Level 1 wallet address cannot be zero");
        require(_ml2WalletAddress != address(0), "Level 2 wallet address cannot be zero");
        require(_ml3WalletAddress != address(0), "Level 3 wallet address cannot be zero");
        
        usdtToken = _usdtTokenAddress;
        settlementWallet = _settlementWalletAddress;
        ivWallet = _ivWalletAddress;
        dvWallet = _dvWalletAddress;
        adWallet = _adWalletAddress;
        maWallet = _maWalletAddress;
        owWallet = _owWalletAddress;
        ml1Wallet = _ml1WalletAddress;
        ml2Wallet = _ml2WalletAddress;
        ml3Wallet = _ml3WalletAddress;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    /**
     * @dev Deposit USDT tokens and receive certificate tokens in return
     * @param amount The amount of USDT tokens to deposit
     * @param _ml1Wallet Address for Level 1 MLM Incentive
     * @param _ml2Wallet Address for Level 2 MLM Incentive
     * @param _ml3Wallet Address for Level 3 MLM Incentive
     */
    function deposit(
        uint256 amount,
        address _ml1Wallet,
        address _ml2Wallet,
        address _ml3Wallet
    ) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        
        // Validate MLM wallet addresses
        require(_ml1Wallet != address(0), "Level 1 wallet address cannot be zero");
        require(_ml2Wallet != address(0), "Level 2 wallet address cannot be zero");
        require(_ml3Wallet != address(0), "Level 3 wallet address cannot be zero");
        
        // Total percentage should be 100%
        uint256 totalPercentage = INVEST_PERCENTAGE + DEV_OPS_PERCENTAGE + ADVISOR_PERCENTAGE +
                                 MARKETING_PERCENTAGE + OWNER_PERCENTAGE + LEVEL1_PERCENTAGE +
                                 LEVEL2_PERCENTAGE + LEVEL3_PERCENTAGE;
        require(totalPercentage == BASIS_POINTS, "Fund split percentages must sum to 100%");
        
        // Calculate fund split amounts using constants
        uint256 investAmount = (amount * INVEST_PERCENTAGE) / BASIS_POINTS;
        uint256 devOpsAmount = (amount * DEV_OPS_PERCENTAGE) / BASIS_POINTS;
        uint256 advisorAmount = (amount * ADVISOR_PERCENTAGE) / BASIS_POINTS;
        uint256 marketingAmount = (amount * MARKETING_PERCENTAGE) / BASIS_POINTS;
        uint256 ownerAmount = (amount * OWNER_PERCENTAGE) / BASIS_POINTS;
        uint256 level1Amount = (amount * LEVEL1_PERCENTAGE) / BASIS_POINTS;
        uint256 level2Amount = (amount * LEVEL2_PERCENTAGE) / BASIS_POINTS;
        uint256 level3Amount = (amount * LEVEL3_PERCENTAGE) / BASIS_POINTS;
        
        // Emit FundSplitCalculated event
        emit FundSplitCalculated(
            msg.sender,
            amount,
            investAmount,
            devOpsAmount,
            advisorAmount,
            marketingAmount,
            ownerAmount,
            level1Amount,
            level2Amount,
            level3Amount
        );
        
        // Transfer USDT from user to all wallets atomically
        IERC20(usdtToken).safeTransferFrom(msg.sender, ivWallet, investAmount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, dvWallet, devOpsAmount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, adWallet, advisorAmount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, maWallet, marketingAmount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, owWallet, ownerAmount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, _ml1Wallet, level1Amount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, _ml2Wallet, level2Amount);
        IERC20(usdtToken).safeTransferFrom(msg.sender, _ml3Wallet, level3Amount);
        
        // Mint certificate tokens to the depositor
        _mint(msg.sender, amount);
        
        // Update the last deposit time for the depositor
        lastDepositTime[msg.sender] = block.timestamp;
        
        // Emit the Deposited event
        emit Deposited(msg.sender, amount, block.timestamp, _ml1Wallet, _ml2Wallet, _ml3Wallet);
    }

    /**
     * @dev Calculate penalty amount based on time elapsed since last deposit
     * @param holder The address of the certificate holder
     * @param amount The amount of certificate tokens to calculate penalty for
     * @return penaltyAmount The calculated penalty amount
     * @return payoutAmount The amount after deducting penalty (amount - penaltyAmount)
     */
    function calculatePenalty(address holder, uint256 amount)
        public
        view
        returns (uint256 penaltyAmount, uint256 payoutAmount)
    {
        require(holder != address(0), "Holder address cannot be zero");
        require(amount > 0, "Amount must be greater than zero");
        require(lastDepositTime[holder] > 0, "No deposit timestamp found for holder");

        // Calculate elapsed time since last deposit
        uint256 elapsedTime = block.timestamp - lastDepositTime[holder];
        
        // Calculate penalty based on time tiers
        if (elapsedTime < ONE_YEAR_IN_SECONDS) {
            // 0-1 year: 50% penalty (5000 basis points)
            penaltyAmount = (amount * 5000) / BASIS_POINTS;
        } else if (elapsedTime < FIVE_YEARS_IN_SECONDS) {
            // 1-5 years: Linear decrease from 50% to 0%
            // Calculate the linear interpolation factor
            uint256 timeInRange = elapsedTime - ONE_YEAR_IN_SECONDS;
            uint256 totalTimeRange = FIVE_YEARS_IN_SECONDS - ONE_YEAR_IN_SECONDS;
            
            // Calculate penalty percentage (decreases from 5000 to 0 basis points)
            uint256 penaltyBasisPoints = 5000 - (timeInRange * 5000) / totalTimeRange;
            
            // Calculate penalty amount
            penaltyAmount = (amount * penaltyBasisPoints) / BASIS_POINTS;
        } else {
            // 5+ years: 0% penalty (0 basis points)
            penaltyAmount = 0;
        }
        
        // Calculate payout amount (amount - penalty)
        payoutAmount = amount - penaltyAmount;
        
        return (penaltyAmount, payoutAmount);
    }

    /**
     * @dev Update MLM wallet addresses (owner only function)
     * @param _ml1Wallet New address for Level 1 MLM Incentive
     * @param _ml2Wallet New address for Level 2 MLM Incentive
     * @param _ml3Wallet New address for Level 3 MLM Incentive
     */
    function updateMLMWallets(
        address _ml1Wallet,
        address _ml2Wallet,
        address _ml3Wallet
    ) external onlyOwner {
        require(_ml1Wallet != address(0), "Level 1 wallet address cannot be zero");
        require(_ml2Wallet != address(0), "Level 2 wallet address cannot be zero");
        require(_ml3Wallet != address(0), "Level 3 wallet address cannot be zero");
        
        ml1Wallet = _ml1Wallet;
        ml2Wallet = _ml2Wallet;
        ml3Wallet = _ml3Wallet;
        
        emit WalletAddressesUpdated(
            msg.sender,
            _ml1Wallet,
            _ml2Wallet,
            _ml3Wallet
        );
    }

    /**
     * @dev Get current wallet addresses for fund split
     * @return iv Investment wallet address
     * @return dv DevOps wallet address
     * @return ad Advisor wallet address
     * @return ma Marketing wallet address
     * @return ow Owner wallet address
     * @return ml1 Level 1 MLM wallet address
     * @return ml2 Level 2 MLM wallet address
     * @return ml3 Level 3 MLM wallet address
     */
    function getFundSplitWallets()
        external
        view
        returns (
            address iv,
            address dv,
            address ad,
            address ma,
            address ow,
            address ml1,
            address ml2,
            address ml3
        )
    {
        // Return all wallet addresses including immutable ones
        return (
            ivWallet,
            dvWallet,
            adWallet,
            maWallet,
            owWallet,
            ml1Wallet,
            ml2Wallet,
            ml3Wallet
        );
    }

    /**
     * @dev Hook that is called before any token transfer
     * @param from Address sending the tokens
     * @param to Address receiving the tokens
     * @param amount Amount of tokens being transferred
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._update(from, to, amount);

        // Handle minting (from is zero address)
        if (from == address(0)) {
            // Update the recipient's timestamp to current block timestamp
            lastDepositTime[to] = block.timestamp;
            emit TimestampUpdated(to, block.timestamp);
        }
        // Handle burning (to is zero address) - do nothing
        else if (to == address(0)) {
            // No timestamp update for burning
        }
        // Handle regular transfer (both from and to are non-zero addresses)
        else {
            // If sender has a deposit timestamp, use it
            if (lastDepositTime[from] > 0) {
                lastDepositTime[to] = lastDepositTime[from];
            } else {
                // If sender has no deposit timestamp, use current block timestamp
                lastDepositTime[to] = block.timestamp;
            }
            emit TimestampUpdated(to, lastDepositTime[to]);
        }
    }

    /**
     * @dev Redeem certificate tokens and receive USDT in return (minus penalty)
     * @param amount The amount of certificate tokens to redeem
     */
    function redeem(uint256 amount) external {
        require(amount > 0, "Redeem amount must be greater than zero");
        
        // Check if the caller has sufficient certificate token balance
        require(balanceOf(msg.sender) >= amount, "Insufficient certificate token balance");
        
        // Calculate penalty and payout amounts
        (uint256 penaltyAmount, uint256 payoutAmount) = calculatePenalty(msg.sender, amount);
        
        // Burn the certificate tokens from the caller's balance
        _burn(msg.sender, amount);
        
        // Transfer the payout amount of USDT from settlement wallet to caller
        IERC20(usdtToken).safeTransferFrom(settlementWallet, msg.sender, payoutAmount);
        
        // Emit the Redeemed event
        emit Redeemed(msg.sender, amount, payoutAmount, penaltyAmount);
    }
}