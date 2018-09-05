/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

// File: contracts/LegalDocument.sol

/**
 * @title LegalDocument
 * @dev Basic version of a legal contract, allowing the owner to save a legal document and associate the governing law
 * contact information.
 */
contract LegalDocument {

    string public documentIPFSHash;
    string public governingLaw;

    /**
      * @dev Constructs a document
      * @param ipfsHash The IPFS hash to the human readable legal contract.
      * @param law The governing law
      */
    constructor(string ipfsHash, string law) public {
        documentIPFSHash = ipfsHash;
        governingLaw = law;
    }

}