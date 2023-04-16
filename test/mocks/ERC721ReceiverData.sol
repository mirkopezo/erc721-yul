// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "lib/forge-std/src/console.sol";

contract ERC721ReceiverData {
    function onERC721Received(address, address, uint256, bytes memory data)
        external
        pure
        returns (bytes4)
    {
        bytes memory expectedData1 = abi.encodePacked(
            bytes32(0x0a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20212223242526272829),
            bytes8(0x2a2b2c2d2e2f3031)
        );
        bytes memory expectedData2 = abi.encodePacked(bytes6(0x0a0b0c0d0e0f));

        if (data.length == 40 && keccak256(data) == keccak256(expectedData1)) {
            return 0x150b7a02;
        } else if (data.length == 6 && keccak256(data) == keccak256(expectedData2)) {
            return 0x150b7a02;
        } else {
            return 0xbeefbabe;
        }
    }
}
