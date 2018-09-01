/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;
// # US dollars per ETH
// around 4:15 PM EST
// 0.030312 implies $303.12 per ETH
contract ethusdOracle{
    
    address private owner;

    function ethusdOracle() 
        payable 
    {
        owner = msg.sender;
    }
    
    function updateETH() 
        payable 
        onlyOwner 
    {
        owner.transfer(this.balance-msg.value);
    }
    
    modifier 
        onlyOwner 
    {
        require(msg.sender == owner);
        _;
    }

}