// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @dev
/// @author Mirko Pezo (https://github.com/mirkopezo)
contract ERC721Yul {
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function transferFrom(address from, address to, uint256 tokenId) public payable {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let ownerSlot := keccak256(0x00, 64)

            let owner := sload(ownerSlot)

            mstore(0x20, _tokenApprovals.slot)

            let tokenApprovalsLoc := keccak256(0x00, 64)

            let approvedAddr := sload(tokenApprovalsLoc)

            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, caller())
            mstore(0x20, location)

            let isOperatorApproved := sload(keccak256(0x00, 64))

            // Revert if caller is not owner nor approved nor operator.
            if iszero(or(or(eq(owner, caller()), eq(approvedAddr, caller())), isOperatorApproved)) {
                revert(0x00, 0)
            }

            // Revert if 'from' is not owner of token.
            if iszero(eq(owner, from)) { revert(0x00, 0) }

            // Revert if 'to' is zero address.
            if iszero(to) { revert(0x00, 0) }

            // delete _tokenApprovals[tokenId]
            sstore(tokenApprovalsLoc, 0)

            sstore(ownerSlot, to)

            mstore(0x00, from)
            mstore(0x20, _balances.slot)

            let location2 := keccak256(0x00, 64)

            sstore(location2, sub(sload(location2), 1))

            mstore(0x00, to)
            mstore(0x20, _balances.slot)

            let location3 := keccak256(0x00, 64)

            sstore(location3, add(sload(location3), 1))

            // emit Transfer(from, to, tokenId)
            log4(
                0x00,
                0,
                // keccak256("Transfer(address,address,uint256)")
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                from,
                to,
                tokenId
            )
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let ownerSlot := keccak256(0x00, 64)

            let owner := sload(ownerSlot)

            mstore(0x20, _tokenApprovals.slot)

            let tokenApprovalsLoc := keccak256(0x00, 64)

            let approvedAddr := sload(tokenApprovalsLoc)

            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, caller())
            mstore(0x20, location)

            let isOperatorApproved := sload(keccak256(0x00, 64))

            // Revert if caller is not owner nor approved nor operator.
            if iszero(or(or(eq(owner, caller()), eq(approvedAddr, caller())), isOperatorApproved)) {
                revert(0x00, 0)
            }

            // Revert if 'from' is not owner of token.
            if iszero(eq(owner, from)) { revert(0x00, 0) }

            // Revert if 'to' is zero address.
            if iszero(to) { revert(0x00, 0) }

            // delete _tokenApprovals[tokenId]
            sstore(tokenApprovalsLoc, 0)

            sstore(ownerSlot, to)

            mstore(0x00, from)
            mstore(0x20, _balances.slot)

            let location2 := keccak256(0x00, 64)

            sstore(location2, sub(sload(location2), 1))

            mstore(0x00, to)
            mstore(0x20, _balances.slot)

            let location3 := keccak256(0x00, 64)

            sstore(location3, add(sload(location3), 1))

            // emit Transfer(from, to, tokenId)
            log4(
                0x00,
                0,
                // keccak256("Transfer(address,address,uint256)")
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                from,
                to,
                tokenId
            )

            let codeSize := extcodesize(to)
            // Return if recipient is not a contract.
            if iszero(codeSize) { return(0x00, 0) }

            mstore(0x00, 0x150b7a02)
            mstore(0x20, caller())
            mstore(0x40, from)
            mstore(0x60, tokenId)
            mstore(0x80, 0x80)
            mstore(0xa0, 0)

            let success := call(gas(), to, 0, 28, 164, 0x00, 32)

            // Revert if call failed.
            if iszero(success) { revert(0x00, 0) }

            let retVal := mload(0x00)

            // Revert if magic value is not returned.
            if iszero(
                eq(retVal, 0x150b7a0200000000000000000000000000000000000000000000000000000000)
            ) { revert(0x00, 0) }
        }
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data)
        public
        payable
    {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let ownerSlot := keccak256(0x00, 64)

            let owner := sload(ownerSlot)

            mstore(0x20, _tokenApprovals.slot)

            let tokenApprovalsLoc := keccak256(0x00, 64)

            let approvedAddr := sload(tokenApprovalsLoc)

            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, caller())
            mstore(0x20, location)

            let isOperatorApproved := sload(keccak256(0x00, 64))

            // Revert if caller is not owner nor approved nor operator.
            if iszero(or(or(eq(owner, caller()), eq(approvedAddr, caller())), isOperatorApproved)) {
                revert(0x00, 0)
            }

            // Revert if 'from' is not owner of token.
            if iszero(eq(owner, from)) { revert(0x00, 0) }

            // Revert if 'to' is zero address.
            if iszero(to) { revert(0x00, 0) }

            // delete _tokenApprovals[tokenId]
            sstore(tokenApprovalsLoc, 0)

            sstore(ownerSlot, to)

            mstore(0x00, from)
            mstore(0x20, _balances.slot)

            let location2 := keccak256(0x00, 64)

            sstore(location2, sub(sload(location2), 1))

            mstore(0x00, to)
            mstore(0x20, _balances.slot)

            let location3 := keccak256(0x00, 64)

            sstore(location3, add(sload(location3), 1))

            // emit Transfer(from, to, tokenId)
            log4(
                0x00,
                0,
                // keccak256("Transfer(address,address,uint256)")
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                from,
                to,
                tokenId
            )

            let codeSize := extcodesize(to)
            // Return if recipient is not a contract.
            if iszero(codeSize) { return(0x00, 0) }

            mstore(0x00, 0x150b7a02)
            mstore(0x20, caller())
            mstore(0x40, from)
            mstore(0x60, tokenId)
            mstore(0x80, 0x80)
            mstore(0xa0, data.length)
            calldatacopy(0xc0, data.offset, data.length)

            let len := add(164, data.length)

            let success := call(gas(), to, 0, 28, len, 0x00, 32)

            // Revert if call failed.
            if iszero(success) { revert(0x00, 0) }

            let retVal := mload(0x00)

            // Revert if magic value is not returned.
            if iszero(
                eq(retVal, 0x150b7a0200000000000000000000000000000000000000000000000000000000)
            ) { revert(0x00, 0) }
        }
    }

    function approve(address to, uint256 tokenId) public payable {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let owner := sload(keccak256(0x00, 64))

            // Revert if token doesn't exist or current owner is receiving approval.
            if or(iszero(owner), eq(owner, to)) { revert(0x00, 0) }

            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, caller())
            mstore(0x20, location)

            // Revert if caller is not owner nor operator.
            if iszero(or(eq(caller(), owner), sload(keccak256(0x00, 64)))) { revert(0x00, 0) }

            mstore(0x00, tokenId)
            mstore(0x20, _tokenApprovals.slot)

            sstore(keccak256(0x00, 64), to)

            // emit Approval(owner, to, tokenId)
            log4(
                0x00,
                0,
                // keccak256("Approval(address,address,uint256)")
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925,
                owner,
                to,
                tokenId
            )
        }
    }

    function setApprovalForAll(address operator, bool approved) public {
        assembly {
            // Revert if current owner is receiving approval.
            if eq(caller(), operator) { revert(0x00, 0) }

            mstore(0x00, caller())
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, operator)
            mstore(0x20, location)

            sstore(keccak256(0x00, 64), approved)

            mstore(0x00, approved)

            // emit ApprovalForAll(msg.sender, operator, approved)
            log3(
                0x00,
                32,
                // keccak256("ApprovalForAll(address,address,bool)")
                0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31,
                caller(),
                operator
            )
        }
    }

    function balanceOf(address owner) public view returns (uint256) {
        assembly {
            // Revert if address is zero.
            if iszero(owner) { revert(0x00, 0) }

            mstore(0x00, owner)
            mstore(0x20, _balances.slot)

            mstore(0x00, sload(keccak256(0x00, 64)))

            return(0x00, 32)
        }
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let owner := sload(keccak256(0x00, 64))

            // Revert if token doesn't exist.
            if iszero(owner) { revert(0x00, 0) }

            mstore(0x00, owner)

            return(0x00, 32)
        }
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            // Revert if token doesn't exist.
            if iszero(sload(keccak256(0x00, 64))) { revert(0x00, 0) }

            mstore(0x00, tokenId)
            mstore(0x20, _tokenApprovals.slot)

            mstore(0x00, sload(keccak256(0x00, 64)))

            return(0x00, 32)
        }
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        assembly {
            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, operator)
            mstore(0x20, location)

            mstore(0x00, sload(keccak256(0x00, 64)))

            return(0x00, 32)
        }
    }

    function _mint(address to, uint256 tokenId) internal {
        assembly {
            // Revert if mint to zero address.
            if iszero(to) { revert(0x00, 0) }

            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let location := keccak256(0x00, 64)

            // Revert if token already exists.
            if sload(location) { revert(0x00, 0) }

            sstore(location, to)

            mstore(0x00, to)
            mstore(0x20, _balances.slot)

            let location2 := keccak256(0x00, 64)

            sstore(location2, add(sload(location2), 1))

            // emit Transfer(address(0), to, tokenId)
            log4(
                0x00,
                0,
                // keccak256("Transfer(address,address,uint256)")
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                0,
                to,
                tokenId
            )
        }
    }
}
