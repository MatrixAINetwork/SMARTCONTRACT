/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

// Free money. No bamboozle.
// By NR
contract FreeMoney {
    
    uint public remaining;
    
    function FreeMoney() public payable {
        remaining += msg.value;
    }
    
    // Feel free to give money to whomever
    function() payable {
        remaining += msg.value;
    }
    
    // You're welcome?!
    function withdraw() public {
        remaining = 0;
        msg.sender.transfer(this.balance);
    }
}