// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract Token1 is ERC20 {
    address owner1 = 0x2c5F2886100114C10833dF2E52Ebfab54D59dfc9;

    constructor() ERC20("Token1", "TKN1", 18) {
        _mint(owner1, 1000e18);
    }
}
