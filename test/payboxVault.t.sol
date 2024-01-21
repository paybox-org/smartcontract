// SPDX-License-Ideentifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import "../src/IERC20.sol";

import {paybox} from "../src/paybox.sol";
import {payboxDashboard} from "../src/payboxDashboard.sol";
import {testToken} from "./mock/testToken.sol";
import "forge-std/console.sol";

contract payboxVault is Test {
    paybox factory;
    address gho = 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951;
    address usdtToken = 0xaA8E23Fb1079EA71e0a56F48a2aA51851D8433D0;
    address daiToken = 0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357;
    address staff = 0x8DCeC3aF87Efc4B258f2BCAEB116D36B9ca012ee;
    address owner = 0x8e4AFA7AF752407783BcFCEB465D456E4179e79A;

    function setUp() public {
        uint mainnet = vm.createFork(
            "https://eth-sepolia.g.alchemy.com/v2/iAUaLtsNebgVs4nr_5VAOrrVmui6EZWB",
            5121668
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

    function addStaff() public {
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

    function testAddStaff() public {
        addStaff();
    }

    // function testbuyShares() public {
    //     addStaff();
    //     address paybox2 = factory.showMyAcct(owner);
    //     payboxDashboard myPAcct = payboxDashboard(paybox2);
    //     uint256 amount = 50000000;
    //     vm.startPrank(staff);
    //     testToken(daiToken).approve(paybox2, amount);
    //     myPAcct.buyShares(staff, amount, daiToken);

    //     vm.warp(block.timestamp + 50 weeks);
    //     uint bal = myPAcct.withdrawShares(staff, daiToken);
    //     console.log(bal);

    //     vm.stopPrank();
    // }

    function testborrowGHO() public {
        addStaff();
        address paybox2 = factory.showMyAcct(owner);
        payboxDashboard myPAcct = payboxDashboard(paybox2);
        uint256 amount = 12e18;
        vm.startPrank(staff);
        testToken(daiToken).approve(paybox2, amount);
         testToken(daiToken).approve(gho, amount);




        uint balBefore = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357)
            .balanceOf(staff);


        myPAcct.buyShares(staff, 5e7, daiToken);

        vm.warp(block.timestamp + 50 weeks);
        uint balAfter = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357)
            .balanceOf(staff);
           
           
        uint t = myPAcct.borrowGHOTokens(staff,0);
           
           myPAcct.paybackLoan(staff);
           

        // console.log(balBefore);
        // console.log(balBefore);
        uint bal = IERC20(0xc4bF5CbDaBE595361438F8c6a187bDc330539c60).balanceOf(
            staff
        );
        vm.stopPrank();
    }
}

// forge create --rpc-url https://eth-sepolia.g.alchemy.com/v2/iAUaLtsNebgVs4nr_5VAOrrVmui6EZWB \
//     --constructor-args 0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357 "JoNFT" "JFT" "euee" "joeCom" "Joee" "joe@gmail" 0x1b6e16403b06a51C42Ba339E356a64fE67348e92 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951 \
//     --private-key bd83404727a183edcc32ce0c9a7e07e004b179f65a14c8aca8f106e2cc73556a \
//     --etherscan-api-key 8VWGCW9PI2P8QT1CTTDQPA5Y44YMMSJGCA \
//     --verify \
//     src/payboxDashboard.sol:payboxDashboard
