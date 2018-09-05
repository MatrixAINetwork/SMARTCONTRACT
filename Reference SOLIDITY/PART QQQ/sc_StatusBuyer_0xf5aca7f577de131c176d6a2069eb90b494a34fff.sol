/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

/*

Status Buyer
========================

Buys Status tokens from the crowdsale on your behalf.
Author: /u/Cintix

*/

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

// Interface to Status ICO Contract
contract StatusContribution {
  uint256 public totalNormalCollected;
  function proxyPayment(address _th) payable returns (bool);
}

// Interface to Status Cap Determination Contract
contract DynamicCeiling {
  function curves(uint currentIndex) returns (bytes32 hash, 
                                              uint256 limit, 
                                              uint256 slopeFactor, 
                                              uint256 collectMinimum);
  uint256 public currentIndex;
  uint256 public revealedCurves;
}

contract StatusBuyer {
  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public deposits;
  // Track the amount of SNT each account's "buy" calls have purchased from the ICO.
  // Allows tracking which accounts would have made it into the ICO on their own.
  mapping (address => uint256) public purchased_snt;
  // Bounty for executing buy.
  uint256 public bounty;
  // Track whether the contract has started buying tokens yet.
  bool public bought_tokens;
  
  // The Status Token Sale address.
  StatusContribution public sale = StatusContribution(0x0);
  // The Status DynamicCeiling Contract address.
  DynamicCeiling public dynamic = DynamicCeiling(0x0);
  // Status Network Token (SNT) Contract address.
  ERC20 public token = ERC20(0x0);
  // The developer address.
  address developer = 0x4e6A1c57CdBfd97e8efe831f8f4418b1F2A09e6e;
  
  // Withdraws all ETH/SNT owned by the user in the ratio currently owned by the contract.
  function withdraw() {
    // Store the user's deposit prior to withdrawal in a temporary variable.
    uint256 user_deposit = deposits[msg.sender];
    // Update the user's deposit prior to sending ETH to prevent recursive call.
    deposits[msg.sender] = 0;
    // Retrieve current ETH balance of contract (less the bounty).
    uint256 contract_eth_balance = this.balance - bounty;
    // Retrieve current SNT balance of contract.
    uint256 contract_snt_balance = token.balanceOf(address(this));
    // Calculate total SNT value of ETH and SNT owned by the contract.
    // 1 ETH Wei -> 10000 SNT Wei
    uint256 contract_value = (contract_eth_balance * 10000) + contract_snt_balance;
    // Calculate amount of ETH to withdraw.
    uint256 eth_amount = (user_deposit * contract_eth_balance * 10000) / contract_value;
    // Calculate amount of SNT to withdraw.
    uint256 snt_amount = 10000 * ((user_deposit * contract_snt_balance) / contract_value);
    // No fee for withdrawing if user would have made it into the crowdsale alone.
    uint256 fee = 0;
    // 1% fee on portion of tokens user would not have been able to buy alone.
    if (purchased_snt[msg.sender] < snt_amount) {
      fee = (snt_amount - purchased_snt[msg.sender]) / 100;
    }
    // Send the funds.  Throws on failure to prevent loss of funds.
    if(!token.transfer(msg.sender, snt_amount - fee)) throw;
    if(!token.transfer(developer, fee)) throw;
    msg.sender.transfer(eth_amount);
  }
  
  // Allow anyone to contribute to the buy execution bounty.
  function add_bounty() payable {
    // Update bounty to include received amount.
    bounty += msg.value;
  }
  
  // Buys tokens for the contract and rewards the caller.  Callable by anyone.
  function buy() {
    buy_for(msg.sender);
  }
  
  // Buys tokens in the crowdsale and rewards the given address.  Callable by anyone.
  // Enables Sybil attacks, wherein a single user creates multiple accounts with which
  // to call "buy_for" to reward their primary account.  Useful for bounty-seekers who
  // haven't sent ETH to the contract, but don't want to clean up Sybil dust, or for users
  // who have sent a large amount of ETH to the contract and want to reduce/avoid their fee.
  function buy_for(address user) {
    // Short circuit to save gas if the contract doesn't have any ETH left to buy tokens.
    if (this.balance == 0) return;
    // Store the current curve/cap index as temporary variable to avoid calling twice.
    uint256 currentIndex = dynamic.currentIndex();
    // Check whether the current curve/cap is the last one revealed so far.
    if ((currentIndex + 1) >= dynamic.revealedCurves()) {
      // Extract the buy limit of the current curve/cap.
      uint256 limit;
      (,limit,,) = dynamic.curves(currentIndex);
      // Short circuit to save gas if the ICO is currently at the cap, waiting for a reveal.
      if (limit <= sale.totalNormalCollected()) return;
    }
    // Record that the contract has started buying tokens.
    bought_tokens = true;
    // Store the contract's ETH balance prior to the purchase in a temporary variable.
    uint256 old_contract_eth_balance = this.balance;
    // Transfer all the funds (less the bounty) to the Status ICO contract 
    // to buy tokens.  Throws if the crowdsale hasn't started yet or has 
    // already completed, preventing loss of funds.
    sale.proxyPayment.value(this.balance - bounty)(address(this));
    // Verify contract ETH balance has not increased instead of decreased.
    if (this.balance > old_contract_eth_balance) throw;
    // Calculate ETH spent to buy tokens.
    uint256 eth_spent = old_contract_eth_balance - this.balance;
    // Update user's number of purchased SNT to include this purchase.
    purchased_snt[user] += (eth_spent * 10000);
    // Calculate the user's bounty proportionally to the amount purchased.
    uint256 user_bounty = (bounty * eth_spent) / (old_contract_eth_balance - bounty);
    // Update the bounty prior to sending ETH to prevent recursive call.
    bounty -= user_bounty;
    // Send the user their bounty for buying tokens for the contract.
    user.transfer(user_bounty);
  }
  
  // A helper function for the default function, allowing contracts to interact.
  function default_helper() payable {
    // Only allow deposits if the contract hasn't already purchased the tokens.
    if (!bought_tokens) {
      // Update records of deposited ETH to include the received amount.
      deposits[msg.sender] += msg.value;
    }
    // Withdraw the sender's ETH and SNT if the contract has started purchasing SNT.
    else {
      // Reject ETH sent after the contract has already purchased tokens.
      if (msg.value != 0) throw;
      // Withdraw user's funds if they sent 0 ETH to the contract after the ICO.
      withdraw();
    }
  }
  
  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    throw;  // Safety throw, which will be removed in deployed version.
    // Avoid recursively buying tokens when the sale contract refunds ETH.
    if (msg.sender != address(sale)) {
      // Delegate to the helper function.
      default_helper();
    }
  }
}