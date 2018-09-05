/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;



/// @title Kyber constants contract
contract Utils {
  function testrc(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public pure returns(address) {
    return ecrecover(hash, v, r, s);
  }

  function hash(uint x, uint y, uint z, uint w) public pure returns(bytes32) {
    return sha3(x,y,z,w);
  }
}