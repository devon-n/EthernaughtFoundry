// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../src/Token.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract TokenSolution is Script {

    Token public tokenInstance = Token(0xbEB02D8a6F38BB769458b31d5CF1D2E1f3C9a2a7);

    function run() external {
        // Send 21 tokens to another address
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        tokenInstance.transfer(address(tokenInstance), 21);
        console.log(tokenInstance.balanceOf(vm.envAddress("MY_ADDRESS")));
        vm.stopBroadcast();
    }
}