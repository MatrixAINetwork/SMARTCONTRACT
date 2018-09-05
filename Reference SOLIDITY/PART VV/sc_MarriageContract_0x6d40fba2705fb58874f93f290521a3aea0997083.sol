/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.21;

contract MarriageContract {
    
    address a;
    address b;
    uint256 till;
    string agreement;
    
    mapping(address => bool) coupleConfirmations;
    mapping(address => bool) witnesses;
    
    modifier onlyCouple(){
        require(msg.sender == a || msg.sender == b);
        _;
    }
    
    function MarriageContract(address _a, address _b, uint256 _till, string _agreement){
        a = _a;
        b = _b;
        till = _till;
        agreement = _agreement;
    }
    
    function married() constant returns (bool) {
        return coupleConfirmations[a] && coupleConfirmations[b];
    }
    
    function signContract() onlyCouple() {
        coupleConfirmations[msg.sender] = true;
    }
    
    function signWitness(){
        witnesses[msg.sender] = true;
    }
    
    function isWitness(address _address) constant returns (bool) {
        return witnesses[_address];
    }
    
}