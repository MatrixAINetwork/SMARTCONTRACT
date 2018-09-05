/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract TokenRate {
    uint public USDValue;
    uint public EURValue;
    uint public GBPValue;
    uint public BTCValue;
    address public owner = msg.sender;

    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }

    function setValues(uint USD, uint EUR, uint GBP, uint BTC) ownerOnly public {
        USDValue = USD;
        EURValue = EUR;
        GBPValue = GBP;
        BTCValue = BTC;
    }
}