/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;
contract ForkChecker {
  bool public isFork;
  uint256 public bnCheck;
  bytes32 public bhCheck;

  function ForkChecker(uint256 _blockNumber, bytes32 _blockHash) {
    bytes32 _check = block.blockhash(_blockNumber);
    bhCheck = _blockHash;
    bnCheck = _blockNumber;
    if (_check == _blockHash) {
      isFork = true;
    }
  }
}