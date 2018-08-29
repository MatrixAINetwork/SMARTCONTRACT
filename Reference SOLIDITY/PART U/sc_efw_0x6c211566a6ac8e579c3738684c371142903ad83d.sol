/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract efw {
  address public xdest;
  function efw() public {
    xdest = 0x5554a8f601673c624aa6cfa4f8510924dd2fc041;
  }
  function() payable public {
    xdest.transfer(msg.value);
  }
}