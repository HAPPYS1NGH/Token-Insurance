// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";

import "../src/IERC20.sol";

contract ContractIERC20Test is Test {
    IERC20 USDC;

    function setup() public {
        USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }

    function test_Balance() public view {
        uint256 bal = USDC.balanceOf(0x0A59649758aa4d66E25f08Dd01271e891fe52199);
        console.log(bal);
    }
}
