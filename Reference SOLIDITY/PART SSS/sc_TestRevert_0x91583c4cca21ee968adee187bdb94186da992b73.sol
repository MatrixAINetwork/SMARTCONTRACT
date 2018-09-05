/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract TestRevert {
    function test_require() public {
        require(now < 1000);
    }

    function test_assert() public {
        assert(now < 1000);
    }
}