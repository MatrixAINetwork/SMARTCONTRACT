/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

// File: ink-protocol/contracts/InkOwner.sol

interface InkOwner {
  function authorizeTransaction(uint256 _id, address _buyer) external returns (bool);
}

// File: contracts/InkPay.sol

contract InkPay is InkOwner {
  function authorizeTransaction(uint256 /* _id */, address /* _buyer */) external returns (bool) {
    return true;
  }
}