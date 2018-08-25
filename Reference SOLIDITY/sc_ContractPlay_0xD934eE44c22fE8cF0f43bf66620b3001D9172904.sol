/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract ContractPlay {
    address owner;
    uint16 numCalled;
    
    modifier onlyOwner {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
    
    function ContractPlay() {
        owner = msg.sender;
    }
    
    function remove() onlyOwner {
        selfdestruct(owner);
    }
    
    function addFunds() payable {
        numCalled++;
    }
    
    function getNumCalled() returns (uint16) {
        return numCalled;
    }
    
    function() {
        throw;
    }
}