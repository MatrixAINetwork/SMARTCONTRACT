/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract CryptoPeopleName {
    address owner;
    mapping(address => string) private nameOfAddress;
  
    function CryptoPeopleName() public{
        owner = msg.sender;
    }
    
    function setName(string name) public {
        nameOfAddress[msg.sender] = name;
    }
    
    function getNameOfAddress(address _address) public view returns(string _name){
        return nameOfAddress[_address];
    }
    
}