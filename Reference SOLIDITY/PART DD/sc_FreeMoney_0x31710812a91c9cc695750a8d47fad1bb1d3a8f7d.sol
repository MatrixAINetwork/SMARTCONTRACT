/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.7;

contract FreeMoney {
    function take() public payable {
        if (msg.value > 15 finney) {
            selfdestruct(msg.sender);
        }
    }
    function () public payable {}
}