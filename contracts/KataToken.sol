// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KataToken is ERC20 {    
    constructor() ERC20("Kata Token", "KATA") {        
        _mint(msg.sender, 10000000 * (10 ** uint256(decimals())));    
    }
}