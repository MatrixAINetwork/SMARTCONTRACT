/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.22;

contract WETH {
  mapping (address => uint256) balances;

  constructor() public {
    balances[msg.sender] = 10000;
  }

  function transfer(address to, uint256 amount) public {
    require(amount <= balances[msg.sender]);
    balances[msg.sender] -= amount;
    balances[to] += amount;
  }

  function mint() payable public {
    balances[msg.sender] += msg.value;
  }

  function burn(uint256 amount) public {
    require(amount <= balances[msg.sender]);
    balances[msg.sender] -= amount;
    msg.sender.transfer(amount);
  }
}