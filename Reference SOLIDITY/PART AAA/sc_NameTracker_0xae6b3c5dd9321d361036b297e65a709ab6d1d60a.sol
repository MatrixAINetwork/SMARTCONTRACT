/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract NameTracker {
  address creator;
  string public name;

  function NameTracker(string initialName) {
    creator = msg.sender;
    name = initialName;
  }
  
  function update(string newName) {
    if (msg.sender == creator) {
      name = newName;
    }
  }

  function getBlockNumber() constant returns (uint)
  {
    return block.number;
  }

  function kill() {
    if (msg.sender == creator) suicide(creator);
  }
}