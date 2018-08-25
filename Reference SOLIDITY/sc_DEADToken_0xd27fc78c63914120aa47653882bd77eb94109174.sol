/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.18;

contract DEADToken {
  // Balances for each account
  mapping (address => uint) public balances;
  // Owner of account approves the transfer of an amount to another account
  mapping (address => mapping (address => uint)) public allowed;

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  /// @notice Get the token balance `_owner`
  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public constant returns (uint) {
    return allowed[_owner][_spender];
  }

  /// @notice Send `_value` from `msg.sender` to `_to`
  /// @param _to The address of the recipient
  /// @param _value The amount to send
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @notice Send `_value` tokens to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount to send
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]);
    balances[_to] += _value;
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
  }

  /// @notice Allows `_spender` to spend no more than `_value` tokens
  /// @param _spender The address authorized to spend
  /// @param _value The max amount they can spend
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Increase the amount of tokens that an owner allowed to a spender.
  /// approve should be called when allowed[_spender] == 0. To increment
  /// allowed value is better to use this function to avoid 2 calls (and wait until
  /// the first transaction is mined)
  /// From MonolithDAO Token.sol
  /// @param _spender The address which will spend the funds.
  /// @param _addedValue The amount of tokens to increase the allowance by.
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] += _addedValue;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /// @dev Decrease the amount of tokens that an owner allowed to a spender.
  /// approve should be called when allowed[_spender] == 0. To decrement
  /// allowed value is better to use this function to avoid 2 calls (and wait until
  /// the first transaction is mined)
  /// From MonolithDAO Token.sol
  /// @param _spender The address which will spend the funds.
  /// @param _subtractedValue The amount of tokens to decrease the allowance by.
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue - _subtractedValue;
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  uint8 public decimals = 8;
  uint public initialSupply = 10000000;
  uint public totalSupply = initialSupply * 10 ** uint(decimals); // 10,000,000.00000000;
  string public name = "Dead Unicorn";
  string public symbol = "DEAD";

  function DEADToken() public {
    balances[msg.sender] = totalSupply;
  }
}