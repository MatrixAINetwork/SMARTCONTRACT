/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract BountyHunt {
  mapping(address => uint) public bountyAmount;
  uint public totalBountyAmount;

  modifier preventTheft {
    _;  
    if (this.balance < totalBountyAmount) throw;
  }

  function grantBounty(address beneficiary, uint amount) payable preventTheft {
    bountyAmount[beneficiary] += amount;
    totalBountyAmount += amount;
  }

  function claimBounty() preventTheft {
    uint balance = bountyAmount[msg.sender];
    if (msg.sender.call.value(balance)()) {
      totalBountyAmount -= balance;
      bountyAmount[msg.sender] = 0;
    }   
  }

  function transferBounty(address to, uint value) preventTheft {
    if (bountyAmount[msg.sender] >= value) {
      bountyAmount[to] += value;
      bountyAmount[msg.sender] -= value;
    }   
  }
}