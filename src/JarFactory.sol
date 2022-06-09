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

import {Jar} from "./Jar.sol";

contract JarFactory {
  /// @notice registry for Jar Addresses. `ilkToJar[ilk]`.
  mapping(bytes32 => Jar) public ilkToJar;

  /// @notice registry of jar addresses to ilks. `jarToIlk[jar]`.
  mapping(Jar => bytes32) public jarToIlk;

  /// @notice list of created jars.
  Jar[] public jars;

  /**
   * @notice Vow Join created.
   * @param ilk ilk name.
   * @param jar address of vow join.
   */
  event JarCreated(bytes32 indexed ilk, Jar indexed jar);

  /**
   * @notice Error event - Jar already exists for specified ilk.
   * @param ilk ilk name.
   */
  error JarAlreadyExists(bytes32 ilk);

  /**
   * @notice Create a Jar contract.
   * @param ilk ilk name.
   * @param daiJoin daiJoin address.
   * @param vow vow address.
   * @return created Jar contract.
   */
  function createJar(
    bytes32 ilk,
    address daiJoin,
    address vow
  ) public returns (Jar) {
    if (ilkToJar[ilk] != Jar(address(0))) {
      revert JarAlreadyExists(ilk);
    }

    Jar jar = new Jar(daiJoin, vow);

    jars.push(jar);
    ilkToJar[ilk] = jar;
    jarToIlk[jar] = ilk;

    emit JarCreated(ilk, jar);

    return jar;
  }

  /**
   * @notice returns count of jars.
   * @return count of jars.
   */
  function count() public view returns (uint256) {
    return jars.length;
  }

  /**
   * @notice returns list of jars.
   * @return list of jars.
   */
  function list() public view returns (Jar[] memory) {
    return jars;
  }
}
