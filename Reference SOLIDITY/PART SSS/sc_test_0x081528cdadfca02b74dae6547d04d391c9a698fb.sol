/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

contract test {
    // Get balace of an account.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return 34500000000000000000;
    }
    // Transfer function always returns true.
    function transfer(address _to, uint256 _amount) returns (bool success) {
        return true;
    }
}