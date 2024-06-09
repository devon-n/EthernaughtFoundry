
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/DoubleEntryPoint.sol";


/*
    This level features a CryptoVault with special functionality, the sweepToken function.
    This is a common function used to retrieve tokens stuck in a contract.
    The CryptoVault operates with an underlying token that can't be swept, as it is an important core logic component of the CryptoVault.
    Any other tokens can be swept.

    The underlying token is an instance of the DET token implemented in the DoubleEntryPoint contract definition and
    the CryptoVault holds 100 units of it.
    Additionally the CryptoVault also holds 100 of LegacyToken LGT.

    In this level you should figure out where the bug is in CryptoVault and protect it from being drained out of tokens.

    The contract features a Forta contract where any user can register its own detection bot contract.
    Forta is a decentralized, community-based monitoring network to detect threats and anomalies on DeFi, NFT,
    governance, bridges and other Web3 systems as quickly as possible.

    Your job is to implement a detection bot and register it in the Forta contract.
    The bot's implementation will need to raise correct alerts to prevent potential attacks or bug exploits.

    Things that might help:
        How does a double entry point work for a token contract?



    Exploit
    Get vault from double entry point contract
    CryptoVault vault = CryptoVault(doubleEntryPoint.cryptoVault());

    Get underlying ERC20 from vault
    address DET = address(vault.underlying());

    Get LegacyToken from double entry point
    address LGT = doubleEntryPoint.delegatedFrom();

    Sweep token
    vault.sweepToken(IERC20(LGT));

    Solution: Bot deploy
    1. Create and deploy the `DetectionBot` with the correct constructor paramter
        The first one is the source we want to monitor
        The second one is the signature of the function we want to match
*/

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

        DetectionBot bot = new DetectionBot(
            doubleEntryPoint.cryptoVault(),
            abi.encodeWithSignature("delegateTransfer(address,uint256,address)")
        );

        // add the bot to the Forta network detection system that monitor the `DoubleEntryPoint` contract
        doubleEntryPoint.forta().setDetectionBot(address(bot));

        vm.stopBroadcast();
    }
}