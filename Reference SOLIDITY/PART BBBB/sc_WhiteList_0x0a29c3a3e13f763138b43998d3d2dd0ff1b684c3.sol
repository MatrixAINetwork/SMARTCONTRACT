/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

// File: _contracts/WhiteList.sol

contract WhiteList {

  function canTransfer(address _from, address _to)
  public
  returns (bool) {
    return true;
  }
}