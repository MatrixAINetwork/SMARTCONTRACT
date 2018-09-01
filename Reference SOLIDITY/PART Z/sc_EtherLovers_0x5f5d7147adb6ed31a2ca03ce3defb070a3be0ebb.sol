/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.1;

contract EtherLovers {

  event LoversAdded(string lover1, string lover2);

  uint constant requiredFee = 100 finney;

  address private owner;

  function EtherLovers() public {
    owner = msg.sender;
  }

  modifier isOwner() { 
    if (msg.sender != owner) {
      throw;       
    }
    _;
  }

  function declareLove(string lover1, string lover2) public payable {
    if (msg.value >= requiredFee) {
      LoversAdded(lover1, lover2);
    } else {
      throw;
    }
  }

  function collectFees() public isOwner() {
    msg.sender.send(this.balance);
  }

}