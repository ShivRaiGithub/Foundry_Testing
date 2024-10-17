// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {StockERC1155} from "./StockERC1155.sol";

contract NexTradeERC1155 {
    struct Company {
        address owner;
        address stockContract;
    }

    mapping(address => Company) public companies;

    event CompanyCreated(address indexed owner, address stockContract);
    event StockBought(address indexed buyer, uint256 amount);
    event StockSold(address indexed seller, uint256 amount);
    
    error NexTrade__NoStockContract();
    error NexTrade__NoStock();
    error NexTrade__NotEnoughStockAvailable();
    error NexTrade__IncorrectPayment();
    error NexTrade__CompanyAlreadyCreatedStock();
    error NexTrade__CompanyAlreadyHasStock();



    modifier hasStockContractAndStocks(address _company) {
        require(getCompanyStockContract(_company) != address(0), NexTrade__NoStockContract());
        require(StockERC1155(getCompanyStockContract(_company)).getTotalSupply() != 0, NexTrade__NoStock());
        _;
    }

    // Company creates its own stock contract
    function registerCompany(string memory uri) public {
        require(companies[msg.sender].stockContract == address(0), NexTrade__CompanyAlreadyCreatedStock());

        // Deploy a new StockERC1155 contract for the company
        StockERC1155 newStockContract = new StockERC1155(uri, msg.sender);

        // Store the company's details
        companies[msg.sender] = Company({
            owner: msg.sender,
            stockContract: address(newStockContract)
        });

        emit CompanyCreated(msg.sender, address(newStockContract));
    }

    function createCompanyStock(uint256 _initialSupply, uint256 _price) public {
        address stockContractAddress = getCompanyStockContract(msg.sender);
        require(stockContractAddress != address(0), NexTrade__NoStockContract());

        StockERC1155 stockContract = StockERC1155(stockContractAddress);

        // Ensure the company has not created a stock before
        require(stockContract.getTotalSupply() == 0, NexTrade__CompanyAlreadyHasStock());

        // Create a new stock with supply and price
        stockContract.createStock(_price, _initialSupply);
    }

    // Function to buy stock from a company's stock contract
    function buyCompanyStock(address _company, uint256 _amount) public payable hasStockContractAndStocks(_company) {
        address stockContractAddress = getCompanyStockContract(_company);

        StockERC1155 stockContract = StockERC1155(stockContractAddress);

        // Validate stock price and payment
        uint256 stockPrice = stockContract.getStockPrice();
        require(msg.value == stockPrice * _amount, NexTrade__IncorrectPayment());

        uint256 availableSupply = stockContract.getAvailableSupply();
        require(_amount <= availableSupply, NexTrade__NotEnoughStockAvailable());

        // Call stock contract to process the purchase
        stockContract.buyStock{value: msg.value}(msg.sender, _amount);

        emit StockBought(msg.sender, _amount);
    }

    // Function to sell stock back to the company's stock contract
    function sellCompanyStock(address _company, uint256 _amount) public hasStockContractAndStocks(_company) {
        address stockContractAddress = getCompanyStockContract(_company);
        StockERC1155 stockContract = StockERC1155(stockContractAddress);

        // Process the sale in the stock contract
        stockContract.sellStock(msg.sender, _amount);

        emit StockSold(msg.sender, _amount);
    }

    
    // Retrieve the stock contract for a company
    function getCompanyStockContract(address company) public view returns (address) {
        return companies[company].stockContract;
    }

    function getCompanyStockPrice(address _company) public view hasStockContractAndStocks(_company) returns (uint256) {
        address stockContractAddress = getCompanyStockContract(_company);
        StockERC1155 stockContract = StockERC1155(stockContractAddress);
        return stockContract.getStockPrice();
    }
    function getCompanyAvailableStocks(address _company) public view hasStockContractAndStocks(_company) returns (uint256) {
        address stockContractAddress = getCompanyStockContract(_company);
        StockERC1155 stockContract = StockERC1155(stockContractAddress);
        return stockContract.getAvailableSupply();
    }

}
