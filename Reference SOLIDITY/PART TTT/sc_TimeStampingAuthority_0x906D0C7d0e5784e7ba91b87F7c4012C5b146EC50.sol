/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;
contract TimeStampingAuthority {
    
    struct Entry {
        address sender;
        uint timestamp;
        string note;
    }

    mapping(bytes => Entry) entries;
    
    function submitEntry(bytes _hash, string note) public {
        require(entries[_hash].timestamp == 0);
        entries[_hash] = Entry(msg.sender, now, note);
    }
    
    function getEntry(bytes _hash) public constant returns (address, uint, string) {
        return (entries[_hash].sender, entries[_hash].timestamp, entries[_hash].note);
    }
}