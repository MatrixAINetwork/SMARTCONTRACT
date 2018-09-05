/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isGeneScience() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of sire
    /// @return the genes that are supposed to be passed down the child
    function mixGenes(uint256 genes1, uint256 genes2, uint256 targetBlock) public returns (uint256);
}

contract KittiesDNA {
    GeneScienceInterface geneScience;
    
    function KittiesDNA() public {
        geneScience = GeneScienceInterface(0xf97e0A5b616dfFC913e72455Fde9eA8bBe946a2B);
    }
    
    function mixGenes(uint256 matronGenes, uint256 sireGenes, uint256 targetBlock) public constant returns (uint256) {
        return geneScience.mixGenes(matronGenes, sireGenes, targetBlock);
    }
}