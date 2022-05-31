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

import {VatLike} from "./FakeVat.sol";
import {DaiLike} from "./FakeDai.sol";

interface DaiJoinLike {
    function dai() external view returns (DaiLike);
    function vat() external view returns (VatLike);
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

contract FakeDaiJoin is DaiJoinLike {
    VatLike public immutable vat;
    DaiLike public immutable dai;

    constructor(address _vat, address _dai) {
        vat = VatLike(_vat);
        dai = DaiLike(_dai);
    }

    event Join(address indexed usr, uint256 wad);
    event Exit(address indexed usr, uint256 wad);

    function join(address usr, uint256 wad) external {
        vat.move(address(this), usr, wad);
        dai.burn(msg.sender, wad);
        emit Join(usr, wad);
    }

    function exit(address usr, uint256 wad) external {
        vat.move(msg.sender, address(this), wad);
        dai.mint(usr, wad);
        emit Exit(usr, wad);
    }
}
