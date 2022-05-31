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

import {ERC20} from "solmate/tokens/ERC20.sol";

interface DaiLike {
    function mint(address usr, uint256 wad) external;
    function mint(uint256 wad) external;
    function burn(address usr, uint256 wad) external;
    function burn(uint256 wad) external;
}

contract FakeDai is ERC20, DaiLike {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address usr, uint256 wad) external override {
        _mint(usr, wad);
    }

    function mint(uint256 wad) external override {
        _mint(msg.sender, wad);
    }

    function burn(address usr, uint256 wad) external override {
        _burn(usr, wad);
    }

    function burn(uint256 wad) external override {
        _burn(msg.sender, wad);
    }
}

