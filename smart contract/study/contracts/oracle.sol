// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FastcampusOracle is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}
    uint256 public BTC_PRICE;

    function setPrice(uint256 price) public onlyOwner {
        BTC_PRICE = price;
    }

    function getPrice() public view returns (uint256) {
        return BTC_PRICE;
    }
}