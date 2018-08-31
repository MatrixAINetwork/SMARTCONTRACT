/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.13;

contract Escrow {
  address public owner;
  uint public fee;
  mapping (address =>  mapping (address => uint)) public balances;

  function Escrow() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setFee(uint price) onlyOwner external {
    fee = price;
  }

  function start(address payee) payable external {
    balances[msg.sender][payee] = balances[msg.sender][payee] + msg.value;
  }

  function end(address payer, address payee) onlyOwner external returns(bool){
    uint value = balances[payer][payee];
    uint paidFee = value / (1000000 / fee);
    uint payment = value - paidFee;
    balances[payer][payee] = 0;
    payee.transfer(payment);
    owner.transfer(paidFee);
    return true;
  }
  
  function refund(address payer, address payee) onlyOwner external returns(bool){
    uint value = balances[payer][payee];
    balances[payer][payee] = 0;
    payer.transfer(value);
    return true;
  }
}