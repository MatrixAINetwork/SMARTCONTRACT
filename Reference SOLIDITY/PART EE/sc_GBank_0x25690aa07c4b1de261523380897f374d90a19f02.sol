/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract GBank {

    address creator;

    mapping (address => uint) balances;

    function GBank(uint startAmount) {
        balances[msg.sender] = startAmount;
        creator = msg.sender;
    }

    function getBalance(address a) constant returns (uint) {
        return balances[a];
    }

    function transfer(address to, uint amount) {

        // Don't allow sending to self
        if (msg.sender == to) {
            throw;
        }

        // Check if sender has sufficient balance to send
        if (amount > balances[msg.sender]) {
            throw;
        }

        balances[msg.sender] -= amount;
        balances[to] += amount;
    }
}