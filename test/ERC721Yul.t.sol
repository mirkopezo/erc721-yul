// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "../src/ERC721Yul.sol";
import "../test/mocks/ERC721Receiver.sol";
import "../test/mocks/ERC721ReceiverData.sol";

contract MyCollection is ERC721Yul {
    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }
}

contract ERC721YulTest is Test {
    MyCollection nftContract;
    ERC721Receiver receiverContractAccept;
    ERC721Receiver receiverContractDecline;
    ERC721ReceiverData receiverContractData;

    address user1 = address(0x1);
    address user2 = address(0x2);
    address user3 = address(0x3);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function setUp() external {
        nftContract = new MyCollection();
        receiverContractAccept = new ERC721Receiver(true);
        receiverContractDecline = new ERC721Receiver(false);
        receiverContractData = new ERC721ReceiverData();
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

    function testApprovalForAll(address owner, address operator, bool approved) external {
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

    function testTransferFrom(address to, uint256 tokenId) external {
        nftContract.mint(user1, tokenId);

        vm.startPrank(user1);

        nftContract.approve(user3, tokenId);

        if (to == address(0)) {
            // Revert if 'to' is zero address.
            vm.expectRevert();
            nftContract.transferFrom(user1, to, tokenId);
        } else {
            // Event should be emitted after every transfer.
            vm.expectEmit(true, true, true, true, address(nftContract));
            emit Transfer(user1, to, tokenId);
            nftContract.transferFrom(user1, to, tokenId);

            assertEq(nftContract.ownerOf(tokenId), to);
            // Token approvals should be cleared after every transfer.
            assertEq(nftContract.getApproved(tokenId), address(0));

            if (to == user1) {
                assertEq(nftContract.balanceOf(user1), 1);
            } else {
                assertEq(nftContract.balanceOf(user1), 0);
                assertEq(nftContract.balanceOf(to), 1);
            }
        }
    }

    function testTransferFrom(address randomCaller) external {
        nftContract.mint(user1, 56);
        nftContract.mint(user1, 75);
        nftContract.mint(user1, 99);

        vm.startPrank(user1);

        nftContract.approve(user2, 56);
        nftContract.setApprovalForAll(user3, true);

        changePrank(user2);

        nftContract.transferFrom(user1, user2, 56);

        changePrank(user3);

        nftContract.transferFrom(user1, user2, 75);

        // Should revert if caller is not approved.
        vm.expectRevert();
        nftContract.transferFrom(user2, user3, 99);

        vm.assume(randomCaller != address(0));
        vm.assume(randomCaller != user1);
        vm.assume(randomCaller != user3);

        changePrank(randomCaller);

        // Should revert if caller is not approved.
        vm.expectRevert();
        nftContract.transferFrom(user1, user2, 99);
    }

    function testSafeTransferFrom(address from, address to, uint256 tokenId) external {
        vm.assume(from != address(0) && to != address(0));
        vm.assume(from != to);
        vm.assume(
            to.code.length == 0 && to != address(receiverContractDecline)
                && to != address(receiverContractData)
        );

        nftContract.mint(from, tokenId);

        assertEq(nftContract.balanceOf(from), 1);
        assertEq(nftContract.balanceOf(to), 0);

        vm.startPrank(from);

        nftContract.safeTransferFrom(from, to, tokenId);

        assertEq(nftContract.balanceOf(from), 0);
        assertEq(nftContract.balanceOf(to), 1);
    }

    function testSafeTransferFromAccept() external {
        address to = address(receiverContractAccept);

        nftContract.mint(user1, 23);

        assertEq(nftContract.balanceOf(user1), 1);
        assertEq(nftContract.balanceOf(to), 0);

        vm.startPrank(user1);

        nftContract.safeTransferFrom(user1, to, 23);

        assertEq(nftContract.balanceOf(user1), 0);
        assertEq(nftContract.balanceOf(to), 1);
    }

    function testSafeTransferFromDecline() external {
        address to = address(receiverContractDecline);

        nftContract.mint(user1, 23);

        assertEq(nftContract.balanceOf(user1), 1);
        assertEq(nftContract.balanceOf(to), 0);

        vm.startPrank(user1);

        // Should revert if receiver contract does not accept transfer.
        vm.expectRevert();
        nftContract.safeTransferFrom(user1, to, 23);
    }

    function testSafeTransferFromData(address from, address to, uint256 tokenId) external {
        vm.assume(from != address(0) && to != address(0));
        vm.assume(from != to);
        vm.assume(
            to.code.length == 0 && to != address(receiverContractDecline)
                && to != address(receiverContractData)
        );

        nftContract.mint(from, tokenId);

        assertEq(nftContract.balanceOf(from), 1);
        assertEq(nftContract.balanceOf(to), 0);

        vm.startPrank(from);

        bytes memory data = abi.encodePacked(bytes4(0xcafebabe));

        nftContract.safeTransferFrom(from, to, tokenId, data);

        assertEq(nftContract.balanceOf(from), 0);
        assertEq(nftContract.balanceOf(to), 1);
    }

    function testSafeTransferFromSmallData() external {
        address to = address(receiverContractData);

        nftContract.mint(user1, 23);

        assertEq(nftContract.balanceOf(user1), 1);
        assertEq(nftContract.balanceOf(to), 0);

        vm.startPrank(user1);

        bytes memory notExpectedData = abi.encodePacked(bytes6(0x1a0b0c0d0e0f));

        // Should revert if receiver contract does not accept transfer.
        vm.expectRevert();
        nftContract.safeTransferFrom(user1, to, 23, notExpectedData);

        bytes memory expectedData = abi.encodePacked(bytes6(0x0a0b0c0d0e0f));

        nftContract.safeTransferFrom(user1, to, 23, expectedData);

        assertEq(nftContract.balanceOf(user1), 0);
        assertEq(nftContract.balanceOf(to), 1);
    }

    function testSafeTransferFromBigData() external {
        address to = address(receiverContractData);

        nftContract.mint(user1, 23);

        assertEq(nftContract.balanceOf(user1), 1);
        assertEq(nftContract.balanceOf(to), 0);

        vm.startPrank(user1);

        bytes memory notExpectedData = abi.encodePacked(
            bytes32(0x0a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20212223242526272829),
            bytes8(0x3a2b2c2d2e2f3031)
        );

        // Should revert if receiver contract does not accept transfer.
        vm.expectRevert();
        nftContract.safeTransferFrom(user1, to, 23, notExpectedData);

        bytes memory expectedData = abi.encodePacked(
            bytes32(0x0a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20212223242526272829),
            bytes8(0x2a2b2c2d2e2f3031)
        );

        nftContract.safeTransferFrom(user1, to, 23, expectedData);

        assertEq(nftContract.balanceOf(user1), 0);
        assertEq(nftContract.balanceOf(to), 1);
    }
}
