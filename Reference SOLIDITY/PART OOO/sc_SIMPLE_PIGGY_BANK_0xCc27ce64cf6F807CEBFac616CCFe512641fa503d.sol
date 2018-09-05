/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract SIMPLE_PIGGY_BANK
{
    address creator = msg.sender;
    
    mapping (address => uint) public Bal;
    
    uint public MinSum = 1 ether;
    
    function() 
    public 
    payable
    {
        Bal[msg.sender]+=msg.value;
    }  
    
    function Collect(uint _am)
    public
    payable
    {
        if(Bal[msg.sender]>=MinSum && _am<=Bal[msg.sender])
        {
            msg.sender.call.value(_am);
            Bal[msg.sender]-=_am;
        }
    }
    
    function Break()
    public
    payable
    {
        if(msg.sender==creator && this.balance>= MinSum)
        {
            selfdestruct(msg.sender);
        }
    }
}