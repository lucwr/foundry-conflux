// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract Token2 is ERC20 {
    constructor() ERC20("Token2", "TKN2", 18) {
        _mint(msg.sender, 1000e18);
    }
}
