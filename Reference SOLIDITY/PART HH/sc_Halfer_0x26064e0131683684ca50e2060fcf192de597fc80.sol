/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract Halfer{
    address owner; 
    constructor() public {
        owner = msg.sender;
    }
    
    function() public payable{
        owner.transfer(msg.value/2);
        msg.sender.transfer(address(this).balance);
    }
}