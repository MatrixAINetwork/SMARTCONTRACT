/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract WhiteList {
    
    mapping (address => bool)   public  whiteList;
    
    address  public  owner;
    
    function WhiteList() public {
        owner = msg.sender;
        whiteList[owner] = true;
    }
    
    function addToWhiteList(address [] _addresses) public {
        require(msg.sender == owner);
        
        for (uint i = 0; i < _addresses.length; i++) {
            whiteList[_addresses[i]] = true;
        }
    }
    
    function removeFromWhiteList(address [] _addresses) public {
        require (msg.sender == owner);
        for (uint i = 0; i < _addresses.length; i++) {
            whiteList[_addresses[i]] = false;
        }
    }
}