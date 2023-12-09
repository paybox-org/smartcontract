// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {paybox} from "../src/paybox.sol";
import {payboxDashboard} from "../src/payboxDashboard.sol";
import {testToken} from "./mock/testToken.sol";
import "forge-std/console.sol";

interface CheatCodes {
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
}

contract PayboxTest is Test {
    testToken token;
    paybox factory;

    address public owner;
    address public addr1;
    address public addr2;
    address public addr3;
    address public addr4;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

    function setUp() public {
        addr1 = cheats.addr(1);
        vm.startPrank(addr1);
        token = new testToken();
        vm.stopPrank();

        factory = new paybox();
        addr2 = cheats.addr(2);
        addr3 = cheats.addr(3);
        addr4 = cheats.addr(4);
    }

    function CreateAccount() public {
        factory.createAccount(
            address(token),
            "vinceCompany",
            "VCT",
            "123qwqead",
            "VincedCompany",
            "123456788",
            "abc@gmail.com"
        );
    }

    function ShowAcct() public {
        address[] memory addresses = new address[](3);
        addresses[0] = addr2;
        addresses[1] = addr3;
        addresses[2] = addr4;

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1000;
        amounts[1] = 1500;
        amounts[2] = 1200;

        string[] memory names = new string[](3);
        names[0] = "John";
        names[1] = "Alice";
        names[2] = "Bob";

        string[] memory positions = new string[](3);
        positions[0] = "Manager";
        positions[1] = "Developer";
        positions[2] = "Designer";

        string[] memory emails = new string[](3);
        emails[0] = "john@example.com";
        emails[1] = "alice@example.com";
        emails[2] = "bob@example.com";

        vm.startPrank(addr1);
        CreateAccount();
        address myPayBox = factory.showMyAcct(addr1);
        console.log(myPayBox);

        payboxDashboard myPAcct = payboxDashboard(myPayBox);
        myPAcct.addStaff(addresses, amounts, names, positions, emails);
        vm.stopPrank();
        
    }

    function testRemoveAcct() public {
        ShowAcct();
        address myPayBox = factory.showMyAcct(addr1);
        console.log(myPayBox);

        payboxDashboard myPAcct = payboxDashboard(myPayBox);
    vm.prank(addr1);
        myPAcct.removeStaff(addr2);
        token.balanceOf(addr1);
        vm.startPrank(addr1);
token.approve( address(myPAcct), 18000);
        myPAcct.depositFund(18000);

        myPAcct.withdrawFund(addr1, 10);
        vm.warp(1 days);
        myPAcct.openAttendance();
        vm.stopPrank();

        vm.prank(addr3);
        myPAcct.markAttendance();

        vm.warp(2 days);
        vm.prank(addr1);
        myPAcct.openAttendance();
        vm.prank(addr3);
        myPAcct.markAttendance();
        vm.prank(addr4);
        myPAcct.markAttendance();
        token.balanceOf(address(myPAcct));
        vm.prank(addr1);
        myPAcct.salaryPayment();

        vm.prank(addr1);
        factory.payStaff();
        // myPAcct.salaryPaidout();

        myPAcct.allMembers();
        myPAcct.companyDetails();
    }
}
