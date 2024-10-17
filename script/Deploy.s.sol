//SPDX-License-Identifer:MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {NexTradeERC1155} from "../src/NexTradeERC1155.sol";

contract Deploy is Script {
    NexTradeERC1155 nexTrade;

    function run() public returns (NexTradeERC1155) {
        vm.startBroadcast(msg.sender);
        nexTrade = new NexTradeERC1155();
        vm.stopBroadcast();
        return nexTrade;

    }
}