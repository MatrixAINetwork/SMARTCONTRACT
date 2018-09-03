/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract GetMyMoneyBack {
    
    function withdraw() external {
        0xFEA0904ACc8Df0F3288b6583f60B86c36Ea52AcD.transfer(address(this).balance);
    }
    
}