/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract Random {
  uint64 _seed = 0;

  // return a pseudo random number between lower and upper bounds
  // given the number of previous blocks it should hash.
  function random(uint64 upper) public returns (uint64 randomNumber) {
    _seed = uint64(sha3(sha3(block.blockhash(block.number), _seed), now));
    return _seed % upper;
  }
}