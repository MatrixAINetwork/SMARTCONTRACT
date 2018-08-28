/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.15;

contract DocumentSigner {
    mapping(string => address[]) signatureMap;
    
    function sign(string _documentHash) public {
        signatureMap[_documentHash].push(msg.sender);
    }

    function getSignatureAtIndex(string _documentHash, uint _index) public constant returns (address) {
    	return signatureMap[_documentHash][_index];
    }

    function getSignatures(string _documentHash) public constant returns (address[]) {
    	return signatureMap[_documentHash];
    }
}