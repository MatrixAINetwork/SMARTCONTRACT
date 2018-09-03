/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

contract FunGame 
{
    address owner;
    modifier OnlyOwner() 
    {
        if (msg.sender == owner) 
        _;
    }
    function FunGame()
    {
        owner = msg.sender;
    }
    function TakeMoney() OnlyOwner
    {
        owner.transfer(this.balance);
    }
    function ChangeOwner(address NewOwner) OnlyOwner 
    {
        owner = NewOwner;
    }
}