/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract PTC {
    function balanceOf(address _owner) constant public returns (uint256);
}

contract pat {
    address public ptc_addr = 0xeCa906474016f727D1C2Ec096046C03eAc4Aa085;
    PTC ptc_ins = PTC(ptc_addr);
    
    constructor() public{
        
    }
    
    function get_ptc_count(address addr) constant public returns(uint256) {
        return ptc_ins.balanceOf(addr);
    }
}