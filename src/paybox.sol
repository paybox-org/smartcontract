// SPDX-License_Identifier: MIT

pragma solidity ^0.8.21;
import "./payboxDashboard.sol";

contract paybox {
    mapping(address => address) myAccount;
    mapping(address => bool) userExist;

    //Event
    event AccountCreated(address indexed caller, address indexed _factory);

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
        string memory _email
    ) external returns (bool) {
        address _caller = msg.sender;
        require(!userExist[_caller], "user account created");
        payboxDashboard myAcct = new payboxDashboard(
            _tokenAddress,
            _nftName,
            _nftSymbol,
            _Nfturi,
            _companyName,
            _companyLogo, 
            _email
        );
        myAccount[_caller] = address(myAcct);
       emit AccountCreated(_caller, address(myAcct));
        return true;
    }

    function showMyAcct(address _owner) external view returns (address) {
        return myAccount[_owner];
    }
}
