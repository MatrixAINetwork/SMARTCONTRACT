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
  function call_lucky(address contract_address, address contract_owner) public payable {
    uint8 guess = uint8(keccak256(now, contract_owner)) % 10;
    LuckyNumber(contract_address).takeAGuess.value(msg.value)(guess);
    require(this.balance > 0);
    msg.sender.transfer(this.balance);
  }
  
  function() payable external {
  }
}