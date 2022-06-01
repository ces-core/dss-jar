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

// Contracts from CES MCD on Goerli
address constant MCD_VAT = 0xDEcab25Ce117b3acB149E21e6A70acEF57aB89cA;
address constant MCD_DAI = 0x1Dd2f5799F83A5bD045F656Cd85a06F1C078183D;
address constant MCD_JOIN_DAI = 0x157c794cE5dAd9F0C42870eaD45Cd9B072A08527;

contract VowJoinTest is Test {
    using stdStorage for StdStorage;

    VatLike internal vat;
    DaiLike internal dai;
    DaiJoinLike internal daiJoin;
    VowJoin internal vowJoin;
    address internal constant VOW = address(0x1337);
    uint256 internal constant AMOUNT = 1e18;

    function setUp() public {
        vat = VatLike(MCD_VAT);
        daiJoin = DaiJoinLike(MCD_JOIN_DAI);
        dai = DaiLike(MCD_DAI);

        vowJoin = new VowJoin(address(daiJoin), VOW);

        _mintDai(address(this), AMOUNT);
    }

    function testTransfersAnyOutstandingDaiBalanceToTheVow() public {
        dai.transfer(address(vowJoin), AMOUNT);

        vowJoin.join();

        assertEq(dai.balanceOf(address(vowJoin)), 0, "Balance of VowJoin is not zero");
        assertEq(vat.dai(VOW), _rad(AMOUNT), "Vow internal balance not equals to the amount transfereed");
    }

    function _mintDai(address usr, uint256 wad) private {
        // Set initial balance for `usr` in the vat
        stdstore.target(address(vat)).sig(vat.dai.selector).with_key(usr).checked_write(_rad(wad));
        // Authorizes daiJoin to operate on behalf of the user in the vat
        stdstore.target(address(vat)).sig(vat.can.selector).with_key(usr).with_key(address(daiJoin)).checked_write(1);
        daiJoin.exit(usr, wad);
    }

    function _rad(uint256 wad) private pure returns (uint256) {
        uint256 ray = 10**27;
        return wad * ray;
    }
}

interface VatLike {
    function can(address, address) external view returns (uint256);

    function dai(address) external view returns (uint256);

    function move(
        address,
        address,
        uint256
    ) external;
}

interface DaiLike {
    function approve(
        address,
        address,
        uint256
    ) external;

    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function pull(address, uint256) external;

    function push(address, uint256) external;

    function move(
        address,
        address,
        uint256
    ) external;

    function mint(address, uint256) external;

    function burn(address, uint256) external;

    function balanceOf(address usr) external view returns (uint256);

    function permit(
        address,
        address,
        uint256,
        uint256,
        bool,
        uint8,
        bytes32,
        bytes32
    ) external;
}

interface DaiJoinLike {
    function dai() external view returns (DaiLike);

    function vat() external view returns (VatLike);

    function join(address, uint256) external;

    function exit(address, uint256) external;
}
