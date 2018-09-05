/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract MultiSender {
    function multiSend(uint256 amount, address[] addresses) public returns (bool) {
        for (uint i = 0; i < addresses.length; i++) {
            addresses[i].transfer(amount);
        }
    }

    function () public payable {
        
    }
}