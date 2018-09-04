/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;
contract holdEthereum {
    event Hodl(address indexed hodler, uint indexed amount);
    event Party(address indexed hodler, uint indexed amount);
    mapping (address => uint) holders;
    
    uint constant partyTime = 1596067200; // Time funds can be withdrawn. 30th July 2020
    
    function() payable {
        holders[msg.sender] += msg.value;
        Hodl(msg.sender, msg.value);
    }
    
    function party() {
        if (block.timestamp < partyTime) throw;
        uint value = holders[msg.sender];
        if (value == 0) throw;
        holders[msg.sender] = 0;
        msg.sender.transfer(value);
        Party(msg.sender, value);
    }
}