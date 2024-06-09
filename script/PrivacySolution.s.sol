// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Privacy.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";



/*
    The creator of this contract was careful enough to protect the sensitive areas of its storage.

    Unlock this contract to beat the level.

    Solution 1: Read the deployment transaction from the block explorer for constructor value
    Solution 2: Use cast <address> 5 to read the fifth storage slot
    Pass that value into unlock casting it into bytes16
 */
contract PrivacySolution is Script {

    Privacy public privacyInstance = Privacy(0x297baf5619c7c0c469FAd1b1485FfEd76fdD7595);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        bytes32 key = 0x2a11054a1853ac7a500f44d6fbb7f48c517f33bf6a65a33bd5fb77b4742050b0;
        privacyInstance.unlock(bytes16(key));
        vm.stopBroadcast();
    }
}