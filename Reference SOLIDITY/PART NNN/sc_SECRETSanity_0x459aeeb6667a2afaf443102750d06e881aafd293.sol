/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
// Author : shift

pragma solidity ^0.4.13;

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  function transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}

contract SECRETSanity {

  modifier onlyOwner {
    require(msg.sender == developer);
    _;
  }

  // Store the amount of ETH deposited by each account.
  mapping (address => uint256) public balances;
  // Track whether the contract has bought the tokens yet.
  bool public bought_tokens = false;
  // Record ETH value of tokens currently held by contract.
  uint256 public contract_eth_value;
  uint256 constant public min_amount = 365 ether;
  // The crowdsale address.
  address public sale;
  // Token address
  ERC20 public token;
  address constant public developer = 0xEE06BdDafFA56a303718DE53A5bc347EfbE4C68f;
  
  // Allows any user to withdraw his tokens.
  function withdraw() {
    // Disallow withdraw if tokens haven't been bought yet.
    require(bought_tokens);
    uint256 contract_token_balance = token.balanceOf(address(this));
    // Disallow token withdrawals if there are no tokens to withdraw.
    require(contract_token_balance != 0);
    // Store the user's token balance in a temporary variable.
    uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
    // Update the value of tokens currently held by the contract.
    contract_eth_value -= balances[msg.sender];
    // Update the user's balance prior to sending to prevent recursive call.
    balances[msg.sender] = 0;
    // Send the funds.  Throws on failure to prevent loss of funds.
    require(token.transfer(msg.sender, tokens_to_withdraw));
  }
  
  // Allows any user to get his eth refunded before the purchase is made.
  function refund_me() {
    require(!bought_tokens);
    // Store the user's balance prior to withdrawal in a temporary variable.
    uint256 eth_to_withdraw = balances[msg.sender];
    // Update the user's balance prior to sending ETH to prevent recursive call.
    balances[msg.sender] = 0;
    // Return the user's funds.  Throws on failure to prevent loss of funds.
    msg.sender.transfer(eth_to_withdraw);
  }
  
  // Buy the tokens. Sends ETH to the presale wallet and records the ETH amount held in the contract.
  function buy_the_tokens() onlyOwner {
    require(!bought_tokens);
    require(sale != 0x0);
    // Record that the contract has bought the tokens.
    bought_tokens = true;
    // Record the amount of ETH sent as the contract's current value.
    contract_eth_value = this.balance;
    // Transfer all the funds to the crowdsale address.
    sale.transfer(contract_eth_value);
  }
  
  function set_sale_address(address _sale) onlyOwner {
    require(!bought_tokens);
    sale = _sale;
  }

  function set_token_address(address _token) onlyOwner {
    token = ERC20(_token);
  }

  // Default function.  Called when a user sends ETH to the contract.
  function () payable {
    require(!bought_tokens);
    //Fee is taken on the ETH
    uint256 fee = msg.value / 50;
    developer.transfer(fee);
    balances[msg.sender] += (msg.value-fee);
  }
}