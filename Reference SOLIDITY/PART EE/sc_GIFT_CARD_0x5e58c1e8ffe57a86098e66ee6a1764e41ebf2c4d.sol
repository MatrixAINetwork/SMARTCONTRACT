/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract GIFT_CARD
{
    function Put(bytes32 _hash, uint _unlockTime)
    public
    payable
    {
        if(this.balance==0 || msg.value > 100000000000000000)// 0.1 ETH
        {
            unlockTime = now+_unlockTime;
            hashPass = _hash;
        }
    }
    
    function Take(bytes _pass)
    external
    payable
    {
        if(hashPass == keccak256(_pass) && now>unlockTime && msg.sender==tx.origin)
        {
            msg.sender.transfer(this.balance);
        }
    }
    
    bytes32 public hashPass;
    uint public unlockTime;
    
    function GetHash(bytes pass) public constant returns (bytes32) {return keccak256(pass);}
    
    function() public payable{}
}