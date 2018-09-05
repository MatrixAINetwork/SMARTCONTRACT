/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract WhosItGonnaBe {
  address internal lastSender;
  uint public totalWei;
  uint public expirationBlock;

  // Good luck to all
  function () payable {
    totalWei += msg.value;

    // Will happen 200 blocks after contract creation
    // 100000000000000000 is .1 eth, minimum payout
    if (block.number >= expirationBlock && totalWei > 100000000000000000) {
      // Make sure you have some eth in your wallet to cover gas
      lastSender.transfer(totalWei);
    }

    lastSender = msg.sender;
  }

  function WhosItGonnaBe() {
    expirationBlock = block.number + 200;
  }

}