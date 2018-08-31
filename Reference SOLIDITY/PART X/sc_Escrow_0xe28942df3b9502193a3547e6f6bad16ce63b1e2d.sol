/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract Escrow {
    mapping (address => uint) public balances;

    function deposit(address _recipient) payable {
        require(msg.value > 0);
        balances[_recipient] += msg.value;
    }

    function claim() {
        uint balance = balances[msg.sender];
        require(balance > 0);

        balances[msg.sender] = 0;
        bool claimed = msg.sender.call.value(balance)();

        require(claimed);
    }
}