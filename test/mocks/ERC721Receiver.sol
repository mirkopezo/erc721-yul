// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ERC721Receiver {
    bool public acceptAllNfts;

    constructor(bool _acceptAllNfts) {
        acceptAllNfts = _acceptAllNfts;
    }

    function onERC721Received(address, address, uint256, bytes calldata)
        external
        view
        returns (bytes4)
    {
        if (acceptAllNfts) {
            return 0x150b7a02;
        } else {
            return 0xbeefbabe;
        }
    }
}
