/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.16;

contract test
{
    event AAA(address indexed sender, uint x);
    
    function aaa(bytes data) public
    {
        uint x = _bytesToUint(data);
        AAA(msg.sender, x);
    }
    
    function _bytesToUint(bytes data) internal view returns (uint) {
        uint num = 0;
        for(uint i = 0; i < data.length; i++) {
            num += uint(data[i]);
            if(i != data.length - 1)
                num *= 256;
        }
        return num;
    }
}