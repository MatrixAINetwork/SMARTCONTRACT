/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
/*
  Copyright (c) 2015-2016 Oraclize SRL
  Copyright (c) 2016 Oraclize LTD
*/

contract OraclizeAddrResolver {

    address public addr;

    address owner;

    function OraclizeAddrResolver(){
        owner = msg.sender;
    }

    function changeOwner(address newowner){
        if (msg.sender != owner) throw;
        owner = newowner;
    }

    function getAddress() returns (address oaddr){
        return addr;
    }

    function setAddr(address newaddr){
        if (msg.sender != owner) throw;
        addr = newaddr;
    }

}