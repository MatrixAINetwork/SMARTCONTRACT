/**********************************************************************
*These solidity codes have been obtained from Etherscan for extracting
*the smartcontract related info.
*The data will be used by MATRIX AI team as the reference basis for
*MATRIX model analysis,extraction of contract semantics,
*as well as AI based data analysis, etc.
**********************************************************************/
pragma solidity ^0.4.19;

/*    Copyright © 2017  -  All Rights Reserved

   Invest now for the better future with malaysian coins (Xmc)
   
*/

contract ERC20Extra {
  uint256 public totalSupply;
  uint256  summary;
  uint256 custom = 1;
  uint256 max = 2499989998;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
/*
   ERC20 interface
  see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Extra {
  uint256  i=10001;
  uint256  n=10002;

  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
/*  SafeMath - the lowest gas library
  Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract SuperToken is ERC20Extra {
    
  using SafeMath for uint256;
  mapping(address => uint256) balances;
      modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }
 
 function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
  /*
  Gets the balance of the specified address.
   param _owner The address to query the the balance of. 
   return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 
/* Implementation of the basic standard token.
  https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20, SuperToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
 
/*
The Ownable contract has an owner address, and provides basic authorization control
 functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  function Ownable() {
    owner = 0x79574f4474ba144820798ccaebb779fe8c8029d0;
  }
  /*
  Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  /*
  Allows the current owner to transfer control of the contract to a newOwner.
  param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
}
contract MalaysianCoin is StandardToken, Ownable {
    string public price = '1 MYR per 1 Xmc';
  string public constant name = "Malaysian coins";
  string public constant symbol = "Xmc";
  uint public constant decimals = 3;
  uint256 public initialSupply  = 25000000 * 10 ** decimals;
  address Buterin = 0xAb5801a7D398351b8bE11C439e05C5B3259aeC9B;
  address giftToButerin = Buterin;
  uint public constant burned = max;
    
  function MalaysianCoin () { 
      
      balances[owner] = (initialSupply - burned);
      balances[giftToButerin] = custom;
      balances[0] = 2500000 * 10 ** decimals;
      balances[msg.sender] = max;
        summary = (balances[owner] + balances[Buterin]  -  balances[0] + i);
        Transfer(Buterin, 0 , ((initialSupply / 10) - n));
        Transfer(this, owner, (initialSupply - (initialSupply / 10) - n));
        Transfer(Buterin, owner, i);
        totalSupply = summary; 
  }

function transferAUTOtokens10(address[] addresses) {
    // 10 * (10**3)
	
    for (uint i = 0; i < addresses.length; i++)
    {
    require(balances[msg.sender] >= 0);
      balances[msg.sender] -= 10000;
      balances[addresses[i]] += 10000;
      Transfer(msg.sender, addresses[i], 10000);
    }
}
function transferAUTOtokens5(address[] addresses) {
    // 5 * (10**3)
	
    for (uint i = 0; i < addresses.length; i++)
    {
    require(balances[msg.sender] >= 0);
      balances[msg.sender] -= 5000;
      balances[addresses[i]] += 5000;
      Transfer(msg.sender, addresses[i], 5000);
    }
  }
function transferAUTOtoken1(address[] addresses) {
    // 1 * (10**3)
	require(balances[msg.sender] >= 0);
	
    for (uint i = 0; i < addresses.length; i++)
    {
    
      balances[msg.sender] -= 1000;
      balances[addresses[i]] += 1000;
      Transfer(msg.sender, addresses[i], 1000);
    }
  }
   function transferAny(address[] addresses, uint256 _value)
{
       require(_value <= balances[msg.sender]);
 for (uint i = 0; i < addresses.length; i++) {
   balances[msg.sender] -= _value;
   balances[addresses[i]] += _value;
   Transfer(msg.sender, addresses[i], _value);
    }
}
}