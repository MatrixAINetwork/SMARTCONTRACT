/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
contract PullPayment {
  mapping(address => uint) public payments;
  event RefundETH(address to, uint value);
  // store sent amount as credit to be pulled, called by payer
  function asyncSend(address dest, uint amount) internal {
    payments[dest] += amount;
  }

  // withdraw accumulated balance, called by payee
  function withdrawPayments() {
    address payee = msg.sender;
    uint payment = payments[payee];
    
    if (payment == 0) {
      throw;
    }

    if (this.balance < payment) {
      throw;
    }

    payments[payee] = 0;

    if (!payee.send(payment)) {
      throw;
    }
    RefundETH(payee,payment);
  }
}