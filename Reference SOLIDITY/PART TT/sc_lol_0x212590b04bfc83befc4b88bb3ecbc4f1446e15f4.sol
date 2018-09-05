/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract lol{
        address private admin;
        function lol() {
            admin = msg.sender;
        }
        modifier onlyowner {if (msg.sender == admin) _  }
function recycle() onlyowner
{
        //Destroy the contract
        selfdestruct(admin);
    
}
}