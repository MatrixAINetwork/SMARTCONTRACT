/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract RecoverEosKey {
    
    mapping (address => string) public keys;
    
    event LogRegister (address user, string key);
    
    function register(string key) public {
        assert(bytes(key).length <= 64);
        keys[msg.sender] = key;
        emit LogRegister(msg.sender, key);
    }
}