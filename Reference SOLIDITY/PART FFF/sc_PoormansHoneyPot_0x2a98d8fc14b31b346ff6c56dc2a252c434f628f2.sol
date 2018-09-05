/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.23;

contract PoormansHoneyPot {
    mapping (address => uint) public balances;

    constructor() public payable {
        store();
    }

    function store() public payable {
        balances[msg.sender] = msg.value;
    }

    function withdraw() public{
        assert (msg.sender.call.value(balances[msg.sender])()) ;
        balances[msg.sender] = 0;
    }


}