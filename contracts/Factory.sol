pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Fund.sol";

interface issuedERC20 {
    function issue(address to, uint256 amount) external;
}

contract Factory is Ownable {
    IERC20 constant FGT = IERC20(0xe193AB2EE6b6E0ABE1C9818763d3070BAC96DFBC);
    IERC20 constant USDT = IERC20(0x36AA5e2fAfE33bF95344165fa0FCc33b9e8a4886);
    address[] public funds;
    uint interest;
    uint DENOMINATOR = 10000;
    uint OWNER_CONTRIBUTION = 50_000*1e6;

    function createFund(string calldata name, string calldata symbol, address owner) public {
        USDT.transferFrom(msg.sender, address(this), OWNER_CONTRIBUTION);
        Fund f = new Fund(name, symbol, owner);
        USDT.approve(address(f), OWNER_CONTRIBUTION);
        f.fund(owner, OWNER_CONTRIBUTION);
        funds.push(address(f));
        issuedERC20(address(FGT)).issue(msg.sender, OWNER_CONTRIBUTION);
    }

    function fund(uint256 _fund, uint256 amount) public {
        USDT.transferFrom(msg.sender, address(this), amount);
        amount = amount - amount * interest / DENOMINATOR;
        USDT.approve(address(funds[_fund]), amount);
        Fund(funds[_fund]).fund(msg.sender, amount);
        issuedERC20(address(FGT)).issue(msg.sender, amount);
    }
}
