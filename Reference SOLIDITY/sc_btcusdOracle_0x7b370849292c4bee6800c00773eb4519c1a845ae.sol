/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;
// # US dollars per BTC
// around 4:15 PM EST
// 0.0732412 implies $7324.12 per BTC
contract btcusdOracle{
    
    address private owner;

    function btcusdOracle() 
        payable 
    {
        owner = msg.sender;
    }
    
    function ubdateBTC() 
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