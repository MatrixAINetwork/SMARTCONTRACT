/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

/// @title BlockchainCuties lottery
/// @author https://BlockChainArchitect.io
contract Lottery
{
    event Bid(address sender);

    function bid() public
    {
        emit Bid(msg.sender);
    }
}