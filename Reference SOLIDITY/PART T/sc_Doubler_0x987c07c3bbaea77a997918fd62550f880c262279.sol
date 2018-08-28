/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract Doubler
{
    address owner;

    function Doubler() payable
    {
        owner = msg.sender;
    }
    
    function() payable{
        if (msg.value<0.2 ether)
            revert();
        if (!msg.sender.call(msg.value*2))
            revert();
    }
    
    function kill()
    {
        if (msg.sender==owner)
            suicide(owner);
    }
}