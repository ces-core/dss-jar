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
import {Jar} from "./Jar.sol";
import {JarFactory} from "./JarFactory.sol";

address constant MCD_JOIN_DAI = 0x157c794cE5dAd9F0C42870eaD45Cd9B072A08527;

contract JarFactoryTest is Test {
  JarFactory internal factory;

  event JarCreated(bytes32 indexed ilk, Jar indexed jar);

  function setUp() public {
    factory = new JarFactory();
  }

  function testCreateJarAddress() public {
    bytes32 ilk = "RWAX-A";
    address daiJoin = MCD_JOIN_DAI;
    address vow = 0x0000000000000000000000000000000000000001;

    Jar created = factory.createJar(ilk, daiJoin, vow);

    assertEq(factory.count(), 1);
    assertEq(address(factory.jars(0)), address(created));
    assertEq(address(factory.ilkToJar(ilk)), address(created));
    assertEq(factory.jarToIlk(created), ilk);
  }

  function testCreateJarAddressEvents() public {
    bytes32 ilk = "RWAX-A";
    address daiJoin = MCD_JOIN_DAI;
    address vow = 0x0000000000000000000000000000000000000001;

    // This is specific to how Foundry expectEmit woks:
    // We need to emit the event we want to check BEFORE making the call, however the Jar address will only be known AFTER we call it.
    // It would be cumbersome to derive the address being generated, so we don't bother checking it.
    vm.expectEmit(true, false, false, false, address(factory));
    emit JarCreated(ilk, Jar(address(0)));

    factory.createJar(ilk, daiJoin, vow);
  }

  function testRevertOnDuplicateIlk() public {
    bytes32 ilk = "RWAX-A";
    address daiJoin = MCD_JOIN_DAI;
    address vow = 0x0000000000000000000000000000000000000001;

    factory.createJar(ilk, daiJoin, vow);

    vm.expectRevert(abi.encodeWithSelector(JarFactory.JarAlreadyExists.selector, ilk));
    factory.createJar(ilk, daiJoin, vow);
  }
}
