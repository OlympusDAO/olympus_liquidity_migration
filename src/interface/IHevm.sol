// SPDX-License-Identifier: AGPL-3.0
pragma solidity >=0.7.5;

interface IHevm {
    function prank(address h) external;

    function expectRevert(bytes calldata expectedError) external;

    function addr(uint256) external returns (address);

    function warp(uint256 x) external;

    function roll(uint256 x) external;
}
