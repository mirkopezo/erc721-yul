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
    address user3 = address(0x3);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function testApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) external {
        vm.startPrank(owner);

        if (owner == operator) {
            // Should revert if current owner is receiving approval.
            vm.expectRevert();
            nftContract.setApprovalForAll(operator, approved);
        } else {
            // Event should be emitted after approval.
            vm.expectEmit(true, true, false, true, address(nftContract));
            emit ApprovalForAll(owner, operator, approved);
            nftContract.setApprovalForAll(operator, approved);

            assertEq(nftContract.isApprovedForAll(owner, operator), approved);
        }

        vm.stopPrank();
    }

    function testApprove(uint256 tokenId) external {
        // Should revert if token does not exist.
        vm.expectRevert();
        nftContract.getApproved(tokenId);

        nftContract.mint(user1, tokenId);

        vm.startPrank(user2);

        // Should revert if caller is not owner nor operator.
        vm.expectRevert();
        nftContract.approve(user3, tokenId);

        changePrank(user1);

        // Event should be emitted after approval.
        vm.expectEmit(true, true, true, true, address(nftContract));
        emit Approval(user1, user3, tokenId);
        nftContract.approve(user3, tokenId);
        assertEq(nftContract.getApproved(tokenId), user3);

        nftContract.setApprovalForAll(user3, true);

        changePrank(user3);

        // Should allow to approve because caller is operator.
        nftContract.approve(user2, tokenId);
        assertEq(nftContract.getApproved(tokenId), user2);

        vm.stopPrank();
    }

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
