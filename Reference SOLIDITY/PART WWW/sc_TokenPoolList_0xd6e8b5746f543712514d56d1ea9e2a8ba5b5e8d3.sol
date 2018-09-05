/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

contract TokenPoolList {
  address[] public list;

  event Added(address x);

  function add(address x) {
    list.push(x);
    Added(x);
  }

  function getCount() public constant returns(uint) {
    return list.length;
  }

  function getAddress(uint index) public constant returns(address) {
    return list[index];
  }
}