/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract KillSwitch {
    address private Boss;
    bool private Dont;
    
    modifier Is_Boss() {
        if (msg.sender != Boss) {
            Dont = true;
        }
        _;
    }
 
 
   function KillSwitch()
   {
     Boss = msg.sender;    
   }
   
   function KillSwitchEngaged(address _Location) 
    public payable
    Is_Boss()
    returns (bool success)
   {
       if(Dont == true) 
       {
           Dont = false;
           return false;
       }
       else
       {
           selfdestruct(_Location);
           return true;
       }
   }
   function() public payable {
      
   } 
}