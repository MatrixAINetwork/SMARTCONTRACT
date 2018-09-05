/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;
contract MessagingContract {
    struct Message {
        string data;
        string senderName;
    }
    struct Feed {
        Message[] messages;
        string name;
    }
    event FeedCreated(uint256 feedId,string feedName);
    event MessageSent(uint256 feedId, uint256 msgId,string msg,string sender);
    Feed[] feeds;
    /// Create a new ballot with $(_numProposals) different proposals.
    function MessagingContract(string firstFeedName) public {
        newFeed(firstFeedName);
    }
    function newFeed(string name) public returns (uint256){
        feeds[feeds.length++].name=name;
        FeedCreated(feeds.length-1,name);
        return feeds.length-1;
    }
    function feedMessage(uint256 feedId,string data,string alias) public{
        feeds[feedId].messages[feeds[feedId].messages.length++]=Message(data,alias);
        MessageSent(feedId,feeds[feedId].messages.length-1,data,alias);
    }
}