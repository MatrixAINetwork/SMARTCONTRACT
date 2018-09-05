/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract OriginalMyDocAuthenticity {
    
  mapping (string => uint) private authenticity;

  function storeAuthenticity(string sha256) {
    if (checkAuthenticity(sha256) == 0) {
        authenticity[sha256] = now;
    }   
  }

  function checkAuthenticity(string sha256) constant returns (uint) {
    return authenticity[sha256];
  }
}