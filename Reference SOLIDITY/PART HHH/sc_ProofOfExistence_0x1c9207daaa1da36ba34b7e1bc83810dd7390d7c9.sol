/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract ProofOfExistence {
  mapping (string => uint) private proofs;

  function storeProof(string sha256) {
    proofs[sha256] = block.timestamp;
  }

  function notarize(string sha256) {
    storeProof(sha256);
  }
  

  function checkDocument(string sha256) constant returns (uint) {
    return proofs[sha256];
  }
  
}