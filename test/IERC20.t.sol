// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.6.2 <0.9.0;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";
import "../src/PriceConvertor.sol";
import "../src/AggregatorV3Interface.sol";
import "src/AssetInsurance.sol";

contract ContractIERC20Test is Test {
    event Log(string message, int256 price);

    CryptoAssetInsuranceFactory public factory;
    address public owner; //0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
    address public usdc;
    address public oracle;
    IERC20 USDC;
    address[] addresses = [
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8,
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC
    ];
    string public output;
    AggregatorV3Interface priceFeed;

    function setUp() public {
        string memory value = vm.envString("RPC_URL");
        // vm.createSelectFork(output, 16806000);
        vm.createSelectFork(value);
        //0xc3dcB715eDeb0374E968177A3620c441344c3ED8 with USDC 151350000_000000
        usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        oracle = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
        owner = msg.sender;
        factory = new CryptoAssetInsuranceFactory{value : 2 ether}();
        priceFeed = AggregatorV3Interface(oracle);
        USDC = IERC20(usdc);
        vm.startPrank(0xc3dcB715eDeb0374E968177A3620c441344c3ED8);
        fundAddresses();
        vm.stopPrank();
    }

    function fundAddresses() public {
        uint256 amount = 100_000000;
        for (uint256 i = 0; i < addresses.length; i++) {
            bool success = USDC.transfer(addresses[i], amount);
            assertEq(success, true);
            uint256 bal = USDC.balanceOf(addresses[i]);
            assertEq(bal, 100000000);
        }
    }

    function test_Asset() public {
        // vm.startPrank(addresses[0]);
        startHoax(addresses[0]);
        console.log("Insisde Test");
        factory.getInsurance{value: 1 ether}(1, usdc, 1, oracle, 8);
        address contractAsset = factory.getCustomerToContract(msg.sender);
        AssetWalletInsurance childContract = AssetWalletInsurance(payable(contractAsset));
        // assertEq(msg.sender, childContract.owner );

        console.log(childContract.owner());
        console.log("////////////\\\\\\\\\\\\");
    }

    function test_Balance() public {
        // startHoax(addresses[0]);
        vm.startPrank(addresses[0]);
        console.log(addresses[0].balance);
    }

    // function test_TransferUSDC() public {
    //     uint256 bal = USDC.balanceOf(0xc3dcB715eDeb0374E968177A3620c441344c3ED8);
    //     console.log(bal);

    //     bool success = USDC.transfer(alice, amount);
    //     bal = USDC.balanceOf(alice);
    //     console.log(bal);

    //     assertEq(success, true);
    // }

    function test_PriceFeed() public {
        (
            /* uint80 roundID */
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        emit Log("Did something!", price);
    }

    // function test_Fork() public {
    //     // uint256 bal = USDC.balanceOf(0x0A59649758aa4d66E25f08Dd01271e891fe52199);
    //     string memory expected = "https://eth-mainnet.g.alchemy.com/v2/7HGAc8jupPxgmBuEZagmzM7oNtkA1gF8";
    //     assertEq(output, expected);
    // }
}
