/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract BraggerContract {
    address public richest;
    string public displayString;
    uint public highestBalance;
    
    address owner;
    address[] public participants;
    uint[] public pastValues;

    function BraggerContract() public payable {
        owner = msg.sender;
        highestBalance = 0;
    }

    function becomeRichest(string newString) public payable {
        require(msg.value > 0.002 ether);
        require(msg.sender.balance > highestBalance);
        require(bytes(newString).length < 500);
        
        highestBalance = msg.sender.balance;
        pastValues.push(msg.sender.balance);
        
        richest = msg.sender;
        participants.push(msg.sender);
        
        displayString = newString;
        owner.transfer(msg.value);
    }
}