/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract PublicProfile {
    mapping (address => string) nicknames;
    mapping (address => string) pictures;
    
    function setNickname (string _nickname) public {
        nicknames[msg.sender] = _nickname;
    }
    
    function setPicture (string _url) public {
        pictures[msg.sender] = _url;
    }
    
    function setInfo (string _nickname, string _url) public {
        setNickname(_nickname);
        setPicture(_url);
    }
    
    function getInfo (address _addr) public view returns (string, string) {
        return (nicknames[_addr], pictures[_addr]);
    }
}