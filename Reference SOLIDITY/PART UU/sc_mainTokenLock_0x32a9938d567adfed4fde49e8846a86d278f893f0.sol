/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

interface token {
    function transfer(address receiver, uint amount);
}

contract Ownable {
    
  address public owner;


  function Ownable() {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}
 contract mainTokenLock is Ownable {
    
  token public tokenLocked;
  
  function retrieveTokens(uint _value) onlyOwner {
    require(_value > 0);
    if (now <= 1537876800)
    revert();
	tokenLocked = token(0xC2eAF62D3DB7c960d8Bb5D2D6a800Dd817C8E596);
    tokenLocked.transfer(owner, _value);
  }
}