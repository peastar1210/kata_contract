// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KataToken is ERC20 {    
    constructor() ERC20("Kata Token", "KATA") {        
        _mint(msg.sender, 1000 * (10 ** uint256(decimals())));    
    }
}