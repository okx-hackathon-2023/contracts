pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FGT is ERC20, Ownable {
    address public factory;

    constructor() ERC20("FGT", "FGT") {}
    function decimals() public override view returns (uint8) {
        return 6;
    }

    function setFactory(address _factory) public onlyOwner {
        factory = _factory;
    }

    modifier onlyFactory() {
        require(factory == msg.sender);
        _;
    }

    function issue(address to, uint256 amount) public onlyFactory() {
        _mint(to, amount);
    }
}
