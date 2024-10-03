// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Slunicoin {

    string public name = "Slunicoin";
    string public symbol = "SLC"; 
    uint8 public decimals = 18; 
    uint256 public totalSupply; 

    mapping(address => uint256) public balanceOf;
    mapping(address => address) public allowancemap;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender);

    constructor() {
        uint256 _totalSupply = 20_000_000;
        totalSupply = _totalSupply * (10 ** uint256(decimals));

        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Approve another address to spend tokens on my beahlf 
    function approve(address spender) public returns (bool) {
        allowancemap[msg.sender] = spender;  
        emit Approval(msg.sender, spender);
        return true;
    }

    //pass the spender address on "sender" and any recipient addr on "recipient", if you are authorized by the sender you can transact for him
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowancemap[sender] == msg.sender, "Not authorized to spend on behalf of this account");

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Check authorization of an addr
    function allowance(address owner, address spender) public view returns (bool) {
        return allowancemap[owner] == spender;
    }
}
