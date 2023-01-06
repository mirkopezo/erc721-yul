// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "../src/ERC721Yul.sol";

contract ERC721YulScript is Script {
    bool constant USE_MAINNET_PRIVATE_KEY = false;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey;

        if (USE_MAINNET_PRIVATE_KEY) {
            deployerPrivateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);

        ERC721Yul erc721Yul = new ERC721Yul();

        vm.stopBroadcast();

        console.log("ERC721Yul contract is deployed to: ", address(erc721Yul));
    }
}
