/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract Hellina{
    address owner;
    function Hellina(){
        owner=msg.sender;
    }
    
    function Buy() payable{
        
    }
    
    function Withdraw(){
        owner.transfer(address(this).balance);
    }
}