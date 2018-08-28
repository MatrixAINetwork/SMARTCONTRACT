/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract C
{
    mapping (bytes2 => string) languageCodeToComment;
    function C() public
    {
        languageCodeToComment["ZH"] = "漢字";
    }
    function m() public view returns (string)
    {
        return languageCodeToComment["ZH"];
    }
}