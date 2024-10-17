//SPDX-License-Identifier:MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {Deploy} from "../script/Deploy.s.sol";
import {NexTradeERC1155} from "../src/NexTradeERC1155.sol";
import {StockERC1155} from "../src/StockERC1155.sol";

contract Trade is Test {
    Deploy deploy;
    NexTradeERC1155 nexTradeERC1155;
    StockERC1155 stockERC1155;

    address public companyOwner = makeAddr("CompanyOwner");
    address public buyer = makeAddr("Buyer");

    function setUp() public {
        deploy = new Deploy();
        nexTradeERC1155 = deploy.run();
    }

    
    function testRegisterCompany() public {
        vm.startPrank(companyOwner);
        nexTradeERC1155.registerCompany("abc.com");
        nexTradeERC1155.createCompanyStock(100, 20);
        vm.stopPrank();
        assertEq(nexTradeERC1155.getCompanyAvailableStocks(companyOwner), 100);
        assertEq(nexTradeERC1155.getCompanyStockPrice(companyOwner), 20);
    }

    function testBuyCompanyStock() public {
        vm.startPrank(companyOwner);
        nexTradeERC1155.registerCompany("abc.com");
        nexTradeERC1155.createCompanyStock(100, 20);
        vm.stopPrank();
        vm.deal(buyer, 200); 
        vm.startPrank(buyer);
        nexTradeERC1155.buyCompanyStock{value: 200}(companyOwner, 10);
        vm.stopPrank();
        assertEq(nexTradeERC1155.getCompanyAvailableStocks(companyOwner), 90);
        address stockAddress = nexTradeERC1155.getCompanyStockContract(companyOwner);
        stockERC1155 = StockERC1155(stockAddress);
        assertEq(stockERC1155.balanceOf(buyer, 0), 10);
    }

        function testSellCompanyStock() public {
        vm.startPrank(companyOwner);
        nexTradeERC1155.registerCompany("abc.com");
        nexTradeERC1155.createCompanyStock(100, 20);
        vm.stopPrank();
        vm.deal(buyer, 1000); 
        vm.startPrank(buyer);
        nexTradeERC1155.buyCompanyStock{value: 400}(companyOwner, 20);
        nexTradeERC1155.sellCompanyStock(companyOwner, 10);
        vm.stopPrank();
        assertEq(nexTradeERC1155.getCompanyAvailableStocks(companyOwner), 90);
        address stockAddress = nexTradeERC1155.getCompanyStockContract(companyOwner);
        stockERC1155 = StockERC1155(stockAddress);
        assertEq(stockERC1155.balanceOf(buyer, 0), 10);
    }


}
