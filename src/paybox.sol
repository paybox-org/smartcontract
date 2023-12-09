// SPDX-License_Identifier: MIT

pragma solidity ^0.8.21;
import "./payboxDashboard.sol";

contract paybox {
    mapping(address => address) myAccount;
    mapping(address => bool) userExist;
    struct AddressPayment {
        address myAccout;
        uint256 FutureTime;
        Interval interval;
    }
    enum Interval {
        daily,
        Biweekly,
        monthly
    }
    AddressPayment[] private arrayAddress;

    //Event
    event AccountCreated(address indexed caller, address indexed _child);

    /**
     * @dev create an instance of paybox dashoard for the user
     */

    // companys create account :factory contract
    function createAccount(
        address _tokenAddress,
        string memory _nftName,
        string memory _nftSymbol,
        string memory _Nfturi,
        string memory _companyName,
        string memory _companyLogo,
        string memory _email,
        Interval _interval
    ) external returns (address) {
        address _caller = msg.sender;
        require(!userExist[_caller], "user account created");
        payboxDashboard myAcct = new payboxDashboard(
            _tokenAddress,
            _nftName,
            _nftSymbol,
            _Nfturi,
            _companyName,
            _companyLogo,
            _email,
            msg.sender
        );
        address _accountCreated = address(myAcct);
        myAccount[_caller] = address(myAcct);
        uint256 _schedulePayment;
        if (_interval == Interval.daily) {
            _schedulePayment = block.timestamp + 1 hours;
        } else if (_interval == Interval.Biweekly) {
            _schedulePayment = block.timestamp + 14 days;
        } else {
            _schedulePayment = block.timestamp + 30 days;
        }
        arrayAddress.push(
            AddressPayment(_accountCreated, _schedulePayment, _interval)
        );
        emit AccountCreated(_caller, address(myAcct));
        return _accountCreated;
    }

    function showMyAcct(address _owner) external view returns (address) {
        return myAccount[_owner];
    }

    function payStaff() external {
        for (uint i = 0; i < arrayAddress.length; ++i) {
            AddressPayment memory details = arrayAddress[i];
            if (details.FutureTime < block.timestamp) {
                return;
            } else {
                if (details.interval == Interval.daily) {
                    details.FutureTime = block.timestamp + 1 hours;
                } else if (details.interval == Interval.Biweekly) {
                    details.FutureTime = block.timestamp + 14 days;
                } else {
                    details.FutureTime = block.timestamp + 30 days;
                }
                payboxDashboard(details.myAccout).salaryPayment();
            }
        }
    }
}
