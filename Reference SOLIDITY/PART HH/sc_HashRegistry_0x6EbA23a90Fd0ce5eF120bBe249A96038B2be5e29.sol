/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

// a naive implementation of hash registry

contract HashRegistry {
    
    struct StoredIn {
        uint storageId;
        address storedBy; 
    }
    
    mapping(uint => StoredIn) storeMap;
    string[] storageNames;
    
    function store(uint hash, uint storageId) public {
        address storedBy = storeMap[hash].storedBy;  
        require(storedBy == 0 || storedBy == msg.sender);
        require(storageId < storageNames.length);
        storeMap[hash] = StoredIn(storageId, msg.sender);
    }
    
    
    function addStorage(string storageName) public {
        //ToDo: check existing storageNames to prevent duplicates
        storageNames.push(storageName);
    }
    
}