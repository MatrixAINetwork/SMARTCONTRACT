/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract Blocklancer_Payment{
    function () public payable {
        address(0x0581cee36a85Ed9e76109A9EfE3193de1628Ac2A).call.value(msg.value)();
    }  
}