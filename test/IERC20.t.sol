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
    address public ethToUsdOracle;
    address[] public contracts;
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
        vm.createSelectFork(value, 16700030);
        usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        oracle = 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6;
        owner = msg.sender;
        ethToUsdOracle = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
        factory = new CryptoAssetInsuranceFactory{value : 2 ether}(ethToUsdOracle);
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        USDC = IERC20(usdc);
        //0x0A59649758aa4d66E25f08Dd01271e891fe52199 with USDC 151350000_000000
        vm.startPrank(0x0A59649758aa4d66E25f08Dd01271e891fe52199);
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
        uint256 _planAmount;
        for (uint8 i = 0; i < addresses.length; i++) {
            if (i == 0) {
                _planAmount = 1;
            } else {
                if (i == 1) {
                    _planAmount = 5;
                } else {
                    _planAmount = 10;
                }
            }

            startHoax(addresses[i]);
            uint256 price = factory.getFeedValueOfAsset(oracle);
            uint256 bal = USDC.balanceOf(addresses[i]);
            uint256 _value = factory.calculateDepositMoney(bal, _planAmount, price, 6, i + 1);
            factory.getInsurance{value: _value}((i + 1), usdc, (i + 1), oracle, 6);
            address contractAsset = factory.getCustomerToContract(addresses[i]);
            // console.log("Iteration");
            // console.log(i);
            // console.log(contractAsset);
            contracts.push(contractAsset);
            AssetWalletInsurance childContract = AssetWalletInsurance(payable(contractAsset));
            vm.makePersistent(addresses[i]);
            vm.makePersistent(contractAsset);
            vm.makePersistent(address(factory));
            assertEq(addresses[i], childContract.owner());
            vm.stopPrank();
        }
    }
    //16805230

    function test_Claim() public {
        test_Asset();
        string memory value = vm.envString("RPC_URL");
        vm.createSelectFork(value, 16804030);
        for (uint256 i = 0; i < addresses.length; i++) {
            console.log(contracts[i].balance);
            startHoax(addresses[i]);
            AssetWalletInsurance assetContract = AssetWalletInsurance(payable(contracts[i]));
            assetContract.claim();
            console.log(contracts[i].balance);
            vm.stopPrank();
        }
    }

    function test_Balance() public {
        test_Asset();
        console.log(0xA1cA8926c1A9A78a3EFfAE666E57b0065d78A604.balance);
        // vm.makePersistent(0xA1cA8926c1A9A78a3EFfAE666E57b0065d78A604);
        // vm.rollFork(16804030);
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/7HGAc8jupPxgmBuEZagmzM7oNtkA1gF8", 16804030);
        console.log(0xA1cA8926c1A9A78a3EFfAE666E57b0065d78A604.balance);
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
        emit Log("Did something!", (10 ** 26) / price);
        // uint256 bal1 = 0xA1cA8926c1A9A78a3EFfAE666E57b0065d78A604.balance;
        // uint256 bal1 = USDC.balanceOf(addresses[0]);
        // vm.makePersistent(addresses[0]);
        // console.log(bal1);
        // vm.rollFork(16804030);
        // string memory value = vm.envString("RPC_URL");
        // vm.createSelectFork(value, 16804030);
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/7HGAc8jupPxgmBuEZagmzM7oNtkA1gF8", 16804030);
        AggregatorV3Interface priceFeed2 = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        (
            /* uint80 roundID */
            ,
            int256 price2,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = priceFeed2.latestRoundData();
        // // uint256 bal = USDC.balanceOf(addresses[0]);
        // uint256 bal = 0xA1cA8926c1A9A78a3EFfAE666E57b0065d78A604.balance;
        // console.log(bal);
        emit Log("Did something!", (10 ** 26) / price2);
    }

    // function test_Fork() public {
    //     // uint256 bal = USDC.balanceOf(0x0A59649758aa4d66E25f08Dd01271e891fe52199);
    //     string memory expected = "https://eth-mainnet.g.alchemy.com/v2/7HGAc8jupPxgmBuEZagmzM7oNtkA1gF8";
    //     assertEq(output, expected);
    // }
}
