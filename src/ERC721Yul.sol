// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @dev
/// @author Mirko Pezo (https://github.com/mirkopezo)
contract ERC721Yul {
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function balanceOf(address owner) external view returns (uint256) {
        assembly {
            // Revert if address is zero.
            if iszero(owner) {
                revert(0x00, 0)
            }

            mstore(0x00, owner)
            mstore(0x20, _balances.slot)

            let location := keccak256(0x00, 64)

            let bal := sload(location)

            mstore(0x00, bal)

            return(0x00, 32)
        }
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let location := keccak256(0x00, 64)

            let owner := sload(location)

            // Revert if token doesn't exist.
            if iszero(owner) {
                revert(0x00, 0)
            }

            mstore(0x00, owner)

            return(0x00, 32)
        }
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external payable {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable {}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external payable {}

    function approve(address to, uint256 tokenId) external payable {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let location := keccak256(0x00, 64)

            let owner := sload(location)

            // Revert if token doesn't exist or current owner is receiving approval.
            if or(iszero(owner), eq(owner, to)) {
                revert(0x00, 0)
            }

            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            location := keccak256(0x00, 64)

            mstore(0x00, caller())
            mstore(0x20, location)

            location := keccak256(0x00, 64)

            let isApproved := sload(location)

            // Revert if caller is not owner nor operator.
            if iszero(or(eq(caller(), owner), isApproved)) {
                revert(0x00, 0)
            }

            mstore(0x00, tokenId)
            mstore(0x20, _tokenApprovals.slot)

            location := keccak256(0x00, 64)

            sstore(location, to)
        }
    }

    function setApprovalForAll(address operator, bool approved) external {
        assembly {
            // Revert if current owner is receiving approval.
            if eq(caller(), operator) {
                revert(0x00, 0)
            }

            mstore(0x00, caller())
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, operator)
            mstore(0x20, location)

            location := keccak256(0x00, 64)

            sstore(location, approved)
        }
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        assembly {
            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let location := keccak256(0x00, 64)

            let owner := sload(location)

            // Revert if token doesn't exist.
            if iszero(owner) {
                revert(0x00, 0)
            }

            mstore(0x00, tokenId)
            mstore(0x20, _tokenApprovals.slot)

            location := keccak256(0x00, 64)

            let approved := sload(location)

            mstore(0x00, approved)

            return(0x00, 32)
        }
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {
        assembly {
            mstore(0x00, owner)
            mstore(0x20, _operatorApprovals.slot)

            let location := keccak256(0x00, 64)

            mstore(0x00, operator)
            mstore(0x20, location)

            location := keccak256(0x00, 64)

            let isApproved := sload(location)

            mstore(0x00, isApproved)

            return(0x00, 32)
        }
    }

    function _mint(address to, uint256 tokenId) internal {
        assembly {
            // Revert if mint to zero address.
            if iszero(to) {
                revert(0x00, 0)
            }

            mstore(0x00, tokenId)
            mstore(0x20, _owners.slot)

            let location := keccak256(0x00, 64)

            let owner := sload(location)

            // Revert if token already exists.
            if owner {
                revert(0x00, 0)
            }

            sstore(location, to)

            mstore(0x00, to)
            mstore(0x20, _balances.slot)

            location := keccak256(0x00, 64)

            let bal := add(sload(location), 1)

            sstore(location, bal)

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
