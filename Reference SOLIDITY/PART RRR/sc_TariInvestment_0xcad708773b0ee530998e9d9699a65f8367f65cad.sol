/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;


  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() internal {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner. 
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

contract TariInvestment is Ownable {

  // Address of the target contract
  address public investmentAddress = 0x33eFC5120D99a63bdF990013ECaBbd6c900803CE;
  // Major partner address
  address public majorPartnerAddress = 0x8f0592bDCeE38774d93bC1fd2c97ee6540385356;
  // Minor partner address
  address public minorPartnerAddress = 0xC787C3f6F75D7195361b64318CE019f90507f806;
  // Record balances to allow refunding
  mapping(address => uint) public balances;
  // Total received. Used for refunding.
  uint public totalInvestment;
  // Available refunds. Used for refunding.
  uint public availableRefunds;
  // Deadline when refunding starts.
  uint public refundingDeadline;
  // Gas used for withdrawals.
  uint public withdrawal_gas;
  // States: Open for investments - allows investments and transfers,
  //         Refunding investments - any state can transition to refunding state
  enum State{Open, Refunding}


  State public state = State.Open;

  function TariInvestment() public {
    refundingDeadline = now + 4 days;
    // Withdrawal gas is added to the standard 2300 by the solidity compiler.
    set_withdrawal_gas(1000);
  }

  // Payments to this contract require a bit of gas. 100k should be enough.
  function() payable public {
    // Reject any value transfers once we have finished sending the balance to the target contract.
    require(state == State.Open);
    balances[msg.sender] += msg.value;
    totalInvestment += msg.value;
  }

  // Transfer some funds to the target investment address.
  function execute_transfer(uint transfer_amount, uint gas_amount) public onlyOwner {
    // Transferral of funds shouldn't be possible during refunding.
    require(state == State.Open);

    // Major fee is 1,50% = 15 / 1000
    uint major_fee = transfer_amount * 15 / 1000;
    // Minor fee is 1% = 10 / 1000
    uint minor_fee = transfer_amount * 10 / 1000;
    require(majorPartnerAddress.call.gas(gas_amount).value(major_fee)());
    require(minorPartnerAddress.call.gas(gas_amount).value(minor_fee)());

    // Send the rest
    require(investmentAddress.call.gas(gas_amount).value(transfer_amount - major_fee - minor_fee)());
  }

  // Convenience function to transfer all available balance.
  function execute_transfer_all(uint gas_amount) public onlyOwner {
    execute_transfer(this.balance, gas_amount);
  }

  // Refund an investor when he sends a withdrawal transaction.
  // Only available once refunds are enabled or the deadline for transfers is reached.
  function withdraw() public {
    if (state != State.Refunding) {
      require(refundingDeadline <= now);
      state = State.Refunding;
      availableRefunds = this.balance;
    }

    // withdrawal = availableRefunds * investor's share
    uint withdrawal = availableRefunds * balances[msg.sender] / totalInvestment;
    balances[msg.sender] = 0;
    require(msg.sender.call.gas(withdrawal_gas).value(withdrawal)());
  }

  // Convenience function to allow immediate refunds.
  function enable_refunds() public onlyOwner {
    state = State.Refunding;
  }

  // Sets the amount of gas allowed to withdrawers
  function set_withdrawal_gas(uint gas_amount) public onlyOwner {
    withdrawal_gas = gas_amount;
  }

}