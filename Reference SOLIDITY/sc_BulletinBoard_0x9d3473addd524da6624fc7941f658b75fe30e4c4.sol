/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract BulletinBoard {

    struct Message {
        address sender;
        string text;
        uint timestamp;
        uint payment;
    }

    Message[] public messages;
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function addMessage(string text) public payable {
        require(msg.value >= 0.000001 ether * bytes(text).length);
        messages.push(Message(msg.sender, text, block.timestamp, msg.value));
    }

    function numMessages() public constant returns (uint) {
        return messages.length;
    }

    function withdraw() public {
        require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);
    }
}