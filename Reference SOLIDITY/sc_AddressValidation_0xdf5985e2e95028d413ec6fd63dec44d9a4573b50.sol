/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract AddressValidation {
    string public name = "AddressValidation";
    mapping (address => bytes32) public keyValidations;
    event ValidateKey(address indexed account, bytes32 indexed message);

    function validateKey(bytes32 _message) public {
        keyValidations[msg.sender] = _message;
        ValidateKey(msg.sender, _message);
    }
}