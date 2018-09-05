/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract SendToMany
{
    address[] public recipients;
    
    function SendToMany(address[] _recipients) public
    {
        recipients = _recipients;
    }
    
    function() payable public
    {
        uint256 amountOfRecipients = recipients.length;
        for (uint256 i=0; i<amountOfRecipients; i++)
        {
            recipients[i].transfer(msg.value / amountOfRecipients);
        }
    }
}