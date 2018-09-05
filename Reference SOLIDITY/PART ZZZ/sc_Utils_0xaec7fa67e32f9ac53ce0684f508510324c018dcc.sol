/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;


contract makerDAO {
    function read() view public returns(bytes32);
}


/// @title Kyber constants contract
contract Utils {
    function toUint(bytes32 x) view public returns(uint) {
        return uint(x);
    }
    
    function test1() view public returns(uint){
        bytes32 y = bytes32(0x123456);
        return toUint(y);
    }
    
    function testDAO() view public returns(uint) {
        return toUint(makerDAO(0x729D19f657BD0614b4985Cf1D82531c67569197B).read());
    }
}