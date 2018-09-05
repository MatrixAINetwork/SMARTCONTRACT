/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

/*
* Simply returns keccak256 of your eth address
*/

contract kektest {
  
  
  
  function kek(address) public view returns(bytes32) {
      
      address _ethaddy = msg.sender;
        return (keccak256(_ethaddy));
  }  
    
}