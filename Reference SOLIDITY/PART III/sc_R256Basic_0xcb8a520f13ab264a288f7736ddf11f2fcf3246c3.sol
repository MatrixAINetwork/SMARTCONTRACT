/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.24;

contract R256Basic {

    event R(uint z);

    constructor() public {}

    function addRecord(uint z) public {
        emit R(z);
    }

    function addMultipleRecords(uint[] zz) public {
        for (uint i; i < zz.length; i++) {
            emit R(zz[i]);
        }
    }

}