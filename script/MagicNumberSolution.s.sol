
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/MagicNumber.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract MagicNumContract {
    constructor(MagicNum magicNum) {
        // Create bytecode of a contract that returns 42 for the function in question
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address addr;
        assembly {
            // use assembly to deploy another contract with the above bytecode that returns the function we want
            // create(value, offset, size)
            addr := create(0, add(bytecode, 0x20), 0x13)
        }
        require(addr != address(0));
        // Call setSolver() on the deployed contract with the bytecode
        magicNum.setSolver(addr);
    }

}
contract MagicNumberSolution is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new MagicNumContract(MagicNum(0x632027639fa000365eC8C589FF6f92B1071eab59));
        vm.stopBroadcast();
    }
}