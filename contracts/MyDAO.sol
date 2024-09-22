// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

import "./votingContract.sol";

contract DAOContract {

    address public owner;
    IERC20 public slunicoinToken;
    uint256 public soldShares;
    uint256 public sharePrice = 1 ether;
    bool public isSaleActive = true;

    mapping(address => uint256) public sharesOwned;
    mapping(address => bool) public isMember;

    DAOVoting public votingContract;

    event SharesPurchased(address indexed buyer, uint256 shares, uint256 tokensRewarded);
    event SaleStateChanged(bool newState);
    event NewMemberAdded(address indexed member);
    event FundsDeposited(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only the owner can perform this action");
        _;
    }

    modifier onlyMembers(){
        require(isMember[msg.sender], "only members can perform this action, to become a member you need to buy a DAO share");
        _;
    }

    constructor() {
        owner = msg.sender;
        isMember[owner] = true;
        sharesOwned[owner] = 1000000;
        emit NewMemberAdded(owner);
    }

    function connectTokenContract(address _slunicoinToken) public onlyOwner {
        slunicoinToken = IERC20(_slunicoinToken);
    }

    function connectVotingContract(address _votingContract) public onlyOwner {
        votingContract = DAOVoting(_votingContract);
    }

    function buyShares(uint256 _numShares) public payable {
        require(isSaleActive, "We are not selling shares right now, please retry later");
        uint256 totalCost = _numShares * sharePrice;
        require(msg.value == totalCost, "Incorrect payment amount, the change is 1 ETH x shares, example: 5 shares = 5 ETH");
        sharesOwned[msg.sender] += _numShares;
        soldShares += _numShares;
        uint256 tokensToReward = _numShares * (10 ** 18);
        require(slunicoinToken.balanceOf(address(this)) >= tokensToReward, "Not enough tokens for rewards");
        slunicoinToken.transfer(msg.sender, tokensToReward);
        emit SharesPurchased(msg.sender, _numShares, tokensToReward);

        if (!isMember[msg.sender]) {
            isMember[msg.sender] = true;
            emit NewMemberAdded(msg.sender);
        }
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function toggleSaleState() public onlyOwner {
        isSaleActive = !isSaleActive;
        emit SaleStateChanged(isSaleActive);
    }

    function checkTokenBalance() public view returns (uint256) {
        return slunicoinToken.balanceOf(address(this));
    }

    function checkContractEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function checkUserSlcTokenBalance(address _user) public view returns (uint256) {
        return slunicoinToken.balanceOf(_user);
    }
}
