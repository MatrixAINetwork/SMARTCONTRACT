/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract Nonce {
    event IncrementEvent(address indexed _sender, uint256 indexed _newNonce);
    uint256 value;
    
    function increment() public returns (uint256) {
        value = ++value;
        emit IncrementEvent(msg.sender, value);
        return value;
    }
    
    function getValue() public view returns (uint256) {
        return value;
    }
}