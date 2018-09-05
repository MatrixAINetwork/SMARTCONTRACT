/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract RandomContract {
    
  uint64 _seed = 0;
  address public admin;
  
  event LogRandom(uint64 _randomNumber);
  
  function RandomContract () public {
      admin = msg.sender;
  }
  
  modifier ifAdmin() {
      if(admin != msg.sender){
          revert();
      }else{
          _;
      }
  }
  
  function doRandom(uint64 upper) public ifAdmin returns(uint64 randomNumber) {
    _seed = uint64(keccak256(keccak256(block.blockhash(block.number), _seed), now ));
    uint64 _randomNumber = _seed % upper;
    LogRandom(_randomNumber);
    return _randomNumber;
  }
}