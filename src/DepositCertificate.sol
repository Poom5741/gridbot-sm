// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DepositCertificate is ERC20, Ownable {
    using SafeERC20 for IERC20;

    address public immutable usdtToken;
    address public settlementWallet;

    address public ivWallet;
    address public dvWallet;
    address public adWallet;
    address public mlWallet;
    address public bcWallet;

    address public ml1Wallet;
    address public ml2Wallet;
    address public ml3Wallet;

    uint256 public constant P_IV = 5500;
    uint256 public constant P_DV = 500;
    uint256 public constant P_AD = 500;
    uint256 public constant P_ML = 1500;
    uint256 public constant P_BC = 500;
    uint256 public constant P_ML1 = 1000;
    uint256 public constant P_ML2 = 300;
    uint256 public constant P_ML3 = 200;

    event CoreWalletsUpdated(
        address indexed updater,
        address newSettlementWallet,
        address newIvWallet,
        address newDvWallet,
        address newAdWallet,
        address newMlWallet,
        address newBcWallet
    );

    event WalletAddressesUpdated(
        address indexed updater,
        address newMl1Wallet,
        address newMl2Wallet,
        address newMl3Wallet
    );

    event FundSplitCalculated(
        address indexed caller,
        uint256 amount,
        uint256 amtIv,
        uint256 amtDv,
        uint256 amtAd,
        uint256 amtMl,
        uint256 amtBc,
        uint256 amtMl1,
        uint256 amtMl2,
        uint256 amtMl3,
        uint256 remainderAmount
    );

    mapping(address => uint256) public lastDepositTime;

    event Deposited(
        address indexed depositor,
        uint256 amount,
        uint256 timestamp,
        address ml1Wallet,
        address ml2Wallet,
        address ml3Wallet
    );

    event TimestampUpdated(
        address indexed holder,
        uint256 newTimestamp
    );

    event Redeemed(
        address indexed redeemer,
        uint256 redeemedAmount,
        uint256 payoutAmount,
        uint256 penaltyAmount
    );

    uint256 public constant ONE_YEAR_IN_SECONDS = 365 days;
    uint256 public constant FIVE_YEARS_IN_SECONDS = 5 * 365 days;
    uint256 public constant BASIS_POINTS = 10000;

    constructor(
        address _usdtTokenAddress,
        address _settlementWalletAddress,
        address _ivWalletAddress,
        address _dvWalletAddress,
        address _adWalletAddress,
        address _mlWalletAddress,
        address _bcWalletAddress,
        address _ml1WalletAddress,
        address _ml2WalletAddress,
        address _ml3WalletAddress
    ) ERC20("Deposit Certificate", "DC") Ownable(msg.sender) {
        require(_usdtTokenAddress != address(0));
        require(_settlementWalletAddress != address(0));
        require(_ivWalletAddress != address(0));
        require(_dvWalletAddress != address(0));
        require(_adWalletAddress != address(0));
        require(_mlWalletAddress != address(0));
        require(_bcWalletAddress != address(0));
        require(_ml1WalletAddress != address(0));
        require(_ml2WalletAddress != address(0));
        require(_ml3WalletAddress != address(0));

        usdtToken = _usdtTokenAddress;
        settlementWallet = _settlementWalletAddress;
        ivWallet = _ivWalletAddress;
        dvWallet = _dvWalletAddress;
        adWallet = _adWalletAddress;
        mlWallet = _mlWalletAddress;
        bcWallet = _bcWalletAddress;
        ml1Wallet = _ml1WalletAddress;
        ml2Wallet = _ml2WalletAddress;
        ml3Wallet = _ml3WalletAddress;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function deposit(
        uint256 amount,
        address _ml1Wallet,
        address _ml2Wallet,
        address _ml3Wallet
    ) external {
        require(amount > 0);

        require(_ml1Wallet != address(0));
        require(_ml2Wallet != address(0));
        require(_ml3Wallet != address(0));

        uint256 totalPercentage = P_IV + P_DV + P_AD +
                                 P_ML + P_BC + P_ML1 +
                                 P_ML2 + P_ML3;
        require(totalPercentage == BASIS_POINTS);

        uint256 amtIv = (amount * P_IV) / BASIS_POINTS;
        uint256 amtDv = (amount * P_DV) / BASIS_POINTS;
        uint256 amtAd = (amount * P_AD) / BASIS_POINTS;
        uint256 amtMl = (amount * P_ML) / BASIS_POINTS;
        uint256 amtBc = (amount * P_BC) / BASIS_POINTS;
        uint256 amtMl1 = (amount * P_ML1) / BASIS_POINTS;
        uint256 amtMl2 = (amount * P_ML2) / BASIS_POINTS;
        uint256 amtMl3 = (amount * P_ML3) / BASIS_POINTS;

        emit FundSplitCalculated(
            msg.sender,
            amount,
            amtIv,
            amtDv,
            amtAd,
            amtMl,
            amtBc,
            amtMl1,
            amtMl2,
            amtMl3,
            0
        );

        IERC20(usdtToken).safeTransferFrom(msg.sender, ivWallet, amtIv);
        IERC20(usdtToken).safeTransferFrom(msg.sender, dvWallet, amtDv);
        IERC20(usdtToken).safeTransferFrom(msg.sender, adWallet, amtAd);
        IERC20(usdtToken).safeTransferFrom(msg.sender, mlWallet, amtMl);
        IERC20(usdtToken).safeTransferFrom(msg.sender, bcWallet, amtBc);
        IERC20(usdtToken).safeTransferFrom(msg.sender, _ml1Wallet, amtMl1);
        IERC20(usdtToken).safeTransferFrom(msg.sender, _ml2Wallet, amtMl2);
        IERC20(usdtToken).safeTransferFrom(msg.sender, _ml3Wallet, amtMl3);

        _mint(msg.sender, amount);

        lastDepositTime[msg.sender] = block.timestamp;

        emit Deposited(msg.sender, amount, block.timestamp, _ml1Wallet, _ml2Wallet, _ml3Wallet);
    }

    function calculatePenalty(address holder, uint256 amount)
        public
        view
        returns (uint256 penaltyAmount, uint256 payoutAmount)
    {
        require(holder != address(0));
        require(amount > 0);
        require(lastDepositTime[holder] > 0);

        uint256 elapsedTime = block.timestamp - lastDepositTime[holder];

        if (elapsedTime < ONE_YEAR_IN_SECONDS) {
            penaltyAmount = (amount * 5000) / BASIS_POINTS;
        } else if (elapsedTime < FIVE_YEARS_IN_SECONDS) {
            uint256 timeInRange = elapsedTime - ONE_YEAR_IN_SECONDS;
            uint256 totalTimeRange = FIVE_YEARS_IN_SECONDS - ONE_YEAR_IN_SECONDS;

            uint256 penaltyBasisPoints = 5000 - (timeInRange * 5000) / totalTimeRange;

            penaltyAmount = (amount * penaltyBasisPoints) / BASIS_POINTS;
        } else {
            penaltyAmount = 0;
        }

        payoutAmount = amount - penaltyAmount;

        return (penaltyAmount, payoutAmount);
    }

    function updateCoreWallets(
        address _settlementWallet,
        address _ivWallet,
        address _dvWallet,
        address _adWallet,
        address _mlWallet,
        address _bcWallet
    ) external onlyOwner {
        require(_settlementWallet != address(0), "Invalid settlement wallet address");
        require(_ivWallet != address(0), "Invalid IV wallet address");
        require(_dvWallet != address(0), "Invalid DV wallet address");
        require(_adWallet != address(0), "Invalid AD wallet address");
        require(_mlWallet != address(0), "Invalid ML wallet address");
        require(_bcWallet != address(0), "Invalid BC wallet address");

        settlementWallet = _settlementWallet;
        ivWallet = _ivWallet;
        dvWallet = _dvWallet;
        adWallet = _adWallet;
        mlWallet = _mlWallet;
        bcWallet = _bcWallet;

        emit CoreWalletsUpdated(
            msg.sender,
            _settlementWallet,
            _ivWallet,
            _dvWallet,
            _adWallet,
            _mlWallet,
            _bcWallet
        );
    }

    function updateMLMWallets(
        address _ml1Wallet,
        address _ml2Wallet,
        address _ml3Wallet
    ) external onlyOwner {
        require(_ml1Wallet != address(0));
        require(_ml2Wallet != address(0));
        require(_ml3Wallet != address(0));

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

    function getFundSplitWallets()
        external
        view
        returns (
            address iv,
            address dv,
            address ad,
            address ml,
            address bc,
            address ml1,
            address ml2,
            address ml3
        )
    {
        return (
            ivWallet,
            dvWallet,
            adWallet,
            mlWallet,
            bcWallet,
            ml1Wallet,
            ml2Wallet,
            ml3Wallet
        );
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._update(from, to, amount);

        if (from == address(0)) {
            lastDepositTime[to] = block.timestamp;
            emit TimestampUpdated(to, block.timestamp);
        }
        else if (to == address(0)) {
        }
        else {
            if (lastDepositTime[from] > 0) {
                lastDepositTime[to] = lastDepositTime[from];
            } else {
                lastDepositTime[to] = block.timestamp;
            }
            emit TimestampUpdated(to, lastDepositTime[to]);
        }
    }

    function redeem(uint256 amount) external {
        require(amount > 0);

        require(balanceOf(msg.sender) >= amount);

        (uint256 penaltyAmount, uint256 payoutAmount) = calculatePenalty(msg.sender, amount);

        _burn(msg.sender, amount);

        IERC20(usdtToken).safeTransferFrom(settlementWallet, msg.sender, payoutAmount);

        emit Redeemed(msg.sender, amount, payoutAmount, penaltyAmount);
    }
}
