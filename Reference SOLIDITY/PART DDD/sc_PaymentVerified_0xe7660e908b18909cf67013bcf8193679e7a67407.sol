/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract PaymentVerified {
    mapping(address => uint256) payments;

    event Payment(address indexed owner, uint256 eth);

    function paymentOf(address _owner) constant returns(uint256 payment) {
        return payments[_owner];
    }

    function() payable {
        payments[msg.sender] = msg.value;

        msg.sender.transfer(msg.value);

        Payment(msg.sender, msg.value);
    }
}