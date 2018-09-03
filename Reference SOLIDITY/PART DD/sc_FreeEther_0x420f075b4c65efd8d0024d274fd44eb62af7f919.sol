/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.2;

contract FreeEther {
    
    // This contract has free Ether for anyone to withdraw. This is just a fun test to see if anyone looks at this. If there's any Ether in this contract, go ahead and take it! Just call the gimmeEther() function. If there's no Ether in this contract, someone's already taken it.
    
    // Visit ETH93.com
    
    function() payable {
        // We will deposit 0.1 Ether to the contract for anyone to claim!
    }
    
    function gimmeEtherr() {
        msg.sender.transfer(this.balance);
    }
    
}