/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract EtherealNotes {
    
    string public constant CONTRACT_NAME = "EtherealNotes";
    string public constant CONTRACT_VERSION = "A";
    string public constant QUOTE = "'When you stare into the abyss the abyss stares back at you.' -Friedrich Nietzsche";
    
    event Note(address sender,string indexed note);
    function SubmitNote(string note) public{
        Note(msg.sender, note);
    }
}