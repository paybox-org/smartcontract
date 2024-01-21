//SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC4626.sol";
import "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "./IAave.sol";
import "./IBalance.sol";
import "./chainlinkOracle.sol";

contract payboxDashboard is ERC721, ERC721URIStorage, chainlinkOracle {
    /* ========== STATE VARIABLES  ========== */
    IERC20 public token;
    IERC20 public gho_contract;
    IAave public aave_contract;
    mapping(address => uint256) Salary;
    mapping(address => uint256) staffLength;
    mapping(address => uint256) dateAdded;
    mapping(address => bool) attendanceMarked;
    mapping(address => bool) staffExist;
    mapping(address => uint256) staffShares;
    mapping(address => uint256) staffLoan;
    mapping(address => bool) borrowActive;

    struct Profile {
        address myAddress;
        string myName;
        string position;
        uint256 salary;
        string email;
        bool shareAcquisition;
        uint sharesPercent;
        uint sharesBalance;
    }
    mapping(address => Profile) profile;

    //company total shares
    uint public totalShares;

    bool dailyAttendance;
    mapping(address => uint256) attendanceCounter;

    uint256 lastResetTimestamp;

    uint256 attendanceResetInterval = 1 hours;
    uint256 tokenId = 0;

    address[] allStaffs;
    string URI;
    string companyName;
    string companyLogo;
    string email;
    uint256 lastPayOut;
    uint256 TotalPayOut;
    // uint256 totalInvestment;
    address owner;

    /* ========== Event ========== */
    event staffRemove(address _contract, string indexed name);
    event AmountPaidout(
        address _contract,
        uint256 indexed amount,
        uint256 indexed timePaid
    );
    event bestStaff(
        address _contract,
        string indexed name,
        address indexed bestStaff,
        uint256 indexed nftId
    );
    event tokenDeposit(
        address _contract,
        uint256 indexed _amount,
        uint256 time
    );
    event borrowGHO(uint256 indexed amount, address onBehalfOf);
    event withdrawToken(
        address _contract,
        uint256 indexed _amount,
        address indexed receiver,
        uint256 indexed time
    );
    event AllAttendance(
        address _contract,
        address indexed _staff,
        string name,
        string position,
        string email,
        uint256 indexed _time
    );

    /* ========== INITIALIZER ========== */
    constructor(
        address _tokenAddress,
        string memory _nftName,
        string memory _nftSymbol,
        string memory uri,
        string memory _companyName,
        string memory _companyLogo,
        string memory _email,
        address _owner,
        address _aave_contract
    ) ERC721(_nftName, _nftSymbol) {
        token = IERC20(_tokenAddress);
        URI = uri;
        companyName = _companyName;
        companyLogo = _companyLogo;
        email = _email;
        lastResetTimestamp = 0;
        owner = _owner;
        aave_contract = IAave(_aave_contract);
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }
    modifier _onlyStaff() {
        require(staffExist[msg.sender] == true, "NOT_STAFF");
        _;
    }

    /* ========== PRIVATE FUNCTIONS ========== */
    // The following functions are overrides required by Solidity.
    function safeMint(
        address to,
        string memory uri,
        uint256 _tokenId
    ) internal {
        _safeMint(to, _tokenId);
        _setTokenURI(_tokenId, uri);
    }

    /**
     * @dev check the best staff of the month
     */
    function checkHighestAttendance() internal view returns (address) {
        uint highestAttendance = 0;
        address bestEmployee = address(0);
        for (uint i = 0; i < allStaffs.length; i++) {
            address participant = allStaffs[i];
            if (attendanceCounter[participant] > highestAttendance) {
                highestAttendance = attendanceCounter[participant];
                bestEmployee = participant;
            }
        }
        return bestEmployee;
    }

    /**
     * @dev return amount to pay all staffs
     */
    function totalPayment() public view returns (uint256) {
        uint totalAmount = 0;
        for (uint i = 0; i < allStaffs.length; i++) {
            address to = allStaffs[i];
            uint amount = Salary[to];
            require(amount > 0, "AMOUNT_IS_ZERO");
            totalAmount += amount;
        }

        return totalAmount;
    }

    /* ========== VIEWS ========== */
    function salaryPaidout() external view returns (uint256, uint256) {
        return (lastPayOut, TotalPayOut);
    }

    /**
     * @dev returns all registered staff
     */
    function allMembers() external view returns (Profile[] memory) {
        Profile[] memory allProfiles = new Profile[](allStaffs.length);

        for (uint256 i = 0; i < allStaffs.length; i++) {
            allProfiles[i] = profile[allStaffs[i]];
        }
        return allProfiles;
    }

    /**
     * @dev return companyDetails
     */
    function companyDetails()
        external
        view
        returns (string memory, string memory, string memory)
    {
        return (companyName, companyLogo, email);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(_tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev  companys add their staffs batch adding and single adding
     */

    function addStaff(
        address[] memory _staffAdresses,
        uint256[] memory _amount,
        string[] memory _name,
        string[] memory _position,
        string[] memory _email
    ) external _onlyOwner returns (bool) {
        require(
            _staffAdresses.length == _amount.length,
            "LENGTH_DOES_NOT_MATCH"
        );
        for (uint i = 0; i < _staffAdresses.length; i++) {
            Profile storage user = profile[_staffAdresses[i]];
            user.myAddress = _staffAdresses[i];
            user.myName = _name[i];
            user.position = _position[i];
            user.salary = _amount[i];
            user.email = _email[i];
            allStaffs.push(_staffAdresses[i]);
            staffLength[_staffAdresses[i]] = allStaffs.length - 1;
            Salary[_staffAdresses[i]] = _amount[i];
            dateAdded[_staffAdresses[i]] = block.timestamp;
            staffExist[_staffAdresses[i]] = true;
        }
        return true;
    }

    /**
     * @dev delete a particular staff data
     */
    //companies remove staff
    function removeStaff(address _staff) external _onlyOwner returns (bool) {
        require(staffLength[_staff] < allStaffs.length, "user not found");
        uint indexToRemove = staffLength[_staff];
        uint lastIndex = allStaffs.length - 1;

        //exchanging the address to remove with last address in the array
        allStaffs[indexToRemove] = allStaffs[lastIndex];
        staffLength[allStaffs[lastIndex]] = indexToRemove;

        //remove the last elemnet from the array
        allStaffs.pop();
        delete staffLength[_staff];
        delete Salary[_staff];
        // profile[_staff] = Profile(address(0), "", "", 0, "");
        emit staffRemove(address(this), profile[_staff].myName);

        return true;
    }

    /**
     * You must be a staff to buy shares
     */
    function buyShares(
        address _staff,
        uint _amount,
        address _asset
    ) public _onlyStaff {
        if (token.balanceOf(_staff) < _amount) {
            revert("Insufficient funds");
        }

        Profile storage user = profile[_staff];
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */

        uint totalInvestment = IERC20(
            0x29598b72eb5CeBd806C5dCD549490FdA35B13cD8
        ).balanceOf(address(this));

        uint shares;
        if (totalShares == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalShares) / totalInvestment;
        }
        // send the amount to aave contract
        IERC20(_asset).transferFrom(_staff, address(this), _amount);
        IERC20(_asset).approve(address(aave_contract), _amount);
        aave_contract.supply(_asset, _amount, msg.sender, 0);
        staffShares[_staff] += shares;
        totalShares += shares;
    }

    /**
     * Rules Governing shares removal
     * Lock time
     */
    function withdrawShares(
        address _staff,
        address _asset
    ) external returns (uint256) {
        // Profile storage user = profile[_staff];

        // if(user.sharesBalance < _shares){
        // revert("Insufficient shares");
        // }

        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn

        (T - s) / T = (B - a) / B 

        a = sB / T
        */
        address[] memory tokenAsset = new address[](1);
        tokenAsset[0] = address(token);
        address reward = 0x29598b72eb5CeBd806C5dCD549490FdA35B13cD8;

        uint shares = staffShares[_staff];

        uint contractInvestment = IERC20(
            0x29598b72eb5CeBd806C5dCD549490FdA35B13cD8
        ).balanceOf(address(this));

        uint amount = (shares * contractInvestment) / totalShares;

        // uint256 b = amount + amount2;
        uint256 with = aave_contract.withdraw(_asset, amount, _staff);
        staffShares[_staff] = 0;
        totalShares -= shares;
        return contractInvestment;
    }

    /**
     * @dev to borrow gho token
     * @dev only staff with shares can borrow
     */

    function borrowGHOTokens(
        address _staff,
        uint desiredAmount
    ) external returns (uint) {
        if (staffShares[_staff] == 0) {
            revert("You don't have shares");
        }

        //calculate 20%
        uint allowedTokens = ((staffShares[_staff] / 100) * 20);

        if (desiredAmount > allowedTokens) {
            revert("Exceeded amount available for borrowing");
        }

        aave_contract.borrow(
            0xc4bF5CbDaBE595361438F8c6a187bDc330539c60,
            desiredAmount,
            2,
            0,
            msg.sender
        );

        staffLoan[_staff] += desiredAmount;
        IERC20(0xc4bF5CbDaBE595361438F8c6a187bDc330539c60).transfer(
            _staff,
            desiredAmount
        );
        borrowActive[_staff] = true;

        emit borrowGHO(desiredAmount, _staff);
    }

    function previewEstimatedLoan(address _staff) external view returns (uint) {
        if (staffShares[_staff] == 0) {
            revert("You don't have shares");
        }

        //calculate 20%
        uint allowedTokens = ((staffShares[_staff] / 100) * 20);

        return allowedTokens;
    }
/**
*@dev Amount to payback
 */

 function ghoPayback(address _staff) public view returns(uint256){
    (
            ,
            uint256 totalDebtETH,
            ,
            uint256 currentLiquidationThreshold,
            ,

        ) = aave_contract.getUserAccountData(address(this));

        //staff loan out of the debt owned to aave
        uint repayableBal = staffLoan[_staff];
        int usd = getChainlinkDataFeedLatestAnswer();
        uint256 usdPrice = uint256(usd);

        // uint256 stablePrice =( totalDebtETH * usdPrice)/1e8;
        uint256 _totalToPayBack = (repayableBal / totalDebtETH) * totalDebtETH;
        return _totalToPayBack;
 }

 /** 
 *@dev payback loan
  */
    function paybackLoan(address _staff) external {
    uint repayAmount = ghoPayback(_staff);
        IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357).transferFrom(_staff, address(this), repayAmount);
        IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357).approve(0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951, repayAmount);
        payGhoOwe( repayAmount);
        borrowActive[_staff] = false;
        staffLoan[_staff] = 0;
    }

    /**
    
     */
     function payGhoOwe( uint256 _repayAmount) internal {
            aave_contract.repayWithATokens(
            0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357,
            _repayAmount,
            2,
            address(this)
        );
     }

    // function setSharePercentage(address _staff, uint _percent) external {
    //     Profile storage user = profile[_staff];
    //     if(_percent < 10){
    //         revert("Shares acquisition percent must be greater than 10");
    //     }
    //     if(user.shareAquisition == false){
    //         revert("Shares acquisition status is Inactive");
    //     }
    //     user.sharesPercent = _percent;
    // }

    /**
     * @dev Batch token transfer func
     * @return true if successful, false otherwise.
     */
    function salaryPayment() external _onlyOwner returns (bool) {
        uint totalAmount = totalPayment();
        address bestEmployee = checkHighestAttendance();
        uint payloan;
        require(
            token.balanceOf(address(this)) >= totalAmount,
            "Insufficient balance"
        );
        for (uint i = 0; i < allStaffs.length; i++) {
            address to = allStaffs[i];
            uint amount = Salary[to];
            require(amount > 0, "AMOUNT_IS_ZERO");
            if(borrowActive[allStaffs[i]] == true){
uint userLoan = ghoPayback(allStaffs[i]);
payloan += userLoan;
uint _balance = amount - userLoan;
            token.transfer(to, _balance);
            borrowActive[allStaffs[i]] = false;
            staffLoan[allStaffs[i]] = 0;
            }else{
            token.transfer(to, amount);

            }

        }

        uint256 _tokenId = tokenId + 1;
        safeMint(bestEmployee, URI, _tokenId);
        tokenId = _tokenId;
        lastPayOut = totalAmount;
        TotalPayOut += totalAmount;
        if (payloan == 0){

        emit bestStaff(
            address(this),
            profile[bestEmployee].myName,
            bestEmployee,
            _tokenId
        );
        emit AmountPaidout(address(this), totalAmount, block.timestamp);
        return true;
        }
        else{
payGhoOwe(payloan);
        emit bestStaff(
            address(this),
            profile[bestEmployee].myName,
            bestEmployee,
            _tokenId
        );
        emit AmountPaidout(address(this), totalAmount, block.timestamp);
        return true;
        }
    }

    /**
     * @dev only Admin can call function
     * @param _amount the amount of GHO token you want to deposit
     */
    function depositFund(uint256 _amount) external returns (bool) {
        require(
            gho_contract.balanceOf(msg.sender) >= _amount,
            "Insufficient balance"
        );
        gho_contract.transferFrom(msg.sender, address(this), _amount);
        emit tokenDeposit(address(this), _amount, block.timestamp);
        return true;
    }

    function withdrawFund(
        address to,
        uint256 _amount
    ) external _onlyOwner returns (bool) {
        require(
            gho_contract.balanceOf(address(this)) >= _amount,
            "INSUFFICIENT_AMOUNT"
        );
        gho_contract.transfer(to, _amount);

        emit withdrawToken(address(this), _amount, to, block.timestamp);
        return true;
    }

    /**
     *@dev instantiate a new attendance for the day
     */
    function openAttendance() external _onlyOwner returns (bool) {
        require(
            block.timestamp - lastResetTimestamp >= attendanceResetInterval,
            "NOT_A_NEW_DAY"
        );

        dailyAttendance = false;
        lastResetTimestamp = block.timestamp;
        for (uint i = 0; i < allStaffs.length; i++) {
            address participant = allStaffs[i];
            attendanceMarked[participant] = false;
        }
        return true;
    }

    //user

    function markAttendance() external returns (bool) {
        require(attendanceMarked[msg.sender] == false, "Attendance marked");
        if (dailyAttendance == false) {
            dailyAttendance = true;
            attendanceCounter[msg.sender] += 1;
            attendanceMarked[msg.sender] = true;
        } else {
            attendanceMarked[msg.sender] = true;
        }
        Profile storage user = profile[msg.sender];
        emit AllAttendance(
            address(this),
            msg.sender,
            user.myName,
            user.email,
            user.position,
            block.timestamp
        );
        return true;
    }
}
