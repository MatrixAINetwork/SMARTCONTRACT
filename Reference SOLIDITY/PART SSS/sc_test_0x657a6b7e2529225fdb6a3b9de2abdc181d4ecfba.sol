/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract test {

    modifier notzero1(address _addr) {
        require(_addr != address(0x0));
        _;
    }

    modifier notzero2(address _addr) {
        require(_addr != address(0x0), "something is wrong");
        _;
    }

    function viewa1(address _addr) notzero1(_addr) public pure returns (uint256) 
    {
        return 100;
    }

    function viewa2(address _addr) notzero2(_addr) public pure returns (uint256) 
    {
        return 200;
    }

}