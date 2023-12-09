// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;
import "./payboxDashboard.sol";

contract paybox {
    mapping(address => address) myAccount;
    mapping(address => bool) userExist;

    //Event
    event AccountCreated(address indexed caller, address indexed _factory);

    /**
    * @dev create company account: factory child contract
    * @notice an instance of paybox dashoard for the user
    * @param _tokenAddress of ERC721, _nftSymbol, URI, _nftname of the ERC721
    * @param _companyName, logo and email address in strings
    * @return bool
    */
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
            _email,
            msg.sender
        );
        myAccount[_caller] = address(myAcct);
       emit AccountCreated(_caller, address(myAcct));
        return true;
    }

    /**
     * @dev mapping of owner address to account created
     * @param _owner address of account creator
     * @return address of company account created
     */
    function showMyAcct(address _owner) external view returns (address) {
        return myAccount[_owner];
    }
}
