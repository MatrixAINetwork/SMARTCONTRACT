/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Metadata {
    mapping (address => mapping (address => mapping (string => string))) metadata;

    function put(address _namespace, string _key, string _value) public {
        metadata[_namespace][msg.sender][_key] = _value;
    }

    function get(address _namespace, address _ownerAddress, string _key) public constant returns (string) {
        return metadata[_namespace][_ownerAddress][_key];
    }
}