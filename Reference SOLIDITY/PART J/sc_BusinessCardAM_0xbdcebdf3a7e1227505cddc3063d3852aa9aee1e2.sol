/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract BusinessCardAM {
    
    mapping (bytes32 => string) variables;
    
    function setVar(string key, string value) {
        variables[sha3(key)] = value;
    }
    
    function getVar(string key) constant returns(string) {
        return variables[sha3(key)];
    }
}