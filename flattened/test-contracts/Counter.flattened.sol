// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// src/Counter.sol

contract Counter {
    uint256 public number;

    function setNumber(uint256 new_number) public {
        number = new_number;
    }

    function increment() public {
        number++;
    }
}
