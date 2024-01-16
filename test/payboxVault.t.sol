// SPDX-License-Ideentifier: MIT

pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";

import {paybox} from "../src/paybox.sol";
import {payboxDashboard} from "../src/payboxDashboard.sol";
import {testToken} from "./mock/testToken.sol";
import "forge-std/console.sol";

contract payboxVault is Test {
    paybox factory;
    address gho = 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951;
    address usdtToken = 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0;
    address staff = 0x8DCeC3aF87Efc4B258f2BCAEB116D36B9ca012ee;
    address owner = 0x8e4AFA7AF752407783BcFCEB465D456E4179e79A;


    function setUp() public {
        uint mainnet = vm.createFork(
            "https://eth-sepolia.g.alchemy.com/v2/iAUaLtsNebgVs4nr_5VAOrrVmui6EZWB",
            5094026
        );
        vm.selectFork(mainnet);
        factory = new paybox(gho);
    }

    function CreateAccount() public {
        factory.createAccount(
            usdtToken,
            "vincNft",
            "vNt",
            "abvsgfsf",
            "vince",
            "avbss",
            "ad@gmail.com",
            paybox.Interval(0)
        );
    }

    function testCreateAcct() public {
        vm.prank(owner);
        CreateAccount();
    }

    function addStaff() public{
                address[] memory addresses = new address[](1);
        addresses[0] = staff;


        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1000;


        string[] memory names = new string[](1);
        names[0] = "John";


        string[] memory positions = new string[](3);


        string[] memory emails = new string[](1);
        emails[0] = "john@example.com";

   vm.startPrank(owner);
        CreateAccount();
        
        address myPayBox = factory.showMyAcct(owner);
        console.log(myPayBox);

        payboxDashboard myPAcct = payboxDashboard(myPayBox);

        myPAcct.addStaff(addresses, amounts, names, positions, emails);
        vm.stopPrank();

        
    }
    function testAddStaff() public{

        addStaff();
    }
    function testbuyShares() public{
        addStaff();
        address paybox2 = factory.showMyAcct(owner);
        payboxDashboard myPAcct = payboxDashboard(paybox2);
        uint256 amount = 2 * 1e6;
        vm.startPrank(staff);
        testToken(usdtToken).approve(paybox2, amount);
        myPAcct.buyShares(staff,amount , usdtToken);
        vm.stopPrank();
    }
} 
