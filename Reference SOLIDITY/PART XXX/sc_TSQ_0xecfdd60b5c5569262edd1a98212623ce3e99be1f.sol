/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.0;

contract TSQ {

    address public jak;
    bool public is_open = true;

    function TSQ() {
        jak = msg.sender;
    }

    function open() {
        if (msg.sender != jak) return;
        is_open = true;
    }

    function close() {
        if (msg.sender != jak) return;
        is_open = false;
    }
}