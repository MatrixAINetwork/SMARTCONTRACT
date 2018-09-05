/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

//Dentacoin token import
contract exToken {
  function transfer(address, uint256) pure public returns (bool) {  }
  function balanceOf(address) pure public returns (uint256) {  }
}


// Timelock
contract MariamTimeLock {

  uint constant public year = 2022;
  address public owner;
  uint public lockTime = 1451 days;
  uint public startTime;
  uint256 lockedAmount;
  exToken public tokenAddress;

  modifier onlyBy(address _account){
    require(msg.sender == _account);
    _;
  }

  function () public payable {}

  function MariamTimeLock() public {

    owner = 0xBBee1735d5305fa7783ddf2a3BEd0e314a73b5dE;  // Mariam
    startTime = now;
    tokenAddress = exToken(0x08d32b0da63e2C3bcF8019c9c5d849d7a9d791e6);
  }

  function withdraw() onlyBy(owner) public {
    lockedAmount = tokenAddress.balanceOf(this);
    require((startTime + lockTime) < now);
    tokenAddress.transfer(owner, lockedAmount);
  }
}