pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Fund is ERC20 {
    enum statuses {CrowdLoan, Operation, Liquidation, Cancelled}
    statuses status = statuses.CrowdLoan;

    address immutable owner;
    IERC20 constant USDT = IERC20(0x36AA5e2fAfE33bF95344165fa0FCc33b9e8a4886);

    struct asset {
        uint256 balance;
        uint256 index;
    }
    mapping(address => asset) private assetsMap;
    IERC20[] assetsArr;

    IERC20[] proposalAssets;
    uint256 proposalHash;
    uint256 proposalLock;
    uint256 LOCK_DURATION = 5760;

    uint CrowdLoanMinAmount = 300_000;
    uint immutable CrowdLoanLock;

    uint256 DENOMINATOR = 1e6;
    uint256 rate = 1e6;

    constructor(string memory name, string memory symbol, address _owner) ERC20(name, symbol) {
        owner = _owner;
        CrowdLoanLock = block.number + LOCK_DURATION;
    }
    function decimals() public override view returns (uint8) {
        return 6;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function operate() public {
        require(status == statuses.CrowdLoan);
        require(block.number >= CrowdLoanLock);
        if (USDT.balanceOf(address(this)) >= CrowdLoanMinAmount) {
            status = statuses.Operation;
        } else {
            status = statuses.Cancelled;
        }
    }

    function fund(address addr, uint256 amount) public {
        USDT.transferFrom(msg.sender, address(this), amount);
        if (status == statuses.CrowdLoan) {
            _mint(addr, amount);
        } else if(status == statuses.Operation) {
            _mint(addr, amount * rate / DENOMINATOR);
        } else {
            revert();
        }
    }

    function withdraw(uint256 amount) public {
        require(status == statuses.Operation || status == statuses.Cancelled);
        _burn(msg.sender, amount);
        USDT.transfer(msg.sender, amount);
    }

    function setRate(uint _rate) public onlyOwner { // change to oracle call
        rate = _rate;
    }

    function propose(IERC20[] calldata assets, uint256 hash) public onlyOwner() {
        proposalAssets = assets;
        proposalHash = hash;
        proposalLock = block.number + LOCK_DURATION;
    }

    function proposalExecute(bytes calldata _calldata) public onlyOwner() {
        require(proposalHash == uint256(keccak256(_calldata)));
        // here is executing calls from _calldata
        for (uint i=0; i<proposalAssets.length; i++) {
            uint balance = IERC20(proposalAssets[i]).balanceOf(address(this));
            asset storage _asset = assetsMap[address(proposalAssets[i])];
            if (balance == 0 && _asset.balance > 0) {
                assetsArr[_asset.index] = assetsArr[assetsArr.length-1];
                assetsMap[address(assetsArr[_asset.index])].index = _asset.index;
                assetsArr.pop();
                delete assetsMap[address(proposalAssets[i])];
            } else {
                if (_asset.balance == 0) {
                    assetsArr.push(proposalAssets[i]);
                    assetsMap[address(proposalAssets[i])].index = assetsArr.length-1;
                }
                assetsMap[address(proposalAssets[i])].balance = balance;
            }
        }
    }
}
