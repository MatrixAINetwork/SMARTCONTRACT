/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.20;

contract Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) public returns (bool success) {}
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract SmiloToken is StandardToken {

    function () public {
        revert();
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';

    address private constant SMILO_COMMUNITY_WALLET = 0xaae742034cd06eb1a02c76603cc6264711dce5c3;
    uint public constant SMILO_COMMUNITY_AMOUNT = 15040000;

    address private constant SMILO_SALES_WALLET = 0x1caa94bb4122971176f009cf943780712cdf4062;
    uint public constant SMILO_SALES_AMOUNT = 84960000;

    address private constant SMILO_FOUNDERS_WALLET = 0xe9d4ba9f3d69ae7a2b1c4be89eac6238bafb6344;
    uint public constant SMILO_FOUNDERS_AMOUNT = 28000000;

    address private constant SMILO_FOUNDATION_WALLET = 0x6ab95a0c50f78e0bddb576b75bb1fb89f834c42f;
    uint public constant SMILO_FOUNDATION_AMOUNT = 72000000;

    function SmiloToken(
    ) public {
        balances[SMILO_COMMUNITY_WALLET] = SMILO_COMMUNITY_AMOUNT;
        balances[SMILO_SALES_WALLET] = SMILO_SALES_AMOUNT;
        balances[SMILO_FOUNDERS_WALLET] = SMILO_FOUNDERS_AMOUNT;
        balances[SMILO_FOUNDATION_WALLET] = SMILO_FOUNDATION_AMOUNT;
        totalSupply = 200000000;
        name = "Smilo";
        decimals = 0;
        symbol = "XSM";
    }

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}