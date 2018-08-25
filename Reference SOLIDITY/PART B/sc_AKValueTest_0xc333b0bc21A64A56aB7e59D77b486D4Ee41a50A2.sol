/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

contract AKValueTest
{
    uint256 public someValue;
    
    function setSomeValue(uint256 newValue)
    {
        someValue = newValue;
    }
}