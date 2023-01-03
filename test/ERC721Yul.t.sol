// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ERC721Yul.sol";

contract MyCollection is ERC721Yul {
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract ERC721YulTest is Test {
    MyCollection nftContract;

    address user1 = address(0x1);
    address user2 = address(0x2);

    function setUp() external {
        nftContract = new MyCollection();
    }

    function testBalanceOf(address owner) external {
        if (owner == address(0)) {
            // Should revert if address is zero.
            vm.expectRevert();
            nftContract.balanceOf(owner);
        } else {
            assertEq(nftContract.balanceOf(owner), 0);

            nftContract.mint(owner, 3243);
            nftContract.mint(owner, 0);
            nftContract.mint(owner, 1256);
            nftContract.mint(owner, 542);

            vm.assume(owner != user1);

            nftContract.mint(user1, 2323);
            nftContract.mint(user1, 4444);

            assertEq(nftContract.balanceOf(owner), 4);

            assertEq(nftContract.balanceOf(user1), 2);
        }
    }

    function testOwnerOf(uint256 tokenId) external {
        // Should revert if token does not exist yet.
        vm.expectRevert();
        nftContract.ownerOf(tokenId);

        nftContract.mint(user1, tokenId);

        assertEq(nftContract.ownerOf(tokenId), user1);
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    function testMint(address to, uint256 tokenId) external {
        if (to == address(0)) {
            // Should revert if receiver is zero address.
            vm.expectRevert();
            nftContract.mint(to, tokenId);
        } else {
            // Event should be emitted after mint.
            vm.expectEmit(true, true, true, true, address(nftContract));
            emit Transfer(address(0), to, tokenId);
            nftContract.mint(to, tokenId);

            assertEq(nftContract.balanceOf(to), 1);
            assertEq(nftContract.ownerOf(tokenId), to);

            // Should revert if we try to mint token that exists.
            vm.expectRevert();
            nftContract.mint(to, tokenId);
        }
    }
}
