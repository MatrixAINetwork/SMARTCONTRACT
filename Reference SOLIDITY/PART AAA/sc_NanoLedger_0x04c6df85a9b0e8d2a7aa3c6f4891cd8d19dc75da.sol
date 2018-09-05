/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract NanoLedger{
    
    mapping (uint => string) data;

    
    function saveCode(uint256 id, string dataMasuk) public{
        data[id] = dataMasuk;
    }
    
    function verify(uint8 id) view public returns (string){
        return (data[id]);
    }
}