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

contract VowJoin {
    /// @dev The DaiJoin adapter from MCD.
    DaiJoinLike public immutable daiJoin;
    /// @dev The Dai token.
    DaiLike public immutable dai;
    /// @dev The Vow address from MCD.
    address public immutable vow;

    /**
     * @notice Revert reason when the Dai balance of this contract is zero and `flush` is called.
     */
    error Empty();

    /**
     * @notice Emitted when `join` is called.
     * @param amount The outstanding Dai balance when the `join` was called.
     */
    event Flush(uint256 amount);

    /**
     * @dev The Dai address is obtained from the DaiJoin contract.
     * @param _daiJoin The DaiJoin adapter from MCD.
     * @param _vow The vow from MCD.
     */
    constructor(address _daiJoin, address _vow) {
        daiJoin = DaiJoinLike(_daiJoin);
        dai = DaiLike(DaiJoinLike(_daiJoin).dai());
        vow = _vow;

        DaiLike(DaiJoinLike(_daiJoin).dai()).approve(_daiJoin, type(uint256).max);
    }

    /**
     * @notice Transfers any outstanding Dai balance in this contract to the surplus buffer.
     * @dev This effectively burns ERC-20 Dai and credits it to the internal Dai balance in the Vat.
     */
    function flush() external {
        uint256 balance = dai.balanceOf(address(this));

        if (balance == 0) {
            revert Empty();
        }

        daiJoin.join(vow, balance);
        emit Flush(balance);
    }
}

interface DaiLike {
    function approve(address, uint256) external;

    function balanceOf(address) external view returns (uint256);
}

interface DaiJoinLike {
    function dai() external view returns (address);

    function join(address, uint256) external;
}
