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
    address owner;
    
    address[] public recipients;
    
    function SendToMany() public
    {
        owner = msg.sender;
    }
    
    function setRecipients(address[] newRecipientsList) public
    {
        require(msg.sender == owner);
        
        recipients = newRecipientsList;
    }
    
    function addRecipient(address newRecipient) public
    {
        recipients.push(newRecipient);
    }
    
    function sendToAll(uint256 amountPerRecipient) payable public
    {
        for (uint256 i=0; i<recipients.length; i++)
        {
            recipients[i].transfer(amountPerRecipient);
        }
    }
}