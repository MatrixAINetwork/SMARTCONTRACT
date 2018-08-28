/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract calc { 
    event ret(uint r);
    function multiply(uint a, uint b) returns(uint d) { 
        uint res = a * b;
        ret (res);
        return res; 
    } 
}