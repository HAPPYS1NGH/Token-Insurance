// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {CryptoAssetInsuranceFactory} from"../src/AssetInsurance.sol";

contract AssetInsuranceScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        CryptoAssetInsuranceFactory factory =
            new CryptoAssetInsuranceFactory{value : 1 ether}(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        vm.stopBroadcast();
    }
}
