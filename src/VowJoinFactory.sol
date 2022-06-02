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

import {VowJoin} from "./VowJoin.sol";

contract VowJoinFactory {
    /// @notice registry for VowJoin Addresses. `ilkToVowJoin[ilk]`
    mapping(bytes32 => VowJoin) public ilkToVowJoin;

    /// @notice registry of vowJoin addresses to ilks. `vowJoinToIlk[vowJoin]`
    mapping(VowJoin => bytes32) public vowJoinToIlk;

    /// @notice list of created vowJoins.
    VowJoin[] public vowJoins;

    /**
     * @notice Vow Join created.
     * @param ilk ilk name.
     * @param vowJoin address of vow join.
     */
    event VowJoinCreated(bytes32 indexed ilk, VowJoin indexed vowJoin);

    /**
     * @notice Error event - VowJoin already exists for specified ilk.
     * @param ilk ilk name.
     */

    error VowJoinAlreadyExists(bytes32 ilk);

    /**
     * @notice Create a VowJoin contract.
     * @param ilk ilk name.
     * @param daiJoin daiJoin address.
     * @param vow vow address.
     * @return created VowJoin contract.
     */
    function createVowJoinAddress(
        bytes32 ilk,
        address daiJoin,
        address vow
    ) public returns (VowJoin) {
        if (ilkToVowJoin[ilk] != VowJoin(address(0))) {
            revert VowJoinAlreadyExists(ilk);
        }
        VowJoin vowJoin = new VowJoin(daiJoin, vow);
        vowJoins.push(vowJoin);
        ilkToVowJoin[ilk] = vowJoin;
        vowJoinToIlk[vowJoin] = ilk;
        emit VowJoinCreated(ilk, vowJoin);
        return vowJoin;
    }

    /**
     * @notice returns count of vowJoins.
     * @return count of vowJoins.
     */

    function count() public view returns (uint256) {
        return vowJoins.length;
    }

    /**
     * @notice returns list of vowJoins.
     * @return list of vowJoins.
     */
    function list() public view returns (VowJoin[] memory) {
        return vowJoins;
    }
}
