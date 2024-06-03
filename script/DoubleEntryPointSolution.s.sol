
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/DoubleEntryPoint.sol";


contract DetectionBot is IDetectionBot {
    address private monitoredSource;
    bytes private monitoredSig;

    constructor(address _monitoredSource, bytes memory _monitoredSig) public {
        monitoredSource = _monitoredSource;
        monitoredSig = _monitoredSig;
    }

    function handleTransaction(address user, bytes calldata msgData) external override {
        (address to, uint256 value, address origSender) = abi.decode(msgData[4:], (address, uint256, address));

        bytes memory callSig = abi.encodePacked(msgData[0], msgData[1], msgData[2], msgData[3]);

        if (origSender == monitoredSource && keccak256(callSig) == keccak256(monitoredSig)) {
            IForta(msg.sender).raiseAlert(user);
        }
    }
}


contract DoubleEntryPointSolution is Script {

    DoubleEntryPoint doubleEntryPoint = DoubleEntryPoint(0xB510680D4Fe5Fa9dEF1efF57b0D278F7e2aBacD0);
    function run() external{
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Exploit
        // // Get vault from double entry point contract
        // CryptoVault vault = CryptoVault(doubleEntryPoint.cryptoVault());

        // // Get underlying ERC20 from vault
        // address DET = address(vault.underlying());

        // // Get LegacyToken from double entry point
        // address LGT = doubleEntryPoint.delegatedFrom();

        // // Sweep token
        // vault.sweepToken(IERC20(LGT));

        // Solution: Bot deploy
        // Create and deploy the `DetectionBot` with the correct constructor paramter
        // The first one is the source we want to monitor
        // The second one is the signature of the function we want to match
        DetectionBot bot = new DetectionBot(
            doubleEntryPoint.cryptoVault(),
            abi.encodeWithSignature("delegateTransfer(address,uint256,address)")
        );

        // add the bot to the Forta network detection system that monitor the `DoubleEntryPoint` contract
        doubleEntryPoint.forta().setDetectionBot(address(bot));

        vm.stopBroadcast();
    }
}