// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Slunicoin {


    string public name = "Slunicoin";
    string public symbol = "SLC"; 
    uint8 public decimals = 18; 
    uint256 public totalSupply; 


    mapping(address => uint256) public balanceOf;


    event Transfer(address indexed from, address indexed to, uint256 value);


    constructor() {
        uint256 _totalSupply = 20_000_000;
        totalSupply = _totalSupply * (10 ** uint256(decimals));


        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }


    function transferToDAO(address _daoContract) public returns (bool success) {
        require(msg.sender == tx.origin, "No contract calls allowed");
        uint256 amountToTransfer = 19_000_000 * (10 ** uint256(decimals));

        require(balanceOf[msg.sender] >= amountToTransfer, "Saldo insufficiente");
        
        balanceOf[msg.sender] -= amountToTransfer;
        balanceOf[_daoContract] += amountToTransfer;
        emit Transfer(msg.sender, _daoContract, amountToTransfer);
        
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
    require(balanceOf[msg.sender] >= amount, "Insufficient balance");
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
}


}
