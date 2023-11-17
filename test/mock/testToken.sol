// SPDX-License_Identifier: MIT

pragma solidity ^0.8.21;
import 'openzeppelin-contracts/contracts/token/ERC20/ERC20.sol'
contract testToken is Erc20{
constructor()ERC20('TestToken','TTT'){
        _mint(msg.sender, 1000*10**16);
}
}