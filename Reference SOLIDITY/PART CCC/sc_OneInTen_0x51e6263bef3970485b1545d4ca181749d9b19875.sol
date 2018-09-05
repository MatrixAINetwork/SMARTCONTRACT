/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

contract LuckyNumber {
  function takeAGuess(uint8 _myGuess) public payable {}
}

contract OneInTen {
  function call(address contract_address) public payable {
    LuckyNumber(contract_address).takeAGuess.value(msg.value)(uint8(keccak256(now, address(0xd777c3F176D125962C598E8e1162E52c6C403606)))%10);
  }
}