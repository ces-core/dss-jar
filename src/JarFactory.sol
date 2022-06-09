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
  /**
   * @notice Jar created.
   * @param daiJoin daiJoin address.
   * @param vow vow address.
   * @param jar the address of the Jar created.
   */
  event JarCreated(address indexed daiJoin, address indexed vow, Jar jar);

  /**
   * @notice Create a Jar contract.
   * @param daiJoin daiJoin address.
   * @param vow vow address.
   * @return created Jar contract.
   */
  function newJar(address daiJoin, address vow) public returns (Jar) {
    Jar jar = new Jar(daiJoin, vow);

    emit JarCreated(daiJoin, vow, jar);

    return jar;
  }
}
