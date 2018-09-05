/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;

contract TimeBasedContract
{
    function TimeBasedContract() public {
    }

    function() public payable {
        uint minutesTime = (now / 60) % 60;
        require(((minutesTime/10)*10) == minutesTime);
    }
}