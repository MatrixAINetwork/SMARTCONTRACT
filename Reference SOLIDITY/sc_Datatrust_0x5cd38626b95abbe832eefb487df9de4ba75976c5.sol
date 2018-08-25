/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

/**
 * @title Datatrust Anchoring system
 * @author Blockchain Partner
 * @author https://blockchainpartner.fr
 */
contract Datatrust {

    // Mapping from Merkle tree root hashes to their anchored state
    mapping (bytes32 => bool) public anchors;

    // Event emitted when saving a new anchor
    event NewAnchor(bytes32 merkleRoot);
    
    /**
     * @dev Save a new anchor for a given Merkle tree root hash
     * @param _merkleRoot bytes32 hash to anchor
     */
    function saveNewAnchor(bytes32 _merkleRoot) public {
        anchors[_merkleRoot] = true;
        emit NewAnchor(_merkleRoot);
    }
}