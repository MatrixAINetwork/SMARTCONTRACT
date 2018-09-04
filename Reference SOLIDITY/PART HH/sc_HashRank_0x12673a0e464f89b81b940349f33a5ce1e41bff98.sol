/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

// This allows stakeholders to approve an IPFS hash, and can return the
// weighted sum of ether that approved it. Used for rank & anti-phishing.

contract HashRank {
  // Who approved this hash
  mapping (bytes => address[]) approved;
  
  // Approves a hash
  function approve(bytes doc) public {
    approved[doc].push(msg.sender);
  }
  
  // Computes the rank (eth-weighted sum of approvals) of the document at index
  function rankOf(bytes doc) public constant returns (uint256) {
    uint256 rank = 0;
    
    uint256 len = approved[doc].length;
    for (uint256 i = 0; i < len; ++i) { 
      address voter = approved[doc][i];
        
      // Checks if voter already voted
      // FIXME: this would be less stupid with an in-memory map, but how?
      bool voted = false;
      for (uint256 j = 0; j < i; ++j) {
        voted = voted || approved[doc][j] == voter;
      }
      
      if (!voted) {
        rank += voter.balance;
      }
    }
    return rank;
  }
}