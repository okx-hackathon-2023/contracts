pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockUSDT is ERC20, Ownable {
    constructor() ERC20("MockUSDT", "mUSDT") {
    }
    function decimals() public override view returns (uint8) {
        return 6;
    }

    function issue(address to, uint256 amount) public onlyOwner() {
        _mint(to, amount);
    }
}
