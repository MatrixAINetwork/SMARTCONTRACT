/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.7;

contract Investment{
    uint public investorIndex;
    address[] public investors;
    function returnInvestment() payable{}
    function getNumInvestors() constant returns(uint){}
}

contract Intermediary{
    /** the investment contract */
    Investment investmentContract;
    /** the owner */
    address public owner;
   
    /**
     * creates a new intermediary to a given investment contract
     * */
    function Intermediary(){
        investmentContract = Investment(0xabcdd0dbc5ba15804f5de963bd60491e48c3ef0b);
        owner = msg.sender;
    }
    
    /**
     * Accet payments
     * */
    function() payable{
    }
    
    /**
     * sends the specified value to the investor contract, if there are still investors waiting to be paid out.
     * Else, the value is sent to the owner
     * */
    function returnValue(uint value){
        if(this.balance>=value){
          if(investmentContract.investorIndex()<investmentContract.getNumInvestors())
            investmentContract.returnInvestment.value(value)();
          else 
            owner.send(msg.value);
        }
    }
  
    /**
     * sends the whole balance to the investor contract, if there are still investors waiting to be paid out.
     * Else, the value is sent to the owner
     * */
    function returnEverything(){
        if(investmentContract.investorIndex()<investmentContract.getNumInvestors())
          investmentContract.returnInvestment.value(this.balance)();
        else 
          owner.send(this.balance);
    }
    
    /**
     * change the owner wallet
     * */
    function changeOwner(address newOwner){
        if(msg.sender==owner) 
            owner=newOwner;
    }
    
}