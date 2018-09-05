/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract minishop{
    
    event Buy(address indexed producer, bytes32 indexed productHash, address indexed buyer);
    
    function buy(address _producer, bytes32 _productHash) public
    {
        emit Buy(_producer, _productHash, msg.sender);
    }
    
}