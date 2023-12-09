//SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract payboxDashboard is ERC721, ERC721URIStorage {
    /* ========== STATE VARIABLES  ========== */
    IERC20 public token;

    mapping(address => uint256) Salary;
    mapping(address => uint256) staffLength;
    mapping(address => uint256) dateAdded;
    mapping(address => bool) attendanceMarked;

    struct Profile {
        address myAddress;
        string myName;
        string position;
        uint256 salary;
        string email;
    }
    mapping(address => Profile) profile;

    bool dailyAttendance;
    mapping(address => uint256) attendanceCounter;

    uint256 lastResetTimestamp;

    uint256 attendanceResetInterval = 1 days;
    uint256 tokenId = 0;

    address[] allStaffs;
    string URI;
    string companyName;
    string companyLogo;
    string email;
    uint256 lastPayOut;
    uint256 TotalPayOut;
    address owner;

    /* ========== Event ========== */
    event staffRemove(string indexed name);
    event AmountPaidout(uint256 indexed amount, uint256 indexed timePaid);
    event bestStaff(
        string indexed name,
        address indexed bestStaff,
        uint256 indexed nftId
    );
    event tokenDeposit(uint256 indexed _amount, uint256 time);
    event withdrawToken(
        uint256 indexed _amount,
        address indexed receiver,
        uint256 indexed time
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
        address _owner
    ) ERC721(_nftName, _nftSymbol) {
        token = IERC20(_tokenAddress);
        URI = uri;
        companyName = _companyName;
        companyLogo = _companyLogo;
        email = _email;
        lastResetTimestamp = 0;
        owner = _owner;
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
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
     * @dev Internal func 
     * @return address of highest attendance
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
     * @dev internal func
     * @return total token uint to be paid out
     * 
     */
    function totalPayment() internal view returns (uint256) {
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
    /**
     * @dev Frontend require
     * @return uint paid last, total uint paid out
     */
    function salaryPaidout() external view returns (uint256, uint256) {
        return (lastPayOut, TotalPayOut);
    }

    /**
     * @dev returns array of struct Profile 
     * @return all registered staffs
     */
    function allMembers() external view returns (Profile[] memory) {
        Profile[] memory allProfiles = new Profile[](allStaffs.length);

        for (uint256 i = 0; i < allStaffs.length; i++) {
            allProfiles[i] = profile[allStaffs[i]];
        }
        return allProfiles;
    }

    /**
     * @dev return strings
     * @return company info in strings
     */
    function companyDetails()
        external
        view
        returns (string memory, string memory, string memory)
    {
        return (companyName, companyLogo, email);
    }

    /**
     * @dev ERC721 tokenURI func
     * @param _tokenId  ERC721 Token ID
     * 
     */
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
     * @dev  add struct Profile in Single && Batch
     * @param _staffAddresses address(s) of staff(s)
     * @param _amount salary in uint
     * @param _name string of staff(s)
     * @param _position level of staff(s)
     * @param _email of staff(s)
     * @return true if staff(s) added
     */

    function addStaff(
        address[] memory _staffAddresses,
        uint256[] memory _amount,
        string[] memory _name,
        string[] memory _position,
        string[] memory _email
    ) external _onlyOwner returns (bool) {
        require(
            _staffAddresses.length == _amount.length,
            "LENGTH_DOES_NOT_MATCH"
        );
        for (uint i = 0; i < _staffAddresses.length; i++) {
            Profile storage user = profile[_staffAddresses[i]];
            user.myAddress = _staffAddresses[i];
            user.myName = _name[i];
            user.position = _position[i];
            user.salary = _amount[i];
            user.email = _email[i];
            allStaffs.push(_staffAddresses[i]);
            staffLength[_staffAddresses[i]] = allStaffs.length - 1;
            Salary[_staffAddresses[i]] = _amount[i];
            dateAdded[_staffAddresses[i]] = block.timestamp;
        }
        return true;
    }

    /**
     * @dev delete a struct Profile // remove staff from company
     * @param _staff address of staff to be removed
     * @return bool 
     * 
     */
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
        profile[_staff] = Profile(address(0), "", "", 0, "");
        emit staffRemove(profile[_staff].myName);

        return true;
    }

    /**
     * @dev Batch token transfer func
     * @return true if successful, false otherwise.
     */
    function salaryPayment() external _onlyOwner returns (bool) {
        uint totalAmount = totalPayment();
        address bestEmployee = checkHighestAttendance();
        require(
            token.balanceOf(address(this)) >= totalAmount,
            "Insufficient balance"
        );
        for (uint i = 0; i < allStaffs.length; i++) {
            address to = allStaffs[i];
            uint amount = Salary[to];
            require(amount > 0, "AMOUNT_IS_ZERO");
            token.transfer(to, amount);
        }
        uint256 _tokenId = tokenId + 1;
        safeMint(bestEmployee, URI, _tokenId);
        tokenId = _tokenId;
        lastPayOut = totalAmount;
        TotalPayOut += totalAmount;
        emit bestStaff(profile[bestEmployee].myName, bestEmployee, _tokenId);
        emit AmountPaidout(totalAmount, block.timestamp);
        return true;
    }

    /**
     * @dev tokenDeposit func for salary pay. 
     * @param _amount  uint of token to be deposited
     */
    function depositFund(uint256 _amount) external returns (bool) {
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        token.transferFrom(msg.sender, address(this), _amount);
        emit tokenDeposit(_amount, block.timestamp);
        return true;
    }

    /**
     * @dev withdrawal func
     * @param to address to be deposited to
     * @param _amount  uint of token to be transferred
     */
    function withdrawFund(
        address to,
        uint256 _amount
    ) external _onlyOwner returns (bool) {
        require(
            token.balanceOf(address(this)) >= _amount,
            "INSUFFICIENT_AMOUNT"
        );
        token.transfer(to, _amount);

        emit withdrawToken(_amount, to, block.timestamp);
        return true;
    }

    /**
     * @dev instantiate a new attendance for the day.
     * @return a boolean
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

    
    /**
     * @dev mark attendance called by staff(s)
     * @return bool
     */
    function markAttendance() external returns (bool) {
        require(attendanceMarked[msg.sender] == false, "Attendance marked");
        if (dailyAttendance == false) {
            dailyAttendance = true;
            attendanceCounter[msg.sender] += 1;
            attendanceMarked[msg.sender] = true;
        } else {
            attendanceMarked[msg.sender] = true;
        }
        return true;
    }
}
