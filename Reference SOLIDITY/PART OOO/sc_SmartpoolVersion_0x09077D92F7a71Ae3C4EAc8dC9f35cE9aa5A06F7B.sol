/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;

contract SmartpoolVersion {
    address    public poolContract;
    bytes32    public clientVersion;
    
    mapping (address=>bool) owners;
    
    function SmartpoolVersion( address[3] _owners ) {
        owners[_owners[0]] = true;
        owners[_owners[1]] = true;
        owners[_owners[2]] = true;        
    }
    
    function updatePoolContract( address newAddress ) {
        if( ! owners[msg.sender] ) throw;
        
        poolContract = newAddress;
    }
    
    function updateClientVersion( bytes32 version ) {
        if( ! owners[msg.sender] ) throw;
        
        clientVersion = version;
    }
}