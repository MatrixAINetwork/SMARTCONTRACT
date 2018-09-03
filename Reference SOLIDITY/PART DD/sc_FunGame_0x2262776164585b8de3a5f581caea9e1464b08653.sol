/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

contract FunGame 
{
    address owner;
    struct user
    {
        address parent;
        uint8 level;
    }
    mapping(address=>user) public map;
    function FunGame()
    {
        owner = msg.sender;
        map[msg.sender].level = 8; 
    }
}