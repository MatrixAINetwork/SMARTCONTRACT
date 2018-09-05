/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract Lime7 {
    
    address public creatorad;

    function Lime7() {
        creatorad = msg.sender;
    }

    function feedme(uint256 amount) payable returns(bool success) {
        return true;
    }
    
    function payback(uint256 _amts) returns (string) {
        creatorad.transfer(_amts);
        return "good";
    }
    
    function get () constant returns (uint) {
        return this.balance;
    }

}