/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.8;
library ArrayLib{
  function findAddress(address a, address[] storage arry) returns (int){
    for (uint i = 0 ; i < arry.length ; i++){
      if(arry[i] == a){return int(i);}
    }
    return -1;
  }
  function removeAddress(uint i, address[] storage arry){
    uint lengthMinusOne = arry.length - 1;
    arry[i] = arry[lengthMinusOne];
    delete arry[lengthMinusOne];
    arry.length = lengthMinusOne;
  }
}