// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/SimpleStorage.sol";

contract SimpleStorageTest is Test {
    SimpleStorage simpleStorage;

    function setUp() public {
        simpleStorage = new SimpleStorage();
    }

    function testSetAndGet() public {
        simpleStorage.set(42);
        assertEq(simpleStorage.get(), 42);
    }
}
