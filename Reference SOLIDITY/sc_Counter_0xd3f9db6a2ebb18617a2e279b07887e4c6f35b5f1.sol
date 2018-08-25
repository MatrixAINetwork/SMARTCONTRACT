/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract Counter {
    
    uint total;
  
    function add(uint num) public {
        total = total + num;
    }
    
    function subtract(uint num) public {
        total = total - num;
    }
    
    function double() public {
        total = total * 2;
    }
  
}