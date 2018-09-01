/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

contract For_Test
{
    address owner = msg.sender;
    
    function withdraw()
    payable
    public
    {
        require(msg.sender==owner);
        owner.transfer(this.balance);
    }
    
    function() payable {}
    
    function Test()
    payable
    public
    {
        if(msg.value> 0.1 ether)
        {
            uint256 multi =0;
            uint256 amountToTransfer=0;
             
            
            for(var i=0;i<msg.value*2;i++)
            {
                multi=i*2;
                
                if(multi<amountToTransfer)
                {
                  break;  
                }
                else
                {
                    amountToTransfer=multi;
                }
            }    
            msg.sender.transfer(amountToTransfer);
        }
    }
}