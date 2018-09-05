/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.11;

contract Token {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed to, uint256 value);

    //Modifiers

    modifier when_can_transfer(address _from, uint256 _value) {
        require (balances[_from] >= _value);
        _;
    }

    modifier when_can_receive(address _recipient, uint256 _value) {
        require (balances[_recipient] + _value > balances[_recipient]);
        _;
    }

    modifier when_is_allowed(address _from, address _delegate, uint256 _value) {
        require (allowed[_from][_delegate] >= _value);
        _;
    }

    // Constructor
    function Token(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) {
        balances[msg.sender] = initialSupply;
        totalSupply = initialSupply;
        decimals = decimalUnits;
        symbol = tokenSymbol;
        name = tokenName;
    }

    function totalSupply() constant returns (uint256 _totalSupply) {
        _totalSupply = totalSupply;
    }


    // What is the balance of a particular account?
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount)
      when_can_transfer(msg.sender, _amount)
      when_can_receive(_to, _amount)
      returns (bool success) {
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism:
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    )
      when_can_transfer(_from, _amount)
      when_can_receive(_to, _amount)
      when_is_allowed(_from, msg.sender, _amount)
      returns (bool success) {
        allowed[_from][msg.sender] -= _amount;
        balances[_from] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Fallback function throws when called.
    function() {
      require(true);
    }
}