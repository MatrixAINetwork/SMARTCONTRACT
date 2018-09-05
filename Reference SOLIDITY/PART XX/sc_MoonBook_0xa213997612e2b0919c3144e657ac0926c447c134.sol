/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.6;

contract MoonBook { 
  function MoonBook() {}

  bytes[] terms;

  function put(bytes term) {
    terms.push(term);
  }

  function get(uint256 index) constant returns (bytes) {
    return terms[index];
  }
}