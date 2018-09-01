/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.1;

contract ForceSendHelper
{
    function ForceSendHelper(address _to) payable
    {
        selfdestruct(_to);
    }
}

contract ForceSend
{
    function send(address _to) payable
    {
        if (_to == 0x0) {
            throw;
        }
        ForceSendHelper s = (new ForceSendHelper).value(msg.value)(_to);
        if (address(s) == 0x0) {
            throw;
        }
    }
    
    function withdraw(address _to)
    {
        if (_to == 0x0) {
            throw;
        }
        if (!_to.send(this.balance)) {
            throw;
        }
    }
}