/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

contract dubbel {
    address public previousSender;
    uint public price = 0.001 ether;
    
    function() public payable {
            require(msg.value == price);
            previousSender.transfer(msg.value);
            price *= 2;
            previousSender = msg.sender;
    }
}