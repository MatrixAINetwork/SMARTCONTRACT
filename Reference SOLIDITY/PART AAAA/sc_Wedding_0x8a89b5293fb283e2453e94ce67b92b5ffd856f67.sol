/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Wedding {
    string bride = "Taja";
    string groom = "Matej";
    string date = "29th July 2017";
    
    function getWeddingData() returns (string) {
        return string(abi.encodePacked(bride, " & ", groom, ", happily married on ", date, ". :)"));
    }
    
    function myWishes() returns (string) {
        return "May today be the beginning of a long, happy life together!";
    }
}