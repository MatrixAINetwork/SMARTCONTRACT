/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract MoonCatTools {
    bytes32 searchSeed = 0x8363e7eaae8e35b1c2db100a7b0fb9db1bc604a35ce1374d882690d0b1d888e2;
    
    function rescueCatHashCheck(bytes32 seed) constant returns (bytes32 catIdHash) {
        catIdHash = keccak256(seed, searchSeed);
        if (!(catIdHash[0] | catIdHash[1] | catIdHash[2] == 0x0)) {
            catIdHash = 0x0;
        }
    }
}