/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/// davidphan.eth

pragma solidity ^0.4.0;
contract InternetWall {

    address owner;

    struct Message{
        string message;
        address from;
        uint timestamp;
    }
    
    Message[10] messages;
    uint messagesIndex;
    
    uint postedMessages;


    function InternetWall() {
        owner = msg.sender;
        messagesIndex = 0;
        postedMessages = 0;
    }
    
    function addMessage(string msgStr) payable {
        Message memory newMsg;
        newMsg.message = msgStr;
        newMsg.from = msg.sender;
        newMsg.timestamp = block.timestamp;
        messages[messagesIndex] = newMsg;
        messagesIndex += 1;
        messagesIndex = messagesIndex % 10;
        postedMessages++;
    }
    
    function getMessagesCount() constant returns (uint) {
        return messagesIndex;
    }
    
    function getMessage(uint index) constant returns(string) {
        assert(index < messagesIndex);
        return messages[index].message;
    }
    function getMessageSender(uint index) constant returns(address) {
        assert(index < messagesIndex);
        return messages[index].from;
    }
    function getMessageTimestamp(uint index) constant returns(uint) {
        assert(index < messagesIndex);
        return messages[index].timestamp;
    }
    
    function closeWall(){
        assert(msg.sender == owner);
        suicide(owner);
    }
    
}