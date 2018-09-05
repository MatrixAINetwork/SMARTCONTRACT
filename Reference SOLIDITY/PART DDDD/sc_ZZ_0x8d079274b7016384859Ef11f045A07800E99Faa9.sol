/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract ZZ
{
    address creator;
    function ZZ() public payable {
        creator = msg.sender;
    }

    function getMessage() public pure returns (bytes32) {
        return "ZZ loves mandy.";
    }
  
    function e() public { 
        if (msg.sender == creator)
            selfdestruct(creator);
    }
}