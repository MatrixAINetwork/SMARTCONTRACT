/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.8;
/*
AvatarNetwork Code Copyright

https://avatarnetwork.io
*/

contract Owned {

    address owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyowner() {
        if (msg.sender==owner) _;
    }

    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }
}

contract Token is Owned {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20Token is Token
{

    function transfer(address _to, uint256 _value) returns (bool success)
    {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract INCoin is ERC20Token
{
    function ()
    {
        throw;
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = '1.0';

    function INCoin ()
    {
        balances[msg.sender] = 10000000000000000000;
        totalSupply = 10000000000000000000;
        name = 'INCoin';
        decimals = 6;
        symbol = 'INC';
    }

    function add(uint256 _value) onlyowner  returns (bool success)
    {
        totalSupply += _value;
        balances[msg.sender] += _value;
        return true;
    }

    function burn(uint256 _value) onlyowner  returns (bool success)
    {
        if (balances[msg.sender] < _value) {
            return false;
        }
        totalSupply -= _value;
        balances[msg.sender] -= _value;
        return true;
    }
}