/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract HTLC {
  address funder;
  address beneficiary;
  bytes32 public secret;
  bytes32 public hashSecret;
  uint public unlockTime;

  constructor(address beneficiary_, bytes32 hashSecret_, uint lockTime) public {
    beneficiary = beneficiary_;
    hashSecret = hashSecret_;
    unlockTime = now + lockTime * 1 minutes;
  }

  function() public payable {
    if (funder == 0) {
      funder = msg.sender;
    }
    if (msg.sender != funder) {
      revert();
    }
  }

  function resolve(bytes32 secret_) public {
    if (sha256(secret_) != hashSecret) {
      revert();
    }
    secret = secret_;
    beneficiary.transfer(address(this).balance);
  }

  function refund() public {
    if (now < unlockTime) {
      revert();
    }
    funder.transfer(address(this).balance);
  }
}