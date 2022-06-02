// Copyright (C) 2020, 2021 Lev Livnev <lev@liv.nev.org.uk>
// Copyright (C) 2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import "forge-std/Test.sol";
import {VowJoin} from "./VowJoin.sol";
import {VowJoinFactory} from "./VowJoinFactory.sol";

address constant MCD_JOIN_DAI = 0x157c794cE5dAd9F0C42870eaD45Cd9B072A08527;

contract VowJoinFactoryTest is Test {
    VowJoinFactory internal factory;

    event VowJoinCreated(bytes32 indexed ilk, VowJoin indexed vowJoin);

    function setUp() public {
        factory = new VowJoinFactory();
    }

    function testCreateVowJoinAddress() public {
        bytes32 ilk = "RWAX-A";
        address daiJoin = MCD_JOIN_DAI;
        address vow = 0x0000000000000000000000000000000000000001;
        VowJoin created = factory.createVowJoinAddress(ilk, daiJoin, vow);
        // vm.expectEmit(true, true, false, false, address(factory));
        // emit VowJoinCreated(ilk, created);
        assertEq(factory.count(), 1);
        assertEq(factory.vowJoins(0), address(created));
        assertEq(factory.ilkToVowJoin(ilk), address(created));
        assertEq(factory.vowJoinToIlk(address(created)), ilk);
    }
}



