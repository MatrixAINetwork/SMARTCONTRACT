/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.10;

contract ReverseBugBounty {
    address owner;

    function () payable {
        revert; 
    }

    function ReverseBugBounty(){
        owner = msg.sender;
    }
    
    function destroy(){
        selfdestruct(owner);
    }
}