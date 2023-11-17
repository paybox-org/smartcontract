// SPDX-License-Identifier: MIT

pragma solidity ^0.8.21;

import {Test} from 'forge-std/Test.sol';
import {paybox} from '../src/paybox.sol';
import {payboxDashboard} from '../src/payboxDashboard.sol';


contract PayboxTest is Test{

        function setUp() public{
                paybox = new paybox();
        }

}