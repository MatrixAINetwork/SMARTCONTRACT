/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;
//Copyright 2018 MiningRigRentals.com
contract ClientReceipt {
    event Deposit(address indexed _to, bytes32 indexed _id, uint _value);
    address public owner;
    function ClientReceipt() {
        owner = msg.sender;
    }
    function deposit(bytes32 _id) public payable {
        Deposit(this, _id, msg.value);
        if(msg.value > 0) {
            owner.transfer(msg.value);
        }
    }
    function () public payable { 
        Deposit(this, 0, msg.value);
        if(msg.value > 0) {
            owner.transfer(msg.value);
        }
    }
}