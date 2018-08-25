/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract cryptocurrencyClubTest {
    
    uint originalTime;
    
    constructor() public{
        originalTime = now;
    }
    
    
    //prints a birthday message and then becomes impossible to execute after 23 hours
    function BirthdayBoyClickHere() public view returns(string) {
        require(now < originalTime + 23 hours);
        return "Happy Birthday Harrison! I know this contract is noobish but I will get better.";
    }

}