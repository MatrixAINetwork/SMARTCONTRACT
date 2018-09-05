/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract UserName {

  mapping (address => mapping (uint => string)) public userDict;

  event OnNameChanged(uint indexed _guid, address indexed _who, string _newName);

  function changeName(uint _guid, string _newName) public {
    userDict[msg.sender][_guid] = _newName;
    OnNameChanged(_guid, msg.sender, _newName);
  }

  function nameOf(uint _guid, address _who) view public returns (string) {
    return userDict[_who][_guid];
  }
}