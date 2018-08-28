/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

contract DiscordLink {
    mapping (bytes => address) private linkage;
    
    function setLink(bytes didHash) {
        require(linkage[didHash] == 0x0);
        linkage[didHash] = msg.sender;
    }
    
    function changeLink(bytes didHash, address newAddress) {
        require(linkage[didHash] == msg.sender);
        linkage[didHash] = newAddress;
    }
    
    function getOwner(bytes didHash) constant returns(address) {
        return linkage[didHash];
    }
}