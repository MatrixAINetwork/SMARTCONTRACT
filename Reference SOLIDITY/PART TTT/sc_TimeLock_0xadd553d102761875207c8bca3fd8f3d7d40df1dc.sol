/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.9;

contract TimeLock {
    address user;
    uint balance;
    uint depositTime;
    function () payable {
      if (user!=0)
        throw;
      user = msg.sender;
      balance = msg.value;
      depositTime = block.timestamp;
    }
    function withdraw (){
        if (user==0){
            throw;
        }
        
        if (block.timestamp-depositTime<20*60){
            throw;
        }
        
        if(!user.send(balance))
            throw;
        
        delete user;
        
        
        
    }
}