/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.8;

contract HashMap {
    mapping(bytes32 => bytes) map;
    
    function set(bytes _data) public {
        map[keccak256(_data)] = _data;
    }
    
    function get(bytes32 _hash) public constant returns (bytes data) {
        return map[_hash];
    }
}