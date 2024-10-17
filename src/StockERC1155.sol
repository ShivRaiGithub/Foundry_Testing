// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StockERC1155 is ERC1155, Ownable {
    address public companyOwner;
    uint256 private totalSupply;
    uint256 private availableSupply;
    uint256 private stockPrice;
    uint256 private constant STOCK_TYPE=0;

    constructor(string memory _uri, address _owner) ERC1155(_uri) Ownable(msg.sender) {
        companyOwner = _owner;
    }

    // Create stock with initial supply and price
    function createStock(uint256 _price, uint256 _initialSupply) external onlyOwner {
        totalSupply = _initialSupply;
        availableSupply = _initialSupply;
        stockPrice = _price;
        _mint(companyOwner, STOCK_TYPE, _initialSupply, "");
    }

    // Buy stock from the stock contract
    function buyStock(address buyer, uint256 amount) external payable onlyOwner {
        uint256 totalPrice = stockPrice * amount;
        require(msg.value == totalPrice, "Incorrect payment amount");
        require(amount <= availableSupply, "Not enough stocks available");

        // Update available supply
        availableSupply -= amount;

        // Transfer the stock tokens to the buyer
        _safeTransferFrom(companyOwner, buyer, STOCK_TYPE, amount, "");
    }

    // Sell stock back to the stock contract
    function sellStock(address seller, uint256 amount) external onlyOwner {
        require(balanceOf(seller, STOCK_TYPE) >= amount, "Insufficient stock to sell");

        uint256 totalPrice = stockPrice * amount;

        // Transfer stock tokens back to the company owner
        _safeTransferFrom(seller, companyOwner, STOCK_TYPE, amount, "");

        // Update available supply
        availableSupply += amount;

        // Pay the seller from the contract's balance
        payable(seller).transfer(totalPrice);
    }

    // Retrieve price of the stock
    function getStockPrice() external view returns (uint256) {
        return stockPrice;
    }

    // Retrieve total supply of the stock
    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    // Retrieve available supply of the stock
    function getAvailableSupply() external view returns (uint256) {
        return availableSupply;
    }
}
