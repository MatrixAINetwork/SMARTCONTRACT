/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.4;


contract showNum {
    address owner = msg.sender;

    uint _num = 0;
   function setNum(uint number) public payable {
        _num = number;
    }

    function getNum() constant public returns(uint) {
        return _num;
    }
}