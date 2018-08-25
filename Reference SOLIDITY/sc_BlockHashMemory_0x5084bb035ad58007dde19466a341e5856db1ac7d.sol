/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract BlockHashMemory
{
    bytes32[] private blockHashes;
    address private curator;
    
    function BlockHashMemory() public
    {
        curator = msg.sender;
    }
    
    function transferCuratorship(address newCurator) external
    {
        require(msg.sender == curator);
        curator = newCurator;
    }
    
    function getBlockHashOrZero(uint256 blockNumber) external view returns (bytes32 blockHashOrZero)
    {
        if (blockNumber >= blockHashes.length) return 0x00;
        return blockHashes[blockNumber];
    }
    
    function curatorWrite(uint256 startBlockNumber, bytes32[] newHashes) external
    {
        require(msg.sender == curator);
        for (uint256 i=0; i<newHashes.length; i++)
        {
            blockHashes[startBlockNumber + i] = newHashes[i];
        }
    }
    
    function volunteerWrite() external returns (uint256 amountWritten)
    {
        amountWritten = 0;
        for (uint256 num=block.number-255; num<block.number; num++)
        {
            if (msg.gas < 20000) break;
            blockHashes[num] = block.blockhash(num);
            amountWritten++;
        }
    }
}