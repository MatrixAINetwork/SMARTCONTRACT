/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract HelloWorld {
    address public owner;
    
    modifier onlyOwner() { require(msg.sender == owner); _; }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function salutaAndonio() public pure returns(bytes32 hw) {
        hw = "HelloWorld";
    }
    
    function killMe() public onlyOwner {
        selfdestruct(owner);
    }
    
}