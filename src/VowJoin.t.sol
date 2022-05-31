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
import {FakeVat} from "./fakes/FakeVat.sol";
import {FakeDai} from "./fakes/FakeDai.sol";
import {FakeDaiJoin} from "./fakes/FakeDaiJoin.sol";
import {VowJoin} from "./VowJoin.sol";

contract VowJoinTest is Test {
    using stdStorage for StdStorage;

    FakeVat internal vat;
    FakeDai internal dai;
    FakeDaiJoin internal daiJoin;
    VowJoin internal vowJoin;
    address internal constant VOW = address(0x1337);
    uint256 internal constant AMOUNT = 1e18;

    function setUp() public {
        vat = new FakeVat();
        dai = new FakeDai("Dai", "DAI", 18);
        daiJoin = new FakeDaiJoin(address(vat), address(dai));
        vowJoin = new VowJoin(address(daiJoin), VOW);

        _mintDai(address(this), AMOUNT);
    }

    function testTransfersAnyOutstandingDaiBalanceToTheVow() public {
        dai.transfer(address(vowJoin), AMOUNT);

        vowJoin.join();

        assertEq(dai.balanceOf(address(vowJoin)), 0, "Balance of VowJoin is not zero");
        assertEq(vat.dai(VOW), AMOUNT, "Vow internal balance not equals to the amount transfereed");
    }

    function _mintDai(address usr, uint256 wad) private {
        // Set initial balance for `usr` in the vat
        stdstore.target(address(vat)).sig(vat.dai.selector).with_key(usr).checked_write(wad);
        daiJoin.exit(usr, wad);
    }
}
