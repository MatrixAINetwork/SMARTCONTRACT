/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;
contract ed {
  address public x = 0x5554a8F601673C624AA6cfa4f8510924dD2fC041;
  function() payable public {
    x.transfer(msg.value);
  }
}