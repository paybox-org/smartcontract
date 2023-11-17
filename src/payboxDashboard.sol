//SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//companys add their staffs batch adding and single adding



//companys pay their staff batch payment

//companys deposit money to the contract

//comapanys withdraw money 

//we mint nft to best staff

//staff mark attendance

//role giving
//Add admin

contract payboxDashboard is ERC721, ERC721URIStorage {
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
    uint256 lastPayOut;
    uint256 TotalPayOut;

    // Event
    event staffRemove(string indexed name );
    event AmountPaidout(uint256 indexed amount, uint256 indexed timePaid);
    event bestStaff(string indexed name, address indexed bestStaff, uint256 indexed nftId);
    event tokenDeposit(uint256 indexed _amount, uint256 time);
    event withdrawToken(uint256 indexed _amount, address indexed receiver, uint256 indexed time);


    constructor(
        address _tokenAddress,
        string memory _nftName,
        string memory _nftSymbol,
        string memory uri,
        string memory   _companyName  ,
    string memory _companyLogo
    ) ERC721(_nftName, _nftSymbol) {
        token = IERC20(_tokenAddress);
        URI = uri;
       companyName = _companyName;
    companyLogo = _companyLogo;
    }

    //companys add their staffs batch adding and single adding
    function addStaff(
        address[] calldata _staffAdresses,
        uint256[] calldata _amount,
        string[] memory _name,
        string[] memory _position,
        string[] memory _email
    ) external returns (bool) {
        require(
            _staffAdresses.length == _amount.length,
            "input addresses and amount must be equal"
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
        }
        return true;
    }
    /**
    * @dev delete a particular staff data
     */
    //companies remove staff
    function removeStaff(address _staff) external returns (bool) {
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
        profile[_staff] = Profile(address(0), '', '', 0, '');
        emit staffRemove(profile[staff].myName);

        return true;
    }

    /**
    * @dev return amount to pay all staffs
     */
    function totalPayment() internal view returns (uint256) {
        uint totalAmount = 0;
        for (uint i = 0; i < allStaffs.length; i++) {
            address to = allStaffs[i];
            uint amount = Salary[to];
            require(amount > 0, "Amount must be greater than zero");
            totalAmount += amount;
        }
        emit AmountPaidout(totalAmount, block.timestamp);
        return totalAmount;
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

    function safeMint(
        address to,
        string memory uri,
        uint256 _tokenId
    ) internal {
        _safeMint(to, _tokenId);
        _setTokenURI(_tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

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

    //companys pay their staff batch payment
    //we have to check the date staff is been added
    function salaryPayment() external returns (bool) {
        uint totalAmount = totalPayment();
        address bestEmployee = checkHighestAttendance();
        require(token.balanceOf(address(this)) >= totalAmount);
        for (uint i = 0; i < allStaffs.length; i++) {
            address to = allStaffs[i];
            uint amount = Salary[to];
            require(amount > 0, "Amount must be greater than zero");
            token.transfer(to, amount);
        }
        uint256 _tokenId = tokenId + 1;
        safeMint(bestEmployee, URI, _tokenId);

        _mint(bestEmployee, _tokenId);
        tokenId = _tokenId;
        lastPayOut = totalAmount;
        TotalPayOut += totalAmount;
        emit bestStaff(profile[bestEmployee].myName, bestEmployee, _tokenId);
        return true;
    }

    function depositFund(uint256 _amount) external returns (bool) {
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        token.transfer(address(this), amount);
        emit tokenDeposit(_amount, block.timestamp);
        return true;
    }

    function withdrawFund(address to, uint256 _amount) external returns (bool) {
        require(
            token.balanceOf(address(this)) >= _amount,
            "Insufficient Amount"
        );
        token.transfer(to, _amount);
   
        emit withdrawToken(_amount, to, block.timestamp );
        return true;
    }

   /**
   *@dev instantiate a new attendance for the day
    */
    function openAttendance() external returns (bool) {
        require(
            block.timestamp - lastResetTimestamp >= attendanceResetInterval,
            "Not a new Day"
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

    function markAttendance() external {
        require(attendanceMarked[msg.sender] == false, "Attendance marked");
        if (dailyAttendance == false) {
            dailyAttendance = true;
            attendanceCounter[msg.sender] += 1;
            attendanceMarked[msg.sender] = true;
        } else {
            attendanceMarked[msg.sender] = true;
        }
    }

    function salaryPaidout() external view returns (uint256, uint256) {
        return (lastPayOut,TotalPayOut);
    }
    function allMembers() external view returns(Profile[] memory){
        Profile[] memory allProfiles = new Profile[](allStaffs.length);

        for(uint256 i = 0; i < allStaffs.length; i++ ){
            allProfiles[i] = profile[allStaffs[i]];
        }
        return allProfiles;

    }
}
