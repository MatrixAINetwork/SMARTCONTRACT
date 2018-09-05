/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity 0.4.24;

contract JNS {
    mapping (string => address) strToAddr;
    mapping (address => string) addrToStr;
    address private wallet;

    constructor (address _wallet) public {
        require(_wallet != address(0), "You must inform a valid address");
        wallet = _wallet;
    }
    
    function registerAddress (string _nickname, address _address) public payable returns (bool) {
        require (msg.value > 1000000000000000, "Send more money");
        require (strToAddr[_nickname] == address(0), "Name already registered");
        require (keccak256(addrToStr[_address]) == keccak256(""), "Address already registered");
        
        strToAddr[_nickname] = _address;
        addrToStr[_address] = _nickname;

        wallet.transfer(msg.value);
        return true;
    }
    
    function getAddress (string _nickname) public view returns (address _address) {
        _address = strToAddr[_nickname];
    }
    
    function getNickname (address _address) public view returns (string _nickname) {
        _nickname = addrToStr[_address];
    }
}