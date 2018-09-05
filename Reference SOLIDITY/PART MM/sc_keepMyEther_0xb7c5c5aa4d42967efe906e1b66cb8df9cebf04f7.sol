/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

/*
!!! THIS CONTRACT IS EXPLOITABLE AND FOR EDUCATIONAL PURPOSES ONLY !!!

This smart contract allows a user to (insecurely) store funds
in this smart contract and withdraw them at any later point in time
*/

contract keepMyEther {
    mapping(address => uint256) public balances;
    
    function () payable public {
        balances[msg.sender] += msg.value;
    }
    
    function withdraw() public {
        msg.sender.call.value(balances[msg.sender])();
        balances[msg.sender] = 0;
    }
}