/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract TerraNullius {
  struct Claim { address claimant; string message; uint block_number; }
  Claim[] public claims;

  function claim(string message) {
    uint index = claims.length;
    claims.length++;
    claims[index] = Claim(msg.sender, message, block.number);
  }

  function number_of_claims() returns(uint result) {
    return claims.length;
  }
}